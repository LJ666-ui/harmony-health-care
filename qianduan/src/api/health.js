import request from '@/utils/request'

export default {
  getRecordList(params) {
    return request.get('/health-record/list', { params })
  },
  getRecordDetail(id) {
    return request.get(`/health-record/${id}`)
  },
  createRecord(data) {
    return request.post('/health-record', data)
  },
  updateRecord(id, data) {
    return request.put(`/health-record/${id}`, data)
  },
  deleteRecord(id) {
    return request.delete(`/health-record/${id}`)
  },
  getRiskAssessList(params) {
    return request.get('/risk-assess/list', { params })
  },
  getRiskAssessDetail(id) {
    return request.get(`/risk-assess/${id}`)
  },
  createRiskAssess(data) {
    return request.post('/risk-assess', data)
  },
  getAlertList(params) {
    return request.get('/health-alert/list', { params })
  },
  getAlertDetail(id) {
    return request.get(`/health-alert/${id}`)
  },
  handleAlert(id, data) {
    return request.put(`/health-alert/${id}/handle`, data)
  },
  getStandardList(params) {
    return request.get('/health-standard/list', { params })
  },
  getFoodList(params) {
    return request.get('/health-food/list', { params })
  }
}
