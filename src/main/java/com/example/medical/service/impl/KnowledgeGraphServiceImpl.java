package com.example.medical.service.impl;

import com.example.medical.dto.KnowledgeExploreRequest;
import com.example.medical.entity.KnowledgeEdge;
import com.example.medical.entity.KnowledgeNode;
import com.example.medical.mapper.KnowledgeMapper;
import com.example.medical.service.KnowledgeGraphService;
import com.example.medical.utils.AIClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Deque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class KnowledgeGraphServiceImpl implements KnowledgeGraphService {

    private static final Logger log = LoggerFactory.getLogger(KnowledgeGraphServiceImpl.class);
    private static final int DEFAULT_DEPTH = 2;
    private static final int MAX_DEPTH = 3;
    private static final double CENTER_X = 500D;
    private static final double CENTER_Y = 360D;

    @Autowired
    private KnowledgeMapper knowledgeMapper;

    @Autowired(required = false)
    private AIClient aiClient;

    @Override
    public Map<String, Object> getGraph(Long centerId, Integer depth) {
        Long actualCenterId = centerId == null ? 1L : centerId;
        int actualDepth = normalizeDepth(depth);
        KnowledgeNode centerNode = knowledgeMapper.getNodeById(actualCenterId);
        if (centerNode == null) {
            return emptyGraph(actualCenterId, actualDepth);
        }

        List<KnowledgeEdge> subgraphEdges = knowledgeMapper.getGraph(actualCenterId, actualDepth);
        Map<Long, Integer> levelMap = calculateLevels(actualCenterId, subgraphEdges, actualDepth);
        Set<Long> nodeIds = new LinkedHashSet<>(levelMap.keySet());
        nodeIds.add(actualCenterId);

        List<KnowledgeNode> nodes = nodeIds.isEmpty()
                ? Collections.singletonList(centerNode)
                : knowledgeMapper.selectNodesByIds(new ArrayList<>(nodeIds));

        Map<Long, KnowledgeNode> nodeMap = nodes.stream()
                .collect(Collectors.toMap(KnowledgeNode::getId, node -> node, (a, b) -> a, LinkedHashMap::new));
        nodeMap.putIfAbsent(centerNode.getId(), centerNode);

        List<Map<String, Object>> graphNodes = buildGraphNodes(nodeMap.values(), levelMap, actualCenterId);
        List<Map<String, Object>> graphEdges = buildGraphEdges(subgraphEdges, levelMap);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("centerId", actualCenterId);
        result.put("depth", actualDepth);
        result.put("nodeCount", graphNodes.size());
        result.put("edgeCount", graphEdges.size());
        result.put("nodes", graphNodes);
        result.put("edges", graphEdges);
        return result;
    }

    @Override
    public KnowledgeNode getNodeById(Long id) {
        return knowledgeMapper.getNodeById(id);
    }

    @Override
    public List<KnowledgeNode> searchNodes(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return knowledgeMapper.selectAllNodes().stream()
                    .sorted(Comparator.comparing(KnowledgeNode::getId))
                    .limit(20)
                    .collect(Collectors.toList());
        }
        return knowledgeMapper.searchNodes(keyword.trim());
    }

    @Override
    public Map<String, Object> findPath(Long sourceId, Long targetId) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (sourceId == null || targetId == null) {
            result.put("nodes", Collections.emptyList());
            result.put("edges", Collections.emptyList());
            result.put("pathLength", 0);
            result.put("message", "起点和终点不能为空");
            return result;
        }

        if (sourceId.equals(targetId)) {
            KnowledgeNode node = knowledgeMapper.getNodeById(sourceId);
            result.put("nodes", node == null ? Collections.emptyList() : Collections.singletonList(node));
            result.put("edges", Collections.emptyList());
            result.put("pathLength", 0);
            result.put("message", "起点和终点相同");
            return result;
        }

        List<KnowledgeEdge> pathEdges = knowledgeMapper.findPath(sourceId, targetId);
        if (pathEdges.isEmpty()) {
            result.put("nodes", Collections.emptyList());
            result.put("edges", Collections.emptyList());
            result.put("pathLength", 0);
            result.put("message", "未找到可达路径");
            return result;
        }

        Set<Long> pathNodeIds = new LinkedHashSet<>();
        pathNodeIds.add(sourceId);
        Long current = sourceId;
        for (KnowledgeEdge edge : pathEdges) {
            pathNodeIds.add(edge.getSourceId());
            pathNodeIds.add(edge.getTargetId());
            current = current.equals(edge.getSourceId()) ? edge.getTargetId() : edge.getSourceId();
            pathNodeIds.add(current);
        }

        List<KnowledgeNode> pathNodes = knowledgeMapper.selectNodesByIds(new ArrayList<>(pathNodeIds));
        result.put("nodes", pathNodes);
        result.put("edges", buildGraphEdges(pathEdges, calculateLevels(sourceId, pathEdges, pathEdges.size())));
        result.put("pathLength", pathEdges.size());
        result.put("message", "success");
        return result;
    }

    @Override
    public List<KnowledgeNode> listNodesByType(String type) {
        if (type == null || type.trim().isEmpty()) {
            return knowledgeMapper.selectAllNodes();
        }
        return knowledgeMapper.selectNodesByType(type.trim().toUpperCase(Locale.ROOT));
    }

    @Override
    public Map<String, Object> explore(KnowledgeExploreRequest request) {
        log.info("[explore] 开始处理探索请求: {}", request);
        KnowledgeExploreRequest actualRequest = request == null ? new KnowledgeExploreRequest() : request;
        Integer depth = actualRequest.getDepth() == null ? DEFAULT_DEPTH : actualRequest.getDepth();
        List<KnowledgeNode> matchedNodes = resolveNodesFromQuery(actualRequest.getQuery());
        log.info("[explore] 匹配到节点数: {}", matchedNodes.size());

        KnowledgeNode centerNode = null;
        if (actualRequest.getCenterId() != null) {
            centerNode = knowledgeMapper.getNodeById(actualRequest.getCenterId());
        }
        if (centerNode == null && !matchedNodes.isEmpty()) {
            centerNode = pickBestCenter(matchedNodes);
        }

        if (centerNode == null) {
            log.warn("[explore] 未找到中心节点, query={}", actualRequest.getQuery());
            Map<String, Object> fallback = emptyGraph(null, normalizeDepth(depth));
            fallback.put("keywords", Collections.emptyList());
            fallback.put("interpretation", "未识别到明确的图谱节点，请尝试输入疾病、症状或药材名称，例如高血压头晕失眠怎么调理。");
            return fallback;
        }

        log.info("[explore] 中心节点: id={}, name={}, type={}", centerNode.getId(), centerNode.getName(), centerNode.getNodeType());
        Map<String, Object> graph = getGraph(centerNode.getId(), depth);
        List<String> keywords = matchedNodes.stream()
                .map(KnowledgeNode::getName)
                .distinct()
                .collect(Collectors.toList());

        Map<String, Object> result = new LinkedHashMap<>(graph);
        result.put("centerNode", centerNode);
        result.put("keywords", keywords);
        result.put("interpretation", buildExploreInterpretation(actualRequest.getQuery(), centerNode, result, keywords));
        return result;
    }

    @Override
    public Map<String, Object> getStats() {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("totalNodes", knowledgeMapper.countNodes());
        result.put("totalEdges", knowledgeMapper.countEdges());
        result.put("coreNodes", knowledgeMapper.countCoreNodes());
        result.put("isolatedNodes", knowledgeMapper.countIsolatedNodes());
        result.put("nodeTypeCounts", convertCountList(knowledgeMapper.countNodesByType()));
        result.put("relationTypeCounts", convertCountList(knowledgeMapper.countEdgesByType()));
        return result;
    }

    @Override
    public List<KnowledgeNode> getRelatedNodes(Long nodeId, String type) {
        if (nodeId == null) {
            return Collections.emptyList();
        }
        String nodeType = type == null || type.trim().isEmpty() ? null : type.trim().toUpperCase(Locale.ROOT);
        return knowledgeMapper.getRelatedNodes(nodeId, nodeType);
    }

    private Map<String, Object> emptyGraph(Long centerId, Integer depth) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("centerId", centerId);
        result.put("depth", depth);
        result.put("nodeCount", 0);
        result.put("edgeCount", 0);
        result.put("nodes", Collections.emptyList());
        result.put("edges", Collections.emptyList());
        return result;
    }

    private int normalizeDepth(Integer depth) {
        if (depth == null || depth < 1) {
            return DEFAULT_DEPTH;
        }
        return Math.min(depth, MAX_DEPTH);
    }

    /**
     * BFS 用于计算每个节点距离中心节点的层级，后续同心圆布局直接使用这个层级结果。
     */
    private Map<Long, Integer> calculateLevels(Long centerId, List<KnowledgeEdge> edges, int maxDepth) {
        Map<Long, Integer> levelMap = new LinkedHashMap<>();
        levelMap.put(centerId, 0);

        Map<Long, List<KnowledgeEdge>> adjacency = KnowledgeMapper.buildAdjacency(edges);
        Deque<Long> queue = new ArrayDeque<>();
        queue.offer(centerId);

        while (!queue.isEmpty()) {
            Long current = queue.poll();
            Integer currentLevel = levelMap.get(current);
            if (currentLevel == null || currentLevel >= maxDepth) {
                continue;
            }
            for (KnowledgeEdge edge : adjacency.getOrDefault(current, Collections.emptyList())) {
                Long next = current.equals(edge.getSourceId()) ? edge.getTargetId() : edge.getSourceId();
                if (!levelMap.containsKey(next)) {
                    levelMap.put(next, currentLevel + 1);
                    queue.offer(next);
                }
            }
        }
        return levelMap;
    }

    private List<Map<String, Object>> buildGraphNodes(Collection<KnowledgeNode> nodes,
                                                      Map<Long, Integer> levelMap,
                                                      Long centerId) {
        Map<Integer, List<KnowledgeNode>> grouped = new LinkedHashMap<>();
        for (KnowledgeNode node : nodes) {
            int level = levelMap.getOrDefault(node.getId(), node.getId().equals(centerId) ? 0 : 1);
            grouped.computeIfAbsent(level, key -> new ArrayList<>()).add(node);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Integer, List<KnowledgeNode>> entry : grouped.entrySet()) {
            int level = entry.getKey();
            List<KnowledgeNode> levelNodes = entry.getValue().stream()
                    .sorted(Comparator.comparing(KnowledgeNode::getId))
                    .collect(Collectors.toList());

            for (int i = 0; i < levelNodes.size(); i++) {
                KnowledgeNode node = levelNodes.get(i);
                Map<String, Object> nodeMap = new LinkedHashMap<>();
                nodeMap.put("id", node.getId());
                nodeMap.put("label", node.getName());
                nodeMap.put("name", node.getName());
                nodeMap.put("type", node.getNodeType());
                nodeMap.put("alias", node.getAlias());
                nodeMap.put("description", node.getDescription());
                nodeMap.put("isCoreNode", node.getIsCoreNode());
                nodeMap.put("color", getColor(node.getNodeType()));
                nodeMap.put("radius", getRadius(node, level));
                nodeMap.put("depthLevel", level);
                nodeMap.put("propertiesJson", node.getPropertiesJson());

                double[] coordinates = calculateCoordinates(node.getId(), level, i, levelNodes.size());
                nodeMap.put("x", coordinates[0]);
                nodeMap.put("y", coordinates[1]);
                result.add(nodeMap);
            }
        }
        return result;
    }

    private double[] calculateCoordinates(Long nodeId, int level, int index, int total) {
        if (level == 0) {
            return new double[]{CENTER_X, CENTER_Y};
        }
        double orbitRadius = 150D * level;
        double angleStep = (Math.PI * 2D) / Math.max(total, 1);
        double angle = index * angleStep;
        Random random = new Random(nodeId * 31 + level);
        double offsetX = random.nextDouble() * 30D - 15D;
        double offsetY = random.nextDouble() * 30D - 15D;
        double x = CENTER_X + orbitRadius * Math.cos(angle) + offsetX;
        double y = CENTER_Y + orbitRadius * Math.sin(angle) + offsetY;
        return new double[]{
                round(x),
                round(y)
        };
    }

    private List<Map<String, Object>> buildGraphEdges(List<KnowledgeEdge> edges, Map<Long, Integer> levelMap) {
        return edges.stream()
                .sorted(Comparator.comparing(KnowledgeEdge::getId))
                .map(edge -> {
                    Map<String, Object> edgeMap = new LinkedHashMap<>();
                    edgeMap.put("id", edge.getId());
                    edgeMap.put("source", edge.getSourceId());
                    edgeMap.put("target", edge.getTargetId());
                    edgeMap.put("relationType", edge.getRelationType());
                    edgeMap.put("relationName", edge.getRelationName());
                    edgeMap.put("label", edge.getRelationName() == null ? edge.getRelationType() : edge.getRelationName());
                    edgeMap.put("weight", safeWeight(edge.getWeight()));
                    edgeMap.put("confidence", safeWeight(edge.getWeight()));
                    edgeMap.put("sourceLevel", levelMap.get(edge.getSourceId()));
                    edgeMap.put("targetLevel", levelMap.get(edge.getTargetId()));
                    return edgeMap;
                })
                .collect(Collectors.toList());
    }

    private List<KnowledgeNode> resolveNodesFromQuery(String query) {
        if (query == null || query.trim().isEmpty()) {
            return Collections.emptyList();
        }

        List<KnowledgeNode> allNodes = knowledgeMapper.selectAllNodes();
        List<KnowledgeNode> matched = new ArrayList<>();
        String normalizedQuery = query.replace("，", ",")
                .replace("。", ",")
                .replace("；", ",")
                .replace("、", ",")
                .replace("？", ",")
                .replace(" ", "");

        for (KnowledgeNode node : allNodes) {
            if (normalizedQuery.contains(node.getName())) {
                matched.add(node);
                continue;
            }
            if (node.getAlias() != null && !node.getAlias().trim().isEmpty()) {
                String[] aliases = node.getAlias().split(",");
                for (String alias : aliases) {
                    if (!alias.trim().isEmpty() && normalizedQuery.contains(alias.trim())) {
                        matched.add(node);
                        break;
                    }
                }
            }
        }

        if (matched.isEmpty()) {
            matched.addAll(knowledgeMapper.searchNodes(query.trim()));
        }

        return matched.stream()
                .distinct()
                .sorted(Comparator.comparingInt(this::nodePriority)
                        .thenComparing(KnowledgeNode::getId))
                .collect(Collectors.toList());
    }

    private KnowledgeNode pickBestCenter(List<KnowledgeNode> candidates) {
        return candidates.stream()
                .sorted(Comparator.comparingInt(this::nodePriority)
                        .thenComparing(node -> node.getIsCoreNode() == null ? 0 : -node.getIsCoreNode())
                        .thenComparing(KnowledgeNode::getId))
                .findFirst()
                .orElse(null);
    }

    private int nodePriority(KnowledgeNode node) {
        if (node == null || node.getNodeType() == null) {
            return 9;
        }
        if ("DISEASE".equals(node.getNodeType())) {
            return 1;
        }
        if ("SYMPTOM".equals(node.getNodeType())) {
            return 2;
        }
        if ("PRESCRIPTION".equals(node.getNodeType())) {
            return 3;
        }
        if ("HERBAL".equals(node.getNodeType())) {
            return 4;
        }
        if ("THERAPY".equals(node.getNodeType())) {
            return 5;
        }
        return 9;
    }

    private String buildExploreInterpretation(String query,
                                              KnowledgeNode centerNode,
                                              Map<String, Object> graph,
                                              List<String> keywords) {
        String aiSummary = tryGenerateAiSummary(query, centerNode.getName(), graph);
        if (aiSummary != null && !aiSummary.trim().isEmpty()) {
            return aiSummary;
        }

        int nodeCount = ((List<?>) graph.getOrDefault("nodes", Collections.emptyList())).size();
        int edgeCount = ((List<?>) graph.getOrDefault("edges", Collections.emptyList())).size();
        String keywordText = keywords.isEmpty() ? centerNode.getName() : String.join("、", keywords);
        return "已围绕“" + centerNode.getName() + "”展开知识图谱探索，识别关键词为“" + keywordText
                + "”，当前子图包含 " + nodeCount + " 个节点、" + edgeCount
                + " 条关系，可继续查看相关症状、药材、方剂和疗法之间的关联。";
    }

    private String tryGenerateAiSummary(String query, String centerName, Map<String, Object> graph) {
        if (aiClient == null || query == null || query.trim().isEmpty()) {
            return null;
        }
        try {
            int nodeCount = ((List<?>) graph.getOrDefault("nodes", Collections.emptyList())).size();
            int edgeCount = ((List<?>) graph.getOrDefault("edges", Collections.emptyList())).size();
            String prompt = "你是医学知识图谱助手。"
                    + "用户问题：" + query + "。"
                    + "图谱中心节点：" + centerName + "。"
                    + "当前子图包含 " + nodeCount + " 个节点，" + edgeCount + " 条关系。"
                    + "请用 80 字以内给出简洁解读，不要编造未出现的疾病。";
            return aiClient.chat(prompt);
        } catch (Exception e) {
            return null;
        }
    }

    private Map<String, Long> convertCountList(List<Map<String, Object>> rows) {
        Map<String, Long> result = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            Object itemType = row.get("itemType");
            Object itemCount = row.get("itemCount");
            if (itemType != null && itemCount != null) {
                result.put(String.valueOf(itemType), Long.parseLong(String.valueOf(itemCount)));
            }
        }
        return result;
    }

    private String getColor(String nodeType) {
        if ("DISEASE".equals(nodeType)) {
            return "#E74C3C";
        }
        if ("SYMPTOM".equals(nodeType)) {
            return "#F39C12";
        }
        if ("HERBAL".equals(nodeType)) {
            return "#3498DB";
        }
        if ("PRESCRIPTION".equals(nodeType)) {
            return "#27AE60";
        }
        if ("THERAPY".equals(nodeType)) {
            return "#8E44AD";
        }
        return "#7F8C8D";
    }

    private int getRadius(KnowledgeNode node, int level) {
        if (level == 0) {
            return 36;
        }
        if (node.getIsCoreNode() != null && node.getIsCoreNode() == 1) {
            return 30;
        }
        return 24;
    }

    private double round(double value) {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

    private double safeWeight(BigDecimal weight) {
        if (weight == null) {
            return 1D;
        }
        return weight.setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

    @Override
    public Map<String, Object> debugFindPath(Long sourceId, Long targetId) {
        Map<String, Object> result = new LinkedHashMap<>();
        List<KnowledgeEdge> allEdges = knowledgeMapper.selectAllEdges();
        result.put("totalEdges", allEdges.size());

        List<Map<String, Object>> edgeSamples = new ArrayList<>();
        for (int i = 0; i < Math.min(5, allEdges.size()); i++) {
            KnowledgeEdge e = allEdges.get(i);
            Map<String, Object> sample = new LinkedHashMap<>();
            sample.put("id", e.getId());
            sample.put("sourceId", e.getSourceId());
            sample.put("targetId", e.getTargetId());
            sample.put("relationType", e.getRelationType());
            edgeSamples.add(sample);
        }
        result.put("edgeSamples", edgeSamples);

        if (sourceId != null && targetId != null) {
            Map<Long, List<KnowledgeEdge>> adjacency = KnowledgeMapper.buildAdjacency(allEdges);
            result.put("adjacencyNodeCount", adjacency.size());
            result.put("sourceAdjacencySize", adjacency.getOrDefault(sourceId, Collections.emptyList()).size());

            List<Map<String, Object>> sourceEdgesRaw = new ArrayList<>();
            for (KnowledgeEdge e : adjacency.getOrDefault(sourceId, Collections.emptyList())) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", e.getId());
                m.put("sourceId", e.getSourceId());
                m.put("targetId", e.getTargetId());
                m.put("oppositeFrom" + sourceId, KnowledgeMapper.getOppositeNode(e, sourceId));
                sourceEdgesRaw.add(m);
            }
            result.put("sourceEdgesDetail", sourceEdgesRaw);

            Map<String, Object> pathResult = this.findPath(sourceId, targetId);
            result.put("pathResult", pathResult);
        }
        return result;
    }
}
