import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/follow-up/list', { params })
  },
  getDetail(id) {
    return request.get(`/follow-up/${id}`)
  },
  create(data) {
    return request.post('/follow-up', data)
  },
  update(id, data) {
    return request.put(`/follow-up/${id}`, data)
  },
  delete(id) {
    return request.delete(`/follow-up/${id}`)
  },
  complete(id) {
    return request.post(`/follow-up/${id}/complete`)
  }
}
