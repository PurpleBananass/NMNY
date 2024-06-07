from flask import Flask, request
from flask_cors import CORS
from api_request import *

app = Flask(__name__)
CORS(app)

@app.route('/submit', methods=['POST'])
def submit():
    data = request.json
    # print('Received data:', data)
    res = request_auth(data)
    print("DAATTAAAQ")
    print(res)
    # res = ""
    with open('./data.json', 'w', encoding='utf-8') as f:
        json.dump(res, f, ensure_ascii=False, indent=4)
        f.close()
    return 'Data received', 200

@app.route('/complete', methods=['POST'])
def complete():
    rrn = request.json.get('rrn')
    print('Received RRN for completion:', rrn)
    f = open('./data.json')
    

    # # returns JSON object as 
    # # a dictionary
    data = json.load(f)
    # # data = json.dumps(data)
    # print(data["ResultData"]["CxId"])
    # # data = data.json()
    med = med_info(data["ResultData"],rrn)
    with open('./med.json', 'w', encoding='utf-8') as f:
        json.dump(med, f, ensure_ascii=False, indent=4)
        f.close()
    return 'Completed', 200  # Return 200 for success, 400 or other for failure
@app.route('/api/medication', methods=['GET'])
def get_medication():
    print("SSS")
    f = open('./med.json')
    

    # # returns JSON object as 
    # # a dictionary
    data = json.load(f)
    response = app.response_class(
        response=json.dumps(data),
        status=200,
        mimetype='application/json'
    )
    # # data = json.dumps(data)
    # print(data["ResultData"]["CxId"])
    # # data = data.json()

    return response  # Return 200 for success, 400 or other for failure


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
