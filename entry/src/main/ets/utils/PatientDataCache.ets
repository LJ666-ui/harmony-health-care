export interface SimplePatientData {
  id: number;
  username: string;
  realName: string;
  phone: string;
  age: number;
  gender: number;
  idCard?: string;
  hospital?: string;
  department?: string;
  bedNumber?: string;
  diagnosis?: string;
}

export class PatientDataCache {
  private static cachedDataStr: string = '';
  
  static savePatientData(data: SimplePatientData): void {
    PatientDataCache.cachedDataStr = JSON.stringify(data);
    console.log('PatientDataCache - Saved patient data, length:', PatientDataCache.cachedDataStr.length);
  }
  
  static getPatientData(): SimplePatientData | null {
    if (!PatientDataCache.cachedDataStr || PatientDataCache.cachedDataStr.length === 0) {
      console.log('PatientDataCache - No cached data');
      return null;
    }
    
    try {
      const data = JSON.parse(PatientDataCache.cachedDataStr) as SimplePatientData;
      console.log('PatientDataCache - Got cached data, ID:', data.id);
      return data;
    } catch (e) {
      console.error('PatientDataCache - Failed to parse data:', e);
      return null;
    }
  }
  
  static clearPatientData(): void {
    PatientDataCache.cachedDataStr = '';
    console.log('PatientDataCache - Cleared data');
  }
}
