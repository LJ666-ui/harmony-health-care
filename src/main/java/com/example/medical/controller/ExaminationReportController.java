package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.example.medical.common.Result;
import com.example.medical.entity.Appointment;
import com.example.medical.entity.Doctor;
import com.example.medical.entity.ExaminationReport;
import com.example.medical.entity.User;
import com.example.medical.service.AppointmentService;
import com.example.medical.service.DoctorService;
import com.example.medical.service.ExaminationReportService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.*;

@RestController
@RequestMapping("/examination-report")
@CrossOrigin
public class ExaminationReportController {

    @Autowired
    private ExaminationReportService examinationReportService;

    @Autowired
    private UserService userService;

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private AppointmentService appointmentService;

    @GetMapping("/list")
    public Result<?> getReportList(@RequestParam Long userId) {
        try {
            List<ExaminationReport> reports = examinationReportService.getByUserId(userId);

            List<Map<String, Object>> result = new ArrayList<>();
            for (ExaminationReport report : reports) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", report.getId());
                item.put("reportType", report.getReportType());
                item.put("reportName", report.getReportName());
                item.put("examDate", report.getExamDate());
                item.put("departmentName", report.getDepartmentName());
                item.put("doctorName", report.getDoctorName());
                item.put("hospitalName", report.getHospitalName());
                item.put("pickupLocation", report.getPickupLocation());
                item.put("printStatus", report.getPrintStatus());
                item.put("resultStatus", report.getResultStatus());
                item.put("conclusion", report.getConclusion());
                item.put("abnormalItems", report.getAbnormalItems());
                item.put("printTime", report.getPrintTime());
                item.put("resultTime", report.getResultTime());
                item.put("fee", report.getFee());

                String printStatusText = "";
                switch (report.getPrintStatus() != null ? report.getPrintStatus() : 0) {
                    case 0:
                        printStatusText = "待打印";
                        break;
                    case 1:
                        printStatusText = "打印中";
                        break;
                    case 2:
                        printStatusText = "已完成可取";
                        break;
                    default:
                        printStatusText = "待打印";
                }
                item.put("printStatusText", printStatusText);

                String resultStatusText = "";
                switch (report.getResultStatus() != null ? report.getResultStatus() : 0) {
                    case 0:
                        resultStatusText = "待出结果";
                        break;
                    case 1:
                        resultStatusText = "已出结果";
                        break;
                    default:
                        resultStatusText = "待出结果";
                }
                item.put("resultStatusText", resultStatusText);

                result.add(item);
            }

            Map<String, Object> data = new HashMap<>();
            data.put("reports", result);
            data.put("total", result.size());
            return Result.success(data);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询报告列表失败：" + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public Result<?> getReportDetail(@PathVariable Long id) {
        try {
            ExaminationReport report = examinationReportService.getById(id);
            if (report == null || report.getIsDeleted() == 1) {
                return Result.error("报告不存在");
            }

            Map<String, Object> item = new HashMap<>();
            item.put("id", report.getId());
            item.put("reportType", report.getReportType());
            item.put("reportName", report.getReportName());
            item.put("examDate", report.getExamDate());
            item.put("departmentName", report.getDepartmentName());
            item.put("doctorName", report.getDoctorName());
            item.put("hospitalName", report.getHospitalName());
            item.put("pickupLocation", report.getPickupLocation());
            item.put("printStatus", report.getPrintStatus());
            item.put("resultStatus", report.getResultStatus());
            item.put("conclusion", report.getConclusion());
            item.put("abnormalItems", report.getAbnormalItems());
            item.put("printTime", report.getPrintTime());
            item.put("resultTime", report.getResultTime());
            item.put("fee", report.getFee());

            return Result.success(item);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询报告详情失败：" + e.getMessage());
        }
    }

