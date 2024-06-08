
import 'package:encrypt/encrypt.dart' as enc;
void main() {
  final key = enc.Key.fromUtf8('4f1aaae66406e358');
  final iv = enc.IV.fromUtf8('df1e180949793972');
  String encryptedText;
  String plainText = 'Chanaka';
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  encryptedText = encrypted.base64;
  print(encryptedText);
}
