export enum EnvType {
  DEV = 'DEV',
  DEV_EMULATOR = 'DEV_EMULATOR',
  DEV_DEVICE = 'DEV_DEVICE',
  TEST = 'TEST',
  PROD = 'PROD'
}

interface EnvConfig {
  BASE_URL: string;
  UPLOAD_URL: string;
}

const ENV_MAP: Record<EnvType, EnvConfig> = {
  [EnvType.DEV]: { BASE_URL: 'http://localhost:8080', UPLOAD_URL: 'http://localhost:8080/upload' },
  [EnvType.DEV_EMULATOR]: { BASE_URL: 'http://10.0.2.2:8080', UPLOAD_URL: 'http://10.0.2.2:8080/upload' },
  [EnvType.DEV_DEVICE]: { BASE_URL: 'http://192.168.71.233:8080', UPLOAD_URL: 'http://192.168.71.233:8080/upload' },
  [EnvType.TEST]: { BASE_URL: 'http://test.health-care.com', UPLOAD_URL: 'http://test.health-care.com/upload' },
  [EnvType.PROD]: { BASE_URL: 'https://api.health-care.com', UPLOAD_URL: 'https://api.health-care.com/upload' }
};

let currentEnv: EnvType = EnvType.DEV_EMULATOR;

export function setEnv(env: EnvType): void {
  currentEnv = env;
}

export function getBaseUrl(): string {
  return ENV_MAP[currentEnv].BASE_URL;
}

export function getUploadUrl(): string {
  return ENV_MAP[currentEnv].UPLOAD_URL;
}

export function getCurrentEnv(): EnvType {
  return currentEnv;
}

interface ApiConstantsInterface {

  BASE_URL: string;

  LOGIN_PATH: string;

  USER_REGISTER: string;
  USER_LOGIN: string;
  USER_INFO: string;
  USER_UPDATE: string;
  USER_PASSWORD: string;
  USER_AVATAR: string;
  USER_LOGOUT: string;

  HOSPITAL_NEARBY: string;
  HOSPITAL_LIST: string;
  HOSPITAL_PAGE: string;
  HOSPITAL_DETAIL: string;
  HOSPITAL_DEPARTMENT_LIST: string;
  HOSPITAL_DEPARTMENT_ALL: string;
  HOSPITAL_DEPARTMENT_DETAIL: string;

  HEALTH_RECORD_ADD: string;
  HEALTH_RECORD_MY: string;
  HEALTH_RECORD_TIME: string;
  HEALTH_RECORD_PAGE: string;
  HEALTH_RECORD_LATEST: string;
  HEALTH_STATS_PERSONAL_TREND: string;
  HEALTH_STATS_PERSONAL_SUMMARY: string;
  HEALTH_STATS_PERSONAL_CURVE: string;
  HEALTH_STATS_SYSTEM: string;

  RISK_ASSESS: string;
  RISK_LIST: string;
  RISK_LATEST: string;
  RISK_DETAIL: string;
  RISK_DELETE: string;
  RISK_INTERPRET: string;

  HERBAL_PAGE: string;
  HERBAL_LIST: string;
  HERBAL_LIST_ALL: string;
  HERBAL_LIST_BY_STATUS: string;
  HERBAL_DETAIL: string;
  HERBAL_SEARCH: string;
  HERBAL_ADD: string;
  HERBAL_UPDATE: string;
  HERBAL_DELETE: string;
  HERBAL_EFFICACY_LIST: string;
  HERBAL_EFFICACY_ADD: string;
  HERBAL_EFFICACY_UPDATE: string;
  HERBAL_EFFICACY_DELETE: string;
  HERBAL_COLLECT: string;
  HERBAL_UNCOLLECT: string;
  HERBAL_MY_COLLECTS: string;
  HERBAL_HOT: string;
  HERBAL_RANDOM: string;
  HERBAL_CATEGORY_TREE: string;
  HERBAL_BY_EFFICACY: string;

  KNOWLEDGE_GRAPH: string;
  KNOWLEDGE_NODE: string;
  KNOWLEDGE_NODE_DETAIL: string;
  KNOWLEDGE_SEARCH: string;
  KNOWLEDGE_PATH: string;
  KNOWLEDGE_NODES: string;
  KNOWLEDGE_EXPLORE: string;
  KNOWLEDGE_STATS: string;
  KNOWLEDGE_RELATED: string;

