package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.HealthArticle;
import com.example.medical.mapper.HealthArticleMapper;
import com.example.medical.service.HealthArticleService;
import org.springframework.stereotype.Service;

@Service
public class HealthArticleServiceImpl extends ServiceImpl<HealthArticleMapper, HealthArticle> implements HealthArticleService {
}