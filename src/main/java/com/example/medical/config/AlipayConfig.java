package com.example.medical.config;

import com.alipay.api.AlipayClient;
import com.alipay.api.DefaultAlipayClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AlipayConfig {

    public static final String APP_ID = "9021000163649133";
    public static final String APP_PRIVATE_KEY = "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCepy0LIeIVQgG09fuFnAxV6aUiHtE0kF9YE8fP7pYyIEs5frWNOtzIkAvKe7h5uPNLpD8eJtw16+N+fJsYWpKweEY6NphPdrOpBsSc3IOeYPCZui21hwcBOGp3VhjdWS97UeoOnV8N7qq271RyXAyehdFttd+doUTyXzks0qK9TeiWrasKBIpITwAk7Cu+k2E4drSQwtg4lGtJAvvenFqtJmNUIk4rNLSCmPC2yJsUit3OW1tJ38zj9aQQBYjfkM401Narl9S3yPiJtFXGxxqgb0+Ck8Ux/x1uHPqTCCqrh9gQHWAtyulyU5XF0J/NpogioukyXAfzHSNf6RA/6p9BAgMBAAECggEBAIyHQ+yybJGrz9s8bzgfywVmWXDpnyFSKEHZ84kIql1oIXmh9KpOUzYL8YW/JN4cptR/fbD1duUENpPZR3/A6mIJhxsVNMBeQjEb35eZ87Ob5kIkmUxLeDbqg9OEna2iy94N5qZfWsz6dJhpUYGia0MXATSOfq4fJPUSx5AeWywVqGoqTJN+bVJbaAt19duNEM6sy4NGwiuRmCospmdntsrQk7qqallYlI1Q2uP86d6xEQlsYABMuPjNs7cYjx7GFa7rRVHB/YlDBF3NjwrBLRvlXCUzt9jqQHXwm5fzZMWcO0GiiDp+CUtPKYOfmpNVuBCBF8u8AV++3blzYUPXTakCgYEA5Kd+kv85PRdiOjYqpjqfiRBrQb8wgBokEV1go970epbcJiO9lqFFMtA6LC+ji/Win+UbIuzXwK9kRCkM9MV2yVkvakp1ql0IxJXwOI4MMmp7YooH1vV1U3VEhDtro9kbJ8dUDioJQpjm2h+7BTgT3tzTCWjgjqZeVEmJAPEX79MCgYEAsaCD8FpoX30268Z+IY1J70QTjaGN8gs2XG0kqAxvdjxysaI//G7Il+NnMJqw0jYwFPCuDJP6C3UuGnoEPNKFrHWu15BroVSeU7faLZKNRejWcLZlt8Lvy3h5jXB2N+DyV8I9DomLrKWdOL022rOPPeEuAi5rSMX5lm9s/Jqp3BsCgYBVQzfprI41f6C7QDOLJNUUkTDNpXN6cUT9zKoasSrNA7A38J/jqWNaXVcz3tfHeuMXaKFD1rllOoHTANO5+mAfGMibhAR4cJSyaY7YJ+/YZOh5iCsANyt24YWZIWc0A+MiZCut1HL7iHSc5bQhcBXIxuNS4O7LgrIuD/Wsijp4zQKBgD3KRtt/t7swBcDzJcFqMwQGvH6Sapx+hgSU+yFyYfvRf1yHwpZ/u0wLEUR5K3WU4BkIuKMrftopg0Y2l+7IlTOvJIlcdfSDSSh6Vm1wA7EEFETVToEkUOKJIE+xhY5etC8PJMo/0tTWL+EjAUgHGpc+FBEyMKP6Kp7IWDNvYhNtAoGAVGOFymRbfFvGC463yqtRBAiKLdheTna9LhpaOOEx/jhTfOT1VBB5B7VsxwpdOmzlfUYgLDUexP6cOZNKf1XHX8Trx5rYZg5o0JymEsmgho17trs6i/JSLKx6I4EUGa/p0GeKN7QDCe0Twv7IVAEyil77TgeZDkwGDLlSHi9fKpM=";
    public static final String ALIPAY_PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhfBzT1ty2TEPCyTUA2OQi2kqkHD4YdNntT/nPJ2cEIFnjA+6VUol5JilczmaxNMu9A+PP9pJERHVWgK3+wAp9cz2MNQvdoJaaJTy+72MtQGBCSYChppPJ0x/qp4b1tqdnL7mB038OvBWhAFVRzx/cqF2dcVX0HodkJQum6AdXni5FL2/B63Kjji+Vuf5o7EdrYLRvL+G8zc8sHfn4+MWzDfSg6CAfEl8Tg2mfIlFlj3Nwj5bZliZWfy1nhNDxtLglNZwci5fWWxXDmg2DMfBbrjummjtx8hFXqLeSLpY1QY6yCKKYkeytr7gtLLUFTaYTab8xZey6k3NjUlQK+SsdQIDAQAB";
    public static final String GATEWAY_URL = "https://openapi-sandbox.dl.alipaydev.com/gateway.do";
    public static final String FORMAT = "JSON";
    public static final String CHARSET = "UTF-8";
    public static final String SIGN_TYPE = "RSA2";

    public static final String RETURN_URL = "http://localhost:8080/pay/return";
    public static final String NOTIFY_URL = "http://localhost:8080/pay/notify";

    @Bean
    public AlipayClient alipayClient() {
        com.alipay.api.AlipayConfig config = new com.alipay.api.AlipayConfig();
        config.setServerUrl(GATEWAY_URL);
        config.setAppId(APP_ID);
        config.setPrivateKey(APP_PRIVATE_KEY);
        config.setFormat(FORMAT);
        config.setCharset(CHARSET);
        config.setSignType(SIGN_TYPE);
        config.setAlipayPublicKey(ALIPAY_PUBLIC_KEY);
        try {
            return new DefaultAlipayClient(config);
        } catch (Exception e) {
            throw new RuntimeException("AlipayClient初始化失败", e);
        }
    }
}
