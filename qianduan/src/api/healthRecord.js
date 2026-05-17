import request from '@/utils/request'

export default {
  getList(userId) {
    return request.get('/healthRecord/my', { params: { userId } })
  },
  getPage(page, size, userId) {
    return request.get('/healthRecord/page', { params: { page, size, userId } })
  },
  getByTime(userId, startTime, endTime) {
    return request.get('/healthRecord/time', { params: { userId, startTime, endTime } })
  },
  add(data) {
    return request.post('/healthRecord/add', data)
  },
  update(id, data) {
    return request.put('/healthRecord/update', { id, ...data })
  },
  delete(id) {
    return request.delete('/healthRecord/delete', { params: { id } })
  }
}
