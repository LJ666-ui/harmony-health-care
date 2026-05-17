import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/herbal/page', { params: { page: params.page || 1, size: params.size || 10, keyword: params.name || params.keyword } })
  },
  getDetail(id) {
    return request.get(`/herbal/info/${id}`)
  },
  add(data) {
    return request.post('/herbal/add', data)
  },
  update(id, data) {
    return request.put('/herbal/update', { id, ...data })
  },
  delete(id) {
    return request.delete(`/herbal/delete/${id}`)
  },
  incrementView(id) {
    return request.post(`/herbal/view/${id}`)
  },
  collect(id, data) {
    return request.post(`/herbal/collect/${id}`, data || {})
  },
  uncollect(id, data) {
    return request.post(`/herbal/uncollect/${id}`, data || {})
  },
  getCategories() {
    return request.get('/herbal/categories')
  },
  getAll() {
    return request.get('/herbal/list/all')
  }
}
