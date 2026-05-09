package com.example.medical.service;

import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class DataService {

    /**
     * 搜索患者
     */
    public List<Map<String, Object>> searchPatients(String keyword, Integer page, Integer size) {
        // TODO: 实现数据库查询
        // 这里返回模拟数据，实际应该从数据库查询
        List<Map<String, Object>> patients = new ArrayList<>();
        
        Map<String, Object> patient1 = new HashMap<>();
        patient1.put("id", 1);
        patient1.put("name", "张三");
        patient1.put("phone", "13800138001");
        patient1.put("age", 45);
        patient1.put("gender", "男");
        patients.add(patient1);
        
        Map<String, Object> patient2 = new HashMap<>();
        patient2.put("id", 2);
        patient2.put("name", "李四");
        patient2.put("phone", "13800138002");
        patient2.put("age", 32);
        patient2.put("gender", "女");
        patients.add(patient2);
        
        // 如果有搜索关键字，进行过滤
        if (keyword != null && !keyword.isEmpty()) {
            patients.removeIf(patient -> {
                String name = (String) patient.get("name");
                String phone = (String) patient.get("phone");
                return !name.contains(keyword) && !phone.contains(keyword);
            });
        }
        
        return patients;
    }

    /**
     * 搜索医生
     */
    public List<Map<String, Object>> searchDoctors(String keyword, String department, Integer page, Integer size) {
        // TODO: 实现数据库查询
        List<Map<String, Object>> doctors = new ArrayList<>();
        
        Map<String, Object> doctor1 = new HashMap<>();
        doctor1.put("id", 1);
        doctor1.put("name", "王医生");
        doctor1.put("phone", "13900139001");
        doctor1.put("department", "内科");
        doctor1.put("title", "主任医师");
        doctor1.put("specialty", "心血管疾病");
        doctors.add(doctor1);
        
        Map<String, Object> doctor2 = new HashMap<>();
        doctor2.put("id", 2);
        doctor2.put("name", "刘医生");
        doctor2.put("phone", "13900139002");
        doctor2.put("department", "外科");
        doctor2.put("title", "副主任医师");
        doctor2.put("specialty", "骨科");
        doctors.add(doctor2);
        
        // 过滤
        if (keyword != null && !keyword.isEmpty()) {
            doctors.removeIf(doctor -> {
                String name = (String) doctor.get("name");
                String dept = (String) doctor.get("department");
                return !name.contains(keyword) && (dept == null || !dept.contains(keyword));
            });
        }
        
        if (department != null && !department.isEmpty()) {
            doctors.removeIf(doctor -> {
                String dept = (String) doctor.get("department");
                return dept == null || !dept.equals(department);
            });
        }
        
        return doctors;
    }

    /**
     * 搜索医院
     */
    public List<Map<String, Object>> searchHospitals(String keyword, String city, Integer page, Integer size) {
        // TODO: 实现数据库查询
        List<Map<String, Object>> hospitals = new ArrayList<>();
        
        Map<String, Object> hospital1 = new HashMap<>();
        hospital1.put("id", 1);
        hospital1.put("name", "北京协和医院");
        hospital1.put("address", "北京市东城区帅府园1号");
        hospital1.put("level", "三甲");
        hospital1.put("city", "北京");
        hospitals.add(hospital1);
        
        Map<String, Object> hospital2 = new HashMap<>();
        hospital2.put("id", 2);
        hospital2.put("name", "上海瑞金医院");
        hospital2.put("address", "上海市黄浦区瑞金二路197号");
        hospital2.put("level", "三甲");
        hospital2.put("city", "上海");
        hospitals.add(hospital2);
        
        // 过滤
        if (keyword != null && !keyword.isEmpty()) {
            hospitals.removeIf(hospital -> {
                String name = (String) hospital.get("name");
                return !name.contains(keyword);
            });
        }
        
        if (city != null && !city.isEmpty()) {
            hospitals.removeIf(hospital -> {
                String hospitalCity = (String) hospital.get("city");
                return hospitalCity == null || !hospitalCity.equals(city);
            });
        }
        
        return hospitals;
    }

    /**
     * 获取科室列表
     */
    public List<Map<String, Object>> getDepartments(Long hospitalId) {
        // TODO: 实现数据库查询
        List<Map<String, Object>> departments = new ArrayList<>();
        
        String[] deptNames = {"内科", "外科", "儿科", "妇产科", "骨科", "眼科", "耳鼻喉科", "口腔科"};
        for (int i = 0; i < deptNames.length; i++) {
            Map<String, Object> dept = new HashMap<>();
            dept.put("id", i + 1);
            dept.put("name", deptNames[i]);
            departments.add(dept);
        }
        
        return departments;
    }
}
