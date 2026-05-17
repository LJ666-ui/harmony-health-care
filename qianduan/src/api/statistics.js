import request from '@/utils/request'

export default {
  getOverview() {
    return request.get('/statistics/overview')
  },
  getUserStats(params) {
    return request.get('/statistics/user', { params })
  },
  getArticleStats(params) {
    return request.get('/statistics/article', { params })
  },
  getHealthStats(params) {
    return request.get('/statistics/health', { params })
  },
  getRecentActivities(limit = 10) {
    return request.get('/log/oper/recent', { params: { limit } })
  }
}
