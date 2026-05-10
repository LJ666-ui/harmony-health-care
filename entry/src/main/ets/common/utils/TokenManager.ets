import { SettingsUtil } from '../utils/SettingsUtil';
import { AuthManager } from '../utils/AuthManager';

/**
 * Token管理器
 * 统一管理多角色Token，确保角色隔离
 */
export class TokenManager {
  /**
   * 获取当前角色的Token
   * 优先级：家属 > 护士 > 医生 > 普通用户
   */
  static getCurrentToken(): string | null {
    if (AuthManager.isFamily()) {
      return SettingsUtil.get('familyToken');
    } else if (AuthManager.isNurse()) {
      return SettingsUtil.get('nurseToken');
    } else if (AuthManager.isDoctor()) {
      return SettingsUtil.get('doctorToken');
    } else {
      return SettingsUtil.get('token');
    }
  }

  /**
   * 保存医生Token
   */
  static saveDoctorToken(token: string, doctorInfo: any) {
    SettingsUtil.put('doctorToken', token);
    SettingsUtil.put('isLoggedInAsDoctor', true);
    SettingsUtil.put('doctorInfo', JSON.stringify(doctorInfo));
  }

  /**
   * 获取医生Token
   */
  static getDoctorToken(): string | null {
    return SettingsUtil.get('doctorToken');
  }

  /**
   * 清除医生Token
   */
  static clearDoctorToken() {
    SettingsUtil.delete('doctorToken');
    SettingsUtil.put('isLoggedInAsDoctor', false);
    SettingsUtil.delete('doctorInfo');
  }

  /**
   * 判断医生是否已登录
   */
  static isDoctorLoggedIn(): boolean {
    const isLoggedIn = SettingsUtil.get('isLoggedInAsDoctor');
    const token = SettingsUtil.get('doctorToken');
    return isLoggedIn === true && token !== null && token !== '';
  }

  /**
   * 获取医生信息
   */
  static getDoctorInfo(): any | null {
    const doctorInfoStr = SettingsUtil.get('doctorInfo');
    if (doctorInfoStr) {
      try {
        return JSON.parse(doctorInfoStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /**
   * 保存家属Token
   */
  static saveFamilyToken(token: string, familyInfo: any) {
    SettingsUtil.put('familyToken', token);
    SettingsUtil.put('isLoggedInAsFamily', true);
    SettingsUtil.put('familyInfo', JSON.stringify(familyInfo));
  }

  /**
   * 获取家属Token
   */
  static getFamilyToken(): string | null {
    return SettingsUtil.get('familyToken');
  }

  /**
   * 清除家属Token
   */
  static clearFamilyToken() {
    SettingsUtil.delete('familyToken');
    SettingsUtil.put('isLoggedInAsFamily', false);
    SettingsUtil.delete('familyInfo');
  }

  /**
   * 判断家属是否已登录
   */
  static isFamilyLoggedIn(): boolean {
    const isLoggedIn = SettingsUtil.get('isLoggedInAsFamily');
    const token = SettingsUtil.get('familyToken');
    return isLoggedIn === true && token !== null && token !== '';
  }

  /**
   * 保存护士Token
   */
  static saveNurseToken(token: string, nurseInfo: any) {
    SettingsUtil.put('nurseToken', token);
    SettingsUtil.put('isLoggedInAsNurse', true);
    SettingsUtil.put('nurseInfo', JSON.stringify(nurseInfo));
  }

  /**
   * 获取护士Token
   */
  static getNurseToken(): string | null {
    return SettingsUtil.get('nurseToken');
  }

  /**
   * 清除护士Token
   */
  static clearNurseToken() {
    SettingsUtil.delete('nurseToken');
    SettingsUtil.put('isLoggedInAsNurse', false);
    SettingsUtil.delete('nurseInfo');
  }

  /**
   * 判断护士是否已登录
   */
  static isNurseLoggedIn(): boolean {
    const isLoggedIn = SettingsUtil.get('isLoggedInAsNurse');
    const token = SettingsUtil.get('nurseToken');
    return isLoggedIn === true && token !== null && token !== '';
  }

  /**
   * 保存普通用户Token
   */
  static saveUserToken(token: string, userInfo: any) {
    SettingsUtil.put('token', token);
    SettingsUtil.put('isLoggedIn', true);
    SettingsUtil.put('userInfo', JSON.stringify(userInfo));
  }

  /**
   * 获取普通用户Token
   */
  static getUserToken(): string | null {
    return SettingsUtil.get('token');
  }

  /**
   * 清除普通用户Token
   */
  static clearUserToken() {
    SettingsUtil.delete('token');
    SettingsUtil.put('isLoggedIn', false);
    SettingsUtil.delete('userInfo');
  }

  /**
   * 判断普通用户是否已登录
   */
  static isUserLoggedIn(): boolean {
    const isLoggedIn = SettingsUtil.get('isLoggedIn');
    const token = SettingsUtil.get('token');
    return isLoggedIn === true && token !== null && token !== '';
  }

  /**
   * 清除所有Token
   */
  static clearAllTokens() {
    this.clearDoctorToken();
    this.clearFamilyToken();
    this.clearNurseToken();
    this.clearUserToken();
  }

  /**
   * 获取当前登录角色
   */
  static getCurrentRole(): string | null {
    if (this.isDoctorLoggedIn()) {
      return 'DOCTOR';
    } else if (this.isFamilyLoggedIn()) {
      return 'FAMILY';
    } else if (this.isNurseLoggedIn()) {
      return 'NURSE';
    } else if (this.isUserLoggedIn()) {
      return 'USER';
    }
    return null;
  }
}
