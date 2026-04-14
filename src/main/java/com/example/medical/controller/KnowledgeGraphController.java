package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.dto.KnowledgeExploreRequest;
import com.example.medical.entity.KnowledgeNode;
import com.example.medical.service.KnowledgeGraphService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/knowledge")
@CrossOrigin
public class KnowledgeGraphController {

    private static final Logger log = LoggerFactory.getLogger(KnowledgeGraphController.class);

    @Autowired
    private KnowledgeGraphService knowledgeGraphService;

    @GetMapping("/graph")
    public Result<Map<String, Object>> graph(@RequestParam Long centerId,
                                             @RequestParam(defaultValue = "2") Integer depth) {
        try {
            return Result.success(knowledgeGraphService.getGraph(centerId, depth));
        } catch (Exception e) {
            return Result.error("获取知识图谱失败：" + e.getMessage());
        }
    }

    @GetMapping("/node/{id}")
    public Result<KnowledgeNode> getNode(@PathVariable Long id) {
        try {
            KnowledgeNode node = knowledgeGraphService.getNodeById(id);
            if (node == null) {
                return Result.error("节点不存在");
            }
            return Result.success(node);
        } catch (Exception e) {
            return Result.error("获取节点详情失败：" + e.getMessage());
        }
    }

    @GetMapping("/search")
    public Result<List<KnowledgeNode>> search(@RequestParam String keyword) {
        try {
            return Result.success(knowledgeGraphService.searchNodes(keyword));
        } catch (Exception e) {
            return Result.error("搜索节点失败：" + e.getMessage());
        }
    }

    @GetMapping("/path")
    public Result<Map<String, Object>> path(@RequestParam("from") Long from,
                                            @RequestParam("to") Long to) {
        try {
            return Result.success(knowledgeGraphService.findPath(from, to));
        } catch (Exception e) {
            return Result.error("查询最短路径失败：" + e.getMessage());
        }
    }

    @GetMapping("/nodes")
    public Result<List<KnowledgeNode>> nodesByType(@RequestParam(required = false) String type) {
        try {
            return Result.success(knowledgeGraphService.listNodesByType(type));
        } catch (Exception e) {
            return Result.error("按类型查询节点失败：" + e.getMessage());
        }
    }

    @PostMapping("/explore")
    public Result<Map<String, Object>> explore(@RequestBody(required = false) KnowledgeExploreRequest request) {
        log.info("[explore] 收到探索请求: query={}, centerId={}, depth={}",
                request != null ? request.getQuery() : null,
                request != null ? request.getCenterId() : null,
                request != null ? request.getDepth() : null);
        try {
            return Result.success(knowledgeGraphService.explore(request));
        } catch (Exception e) {
            log.error("[explore] AI探索失败", e);
            return Result.error("AI探索失败：" + e.getMessage());
        }
    }

    @GetMapping("/stats")
    public Result<Map<String, Object>> stats() {
        try {
            return Result.success(knowledgeGraphService.getStats());
        } catch (Exception e) {
            return Result.error("获取图谱统计失败：" + e.getMessage());
        }
    }

    @GetMapping("/related")
    public Result<List<KnowledgeNode>> related(@RequestParam("id") Long id,
                                               @RequestParam(required = false) String type) {
        try {
            return Result.success(knowledgeGraphService.getRelatedNodes(id, type));
        } catch (Exception e) {
            return Result.error("获取关联推荐失败：" + e.getMessage());
        }
    }

    @GetMapping("/debug/edges")
    public Result<Map<String, Object>> debugEdges(@RequestParam(required = false) Long sourceId,
                                                  @RequestParam(required = false) Long targetId) {
        try {
            Map<String, Object> debug = knowledgeGraphService.debugFindPath(sourceId, targetId);
            return Result.success(debug);
        } catch (Exception e) {
            log.error("[debug/edges] 诊断失败", e);
            return Result.error("诊断失败：" + e.getMessage());
        }
    }
}
