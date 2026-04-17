-- 初始化数据库表结构

-- 创建用户缓存表
CREATE TABLE IF NOT EXISTS local_user_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  token TEXT NOT NULL,
  nickname TEXT,
  avatar_url TEXT,
  role_type TEXT,
  last_sync_time INTEGER,
  expire_time INTEGER
);

-- 创建离线健康记录表
CREATE TABLE IF NOT EXISTS offline_health_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  record_type TEXT NOT NULL,
  value REAL NOT NULL,
  unit TEXT,
  record_time INTEGER NOT NULL,
  notes TEXT,
  synced INTEGER DEFAULT 0,
  create_time INTEGER,
  retry_count INTEGER DEFAULT 0
);

-- 创建文章缓存表
CREATE TABLE IF NOT EXISTS local_article_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  article_id INTEGER UNIQUE NOT NULL,
  title TEXT,
  content_summary TEXT,
  cover_image TEXT,
  category_id INTEGER,
  is_collected INTEGER DEFAULT 0,
  cached_time INTEGER,
  last_read_time INTEGER
);

-- 创建设备缓存表
CREATE TABLE IF NOT EXISTS local_device_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  device_id TEXT UNIQUE NOT NULL,
  device_name TEXT,
  device_type TEXT,
  device_model TEXT,
  paired INTEGER DEFAULT 0,
  last_connect_time INTEGER
);

-- 创建同步队列表
CREATE TABLE IF NOT EXISTS sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_name TEXT NOT NULL,
  operation_type TEXT NOT NULL,
  data_json TEXT NOT NULL,
  target_url TEXT,
  retry_count INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending',
  error_message TEXT,
  create_time INTEGER,
  sync_time INTEGER
);

-- 创建浏览历史表
CREATE TABLE IF NOT EXISTS local_browse_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  browse_type TEXT NOT NULL,
  target_id INTEGER NOT NULL,
  target_title TEXT,
  browse_duration INTEGER DEFAULT 0,
  source_page TEXT,
  create_time INTEGER
);

-- 创建搜索历史表
CREATE TABLE IF NOT EXISTS local_search_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  keyword TEXT NOT NULL,
  search_count INTEGER DEFAULT 1,
  last_search_time INTEGER,
  search_scope TEXT DEFAULT 'GLOBAL'
);

-- 创建收藏缓存表
CREATE TABLE IF NOT EXISTS local_collection_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  collect_type TEXT NOT NULL,
  target_id INTEGER NOT NULL,
  target_title TEXT,
  target_image TEXT,
  collect_time INTEGER,
  note TEXT,
  is_synced INTEGER DEFAULT 0
);
