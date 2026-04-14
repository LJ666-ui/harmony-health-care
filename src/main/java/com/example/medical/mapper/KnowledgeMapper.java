package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.KnowledgeEdge;
import com.example.medical.entity.KnowledgeNode;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Mapper
public interface KnowledgeMapper extends BaseMapper<KnowledgeNode> {

    Logger log = LoggerFactory.getLogger(KnowledgeMapper.class);

    @Select("SELECT * FROM knowledge_node WHERE id = #{id}")
    KnowledgeNode selectNodeDetail(@Param("id") Long id);

    @Select({
            "<script>",
            "SELECT * FROM knowledge_node",
            "WHERE name LIKE CONCAT('%', #{keyword}, '%')",
            "   OR alias LIKE CONCAT('%', #{keyword}, '%')",
            "ORDER BY is_core_node DESC, id ASC",
            "</script>"
    })
    List<KnowledgeNode> searchNodes(@Param("keyword") String keyword);

    @Select("SELECT * FROM knowledge_node WHERE node_type = #{type} ORDER BY id ASC")
    List<KnowledgeNode> selectNodesByType(@Param("type") String type);

    @Select("SELECT * FROM knowledge_node ORDER BY id ASC")
    List<KnowledgeNode> selectAllNodes();

    @Select({
            "<script>",
            "SELECT * FROM knowledge_node WHERE id IN ",
            "<foreach collection='nodeIds' item='id' open='(' separator=',' close=')'>",
            "#{id}",
            "</foreach>",
            "ORDER BY id ASC",
            "</script>"
    })
    List<KnowledgeNode> selectNodesByIds(@Param("nodeIds") List<Long> nodeIds);

    @Results(value = {
            @org.apache.ibatis.annotations.Result(column = "id", property = "id"),
            @org.apache.ibatis.annotations.Result(column = "source_node_id", property = "sourceId"),
            @org.apache.ibatis.annotations.Result(column = "target_node_id", property = "targetId"),
            @org.apache.ibatis.annotations.Result(column = "relation_type", property = "relationType"),
            @org.apache.ibatis.annotations.Result(column = "relation_name", property = "relationName"),
            @org.apache.ibatis.annotations.Result(column = "description", property = "description"),
            @org.apache.ibatis.annotations.Result(column = "weight", property = "weight"),
            @org.apache.ibatis.annotations.Result(column = "evidence_source", property = "evidenceSource"),
            @org.apache.ibatis.annotations.Result(column = "create_time", property = "createTime")
    })
    @Select("SELECT * FROM knowledge_edge ORDER BY id ASC")
    List<KnowledgeEdge> selectAllEdges();

    @Results(value = {
            @org.apache.ibatis.annotations.Result(column = "id", property = "id"),
            @org.apache.ibatis.annotations.Result(column = "source_node_id", property = "sourceId"),
            @org.apache.ibatis.annotations.Result(column = "target_node_id", property = "targetId"),
            @org.apache.ibatis.annotations.Result(column = "relation_type", property = "relationType"),
            @org.apache.ibatis.annotations.Result(column = "relation_name", property = "relationName"),
            @org.apache.ibatis.annotations.Result(column = "description", property = "description"),
            @org.apache.ibatis.annotations.Result(column = "weight", property = "weight"),
            @org.apache.ibatis.annotations.Result(column = "evidence_source", property = "evidenceSource"),
            @org.apache.ibatis.annotations.Result(column = "create_time", property = "createTime")
    })
    @Select({
            "<script>",
            "SELECT * FROM knowledge_edge",
            "WHERE source_node_id IN ",
            "<foreach collection='nodeIds' item='id' open='(' separator=',' close=')'>",
            "#{id}",
            "</foreach>",
            "OR target_node_id IN ",
            "<foreach collection='nodeIds' item='id' open='(' separator=',' close=')'>",
            "#{id}",
            "</foreach>",
            "ORDER BY id ASC",
            "</script>"
    })
    List<KnowledgeEdge> selectAdjacentEdges(@Param("nodeIds") List<Long> nodeIds);

