// 表名常量
export const TABLE_USER_CACHE = 'local_user_cache';
export const TABLE_OFFLINE_HEALTH_RECORD = 'offline_health_record';
export const TABLE_ARTICLE_CACHE = 'local_article_cache';
export const TABLE_DEVICE_CACHE = 'local_device_cache';
export const TABLE_SYNC_QUEUE = 'sync_queue';
export const TABLE_BROWSE_HISTORY = 'local_browse_history';
export const TABLE_SEARCH_HISTORY = 'local_search_history';
export const TABLE_COLLECTION_CACHE = 'local_collection_cache';
export const TABLE_COMMENT_CACHE = 'local_comment_cache';
export const TABLE_ARTICLE_DRAFT = 'local_article_draft';
export const TABLE_HOSPITAL_CACHE = 'local_hospital_cache';
export const TABLE_DOCTOR_CACHE = 'local_doctor_cache';
export const TABLE_APPOINTMENT_CACHE = 'local_appointment_cache';
export const TABLE_MEDICINE_CACHE = 'local_medicine_cache';
export const TABLE_HEALTH_GOAL_CACHE = 'local_health_goal_cache';

// 字段名常量
export const COLUMN_ID = 'id';
export const COLUMN_USER_ID = 'user_id';
export const COLUMN_USERNAME = 'username';
export const COLUMN_AVATAR = 'avatar';
export const COLUMN_AVATAR_URL = 'avatar_url';
export const COLUMN_PHONE = 'phone';
export const COLUMN_TOKEN = 'token';
export const COLUMN_NICKNAME = 'nickname';
export const COLUMN_ROLE_TYPE = 'role_type';
export const COLUMN_LAST_SYNC_TIME = 'last_sync_time';
export const COLUMN_EXPIRE_TIME = 'expire_time';
export const COLUMN_UPDATE_TIME = 'update_time';

// offline_health_record
export const COLUMN_RECORD_TYPE = 'record_type';
export const COLUMN_RECORD_TIME = 'record_time';
export const COLUMN_VALUE = 'value';
export const COLUMN_UNIT = 'unit';
export const COLUMN_NOTES = 'notes';
export const COLUMN_SYNCED = 'synced';
export const COLUMN_CREATE_TIME = 'create_time';

// local_article_cache
export const COLUMN_ARTICLE_ID = 'article_id';
export const COLUMN_TITLE = 'title';
export const COLUMN_CONTENT = 'content';
export const COLUMN_CONTENT_SUMMARY = 'content_summary';
export const COLUMN_COVER_IMAGE = 'cover_image';
export const COLUMN_CATEGORY = 'category';
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
export const COLUMN_STATUS = 'status';
export const COLUMN_MAC_ADDRESS = 'mac_address';

// sync_queue
export const COLUMN_TABLE_NAME = 'table_name';
export const COLUMN_RECORD_ID = 'record_id';
export const COLUMN_OPERATION = 'operation';
export const COLUMN_RETRY_COUNT = 'retry_count';
export const COLUMN_NEXT_RETRY_TIME = 'next_retry_time';

// local_browse_history
export const COLUMN_TARGET_ID = 'target_id';
export const COLUMN_TARGET_TYPE = 'target_type';
export const COLUMN_TARGET_TITLE = 'target_title';
export const COLUMN_TARGET_IMAGE = 'target_image';
export const COLUMN_BROWSE_TYPE = 'browse_type';
export const COLUMN_BROWSE_TIME = 'browse_time';
export const COLUMN_BROWSE_DURATION = 'browse_duration';
export const COLUMN_SOURCE_PAGE = 'source_page';

// local_search_history
export const COLUMN_KEYWORD = 'keyword';
export const COLUMN_SEARCH_TIME = 'search_time';
export const COLUMN_SEARCH_COUNT = 'search_count';
export const COLUMN_LAST_SEARCH_TIME = 'last_search_time';
export const COLUMN_SEARCH_SCOPE = 'search_scope';

// local_collection_cache
export const COLUMN_COLLECT_TYPE = 'collect_type';
export const COLUMN_COLLECT_TIME = 'collect_time';
export const COLUMN_NOTE = 'note';
export const COLUMN_IS_SYNCED = 'is_synced';

// local_comment_cache
export const COLUMN_COMMENT_ID = 'comment_id';

