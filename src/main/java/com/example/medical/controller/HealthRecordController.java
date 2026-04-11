package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthRecord;
import com.example.medical.service.HealthRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

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
    public Result<?> getMyRecords(@RequestParam Long userId) {
        try {
            if (userId == null) {
                return Result.error("用户ID不能为空");
            }
            List<HealthRecord> records = healthRecordService.findByUserId(userId);
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
            @RequestParam String endTime) {
        try {
            if (userId == null) {
                return Result.error("用户ID不能为空");
            }
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date start = sdf.parse(startTime);
            Date end = sdf.parse(endTime);
            List<HealthRecord> records = healthRecordService.findByUserIdAndTimeRange(userId, start, end);
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
            @RequestParam Long userId) {
        try {
            if (userId == null) {
                return Result.error("用户ID不能为空");
            }
            PageResult<HealthRecord> pageResult = healthRecordService.findByUserIdWithPage(userId, page, size);
            return Result.success(pageResult);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取记录失败：" + e.getMessage());
        }
    }
}