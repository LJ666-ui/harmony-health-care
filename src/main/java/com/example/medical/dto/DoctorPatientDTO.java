package com.example.medical.dto;

import lombok.Data;
import java.io.Serializable;

/**
 * 医生端患者信息DTO
 * 包含患者基本信息和所属分组
 */
@Data
public class DoctorPatientDTO implements Serializable {
    
    private Long patientId;          // 患者用户ID
    private String username;         // 患者姓名
    private String phone;            // 手机号
    private Integer age;             // 年龄
    private String idCard;           // 身份证号
    private Long groupId;            // 所属分组ID
    private String groupName;        // 分组名称
    
    public DoctorPatientDTO() {}
    
    public DoctorPatientDTO(Long patientId, String username, String phone, 
                           Integer age, Long groupId, String groupName) {
        this.patientId = patientId;
        this.username = username;
        this.phone = phone;
        this.age = age;
        this.groupId = groupId;
        this.groupName = groupName;
    }
}
