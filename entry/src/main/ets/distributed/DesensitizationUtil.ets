import { cryptoFramework } from './DistributedKitStubs';
import { DesensitizeLevel } from '../models/DistributedModels';

export class DesensitizationUtil {

  static desensitizeIdCard(idCard: string): string {
    if (!idCard || idCard.length < 8) {
      return idCard;
    }
    const prefix: string = idCard.substring(0, 3);
    const suffix: string = idCard.substring(idCard.length - 4);
    const maskLength: number = idCard.length - 7;
    let mask: string = '';
    for (let i = 0; i < maskLength; i++) {
      mask += '*';
    }
    return prefix + mask + suffix;
  }

  static desensitizePhone(phone: string): string {
    if (!phone || phone.length < 7) {
      return phone;
    }
    const prefix: string = phone.substring(0, 3);
    const suffix: string = phone.substring(phone.length - 4);
    return prefix + '****' + suffix;
  }

  static desensitizeName(name: string): string {
    if (!name || name.length === 0) {
      return name;
    }
    if (name.length === 1) {
      return '*';
    }
    if (name.length === 2) {
      return name.charAt(0) + '*';
    }
    const firstChar: string = name.charAt(0);
    let mask: string = '';
    for (let i = 1; i < name.length; i++) {
      mask += '*';
    }
    return firstChar + mask;
  }

  static desensitizeAddress(address: string): string {
    if (!address || address.length === 0) {
      return address;
    }
    if (address.length <= 6) {
      return '******';
    }
    const prefix: string = address.substring(0, 3);
    const suffix: string = address.substring(address.length - 3);
    const maskLength: number = address.length - 6;
    let mask: string = '';
    for (let i = 0; i < maskLength; i++) {
      mask += '*';
    }
    return prefix + mask + suffix;
  }

  static desensitizeEmail(email: string): string {
    if (!email || !email.includes('@')) {
      return email;
    }
    const atIndex: number = email.indexOf('@');
    const localPart: string = email.substring(0, atIndex);
    const domain: string = email.substring(atIndex);

    if (localPart.length <= 2) {
      return '*' + domain;
    }
    const visiblePart: string = localPart.substring(0, 1);
    let mask: string = '';
    for (let i = 1; i < localPart.length; i++) {
      mask += '*';
    }
    return visiblePart + mask + domain;
  }

  static desensitizeMedicalRecord(content: string, level: DesensitizeLevel): string {
    if (!content) {
      return content;
    }

    let result: string = content;

    result = DesensitizationUtil.desensitizeIdCardsInText(result, level);
    result = DesensitizationUtil.desensitizePhonesInText(result, level);
    result = DesensitizationUtil.desensitizeEmailsInText(result, level);
    result = DesensitizationUtil.desensitizeAddressesInText(result, level);
    result = DesensitizationUtil.desensitizeNamesInText(result, level);

    return result;
  }

  private static desensitizeIdCardsInText(text: string, level: DesensitizeLevel): string {
    const idCardPattern: RegExp = /\b(\d{6})(\d{8}|\d{10}|\d{12})(\d{3}[\dXx]?)\b/g;
    return text.replace(idCardPattern, (match: string): string => {
      return DesensitizationUtil.desensitizeIdCard(match);
    });
  }

  private static desensitizePhonesInText(text: string, level: DesensitizeLevel): string {
    const phonePattern: RegExp = /\b(1[3-9]\d)(\d{4})(\d{4})\b/g;
    return text.replace(phonePattern, (match: string): string => {
      return DesensitizationUtil.desensitizePhone(match);
    });
  }

  private static desensitizeEmailsInText(text: string, level: DesensitizeLevel): string {
    const emailPattern: RegExp = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g;
    return text.replace(emailPattern, (match: string): string => {
      return DesensitizationUtil.desensitizeEmail(match);
    });
  }

  private static desensitizeAddressesInText(text: string, level: DesensitizeLevel): string {
    const addressPatterns: RegExp[] = [
      /(?:北京市|上海市|天津市|重庆市|河北省|山西省|辽宁省|吉林省|黑龙江省|江苏省|浙江省|安徽省|福建省|江西省|山东省|河南省|湖北省|湖南省|广东省|海南省|四川省|贵州省|云南省|陕西省|甘肃省|青海省|台湾省|内蒙古自治区|广西壮族自治区|西藏自治区|宁夏回族自治区|新疆维吾尔自治区)[^\n，。；！？]{5,50}/g,
      /(?:省|市|自治区|特别行政区)[^\n，。；！？]{5,40}(?:市|区|县|镇|乡|街道|路|巷|号|栋|单元|室)/g
    ];

    let result: string = text;
    for (let i = 0; i < addressPatterns.length; i++) {
      result = result.replace(addressPatterns[i], (match: string): string => {
        return DesensitizationUtil.desensitizeAddress(match);
      });
    }
    return result;
  }

  private static desensitizeNamesInText(text: string, level: DesensitizeLevel): string {
    const chineseNamePattern: RegExp = /(?:患者|病人|姓名|名字|叫)[：:]*([\u4e00-\u9fa5]{2,4})/g;
    return text.replace(chineseNamePattern, (match: string, name: string): string => {
      return match.replace(name, DesensitizationUtil.desensitizeName(name));
    });
  }

