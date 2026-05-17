import request from '@/utils/request'

export default {
  getGraph(centerId, depth = 2) {
    return request.get('/api/knowledge/graph', { params: { centerId, depth } })
  },
  getNodeDetail(id) {
    return request.get(`/api/knowledge/node/${id}`)
  },
  searchNodes(keyword) {
    return request.get('/api/knowledge/search', { params: { keyword } })
  },
  findPath(from, to) {
    return request.get('/api/knowledge/path', { params: { from, to } })
  },
  getNodesByType(type) {
    return request.get('/api/knowledge/nodes', { params: { type } })
  },
  explore(data) {
    return request.post('/api/knowledge/explore', data)
  },
  getStats() {
    return request.get('/api/knowledge/stats')
  },
  getRelatedNodes(id, type) {
    return request.get('/api/knowledge/related', { params: { id, type } })
  }
}
