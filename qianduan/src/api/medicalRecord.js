import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/medical/record/page', { params })
  },
  getDetail(id) {
    return request.get('/medical/record/detail', { params: { id } })
  },
  add(data) {
    return request.post('/medical/record/create', data)
  },
  update(data) {
    return request.put('/medical/record/update', data)
  },
  delete(id) {
    return request.delete('/medical/record/delete', { params: { id } })
  },
  getDesensitized(id) {
    return request.get('/medical/record/desensitized', { params: { id } })
  }
}
