package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthRecord;
import com.example.medical.service.HealthRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletRequest;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@RestController
@RequestMapping({"/healthRecord", "/health_record"})
@CrossOrigin
public class HealthRecordController {

    @Autowired
    private HealthRecordService healthRecordService;

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
            // 假设当前登录用户ID为1，实际项目中应该从JWT token中获取
            Long accessUserId = 1L;
            // 获取访问者IP地址
            String accessIp = getIpAddress(request);
            List<HealthRecord> records = healthRecordService.findByUserId(userId, accessUserId, accessIp);
            return Result.success(records);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取记录失败：" + e.getMessage());
        }
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
            // 假设当前登录用户ID为1，实际项目中应该从JWT token中获取
            Long accessUserId = 1L;
            // 获取访问者IP地址
            String accessIp = getIpAddress(request);
            List<HealthRecord> records = healthRecordService.findByUserIdAndTimeRange(userId, start, end, accessUserId, accessIp);
            return Result.success(records);
        } catch (ParseException e) {
            return Result.error("时间格式错误，请使用 yyyy-MM-dd HH:mm:ss 格式");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取记录失败：" + e.getMessage());
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
            // 假设当前登录用户ID为1，实际项目中应该从JWT token中获取
            Long accessUserId = 1L;
            // 获取访问者IP地址
            String accessIp = getIpAddress(request);
            PageResult<HealthRecord> pageResult = healthRecordService.findByUserIdWithPage(userId, page, size, accessUserId, accessIp);
            return Result.success(pageResult);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取记录失败：" + e.getMessage());
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