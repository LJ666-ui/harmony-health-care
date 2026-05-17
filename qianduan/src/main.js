import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createI18n } from 'vue-i18n'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import router from '@/router'
import App from './App.vue'
import { storage } from '@/utils/storage'
import zhCN from '@/locales/zh-CN'
import enUS from '@/locales/en-US'

const i18n = createI18n({
  legacy: false,
  locale: storage.getLanguage() || 'zh-CN',
  messages: {
    'zh-CN': zhCN,
    'en-US': enUS
  }
})

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(ElementPlus)
app.use(i18n)

app.mount('#app')
