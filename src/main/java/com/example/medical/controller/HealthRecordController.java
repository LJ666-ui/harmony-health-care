package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.common.PageResult;
import com.example.medical.dto.HealthRecordItem;
import com.example.medical.entity.HealthRecord;
import com.example.medical.entity.FamilyMember;
import com.example.medical.service.HealthRecordService;
import com.example.medical.service.FamilyAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletRequest;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@RestController
@RequestMapping({"/healthRecord", "/health_record"})
@CrossOrigin
public class HealthRecordController {

    @Autowired
    private HealthRecordService healthRecordService;

    @Autowired
    private FamilyAuthService familyAuthService;

    /**
     * 添加健康记录
     */
    @PostMapping("/add")
    public Result<?> addRecord(@RequestBody HealthRecord record) {
        try {
            // 设置默认记录时间
            if (record.getRecordTime() == null) {
                record.setRecordTime(new Date());
            }
            // 保存记录
            if (healthRecordService.addHealthRecord(record)) {
                return Result.success("添加成功");
            } else {
                return Result.error("添加失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("添加失败：" + e.getMessage());
        }
    }

    /**
     * 查询个人记录
     */
    @GetMapping("/my")
    public Result<?> getMyRecords(@RequestParam Long userId, HttpServletRequest request) {
        try {
            if (userId == null) {
                return Result.error("用户ID不能为空");
            }
            
            // 从JWT token获取访问者用户ID
            Long accessUserId = getAccessUserIdFromToken(request);
            
            // 获取访问者IP地址
            String accessIp = getIpAddress(request);
            List<HealthRecord> records = healthRecordService.findByUserId(userId, accessUserId, accessIp);
            
            // 将每条健康记录拆分成多个指标项（血压、血糖、心率等）
            List<HealthRecordItem> items = convertToItems(records);
            
            return Result.success(items);
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("无权限")) {
                return Result.error(errorMsg);
            }
            return Result.error("获取记录失败：" + errorMsg);
        }
    }

    /**
     * 将健康记录转换为前端期望的格式（每条记录拆分为多个指标项）
     */
    private List<HealthRecordItem> convertToItems(List<HealthRecord> records) {
        List<HealthRecordItem> items = new ArrayList<>();
        
        for (HealthRecord record : records) {
            // 血压
            if (record.getBloodPressure() != null && !record.getBloodPressure().isEmpty()) {
                HealthRecordItem item = new HealthRecordItem();
                item.setId(record.getId());
                item.setRecordType("血压");
                item.setValue(record.getBloodPressure());
                item.setUnit("mmHg");
                item.setRecordTime(record.getRecordTime());
                item.setUserId(record.getUserId());
                items.add(item);
            }
            
            // 血糖
            if (record.getBloodSugar() != null) {
                HealthRecordItem item = new HealthRecordItem();
                item.setId(record.getId());
                item.setRecordType("血糖");
                item.setValue(record.getBloodSugar().toString());
                item.setUnit("mmol/L");
                item.setRecordTime(record.getRecordTime());
                item.setUserId(record.getUserId());
                items.add(item);
            }
            
            // 心率
            if (record.getHeartRate() != null) {
                HealthRecordItem item = new HealthRecordItem();
                item.setId(record.getId());
                item.setRecordType("心率");
                item.setValue(String.valueOf(record.getHeartRate()));
                item.setUnit("bpm");
                item.setRecordTime(record.getRecordTime());
                item.setUserId(record.getUserId());
                items.add(item);
            }
            
            // 体重
            if (record.getWeight() != null) {
                HealthRecordItem item = new HealthRecordItem();
                item.setId(record.getId());
                item.setRecordType("体重");
                item.setValue(record.getWeight().toString());
                item.setUnit("kg");
                item.setRecordTime(record.getRecordTime());
                item.setUserId(record.getUserId());
                items.add(item);
            }
            
            // 身高
            if (record.getHeight() != null) {
                HealthRecordItem item = new HealthRecordItem();
                item.setId(record.getId());
                item.setRecordType("身高");
                item.setValue(record.getHeight().toString());
                item.setUnit("cm");
                item.setRecordTime(record.getRecordTime());
                item.setUserId(record.getUserId());
                items.add(item);
            }
            
            // 步数
            if (record.getStepCount() != null) {
                HealthRecordItem item = new HealthRecordItem();
                item.setId(record.getId());
                item.setRecordType("步数");
                item.setValue(String.valueOf(record.getStepCount()));
                item.setUnit("步");
                item.setRecordTime(record.getRecordTime());
                item.setUserId(record.getUserId());
                items.add(item);
            }
            
            // 睡眠时长
            if (record.getSleepDuration() != null) {
                HealthRecordItem item = new HealthRecordItem();
                item.setId(record.getId());
                item.setRecordType("睡眠");
                item.setValue(record.getSleepDuration().toString());
                item.setUnit("小时");
                item.setRecordTime(record.getRecordTime());
                item.setUserId(record.getUserId());
                items.add(item);
            }
        }
        
        return items;
    }

    /**
     * 从JWT token获取访问者用户ID
     * 支持普通用户、家属、医生等多种角色
     */
    private Long getAccessUserIdFromToken(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        
        if (token == null || token.isEmpty() || !JwtUtil.validateToken(token)) {
            return null;
        }
        
        // 如果是家属token，返回关联的患者userId（允许家属查看患者数据）
        if (JwtUtil.isFamilyToken(token)) {
            Long familyId = JwtUtil.getFamilyId(token);
            if (familyId != null) {
                FamilyMember family = familyAuthService.getById(familyId);
                if (family != null && family.getUserId() != null) {
                    // 返回患者ID作为accessUserId，这样权限检查会通过
                    // 因为家属应该能够查看关联患者的数据
                    return family.getUserId();
                }
            }
            return familyId;
        }
        
        // 普通用户token
        if (JwtUtil.isUserToken(token)) {
            return JwtUtil.getUserId(token);
        }
        
        // 医生token
        if (JwtUtil.isDoctorToken(token)) {
            return JwtUtil.getDoctorId(token);
        }
        
        // 护士token
        if (JwtUtil.isNurseToken(token)) {
            return JwtUtil.getNurseId(token);
        }
        
        return null;
    }

    /**
     * 按时间筛选记录
     */
    @GetMapping("/time")
    public Result<?> getRecordsByTimeRange(
            @RequestParam Long userId,
            @RequestParam String startTime,
            @RequestParam String endTime,
            HttpServletRequest request) {
        try {
            if (userId == null) {
                return Result.error("用户ID不能为空");
            }
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date start = sdf.parse(startTime);
            Date end = sdf.parse(endTime);
            
            // 从JWT token获取访问者用户ID
            Long accessUserId = getAccessUserIdFromToken(request);
            
            // 获取访问者IP地址
            String accessIp = getIpAddress(request);
            List<HealthRecord> records = healthRecordService.findByUserIdAndTimeRange(userId, start, end, accessUserId, accessIp);
            return Result.success(records);
        } catch (ParseException e) {
            return Result.error("时间格式错误，请使用 yyyy-MM-dd HH:mm:ss 格式");
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("无权限")) {
                return Result.error(errorMsg);
            }
            return Result.error("获取记录失败：" + errorMsg);
        }
    }

