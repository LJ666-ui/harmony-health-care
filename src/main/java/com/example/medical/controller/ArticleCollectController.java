package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.ArticleCollect;
import com.example.medical.service.ArticleCollectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/article")
public class ArticleCollectController {

    @Autowired
    private ArticleCollectService articleCollectService;

    @PostMapping("/{id}/collect")
    public Result<?> collectArticle(@PathVariable Long id, HttpServletRequest request) {
        // 从请求属性中获取当前登录用户 id
        Long userId = (Long) request.getAttribute("userId");
        
        // 调用 service 的收藏方法
        boolean result = articleCollectService.collectArticle(userId, id);
        
        if (result) {
            return Result.success("收藏成功");
        } else {
            return Result.error("收藏失败，文章不存在或已收藏");
        }
    }

    @DeleteMapping("/{id}/collect")
    public Result<?> cancelCollect(@PathVariable Long id, HttpServletRequest request) {
        // 从请求属性中获取当前登录用户 id
        Long userId = (Long) request.getAttribute("userId");
        
        // 调用 service 的取消收藏方法
        boolean result = articleCollectService.cancelCollect(userId, id);
        
        if (result) {
            return Result.success("取消收藏成功");
        } else {
            return Result.error("取消收藏失败，收藏记录不存在");
        }
    }

    @GetMapping("/my-collects")
    public Result<?> getMyCollects(HttpServletRequest request) {
        // 从请求属性中获取当前登录用户 id
        Long userId = (Long) request.getAttribute("userId");
        
        // 调用 service 的查询收藏列表方法
        List<ArticleCollect> collects = articleCollectService.getMyCollects(userId);
        
        return Result.success(collects);
    }
}