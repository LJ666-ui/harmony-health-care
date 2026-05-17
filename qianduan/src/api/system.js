import request from '@/utils/request'

export default {
  getOperLogList(params) {
    return request.get('/log/oper/list', { params })
  },
  getOperLogByUser(userId, params) {
    return request.get('/log/oper/user', { params: { userId, ...params } })
  },
  getOperLogByTime(startTime, endTime, params) {
    return request.get('/log/oper/time', { params: { startTime, endTime, ...params } })
  },
  getOperStatistics() {
    return request.get('/log/oper/statistics')
  }
}
