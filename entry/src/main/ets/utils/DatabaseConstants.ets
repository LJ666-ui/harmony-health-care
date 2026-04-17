// 表名常量
export const TABLE_USER_CACHE = 'local_user_cache';
export const TABLE_OFFLINE_HEALTH_RECORD = 'offline_health_record';
export const TABLE_ARTICLE_CACHE = 'local_article_cache';
export const TABLE_DEVICE_CACHE = 'local_device_cache';
export const TABLE_SYNC_QUEUE = 'sync_queue';
export const TABLE_BROWSE_HISTORY = 'local_browse_history';
export const TABLE_SEARCH_HISTORY = 'local_search_history';
export const TABLE_COLLECTION_CACHE = 'local_collection_cache';

// 字段名常量
// local_user_cache
export const COLUMN_ID = 'id';
export const COLUMN_USER_ID = 'user_id';
export const COLUMN_TOKEN = 'token';
export const COLUMN_NICKNAME = 'nickname';
export const COLUMN_AVATAR_URL = 'avatar_url';
export const COLUMN_ROLE_TYPE = 'role_type';
export const COLUMN_LAST_SYNC_TIME = 'last_sync_time';
export const COLUMN_EXPIRE_TIME = 'expire_time';

// offline_health_record
export const COLUMN_RECORD_TYPE = 'record_type';
export const COLUMN_VALUE = 'value';
export const COLUMN_UNIT = 'unit';
export const COLUMN_RECORD_TIME = 'record_time';
export const COLUMN_NOTES = 'notes';
export const COLUMN_SYNCED = 'synced';
export const COLUMN_CREATE_TIME = 'create_time';
export const COLUMN_RETRY_COUNT = 'retry_count';

// local_article_cache
export const COLUMN_ARTICLE_ID = 'article_id';
export const COLUMN_TITLE = 'title';
export const COLUMN_CONTENT_SUMMARY = 'content_summary';
export const COLUMN_COVER_IMAGE = 'cover_image';
export const COLUMN_CATEGORY_ID = 'category_id';
export const COLUMN_IS_COLLECTED = 'is_collected';
export const COLUMN_CACHED_TIME = 'cached_time';
export const COLUMN_LAST_READ_TIME = 'last_read_time';

// local_device_cache
export const COLUMN_DEVICE_ID = 'device_id';
export const COLUMN_DEVICE_NAME = 'device_name';
export const COLUMN_DEVICE_TYPE = 'device_type';
export const COLUMN_DEVICE_MODEL = 'device_model';
export const COLUMN_PAIRED = 'paired';
export const COLUMN_LAST_CONNECT_TIME = 'last_connect_time';

// sync_queue
export const COLUMN_TABLE_NAME = 'table_name';
export const COLUMN_OPERATION_TYPE = 'operation_type';
export const COLUMN_DATA_JSON = 'data_json';
export const COLUMN_TARGET_URL = 'target_url';
export const COLUMN_STATUS = 'status';
export const COLUMN_ERROR_MESSAGE = 'error_message';
export const COLUMN_SYNC_TIME = 'sync_time';

// local_browse_history
export const COLUMN_BROWSE_TYPE = 'browse_type';
export const COLUMN_TARGET_ID = 'target_id';
export const COLUMN_TARGET_TITLE = 'target_title';
export const COLUMN_BROWSE_DURATION = 'browse_duration';
export const COLUMN_SOURCE_PAGE = 'source_page';

// local_search_history
export const COLUMN_KEYWORD = 'keyword';
export const COLUMN_SEARCH_COUNT = 'search_count';
export const COLUMN_LAST_SEARCH_TIME = 'last_search_time';
export const COLUMN_SEARCH_SCOPE = 'search_scope';

// local_collection_cache
export const COLUMN_COLLECT_TYPE = 'collect_type';
export const COLUMN_TARGET_IMAGE = 'target_image';
export const COLUMN_COLLECT_TIME = 'collect_time';
export const COLUMN_NOTE = 'note';
export const COLUMN_IS_SYNCED = 'is_synced';

// SQL语句常量
// 创建表语句
export const CREATE_TABLE_USER_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_USER_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_USER_ID} INTEGER NOT NULL,
    ${COLUMN_TOKEN} TEXT NOT NULL,
    ${COLUMN_NICKNAME} TEXT,
    ${COLUMN_AVATAR_URL} TEXT,
    ${COLUMN_ROLE_TYPE} TEXT,
    ${COLUMN_LAST_SYNC_TIME} INTEGER,
    ${COLUMN_EXPIRE_TIME} INTEGER
  )
