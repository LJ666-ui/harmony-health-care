package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.PageResult;
import com.example.medical.entity.ArticleCategory;
import com.example.medical.entity.HealthArticle;
import com.example.medical.mapper.ArticleCategoryMapper;
import com.example.medical.mapper.HealthArticleMapper;
import com.example.medical.service.HealthArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class HealthArticleServiceImpl extends ServiceImpl<HealthArticleMapper, HealthArticle> implements HealthArticleService {

    @Autowired
    private ArticleCategoryMapper articleCategoryMapper;

    @Override
    public PageResult<HealthArticle> pageQuery(int page, int pageSize, String title, String parentCategoryName, String childCategoryName) {
        Page<HealthArticle> pageInfo = new Page<>(page, pageSize);

        LambdaQueryWrapper<HealthArticle> wrapper = buildQueryWrapper(title, parentCategoryName, childCategoryName);

        wrapper.orderByDesc(HealthArticle::getPublishTime);

        pageInfo = baseMapper.selectPage(pageInfo, wrapper);

        if (title != null && !title.isEmpty() && pageInfo.getTotal() == 0) {
            throw new RuntimeException("未找到包含标题'" + title + "'的文章");
        }

        return new PageResult<>(pageInfo.getTotal(), pageInfo.getRecords(), page, pageSize);
    }

    @Override
    public HealthArticle getDetailById(Long id) {
        return super.getById(id);
    }

    @Override
    public boolean addArticle(HealthArticle healthArticle) {
        if (healthArticle.getPublishTime() == null) {
            healthArticle.setPublishTime(new java.util.Date());
        }
        if (healthArticle.getCreateTime() == null) {
            healthArticle.setCreateTime(new java.util.Date());
        }
        if (healthArticle.getUpdateTime() == null) {
            healthArticle.setUpdateTime(new java.util.Date());
        }
        if (healthArticle.getViewCount() == null) {
            healthArticle.setViewCount(0);
        }
        if (healthArticle.getCollectCount() == null) {
            healthArticle.setCollectCount(0);
        }
        if (healthArticle.getIsDeleted() == null) {
            healthArticle.setIsDeleted(0);
        }
        return super.save(healthArticle);
    }

    @Override
    public boolean updateArticle(HealthArticle healthArticle) {
        return super.updateById(healthArticle);
    }

    @Override
    public boolean deleteArticle(Long id) {
        return super.removeById(id);
    }

    @Override
    public List<HealthArticle> listByCategoryNames(String title, String parentCategoryName, String childCategoryName) {
        LambdaQueryWrapper<HealthArticle> wrapper = buildQueryWrapper(title, parentCategoryName, childCategoryName);

        wrapper.orderByDesc(HealthArticle::getPublishTime);

        List<HealthArticle> result = baseMapper.selectList(wrapper);

        if (title != null && !title.isEmpty() && result.isEmpty()) {
            throw new RuntimeException("未找到包含标题'" + title + "'的文章");
        }

        return result;
    }

    private LambdaQueryWrapper<HealthArticle> buildQueryWrapper(String title, String parentCategoryName, String childCategoryName) {
        LambdaQueryWrapper<HealthArticle> wrapper = new LambdaQueryWrapper<>();

        System.out.println("=== 开始查询 ===");
        System.out.println("输入参数 - title: " + title + ", parentCategoryName: " + parentCategoryName + ", childCategoryName: " + childCategoryName);

        ArticleCategory parentCategory = null;
        ArticleCategory childCategory = null;

        if (parentCategoryName != null && !parentCategoryName.isEmpty()) {
            System.out.println("正在查找父分类: " + parentCategoryName);
            LambdaQueryWrapper<ArticleCategory> parentWrapper = new LambdaQueryWrapper<>();
            parentWrapper.eq(ArticleCategory::getCategoryName, parentCategoryName);
            parentWrapper.eq(ArticleCategory::getParentId, 0L);
            parentCategory = articleCategoryMapper.selectOne(parentWrapper);

            if (parentCategory == null) {
                throw new RuntimeException("未找到父分类'" + parentCategoryName + "'");
            }
            System.out.println("找到父分类: " + parentCategory.getCategoryName() + ", ID: " + parentCategory.getId());
        }

        if (childCategoryName != null && !childCategoryName.isEmpty()) {
            System.out.println("正在查找子分类: " + childCategoryName);
            LambdaQueryWrapper<ArticleCategory> childWrapper = new LambdaQueryWrapper<>();
            childWrapper.eq(ArticleCategory::getCategoryName, childCategoryName);
            childWrapper.eq(ArticleCategory::getLevel, 2);
            childCategory = articleCategoryMapper.selectOne(childWrapper);

            if (childCategory == null) {
                throw new RuntimeException("未找到子分类'" + childCategoryName + "'");
            }

            if (parentCategory != null && !childCategory.getParentId().equals(parentCategory.getId())) {
                throw new RuntimeException("子分类'" + childCategoryName + "'不属于父分类'" + parentCategoryName + "'");
            }
            System.out.println("找到子分类: " + childCategory.getCategoryName() + ", ID: " + childCategory.getId() + ", 父ID: " + childCategory.getParentId());
        }

        if (title != null && !title.isEmpty()) {
            wrapper.like(HealthArticle::getTitle, title);
            System.out.println("添加标题模糊查询: " + title);
        }

        if (childCategory != null) {
            wrapper.eq(HealthArticle::getCategoryId, childCategory.getId());
            System.out.println("按子分类ID查询: " + childCategory.getId());
        } else if (parentCategory != null) {
            System.out.println("正在查找父分类ID=" + parentCategory.getId() + " 的所有子分类");
            LambdaQueryWrapper<ArticleCategory> childrenWrapper = new LambdaQueryWrapper<>();
            childrenWrapper.eq(ArticleCategory::getParentId, parentCategory.getId());
            List<ArticleCategory> children = articleCategoryMapper.selectList(childrenWrapper);

            if (!children.isEmpty()) {
                List<Long> categoryIds = children.stream().map(ArticleCategory::getId).collect(Collectors.toList());
                List<String> categoryNames = children.stream().map(ArticleCategory::getCategoryName).collect(Collectors.toList());
                System.out.println("父分类ID: " + parentCategory.getId() + ", 找到的子分类: " + categoryNames + ", IDs: " + categoryIds);
                wrapper.in(HealthArticle::getCategoryId, categoryIds);
                System.out.println("添加查询条件: categoryId IN " + categoryIds);
            } else {
                System.out.println("父分类ID: " + parentCategory.getId() + " 没有找到子分类");
                wrapper.eq(HealthArticle::getId, -1);
            }
        }

        System.out.println("=== 查询条件构建完成 ===");
        return wrapper;
    }
}