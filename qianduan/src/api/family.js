import request from '@/utils/request'

export default {
  getMemberList(params) {
    return request.get('/family/member/list', { params })
  },
  getMemberDetail(id) {
    return request.get(`/family/member/${id}`)
  },
  createMember(data) {
    return request.post('/family/member', data)
  },
  updateMember(id, data) {
    return request.put(`/family/member/${id}`, data)
  },
  deleteMember(id) {
    return request.delete(`/family/member/${id}`)
  },
  getAuthLogList(params) {
    return request.get('/family/auth-log/list', { params })
  },
  enableLogin(id, data) {
    return request.post(`/family/member/${id}/enable-login`, data)
  },
  disableLogin(id) {
    return request.post(`/family/member/${id}/disable-login`)
  }
}
