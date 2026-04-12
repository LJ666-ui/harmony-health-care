package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.RehabPlan;
import com.example.medical.service.RehabPlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/rehab")
public class RehabPlanController {

    @Autowired
    private RehabPlanService rehabPlanService;

    @GetMapping("/list")
    public Page<RehabPlan> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        Page<RehabPlan> pageInfo = new Page<>(page, size);
        return rehabPlanService.page(pageInfo);
    }

    @PostMapping("/add")
    public boolean add(@RequestBody RehabPlan rehabPlan) {
        return rehabPlanService.save(rehabPlan);
    }

    @PutMapping("/update")
    public boolean update(@RequestBody RehabPlan rehabPlan) {
        return rehabPlanService.updateById(rehabPlan);
    }

    @DeleteMapping("/delete/{id}")
    public boolean delete(@PathVariable Long id) {
        return rehabPlanService.removeById(id);
    }

    @GetMapping("/get/{id}")
    public RehabPlan get(@PathVariable Long id) {
        return rehabPlanService.getById(id);
    }

    @GetMapping("/search")
    public Page<RehabPlan> search(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String disease,
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String content,
            @RequestParam(required = false) Integer planStatus) {
        Page<RehabPlan> pageInfo = new Page<>(page, size);
        QueryWrapper<RehabPlan> queryWrapper = new QueryWrapper<>();
        
        // 复合查询
        if (disease != null && !disease.isEmpty()) {
            queryWrapper.eq("disease", disease);
        }
        if (planStatus != null) {
            queryWrapper.eq("plan_status", planStatus);
        }
        
        // 模糊查询
        if (title != null && !title.isEmpty()) {
            queryWrapper.like("title", title);
        }
        if (content != null && !content.isEmpty()) {
            queryWrapper.like("content", content);
        }
        
        return rehabPlanService.page(pageInfo, queryWrapper);
    }

    @GetMapping("/fuzzy")
    public Page<RehabPlan> fuzzySearch(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam String keyword) {
        Page<RehabPlan> pageInfo = new Page<>(page, size);
        QueryWrapper<RehabPlan> queryWrapper = new QueryWrapper<>();
        queryWrapper.like("title", keyword)
                   .or().like("content", keyword)
                   .or().like("disease", keyword)
                   .or().like("source", keyword);
        return rehabPlanService.page(pageInfo, queryWrapper);
    }

}
// 把测试接口单独拿出来，变成独立类
@RestController
class TestController {

    @GetMapping("/test")
    public String test() {
        return "项目运行成功！接口正常！";
    }
}