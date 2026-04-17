--
-- SQLiteStudio v3.4.21 生成的文件，周二 4月 14 09:43:02 2026
--
-- 所用的文本编码：System
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- 表：local_article_cache
CREATE TABLE IF NOT EXISTS local_article_cache (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    article_id      INTEGER UNIQUE
                            NOT NULL,-- 对应后端health_article.id
    title           TEXT,-- 文章标题
    content_summary TEXT,-- 内容摘要(截取前200字节省空间)
    cover_image     TEXT,-- 封面图URL
    category_id     INTEGER,-- 分类ID
    is_collected    INTEGER DEFAULT 0,-- 是否已收藏(冗余字段加速查询)
    cached_time     INTEGER,-- 缓存时间戳(ms)
    last_read_time  INTEGER-- 最后阅读时间戳(ms)
);


-- 表：local_browse_history
CREATE TABLE IF NOT EXISTS local_browse_history (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    browse_type     TEXT    NOT NULL,-- 枚举值:
    /* ARTICLE      = 科普文章 */target_id       INTEGER NOT NULL,
    target_title    TEXT,
    browse_duration INTEGER DEFAULT 0,
    source_page     TEXT,
    create_time     INTEGER
);
-- HERBAL       = 药材百科-- HOSPITAL     = 医院-- FOOD         = 食疗食谱-- KNOWLEDGE    = 知识图谱节点-- REHAB        = 康复训练-- AI_CHAT      = AI对话-- ANCIENT_IMAGE= 古医图-- 浏览对象的ID(对应各业务表主键)-- 对象标题快照(避免联查)-- 停留时长(秒)，0表示未知-- 来源页面路由名(如'pages/HerbalListPage')-- 浏览开始时间戳(ms)

-- 表：local_collection_cache
CREATE TABLE IF NOT EXISTS local_collection_cache (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    collect_type TEXT    NOT NULL,-- ARTICLE / HERBAL / FOOD / PRESCRIPTION / KNOWLEDGE
    target_id    INTEGER NOT NULL,-- 收藏对象的主键ID
    target_title TEXT,-- 对象标题快照
    target_image TEXT,-- 对象封面图URL(可选)
    collect_time INTEGER,-- 收藏操作时间戳(ms)
    note         TEXT,-- 用户备注("这个对我有用")
    is_synced    INTEGER DEFAULT 0-- 0=仅本地 1=已同步到服务器
);


-- 表：local_device_cache
CREATE TABLE IF NOT EXISTS local_device_cache (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    device_id         TEXT    UNIQUE
                              NOT NULL,-- 设备唯一标识(鸿蒙deviceId)
    device_name       TEXT,-- 设备显示名称
    device_type       TEXT,-- 设备类型 phone/tablet/watch/large_screen
    device_model      TEXT,-- 设备型号
    paired            INTEGER DEFAULT 0,-- 是否已配对(0=仅发现 1=已配对)
    last_connect_time INTEGER-- 最后连接时间戳(ms)
);


-- 表：local_search_history
CREATE TABLE IF NOT EXISTS local_search_history (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    keyword          TEXT    NOT NULL,-- 搜索关键词原文
    search_count     INTEGER DEFAULT 1,-- 搜索次数(相同关键词累加，用于排序)
    last_search_time INTEGER,-- 最后搜索时间戳(ms)
    search_scope     TEXT    DEFAULT 'GLOBAL'-- 搜索范围 GLOBAL/HERBAL/ARTICLE/FOOD...
);


-- 表：local_user_cache
CREATE TABLE IF NOT EXISTS local_user_cache (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id        INTEGER NOT NULL,-- 用户ID(来自后端)
    token          TEXT    NOT NULL,-- JWT令牌(来自后端/login)
    nickname       TEXT,-- 昵称
    avatar_url     TEXT,-- 头像URL
    role_type      TEXT,-- 角色类型
    last_sync_time INTEGER,-- 最后一次与服务器同步的时间戳(ms)
    expire_time    INTEGER-- Token过期时间戳(ms)
);


-- 表：offline_health_record
CREATE TABLE IF NOT EXISTS offline_health_record (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    record_type TEXT    NOT NULL,-- 'blood_pressure'/'blood_sugar'/'heart_rate'/'weight'
    value       REAL    NOT NULL,-- 数值
    unit        TEXT,-- 单位 'mmHg'/'mmol/L'/'bpm'
    record_time INTEGER NOT NULL,-- 测量时间戳(ms)
    notes       TEXT,-- 备注
    synced      INTEGER DEFAULT 0,-- 0=未同步 1=已同步成功 2=同步失败需重试
    create_time INTEGER,-- 本地创建时间戳(ms)
    retry_count INTEGER DEFAULT 0-- 重试次数(超过3次标记为失败)
);


-- 表：sync_queue
CREATE TABLE IF NOT EXISTS sync_queue (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name     TEXT    NOT NULL,-- 要同步的本地表名
    operation_type TEXT    NOT NULL,-- INSERT / UPDATE / DELETE
    data_json      TEXT    NOT NULL,-- 操作数据的完整JSON
    target_url     TEXT,-- 对应的后端API URL
    retry_count    INTEGER DEFAULT 0,-- 已重试次数
    status         TEXT    DEFAULT 'pending',-- pending / syncing / synced / failed
    error_message  TEXT,-- 失败时的错误信息
    create_time    INTEGER,-- 入队时间戳(ms)
    sync_time      INTEGER-- 成功同步的时间戳(ms)
);


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