`;

export const CREATE_TABLE_OFFLINE_HEALTH_RECORD = `
  CREATE TABLE IF NOT EXISTS ${TABLE_OFFLINE_HEALTH_RECORD} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_RECORD_TYPE} TEXT NOT NULL,
    ${COLUMN_VALUE} REAL NOT NULL,
    ${COLUMN_UNIT} TEXT,
    ${COLUMN_RECORD_TIME} INTEGER NOT NULL,
    ${COLUMN_NOTES} TEXT,
    ${COLUMN_SYNCED} INTEGER DEFAULT 0,
    ${COLUMN_CREATE_TIME} INTEGER,
    ${COLUMN_RETRY_COUNT} INTEGER DEFAULT 0
  )
`;

export const CREATE_TABLE_ARTICLE_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_ARTICLE_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_ARTICLE_ID} INTEGER UNIQUE NOT NULL,
    ${COLUMN_TITLE} TEXT,
    ${COLUMN_CONTENT_SUMMARY} TEXT,
    ${COLUMN_COVER_IMAGE} TEXT,
    ${COLUMN_CATEGORY_ID} INTEGER,
    ${COLUMN_IS_COLLECTED} INTEGER DEFAULT 0,
    ${COLUMN_CACHED_TIME} INTEGER,
    ${COLUMN_LAST_READ_TIME} INTEGER
  )
`;

export const CREATE_TABLE_DEVICE_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_DEVICE_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_DEVICE_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_DEVICE_NAME} TEXT,
    ${COLUMN_DEVICE_TYPE} TEXT,
    ${COLUMN_DEVICE_MODEL} TEXT,
    ${COLUMN_PAIRED} INTEGER DEFAULT 0,
    ${COLUMN_LAST_CONNECT_TIME} INTEGER
  )
`;

export const CREATE_TABLE_SYNC_QUEUE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_SYNC_QUEUE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_TABLE_NAME} TEXT NOT NULL,
    ${COLUMN_OPERATION_TYPE} TEXT NOT NULL,
    ${COLUMN_DATA_JSON} TEXT NOT NULL,
    ${COLUMN_TARGET_URL} TEXT,
    ${COLUMN_RETRY_COUNT} INTEGER DEFAULT 0,
    ${COLUMN_STATUS} TEXT DEFAULT 'pending',
    ${COLUMN_ERROR_MESSAGE} TEXT,
    ${COLUMN_CREATE_TIME} INTEGER,
    ${COLUMN_SYNC_TIME} INTEGER
  )
`;

export const CREATE_TABLE_BROWSE_HISTORY = `
  CREATE TABLE IF NOT EXISTS ${TABLE_BROWSE_HISTORY} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_BROWSE_TYPE} TEXT NOT NULL,
    ${COLUMN_TARGET_ID} INTEGER NOT NULL,
    ${COLUMN_TARGET_TITLE} TEXT,
    ${COLUMN_BROWSE_DURATION} INTEGER DEFAULT 0,
    ${COLUMN_SOURCE_PAGE} TEXT,
    ${COLUMN_CREATE_TIME} INTEGER
  )
`;

export const CREATE_TABLE_SEARCH_HISTORY = `
  CREATE TABLE IF NOT EXISTS ${TABLE_SEARCH_HISTORY} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_KEYWORD} TEXT NOT NULL,
    ${COLUMN_SEARCH_COUNT} INTEGER DEFAULT 1,
    ${COLUMN_LAST_SEARCH_TIME} INTEGER,
    ${COLUMN_SEARCH_SCOPE} TEXT DEFAULT 'GLOBAL'
  )
`;

export const CREATE_TABLE_COLLECTION_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_COLLECTION_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_COLLECT_TYPE} TEXT NOT NULL,
    ${COLUMN_TARGET_ID} INTEGER NOT NULL,
    ${COLUMN_TARGET_TITLE} TEXT,
    ${COLUMN_TARGET_IMAGE} TEXT,
    ${COLUMN_COLLECT_TIME} INTEGER,
    ${COLUMN_NOTE} TEXT,
    ${COLUMN_IS_SYNCED} INTEGER DEFAULT 0
  )
`;

// 插入语句
export const INSERT_BROWSE_HISTORY = `
  INSERT INTO ${TABLE_BROWSE_HISTORY} (
    ${COLUMN_BROWSE_TYPE}, ${COLUMN_TARGET_ID}, ${COLUMN_TARGET_TITLE}, 
    ${COLUMN_SOURCE_PAGE}, ${COLUMN_CREATE_TIME}
  ) VALUES (?, ?, ?, ?, ?)
`;

export const UPDATE_BROWSE_DURATION = `
  UPDATE ${TABLE_BROWSE_HISTORY} SET ${COLUMN_BROWSE_DURATION} = ? WHERE ${COLUMN_ID} = ?
`;

export const DELETE_SHORT_BROWSE_HISTORY = `
  DELETE FROM ${TABLE_BROWSE_HISTORY} WHERE ${COLUMN_BROWSE_DURATION} < 2000
`;

export const DELETE_OLD_BROWSE_HISTORY = `
  DELETE FROM ${TABLE_BROWSE_HISTORY} WHERE ${COLUMN_CREATE_TIME} < ?
`;