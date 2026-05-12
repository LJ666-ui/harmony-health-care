package com.example.medical.integration;

import com.example.medical.entity.*;
import com.example.medical.service.*;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 集成测试 - 医生排班管理流程
 */
@SpringBootTest
@Transactional
class DoctorScheduleIntegrationTest {

    @Autowired
    private DoctorScheduleService doctorScheduleService;

    @Test
    void testCreateAndRetrieveSchedule() {
        // 创建排班
        DoctorSchedule schedule = new DoctorSchedule();
        schedule.setDoctorId(1L);
        schedule.setMaxCount(20);
        schedule.setSchedulePeriod(0); // 上午
        
        DoctorSchedule created = doctorScheduleService.createSchedule(schedule);
        
        assertNotNull(created.getId());
        assertEquals(1L, created.getDoctorId());
        assertEquals(20, created.getMaxCount());
        assertEquals(0, created.getCurrentCount());
        
        // 查询排班
        DoctorSchedule retrieved = doctorScheduleService.getScheduleById(created.getId());
        assertNotNull(retrieved);
        assertEquals(created.getId(), retrieved.getId());
    }

    @Test
    void testIncrementAndDecrementAppointmentCount() {
        // 创建排班
        DoctorSchedule schedule = new DoctorSchedule();
        schedule.setDoctorId(1L);
        schedule.setMaxCount(5);
        schedule.setSchedulePeriod(0);
        
        DoctorSchedule created = doctorScheduleService.createSchedule(schedule);
        
        // 增加预约数量
        boolean success = doctorScheduleService.incrementAppointmentCount(created.getId());
        assertTrue(success);
        
        DoctorSchedule updated = doctorScheduleService.getScheduleById(created.getId());
        assertEquals(1, updated.getCurrentCount());
        
        // 减少预约数量
        success = doctorScheduleService.decrementAppointmentCount(created.getId());
        assertTrue(success);
        
        updated = doctorScheduleService.getScheduleById(created.getId());
        assertEquals(0, updated.getCurrentCount());
    }
}

/**
 * 集成测试 - 处方模板管理流程
 */
@SpringBootTest
@Transactional
class PrescriptionTemplateIntegrationTest {

    @Autowired
    private PrescriptionTemplateService prescriptionTemplateService;

    @Test
    void testCreateAndUseTemplate() {
        // 创建模板
        PrescriptionTemplate template = new PrescriptionTemplate();
        template.setDoctorId(1L);
        template.setTemplateName("感冒处方模板");
        template.setMedicines("[{\"name\":\"感冒灵\",\"dosage\":\"1片\"}]");
        template.setIsPublic(0);
        
        PrescriptionTemplate created = prescriptionTemplateService.create(template);
        
        assertNotNull(created.getId());
        assertEquals(0, created.getUsageCount());
        
        // 使用模板
        PrescriptionTemplate used = prescriptionTemplateService.useTemplate(created.getId());
        assertEquals(1, used.getUsageCount());
    }
}

/**
 * 集成测试 - 会诊管理流程
 */
@SpringBootTest
@Transactional
class ConsultationIntegrationTest {

    @Autowired
    private ConsultationService consultationService;

    @Test
    void testInitiateAndCompleteConsultation() {
        // 发起会诊
        Consultation consultation = new Consultation();
        consultation.setInitiatorId(1L);
        consultation.setPatientId(1L);
        consultation.setTitle("疑难病例会诊");
        consultation.setDescription("需要多科室会诊");
        
        Consultation created = consultationService.initiate(
            consultation, 
            Arrays.asList(2L, 3L), 
            null
        );
        
        assertNotNull(created.getId());
        assertEquals("pending", created.getStatus());
        
        // 开始会诊
        Consultation started = consultationService.start(created.getId());
        assertEquals("in_progress", started.getStatus());
        assertNotNull(started.getStartedTime());
        
        // 结束会诊
        Consultation ended = consultationService.end(created.getId());
        assertEquals("completed", ended.getStatus());
        assertNotNull(ended.getEndedTime());
    }
}

/**
 * 集成测试 - 数据访问审批流程
 */
@SpringBootTest
@Transactional
class DataAccessApprovalIntegrationTest {

    @Autowired
    private DataAccessApplicationService dataAccessApplicationService;

    @Test
    void testApplyAndApproveDataAccess() {
        // 申请数据访问
        DataAccessApplication application = new DataAccessApplication();
        application.setRequesterId(2L);
        application.setRequesterRole("doctor");
        application.setApproverId(1L);
        application.setDataType("health_record");
        application.setDataId(1L);
        application.setReason("需要查看患者病历");
        application.setDuration(24);
        
        DataAccessApplication created = dataAccessApplicationService.apply(application);
        
        assertNotNull(created.getId());
        assertEquals("pending", created.getStatus());
        
        // 审批通过
        DataAccessApplication approved = dataAccessApplicationService.approve(
            created.getId(), 
            1L, 
            true, 
            "同意访问"
        );
        
        assertEquals("approved", approved.getStatus());
        assertNotNull(approved.getApprovedAt());
        assertNotNull(approved.getExpiresAt());
    }
}

/**
 * 集成测试 - 敏感操作确认流程
 */
@SpringBootTest
@Transactional
class SensitiveOperationIntegrationTest {

    @Autowired
    private SensitiveOperationService sensitiveOperationService;

    @Test
    void testInitiateAndConfirmSensitiveOperation() {
        // 发起敏感操作
        SensitiveOperation operation = new SensitiveOperation();
        operation.setUserId(1L);
        operation.setOperationType("delete");
        operation.setResourceType("health_record");
        operation.setResourceId(1L);
        operation.setReason("删除过期病历");
        
        SensitiveOperation created = sensitiveOperationService.initiate(operation);
        
        assertNotNull(created.getId());
        assertEquals("pending_confirmation", created.getStatus());
        assertNotNull(created.getConfirmationCode());
        assertEquals(6, created.getConfirmationCode().length());
        
        // 确认操作
        SensitiveOperation confirmed = sensitiveOperationService.confirm(
            created.getId(), 
            created.getConfirmationCode()
        );
        
        assertEquals("confirmed", confirmed.getStatus());
        assertNotNull(confirmed.getConfirmedAt());
    }
}
