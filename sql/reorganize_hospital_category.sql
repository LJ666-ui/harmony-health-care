-- 重新规划医院分类
-- 基于department字段和name字段综合判断

-- 清空level字段重新分类
UPDATE hospital SET level = NULL;

-- 1. 三级甲等医院（department='三级甲等医院'）
UPDATE hospital SET level = '三级甲等' WHERE department = '三级甲等医院';

-- 2. 综合医院（department='综合医院'）
UPDATE hospital SET level = '综合医院' WHERE department = '综合医院';

-- 3. 专科医院（department='专科医院'或专科医院名称）
UPDATE hospital SET level = '专科医院' WHERE 
department = '专科医院' OR
name LIKE '%中医院%' OR
name LIKE '%妇幼%' OR
name LIKE '%口腔医院%' OR
name LIKE '%眼科医院%' OR
name LIKE '%骨科医院%' OR
name LIKE '%肿瘤医院%' OR
name LIKE '%耳鼻喉医院%';

-- 4. 卫生院/乡镇卫生院（department='卫生院'）
UPDATE hospital SET level = '卫生院' WHERE department = '卫生院';

-- 5. 社区卫生服务中心
UPDATE hospital SET level = '社区医院' WHERE 
name LIKE '%社区卫生服务中心%' OR
name LIKE '%社区卫生服务站%';

-- 6. 医疗保健服务场所
UPDATE hospital SET level = '保健机构' WHERE department = '医疗保健服务场所';

-- 7. 诊所
UPDATE hospital SET level = '诊所' WHERE department = '诊所';

-- 8. 其他未分类的根据名称判断
UPDATE hospital SET level = '综合医院' WHERE 
level IS NULL AND (
name LIKE '%人民医院%' OR
name LIKE '%中心医院%' OR
name LIKE '%总医院%'
);

UPDATE hospital SET level = '专科医院' WHERE 
level IS NULL AND (
name LIKE '%医院%' AND (
  name LIKE '%康复%' OR
  name LIKE '%美容%' OR
  name LIKE '%整形%'
)
);

-- 9. 剩余未分类设为综合医院
UPDATE hospital SET level = '综合医院' WHERE level IS NULL;

-- 查看最终结果
SELECT level, COUNT(*) as count FROM hospital GROUP BY level ORDER BY count DESC;
