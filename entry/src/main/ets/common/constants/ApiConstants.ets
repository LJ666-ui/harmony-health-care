interface ApiConstantsInterface {
  LOGIN_PATH: string;
  REHAB_ACTION_LIST: string;
  REHAB_ACTION_DETAIL: string;
  REHAB_PLAN_LIST: string;
  REHAB_PLAN_DETAIL: string;
  UPLOAD_3D: string;
}

export const ApiConstants: ApiConstantsInterface = {
  LOGIN_PATH: '/api/auth/login',
  REHAB_ACTION_LIST: '/api/rehab/action/list',
  REHAB_ACTION_DETAIL: '/api/rehab/action/detail/',
  REHAB_PLAN_LIST: '/api/rehab/plan/list',
  REHAB_PLAN_DETAIL: '/api/rehab/plan/detail/',
  UPLOAD_3D: '/api/upload/3d'
};
