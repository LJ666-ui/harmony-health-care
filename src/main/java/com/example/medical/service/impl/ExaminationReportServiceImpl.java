package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.ExaminationReport;
import com.example.medical.mapper.ExaminationReportMapper;
import com.example.medical.service.ExaminationReportService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class ExaminationReportServiceImpl extends ServiceImpl<ExaminationReportMapper, ExaminationReport> implements ExaminationReportService {

    @Override
    public List<ExaminationReport> getByUserId(Long userId) {
        LambdaQueryWrapper<ExaminationReport> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ExaminationReport::getUserId, userId)
               .eq(ExaminationReport::getIsDeleted, 0)
               .orderByDesc(ExaminationReport::getExamDate)
               .orderByDesc(ExaminationReport::getCreateTime);
        return list(wrapper);
    }

    @Override
    public boolean updatePrintStatus(Long reportId, Integer printStatus) {
        LambdaUpdateWrapper<ExaminationReport> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(ExaminationReport::getId, reportId)
               .set(ExaminationReport::getPrintStatus, printStatus);
        if (printStatus == 2) {
            wrapper.set(ExaminationReport::getPrintTime, new Date());
        }
        return update(wrapper);
    }

    @Override
    public boolean updateResultStatus(Long reportId, Integer resultStatus) {
        LambdaUpdateWrapper<ExaminationReport> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(ExaminationReport::getId, reportId)
               .set(ExaminationReport::getResultStatus, resultStatus);
        if (resultStatus == 1) {
            wrapper.set(ExaminationReport::getResultTime, new Date());
        }
        return update(wrapper);
    }
}
