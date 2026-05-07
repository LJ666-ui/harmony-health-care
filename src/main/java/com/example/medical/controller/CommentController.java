package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.ArticleComment;
import com.example.medical.service.ArticleCommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/comment")
@CrossOrigin
public class CommentController {

    @Autowired
    private ArticleCommentService articleCommentService;

    @GetMapping("/list/{articleId}")
    public Result<List<ArticleComment>> listComments(@PathVariable Long articleId) {
        try {
            List<ArticleComment> comments = articleCommentService.listByArticleId(articleId);
            return Result.success(comments);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取评论列表失败：" + e.getMessage());
        }
    }

    @PostMapping("/add")
    public Result<ArticleComment> addComment(@RequestBody ArticleComment comment, HttpServletRequest request) {
        try {
            Long userId = (Long) request.getAttribute("userId");
            if (userId == null) {
                return Result.error("请先登录");
            }
            comment.setUserId(userId);
            ArticleComment newComment = articleCommentService.addComment(comment);
            return Result.success(newComment);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("评论发布失败：" + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public Result<Boolean> deleteComment(@PathVariable Long id) {
        try {
            boolean success = articleCommentService.deleteComment(id);
            if (success) {
                return Result.success(true);
            } else {
                return Result.error("删除失败，评论不存在");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("删除评论失败：" + e.getMessage());
        }
    }

    @GetMapping("/like/{id}")
    public Result<Integer> likeComment(@PathVariable Long id) {
        try {
            boolean success = articleCommentService.likeComment(id);
            if (success) {
                ArticleComment comment = articleCommentService.getById(id);
                return Result.success(comment.getLikeCount());
            } else {
                return Result.error("点赞失败，评论不存在");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("点赞失败：" + e.getMessage());
        }
    }
}
