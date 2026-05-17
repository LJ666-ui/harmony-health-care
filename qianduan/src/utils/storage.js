const TOKEN_KEY = 'medical_token'
const USER_INFO_KEY = 'medical_user_info'
const LANG_KEY = 'medical_language'

export const storage = {
  getToken() {
    return localStorage.getItem(TOKEN_KEY)
  },
  setToken(token) {
    localStorage.setItem(TOKEN_KEY, token)
  },
  removeToken() {
    localStorage.removeItem(TOKEN_KEY)
  },
  getUserInfo() {
    const info = localStorage.getItem(USER_INFO_KEY)
    return info ? JSON.parse(info) : null
  },
  setUserInfo(userInfo) {
    localStorage.setItem(USER_INFO_KEY, JSON.stringify(userInfo))
  },
  removeUserInfo() {
    localStorage.removeItem(USER_INFO_KEY)
  },
  getLanguage() {
    return localStorage.getItem(LANG_KEY) || 'zh-CN'
  },
  setLanguage(lang) {
    localStorage.setItem(LANG_KEY, lang)
  },
  clearAll() {
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(USER_INFO_KEY)
    localStorage.removeItem(LANG_KEY)
  }
}
