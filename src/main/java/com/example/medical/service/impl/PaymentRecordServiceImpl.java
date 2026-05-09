package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.PaymentRecord;
import com.example.medical.mapper.PaymentRecordMapper;
import com.example.medical.service.PaymentRecordService;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class PaymentRecordServiceImpl extends ServiceImpl<PaymentRecordMapper, PaymentRecord>
        implements PaymentRecordService {

    @Override
    public PaymentRecord getByOutTradeNo(String outTradeNo) {
        LambdaQueryWrapper<PaymentRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PaymentRecord::getOutTradeNo, outTradeNo);
        return getOne(wrapper);
    }

    @Override
    public boolean markPaySuccess(String outTradeNo, String tradeNo) {
        LambdaUpdateWrapper<PaymentRecord> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(PaymentRecord::getOutTradeNo, outTradeNo)
               .set(PaymentRecord::getStatus, 1)
               .set(PaymentRecord::getTradeNo, tradeNo)
               .set(PaymentRecord::getUpdateTime, new Date());
        return update(wrapper);
    }

    @Override
    public boolean removeByOutTradeNo(String outTradeNo) {
        LambdaQueryWrapper<PaymentRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PaymentRecord::getOutTradeNo, outTradeNo);
        return remove(wrapper);
    }
}