  REHAB_PLAN_LIST: string;
  REHAB_PLAN_DETAIL: string;
  REHAB_PLAN_ADD: string;
  REHAB_PLAN_UPDATE: string;
  REHAB_PLAN_DELETE: string;
  REHAB_ACTION_LIST: string;
  REHAB_ACTION_DETAIL: string;
  REHAB_START: string;
  REHAB_COMPLETE: string;
  REHAB_HISTORY: string;
  REHAB_SEARCH: string;
  REHAB_FUZZY: string;

  ARTICLE_LIST: string;
  ARTICLE_PAGE: string;
  ARTICLE_DETAIL: string;
  ARTICLE_SEARCH: string;
  ARTICLE_ADD: string;
  ARTICLE_UPDATE: string;
  ARTICLE_DELETE: string;
  ARTICLE_CATEGORIES_PARENT: string;
  ARTICLE_CATEGORIES_CHILDREN: string;
  ARTICLE_COLLECT: string;
  ARTICLE_UNCOLLECT: string;
  ARTICLE_MY_COLLECTS: string;

  COMMENT_LIST: string;
  COMMENT_ADD: string;
  COMMENT_DELETE: string;
  COMMENT_LIKE: string;

  AI_CHAT: string;
  AI_CONSULT: string;
  AI_RISK_ANALYSIS: string;
  AI_REHAB_GUIDE: string;
  AI_HISTORY: string;
  AI_HISTORY_DETAIL: string;
  AI_INTERPRET: string;

  FOOD_LIST: string;
  FOOD_PAGE: string;
  FOOD_DETAIL: string;
  FOOD_SEARCH: string;
  FOOD_COLLECT: string;
  FOOD_UNCOLLECT: string;

  ANCIENT_IMAGE_UPLOAD: string;
  ANCIENT_IMAGE_LIST: string;
  ANCIENT_IMAGE_DETAIL: string;
  ANCIENT_IMAGE_RESTORE: string;
  ANCIENT_IMAGE_DELETE: string;

  DEVICE_DISCOVER: string;
  DEVICE_BIND: string;
  DEVICE_UNBIND: string;
  DEVICE_LIST: string;

  DISCOVER_BANNER_LIST: string;
  DISCOVER_CATEGORY_LIST: string;
  DISCOVER_ARTICLE_LIST: string;
  DEVICE_ONLINE: string;
  DEVICE_SYNC: string;
  DEVICE_STATUS: string;
  DEVICE_INFO: string;

  PRIVACY_SETTINGS: string;
  PRIVACY_AUTH_LIST: string;
  PRIVACY_APPROVE: string;
  PRIVACY_REVOKE: string;
  PRIVACY_LOGS: string;
  PRIVACY_CREATE_AUTH: string;
  PRIVACY_REVOKE_AUTH: string;
  PRIVACY_ACCESS_LOGS: string;
  PRIVACY_CHECK_AUTH: string;

  MEDICAL_RECORD_CREATE: string;
  MEDICAL_RECORD_PAGE: string;
  MEDICAL_RECORD_DETAIL: string;
  MEDICAL_RECORD_DESENSITIZED: string;
  MEDICAL_RECORD_UPDATE: string;
  MEDICAL_RECORD_DELETE: string;

  MEDICINE_LIST: string;
  MEDICINE_PAGE: string;
  MEDICINE_SEARCH: string;
  MEDICINE_DETAIL: string;
  MEDICINE_CATEGORY_LIST: string;
  MEDICINE_CATEGORY_DETAIL: string;

  DISEASE_DICT_SEARCH: string;
  DISEASE_DICT_CATEGORY: string;
  DISEASE_DICT_DETAIL: string;

  TRANSFER_APPLY: string;
  TRANSFER_MY: string;
  TRANSFER_PENDING: string;
  TRANSFER_APPROVE: string;
  TRANSFER_REJECT: string;
  TRANSFER_HISTORY: string;
  TRANSFER_SYNC: string;

  LOG_OPER_LIST: string;
  LOG_OPER_USER: string;
  LOG_OPER_TIME: string;
  LOG_OPER_STATISTICS: string;

  HEALTH_STANDARD_CHECK: string;
  HEALTH_STANDARD_LIST: string;
  HEALTH_STANDARD_DETAIL: string;
  HEALTH_STANDARD_AGE_GROUP: string;
  HEALTH_STANDARD_GENDER: string;