    @Results(value = {
            @org.apache.ibatis.annotations.Result(column = "id", property = "id"),
            @org.apache.ibatis.annotations.Result(column = "source_node_id", property = "sourceId"),
            @org.apache.ibatis.annotations.Result(column = "target_node_id", property = "targetId"),
            @org.apache.ibatis.annotations.Result(column = "relation_type", property = "relationType"),
            @org.apache.ibatis.annotations.Result(column = "relation_name", property = "relationName"),
            @org.apache.ibatis.annotations.Result(column = "description", property = "description"),
            @org.apache.ibatis.annotations.Result(column = "weight", property = "weight"),
            @org.apache.ibatis.annotations.Result(column = "evidence_source", property = "evidenceSource"),
            @org.apache.ibatis.annotations.Result(column = "create_time", property = "createTime")
    })
    @Select({
            "<script>",
            "SELECT * FROM knowledge_edge",
            "WHERE source_node_id IN ",
            "<foreach collection='nodeIds' item='id' open='(' separator=',' close=')'>",
            "#{id}",
            "</foreach>",
            "AND target_node_id IN ",
            "<foreach collection='nodeIds' item='id' open='(' separator=',' close=')'>",
            "#{id}",
            "</foreach>",
            "ORDER BY id ASC",
            "</script>"
    })
    List<KnowledgeEdge> selectEdgesWithinNodes(@Param("nodeIds") List<Long> nodeIds);

    @Select({
            "<script>",
            "SELECT DISTINCT n.*",
            "FROM knowledge_node n",
            "JOIN knowledge_edge e",
            "  ON n.id = e.source_node_id OR n.id = e.target_node_id",
            "WHERE (e.source_node_id = #{nodeId} OR e.target_node_id = #{nodeId})",
            "  AND n.id != #{nodeId}",
            "<if test='type != null and type != \"\"'>",
            "  AND n.node_type = #{type}",
            "</if>",
            "ORDER BY n.is_core_node DESC, n.id ASC",
            "</script>"
    })
    List<KnowledgeNode> selectRelatedNodes(@Param("nodeId") Long nodeId, @Param("type") String type);

    @Select("SELECT COUNT(*) FROM knowledge_node")
    Long countNodes();

    @Select("SELECT COUNT(*) FROM knowledge_edge")
    Long countEdges();

    @Select("SELECT COUNT(*) FROM knowledge_node WHERE is_core_node = 1")
    Long countCoreNodes();

    @Select("SELECT node_type AS itemType, COUNT(*) AS itemCount FROM knowledge_node GROUP BY node_type")
    List<Map<String, Object>> countNodesByType();

    @Select("SELECT relation_type AS itemType, COUNT(*) AS itemCount FROM knowledge_edge GROUP BY relation_type")
    List<Map<String, Object>> countEdgesByType();

    @Select({
            "SELECT COUNT(*)",
            "FROM knowledge_node n",
            "LEFT JOIN knowledge_edge e ON n.id = e.source_node_id OR n.id = e.target_node_id",
            "WHERE e.id IS NULL"
    })
    Long countIsolatedNodes();

    default KnowledgeNode getNodeById(Long id) {
        return selectNodeDetail(id);
    }

    default List<KnowledgeEdge> getGraph(Long centerId, Integer depth) {
        if (centerId == null || depth == null || depth < 0) {
            return Collections.emptyList();
        }
        Set<Long> visited = new LinkedHashSet<>();
        Set<Long> frontier = new LinkedHashSet<>();
        visited.add(centerId);
        frontier.add(centerId);

        for (int level = 0; level < depth && !frontier.isEmpty(); level++) {
            List<KnowledgeEdge> levelEdges = selectAdjacentEdges(new ArrayList<>(frontier));
            Set<Long> nextFrontier = new LinkedHashSet<>();
            for (KnowledgeEdge edge : levelEdges) {
                if (visited.contains(edge.getSourceId()) && !visited.contains(edge.getTargetId())) {
                    nextFrontier.add(edge.getTargetId());
                }
                if (visited.contains(edge.getTargetId()) && !visited.contains(edge.getSourceId())) {
                    nextFrontier.add(edge.getSourceId());
                }
                if (frontier.contains(edge.getSourceId()) && !visited.contains(edge.getTargetId())) {
                    nextFrontier.add(edge.getTargetId());
                }
                if (frontier.contains(edge.getTargetId()) && !visited.contains(edge.getSourceId())) {
                    nextFrontier.add(edge.getSourceId());
                }
            }
            visited.addAll(nextFrontier);
            frontier = nextFrontier;
        }

        if (visited.isEmpty()) {
            return Collections.emptyList();
        }
        return selectEdgesWithinNodes(new ArrayList<>(visited));
    }

