<script setup>
import { reactive } from 'vue'

const settingsForm = reactive({
  siteName: '智能医疗系统',
  siteDescription: 'Smart Medical System',
  contactPhone: '400-888-8888',
  contactEmail: 'admin@smartmed.com',
  icpNumber: '京ICP备12345678号',
  copyright: '© 2024 Smart Medical. All rights reserved.'
})
</script>

<template>
  <div class="settings-view">
    <h3>系统设置</h3>
    <el-form :model="settingsForm" label-width="140px" class="settings-form" disabled>
      <el-form-item label="系统名称">
        <el-input v-model="settingsForm.siteName" />
      </el-form-item>
      <el-form-item label="系统描述">
        <el-input v-model="settingsForm.siteDescription" />
      </el-form-item>
      <el-form-item label="联系电话">
        <el-input v-model="settingsForm.contactPhone" />
      </el-form-item>
      <el-form-item label="联系邮箱">
        <el-input v-model="settingsForm.contactEmail" />
      </el-form-item>
      <el-form-item label="备案号">
        <el-input v-model="settingsForm.icpNumber" />
      </el-form-item>
      <el-form-item label="版权信息">
        <el-input v-model="settingsForm.copyright" />
      </el-form-item>
    </el-form>
    <el-alert type="info" :closable="false" style="margin-top: 16px">
      系统设置仅管理员可修改，如有需要请联系管理员。
    </el-alert>
  </div>
</template>

<style lang="scss" scoped>
.settings-view {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  h3 { font-size: 18px; margin: 0 0 20px; }
}
.settings-form { max-width: 600px; }
</style>
