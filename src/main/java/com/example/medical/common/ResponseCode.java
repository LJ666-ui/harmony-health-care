package com.example.medical.common;

public enum ResponseCode {
    SUCCESS(200, "成功"),
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未登录或Token已过期"),
    FORBIDDEN(403, "无权限访问"),
    VALIDATION_ERROR(422, "参数校验失败"),
    NOT_FOUND(404, "资源不存在"),
    ERROR(500, "服务器内部错误"),
    USER_NOT_FOUND(404, "用户不存在"),
    USER_ALREADY_EXIST(400, "用户名已存在"),
    PASSWORD_ERROR(401, "密码错误");

    private final int code;
    private final String message;

    ResponseCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
