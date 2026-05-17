import request from '@/utils/request'

export default {
  getFamilyInfo(userId) { return request.get('/family-portal/info', { params: { userId } }) },
  getPatientInfo(userId) { return request.get('/family-portal/patient-info', { params: { userId } }) },
  getFamilyMembers(userId) { return request.get('/family-portal/family-members', { params: { userId } }) },
  getLinkedPatients(userId, familyMemberId) { return request.get('/family-portal/linked-patients', { params: { userId, familyMemberId } }) },
  getAlerts(userId, params, familyMemberId) { return request.get('/family-portal/alerts', { params: { userId, familyMemberId, ...params } }) },
  getActiveAlerts(userId, familyMemberId) { return request.get('/family-portal/active-alerts', { params: { userId, familyMemberId } }) },
  handleAlert(alertId, data) { return request.post(`/family-portal/alert/handle/${alertId}`, data) },
  getHealthData(patientId, params) { return request.get('/family-portal/health-data', { params: { patientId, ...params } }) },
  getHealthSummary(patientId) { return request.get('/family-portal/health-summary', { params: { patientId } }) },
  acknowledgeAlert(alertId) { return request.post(`/family-portal/alert/acknowledge/${alertId}`) },
  resolveAlert(alertId) { return request.post(`/family-portal/alert/resolve/${alertId}`) },
  getAlertHistory(userId, params, familyMemberId) { return request.get('/family-portal/alert-history', { params: { userId, familyMemberId, ...params } }) },
  getPatientDoctors(userId) { return request.get('/family-portal/patient-doctors', { params: { userId } }) },
  getPatientNurses(userId) { return request.get('/family-portal/patient-nurses', { params: { userId } }) }
}
