import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/appointment/list', { params })
  },
  getDetail(id) {
    return request.get(`/appointment/${id}`)
  },
  create(data) {
    return request.post('/appointment', data)
  },
  update(id, data) {
    return request.put(`/appointment/${id}`, data)
  },
  delete(id) {
    return request.delete(`/appointment/${id}`)
  },
  getScheduleList(params) {
    return request.get('/doctor-schedule/list', { params })
  },
  getScheduleDetail(id) {
    return request.get(`/doctor-schedule/${id}`)
  },
  createSchedule(data) {
    return request.post('/doctor-schedule', data)
  },
  updateSchedule(id, data) {
    return request.put(`/doctor-schedule/${id}`, data)
  },
  deleteSchedule(id) {
    return request.delete(`/doctor-schedule/${id}`)
  },
  cancel(id) {
    return request.post(`/appointment/${id}/cancel`)
  },
  approve(id) {
    return request.post(`/appointment/${id}/approve`)
  },
  reject(id, data) {
    return request.post(`/appointment/${id}/reject`, data)
  },
  postpone(id, data) {
    return request.post(`/appointment/${id}/postpone`, data)
  },
  complete(id) {
    return request.post(`/appointment/${id}/complete`)
  },
  confirmPostpone(id) {
    return request.post(`/appointment/${id}/confirm-postpone`)
  },
  rejectPostpone(id) {
    return request.post(`/appointment/${id}/reject-postpone`)
  }
}