  static async generateAESKey(): Promise<string> {
    try {
      const symKeyGenerator: cryptoFramework.SymKeyGenerator =
        cryptoFramework.createSymKeyGenerator('AES256');
      const keyData: cryptoFramework.DataBlob = { data: new Uint8Array(32) };
      cryptoFramework.getRandomValues(keyData.data);
      const key: cryptoFramework.SymKey = await symKeyGenerator.convertKey(keyData);
      const encodedKey: cryptoFramework.DataBlob = await key.getEncoded();
      return DesensitizationUtil.uint8ArrayToBase64(encodedKey.data);
    } catch (error) {
      console.error('[DesensitizationUtil] 生成AES密钥失败:', error);
      throw new Error(String(error));
    }
  }

  static async encryptData(plainText: string, keyBase64: string): Promise<string> {
    try {
      const symKeyGenerator: cryptoFramework.SymKeyGenerator =
        cryptoFramework.createSymKeyGenerator('AES256');

      const keyDataUint8: Uint8Array = DesensitizationUtil.base64ToUint8Array(keyBase64);
      const keyData: cryptoFramework.DataBlob = { data: keyDataUint8 };
      const key: cryptoFramework.SymKey = await symKeyGenerator.convertKey(keyData);

      const cipher: cryptoFramework.Cipher = cryptoFramework.createCipher({
        algName: 'AES256',
        mode: cryptoFramework.CipherMode.GCM,
        padding: cryptoFramework.CryptoPadding.NoPadding
      });

      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, key, null);

      const plainData: cryptoFramework.DataBlob = {
        data: DesensitizationUtil.stringToUint8Array(plainText)
      };

      const encryptedData: cryptoFramework.DataBlob = await cipher.doFinal(plainData);
      return DesensitizationUtil.uint8ArrayToBase64(encryptedData.data);
    } catch (error) {
      console.error('[DesensitizationUtil] 加密失败:', error);
      throw new Error(String(error));
    }
  }

  static async decryptData(encryptedBase64: string, keyBase64: string): Promise<string> {
    try {
      const symKeyGenerator: cryptoFramework.SymKeyGenerator =
        cryptoFramework.createSymKeyGenerator('AES256');

      const keyDataUint8: Uint8Array = DesensitizationUtil.base64ToUint8Array(keyBase64);
      const keyData: cryptoFramework.DataBlob = { data: keyDataUint8 };
      const key: cryptoFramework.SymKey = await symKeyGenerator.convertKey(keyData);

      const cipher: cryptoFramework.Cipher = cryptoFramework.createCipher({
        algName: 'AES256',
        mode: cryptoFramework.CipherMode.GCM,
        padding: cryptoFramework.CryptoPadding.NoPadding
      });

      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, key, null);

      const encryptedDataUint8: Uint8Array = DesensitizationUtil.base64ToUint8Array(encryptedBase64);
      const encryptedData: cryptoFramework.DataBlob = { data: encryptedDataUint8 };

      const decryptedData: cryptoFramework.DataBlob = await cipher.doFinal(encryptedData);
      return DesensitizationUtil.uint8ArrayToString(decryptedData.data);
    } catch (error) {
      console.error('[DesensitizationUtil] 解密失败:', error);
      throw new Error(String(error));
    }
  }

  private static uint8ArrayToBase64(uint8Array: Uint8Array): string {
    const chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    let result: string = '';
    for (let i = 0; i < uint8Array.length; i += 3) {
      const byte1: number = uint8Array[i];
      const byte2: number = (i + 1 < uint8Array.length) ? uint8Array[i + 1] : 0;
      const byte3: number = (i + 2 < uint8Array.length) ? uint8Array[i + 2] : 0;
      result += chars.charAt(byte1 >> 2);
      result += chars.charAt(((byte1 & 3) << 4) | (byte2 >> 4));
      if (i + 1 < uint8Array.length) {
        result += chars.charAt(((byte2 & 15) << 2) | (byte3 >> 6));
      } else {
        result += '=';
      }
      if (i + 2 < uint8Array.length) {
        result += chars.charAt(byte3 & 63);
      } else {
        result += '=';
      }
    }
    return result;
  }

  private static base64ToUint8Array(base64: string): Uint8Array {
    const chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    const cleanedBase64: string = base64.replace(/=+$/, '');
    const length: number = cleanedBase64.length * 3 / 4;
    const bytes: Uint8Array = new Uint8Array(length);
    let index: number = 0;
    for (let i = 0; i < base64.length; i += 4) {
      const c0: number = chars.indexOf(base64.charAt(i));
      const c1: number = chars.indexOf(base64.charAt(i + 1));
      const c2: number = (i + 2 < base64.length) ? chars.indexOf(base64.charAt(i + 2)) : 0;
      const c3: number = (i + 3 < base64.length) ? chars.indexOf(base64.charAt(i + 3)) : 0;
      bytes[index++] = (c0 << 2) | (c1 >> 4);
      if (index < bytes.length) {
        bytes[index++] = ((c1 & 15) << 4) | (c2 >> 2);
      }
      if (index < bytes.length) {
        bytes[index++] = ((c2 & 3) << 6) | c3;
      }
    }
    return bytes;
  }

  private static stringToUint8Array(str: string): Uint8Array {
    const bytes: Uint8Array = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
      bytes[i] = str.charCodeAt(i);
    }
    return bytes;
  }

  private static uint8ArrayToString(uint8Array: Uint8Array): string {
    let str: string = '';
    for (let i = 0; i < uint8Array.length; i++) {
      str += String.fromCharCode(uint8Array[i]);
    }
    return str;
  }
}
