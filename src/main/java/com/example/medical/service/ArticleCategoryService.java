package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.ArticleCategory;

import java.util.List;

public interface ArticleCategoryService extends IService<ArticleCategory> {
    List<ArticleCategory> listParentCategories();
    List<ArticleCategory> listChildrenByParentId(Long parentId);
}
