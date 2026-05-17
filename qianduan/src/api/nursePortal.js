import request from '@/utils/request'

export default {
  getNurseInfo(userId) { return request.get('/nurse-portal/info', { params: { userId } }) },
  getPatients(nurseId, params) { return request.get('/nurse-portal/patients', { params: { nurseId, ...params } }) },
  getPatientDetail(patientId) { return request.get(`/nurse-portal/patient-detail/${patientId}`) },
  getVitalSigns(patientId, params) { return request.get('/nurse-portal/vital-signs', { params: { patientId, ...params } }) },
  createNursingRecord(data) { return request.post('/nurse-portal/nursing-record', data) },
  getNursingRecords(patientId, params) { return request.get('/nurse-portal/nursing-records', { params: { patientId, ...params } }) },
  getCarePlans(nurseId, params) { return request.get('/nurse-portal/care-plans', { params: { nurseId, ...params } }) },
  createCarePlan(data) { return request.post('/nurse-portal/care-plan', data) },
  updateCarePlan(id, data) { return request.put(`/nurse-portal/care-plan/${id}`, data) },
  getMedicationForExec(nurseId, params) { return request.get('/nurse-portal/medication-exec', { params: { nurseId, ...params } }) },
  executeMedication(id, status) { return request.post(`/nurse-portal/medication-exec/${id}`, null, { params: { status } }) },
  getStatistics(nurseId) { return request.get('/nurse-portal/statistics', { params: { nurseId } }) },
  submitRecoveryRequest(data) { return request.post('/nurse-portal/recovery-request/submit', data) }
}
