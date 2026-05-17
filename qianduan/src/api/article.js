import request from '@/utils/request'

export default {
  getPage(params) {
    return request.get('/healthArticle/page', { params })
  },
  getDetail(id) {
    return request.get(`/healthArticle/detail/${id}`)
  },
  add(data) {
    return request.post('/healthArticle/add', data)
  },
  update(data) {
    return request.put('/healthArticle/update', data)
  },
  delete(id) {
    return request.delete(`/healthArticle/delete/${id}`)
  },
  getList(params) {
    return request.get('/healthArticle/list', { params })
  },
  getParentCategories() {
    return request.get('/healthArticle/categories/parent')
  },
  getChildrenCategories(parentId) {
    return request.get(`/healthArticle/categories/children/${parentId}`)
  }
}
