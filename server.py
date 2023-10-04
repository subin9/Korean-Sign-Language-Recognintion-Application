from flask import Flask, jsonify, request
from infer import infer
app = Flask(__name__)

@app.route('/classify', methods=['POST'])

def predict():
    try:
        if request.method=='POST':
            file = request.files['file']
            file.save('./video.mp4')
            num = int(request.form['num'])
        video = './video.mp4'
        return jsonify({'result':infer(num,video)})
    except Exception as e:
        print(e)
        return jsonify({'result':'error'}), 500
app.run(host="0.0.0.0",port=19980)