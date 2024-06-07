from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import json

app = Flask(__name__)
CORS(app)

# MySQL configuration
db_config = {
    'user': 'root',
    'password': 'Ljhb!106424',
    'host': 'localhost',
    'database': 'med_info_db'
}


def add_data_from_json(json_file_path, user_id, user_name):
    # Read the JSON file
    with open(json_file_path, 'r', encoding='utf-8') as file:
        med_info = json.load(file)

    try:
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()

        # Insert user information
        cursor.execute(
            "INSERT INTO users (user_id, user_name) VALUES (%s, %s) ON DUPLICATE KEY UPDATE user_name=%s",
            (user_id, user_name, user_name)
        )
        connection.commit()

        # Insert medication information
        for med in med_info['ResultList']:
            cursor.execute(
                "INSERT INTO medications (user_id, med_no, date_of_preparation, dispensary, phone_number) VALUES (%s, %s, %s, %s, %s)",
                (user_id, med['No'], med['DateOfPreparation'], med['Dispensary'], med['PhoneNumber'])
            )
            med_id = cursor.lastrowid

            # Insert drug information
            for drug in med['DrugList']:
                cursor.execute(
                    "INSERT INTO drugs (med_id, drug_no, effect, code, name, component, quantity, dosage_per_once, daily_dose, total_dosing_days) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (med_id, drug['No'], drug['Effect'], drug['Code'], drug['Name'], drug['Component'], drug['Quantity'], drug['DosagePerOnce'], drug['DailyDose'], drug['TotalDosingDays'])
                )

        connection.commit()
        print("Data submitted successfully")

    except mysql.connector.Error as err:
        print(f"Error: {err}")

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()



def query_database_to_json(user_id):
    try:
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor(dictionary=True)

        # Query user information
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        user = cursor.fetchone()
        if not user:
            return json.dumps({"Error": "User not found"})

        # Query medications information
        cursor.execute("SELECT * FROM medications WHERE user_id = %s", (user_id,))
        medications = cursor.fetchall()

        result_list = []
        for med in medications:
            cursor.execute("SELECT * FROM drugs WHERE med_id = %s", (med['id'],))
            drugs = cursor.fetchall()
            med_dict = {
                "No": med['med_no'],
                "DateOfPreparation": med['date_of_preparation'].strftime('%Y-%m-%d'),
                "Dispensary": med['dispensary'],
                "PhoneNumber": med['phone_number'],
                "DrugList": [
                    {
                        "No": drug['drug_no'],
                        "Effect": drug['effect'],
                        "Code": drug['code'],
                        "Name": drug['name'],
                        "Component": drug['component'],
                        "Quantity": drug['quantity'],
                        "DosagePerOnce": drug['dosage_per_once'],
                        "DailyDose": drug['daily_dose'],
                        "TotalDosingDays": drug['total_dosing_days']
                    } for drug in drugs
                ]
            }
            result_list.append(med_dict)

        result_json = {
            "ResultList": result_list,
            "ApiTxKey": "some_api_tx_key",  # Replace with actual data if available
            "Status": "OK",
            "StatusSeq": 0,
            "ErrorCode": 0,
            "Message": "성공",
            "ErrorLog": None,
            "TargetCode": None,
            "TargetMessage": None,
            "PointBalance": "8900.00"  # Replace with actual data if available
        }

        return json.dumps(result_json, ensure_ascii=False)

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return json.dumps({"Error": str(err)})

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

# Example usage
if __name__ == '__main__':
    user_id = '980929-1222518'
    result_json = query_database_to_json(user_id)
    print(result_json)

# # Example usage
# if __name__ == '__main__':
#     json_file_path = 'path/to/your/med.json'
#     user_id = 'example_user_id'
#     user_name = 'example_user_name'
#     add_data_from_json('./med.json', '980929-1222518', '이준우')

