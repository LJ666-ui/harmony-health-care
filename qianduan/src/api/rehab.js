import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/api/rehab/plan/recommend', { params })
  },
  getDetail(id) {
    return request.get(`/api/rehab/plan/detail/${id}`)
  },
  getActions(planId) {
    return request.get(`/api/rehab/plan/actions/${planId}`)
  },
  getProgress(planId, userId) {
    return request.get(`/api/rehab/plan/progress/${planId}`, { params: { userId } })
  },
  create(data) {
    return request.post('/api/rehab/plan/create', data)
  },
  update(data) {
    return request.post('/api/rehab/plan/update', data)
  },
  delete(id) {
    return request.post(`/api/rehab/plan/delete/${id}`)
  }
}
