import request from '@/utils/request'

export default {
  login(data) {
    return request.post('/user/login', data)
  },
  adminLogin(data) {
    return request.post('/user/adminLogin', data)
  },
  familyLogin(data) {
    return request.post('/user/familyLogin', data)
  },
  register(data) {
    return request.post('/user/register', data)
  },
  getUserInfo(id) {
    return request.get(`/user/info?id=${id}`)
  },
  getDetail(id) {
    return request.get(`/user/info?id=${id}`)
  },
  updateUser(data) {
    return request.post('/user/update', data)
  },
  update(id, data) {
    return request.post('/user/update', { id, ...data })
  },
  getUserList(params) {
    return request.get('/user/list', { params })
  },
  getPage(params) {
    return request.get('/user/page', { params })
  },
  add(data) {
    return request.post('/user/add', data)
  },
  deleteUser(id) {
    return request.delete(`/user/delete/${id}`)
  },
  delete(id) {
    return request.delete(`/user/delete/${id}`)
  },
  searchPatient(phone) {
    return request.get('/user/search-patient', { params: { phone } })
  },
  getMyDoctors(userId) {
    return request.get('/user/my-doctors', { params: { userId } })
  },
  getMyNurses(userId) {
    return request.get('/user/my-nurses', { params: { userId } })
  }
}
