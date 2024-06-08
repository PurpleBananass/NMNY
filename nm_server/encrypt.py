# http://34.64.55.10:8080/medications/pdf?rrn=YKrbPafHGtVnfIN6X+KwhQ==
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
import base64
from flask import Flask, request, jsonify,send_file,after_this_request
from flask_cors import CORS
from api_request import *
import mysql.connector
import json
import base64
import hashlib
from Crypto import Random
from Crypto.Cipher import AES
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
import base64

# # from utils import *

# app = Flask(__name__)
# CORS(app)

# @app.route('/medications/pdf', methods=['GET'])
# def get_medications_pdf():
#     rrn = request.args.get('rrn')
#     if not rrn:
#         return 'Missing RRN', 400
#     print(rrn)
#     rrn = decrypt_rrn(rrn[1:])
#     print(rrn)
#     # data = query_database_to_json(rrn)
#     # generate_pdf_from_json(data,rrn + '.pdf')
#     # @after_this_request
#     # def remove_file(response):
#     #     try:
#     #         os.remove(rrn+ '.pdf')
#     #     except Exception as error:
#     #         app.logger.error("Error removing or closing downloaded file handle", error)
#     #     return response
#     # return send_file('../'+rrn+'.pdf', as_attachment=True)

# def decrypt_rrn(encrypted_rrn):
#     key = b'1joonwooseunghonaegamuckneunyak1'  # 32 bytes key
#     iv = b'\x00' * 16  # 16 bytes IV

#     encrypted_rrn_bytes = base64.b64decode(encrypted_rrn)
#     cipher = Cipher(algorithms.AES(key), modes.CFB(iv))
#     decryptor = cipher.decryptor()
#     decrypted_rrn = decryptor.update(encrypted_rrn_bytes) + decryptor.finalize()
    
#     return decrypted_rrn.decode('utf-8')

# # if __name__ == '__main__':
# #     app.run(debug=True, host='0.0.0.0', port=5000)

# def encrypt_rrn(rrn):
#     key = b'1joonwooseunghonaegamuckneunyak1'  # 32 bytes key
#     iv = b'\x00' * 16  # 16 bytes IV

#     cipher = Cipher(algorithms.AES(key), modes.CFB(iv))
#     encryptor = cipher.encryptor()
#     encrypted_rrn = encryptor.update(rrn.encode('utf-8')) + encryptor.finalize()
    
#     return base64.b64encode(encrypted_rrn).decode('utf-8')

# # Example usage:
# rrn = 'your_rrn_here'
# encrypted_rrn = encrypt_rrn(rrn)
# print(encrypted_rrn)

# def decrypt_rrn(encrypted_rrn):
#     key = b'my32lengthsupersecretnooneknows1'  # 32 bytes key
#     iv = b'\x00' * 16  # 16 bytes IV

#     encrypted_rrn_bytes = base64.b64decode(encrypted_rrn)
#     cipher = Cipher(algorithms.AES(key), modes.CFB(iv))
#     decryptor = cipher.decryptor()
#     decrypted_rrn = decryptor.update(encrypted_rrn_bytes) + decryptor.finalize()
    
#     return decrypted_rrn.decode('utf-8')

def decrypt(enc):
    key = '4f1aaae66406e358'
    enc = base64.b64decode(enc)
    iv = enc[:16]
    cipher = AES.new(key, AES.MODE_CBC, iv )
    return unpad(cipher.decrypt( enc[16:] ))
def _unpad(s):
        return s[:-ord(s[len(s)-1:])]
# num=encrypt_rrn('980929-1222518')
from base64 import b64decode
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad
def dec(rrn):
    # Encryption parameters
    key = b'4f1aaae66406e358'  # 16 bytes key
    iv = b'df1e180949793972'   # 16 bytes IV

    # Encrypted text from Dart output (replace with your actual encrypted text)
    encrypted_text = 'fPscGzYaIU39fbN4v00DVQ=='

    # Decode the base64 encoded encrypted text
    encrypted_bytes = b64decode(rrn)

    # Create the cipher
    cipher = AES.new(key, AES.MODE_CBC, iv)

    # Decrypt and unpad the text
    decrypted_bytes = unpad(cipher.decrypt(encrypted_bytes), AES.block_size)
    decrypted_text = decrypted_bytes.decode('utf-8')

    return decrypted_text

p = dec('AA+WdcgTaGRNC59C9sJEvg==')
p = dec('fPscGzYaIU39fbN4v00DVQ==')
print(p)
# if __name__ == '__main__':
#     app.run(debug=True, host='0.0.0.0', port=5000)
# OYXlh7dMmtXEVqLAsg==
# DBDmL2j/pBRGrDFYDVPUrA==
# YKrbPafHGtVnfIN6X+KwhQ==