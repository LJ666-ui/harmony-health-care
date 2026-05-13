import { PatientInfo, PatientDetail } from './PatientModel';

export interface CacheDataWrapper<T> {
  data: T;
  cacheTime: number;
  expireTime: number;
  version: number;
}

export interface PatientListCache extends CacheDataWrapper<PatientInfo[]> {
  nurseId?: string;
  doctorId?: string;
  pageNumber: number;
  pageSize: number;
  total: number;
}

export interface PatientDetailCache extends CacheDataWrapper<PatientDetail> {
  patientId: string;
}

export interface CacheConfig {
  listCacheExpireTime: number;
  detailCacheExpireTime: number;
  maxCacheCount: number;
  enableCache: boolean;
}

export const DefaultCacheConfig: CacheConfig = {
  listCacheExpireTime: 5 * 60 * 1000,
  detailCacheExpireTime: 10 * 60 * 1000,
  maxCacheCount: 100,
  enableCache: true
};
