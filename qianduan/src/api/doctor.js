import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/doctor/list', { params })
  },
  getDetail(id) {
    return request.get(`/doctor/${id}`)
  },
  create(data) {
    return request.post('/doctor', data)
  },
  update(id, data) {
    return request.put(`/doctor/${id}`, data)
  },
  delete(id) {
    return request.delete(`/doctor/${id}`)
  },
  getMessageList(params) {
    return request.get('/doctor/message/list', { params })
  },
  sendMessage(data) {
    return request.post('/doctor/message', data)
  },
  readMessage(id) {
    return request.post(`/doctor/message/${id}/read`)
  }
}
