import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/medicine/list', { params })
  },
  getDetail(id) {
    return request.get(`/medicine/detail/${id}`)
  },
  add(data) {
    return request.post('/medicine/add', data)
  },
  update(id, data) {
    return request.put('/medicine/update', { id, ...data })
  },
  delete(id) {
    return request.delete(`/medicine/delete/${id}`)
  }
}