// local_article_draft (与harmony_medical.db匹配)
export const COLUMN_DRAFT_ID = 'draft_id';
export const COLUMN_DRAFT_TITLE = 'title';
export const COLUMN_DRAFT_CONTENT = 'content';
export const COLUMN_DRAFT_CATEGORY_ID = 'category';
export const COLUMN_DRAFT_COVER_IMAGE = 'cover_image';
export const COLUMN_DRAFT_LAST_EDIT_TIME = 'update_time';
export const COLUMN_DRAFT_CREATE_TIME = 'create_time';

// local_hospital_cache
export const COLUMN_HOSPITAL_ID = 'hospital_id';
export const COLUMN_NAME = 'name';
export const COLUMN_LEVEL = 'level';
export const COLUMN_ADDRESS = 'address';

// local_doctor_cache
export const COLUMN_DOCTOR_ID = 'doctor_id';
export const COLUMN_HOSPITAL_ID_FK = 'hospital_id';
export const COLUMN_DEPARTMENT = 'department';

// local_appointment_cache
export const COLUMN_APPOINTMENT_ID = 'appointment_id';
export const COLUMN_DOCTOR_ID_FK = 'doctor_id';
export const COLUMN_APPOINTMENT_TIME = 'appointment_time';

// local_medicine_cache
export const COLUMN_MEDICINE_ID = 'medicine_id';
export const COLUMN_SPEC = 'spec';
export const COLUMN_MANUFACTURER = 'manufacturer';
export const COLUMN_USAGE = 'usage';

// local_health_goal_cache
export const COLUMN_GOAL_ID = 'goal_id';
export const COLUMN_TYPE = 'type';
export const COLUMN_TARGET_VALUE = 'target_value';
export const COLUMN_CURRENT_VALUE = 'current_value';
export const COLUMN_START_TIME = 'start_time';
export const COLUMN_END_TIME = 'end_time';

// 建表语句
export const CREATE_TABLE_USER_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_USER_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_USER_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_USERNAME} TEXT,
    ${COLUMN_AVATAR} TEXT,
    ${COLUMN_PHONE} TEXT,
    ${COLUMN_EXPIRE_TIME} INTEGER,
    ${COLUMN_UPDATE_TIME} INTEGER
  )
`;

export const CREATE_TABLE_OFFLINE_HEALTH_RECORD = `
  CREATE TABLE IF NOT EXISTS ${TABLE_OFFLINE_HEALTH_RECORD} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_RECORD_TYPE} TEXT NOT NULL,
    ${COLUMN_RECORD_TIME} INTEGER NOT NULL,
    ${COLUMN_VALUE} TEXT NOT NULL,
    ${COLUMN_SYNCED} INTEGER DEFAULT 0,
    ${COLUMN_CREATE_TIME} INTEGER,
    ${COLUMN_UPDATE_TIME} INTEGER
  )
`;

export const CREATE_TABLE_ARTICLE_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_ARTICLE_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_ARTICLE_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_TITLE} TEXT,
    ${COLUMN_CONTENT} TEXT,
    ${COLUMN_COVER_IMAGE} TEXT,
    ${COLUMN_CATEGORY} TEXT,
    ${COLUMN_CACHED_TIME} INTEGER,
    ${COLUMN_EXPIRE_TIME} INTEGER
  )
`;

export const CREATE_TABLE_DEVICE_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_DEVICE_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_DEVICE_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_DEVICE_NAME} TEXT,
    ${COLUMN_DEVICE_TYPE} TEXT,
    ${COLUMN_LAST_CONNECT_TIME} INTEGER,
    ${COLUMN_STATUS} TEXT,
    ${COLUMN_MAC_ADDRESS} TEXT
  )
`;

export const CREATE_TABLE_SYNC_QUEUE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_SYNC_QUEUE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_TABLE_NAME} TEXT NOT NULL,
    ${COLUMN_RECORD_ID} INTEGER NOT NULL,
    ${COLUMN_OPERATION} TEXT NOT NULL,
    ${COLUMN_RETRY_COUNT} INTEGER DEFAULT 0,
    ${COLUMN_NEXT_RETRY_TIME} INTEGER,
    ${COLUMN_CREATE_TIME} INTEGER
  )
`;

export const CREATE_TABLE_BROWSE_HISTORY = `
  CREATE TABLE IF NOT EXISTS ${TABLE_BROWSE_HISTORY} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_TARGET_ID} TEXT NOT NULL,
    ${COLUMN_TARGET_TYPE} TEXT NOT NULL,
    ${COLUMN_TARGET_TITLE} TEXT,
    ${COLUMN_TARGET_IMAGE} TEXT,
    ${COLUMN_BROWSE_TIME} INTEGER NOT NULL
  )
`;

