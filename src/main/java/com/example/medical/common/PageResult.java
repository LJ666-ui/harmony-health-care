package com.example.medical.common;

import lombok.Data;

import java.util.List;

@Data
public class PageResult<T> {
    private long total;
    private List<T> records;
    private int current;
    private int size;

    public PageResult(long total, List<T> records, int current, int size) {
        this.total = total;
        this.records = records;
        this.current = current;
        this.size = size;
    }
}