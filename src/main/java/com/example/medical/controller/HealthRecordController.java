package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.HealthRecord;
import com.example.medical.service.HealthRecordService;
import com.baomidou.mybatisplus.core.metadata.IPage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/record")
@CrossOrigin
public class HealthRecordController {

    @Autowired
    private HealthRecordService healthRecordService;

    // 添加健康记录
    @PostMapping("/add")
    public Result<?> addRecord(@RequestBody HealthRecord record) {
        // 设置默认记录时间
        if (record.getRecordTime() == null) {
            record.setRecordTime(new Date());
        }
        // 保存记录
        if (healthRecordService.save(record)) {
            return Result.success("添加成功");
        } else {
            return Result.error("添加失败");
        }
    }

    // 查询个人记录
    @GetMapping("/my")
    public Result<?> getMyRecords(@RequestParam Long userId) {
        List<HealthRecord> records = healthRecordService.findByUserId(userId);
        return Result.success(records);
    }

    // 按时间筛选记录
    @GetMapping("/time")
    public Result<?> getRecordsByTimeRange(
            @RequestParam Long userId,
            @RequestParam String startTime,
            @RequestParam String endTime) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date start = sdf.parse(startTime);
            Date end = sdf.parse(endTime);
            List<HealthRecord> records = healthRecordService.findByUserIdAndTimeRange(userId, start, end);
            return Result.success(records);
        } catch (ParseException e) {
            return Result.error("时间格式错误，请使用 yyyy-MM-dd HH:mm:ss 格式");
        }
    }

    // 分页查询记录
    @GetMapping("/page")
    public Result<?> getRecordsWithPage(
            @RequestParam Integer page,
            @RequestParam Integer size,
            @RequestParam Long userId) {
        IPage<HealthRecord> pageInfo = healthRecordService.findByUserIdWithPage(userId, page, size);
        return Result.success(pageInfo);
    }
}