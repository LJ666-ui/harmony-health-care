package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@TableName("knowledge_edge")
public class KnowledgeEdge implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("source_node_id")
    private Long sourceId;

    @TableField("target_node_id")
    private Long targetId;

    @TableField("relation_type")
    private String relationType;

    @TableField("relation_name")
    private String relationName;

    private String description;

    private BigDecimal weight;

    @TableField(exist = false)
    private BigDecimal confidence;

    @TableField("evidence_source")
    private String evidenceSource;

    @TableField("create_time")
    private Date createTime;
}
