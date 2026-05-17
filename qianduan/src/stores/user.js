import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { storage } from '@/utils/storage'
import userApi from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const token = ref(storage.getToken())
  const userInfo = ref(storage.getUserInfo())

  const isLoggedIn = computed(() => !!token.value)
  const isAdmin = computed(() => userInfo.value?.userType === 2)
  const isDoctor = computed(() => userInfo.value?.userType === 1)
  const isNurse = computed(() => userInfo.value?.userType === 3)
  const isFamily = computed(() => userInfo.value?.userType === 4)
  const isUser = computed(() => userInfo.value?.userType === 0)
  const userRoleName = computed(() => {
    const t = userInfo.value?.userType
    if (t === 2) return '管理员'
    if (t === 1) return '医生'
    if (t === 3) return '护士'
    if (t === 4) return '家属'
    return '普通用户'
  })

  const login = async (phone, password) => {
    const res = await userApi.login({ phone, password })
    token.value = res.token
    userInfo.value = { userId: res.userId, username: res.username, realName: res.realName, userType: res.userType }
    storage.setToken(res.token)
    storage.setUserInfo(userInfo.value)
    return res
  }

  const adminLogin = async (username, password) => {
    const res = await userApi.adminLogin({ username, password })
    token.value = res.token
    userInfo.value = { userId: res.userId, username: res.username, realName: res.realName, userType: res.userType }
    storage.setToken(res.token)
    storage.setUserInfo(userInfo.value)
    return res
  }

  const familyLogin = async (phone, password) => {
    const res = await userApi.familyLogin({ phone, password })
    token.value = res.token
    userInfo.value = { userId: res.userId, familyMemberId: res.familyMemberId, username: res.username, realName: res.realName, userType: res.userType, relation: res.relation }
    storage.setToken(res.token)
    storage.setUserInfo(userInfo.value)
    return res
  }

  const register = async (userData) => { return await userApi.register(userData) }

  const logout = () => { token.value = null; userInfo.value = null; storage.clearAll() }

  const getUserInfo = async (userId) => {
    const res = await userApi.getUserInfo(userId)
    userInfo.value = { ...userInfo.value, ...res }
    storage.setUserInfo(userInfo.value)
    return res
  }

  const updateUser = async (userData) => { return await userApi.updateUser(userData) }

  return { token, userInfo, isLoggedIn, isAdmin, isDoctor, isNurse, isFamily, isUser, userRoleName, login, adminLogin, familyLogin, register, logout, getUserInfo, updateUser }
})
