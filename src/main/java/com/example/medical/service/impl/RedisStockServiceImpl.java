package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.medical.entity.DoctorSchedule;
import com.example.medical.service.DoctorScheduleService;
import com.example.medical.service.RedisStockInterface;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
@Profile("redis")
public class RedisStockServiceImpl implements RedisStockInterface {

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired
    private DoctorScheduleService doctorScheduleService;

    private static final String GRAB_SLOT_LUA =
            "local stockKey = KEYS[1] " +
            "local bookedKey = KEYS[2] " +
            "local userId = ARGV[1] " +
            "if redis.call('SISMEMBER', bookedKey, userId) == 1 then " +
            "    return -1 " +
            "end " +
            "local stock = tonumber(redis.call('GET', stockKey)) " +
            "if stock == nil or stock <= 0 then " +
            "    return 0 " +
            "end " +
            "redis.call('DECR', stockKey) " +
            "redis.call('SADD', bookedKey, userId) " +
            "return 1";

    private static final String BACK_STOCK_LUA =
            "local stockKey = KEYS[1] " +
            "local bookedKey = KEYS[2] " +
            "local userId = ARGV[1] " +
            "if redis.call('SISMEMBER', bookedKey, userId) == 0 then " +
            "    return -1 " +
            "end " +
            "redis.call('INCRBY', stockKey, 1) " +
            "redis.call('SREM', bookedKey, userId) " +
            "return 1";

    private static final String UNLOCK_LUA =
            "if redis.call('get', KEYS[1]) == ARGV[1] then " +
            "    return redis.call('del', KEYS[1]) " +
            "else " +
            "    return 0 " +
            "end";

    private static final DefaultRedisScript<Long> GRAB_SCRIPT = new DefaultRedisScript<>(GRAB_SLOT_LUA, Long.class);
    private static final DefaultRedisScript<Long> BACK_SCRIPT = new DefaultRedisScript<>(BACK_STOCK_LUA, Long.class);
    private static final DefaultRedisScript<Long> UNLOCK_SCRIPT = new DefaultRedisScript<>(UNLOCK_LUA, Long.class);

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyyMMdd");

    private static final long STOCK_TTL_DAYS = 30;

    @Override
    public void setStock(Long doctorId, Date scheduleDate, Integer schedulePeriod, int maxCount) {
        String dateStr = DATE_FORMAT.format(scheduleDate);
        String stockKey = buildStockKey(doctorId, dateStr, schedulePeriod);
        String bookedKey = buildBookedKey(doctorId, dateStr, schedulePeriod);
        redisTemplate.opsForValue().set(stockKey, String.valueOf(maxCount), STOCK_TTL_DAYS, TimeUnit.DAYS);
        redisTemplate.delete(bookedKey);
    }

    @Override
    public void incrStock(Long doctorId, Date scheduleDate, Integer schedulePeriod, int delta) {
        String dateStr = DATE_FORMAT.format(scheduleDate);
        String stockKey = buildStockKey(doctorId, dateStr, schedulePeriod);
        redisTemplate.opsForValue().increment(stockKey, delta);
    }

