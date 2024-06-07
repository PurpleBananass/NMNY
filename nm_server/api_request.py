import os, json, base64
import requests
from Crypto import PublicKey
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_v1_5, AES


apiHost = 'https://api.tilko.net/'
apiKey  = 'bcdb5762c50341e9b42cff6e15aa0c2d'

# AES 암호화 함수
def aesEncrypt(key, iv, plainText):
    def pad(text):
        text_length     = len(text)
        amount_to_pad   = AES.block_size - (text_length % AES.block_size)

        if amount_to_pad == 0:
            amount_to_pad = AES.block_size
            
        pad     = chr(amount_to_pad)

        result  = None
        try:
            result  = text + str(pad * amount_to_pad).encode('utf-8')
        except Exception as e:
            result  = text + str(pad * amount_to_pad)

        return result
    
    if type(plainText) == str:
        plainText = plainText.encode('utf-8')
    
    plainText   = pad(plainText)
    cipher      = AES.new(key, AES.MODE_CBC, iv)
    
    if(type(plainText) == bytes):
        return base64.b64encode(cipher.encrypt(plainText)).decode('utf-8')
    else:
        return base64.b64encode(cipher.encrypt(plainText.encode('utf-8'))).decode('utf-8')


# RSA 암호화 함수(RSA 공개키로 AES키 암호화)
def rsaEncrypt(publicKey, aesKey):
    rsa             = RSA.importKey(base64.b64decode(publicKey))
    cipher          = PKCS1_v1_5.new(rsa.publickey())
    aesCipherKey	= cipher.encrypt(aesKey)
    return aesCipherKey


# RSA 공개키(Public Key) 조회 함수
def getPublicKey():
    headers = {'Content-Type': 'application/json'}
    response = requests.get(apiHost + "/api/Auth/GetPublicKey?APIkey=" + apiKey, headers=headers)
    return response.json()['PublicKey']


def request_auth(data):
    # RSA Public Key 조회
    rsaPublicKey    = getPublicKey()
    print(f"rsaPublicKey: {rsaPublicKey}")


    # AES Secret Key 및 IV 생성
    aesKey          = os.urandom(16)
    aesIv           = ('\x00' * 16).encode('utf-8')


    # AES Key를 RSA Public Key로 암호화
    aesCipherKey    = base64.b64encode(rsaEncrypt(rsaPublicKey, aesKey))
    print(f"aesCipherKey: {aesCipherKey}")


    # API URL 설정(정부24 간편인증 요청: https://tilko.net/Help/Api/POST-api-apiVersion-GovSimpleAuth-SimpleAuthRequest)
    url         = apiHost + "api/v1.0/hirasimpleauth/simpleauthrequest";
    # auth_type = data["PrivateAuthType"]#EDIT!!!!
    # 주민등록번호 앞자리
    name = data["name"]
    # birth = data["birth_date"].split("/")
    # birth_date = birth[0]+birth[1]+birth[2]
    birth_date = birth(data["rrn"])
    print(birth_date)
    number = data["phone"].replace('-','')
    id_num = data["rrn"]
    # API 요청 파라미터 설정
    options     = {
        "headers": {
            "Content-Type"          : "application/json",
            "API-KEY"               : apiKey,
            "ENC-KEY"               : aesCipherKey
        },
        
        "json": {
            "PrivateAuthType"       : "0",
            "UserName"              : aesEncrypt(aesKey, aesIv, name),
            "BirthDate"             : aesEncrypt(aesKey, aesIv, birth_date),
            "UserCellphoneNumber"   : aesEncrypt(aesKey, aesIv, number),
            "IdentityNumber"        : aesEncrypt(aesKey, aesIv, id_num),
        },
    }


    # API 호출
    # print(options['json'])
    res         = requests.post(url, headers=options['headers'], json=options['json'])
    print(f"res: {res.json()}")
    # return data
    return res.json()

def med_info(reqData,rrn):
    
    # reqData = res.json()
    print(reqData["ResultData"])
    u = input("Y/N")
    birth_date = birth(rrn)
    if input != "no":
        print("S")
        # API 요청 파라미터 설정
        options     = {
            "headers": {
                "Content-Type"          : "application/json",
                "API-KEY"               : apiKey,
                "ENC-KEY"               : aesCipherKey
            },
            
            "json": {
                "IdentityNumber"        : aesEncrypt(aesKey, aesIv, rrn),
                "StartDate"             : "20230630",
                "EndDate"               : "20240518",
                "CxId"                  : reqData["CxId"],
                "PrivateAuthType"       : reqData["PrivateAuthType"],
                "ReqTxId"               : reqData["ReqTxId"],
                "Token"                 : reqData["Token"],
                "TxId"                  : reqData["TxId"],
                "UserName"              : aesEncrypt(aesKey, aesIv, reqData["UserName"]),
                "BirthDate"             : aesEncrypt(aesKey, aesIv, birth_date),
                "UserCellphoneNumber"   : aesEncrypt(aesKey, aesIv, reqData["UserCellphoneNumber"]),
            },
        }

        url = apiHost+"api/v1.0/hirasimpleauth/hiraa050300000100";
        # url = apiHost+"api/v1.0/hometaxsimpleauth/uternaat32";
        
        # API 호출
        res         = requests.post(url, headers=options['headers'], json=options['json'])
        print(f"res: {res.json()}")



def birth(rrn):
    if int(rrn[:2]) < 21 and int(rrn[6]) in (3, 4) :
        biryear = 2000 + int(rrn[:2])
    else:
        biryear = 1900 + int(rrn[:2])
    birmonth = int(rrn[2:4])
    birmonth = format(birmonth,'02d')
    birday = int(rrn[4:6])
    return str(biryear) + str(birmonth) + str(birday)