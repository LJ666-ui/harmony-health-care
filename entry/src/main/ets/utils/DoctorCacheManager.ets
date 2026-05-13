import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import {
  TABLE_DOCTOR_CACHE,
  COLUMN_ID,
  COLUMN_DOCTOR_ID,
  COLUMN_NAME,
  COLUMN_HOSPITAL_ID_FK,
  COLUMN_DEPARTMENT,
  COLUMN_AVATAR,
  COLUMN_CACHED_TIME,
  COLUMN_EXPIRE_TIME
} from './DatabaseConstants';

export interface DoctorCache {
  id?: number;
  doctorId: string;
  name?: string;
  hospitalId?: string;
  department?: string;
  title?: string;
  avatar?: string;
  cachedTime?: number;
  expireTime?: number;
}

class DoctorCacheManager {
  private static instance: DoctorCacheManager;
  private defaultExpireDuration = 24 * 60 * 60 * 1000;

  private constructor() {}

  public static getInstance(): DoctorCacheManager {
    if (!DoctorCacheManager.instance) {
      DoctorCacheManager.instance = new DoctorCacheManager();
    }
    return DoctorCacheManager.instance;
  }

  public async cacheDoctor(doctor: DoctorCache): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_DOCTOR_ID]: doctor.doctorId,
      [COLUMN_NAME]: doctor.name || null,
      [COLUMN_HOSPITAL_ID_FK]: doctor.hospitalId || null,
      [COLUMN_DEPARTMENT]: doctor.department || null,
      title: doctor.title || null,
      [COLUMN_AVATAR]: doctor.avatar || null,
      [COLUMN_CACHED_TIME]: Date.now(),
      [COLUMN_EXPIRE_TIME]: doctor.expireTime || Date.now() + this.defaultExpireDuration
    };

    const predicates = new relationalStore.RdbPredicates(TABLE_DOCTOR_CACHE);
    predicates.equalTo(COLUMN_DOCTOR_ID, doctor.doctorId);
    
    const resultSet = await RdbHelper.queryByPredicates(predicates, [COLUMN_ID]);
    if (resultSet.goToFirstRow()) {
      resultSet.close();
      return await RdbHelper.update(TABLE_DOCTOR_CACHE, values, predicates);
    }
    resultSet.close();
    
    return await RdbHelper.insert(TABLE_DOCTOR_CACHE, values);
  }

  public async getCachedDoctor(doctorId: string): Promise<DoctorCache | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_DOCTOR_CACHE);
    predicates.equalTo(COLUMN_DOCTOR_ID, doctorId);

    const resultSet = await RdbHelper.queryByPredicates(predicates);
    if (resultSet.goToFirstRow()) {
      const doctor: DoctorCache = {
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        doctorId: resultSet.getString(resultSet.getColumnIndex(COLUMN_DOCTOR_ID)),
        name: resultSet.getString(resultSet.getColumnIndex(COLUMN_NAME)),
        hospitalId: resultSet.getString(resultSet.getColumnIndex(COLUMN_HOSPITAL_ID_FK)),
        department: resultSet.getString(resultSet.getColumnIndex(COLUMN_DEPARTMENT)),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        avatar: resultSet.getString(resultSet.getColumnIndex(COLUMN_AVATAR)),
        cachedTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CACHED_TIME)),
        expireTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME))
      };
      resultSet.close();

      if (doctor.expireTime && doctor.expireTime < Date.now()) {
        await this.removeCachedDoctor(doctorId);
        return null;
      }

      return doctor;
    }
    resultSet.close();
    return null;
  }

  public async getDoctorsByHospital(hospitalId: string): Promise<DoctorCache[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_DOCTOR_CACHE);
    predicates.equalTo(COLUMN_HOSPITAL_ID_FK, hospitalId);
    predicates.orderByDesc(COLUMN_CACHED_TIME);

    const doctors: DoctorCache[] = [];
    const resultSet = await RdbHelper.queryByPredicates(predicates);
    
    while (resultSet.goToNextRow()) {
      const expireTime = resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME));
      if (expireTime >= Date.now()) {
        doctors.push({
          id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
          doctorId: resultSet.getString(resultSet.getColumnIndex(COLUMN_DOCTOR_ID)),
          name: resultSet.getString(resultSet.getColumnIndex(COLUMN_NAME)),
          hospitalId: resultSet.getString(resultSet.getColumnIndex(COLUMN_HOSPITAL_ID_FK)),
          department: resultSet.getString(resultSet.getColumnIndex(COLUMN_DEPARTMENT)),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          avatar: resultSet.getString(resultSet.getColumnIndex(COLUMN_AVATAR)),
          cachedTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CACHED_TIME)),
          expireTime: expireTime
        });
      }
    }
    resultSet.close();
    return doctors;
  }

  public async getDoctorsByDepartment(department: string): Promise<DoctorCache[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_DOCTOR_CACHE);
    predicates.equalTo(COLUMN_DEPARTMENT, department);
    predicates.orderByDesc(COLUMN_CACHED_TIME);

    const doctors: DoctorCache[] = [];
    const resultSet = await RdbHelper.queryByPredicates(predicates);
    
    while (resultSet.goToNextRow()) {
      const expireTime = resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME));
      if (expireTime >= Date.now()) {
        doctors.push({
          id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
          doctorId: resultSet.getString(resultSet.getColumnIndex(COLUMN_DOCTOR_ID)),
          name: resultSet.getString(resultSet.getColumnIndex(COLUMN_NAME)),
          hospitalId: resultSet.getString(resultSet.getColumnIndex(COLUMN_HOSPITAL_ID_FK)),
          department: resultSet.getString(resultSet.getColumnIndex(COLUMN_DEPARTMENT)),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          avatar: resultSet.getString(resultSet.getColumnIndex(COLUMN_AVATAR)),
          cachedTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CACHED_TIME)),
          expireTime: expireTime
        });
      }
    }
    resultSet.close();
    return doctors;
  }

  public async removeCachedDoctor(doctorId: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_DOCTOR_CACHE);
    predicates.equalTo(COLUMN_DOCTOR_ID, doctorId);
    return await RdbHelper.delete(predicates);
  }
}

const doctorCacheManager = DoctorCacheManager.getInstance();
export default doctorCacheManager;
