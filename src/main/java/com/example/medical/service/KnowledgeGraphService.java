package com.example.medical.service;

import com.example.medical.dto.KnowledgeExploreRequest;
import com.example.medical.entity.KnowledgeNode;

import java.util.List;
import java.util.Map;

public interface KnowledgeGraphService {

    Map<String, Object> getGraph(Long centerId, Integer depth);

    KnowledgeNode getNodeById(Long id);

    List<KnowledgeNode> searchNodes(String keyword);

    Map<String, Object> findPath(Long sourceId, Long targetId);

    List<KnowledgeNode> listNodesByType(String type);

    Map<String, Object> explore(KnowledgeExploreRequest request);

    Map<String, Object> getStats();

    List<KnowledgeNode> getRelatedNodes(Long nodeId, String type);

    Map<String, Object> debugFindPath(Long sourceId, Long targetId);
}
