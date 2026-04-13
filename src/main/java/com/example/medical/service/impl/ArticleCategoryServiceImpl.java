package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.ArticleCategory;
import com.example.medical.mapper.ArticleCategoryMapper;
import com.example.medical.service.ArticleCategoryService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ArticleCategoryServiceImpl extends ServiceImpl<ArticleCategoryMapper, ArticleCategory> implements ArticleCategoryService {

    @Override
    public List<ArticleCategory> listParentCategories() {
        LambdaQueryWrapper<ArticleCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleCategory::getParentId, 0L);
        wrapper.orderByAsc(ArticleCategory::getId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<ArticleCategory> listChildrenByParentId(Long parentId) {
        LambdaQueryWrapper<ArticleCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleCategory::getParentId, parentId);
        wrapper.orderByAsc(ArticleCategory::getId);
        return baseMapper.selectList(wrapper);
    }
}