    /**
     * 分页查询记录
     */
    @GetMapping("/page")
    public Result<?> getRecordsWithPage(
            @RequestParam Integer page,
            @RequestParam Integer size,
            @RequestParam Long userId,
            HttpServletRequest request) {
        try {
            if (userId == null) {
                return Result.error("用户ID不能为空");
            }
            
            // 从JWT token获取访问者用户ID
            Long accessUserId = getAccessUserIdFromToken(request);
            
            // 获取访问者IP地址
            String accessIp = getIpAddress(request);
            PageResult<HealthRecord> pageResult = healthRecordService.findByUserIdWithPage(userId, page, size, accessUserId, accessIp);
            return Result.success(pageResult);
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("无权限")) {
                return Result.error(errorMsg);
            }
            return Result.error("获取记录失败：" + errorMsg);
        }
    }

    /**
     * 获取访问者IP地址
     */
    private String getIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("x-forwarded-for");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }

    /**
     * 获取最新一条健康记录
     */
    @GetMapping("/latest")
    public Result<?> getLatestRecord(@RequestParam Long userId) {
        try {
            if (userId == null) {
                return Result.error("用户ID不能为空");
            }
            HealthRecord latestRecord = healthRecordService.getLatestByUserId(userId);
            if (latestRecord == null) {
                return Result.success(null);
            }
            return Result.success(latestRecord);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取最新记录失败：" + e.getMessage());
        }
    }
}