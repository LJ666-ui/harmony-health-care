-- ========================================
# 家属沟通功能数据验证脚本
# 验证护士-患者-家属的数据关联关系
# ========================================

USE medical_health;

SELECT '========================================' AS '';
SELECT '✅ 家属沟通功能数据验证' AS '';
SELECT '========================================' AS '';

-- 第一步：查看当前护士信息
SELECT '第一步：查看护士列表' AS '';
SELECT id, name, job_number, department FROM nurse WHERE is_deleted = 0 LIMIT 5;

-- 第二步：查看护士负责的患者
SELECT '' AS '';
SELECT '第二步：查看护士1（测试护士）负责的患者' AS '';
SELECT 
    npr.nurse_id AS 护士ID,
    npr.patient_id AS 患者ID,
    u.real_name AS 患者姓名,
    u.phone AS 患者电话
FROM nurse_patient_relation npr
JOIN user u ON npr.patient_id = u.id
WHERE npr.nurse_id = 1 
  AND npr.is_deleted = 0
  AND u.is_deleted = 0;

-- 第三步：查看这些患者的家属
SELECT '' AS '';
SELECT '第三步：查看患者的家属列表' AS '';
SELECT 
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    fm.phone AS 电话,
    fm.user_id AS 关联患者ID,
    u.real_name AS 患者姓名,
    CASE fm.is_emergency_contact 
        WHEN 1 THEN '✅ 紧急联系人'
        ELSE ''
    END AS 紧急联系标识
FROM family_member fm
JOIN user u ON fm.user_id = u.id
WHERE fm.user_id IN (
    SELECT patient_id 
    FROM nurse_patient_relation 
    WHERE nurse_id = 1 AND is_deleted = 0
)
AND fm.is_deleted = 0
ORDER BY fm.is_emergency_contact DESC, fm.id;

-- 第四步：统计每个患者的家属数量
SELECT '' AS '';
SELECT '第四步：统计每个患者的家属数量' AS '';
SELECT 
    u.id AS 患者ID,
    u.real_name AS 患者姓名,
    COUNT(fm.id) AS 家属数量,
    SUM(CASE WHEN fm.is_emergency_contact = 1 THEN 1 ELSE 0 END) AS 紧急联系人数量
FROM user u
LEFT JOIN family_member fm ON u.id = fm.user_id AND fm.is_deleted = 0
WHERE u.id IN (
    SELECT patient_id 
    FROM nurse_patient_relation 
    WHERE nurse_id = 1 AND is_deleted = 0
)
AND u.is_deleted = 0
GROUP BY u.id, u.real_name
ORDER BY u.id;

-- 第五步：验证API接口应该返回的数据格式
SELECT '' AS '';
SELECT '第五步：模拟 /nurse/families 接口返回数据（JSON格式预览）' AS '';
SELECT CONCAT(
    '[',
    GROUP_CONCAT(
        CONCAT(
            '{"id":', fm.id, 
            ',"name":"', fm.name, '"',
            ',"phone":"', IFNULL(fm.phone, ''), '"',
            ',"relation":"", fm.relation, '"',
            ',"relatedPatientId":', fm.user_id,
            ',"relatedPatientName":"', IFNULL(u.real_name, '未知用户'), '"}'
        )
        SEPARATOR ','
    ),
    ']'
) AS API_RESPONSE_PREVIEW
FROM family_member fm
JOIN user u ON fm.user_id = u.id
WHERE fm.user_id IN (
    SELECT patient_id 
    FROM nurse_patient_relation 
    WHERE nurse_id = 1 AND is_deleted = 0
)
AND fm.is_deleted = 0
LIMIT 10;

-- 第六步：检查是否有家属数据但未关联到护士的患者
SELECT '' AS '';
SELECT '第六步：检查未分配给任何护士的患者的家属' AS '';
SELECT 
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.user_id AS 患者ID,
    u.real_name AS 患者姓名
FROM family_member fm
JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0
  AND fm.user_id NOT IN (
      SELECT DISTINCT patient_id 
      FROM nurse_patient_relation 
      WHERE is_deleted = 0
  )
LIMIT 10;

-- 第七步：总体统计
SELECT '' AS '';
SELECT '第七步：数据统计汇总' AS '';
SELECT 
    (SELECT COUNT(*) FROM nurse WHERE is_deleted = 0) AS 护士总数,
    (SELECT COUNT(*) FROM nurse_patient_relation WHERE is_deleted = 0) AS 护士患者关联数,
    (SELECT COUNT(DISTINCT patient_id) FROM nurse_patient_relation WHERE is_deleted = 0) AS 被管理的患者数,
    (SELECT COUNT(*) FROM family_member WHERE is_deleted = 0) AS 家属总数;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT '✅ 验证完成！' AS '';
SELECT '========================================' AS '';
SELECT '' AS '';
SELECT '📋 后续操作步骤：' AS '';
SELECT '1. 重启后端服务（如果已修改代码）' AS '';
SELECT '2. 在模拟器中打开护士端应用' AS '';
SELECT '3. 点击"家属沟通"功能' AS '';
SELECT '4. 应该能看到家属列表（如果护士有负责的患者且这些患者有家属）' AS '';
SELECT '' AS '';
SELECT '⚠️ 如果仍显示"暂无家属"：' AS '';
SELECT '- 检查护士是否有关联的患者（nurse_patient_relation表）' AS '';
SELECT '- 检查这些患者是否有家属记录（family_member表）' AS '';
SELECT '- 查看浏览器控制台的网络请求和错误信息' AS '';
