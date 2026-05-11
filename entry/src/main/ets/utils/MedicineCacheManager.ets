import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import {
  TABLE_MEDICINE_CACHE,
  COLUMN_ID,
  COLUMN_MEDICINE_ID,
  COLUMN_NAME,
  COLUMN_SPEC,
  COLUMN_MANUFACTURER,
  COLUMN_USAGE,
  COLUMN_CACHED_TIME,
  COLUMN_EXPIRE_TIME
} from './DatabaseConstants';

export interface MedicineCache {
  id?: number;
  medicineId: string;
  name?: string;
  spec?: string;
  manufacturer?: string;
  usage?: string;
  cachedTime?: number;
  expireTime?: number;
}

class MedicineCacheManager {
  private static instance: MedicineCacheManager;
  private defaultExpireDuration = 7 * 24 * 60 * 60 * 1000;

  private constructor() {}

  public static getInstance(): MedicineCacheManager {
    if (!MedicineCacheManager.instance) {
      MedicineCacheManager.instance = new MedicineCacheManager();
    }
    return MedicineCacheManager.instance;
  }

  public async cacheMedicine(medicine: MedicineCache): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_MEDICINE_ID]: medicine.medicineId,
      [COLUMN_NAME]: medicine.name || null,
      [COLUMN_SPEC]: medicine.spec || null,
      [COLUMN_MANUFACTURER]: medicine.manufacturer || null,
      [COLUMN_USAGE]: medicine.usage || null,
      [COLUMN_CACHED_TIME]: Date.now(),
      [COLUMN_EXPIRE_TIME]: medicine.expireTime || Date.now() + this.defaultExpireDuration
    };

    const predicates = new relationalStore.RdbPredicates(TABLE_MEDICINE_CACHE);
    predicates.equalTo(COLUMN_MEDICINE_ID, medicine.medicineId);
    
    const resultSet = await RdbHelper.queryByPredicates(predicates, [COLUMN_ID]);
    if (resultSet.goToFirstRow()) {
      resultSet.close();
      return await RdbHelper.update(TABLE_MEDICINE_CACHE, values, predicates);
    }
    resultSet.close();
    
    return await RdbHelper.insert(TABLE_MEDICINE_CACHE, values);
  }

  public async getCachedMedicine(medicineId: string): Promise<MedicineCache | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_MEDICINE_CACHE);
    predicates.equalTo(COLUMN_MEDICINE_ID, medicineId);

    const resultSet = await RdbHelper.queryByPredicates(predicates);
    if (resultSet.goToFirstRow()) {
      const medicine: MedicineCache = {
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        medicineId: resultSet.getString(resultSet.getColumnIndex(COLUMN_MEDICINE_ID)),
        name: resultSet.getString(resultSet.getColumnIndex(COLUMN_NAME)),
        spec: resultSet.getString(resultSet.getColumnIndex(COLUMN_SPEC)),
        manufacturer: resultSet.getString(resultSet.getColumnIndex(COLUMN_MANUFACTURER)),
        usage: resultSet.getString(resultSet.getColumnIndex(COLUMN_USAGE)),
        cachedTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CACHED_TIME)),
        expireTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME))
      };
      resultSet.close();

      if (medicine.expireTime && medicine.expireTime < Date.now()) {
        await this.removeCachedMedicine(medicineId);
        return null;
      }

      return medicine;
    }
    resultSet.close();
    return null;
  }

  public async searchMedicines(keyword: string): Promise<MedicineCache[]> {
    const sql = `SELECT * FROM ${TABLE_MEDICINE_CACHE} WHERE ${COLUMN_NAME} LIKE ? AND ${COLUMN_EXPIRE_TIME} >= ?`;
    const resultSet = await RdbHelper.query(sql, [`%${keyword}%`, Date.now()]);

    const medicines: MedicineCache[] = [];
    while (resultSet.goToNextRow()) {
      medicines.push({
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        medicineId: resultSet.getString(resultSet.getColumnIndex(COLUMN_MEDICINE_ID)),
        name: resultSet.getString(resultSet.getColumnIndex(COLUMN_NAME)),
        spec: resultSet.getString(resultSet.getColumnIndex(COLUMN_SPEC)),
        manufacturer: resultSet.getString(resultSet.getColumnIndex(COLUMN_MANUFACTURER)),
        usage: resultSet.getString(resultSet.getColumnIndex(COLUMN_USAGE)),
        cachedTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CACHED_TIME)),
        expireTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME))
      });
    }
    resultSet.close();
    return medicines;
  }

  public async removeCachedMedicine(medicineId: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_MEDICINE_CACHE);
    predicates.equalTo(COLUMN_MEDICINE_ID, medicineId);
    return await RdbHelper.delete(predicates);
  }
}

const medicineCacheManager = MedicineCacheManager.getInstance();
export default medicineCacheManager;
