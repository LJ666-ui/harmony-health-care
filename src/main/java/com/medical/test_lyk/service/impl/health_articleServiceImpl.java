package com.medical.test_lyk.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.medical.test_lyk.entity.health_article;
import com.medical.test_lyk.mapper.health_articleMapper;
import com.medical.test_lyk.service.health_articleService;
import org.springframework.stereotype.Service;

@Service
public class health_articleServiceImpl extends ServiceImpl<health_articleMapper, health_article>
        implements health_articleService {
}
