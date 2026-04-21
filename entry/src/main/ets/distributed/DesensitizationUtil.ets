/**
 * 数据脱敏与AES-256-GCM加密工具类
 * 
 * 核心职责：
 * 1. 敏感信息脱敏（身份证/手机号/姓名/地址）
 * 2. 病历内容智能脱敏（正则匹配多种敏感字段）
 * 3. AES-256-GCM加密解密（用于分布式传输安全）
 */

export enum DesensitizeLevel {
  FULL = 'FULL',       // 完全脱敏（家属查看）
  PARTIAL = 'PARTIAL', // 部分脱敏（其他医院医生）
  MINIMAL = 'MINIMAL'  // 最小脱敏（主治医生可见更多）
}

export class DesensitizationUtil {

  private static readonly ID_CARD_REGEX = /(\d{6})\d{8}(\d{4})/g;
  private static readonly PHONE_REGEX = /(\d{3})\d{4}(\d{4})/g;
  private static readonly EMAIL_REGEX = /([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/g;
  private static readonly NAME_REGEX = /^(.{1})(.+)$/;

  /**
   * 身份证号脱敏: 110***********1234
   */
  static desensitizeIdCard(idCard: string): string {
    if (!idCard || idCard.length < 8) {
      return idCard;
    }
    
    const masked = idCard.substring(0, 6) + '*'.repeat(idCard.length - 10) + idCard.substring(idCard.length - 4);
    console.log('[Desensitization] 身份证脱敏完成');
    return masked;
  }

  /**
   * 手机号脱敏: 138****1234
   */
  static desensitizePhone(phone: string): string {
    if (!phone || phone.length < 7) {
      return phone;
    }
    
    const masked = phone.substring(0, 3) + '****' + phone.substring(phone.length - 4);
    console.log('[Desensitization] 手机号脱敏完成');
    return masked;
  }

  /**
   * 姓名脱敏: 张**
   */
  static desensitizeName(name: string): string {
    if (!name || name.length === 0) {
      return name;
    }

    if (name.length <= 2) {
      return name.charAt(0) + '*';
    } else if (name.length <= 3) {
      return name.charAt(0) + '**';
    } else {
      return name.charAt(0) + '*'.repeat(name.length - 1);
    }
  }

  /**
   * 地址脱敏: 北京市朝阳区***路***号
   */
  static desensitizeAddress(address: string): string {
    if (!address) {
      return address;
    }

    const parts = address.split(/省|市|区|县|镇|乡|街道|路|巷|村|号|栋|单元|室/g);
    let result = '';
    let maskCount = 0;

    for (let i = 0; i < parts.length; i++) {
      const part = parts[i].trim();
      if (part && i > 0 && i < parts.length - 1) {
        result += '***';
        maskCount++;
      } else if (part) {
        result += part;
      }
    }

    console.log('[Desensitization] 地址脱敏完成，隐藏' + maskCount + '段');
    return result || '***';
  }

  /**
   * 病历内容智能脱敏（根据级别自动选择策略）
   * 
   * @param content 原始病历内容
   * @param level 脱敏等级（FULL/PARTIAL/MINIMAL）
   * @returns 脱敏后的内容
   */
  static desensitizeMedicalRecord(content: string, level: DesensitizeLevel): string {
    if (!content) {
      return content;
    }

    let result = content;

    switch (level) {
      case DesensitizeLevel.FULL:
        result = DesensitizationUtil.fullDesensitize(result);
        break;
      case DesensitizeLevel.PARTIAL:
        result = DesensitizationUtil.partialDesensitize(result);
        break;
      case DesensitizeLevel.MINIMAL:
        result = DesensitizationUtil.minimalDesensitize(result);
        break;
      default:
        console.warn('[Desensitization] 未知的脱敏等级: ' + level);
    }

    console.log('[Desensitization] 病历脱敏完成，等级: ' + level);
    return result;
  }

  /**
   * 完全脱敏（家属查看）：隐藏所有敏感信息
   */
  private static fullDesensitize(content: string): string {
    let result = content;

    result = result.replace(DesensitizationUtil.ID_CARD_REGEX, '$1********$2');
    result = result.replace(DesensitizationUtil.PHONE_REGEX, '$1****$2');
    result = result.replace(DesensitizationUtil.EMAIL_REGEX, '***@***.com');

    const lines = result.split('\n');
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      if (line.includes('姓名') || line.includes('患者') || line.includes('病人')) {
        lines[i] = line.replace(/[:：]\s*[\u4e00-\u9fa5]{2,4}/g, ': ***');
      }
      
      if (line.includes('住址') || line.includes('地址') || line.includes('居住')) {
        lines[i] = line.replace(/[:：]\s*.+$/g, ': ***');
      }
    }

    return lines.join('\n');
  }

  /**
   * 部分脱敏（其他医院医生）：保留关键医疗信息
   */
  private static partialDesensitize(content: string): string {
    let result = content;

    result = result.replace(DesensitizationUtil.ID_CARD_REGEX, '$1********$2');
    result = result.replace(DesensitizationUtil.PHONE_REGEX, '$1****$2');
    result = result.replace(DesensitizationUtil.EMAIL_REGEX, '$1@$2');

    const lines = result.split('\n');
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      if (line.includes('姓名')) {
        lines[i] = DesensitizationUtil.desensitizeName(line.split(':')[1]?.trim() || '');
      }
      
      if (line.includes('住址') || line.includes('地址')) {
        lines[i] = line.replace(/[:：]\s*(.+)$/, ': ' + DesensitizationUtil.desensitizeAddress('$1'));
      }
    }

    return lines.join('\n');
  }

