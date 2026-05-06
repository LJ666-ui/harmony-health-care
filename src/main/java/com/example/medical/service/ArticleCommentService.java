package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.ArticleComment;

import java.util.List;

public interface ArticleCommentService extends IService<ArticleComment> {
    List<ArticleComment> listByArticleId(Long articleId);
    ArticleComment addComment(ArticleComment comment);
    boolean deleteComment(Long id);
    boolean likeComment(Long id);
}
