import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  { path: '/login', name: 'Login', component: () => import('@/views/login/Login.vue') },
  { path: '/register', name: 'Register', component: () => import('@/views/login/Register.vue') },
  {
    path: '/user',
    component: () => import('@/layouts/UserLayout.vue'),
    redirect: '/user/home',
    children: [
      { path: 'home', name: 'UserHome', component: () => import('@/views/user/Home.vue') },
      { path: 'appointment', name: 'UserAppointment', component: () => import('@/views/user/AppointmentView.vue') },
      { path: 'article', name: 'UserArticle', component: () => import('@/views/user/ArticleView.vue') },
      { path: 'hospital', name: 'UserHospital', component: () => import('@/views/user/HospitalView.vue') },
      { path: 'medical-record', name: 'UserMedicalRecord', component: () => import('@/views/user/MedicalRecordView.vue') },
      { path: 'health-record', name: 'UserHealthRecord', component: () => import('@/views/user/HealthRecordView.vue') },
      { path: 'medical-team', name: 'UserMedicalTeam', component: () => import('@/views/user/MedicalTeamView.vue') },
      { path: 'knowledge', name: 'UserKnowledge', component: () => import('@/views/user/KnowledgeView.vue') },
      { path: 'ai', name: 'UserAI', component: () => import('@/views/user/AIView.vue') },
      { path: 'risk', name: 'UserRisk', component: () => import('@/views/user/RiskView.vue') },
      { path: 'herbal', name: 'UserHerbal', component: () => import('@/views/user/HerbalView.vue') },
      { path: 'doctor-search', name: 'UserDoctorSearch', component: () => import('@/views/user/DoctorSearch.vue') },
      { path: 'consultation', name: 'UserConsultationList', component: () => import('@/views/user/ConsultationList.vue') },
      { path: 'consultation/:id', name: 'UserConsultationChat', component: () => import('@/views/user/ConsultationChat.vue') },
      { path: 'pre-diagnosis', name: 'UserPreDiagnosis', component: () => import('@/views/user/PreDiagnosis.vue') },
      { path: 'digital-twin', name: 'UserDigitalTwin', component: () => import('@/views/user/DigitalTwin.vue') },
      { path: 'ar-rehab', name: 'UserARRehab', component: () => import('@/views/user/ARRehab.vue') },
      { path: 'knowledge-qa', name: 'UserKnowledgeQA', component: () => import('@/views/user/KnowledgeQA.vue') },
      { path: 'emotion', name: 'UserEmotion', component: () => import('@/views/user/EmotionAnalysis.vue') },
      { path: 'game', name: 'UserHealthGame', component: () => import('@/views/user/HealthGame.vue') },
      { path: 'dialect', name: 'UserDialectConsultation', component: () => import('@/views/user/DialectConsultation.vue') },
      { path: 'virtual-ward', name: 'UserVirtualWard', component: () => import('@/views/user/VirtualWard.vue') },
      { path: 'drug-interaction', name: 'UserDrugInteraction', component: () => import('@/views/user/DrugInteraction.vue') },
      { path: 'profile', name: 'UserProfile', component: () => import('@/views/shared/ProfileView.vue') },
      { path: 'settings', name: 'UserSettings', component: () => import('@/views/shared/SystemSettingsView.vue') }
    ]
  },
  {
    path: '/doctor',
    component: () => import('@/layouts/DoctorLayout.vue'),
    redirect: '/doctor/home',
    children: [
      { path: 'home', name: 'DoctorHome', component: () => import('@/views/doctor/Home.vue') },
      { path: 'appointment', name: 'DoctorAppointment', component: () => import('@/views/doctor/Appointment.vue') },
      { path: 'transfer', name: 'DoctorTransfer', component: () => import('@/views/doctor/Transfer.vue') },
      { path: 'medical-record', name: 'DoctorMedicalRecord', component: () => import('@/views/doctor/MedicalRecord.vue') },
      { path: 'medication', name: 'DoctorMedication', component: () => import('@/views/doctor/Medication.vue') },
      { path: 'patients', name: 'DoctorPatients', component: () => import('@/views/doctor/Patients.vue') },
      { path: 'consultation', name: 'DoctorConsultation', component: () => import('@/views/doctor/DoctorConsultation.vue') },
      { path: 'digital-twin', name: 'DoctorDigitalTwin', component: () => import('@/views/user/DigitalTwin.vue') },
      { path: 'ar-rehab', name: 'DoctorARRehab', component: () => import('@/views/user/ARRehab.vue') },
      { path: 'knowledge-qa', name: 'DoctorKnowledgeQA', component: () => import('@/views/user/KnowledgeQA.vue') },
      { path: 'emotion', name: 'DoctorEmotion', component: () => import('@/views/user/EmotionAnalysis.vue') },
      { path: 'virtual-ward', name: 'DoctorVirtualWard', component: () => import('@/views/user/VirtualWard.vue') },
      { path: 'drug-interaction', name: 'DoctorDrugInteraction', component: () => import('@/views/user/DrugInteraction.vue') },
      { path: 'dialect', name: 'DoctorDialect', component: () => import('@/views/user/DialectConsultation.vue') },
      { path: 'profile', name: 'DoctorProfile', component: () => import('@/views/shared/ProfileView.vue') },
      { path: 'settings', name: 'DoctorSettings', component: () => import('@/views/shared/SystemSettingsView.vue') }
    ]
  },
  {
    path: '/nurse',
    component: () => import('@/layouts/NurseLayout.vue'),
    redirect: '/nurse/home',
    children: [
      { path: 'home', name: 'NurseHome', component: () => import('@/views/nurse/Home.vue') },
      { path: 'patients', name: 'NursePatients', component: () => import('@/views/nurse/Patients.vue') },
      { path: 'vital-signs', name: 'NurseVitalSigns', component: () => import('@/views/nurse/VitalSigns.vue') },
      { path: 'nursing-record', name: 'NurseNursingRecord', component: () => import('@/views/nurse/NursingRecord.vue') },
      { path: 'medication-exec', name: 'NurseMedicationExec', component: () => import('@/views/nurse/MedicationExec.vue') },
      { path: 'virtual-ward', name: 'NurseVirtualWard', component: () => import('@/views/user/VirtualWard.vue') },
      { path: 'profile', name: 'NurseProfile', component: () => import('@/views/shared/ProfileView.vue') },
      { path: 'settings', name: 'NurseSettings', component: () => import('@/views/shared/SystemSettingsView.vue') }
    ]
  },
  {
    path: '/family',
    component: () => import('@/layouts/FamilyLayout.vue'),
    redirect: '/family/home',
    children: [
      { path: 'home', name: 'FamilyHome', component: () => import('@/views/family/Home.vue') },
      { path: 'patient-info', name: 'FamilyPatientInfo', component: () => import('@/views/family/PatientInfo.vue') },
      { path: 'alert', name: 'FamilyAlert', component: () => import('@/views/family/Alert.vue') },
      { path: 'health-data', name: 'FamilyHealthData', component: () => import('@/views/family/HealthData.vue') },
      { path: 'virtual-ward', name: 'FamilyVirtualWard', component: () => import('@/views/user/VirtualWard.vue') },
      { path: 'medical-team', name: 'FamilyMedicalTeam', component: () => import('@/views/family/MedicalTeamView.vue') },
      { path: 'article', name: 'FamilyArticle', component: () => import('@/views/user/ArticleView.vue') },
      { path: 'hospital', name: 'FamilyHospital', component: () => import('@/views/user/HospitalView.vue') },
      { path: 'knowledge', name: 'FamilyKnowledge', component: () => import('@/views/user/KnowledgeView.vue') },
      { path: 'ai', name: 'FamilyAI', component: () => import('@/views/user/AIView.vue') },
      { path: 'herbal', name: 'FamilyHerbal', component: () => import('@/views/user/HerbalView.vue') },
      { path: 'consultation', name: 'FamilyConsultationList', component: () => import('@/views/user/ConsultationList.vue') },
      { path: 'consultation/:id', name: 'FamilyConsultationChat', component: () => import('@/views/user/ConsultationChat.vue') },
      { path: 'profile', name: 'FamilyProfile', component: () => import('@/views/family/Profile.vue') },
      { path: 'settings', name: 'FamilySettings', component: () => import('@/views/shared/SystemSettingsView.vue') }
    ]
  },
  {
    path: '/admin',
    component: () => import('@/layouts/DefaultLayout.vue'),
    redirect: '/admin/home',
    children: [
      { path: 'home', name: 'AdminHome', component: () => import('@/views/admin/home/Home.vue') },
      { path: 'user', name: 'AdminUserList', component: () => import('@/views/admin/system/user/UserList.vue') },
      { path: 'user/form', name: 'AdminUserForm', component: () => import('@/views/admin/system/user/UserForm.vue') },
      { path: 'admin', name: 'AdminAdminList', component: () => import('@/views/admin/system/admin/AdminList.vue') },
      { path: 'doctor', name: 'AdminDoctorList', component: () => import('@/views/admin/doctor/DoctorList.vue') },
      { path: 'family', name: 'AdminFamilyList', component: () => import('@/views/admin/system/family/FamilyList.vue') },
      { path: 'nurse', name: 'AdminNurseList', component: () => import('@/views/admin/system/nurse/NurseList.vue') },
      { path: 'article', name: 'AdminArticleList', component: () => import('@/views/admin/article/ArticleList.vue') },
      { path: 'article/form', name: 'AdminArticleForm', component: () => import('@/views/admin/article/ArticleForm.vue') },
      { path: 'article/category', name: 'AdminCategoryList', component: () => import('@/views/admin/article/CategoryList.vue') },
      { path: 'hospital', name: 'AdminHospitalList', component: () => import('@/views/admin/hospital/HospitalList.vue') },
      { path: 'hospital/form', name: 'AdminHospitalForm', component: () => import('@/views/admin/hospital/HospitalForm.vue') },
      { path: 'hospital/department', name: 'AdminDepartmentList', component: () => import('@/views/admin/hospital/DepartmentList.vue') },
      { path: 'medical-record', name: 'AdminMedicalRecord', component: () => import('@/views/admin/medical/MedicalRecord.vue') },
      { path: 'health-record', name: 'AdminHealthRecord', component: () => import('@/views/admin/health/HealthRecord.vue') },
      { path: 'herbal', name: 'AdminHerbalList', component: () => import('@/views/admin/herbal/HerbalList.vue') },
      { path: 'medicine', name: 'AdminMedicineList', component: () => import('@/views/admin/medicine/MedicineList.vue') },
      { path: 'knowledge', name: 'AdminKnowledgeGraph', component: () => import('@/views/admin/knowledge/KnowledgeGraph.vue') },
      { path: 'risk', name: 'AdminRiskAssess', component: () => import('@/views/admin/risk/RiskAssess.vue') },
      { path: 'ai', name: 'AdminAIChat', component: () => import('@/views/admin/ai/AIChat.vue') },
      { path: 'consultation', name: 'AdminConsultationList', component: () => import('@/views/admin/consultation/ConsultationList.vue') },
      { path: 'appointment', name: 'AdminAppointmentList', component: () => import('@/views/admin/appointment/AppointmentList.vue') },
      { path: 'transfer', name: 'AdminTransferList', component: () => import('@/views/admin/transfer/TransferList.vue') },
      { path: 'settings', name: 'AdminSystemSettings', component: () => import('@/views/admin/system/SystemSettings.vue') },
      { path: 'log', name: 'AdminOperLogList', component: () => import('@/views/admin/system/log/OperLogList.vue') }
    ]
  },
  { path: '/:pathMatch(.*)*', redirect: '/login' }
]

const router = createRouter({ history: createWebHistory(), routes })

router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  if (to.path !== '/login' && to.path !== '/register' && !userStore.isLoggedIn) {
    next('/login')
  } else if (userStore.isLoggedIn) {
    const userType = userStore.userInfo?.userType
    if (to.path.startsWith('/admin') && userType !== 2) {
      next(getHomeByType(userType))
    } else if (to.path.startsWith('/doctor') && userType !== 1) {
      next(getHomeByType(userType))
    } else if (to.path.startsWith('/nurse') && userType !== 3) {
      next(getHomeByType(userType))
    } else if (to.path.startsWith('/family') && userType !== 4) {
      next(getHomeByType(userType))
    } else {
      next()
    }
  } else {
    next()
  }
})

function getHomeByType(userType) {
  if (userType === 2) return '/admin/home'
  if (userType === 1) return '/doctor/home'
  if (userType === 3) return '/nurse/home'
  if (userType === 4) return '/family/home'
  return '/user/home'
}

export default router
