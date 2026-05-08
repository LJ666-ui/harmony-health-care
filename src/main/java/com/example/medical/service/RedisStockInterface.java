package com.example.medical.service;

import java.util.Date;

public interface RedisStockInterface {

    void setStock(Long doctorId, Date scheduleDate, Integer schedulePeriod, int maxCount);

    void incrStock(Long doctorId, Date scheduleDate, Integer schedulePeriod, int delta);

    boolean grabSlot(Long doctorId, Date scheduleDate, Integer schedulePeriod, Long userId);

    boolean backStock(Long doctorId, Date scheduleDate, Integer schedulePeriod, Long userId);

    int getRemainingStock(Long doctorId, Date scheduleDate, Integer schedulePeriod);

    boolean tryLock(String lockKey, String requestId, long expireSeconds);

    void unlock(String lockKey, String requestId);
}
