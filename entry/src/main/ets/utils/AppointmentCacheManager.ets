import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import {
  TABLE_APPOINTMENT_CACHE,
  COLUMN_ID,
  COLUMN_APPOINTMENT_ID,
  COLUMN_USER_ID,
  COLUMN_DOCTOR_ID_FK,
  COLUMN_HOSPITAL_ID,
  COLUMN_APPOINTMENT_TIME,
  COLUMN_STATUS,
  COLUMN_SYNCED
} from './DatabaseConstants';

export interface AppointmentCache {
  id?: number;
  appointmentId: string;
  userId?: string;
  doctorId?: string;
  hospitalId?: string;
  appointmentTime?: number;
  status?: string;
  synced?: number;
}

class AppointmentCacheManager {
  private static instance: AppointmentCacheManager;

  private constructor() {}

  public static getInstance(): AppointmentCacheManager {
    if (!AppointmentCacheManager.instance) {
      AppointmentCacheManager.instance = new AppointmentCacheManager();
    }
    return AppointmentCacheManager.instance;
  }

  public async cacheAppointment(appointment: AppointmentCache): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_APPOINTMENT_ID]: appointment.appointmentId,
      [COLUMN_USER_ID]: appointment.userId || null,
      [COLUMN_DOCTOR_ID_FK]: appointment.doctorId || null,
      [COLUMN_HOSPITAL_ID]: appointment.hospitalId || null,
      [COLUMN_APPOINTMENT_TIME]: appointment.appointmentTime || Date.now(),
      [COLUMN_STATUS]: appointment.status || 'pending',
      [COLUMN_SYNCED]: appointment.synced || 0
    };

    const predicates = new relationalStore.RdbPredicates(TABLE_APPOINTMENT_CACHE);
    predicates.equalTo(COLUMN_APPOINTMENT_ID, appointment.appointmentId);
    
    const resultSet = await RdbHelper.queryByPredicates(predicates, [COLUMN_ID]);
    if (resultSet.goToFirstRow()) {
      resultSet.close();
      return await RdbHelper.update(TABLE_APPOINTMENT_CACHE, values, predicates);
    }
    resultSet.close();
    
    return await RdbHelper.insert(TABLE_APPOINTMENT_CACHE, values);
  }

  public async getCachedAppointment(appointmentId: string): Promise<AppointmentCache | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_APPOINTMENT_CACHE);
    predicates.equalTo(COLUMN_APPOINTMENT_ID, appointmentId);

    const resultSet = await RdbHelper.queryByPredicates(predicates);
    if (resultSet.goToFirstRow()) {
      const appointment: AppointmentCache = {
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        appointmentId: resultSet.getString(resultSet.getColumnIndex(COLUMN_APPOINTMENT_ID)),
        userId: resultSet.getString(resultSet.getColumnIndex(COLUMN_USER_ID)),
        doctorId: resultSet.getString(resultSet.getColumnIndex(COLUMN_DOCTOR_ID_FK)),
        hospitalId: resultSet.getString(resultSet.getColumnIndex(COLUMN_HOSPITAL_ID)),
        appointmentTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_APPOINTMENT_TIME)),
        status: resultSet.getString(resultSet.getColumnIndex(COLUMN_STATUS)),
        synced: resultSet.getLong(resultSet.getColumnIndex(COLUMN_SYNCED))
      };
      resultSet.close();
      return appointment;
    }
    resultSet.close();
    return null;
  }

  public async getAppointmentsByUser(userId: string): Promise<AppointmentCache[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_APPOINTMENT_CACHE);
    predicates.equalTo(COLUMN_USER_ID, userId);
    predicates.orderByDesc(COLUMN_APPOINTMENT_TIME);

    const appointments: AppointmentCache[] = [];
    const resultSet = await RdbHelper.queryByPredicates(predicates);
    
    while (resultSet.goToNextRow()) {
      appointments.push({
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        appointmentId: resultSet.getString(resultSet.getColumnIndex(COLUMN_APPOINTMENT_ID)),
        userId: resultSet.getString(resultSet.getColumnIndex(COLUMN_USER_ID)),
        doctorId: resultSet.getString(resultSet.getColumnIndex(COLUMN_DOCTOR_ID_FK)),
        hospitalId: resultSet.getString(resultSet.getColumnIndex(COLUMN_HOSPITAL_ID)),
        appointmentTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_APPOINTMENT_TIME)),
        status: resultSet.getString(resultSet.getColumnIndex(COLUMN_STATUS)),
        synced: resultSet.getLong(resultSet.getColumnIndex(COLUMN_SYNCED))
      });
    }
    resultSet.close();
    return appointments;
  }

  public async updateAppointmentStatus(appointmentId: string, status: string): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_STATUS]: status
    };
    const predicates = new relationalStore.RdbPredicates(TABLE_APPOINTMENT_CACHE);
    predicates.equalTo(COLUMN_APPOINTMENT_ID, appointmentId);
    return await RdbHelper.update(TABLE_APPOINTMENT_CACHE, values, predicates);
  }

  public async markAsSynced(appointmentId: string): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_SYNCED]: 1
    };
    const predicates = new relationalStore.RdbPredicates(TABLE_APPOINTMENT_CACHE);
    predicates.equalTo(COLUMN_APPOINTMENT_ID, appointmentId);
    return await RdbHelper.update(TABLE_APPOINTMENT_CACHE, values, predicates);
  }

  public async getUnsyncedAppointments(): Promise<AppointmentCache[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_APPOINTMENT_CACHE);
    predicates.equalTo(COLUMN_SYNCED, 0);

    const appointments: AppointmentCache[] = [];
    const resultSet = await RdbHelper.queryByPredicates(predicates);
    
    while (resultSet.goToNextRow()) {
      appointments.push({
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        appointmentId: resultSet.getString(resultSet.getColumnIndex(COLUMN_APPOINTMENT_ID)),
        userId: resultSet.getString(resultSet.getColumnIndex(COLUMN_USER_ID)),
        doctorId: resultSet.getString(resultSet.getColumnIndex(COLUMN_DOCTOR_ID_FK)),
        hospitalId: resultSet.getString(resultSet.getColumnIndex(COLUMN_HOSPITAL_ID)),
        appointmentTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_APPOINTMENT_TIME)),
        status: resultSet.getString(resultSet.getColumnIndex(COLUMN_STATUS)),
        synced: resultSet.getLong(resultSet.getColumnIndex(COLUMN_SYNCED))
      });
    }
    resultSet.close();
    return appointments;
  }

  public async removeCachedAppointment(appointmentId: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_APPOINTMENT_CACHE);
    predicates.equalTo(COLUMN_APPOINTMENT_ID, appointmentId);
    return await RdbHelper.delete(predicates);
  }
}

const appointmentCacheManager = AppointmentCacheManager.getInstance();
export default appointmentCacheManager;