  /**
   * 最小脱敏（主治医生可见更多）：仅脱敏核心隐私
   */
  private static minimalDesensitize(content: string): string {
    let result = content;

    result = result.replace(DesensitizationUtil.ID_CARD_REGEX, '$1********$2');
    result = result.replace(DesensitizationUtil.PHONE_REGEX, '$1****$2');

    return result;
  }

  /**
   * AES-256-GCM加密（用于分布式传输）
   * 
   * @param plainText 明文
   * @param keyBase64 Base64编码的密钥（32字节）
   * @returns Base64编码的密文
   */
  static async encryptData(plainText: string, keyBase64: string): Promise<string> {
    try {
      console.log('[Encryption] 开始加密数据...');
      
      const cryptoFramework: ESObject = requireNapi('security.cryptoFramework', true);

      const keyData: ESObject = {
        data: DesensitizationUtil.base64ToArrayBuffer(keyBase64)
      };

      const symKeyGenerator: ESObject = cryptoFramework.createSymKeyGenerator('AES256');
      const key: ESObject = await symKeyGenerator.convertKey(keyData);

      const cipher: ESObject = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      const ivData: ESObject = {
        data: new Uint8Array(12).buffer as ArrayBuffer
      };

      await cipher.init(cryptoFramework.CryptoMode, key, { algName: 'GcmParamsSpec', iv: ivData } as ESObject);

      const plainBlob: ESObject = {
        data: new TextEncoder().encode(plainText).buffer as ArrayBuffer
      };

      const encryptedBlob: ESObject = await cipher.doFinal(plainBlob);
      
      const encryptedBase64 = DesensitizationUtil.arrayBufferToBase64(encryptedBlob.data);
      console.log('[Encryption] 加密成功，密文长度: ' + encryptedBase64.length);
      
      return encryptedBase64;
    } catch (error) {
      const err = error as Error;
      console.error('[Encryption] 加密失败:', err.message);
      throw new Error('数据加密失败: ' + err.message);
    }
  }

  /**
   * AES-256-GCM解密
   * 
   * @param encryptedBase64 Base64编码的密文
   * @param keyBase64 Base64编码的密钥
   * @returns 解密后的明文
   */
  static async decryptData(encryptedBase64: string, keyBase64: string): Promise<string> {
    try {
      console.log('[Decryption] 开始解密数据...');

      const cryptoFramework: ESObject = requireNapi('security.cryptoFramework', true);

      const keyData: ESObject = {
        data: DesensitizationUtil.base64ToArrayBuffer(keyBase64)
      };

      const symKeyGenerator: ESObject = cryptoFramework.createSymKeyGenerator('AES256');
      const key: ESObject = await symKeyGenerator.convertKey(keyData);

      const decipher: ESObject = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      const ivData: ESObject = {
        data: new Uint8Array(12).buffer as ArrayBuffer
      };

      await decipher.init(cryptoFramework.CryptoMode, key, { algName: 'GcmParamsSpec', iv: ivData } as ESObject);

      const encryptedBlob: ESObject = {
        data: DesensitizationUtil.base64ToArrayBuffer(encryptedBase64)
      };

      const decryptedBlob: ESObject = await decipher.doFinal(encryptedBlob);

      const decryptedText = new TextDecoder().decode(decryptedBlob.data);
      console.log('[Decryption] 解密成功，明文长度: ' + decryptedText.length);
      
      return decryptedText;
    } catch (error) {
      const err = error as Error;
      console.error('[Decryption] 解密失败:', err.message);
      throw new Error('数据解密失败: ' + err.message);
    }
  }

  /**
   * 生成随机AES-256密钥（32字节）
   */
  static generateRandomKey(): string {
    const keyBytes = new Uint8Array(32);
    for (let i = 0; i < 32; i++) {
      keyBytes[i] = Math.floor(Math.random() * 256);
    }
    return DesensitizationUtil.arrayBufferToBase64(keyBytes.buffer as ArrayBuffer);
  }

  /**
   * Base64 → ArrayBuffer 转换
   */
  private static base64ToArrayBuffer(base64: string): ArrayBuffer {
    const binaryString = atob(base64);
    const bytes = new Uint8Array(binaryString.length);
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    return bytes.buffer as ArrayBuffer;
  }

  /**
   * ArrayBuffer → Base64 转换
   */
  private static arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }
}
