package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthArticle;

import java.util.List;

public interface HealthArticleService extends IService<HealthArticle> {
    PageResult<HealthArticle> pageQuery(int page, int pageSize, String title, String parentCategoryName, String childCategoryName);
    HealthArticle getDetailById(Long id);
    boolean addArticle(HealthArticle healthArticle);
    boolean updateArticle(HealthArticle healthArticle);
    boolean deleteArticle(Long id);
    List<HealthArticle> listByCategoryNames(String title, String parentCategoryName, String childCategoryName);
}