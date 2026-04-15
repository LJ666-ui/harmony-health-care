package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.ArticleCollect;

import java.util.List;

public interface ArticleCollectService extends IService<ArticleCollect> {
    boolean collectArticle(Long userId, Long articleId);
    boolean cancelCollect(Long userId, Long articleId);
    List<ArticleCollect> getMyCollects(Long userId);
}