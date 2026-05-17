import request from '@/utils/request'

export default {
  getGroupList(params) {
    return request.get('/patient-group/list', { params })
  },
  getGroupDetail(id) {
    return request.get(`/patient-group/${id}`)
  },
  createGroup(data) {
    return request.post('/patient-group', data)
  },
  updateGroup(id, data) {
    return request.put(`/patient-group/${id}`, data)
  },
  deleteGroup(id) {
    return request.delete(`/patient-group/${id}`)
  },
  getRelationList(groupId) {
    return request.get(`/patient-group/relation/list?groupId=${groupId}`)
  },
  createRelation(data) {
    return request.post('/patient-group/relation', data)
  },
  deleteRelation(id) {
    return request.delete(`/patient-group/relation/${id}`)
  }
}
