package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.DiseaseDict;
import com.example.medical.service.DiseaseDictService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/diseaseDict")
@CrossOrigin
public class DiseaseDictController {

    @Autowired
    private DiseaseDictService diseaseDictService;

    /**
     * 搜索疾病接口
     */
    @GetMapping("/search")
    public Result<?> searchDisease(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            return Result.success(diseaseDictService.searchByKeyword(keyword, page, pageSize));
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("搜索疾病失败：" + e.getMessage());
        }
    }

    /**
     * 分类查询接口
     */
    @GetMapping("/category")
    public Result<?> getByCategory(
            @RequestParam String category,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            return Result.success(diseaseDictService.getByCategory(category, page, pageSize));
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询分类疾病失败：" + e.getMessage());
        }
    }

    /**
     * 详情接口
     */
    @GetMapping("/detail/{id}")
    public Result<?> getDetail(@PathVariable Long id) {
        try {
            DiseaseDict diseaseDict = diseaseDictService.getById(id);
            if (diseaseDict == null) {
                return Result.error("疾病不存在");
            }
            return Result.success(diseaseDict);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取疾病详情失败：" + e.getMessage());
        }
    }
}