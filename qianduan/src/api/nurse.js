import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/nurse/list', { params })
  },
  getDetail(id) {
    return request.get(`/nurse/${id}`)
  },
  create(data) {
    return request.post('/nurse', data)
  },
  update(id, data) {
    return request.put(`/nurse/${id}`, data)
  },
  delete(id) {
    return request.delete(`/nurse/${id}`)
  },
  getScheduleList(params) {
    return request.get('/nurse-schedule/list', { params })
  },
  createSchedule(data) {
    return request.post('/nurse-schedule', data)
  },
  updateSchedule(id, data) {
    return request.put(`/nurse-schedule/${id}`, data)
  },
  deleteSchedule(id) {
    return request.delete(`/nurse-schedule/${id}`)
  },
  getPatientRelationList(nurseId) {
    return request.get(`/nurse/patient/list?nurseId=${nurseId}`)
  },
  createPatientRelation(data) {
    return request.post('/nurse/patient', data)
  },
  deletePatientRelation(id) {
    return request.delete(`/nurse/patient/${id}`)
  }
}
