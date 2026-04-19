package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.medical.common.Result;
import com.example.medical.entity.HerbalMedicine;
import com.example.medical.entity.HerbalEfficacy;
import com.example.medical.entity.HerbalCollect;
import com.example.medical.service.HerbalMedicineService;
import com.example.medical.mapper.HerbalEfficacyMapper;
import com.example.medical.mapper.HerbalCollectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/herbal")
@CrossOrigin
public class HerbalMedicineController {

    @Autowired
    private HerbalMedicineService herbalMedicineService;

    @Autowired
    private HerbalEfficacyMapper herbalEfficacyMapper;

    @Autowired
    private HerbalCollectMapper herbalCollectMapper;

    /**
     * 1. 分页查询药材接口
     */
    @GetMapping("/page")
    public Result<Page<HerbalMedicine>> pageQuery(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        try {
            Page<HerbalMedicine> result = herbalMedicineService.pageQuery(page, size, keyword);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("分页查询失败：" + e.getMessage());
        }
    }

    /**
     * 2. 根据ID查询单条药材接口
     */
    @GetMapping("/info/{id}")
    public Result<HerbalMedicine> getById(@PathVariable Long id) {
        try {
            HerbalMedicine medicine = herbalMedicineService.getById(id);
            if (medicine == null) {
                return Result.error("药材不存在");
            }
            return Result.success(medicine);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    /**
     * 3. 新增药材接口
     */
    @PostMapping("/add")
    public Result<?> add(@RequestBody HerbalMedicine medicine) {
        try {
            medicine.setIsDeleted(0);
            if (herbalMedicineService.save(medicine)) {
                return Result.success("新增成功");
            } else {
                return Result.error("新增失败");
            }
        } catch (Exception e) {
            return Result.error("新增失败：" + e.getMessage());
        }
    }

    /**
     * 4. 修改药材信息接口
     */
    @PutMapping("/update")
    public Result<?> update(@RequestBody HerbalMedicine medicine) {
        try {
            if (herbalMedicineService.updateById(medicine)) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            return Result.error("更新失败：" + e.getMessage());
        }
    }

    /**
     * 5. 逻辑删除药材接口
     */
    @DeleteMapping("/delete/{id}")
    public Result<?> delete(@PathVariable Long id) {
        try {
            HerbalMedicine medicine = new HerbalMedicine();
            medicine.setId(id);
            medicine.setIsDeleted(1);
            if (herbalMedicineService.updateById(medicine)) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            return Result.error("删除失败：" + e.getMessage());
        }
    }

    /**
     * 6. 根据药材ID查询功效列表接口
     */
    @GetMapping("/efficacy/list/{medicineId}")
    public Result<List<HerbalEfficacy>> getEfficacies(@PathVariable Long medicineId) {
        try {
            List<HerbalEfficacy> efficacies = herbalMedicineService.getEfficaciesByMedicineId(medicineId);
            return Result.success(efficacies);
        } catch (Exception e) {
            return Result.error("查询功效列表失败：" + e.getMessage());
        }
    }

    /**
     * 7. 给药材新增功效接口
     */
    @PostMapping("/efficacy/add")
    public Result<?> addEfficacy(@RequestBody HerbalEfficacy efficacy) {
        try {
            if (herbalEfficacyMapper.insert(efficacy) > 0) {
                return Result.success("新增功效成功");
            } else {
                return Result.error("新增功效失败");
            }
        } catch (Exception e) {
            return Result.error("新增功效失败：" + e.getMessage());
        }
    }

    /**
     * 8. 修改药材功效接口
     */
    @PutMapping("/efficacy/update")
    public Result<?> updateEfficacy(@RequestBody HerbalEfficacy efficacy) {
        try {
            if (herbalEfficacyMapper.updateById(efficacy) > 0) {
                return Result.success("更新功效成功");
            } else {
                return Result.error("更新功效失败");
            }
        } catch (Exception e) {
            return Result.error("更新功效失败：" + e.getMessage());
        }
    }

    /**
     * 9. 删除药材功效接口
     */
    @DeleteMapping("/efficacy/delete/{id}")
    public Result<?> deleteEfficacy(@PathVariable Long id) {
        try {
            int result = herbalEfficacyMapper.deleteById(id);
            if (result > 0) {
                return Result.success("删除功效成功");
            } else {
                return Result.error("删除功效失败：功效ID不存在或已被删除");
            }
        } catch (Exception e) {
            return Result.error("删除功效失败：" + e.getMessage());
        }
    }

    /**
     * 10. 按状态查询药材接口
     */
    @GetMapping("/list/by-status")
    public Result<List<HerbalMedicine>> getByStatus(@RequestParam Integer status) {
        try {
            QueryWrapper<HerbalMedicine> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("is_deleted", 0);
            // 这里假设status是指is_deleted字段，根据实际业务逻辑调整
            List<HerbalMedicine> medicines = herbalMedicineService.list(queryWrapper);
            return Result.success(medicines);
        } catch (Exception e) {
            return Result.error("按状态查询失败：" + e.getMessage());
        }
    }

    /**
     * 11. 查询全部药材列表（不分页）接口
     */
    @GetMapping("/list/all")
    public Result<List<HerbalMedicine>> getAll() {
        try {
            QueryWrapper<HerbalMedicine> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("is_deleted", 0);
            List<HerbalMedicine> medicines = herbalMedicineService.list(queryWrapper);
            return Result.success(medicines);
        } catch (Exception e) {
            return Result.error("查询全部列表失败：" + e.getMessage());
        }
    }

    /**
     * 12. 热门药材接口（按收藏数或浏览量排序）
     */
    @GetMapping("/hot")
    public Result<List<HerbalMedicine>> getHotHerbals(
            @RequestParam(defaultValue = "10") Integer limit) {
        try {
            Page<HerbalMedicine> page = new Page<>(1, limit);
            QueryWrapper<HerbalMedicine> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("is_deleted", 0);
            queryWrapper.orderByDesc("collect_count");
            Page<HerbalMedicine> result = herbalMedicineService.page(page, queryWrapper);
            return Result.success(result.getRecords());
        } catch (Exception e) {
            return Result.error("获取热门药材失败：" + e.getMessage());
        }
    }

    /**
     * 13. 药材搜索接口（支持名称和拼音搜索）
     */
    @GetMapping("/search")
    public Result<List<HerbalMedicine>> searchHerbals(
            @RequestParam String keyword) {
        try {
            QueryWrapper<HerbalMedicine> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("is_deleted", 0);
            queryWrapper.and(wrapper -> wrapper
                    .like("name", keyword)
                    .or()
                    .like("pinyin", keyword)
                    .or()
                    .like("alias", keyword)
            );
            queryWrapper.last("LIMIT 50");
            List<HerbalMedicine> medicines = herbalMedicineService.list(queryWrapper);
            return Result.success(medicines);
        } catch (Exception e) {
            return Result.error("搜索失败：" + e.getMessage());
        }
    }

    /**
     * 14. 收藏药材接口
     */
    @PostMapping("/{id}/collect")
    public Result<?> collectHerbal(@PathVariable Long id, HttpServletRequest request) {
        try {
            Long userId = 1L; // TODO: 实际应从JWT Token中获取

            HerbalCollect existing = herbalCollectMapper.findByUserIdAndHerbalId(userId, id);
            if (existing != null) {
                return Result.error("已收藏，请勿重复收藏");
            }

            HerbalCollect collect = new HerbalCollect();
            collect.setUserId(userId);
            collect.setHerbalId(id);
            collect.setCollectTime(new Date());
            collect.setIsDeleted(0);

            int result = herbalCollectMapper.insert(collect);
            if (result > 0) {
                return Result.success("收藏成功");
            } else {
                return Result.error("收藏失败");
            }
        } catch (Exception e) {
            return Result.error("收藏失败：" + e.getMessage());
        }
    }

    /**
     * 15. 取消收藏药材接口
     */
    @DeleteMapping("/{id}/collect")
    public Result<?> uncollectHerbal(@PathVariable Long id, HttpServletRequest request) {
        try {
            Long userId = 1L; // TODO: 实际应从JWT Token中获取

            QueryWrapper<HerbalCollect> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("user_id", userId);
            queryWrapper.eq("herbal_id", id);
            queryWrapper.eq("is_deleted", 0);

            HerbalCollect existing = herbalCollectMapper.selectOne(queryWrapper);
            if (existing == null) {
                return Result.error("未找到收藏记录");
            }

            existing.setIsDeleted(1);
            int result = herbalCollectMapper.updateById(existing);
            if (result > 0) {
                return Result.success("取消收藏成功");
            } else {
                return Result.error("取消收藏失败");
            }
        } catch (Exception e) {
            return Result.error("取消收藏失败：" + e.getMessage());
        }
    }

    /**
     * 16. 根据功效查询同类药材接口
     */
    @GetMapping("/by-efficacy")
    public Result<List<HerbalMedicine>> getHerbalsByEfficacy(
            @RequestParam String name) {
        try {
            QueryWrapper<HerbalMedicine> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("is_deleted", 0);
            queryWrapper.like("efficacy_summary", name);
            queryWrapper.last("LIMIT 10");
            List<HerbalMedicine> medicines = herbalMedicineService.list(queryWrapper);
            return Result.success(medicines);
        } catch (Exception e) {
            return Result.error("查询同类药材失败：" + e.getMessage());
        }
    }
}
