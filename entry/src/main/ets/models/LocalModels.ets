// 用户缓存接口
export interface LocalUserCache {
  id?: number;
  user_id: number;
  token: string;
  nickname?: string;
  avatar_url?: string;
  role_type?: string;
  last_sync_time?: number;
  expire_time?: number;
}

// 离线健康记录接口
export interface OfflineHealthRecord {
  id?: number;
  record_type: string;
  value: number;
  unit?: string;
  record_time: number;
  notes?: string;
  synced?: number;
  create_time?: number;
  retry_count?: number;
}

// 文章缓存接口
export interface LocalArticleCache {
  id?: number;
  article_id: number;
  title?: string;
  content_summary?: string;
  cover_image?: string;
  category_id?: number;
  is_collected?: number;
  cached_time?: number;
  last_read_time?: number;
}

// 设备缓存接口
export interface LocalDeviceCache {
  id?: number;
  device_id: string;
  device_name?: string;
  device_type?: string;
  device_model?: string;
  paired?: number;
  last_connect_time?: number;
}

// 同步队列接口
export interface SyncQueueItem {
  id?: number;
  table_name: string;
  operation_type: string;
  data_json: string;
  target_url?: string;
  retry_count?: number;
  status?: string;
  error_message?: string;
  create_time?: number;
  sync_time?: number;
}

// 浏览历史接口
export interface BrowseHistoryItem {
  id?: number;
  browse_type: string;
  target_id: number;
  target_title?: string;
  browse_duration?: number;
  source_page?: string;
  create_time?: number;
}

// 搜索历史接口
export interface SearchHistoryItem {
  id?: number;
  keyword: string;
  search_count?: number;
  last_search_time?: number;
  search_scope?: string;
}

// 收藏缓存接口
export interface CollectionCacheItem {
  id?: number;
  collect_type: string;
  target_id: number;
  target_title?: string;
  target_image?: string;
  collect_time?: number;
  note?: string;
  is_synced?: number;
}