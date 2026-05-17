import request from '@/utils/request'

export default {
  getList() {
    return request.get('/hospital/list')
  },
  getDetail(id) {
    return request.get(`/hospital/info/${id}`)
  },
  getPage(params) {
    return request.get('/hospital/page', { params })
  },
  getNearby(params) {
    return request.get('/hospital/nearby', { params })
  },
  getDepartments(hospitalId) {
    return request.get(`/hospital/department/list?hospitalId=${hospitalId}`)
  },
  getAllDepartments() {
    return request.get('/hospital/department/all')
  },
  getDepartmentDetail(id) {
    return request.get(`/hospital/department/info/${id}`)
  },
  addDepartment(data) {
    return request.post('/hospital/department/add', data)
  },
  updateDepartment(data) {
    return request.post('/hospital/department/update', data)
  },
  deleteDepartment(id) {
    return request.post(`/hospital/department/delete?id=${id}`)
  },
  add(data) {
    return request.post('/hospital/add', data)
  },
  update(data) {
    return request.put('/hospital/update', data)
  },
  delete(id) {
    return request.delete(`/hospital/delete/${id}`)
  }
}
