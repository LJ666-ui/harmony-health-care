import request from '@/utils/request'

export default {
  getApplyList(params) {
    return request.get('/transfer/pending', { params })
  },
  getApplyDetail(id) {
    return request.get(`/transfer/my`)
  },
  addApply(data) {
    return request.post('/transfer/apply', data)
  },
  approveApply(id) {
    return request.post(`/transfer/approve/${id}`)
  },
  rejectApply(id, data) {
    return request.post(`/transfer/reject/${id}`, data)
  },
  deleteApply(id) {
    return request.delete(`/transfer/delete/${id}`)
  },
  getHistory(params) {
    return request.get('/transfer/history', { params })
  },
  getAllList(params) {
    return request.get('/transfer/all', { params })
  }
}