  DOCTOR_LIST: string;
  DOCTOR_DETAIL: string;
  DOCTOR_REGISTER: string;
  DOCTOR_INFO: string;
  DOCTOR_UPDATE: string;

  MESSAGE_SEND: string;
  MESSAGE_HISTORY: string;
  MESSAGE_CONVERSATIONS: string;
  MESSAGE_DELETE: string;
  MESSAGE_CAN_SEND: string;
  DOCTOR_PATIENTS: string;
  MESSAGE_CLEANUP: string;

  UPLOAD_3D: string;

  APPOINTMENT_CREATE: string;
  APPOINTMENT_LIST: string;
  APPOINTMENT_DETAIL: string;
  APPOINTMENT_CANCEL: string;
  APPOINTMENT_USER_LIST: string;
  APPOINTMENT_CHECK_AVAILABILITY: string;
  APPOINTMENT_STATISTICS: string;

  PAY_CREATE: string;
  PAY_STATUS: string;
  PAY_NOTIFY: string;

  SCHEDULE_ADD: string;
  SCHEDULE_LIST: string;
  SCHEDULE_DOCTOR_DATE: string;

  ADMIN_LOGIN: string;
  ADMIN_INFO: string;
  ADMIN_LOGOUT: string;
}

export const ApiConstants: ApiConstantsInterface = {

  BASE_URL: getBaseUrl(),

  LOGIN_PATH: '/user/login',

  USER_REGISTER: '/user/register',
  USER_LOGIN: '/user/login',
  USER_INFO: '/user/info',
  USER_UPDATE: '/user/update',
  USER_PASSWORD: '/user/password',
  USER_AVATAR: '/user/avatar',
  USER_LOGOUT: '/user/logout',

  HOSPITAL_NEARBY: '/hospital/nearby',
  HOSPITAL_LIST: '/hospital/list',
  HOSPITAL_PAGE: '/hospital/page',
  HOSPITAL_DETAIL: '/hospital/info/',
  HOSPITAL_DEPARTMENT_LIST: '/hospital/department/list',
  HOSPITAL_DEPARTMENT_ALL: '/hospital/department/all',
  HOSPITAL_DEPARTMENT_DETAIL: '/hospital/department/info/',

  HEALTH_RECORD_ADD: '/healthRecord/add',
  HEALTH_RECORD_MY: '/healthRecord/my',
  HEALTH_RECORD_TIME: '/healthRecord/time',
  HEALTH_RECORD_PAGE: '/healthRecord/page',
  HEALTH_RECORD_LATEST: '/healthRecord/my',
  HEALTH_STATS_PERSONAL_TREND: '/statistics/personal/trend',
  HEALTH_STATS_PERSONAL_SUMMARY: '/statistics/personal/summary',
  HEALTH_STATS_PERSONAL_CURVE: '/statistics/personal/curve',
  HEALTH_STATS_SYSTEM: '/statistics/system',

  RISK_ASSESS: '/risk/assess/',
  RISK_LIST: '/risk/list/',
  RISK_LATEST: '/risk/latest/',
  RISK_DETAIL: '/risk/get/',
  RISK_DELETE: '/risk/delete/',
  RISK_INTERPRET: '/ai/risk-analysis',

  HERBAL_PAGE: '/herbal/page',
  HERBAL_LIST: '/herbal/list/by-status',
  HERBAL_LIST_ALL: '/herbal/list/all',
  HERBAL_LIST_BY_STATUS: '/herbal/list/by-status',
  HERBAL_DETAIL: '/herbal/info/',
  HERBAL_SEARCH: '/herbal/list/all',
  HERBAL_ADD: '/herbal/add',
  HERBAL_UPDATE: '/herbal/update',
  HERBAL_DELETE: '/herbal/delete/',
  HERBAL_EFFICACY_LIST: '/herbal/efficacy/list/',
  HERBAL_EFFICACY_ADD: '/herbal/efficacy/add',
  HERBAL_EFFICACY_UPDATE: '/herbal/efficacy/update',
  HERBAL_EFFICACY_DELETE: '/herbal/efficacy/delete/',
  HERBAL_COLLECT: '/api/herbal/collect',
  HERBAL_UNCOLLECT: '/api/herbal/uncollect',
  HERBAL_MY_COLLECTS: '/api/herbal/my-collects',
  HERBAL_HOT: '/herbal/hot',
  HERBAL_RANDOM: '/herbal/random',
  HERBAL_CATEGORY_TREE: '/herbal/category/tree',
  HERBAL_BY_EFFICACY: '/herbal/by-efficacy/',

  KNOWLEDGE_GRAPH: '/api/knowledge/graph',
  KNOWLEDGE_NODE: '/api/knowledge/node/',
  KNOWLEDGE_NODE_DETAIL: '/api/knowledge/node/',
  KNOWLEDGE_SEARCH: '/api/knowledge/search',
  KNOWLEDGE_PATH: '/api/knowledge/path',
  KNOWLEDGE_NODES: '/api/knowledge/nodes',
  KNOWLEDGE_EXPLORE: '/api/knowledge/explore',
  KNOWLEDGE_STATS: '/api/knowledge/stats',
  KNOWLEDGE_RELATED: '/api/knowledge/related',

  REHAB_PLAN_LIST: '/rehab/list',
  REHAB_PLAN_DETAIL: '/rehab/get/',
  REHAB_PLAN_ADD: '/rehab/add',
  REHAB_PLAN_UPDATE: '/rehab/update',
  REHAB_PLAN_DELETE: '/rehab/delete/',
  REHAB_ACTION_LIST: '/rehab/action/list',
  REHAB_ACTION_DETAIL: '/rehab/action/detail/',
  REHAB_START: '/rehab/start/',
  REHAB_COMPLETE: '/rehab/complete/',
  REHAB_HISTORY: '/rehab/history',
  REHAB_SEARCH: '/rehab/search',
  REHAB_FUZZY: '/rehab/fuzzy',

  ARTICLE_LIST: '/healthArticle/list',
  ARTICLE_PAGE: '/healthArticle/page',
  ARTICLE_DETAIL: '/healthArticle/detail/',
  ARTICLE_SEARCH: '/healthArticle/list',
  ARTICLE_ADD: '/healthArticle/add',
  ARTICLE_UPDATE: '/healthArticle/update',
  ARTICLE_DELETE: '/healthArticle/delete/',
  ARTICLE_CATEGORIES_PARENT: '/healthArticle/categories/parent',
  ARTICLE_CATEGORIES_CHILDREN: '/healthArticle/categories/children/',
  ARTICLE_COLLECT: '/api/article/',
  ARTICLE_UNCOLLECT: '/api/article/',
  ARTICLE_MY_COLLECTS: '/api/article/my-collects',

  COMMENT_LIST: '/comment/list/',
  COMMENT_ADD: '/comment/add',
  COMMENT_DELETE: '/comment/delete/',
  COMMENT_LIKE: '/comment/like/',

  AI_CHAT: '/ai/chat',
  AI_CONSULT: '/ai/health-consult',
  AI_RISK_ANALYSIS: '/ai/risk-analysis',
  AI_REHAB_GUIDE: '/ai/rehab-guide',
  AI_HISTORY: '/ai/history',
  AI_HISTORY_DETAIL: '/ai/history/detail',
  AI_INTERPRET: '/ai/interpret',

  FOOD_LIST: '/healthFood/list',
  FOOD_PAGE: '/healthFood/page',
  FOOD_DETAIL: '/healthFood/detail/',
  FOOD_SEARCH: '/healthFood/list',
  FOOD_COLLECT: '/api/food/collect',
  FOOD_UNCOLLECT: '/api/food/uncollect',

  ANCIENT_IMAGE_UPLOAD: '/ancient-image/upload',
  ANCIENT_IMAGE_LIST: '/ancient-image/list',
  ANCIENT_IMAGE_DETAIL: '/ancient-image/',
  ANCIENT_IMAGE_RESTORE: '/ancient-image/',
  ANCIENT_IMAGE_DELETE: '/ancient-image/',

  DEVICE_DISCOVER: '/device/discover',
  DEVICE_BIND: '/device/bind',
  DEVICE_UNBIND: '/device/unbind',
  DEVICE_LIST: '/device/list',

  DISCOVER_BANNER_LIST: '/discover/banners',
  DISCOVER_CATEGORY_LIST: '/discover/categories',
  DISCOVER_ARTICLE_LIST: '/healthArticle/page',
  DEVICE_ONLINE: '/device/online',
  DEVICE_SYNC: '/device/sync',
  DEVICE_STATUS: '/device/status',
  DEVICE_INFO: '/device/info',

  PRIVACY_SETTINGS: '/privacy/settings',
  PRIVACY_AUTH_LIST: '/privacy/myAuths',
  PRIVACY_APPROVE: '/privacy/approve',
  PRIVACY_REVOKE: '/privacy/revoke',
  PRIVACY_LOGS: '/privacy/accessLogs',
  PRIVACY_CREATE_AUTH: '/privacy/createAuth',
  PRIVACY_REVOKE_AUTH: '/privacy/revokeAuth',
  PRIVACY_ACCESS_LOGS: '/privacy/accessLogs',
  PRIVACY_CHECK_AUTH: '/privacy/checkAuth',

  MEDICAL_RECORD_CREATE: '/medical/record/create',
  MEDICAL_RECORD_PAGE: '/medical/record/page',
  MEDICAL_RECORD_DETAIL: '/medical/record/detail',
  MEDICAL_RECORD_DESENSITIZED: '/medical/record/desensitized',
  MEDICAL_RECORD_UPDATE: '/medical/record/update',
  MEDICAL_RECORD_DELETE: '/medical/record/delete',

  MEDICINE_LIST: '/medicine/list',
  MEDICINE_PAGE: '/medicine/page',
  MEDICINE_SEARCH: '/medicine/search',
  MEDICINE_DETAIL: '/medicine/detail/',
  MEDICINE_CATEGORY_LIST: '/medicine/category/list',
  MEDICINE_CATEGORY_DETAIL: '/medicine/category/',

  DISEASE_DICT_SEARCH: '/diseaseDict/search',
  DISEASE_DICT_CATEGORY: '/diseaseDict/category',
  DISEASE_DICT_DETAIL: '/diseaseDict/detail/',

  TRANSFER_APPLY: '/transfer/apply',
  TRANSFER_MY: '/transfer/my',
  TRANSFER_PENDING: '/transfer/pending',
  TRANSFER_APPROVE: '/transfer/approve/',
  TRANSFER_REJECT: '/transfer/reject/',
  TRANSFER_HISTORY: '/transfer/history',
  TRANSFER_SYNC: '/transfer/sync/',

  LOG_OPER_LIST: '/log/oper/list',
  LOG_OPER_USER: '/log/oper/user',
  LOG_OPER_TIME: '/log/oper/time',
  LOG_OPER_STATISTICS: '/log/oper/statistics',

  HEALTH_STANDARD_CHECK: '/healthStandard/check',
  HEALTH_STANDARD_LIST: '/healthStandard/list',
  HEALTH_STANDARD_DETAIL: '/healthStandard/detail/',
  HEALTH_STANDARD_AGE_GROUP: '/healthStandard/ageGroup',
  HEALTH_STANDARD_GENDER: '/healthStandard/gender',

  DOCTOR_LIST: '/user/doctor/list',
  DOCTOR_DETAIL: '/user/doctor/detail/',
  DOCTOR_REGISTER: '/doctor/register',
  DOCTOR_INFO: '/doctor/info/',
  DOCTOR_UPDATE: '/doctor/update',

  MESSAGE_SEND: '/user/message/send',
  MESSAGE_HISTORY: '/user/message/history',
  MESSAGE_CONVERSATIONS: '/user/message/conversations',
  MESSAGE_DELETE: '/user/message/delete',
  MESSAGE_CAN_SEND: '/user/message/can-send',
  DOCTOR_PATIENTS: '/user/doctor/patients',
  MESSAGE_CLEANUP: '/user/message/cleanup',

  UPLOAD_3D: '/api/upload/3d',

  APPOINTMENT_CREATE: '/appointment/create',
  APPOINTMENT_LIST: '/appointment/list',
  APPOINTMENT_DETAIL: '/appointment/',
  APPOINTMENT_CANCEL: '/appointment/',
  APPOINTMENT_USER_LIST: '/appointment/user/',
  APPOINTMENT_CHECK_AVAILABILITY: '/appointment/check-availability',
  APPOINTMENT_STATISTICS: '/appointment/statistics/',

  PAY_CREATE: '/pay/create',
  PAY_STATUS: '/pay/status',
  PAY_NOTIFY: '/pay/notify',

  SCHEDULE_ADD: '/schedule/add',
  SCHEDULE_LIST: '/schedule/list',
  SCHEDULE_DOCTOR_DATE: '/schedule/doctor/',

  ADMIN_LOGIN: '/admin/login',
  ADMIN_INFO: '/admin/info',
  ADMIN_LOGOUT: '/admin/logout'
};
