interface ApiConstantsInterface {
  LOGIN_PATH: string;
  REHAB_ACTION_LIST: string;
  REHAB_ACTION_DETAIL: string;
  REHAB_PLAN_LIST: string;
  REHAB_PLAN_DETAIL: string;
  UPLOAD_3D: string;
  KNOWLEDGE_GRAPH: string;
  KNOWLEDGE_EXPLORE: string;
  KNOWLEDGE_SEARCH: string;
  KNOWLEDGE_NODE_DETAIL: string;
  HEALTH_RECORD_ADD: string;
  HEALTH_RECORD_MY: string;
  HEALTH_RECORD_LATEST: string;
}

export const ApiConstants: ApiConstantsInterface = {
  LOGIN_PATH: '/api/auth/login',
  REHAB_ACTION_LIST: '/api/rehab/action/list',
  REHAB_ACTION_DETAIL: '/api/rehab/action/detail/',
  REHAB_PLAN_LIST: '/api/rehab/plan/list',
  REHAB_PLAN_DETAIL: '/api/rehab/plan/detail/',
  UPLOAD_3D: '/api/upload/3d',
  KNOWLEDGE_GRAPH: '/api/knowledge/graph',
  KNOWLEDGE_EXPLORE: '/api/knowledge/explore',
  KNOWLEDGE_SEARCH: '/api/knowledge/search',
  KNOWLEDGE_NODE_DETAIL: '/api/knowledge/node/',
  HEALTH_RECORD_ADD: '/healthRecord/add',
  HEALTH_RECORD_MY: '/healthRecord/my',
  HEALTH_RECORD_LATEST: '/healthRecord/my'
};
