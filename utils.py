import os
from collections import deque

import cv2
import numpy as np
import tensorflow as tf
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

os.environ['CUDA_VISIBLE_DEVICES'] = '-'  # Edge에서 이용하는 것이 목표이므로 GPU를 이용하지 않음\

question1 = ['허벅지', '무릎', '발목', '발가락', '코', '귀', '손목', '얼굴', '어깨', '팔꿈치', '손', '가슴', '등', '배', '갈비뼈', '골반', '관절', '근육',
             '기도', '뇌', '두개골', '맹장', '목구멍', '성대', '식도', '심장', '엉덩이', '이마', '입속', '입술', '전립선', '질', '척추', '치아', '턱',
             '피부', '혀', '눈', '다리', '머리']
question2 = ['오른쪽', '앞', '왼쪽', '사이', '뒤', '가운데', '경계', '바깥', '반대', '속', '안팎', '이쪽', '전부']
question3 = ['토하다', '가렵다', '괜찮다', '괴롭다', '띵하다', '목마르다', '배탈', '아프다', '약하다', '어지럽다', '조마조마하다', '차다', '힘겹다']
question4 = ['아니오', '예']
questions = [None, question1, question2, question3, question4]
label_numbers = [None, 40, 13, 13, 2]
null_hand = [0 for _ in range(126)]

base_options = python.BaseOptions(model_asset_path='hand_landmarker.task')
options = vision.HandLandmarkerOptions(base_options=base_options, num_hands=2)
detector = vision.HandLandmarker.create_from_options(options)
mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5)


def get_prediction(q_num, video):
    def infer(q_num, video):
        model = tf.keras.models.load_model('q' + str(q_num) + '.h5')
        video = np.array(video)
        video = video.reshape(1, 30, 1662)
        result = model.predict(video)
        return np.argmax(result)

    def extract_keypoints(results):
        pose = np.array([[res.x, res.y, res.z, res.visibility] for res in
                         results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(33 * 4)
        face = np.array([[res.x, res.y, res.z] for res in
                         results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(
            468 * 3)
        lh = np.array([[res.x, res.y, res.z] for res in
                       results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(
            21 * 3)
        rh = np.array([[res.x, res.y, res.z] for res in
                       results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(
            21 * 3)
        return np.concatenate([pose, face, lh, rh])

    def mediapipe_detection(image, model):
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False
        results = model.process(image)
        image.flags.writeable = False
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
        return image, results

    video = cv2.VideoCapture(video)
    label_counts = [0 for _ in range(label_numbers[q_num])]
    sequences = deque()
    hand_exits = False
    while True:
        ret, image = video.read()
        if not ret:
            break
        image, results = mediapipe_detection(image, holistic)
        keypoints = np.array(extract_keypoints(results), dtype="float64")
        if hand_exits:
            sequences.append(keypoints)
        elif np.array_equal(keypoints[1536:], null_hand):
            continue
        else:
            hand_exits = True
            sequences.append(keypoints)

        if len(sequences) == 30:
            temp = infer(q_num, sequences)
            label_counts[temp] += 1
            sequences.popleft()

        elif len(sequences) < 30:
            continue

    return questions[q_num][np.argmax(label_counts)]


class ProcessVideo():
    def __init__(self, q_num, video):
        self.q_num = q_num
        self.video = video

    def __call__(self):
        return get_prediction(self.q_num, self.video)