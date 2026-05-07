package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.ArticleComment;
import com.example.medical.entity.User;
import com.example.medical.mapper.ArticleCommentMapper;
import com.example.medical.service.ArticleCommentService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class ArticleCommentServiceImpl extends ServiceImpl<ArticleCommentMapper, ArticleComment> implements ArticleCommentService {

    @Autowired
    private UserService userService;

    @Override
    public List<ArticleComment> listByArticleId(Long articleId) {
        LambdaQueryWrapper<ArticleComment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleComment::getArticleId, articleId);
        wrapper.eq(ArticleComment::getIsDeleted, 0);
        wrapper.orderByAsc(ArticleComment::getCreateTime);
        
        List<ArticleComment> comments = baseMapper.selectList(wrapper);
        
        // 填充用户名和头像
        for (ArticleComment comment : comments) {
            if (comment.getUserId() != null) {
                try {
                    User user = userService.getById(comment.getUserId());
                    if (user != null) {
                        comment.setUserName(user.getUsername() != null ? user.getUsername() : "用户" + comment.getUserId());
                        comment.setUserAvatar("");
                    } else {
                        comment.setUserName("用户" + comment.getUserId());
                        comment.setUserAvatar("");
                    }
                } catch (Exception e) {
                    System.err.println("获取用户信息失败: " + e.getMessage());
                    comment.setUserName("用户" + comment.getUserId());
                    comment.setUserAvatar("");
                }
            } else {
                comment.setUserName("匿名用户");
                comment.setUserAvatar("");
            }
        }
        
        return comments;
    }

    @Override
    public ArticleComment addComment(ArticleComment comment) {
        if (comment.getCreateTime() == null) {
            comment.setCreateTime(new Date());
        }
        if (comment.getUpdateTime() == null) {
            comment.setUpdateTime(new Date());
        }
        if (comment.getLikeCount() == null) {
            comment.setLikeCount(0);
        }
        if (comment.getStatus() == null) {
            comment.setStatus(1);
        }
        if (comment.getIsDeleted() == null) {
            comment.setIsDeleted(0);
        }
        if (comment.getParentId() == null) {
            comment.setParentId(0L);
        }
        
        baseMapper.insert(comment);
        
        // 填充用户名和头像（返回给前端）
        if (comment.getUserId() != null) {
            try {
                User user = userService.getById(comment.getUserId());
                if (user != null) {
                    comment.setUserName(user.getUsername() != null ? user.getUsername() : "用户" + comment.getUserId());
                    comment.setUserAvatar("");
                } else {
                    comment.setUserName("用户" + comment.getUserId());
                    comment.setUserAvatar("");
                }
            } catch (Exception e) {
                System.err.println("获取用户信息失败: " + e.getMessage());
                comment.setUserName("用户" + comment.getUserId());
                comment.setUserAvatar("");
            }
        } else {
            comment.setUserName("匿名用户");
            comment.setUserAvatar("");
        }
        
        return comment;
    }

    @Override
    public boolean deleteComment(Long id) {
        return super.removeById(id);
    }

    @Override
    public boolean likeComment(Long id) {
        ArticleComment comment = super.getById(id);
        if (comment != null) {
            comment.setLikeCount(comment.getLikeCount() + 1);
            return super.updateById(comment);
        }
        return false;
    }
}
