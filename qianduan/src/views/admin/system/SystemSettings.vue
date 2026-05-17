<script setup>
import { ref, reactive } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAppStore } from '@/stores/app'
import { ElMessage } from 'element-plus'

const { t, locale } = useI18n()
const appStore = useAppStore()

const activeTab = ref('general')

const settingsForm = reactive({
  siteName: '智能医疗系统',
  siteDescription: 'Smart Medical System',
  contactPhone: '400-888-8888',
  contactEmail: 'admin@smartmed.com',
  icpNumber: '京ICP备12345678号',
  copyright: '© 2024 Smart Medical. All rights reserved.'
})

const notificationSettings = reactive({
  emailNotification: true,
  smsNotification: false,
  pushNotification: true,
  dailyReport: true,
  weeklyReport: false
})

const securitySettings = reactive({
  twoFactorAuth: false,
  sessionTimeout: 30,
  passwordExpiration: 90,
  loginLimit: 5
})

const handleSave = () => {
  ElMessage.success(t('common.save') + ' ' + t('common.success'))
}

const handleReset = () => {
  ElMessage.info(t('common.cancel'))
}
</script>

<template>
  <div class="system-settings">
    <div class="settings-header">
      <h2>{{ t('system.settings') }}</h2>
    </div>

    <el-tabs v-model="activeTab" class="settings-tabs">
      <el-tab-pane :label="t('system.general')" name="general">
        <div class="settings-panel">
          <h3>{{ t('system.generalSettings') }}</h3>
          <el-form :model="settingsForm" label-width="140px" class="settings-form">
            <el-form-item :label="t('system.siteName')">
              <el-input v-model="settingsForm.siteName"></el-input>
            </el-form-item>
            <el-form-item :label="t('system.siteDescription')">
              <el-input v-model="settingsForm.siteDescription"></el-input>
            </el-form-item>
            <el-form-item :label="t('system.contactPhone')">
              <el-input v-model="settingsForm.contactPhone"></el-input>
            </el-form-item>
            <el-form-item :label="t('system.contactEmail')">
              <el-input v-model="settingsForm.contactEmail"></el-input>
            </el-form-item>
            <el-form-item :label="t('system.icpNumber')">
              <el-input v-model="settingsForm.icpNumber"></el-input>
            </el-form-item>
            <el-form-item :label="t('system.copyright')">
              <el-input v-model="settingsForm.copyright"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSave">{{ t('common.save') }}</el-button>
              <el-button @click="handleReset">{{ t('common.cancel') }}</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-tab-pane>

      <el-tab-pane :label="t('system.notificationSettings')" name="notification">
        <div class="settings-panel">
          <h3>{{ t('system.notificationSettings') }}</h3>
          <el-form :model="notificationSettings" label-width="180px" class="settings-form">
            <el-form-item :label="t('system.emailNotification')">
              <el-switch v-model="notificationSettings.emailNotification"></el-switch>
            </el-form-item>
            <el-form-item :label="t('system.smsNotification')">
              <el-switch v-model="notificationSettings.smsNotification"></el-switch>
            </el-form-item>
            <el-form-item :label="t('system.pushNotification')">
              <el-switch v-model="notificationSettings.pushNotification"></el-switch>
            </el-form-item>
            <el-form-item :label="t('system.dailyReport')">
              <el-switch v-model="notificationSettings.dailyReport"></el-switch>
            </el-form-item>
            <el-form-item :label="t('system.weeklyReport')">
              <el-switch v-model="notificationSettings.weeklyReport"></el-switch>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSave">{{ t('common.save') }}</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-tab-pane>

      <el-tab-pane :label="t('system.securitySettings')" name="security">
        <div class="settings-panel">
          <h3>{{ t('system.securitySettings') }}</h3>
          <el-form :model="securitySettings" label-width="180px" class="settings-form">
            <el-form-item :label="t('system.twoFactorAuth')">
              <el-switch v-model="securitySettings.twoFactorAuth"></el-switch>
            </el-form-item>
            <el-form-item :label="t('system.sessionTimeout')">
              <el-input-number v-model="securitySettings.sessionTimeout" :min="5" :max="120"></el-input-number>
              <span class="form-tip">分钟</span>
            </el-form-item>
            <el-form-item :label="t('system.passwordExpiration')">
              <el-input-number v-model="securitySettings.passwordExpiration" :min="30" :max="180"></el-input-number>
              <span class="form-tip">天</span>
            </el-form-item>
            <el-form-item :label="t('system.loginLimit')">
              <el-input-number v-model="securitySettings.loginLimit" :min="3" :max="10"></el-input-number>
              <span class="form-tip">次</span>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSave">{{ t('common.save') }}</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-tab-pane>

      <el-tab-pane :label="t('system.aboutSystem')" name="about">
        <div class="settings-panel about-panel">
          <div class="about-logo">
            <div class="logo-icon">🏥</div>
            <div class="logo-text">
              <h2>Smart Medical System</h2>
              <p>{{ t('system.version') }}: 1.0.0</p>
            </div>
          </div>
          <el-divider></el-divider>
          <div class="about-info">
            <p><strong>{{ t('system.developer') }}:</strong> Smart Medical Team</p>
            <p><strong>{{ t('system.contact') }}:</strong> support@smartmed.com</p>
            <p><strong>{{ t('system.website') }}:</strong> www.smartmed.com</p>
          </div>
          <el-divider></el-divider>
          <div class="about-description">
            <p>{{ t('system.aboutDescription') }}</p>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<style lang="scss" scoped>
.system-settings {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.settings-header {
  margin-bottom: 24px;

  h2 {
    font-size: 20px;
    color: #333;
    margin: 0;
  }
}

.settings-tabs {
  :deep(.el-tabs__header) {
    margin-bottom: 24px;
  }
}

.settings-panel {
  max-width: 700px;

  h3 {
    font-size: 16px;
    color: #333;
    margin: 0 0 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #eee;
  }
}

.settings-form {
  .form-tip {
    margin-left: 8px;
    color: #999;
    font-size: 14px;
  }
}

.about-panel {
  max-width: 500px;
  text-align: center;

  .about-logo {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 16px;
    padding: 20px 0;

    .logo-icon {
      font-size: 64px;
    }

    .logo-text {
      h2 {
        margin: 0;
        font-size: 24px;
        color: #333;
      }

      p {
        margin: 8px 0 0;
        color: #666;
      }
    }
  }

  .about-info {
    text-align: left;
    padding: 0 20px;

    p {
      margin: 8px 0;
      color: #666;
    }
  }

  .about-description {
    padding: 0 20px;
    text-align: left;
    color: #666;
    line-height: 1.6;
  }
}
</style>
