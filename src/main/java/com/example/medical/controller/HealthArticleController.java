package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthArticle;
import com.example.medical.entity.ArticleCategory;
import com.example.medical.service.HealthArticleService;
import com.example.medical.service.ArticleCategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping({"/healthArticle", "/health_article", "/health-article"})
@CrossOrigin
public class HealthArticleController {

    @Autowired
    private HealthArticleService healthArticleService;

    @Autowired
    private ArticleCategoryService articleCategoryService;

    @GetMapping("/page")
    public Result<PageResult<HealthArticle>> pageList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String parentCategoryName,
            @RequestParam(required = false) String childCategoryName) {
        try {
            PageResult<HealthArticle> result = healthArticleService.pageQuery(page, pageSize, title, parentCategoryName, childCategoryName);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取健康文章列表失败：" + e.getMessage());
        }
    }

    @GetMapping("/detail/{id}")
    public Result<HealthArticle> detail(@PathVariable Long id) {
        try {
            HealthArticle healthArticle = healthArticleService.getDetailById(id);
            if (healthArticle == null) {
                return Result.error("健康文章不存在");
            }
            return Result.success(healthArticle);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取健康文章详情失败：" + e.getMessage());
        }
    }

    @PostMapping("/add")
    public Result<Boolean> add(@RequestBody HealthArticle healthArticle) {
        try {
            boolean success = healthArticleService.addArticle(healthArticle);
            if (success) {
                return Result.success(true);
            } else {
                return Result.error("添加健康文章失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("添加健康文章失败：" + e.getMessage());
        }
    }

    @PutMapping("/update")
    public Result<Boolean> update(@RequestBody HealthArticle healthArticle) {
        try {
            boolean success = healthArticleService.updateArticle(healthArticle);
            if (success) {
                return Result.success(true);
            } else {
                return Result.error("更新健康文章失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新健康文章失败：" + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public Result<Boolean> delete(@PathVariable Long id) {
        try {
            boolean success = healthArticleService.deleteArticle(id);
            if (success) {
                return Result.success(true);
            } else {
                return Result.error("删除健康文章失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("删除健康文章失败：" + e.getMessage());
        }
    }

    @GetMapping("/list")
    public Result<List<HealthArticle>> list(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String parentCategoryName,
            @RequestParam(required = false) String childCategoryName) {
        try {
            List<HealthArticle> dataList = healthArticleService.listByCategoryNames(title, parentCategoryName, childCategoryName);
            System.out.println("数据库数据：" + dataList);
            return Result.success(dataList);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取健康文章列表失败：" + e.getMessage());
        }
    }

    @GetMapping("/categories/parent")
    public Result<List<ArticleCategory>> listParentCategories() {
        try {
            List<ArticleCategory> categories = articleCategoryService.listParentCategories();
            return Result.success(categories);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取父分类列表失败：" + e.getMessage());
        }
    }

    @GetMapping("/categories/children/{parentId}")
    public Result<List<ArticleCategory>> listChildrenCategories(@PathVariable Long parentId) {
        try {
            List<ArticleCategory> categories = articleCategoryService.listChildrenByParentId(parentId);
            return Result.success(categories);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取子分类列表失败：" + e.getMessage());
        }
    }
}

@RestController
class test_lyk {

    @GetMapping("/test_lyk")
    public String test_lyk() {
        return "项目运行成功！接口正常！";
    }
}