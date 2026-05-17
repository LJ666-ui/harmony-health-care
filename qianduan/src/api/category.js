import request from '@/utils/request'

export default {
  getList() {
    return request.get('/healthArticle/categories/parent')
  },
  getChildren(parentId) {
    return request.get(`/healthArticle/categories/children/${parentId}`)
  }
}
