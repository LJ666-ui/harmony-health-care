package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.PaymentRecord;

public interface PaymentRecordService extends IService<PaymentRecord> {

    PaymentRecord getByOutTradeNo(String outTradeNo);

    boolean markPaySuccess(String outTradeNo, String tradeNo);

    boolean removeByOutTradeNo(String outTradeNo);
}
