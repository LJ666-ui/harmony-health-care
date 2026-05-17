import request from '@/utils/request'

export default {
  getConsultationList(params) {
    return request.get('/consultation/list', { params })
  },
  getPatientConsultations(patientId) {
    return request.get(`/consultation/patient/${patientId}`)
  },
  getDoctorQueue(doctorId) {
    return request.get('/consultation/doctor/queue', { params: { doctorId } })
  },
  getConsultationDetail(id) {
    return request.get(`/consultation/${id}`)
  },
  createConsultation(data) {
    return request.post('/consultation', data)
  },
  acceptConsultation(id) {
    return request.post(`/consultation/${id}/accept`)
  },
  completeConsultation(id, data) {
    return request.post(`/consultation/${id}/complete`, data)
  },
  cancelConsultation(id, reason) {
    return request.post(`/consultation/${id}/cancel`, reason ? { reason } : {})
  },
  rateConsultation(id, data) {
    return request.post(`/consultation/${id}/rate`, data)
  },
  getMessages(consultationId, page = 1, pageSize = 50) {
    return request.get(`/consultation/${consultationId}/messages`, { params: { page, pageSize } })
  },
  markAsRead(consultationId, userId) {
    return request.post(`/consultation/${consultationId}/messages/read`, { userId })
  },
  getStatistics(doctorId) {
    return request.get('/consultation/statistics', { params: { doctorId } })
  }
}
