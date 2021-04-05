import CryptoJS from "crypto-js";

export function encryptAESCryptoJS(plainText: String, passphrase: String) {
  const ciphertext = CryptoJS.AES.encrypt(plainText, passphrase).toString();

  return ciphertext;
}

export function decryptAESCryptoJS(encrypted: String, passphrase: String) {
  const bytes = CryptoJS.AES.decrypt(encrypted, passphrase);
  const decrypted = bytes.toString(CryptoJS.enc.Utf8);

  return decrypted;
}
