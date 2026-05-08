package com.example.medical.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Date;

@Data
public class AppointmentMessage {

    private Long userId;
    private Long doctorId;
    private Date scheduleDate;
    private Integer schedulePeriod;
    private BigDecimal fee;
    private String traceId;
}
