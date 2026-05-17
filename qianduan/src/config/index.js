export default {
  development: {
    baseURL: 'http://localhost:8080',
    timeout: 30000
  },
  production: {
    baseURL: 'http://localhost:8080',
    timeout: 30000
  },
  userTypes: {
    0: '普通用户',
    1: '医生',
    2: '管理员',
    3: '护士'
  },
  statusMap: {
    0: '待审核',
    1: '已通过',
    2: '已拒绝'
  }
}
