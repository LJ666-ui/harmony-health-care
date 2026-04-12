package com.example.medical.common;

import com.example.medical.entity.HealthStandard;

public class HealthCheckResult {
    private boolean isNormal;
    private String status;
    private String message;
    private HealthStandard standard;
    private double value;
    private String unit;

    public boolean isNormal() {
        return isNormal;
    }

    public void setIsNormal(boolean isNormal) {
        this.isNormal = isNormal;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public HealthStandard getStandard() {
        return standard;
    }

    public void setStandard(HealthStandard standard) {
        this.standard = standard;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }
}