export const CREATE_TABLE_SEARCH_HISTORY = `
  CREATE TABLE IF NOT EXISTS ${TABLE_SEARCH_HISTORY} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_KEYWORD} TEXT NOT NULL,
    ${COLUMN_SEARCH_TIME} INTEGER NOT NULL
  )
`;

export const CREATE_TABLE_COLLECTION_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_COLLECTION_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_COLLECT_TYPE} TEXT NOT NULL,
    ${COLUMN_TARGET_ID} TEXT NOT NULL,
    ${COLUMN_TARGET_TITLE} TEXT,
    ${COLUMN_TARGET_IMAGE} TEXT,
    ${COLUMN_COLLECT_TIME} INTEGER NOT NULL,
    ${COLUMN_NOTE} TEXT,
    ${COLUMN_IS_SYNCED} INTEGER DEFAULT 0
  )
`;

export const CREATE_TABLE_COMMENT_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_COMMENT_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_TARGET_TYPE} TEXT NOT NULL,
    ${COLUMN_TARGET_ID} TEXT NOT NULL,
    ${COLUMN_COMMENT_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_USER_ID} TEXT,
    ${COLUMN_CONTENT} TEXT,
    ${COLUMN_CREATE_TIME} INTEGER,
    ${COLUMN_SYNCED} INTEGER DEFAULT 0
  )
`;

export const CREATE_TABLE_ARTICLE_DRAFT = `
  CREATE TABLE IF NOT EXISTS ${TABLE_ARTICLE_DRAFT} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_DRAFT_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_DRAFT_TITLE} TEXT,
    ${COLUMN_DRAFT_CONTENT} TEXT,
    ${COLUMN_DRAFT_CATEGORY_ID} TEXT,
    ${COLUMN_DRAFT_CREATE_TIME} INTEGER,
    ${COLUMN_DRAFT_LAST_EDIT_TIME} INTEGER
  )
`;

export const CREATE_TABLE_HOSPITAL_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_HOSPITAL_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_HOSPITAL_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_NAME} TEXT,
    ${COLUMN_LEVEL} TEXT,
    ${COLUMN_ADDRESS} TEXT,
    ${COLUMN_PHONE} TEXT,
    ${COLUMN_CACHED_TIME} INTEGER NOT NULL,
    ${COLUMN_EXPIRE_TIME} INTEGER NOT NULL
  )
`;

export const CREATE_TABLE_DOCTOR_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_DOCTOR_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_DOCTOR_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_NAME} TEXT,
    ${COLUMN_HOSPITAL_ID_FK} TEXT,
    ${COLUMN_DEPARTMENT} TEXT,
    title TEXT,
    ${COLUMN_AVATAR} TEXT,
    ${COLUMN_CACHED_TIME} INTEGER,
    ${COLUMN_EXPIRE_TIME} INTEGER
  )
`;

export const CREATE_TABLE_APPOINTMENT_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_APPOINTMENT_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_APPOINTMENT_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_USER_ID} TEXT,
    ${COLUMN_DOCTOR_ID_FK} TEXT,
    ${COLUMN_HOSPITAL_ID} TEXT,
    ${COLUMN_APPOINTMENT_TIME} INTEGER,
    ${COLUMN_STATUS} TEXT,
    ${COLUMN_SYNCED} INTEGER DEFAULT 0
  )
`;

export const CREATE_TABLE_MEDICINE_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_MEDICINE_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_MEDICINE_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_NAME} TEXT,
    ${COLUMN_SPEC} TEXT,
    ${COLUMN_MANUFACTURER} TEXT,
    ${COLUMN_USAGE} TEXT,
    ${COLUMN_CACHED_TIME} INTEGER,
    ${COLUMN_EXPIRE_TIME} INTEGER
  )
`;

export const CREATE_TABLE_HEALTH_GOAL_CACHE = `
  CREATE TABLE IF NOT EXISTS ${TABLE_HEALTH_GOAL_CACHE} (
    ${COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${COLUMN_GOAL_ID} TEXT UNIQUE NOT NULL,
    ${COLUMN_USER_ID} TEXT,
    ${COLUMN_TYPE} TEXT,
    ${COLUMN_TARGET_VALUE} TEXT,
    ${COLUMN_CURRENT_VALUE} TEXT,
    ${COLUMN_START_TIME} INTEGER,
    ${COLUMN_END_TIME} INTEGER,
    ${COLUMN_SYNCED} INTEGER DEFAULT 0
  )
`;
