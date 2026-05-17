import request from '@/utils/request'

export default {
  getList(params) {
    return request.get('/ward/list', { params })
  },
  getDetail(id) {
    return request.get(`/ward/${id}`)
  },
  create(data) {
    return request.post('/ward', data)
  },
  update(id, data) {
    return request.put(`/ward/${id}`, data)
  },
  delete(id) {
    return request.delete(`/ward/${id}`)
  },
  getDeviceList(wardNumber) {
    return request.get(`/ward/device/list?wardNumber=${wardNumber}`)
  },
  getDeviceDetail(id) {
    return request.get(`/ward/device/${id}`)
  },
  createDevice(data) {
    return request.post('/ward/device', data)
  },
  updateDevice(id, data) {
    return request.put(`/ward/device/${id}`, data)
  },
  deleteDevice(id) {
    return request.delete(`/ward/device/${id}`)
  },
  controlDevice(id, data) {
    return request.put(`/ward/device/${id}/control`, data)
  }
}