    @PostMapping("/generate")
    public Result<?> generateReport(@RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.parseLong(body.get("userId").toString());
            Long appointmentId = body.containsKey("appointmentId") ?
                Long.parseLong(body.get("appointmentId").toString()) : null;

            Appointment appointment = null;
            if (appointmentId != null) {
                appointment = appointmentService.getById(appointmentId);
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

            ExaminationReport report = new ExaminationReport();
            report.setUserId(userId);

            if (appointment != null) {
                report.setAppointmentId(appointmentId);
                report.setHospitalId(appointment.getDoctorId());
                report.setExamDate(appointment.getScheduleDate());

                Doctor doctor = doctorService.getById(appointment.getDoctorId());
                if (doctor != null) {
                    User docUser = userService.getById(doctor.getUserId());
                    if (docUser != null) {
                        report.setDoctorName(docUser.getRealName());
                    }
                    report.setDepartmentName(doctor.getDepartment());
                    report.setHospitalName(doctor.getHospital());
                }
            } else {
                report.setExamDate(new Date());
            }

            report.setReportType(body.get("reportType") != null ? body.get("reportType").toString() : "检验检查");
            report.setReportName(body.get("reportName") != null ? body.get("reportName").toString() : "常规检查");
            report.setPickupLocation(body.get("pickupLocation") != null ? body.get("pickupLocation").toString() : "一楼放射科取片窗口");
            report.setPrintStatus(0);
            report.setResultStatus(0);
            report.setFee(body.get("fee") != null ? new java.math.BigDecimal(body.get("fee").toString()) : java.math.BigDecimal.ZERO);
            report.setIsDeleted(0);
            report.setCreateTime(new Date());
            report.setUpdateTime(new Date());

            if (examinationReportService.save(report)) {

                LambdaUpdateWrapper<ExaminationReport> updateWrapper = new LambdaUpdateWrapper<>();
                updateWrapper.eq(ExaminationReport::getId, report.getId())
                             .set(ExaminationReport::getPrintStatus, 1)
                             .set(ExaminationReport::getPrintTime, new Date());
                examinationReportService.update(updateWrapper);

                Thread.sleep(2000 + (long)(Math.random() * 3000));

                LambdaUpdateWrapper<ExaminationReport> doneWrapper = new LambdaUpdateWrapper<>();
                doneWrapper.eq(ExaminationReport::getId, report.getId())
                           .set(ExaminationReport::getPrintStatus, 2)
                           .set(ExaminationReport::getResultStatus, 1)
                           .set(ExaminationReport::getConclusion, "未见明显异常")
                           .set(ExaminationReport::getResultTime, new Date());
                examinationReportService.update(doneWrapper);

                Map<String, Object> result = new HashMap<>();
                result.put("message", "报告生成成功");
                result.put("reportId", report.getId());
                return Result.success(result);
            } else {
                return Result.error("报告生成失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("报告生成失败：" + e.getMessage());
        }
    }

    @PutMapping("/{id}/print-status")
    public Result<?> updatePrintStatus(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        try {
            Integer status = Integer.parseInt(body.get("status").toString());
            boolean success = examinationReportService.updatePrintStatus(id, status);
            if (success) {
                return Result.success("打印状态更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新失败：" + e.getMessage());
        }
    }

    @PostMapping("/init-demo")
    public Result<?> initDemoData(@RequestParam Long userId) {
        try {
            String[] types = {"CT检查", "X光片", "MRI核磁共振", "血常规", "尿常规", "心电图", "B超", "生化全项"};
            String[] locations = {"一楼放射科取片窗口（3号）", "二楼检验科自助取片机", "三楼超声科登记处",
                                  "门诊大厅自助打印机A区", "医技楼一层取片处", "急诊楼2层影像中心"};
            String[] departments = {"放射科", "检验科", "影像科", "内科", "外科", "超声科"};
            String[] conclusions = {"未见明显异常", "轻度异常，建议复查", "各项指标正常范围",
                                     "发现异常阴影，建议进一步检查", "指标基本正常"};
            String[] abnormalItems = {"", "", "", "肺部纹理稍增粗", ""};

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Calendar cal = Calendar.getInstance();

            for (int i = 0; i < types.length; i++) {
                ExaminationReport report = new ExaminationReport();
                report.setUserId(userId);
                report.setReportType(types[i]);
                report.setReportName(types[i] + "报告单");
                report.setDepartmentName(departments[i % departments.length]);
                report.setDoctorName("张医生");
                report.setHospitalName("协和医院");
                report.setPickupLocation(locations[i % locations.length]);

                cal.add(Calendar.DATE, -i);
                report.setExamDate(cal.getTime());

                int printStat = (i < 3) ? 2 : ((i < 5) ? 1 : 0);
                report.setPrintStatus(printStat);
                report.setResultStatus(printStat >= 1 ? 1 : 0);

                if (printStat == 2) {
                    report.setPrintTime(new Date(System.currentTimeMillis() - (long)(Math.random() * 3600000)));
                    report.setResultTime(new Date(System.currentTimeMillis() - (long)(Math.random() * 1800000)));
                    report.setConclusion(conclusions[i]);
                    report.setAbnormalItems(abnormalItems[i]);
                } else if (printStat == 1) {
                    report.setPrintTime(new Date());
                }

                report.setFee(new java.math.BigDecimal((int)(20 + Math.random() * 200)));
                report.setIsDeleted(0);
                report.setCreateTime(new Date(System.currentTimeMillis() - (long)(i * 86400000L)));
                report.setUpdateTime(new Date());

                examinationReportService.save(report);
            }

            return Result.success("演示数据初始化完成，共" + types.length + "条报告");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("初始化失败：" + e.getMessage());
        }
    }
}
