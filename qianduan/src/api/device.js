import request from '@/utils/request'

export default {
  getBindList(params) {
    return request.get('/device/bind/list', { params })
  },
  bindDevice(data) {
    return request.post('/device/bind', data)
  },
  unbindDevice(id) {
    return request.delete(`/device/unbind/${id}`)
  },
  syncData(deviceId) {
    return request.get(`/device/sync/${deviceId}`)
  }
}
