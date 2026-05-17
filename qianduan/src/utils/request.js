import axios from 'axios'
import { storage } from './storage'

const baseURL = import.meta.env.VITE_APP_API_BASE_URL || 'http://localhost:8080'

const request = axios.create({
  baseURL,
  timeout: 30000
})

request.interceptors.request.use(
  config => {
    if (!config) return config
    const token = storage.getToken()
    if (token) {
      config.headers = config.headers || {}
      config.headers['Token'] = token
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

request.interceptors.response.use(
  response => {
    const res = response.data
    
    if (res.code !== undefined) {
      if (res.code !== 200) {
        if (res.code === 401) {
          storage.clearAll()
          window.location.href = '/login'
        }
        return Promise.reject(new Error(res.msg || 'Error'))
      }
      return res.data
    } else if (res.success !== undefined) {
      if (!res.success) {
        return Promise.reject(new Error(res.message || 'Error'))
      }
      return res.data || res
    }
    
    return res
  },
  error => {
    return Promise.reject(error)
  }
)

export default request