    @Override
    public int grabSlot(Long doctorId, Date scheduleDate, Integer schedulePeriod, Long userId) {
        String dateStr = DATE_FORMAT.format(scheduleDate);
        String stockKey = buildStockKey(doctorId, dateStr, schedulePeriod);
        String bookedKey = buildBookedKey(doctorId, dateStr, schedulePeriod);

        System.out.println("[Redis调试] grabSlot → stockKey=" + stockKey + " bookedKey=" + bookedKey + " userId=" + userId);

        Boolean hasKey = redisTemplate.hasKey(stockKey);
        if (hasKey == null || !hasKey) {
            System.out.println("[Redis调试] Redis中不存在库存key，从数据库初始化...");
            LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(DoctorSchedule::getDoctorId, doctorId)
                   .eq(DoctorSchedule::getStatus, 1);

            java.util.List<DoctorSchedule> schedules = doctorScheduleService.list(wrapper);
            for (DoctorSchedule schedule : schedules) {
                java.text.SimpleDateFormat checkFormat = new java.text.SimpleDateFormat("yyyyMMdd");
                String scheduleDateStr = checkFormat.format(schedule.getScheduleDate());
                if (scheduleDateStr.equals(dateStr) && schedule.getSchedulePeriod().equals(schedulePeriod)) {
                    int maxCount = schedule.getMaxCount() != null ? schedule.getMaxCount() : 20;
                    int currentCount = schedule.getCurrentCount() != null ? schedule.getCurrentCount() : 0;
                    int remainingStock = maxCount - currentCount;
                    System.out.println("[Redis调试] 从数据库加载: doctorId=" + doctorId +
                        " date=" + dateStr + " period=" + schedulePeriod +
                        " maxCount=" + maxCount + " currentCount=" + currentCount +
                        " remainingStock=" + remainingStock);
                    
                    Boolean existingStock = redisTemplate.hasKey(stockKey);
                    if (existingStock == null || !existingStock) {
                        redisTemplate.opsForValue().set(stockKey, String.valueOf(remainingStock), STOCK_TTL_DAYS, TimeUnit.DAYS);
                        System.out.println("[Redis调试] 设置Redis库存: " + stockKey + " = " + remainingStock);
                    } else {
                        System.out.println("[Redis调试] Redis库存key已存在，跳过设置: " + stockKey);
                    }
                    
                    Boolean existingBooked = redisTemplate.hasKey(bookedKey);
                    if (existingBooked == null || !existingBooked) {
                        redisTemplate.delete(bookedKey);
                        System.out.println("[Redis调试] 确保booked集合为空: " + bookedKey);
                    } else {
                        System.out.println("[Redis调试] booked集合已存在，保留现有数据: " + bookedKey + 
                            " (成员数=" + redisTemplate.opsForSet().size(bookedKey) + ")");
                    }
                    break;
                }
            }

            hasKey = redisTemplate.hasKey(stockKey);
            if (hasKey == null || !hasKey) {
                System.out.println("[Redis调试] 数据库中也未找到排班记录，设置默认库存=20");
                redisTemplate.opsForValue().set(stockKey, "20", STOCK_TTL_DAYS, TimeUnit.DAYS);
            }
        }

        Long result = redisTemplate.execute(GRAB_SCRIPT,
                Arrays.asList(stockKey, bookedKey),
                String.valueOf(userId));
        System.out.println("[Redis调试] grabSlot → 返回值=" + result + " (1=成功 0=已满 -1=重复)");
        if (result == null) {
            return 0;
        }
        return result.intValue();
    }

    @Override
    public boolean backStock(Long doctorId, Date scheduleDate, Integer schedulePeriod, Long userId) {
        String dateStr = DATE_FORMAT.format(scheduleDate);
        String stockKey = buildStockKey(doctorId, dateStr, schedulePeriod);
        String bookedKey = buildBookedKey(doctorId, dateStr, schedulePeriod);
        System.out.println("[Redis调试] backStock → stockKey=" + stockKey + " bookedKey=" + bookedKey + " userId=" + userId);
        Long result = redisTemplate.execute(BACK_SCRIPT,
                Arrays.asList(stockKey, bookedKey),
                String.valueOf(userId));
        System.out.println("[Redis调试] backStock → 返回值=" + result + " (1=退号成功 -1=该用户未挂号)");
        if (result == null || result != 1) {
            return false;
        }
        return true;
    }

    @Override
    public int getRemainingStock(Long doctorId, Date scheduleDate, Integer schedulePeriod) {
        String dateStr = DATE_FORMAT.format(scheduleDate);
        String stockKey = buildStockKey(doctorId, dateStr, schedulePeriod);
        System.out.println("[Redis调试] getRemainingStock → stockKey=" + stockKey);
        String value = redisTemplate.opsForValue().get(stockKey);
        if (value == null) {
            return 0;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    @Override
    public boolean tryLock(String lockKey, String requestId, long expireSeconds) {
        Boolean success = redisTemplate.opsForValue()
                .setIfAbsent(lockKey, requestId, expireSeconds, TimeUnit.SECONDS);
        return Boolean.TRUE.equals(success);
    }

    @Override
    public void unlock(String lockKey, String requestId) {
        redisTemplate.execute(UNLOCK_SCRIPT,
                Collections.singletonList(lockKey),
                requestId);
    }

    private String buildStockKey(Long doctorId, String dateStr, Integer period) {
        return "stock:" + doctorId + ":" + dateStr + ":" + period;
    }

    private String buildBookedKey(Long doctorId, String dateStr, Integer period) {
        return "booked:" + doctorId + ":" + dateStr + ":" + period;
    }
}
