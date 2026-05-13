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
    PASSWORD_ERROR(401, "密码错误"),
    PARAM_ERROR(400, "参数错误"),
    
    // 会诊相关错误码
    CONSULTATION_NOT_FOUND(404, "会诊不存在"),
    CONSULTATION_ALREADY_STARTED(400, "会诊已开始"),
    CONSULTATION_ALREADY_ENDED(400, "会诊已结束"),
    CONSULTATION_NOT_IN_PROGRESS(400, "会诊未在进行中"),
    CONSULTATION_INVITATION_NOT_FOUND(404, "未找到会诊邀请"),
    
    // 数据访问审批相关错误码
    DATA_ACCESS_APPLICATION_NOT_FOUND(404, "数据访问申请不存在"),
    DATA_ACCESS_ALREADY_APPROVED(400, "数据访问申请已审批"),
    DATA_ACCESS_ALREADY_EXPIRED(400, "数据访问权限已过期"),
    
    // 敏感操作相关错误码
    SENSITIVE_OPERATION_NOT_FOUND(404, "敏感操作不存在"),
    CONFIRMATION_CODE_ERROR(400, "确认码错误"),
    SENSITIVE_OPERATION_ALREADY_CONFIRMED(400, "敏感操作已确认"),
    SENSITIVE_OPERATION_ALREADY_CANCELLED(400, "敏感操作已取消"),
    
    // 排班相关错误码
    SCHEDULE_NOT_FOUND(404, "排班不存在"),
    SCHEDULE_ALREADY_BOOKED(400, "该排班已满"),
    SCHEDULE_HAS_APPOINTMENT(400, "该排班已有预约，无法删除"),
    
    // 模板相关错误码
    TEMPLATE_NOT_FOUND(404, "模板不存在");

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