    default List<KnowledgeEdge> findPath(Long sourceId, Long targetId) {
        log.info("[findPath] 查询路径: sourceId={}, targetId={}", sourceId, targetId);
        if (sourceId == null || targetId == null) {
            log.warn("[findPath] 起点或终点为空");
            return Collections.emptyList();
        }
        if (sourceId.equals(targetId)) {
            log.info("[findPath] 起点与终点相同");
            return Collections.emptyList();
        }

        List<KnowledgeEdge> allEdges = selectAllEdges();
        log.info("[findPath] 总边数: {}", allEdges.size());
        if (allEdges.isEmpty()) {
            log.warn("[findPath] knowledge_edge 表为空！请确认是否已导入数据");
            return Collections.emptyList();
        }

        Map<Long, List<KnowledgeEdge>> adjacency = buildAdjacency(allEdges);
        log.info("[findPath] 邻接表节点数: {}, sourceId={}的邻边数: {}", adjacency.size(), adjacency.getOrDefault(sourceId, Collections.emptyList()).size());

        Deque<Long> queue = new ArrayDeque<>();
        Set<Long> visited = new HashSet<>();
        Map<Long, KnowledgeEdge> parentEdge = new HashMap<>();

        queue.offer(sourceId);
        visited.add(sourceId);

        while (!queue.isEmpty()) {
            Long current = queue.poll();
            for (KnowledgeEdge edge : adjacency.getOrDefault(current, Collections.emptyList())) {
                Long next = getOppositeNode(edge, current);
                if (next == null || visited.contains(next)) {
                    continue;
                }
                visited.add(next);
                parentEdge.put(next, edge);
                if (next.equals(targetId)) {
                    log.info("[findPath] 找到目标节点 targetId={}, 已访问节点数: {}", targetId, visited.size());
                    List<KnowledgeEdge> path = buildPathEdges(parentEdge, sourceId, targetId);
                    log.info("[findPath] 路径长度: {}", path.size());
                    return path;
                }
                queue.offer(next);
            }
        }
        log.warn("[findPath] 未找到从 {} 到 {} 的可达路径，BFS共访问 {} 个节点", sourceId, targetId, visited.size());
        return Collections.emptyList();
    }

    default List<KnowledgeNode> getRelatedNodes(Long nodeId, String type) {
        return selectRelatedNodes(nodeId, type);
    }

    static Map<Long, List<KnowledgeEdge>> buildAdjacency(List<KnowledgeEdge> edges) {
        Map<Long, List<KnowledgeEdge>> adjacency = new LinkedHashMap<>();
        for (KnowledgeEdge edge : edges) {
            adjacency.computeIfAbsent(edge.getSourceId(), key -> new ArrayList<>()).add(edge);
            adjacency.computeIfAbsent(edge.getTargetId(), key -> new ArrayList<>()).add(edge);
        }
        return adjacency;
    }

    static Long getOppositeNode(KnowledgeEdge edge, Long current) {
        if (edge == null || current == null) {
            return null;
        }
        if (current.equals(edge.getSourceId())) {
            return edge.getTargetId();
        }
        if (current.equals(edge.getTargetId())) {
            return edge.getSourceId();
        }
        return null;
    }

    static List<KnowledgeEdge> buildPathEdges(Map<Long, KnowledgeEdge> parentEdge, Long sourceId, Long targetId) {
        List<KnowledgeEdge> path = new ArrayList<>();
        Long cursor = targetId;
        while (!cursor.equals(sourceId)) {
            KnowledgeEdge edge = parentEdge.get(cursor);
            if (edge == null) {
                log.warn("[buildPathEdges] 回溯断裂：cursor={} 没有父边，sourceId={}, targetId={}", cursor, sourceId, targetId);
                return Collections.emptyList();
            }
            path.add(edge);
            if (cursor.equals(edge.getSourceId())) {
                cursor = edge.getTargetId();
            } else if (cursor.equals(edge.getTargetId())) {
                cursor = edge.getSourceId();
            } else {
                log.warn("[buildPathEdges] 边与当前节点不匹配：cursor={}, edge.source={}, edge.target={}", cursor, edge.getSourceId(), edge.getTargetId());
                return Collections.emptyList();
            }
        }
        Collections.reverse(path);
        return path;
    }
}
