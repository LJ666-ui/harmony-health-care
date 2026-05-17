import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { storage } from '@/utils/storage'

export const useAppStore = defineStore('app', () => {
  const language = ref(storage.getLanguage())
  const sidebarOpened = ref(true)
  const loading = ref(false)
  const device = ref('desktop')

  const isMobile = computed(() => device.value === 'mobile')

  const setLanguage = (lang) => {
    language.value = lang
    storage.setLanguage(lang)
  }

  const toggleSidebar = () => {
    sidebarOpened.value = !sidebarOpened.value
  }

  const setLoading = (status) => {
    loading.value = status
  }

  const setDevice = (deviceType) => {
    device.value = deviceType
  }

  return {
    language,
    sidebarOpened,
    loading,
    device,
    isMobile,
    setLanguage,
    toggleSidebar,
    setLoading,
    setDevice
  }
})
