package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.ExaminationReport;
import java.util.List;

public interface ExaminationReportService extends IService<ExaminationReport> {

    List<ExaminationReport> getByUserId(Long userId);

    boolean updatePrintStatus(Long reportId, Integer printStatus);

    boolean updateResultStatus(Long reportId, Integer resultStatus);
}
