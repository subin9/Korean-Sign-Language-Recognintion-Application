# Korean-Sign-Language-Recognintion-Application

--------------------------------본 repo는 제작자의 시험 기간으로 인해 미완인 상태입니다.--------------------------------</br>
급하게 만들어져 모델 구조와 성능이 마음에 들지 않아 대대적인 수정이 있을 예정입니다. 우선 대회 제출본을 기재합니다.</br>

## About project

SNU ambient AI Bootcamp & Competition 1위 수상작으로, 응급 상황에서의 수어 통역을 위한 어플리케이션입니다.</br>

응급 상황에 필수적인 4개의 질문에 대해, 정해진 답 중 가장 가까운 대답을 찾아줍니다.</br>

4개의 질문과 답은 다음과 같습니다.</br>

(TODO: 단어 목록 수정 및 영상 재촬영)
  * Q1. 어느 신체 부위가 아프신가요?</br>
Expected answer: 허벅지, 무릎, 발목, 발가락, 코, 귀, 손목, 얼굴, 어깨, 팔꿈치, 손, 가슴, 등, 배, 갈비뼈, 골반, 관절, 근육, 기도, 뇌, 두개골, 맹장, 목구멍, 성대, 식도, 심장, 엉덩이, 이마, 입속, 입술, 전립선, 질, 척추, 치아, 턱, 피부, 혀, 눈, 다리, 머리 (총 40개)
  * Q2. 구체적으로 어느 부분이 아프신가요?</br>
Expected answer: 오른쪽, 앞, 왼쪽, 사이, 뒤, 가운데, 경계, 바깥, 반대, 속, 안팎, 이쪽, 전부 (총 13개)
  * Q3. 어떻게 아프신가요?</br>
Expected answer: 토하다, 가렵다, 괜찮다, 괴롭다, 띵하다, 목마르다, 배탈, 아프다, 약하다, 어지럽다, 조마조마하다, 차다, 힘겹다 (총 13개)
  * Q4. (여자일 경우) 임신하셨나요?</br>
Expected answer: 네, 아니오 (총 2개)

## Training data
(TODO: 데이터 추가 확보 및 교체 작업 진행 및 트레이닝 코드 이용가능한 형태로 제공)</br>
직접 촬영한 데이터들과 [KETI 수어 데이터셋](https://www.aihub.or.kr/aihubdata/data/view.do?currMenu=120&topMenu=100&dataSetSn=264&aihubDataSe=extrldata)에서 추출한 landmark들을 학습에 이용하였습니다.</br>
Landmark는 [mediapipe holistic landmark detection model](https://developers.google.com/mediapipe/solutions/vision/holistic_landmarker)을 이용하여 추출했고, hand, face, pose로 총 543개의 point들이 추출되었습니다.</br>
이 543개의 point들은 pose의 경우에는 x, y, z, visibility 4개의 값으로, 그 외에는 x, y, z 값으로 총 1662개의 integer로 표현됩니다.</br>
한 frame당 1662개씩의 값이 추출되어 이용되었고, 이를 통해 feature로 이용하여 분류를 진행했습니다.</br>
손이 없는 frame은 오히려 noise로 작용할 수 있다는 생각이 들어 '처음 손이 등장하는 frame' 부터 '마지막으로 손이 등장하는 frame'을 이용했습니다.</br>


## Model
(TODO: 최신 연구 동향 확인 후 모델 구조 수정)</br>
모델은 GRU Layer 3개와 Dense Layer 두 개를 이용하여 제작되었습니다. 가능한 한 가벼운 모델을 만들고자 했습니다.</br>

![image](https://github.com/subin9/Korean-Sign-Language-Recognintion-Application/assets/101092510/a5f1bb07-a551-4248-8b38-87dc9a7b51db)</br>
