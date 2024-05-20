from flask import Flask, request
from flask_cors import CORS
from api_request import *

app = Flask(__name__)
CORS(app)

@app.route('/submit', methods=['POST'])
def submit():
    data = request.json
    print('Received data:', data)
    request_auth(data)
    return 'Data received', 200

@app.route('/complete', methods=['POST'])
def complete():
    # Simulate a successful or failed authentication
    return 'Completed', 200  # Return 200 for success, 400 or other for failure


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
