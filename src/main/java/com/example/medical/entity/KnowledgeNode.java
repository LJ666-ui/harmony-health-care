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
@TableName("knowledge_node")
public class KnowledgeNode implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("node_type")
    private String nodeType;

    private String name;

    private String alias;

    private String description;

    @TableField("properties_json")
    private String propertiesJson;

    @TableField("image_url")
    private String imageUrl;

    @TableField("is_core_node")
    private Integer isCoreNode;

    @TableField("source_reference")
    private String sourceReference;

    @TableField("confidence_score")
    private BigDecimal confidenceScore;

    @TableField("view_count")
    private Integer viewCount;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;
}
