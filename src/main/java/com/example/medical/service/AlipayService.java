package com.example.medical.service;


import com.alipay.api.AlipayApiException;
import com.alipay.api.AlipayClient;
import com.alipay.api.internal.util.AlipaySignature;
import com.alipay.api.request.AlipayTradePagePayRequest;
import com.alipay.api.request.AlipayTradeQueryRequest;
import com.alipay.api.response.AlipayTradeQueryResponse;
import com.example.medical.config.AlipayConfig;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;

import java.util.Map;

@Slf4j
@Service
public class AlipayService {

    @Autowired
    private AlipayClient alipayClient;

    public String createPayment(String outTradeNo, String subject, String totalAmount, String description) {
        AlipayTradePagePayRequest request = new AlipayTradePagePayRequest();
        request.setReturnUrl(AlipayConfig.RETURN_URL);
        request.setNotifyUrl(AlipayConfig.NOTIFY_URL);

        JSONObject bizContent = new JSONObject();
        bizContent.put("out_trade_no", outTradeNo);
        bizContent.put("total_amount", totalAmount);
        bizContent.put("subject", subject);
        bizContent.put("product_code", "FAST_INSTANT_TRADE_PAY");
        bizContent.put("body", description);
        request.setBizContent(bizContent.toJSONString());

        try {
            String form = alipayClient.pageExecute(request).getBody();
            log.info("[支付宝] 创建PC网页支付订单成功 outTradeNo={}", outTradeNo);
            return form;
        } catch (AlipayApiException e) {
            log.error("[支付宝] 创建PC网页支付订单失败 outTradeNo={} errCode={} errMsg={}", outTradeNo, e.getErrCode(), e.getErrMsg());
            return null;
        }
    }

    public String createMobilePayment(String outTradeNo, String subject, String totalAmount, String description) {
        AlipayTradePagePayRequest request = new AlipayTradePagePayRequest();
        request.setReturnUrl(AlipayConfig.RETURN_URL);
        request.setNotifyUrl(AlipayConfig.NOTIFY_URL);

        JSONObject bizContent = new JSONObject();
        bizContent.put("out_trade_no", outTradeNo);
        bizContent.put("total_amount", totalAmount);
        bizContent.put("subject", subject);
        bizContent.put("product_code", "FAST_INSTANT_TRADE_PAY");
        bizContent.put("body", description);
        bizContent.put("timeout_express", "20m");
        String bizContentStr = bizContent.toJSONString();
        request.setBizContent(bizContentStr);

        log.info("[支付宝] PC网页支付请求参数 outTradeNo={} bizContent={}", outTradeNo, bizContentStr);

        try {
            String payUrl = alipayClient.pageExecute(request, "GET").getBody();
            if (payUrl != null && payUrl.length() > 0) {
                log.info("[支付宝] 创建PC网页支付订单成功 outTradeNo={} payUrl={}", outTradeNo, payUrl);
            } else {
                log.error("[支付宝] 创建PC网页支付订单返回空URL outTradeNo={}", outTradeNo);
            }
            return payUrl;
        } catch (AlipayApiException e) {
            log.error("[支付宝] 创建PC网页支付订单失败 outTradeNo={} errCode={} errMsg={}",
                outTradeNo, e.getErrCode(), e.getErrMsg());
            return null;
        }
    }

    public boolean verifyNotify(Map<String, String> params) {
        try {
            boolean result = AlipaySignature.rsaCheckV1(
                    params,
                    AlipayConfig.ALIPAY_PUBLIC_KEY,
                    AlipayConfig.CHARSET,
                    AlipayConfig.SIGN_TYPE
            );
            log.info("[支付宝] 异步通知验签结果: {}", result);
            return result;
        } catch (AlipayApiException e) {
            log.error("[支付宝] 异步通知验签失败: {}", e.getErrMsg());
            return false;
        }
    }

    public String queryTradeStatus(String outTradeNo) {
        AlipayTradeQueryRequest request = new AlipayTradeQueryRequest();
        String bizContent = "{\"out_trade_no\":\"" + outTradeNo + "\"}";
        request.setBizContent(bizContent);

        try {
            AlipayTradeQueryResponse response = alipayClient.execute(request);
            if (response.isSuccess()) {
                String tradeStatus = response.getTradeStatus();
                log.info("[支付宝] 查询交易状态 outTradeNo={} status={}", outTradeNo, tradeStatus);
                return tradeStatus;
            } else {
                log.warn("[支付宝] 查询交易状态失败 outTradeNo={} code={} msg={}",
                        outTradeNo, response.getCode(), response.getMsg());
                return null;
            }
        } catch (AlipayApiException e) {
            log.error("[支付宝] 查询交易状态异常 outTradeNo={} error={}", outTradeNo, e.getErrMsg());
            return null;
        }
    }
}
