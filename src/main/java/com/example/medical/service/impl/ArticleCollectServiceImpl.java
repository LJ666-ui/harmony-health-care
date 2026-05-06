package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.ArticleCollect;
import com.example.medical.entity.HealthArticle;
import com.example.medical.entity.ArticleCategory;
import com.example.medical.mapper.ArticleCollectMapper;
import com.example.medical.service.ArticleCollectService;
import com.example.medical.service.ArticleCategoryService;
import com.example.medical.service.HealthArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class ArticleCollectServiceImpl extends ServiceImpl<ArticleCollectMapper, ArticleCollect> implements ArticleCollectService {

    @Autowired
    private HealthArticleService healthArticleService;
    
    @Autowired
    private ArticleCategoryService articleCategoryService;

    @Override
    public boolean collectArticle(Long userId, Long articleId) {
        // 校验文章是否存在
        if (healthArticleService.getById(articleId) == null) {
            return false;
        }
        
        // 校验用户是否已经收藏该文章
        List<ArticleCollect> existingCollects = baseMapper.selectList(
                new QueryWrapper<ArticleCollect>().lambda()
                        .eq(ArticleCollect::getUserId, userId)
                        .eq(ArticleCollect::getArticleId, articleId)
                        .eq(ArticleCollect::getIsDeleted, 0)
        );
        
        if (!existingCollects.isEmpty()) {
            return false; // 已经收藏过了
        }
        
        // 插入收藏数据
        ArticleCollect collect = new ArticleCollect();
        collect.setUserId(userId);
        collect.setArticleId(articleId);
        collect.setCollectTime(new Date());
        collect.setCreateTime(new Date());
        collect.setUpdateTime(new Date());
        collect.setIsDeleted(0);
        
        return save(collect);
    }

    @Override
    public boolean cancelCollect(Long userId, Long articleId) {
        // 根据用户id和文章id删除收藏记录
        int result = baseMapper.delete(
                new QueryWrapper<ArticleCollect>().lambda()
                        .eq(ArticleCollect::getUserId, userId)
                        .eq(ArticleCollect::getArticleId, articleId)
                        .eq(ArticleCollect::getIsDeleted, 0)
        );
        
        return result > 0;
    }

    @Override
    public List<ArticleCollect> getMyCollects(Long userId) {
        List<ArticleCollect> collects = baseMapper.selectList(
                new QueryWrapper<ArticleCollect>().lambda()
                        .eq(ArticleCollect::getUserId, userId)
                        .eq(ArticleCollect::getIsDeleted, 0)
                        .orderByDesc(ArticleCollect::getCollectTime)
        );
        
        for (ArticleCollect collect : collects) {
            if (collect.getArticleId() != null) {
                HealthArticle article = healthArticleService.getById(collect.getArticleId());
                if (article != null) {
                    collect.setTitle(article.getTitle());
                    collect.setCoverImage(article.getCoverImage());
                    String content = article.getContent();
                    if (content != null && content.length() > 100) {
                        collect.setSummary(content.substring(0, 100));
                    } else {
                        collect.setSummary(content);
                    }
                    collect.setViewCount(article.getViewCount());
                    
                    if (article.getCategoryId() != null) {
                        try {
                            ArticleCategory category = articleCategoryService.getById(article.getCategoryId());
                            if (category != null) {
                                collect.setCategoryName(category.getCategoryName());
                            }
                        } catch (Exception e) {
                            System.err.println("获取分类名称失败: " + e.getMessage());
                        }
                    }
                }
            }
        }
        
        return collects;
    }
}