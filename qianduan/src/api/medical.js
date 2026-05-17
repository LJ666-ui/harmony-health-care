import request from '@/utils/request'

export default {
  getRecordList(params) {
    return request.get('/medical-record/list', { params })
  },
  getRecordDetail(id) {
    return request.get(`/medical-record/${id}`)
  },
  createRecord(data) {
    return request.post('/medical-record', data)
  },
  updateRecord(id, data) {
    return request.put(`/medical-record/${id}`, data)
  },
  deleteRecord(id) {
    return request.delete(`/medical-record/${id}`)
  },
  getDiseaseList(params) {
    return request.get('/disease/list', { params })
  },
  getDiseaseDetail(id) {
    return request.get(`/disease/${id}`)
  },
  createDisease(data) {
    return request.post('/disease', data)
  },
  updateDisease(id, data) {
    return request.put(`/disease/${id}`, data)
  },
  deleteDisease(id) {
    return request.delete(`/disease/${id}`)
  },
  getCheckupReportList(params) {
    return request.get('/checkup-report/list', { params })
  },
  getCheckupReportDetail(id) {
    return request.get(`/checkup-report/${id}`)
  },
  createCheckupReport(data) {
    return request.post('/checkup-report', data)
  },
  deleteCheckupReport(id) {
    return request.delete(`/checkup-report/${id}`)
  }
}
