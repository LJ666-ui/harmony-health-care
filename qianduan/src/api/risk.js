import request from '@/utils/request'

export default {
  getList(userId, page = 1, size = 10) {
    return request.get(`/risk/list/${userId}`, { params: { page, size } })
  },
  getLatest(userId) {
    return request.get(`/risk/latest/${userId}`)
  },
  assess(userId) {
    return request.post(`/risk/assess/${userId}`)
  },
  getDetail(id) {
    return request.get(`/risk/get/${id}`)
  },
  delete(id) {
    return request.delete(`/risk/delete/${id}`)
  }
}
