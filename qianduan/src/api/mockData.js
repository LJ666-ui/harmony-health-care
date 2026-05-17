export const mockData = {
  '/user/login': (data) => ({
    code: 200,
    msg: 'success',
    data: {
      token: 'mock-token-12345',
      userId: 1,
      username: data.username,
      userType: 'ADMIN'
    }
  }),
  '/user/register': (data) => ({
    code: 200,
    msg: '注册成功',
    data: null
  }),
  '/user/info': (params) => ({
    code: 200,
    msg: 'success',
    data: {
      id: 1,
      username: 'admin',
      name: '管理员',
      role: 'ADMIN',
      email: 'admin@example.com',
      phone: '13800138000'
    }
  }),
  '/healthArticle/page': (params) => ({
    code: 200,
    msg: 'success',
    data: {
      list: [
        { id: 1, title: '健康饮食指南', summary: '介绍健康饮食的基本原则', categoryName: '健康科普', viewCount: 1234, createTime: '2024-01-15' },
        { id: 2, title: '运动健身建议', summary: '适合不同年龄段的运动方案', categoryName: '运动健康', viewCount: 856, createTime: '2024-01-14' },
        { id: 3, title: '心理健康呵护', summary: '保持心理健康的方法', categoryName: '心理健康', viewCount: 623, createTime: '2024-01-13' }
      ],
      total: 100
    }
  }),
  '/healthArticle/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, title: '健康饮食指南', summary: '介绍健康饮食的基本原则', categoryName: '健康科普' },
      { id: 2, title: '运动健身建议', summary: '适合不同年龄段的运动方案', categoryName: '运动健康' }
    ]
  }),
  '/healthArticle/categories/parent': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, categoryName: '健康科普', description: '健康知识科普' },
      { id: 2, categoryName: '运动健康', description: '运动与健康' },
      { id: 3, categoryName: '心理健康', description: '心理健康知识' }
    ]
  }),
  '/hospital/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, hospitalName: '第一人民医院', address: '北京市朝阳区', level: '三级甲等', phone: '010-12345678' },
      { id: 2, hospitalName: '中医院', address: '北京市西城区', level: '三级甲等', phone: '010-87654321' },
      { id: 3, hospitalName: '妇幼保健院', address: '北京市海淀区', level: '三级甲等', phone: '010-11223344' }
    ]
  }),
  '/hospital/page': (params) => ({
    code: 200,
    msg: 'success',
    data: {
      list: [
        { id: 1, hospitalName: '第一人民医院', address: '北京市朝阳区', level: '三级甲等', phone: '010-12345678' },
        { id: 2, hospitalName: '中医院', address: '北京市西城区', level: '三级甲等', phone: '010-87654321' }
      ],
      total: 10
    }
  }),
  '/hospital/department/all': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, deptName: '内科', description: '内科科室' },
      { id: 2, deptName: '外科', description: '外科科室' },
      { id: 3, deptName: '妇产科', description: '妇产科' },
      { id: 4, deptName: '儿科', description: '儿科' },
      { id: 5, deptName: '急诊科', description: '急诊科' }
    ]
  }),
  '/doctor/list': (params) => ({
    code: 200,
    msg: 'success',
    data: {
      list: [
        { id: 1, name: '张三', hospitalName: '第一人民医院', departmentName: '内科', title: '主任医师', specialty: '心血管疾病', phone: '13800138001', score: 4.8, status: 1 },
        { id: 2, name: '李四', hospitalName: '中医院', departmentName: '外科', title: '副主任医师', specialty: '骨科', phone: '13800138002', score: 4.6, status: 1 },
        { id: 3, name: '王五', hospitalName: '妇幼保健院', departmentName: '妇产科', title: '主任医师', specialty: '妇科', phone: '13800138003', score: 4.9, status: 1 }
      ],
      total: 50
    }
  }),
  '/appointment/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, userName: '患者A', doctorName: '张三', hospitalName: '第一人民医院', departmentName: '内科', scheduleDate: '2024-01-20', schedulePeriod: 0, appointmentNo: 'APPT20240120001', fee: 100, status: 0, createTime: '2024-01-15 10:00' },
      { id: 2, userName: '患者B', doctorName: '李四', hospitalName: '中医院', departmentName: '外科', scheduleDate: '2024-01-21', schedulePeriod: 1, appointmentNo: 'APPT20240121001', fee: 150, status: 1, createTime: '2024-01-16 14:00' }
    ]
  }),
  '/transferApply/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, userName: '患者C', fromHospital: '社区医院', toHospital: '第一人民医院', applyReason: '病情需要进一步治疗', applyTime: '2024-01-17 09:00', status: 0 },
      { id: 2, userName: '患者D', fromHospital: '第二医院', toHospital: '中医院', applyReason: '需要中医调理', applyTime: '2024-01-18 11:00', status: 1 }
    ]
  }),
  '/medicine/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, medicineName: '感冒药', specification: '10片/盒', price: 15.00, manufacturer: 'XX制药', stock: 100 },
      { id: 2, medicineName: '抗生素', specification: '20粒/盒', price: 35.00, manufacturer: 'YY制药', stock: 50 },
      { id: 3, medicineName: '维生素C', specification: '100片/瓶', price: 20.00, manufacturer: 'ZZ制药', stock: 200 }
    ]
  }),
  '/herbal/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, herbalName: '人参', effect: '补气养血', usage: '煎服', price: 200.00 },
      { id: 2, herbalName: '黄芪', effect: '益气健脾', usage: '煎服', price: 50.00 },
      { id: 3, herbalName: '当归', effect: '补血活血', usage: '煎服', price: 80.00 }
    ]
  }),
  '/rehabPlan/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, disease: '高血压', planName: '高血压康复计划', duration: '12周', intensity: '中等', content: '饮食控制、适度运动、定期监测' },
      { id: 2, disease: '糖尿病', planName: '糖尿病康复计划', duration: '16周', intensity: '中等', content: '饮食管理、血糖监测、运动锻炼' },
      { id: 3, disease: '术后康复', planName: '术后康复计划', duration: '8周', intensity: '低', content: '康复训练、伤口护理、营养支持' }
    ]
  }),
  '/risk-assess/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, userId: 1, assessType: '心血管风险', score: 75, level: '高风险', assessTime: '2024-01-15', suggestions: '建议定期体检，控制血压' },
      { id: 2, userId: 2, assessType: '糖尿病风险', score: 45, level: '中风险', assessTime: '2024-01-14', suggestions: '注意饮食，加强运动' }
    ]
  }),
  '/medical-record/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, patientName: '患者A', departmentName: '内科', diagnosis: '高血压', recordTime: '2024-01-10', doctorName: '张三' },
      { id: 2, patientName: '患者B', departmentName: '外科', diagnosis: '骨折', recordTime: '2024-01-08', doctorName: '李四' }
    ]
  }),
  '/medicalRecord/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, userName: '患者A', hospitalName: '第一人民医院', doctorName: '张三', diagnosis: '高血压', recordTime: '2024-01-10', isDesensitized: 0 },
      { id: 2, userName: '患者B', hospitalName: '中医院', doctorName: '李四', diagnosis: '骨折', recordTime: '2024-01-08', isDesensitized: 1 },
      { id: 3, userName: '患者C', hospitalName: '妇幼保健院', doctorName: '王五', diagnosis: '感冒', recordTime: '2024-01-12', isDesensitized: 0 }
    ]
  }),
  '/health-record/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, userId: 1, height: 175, weight: 70, bloodPressure: '120/80', bloodSugar: 5.2, recordTime: '2024-01-15' },
      { id: 2, userId: 2, height: 165, weight: 55, bloodPressure: '110/75', bloodSugar: 4.8, recordTime: '2024-01-14' }
    ]
  }),
  '/checkup-report/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, userId: 1, reportName: '年度体检报告', reportDate: '2024-01-01', status: '已完成' },
      { id: 2, userId: 2, reportName: '专项检查报告', reportDate: '2024-01-10', status: '已完成' }
    ]
  }),
  '/disease/list': (params) => ({
    code: 200,
    msg: 'success',
    data: [
      { id: 1, diseaseName: '高血压', category: '心血管疾病', description: '血压持续升高' },
      { id: 2, diseaseName: '糖尿病', category: '代谢疾病', description: '血糖代谢异常' },
      { id: 3, diseaseName: '感冒', category: '呼吸道疾病', description: '上呼吸道感染' }
    ]
  }),
  '/ai/chat': (data) => ({
    code: 200,
    msg: 'success',
    data: {
      reply: '这是一个智能回复。根据您的问题，建议您注意休息，保持健康的生活方式。如有需要，请及时就医。'
    }
  }),
  '/system/operation-log/page': (params) => ({
    code: 200,
    msg: 'success',
    data: {
      list: [
        { id: 1, userId: 1, userName: 'admin', operation: '登录系统', module: '系统管理', ip: '127.0.0.1', createTime: '2024-01-15 10:00' },
        { id: 2, userId: 1, userName: 'admin', operation: '查看用户列表', module: '用户管理', ip: '127.0.0.1', createTime: '2024-01-15 10:05' }
      ],
      total: 100
    }
  }),
  '/system/user/page': (params) => ({
    code: 200,
    msg: 'success',
    data: {
      list: [
        { id: 1, username: 'admin', name: '管理员', role: 'ADMIN', status: 1, createTime: '2024-01-01' },
        { id: 2, username: 'doctor', name: '医生', role: 'DOCTOR', status: 1, createTime: '2024-01-02' },
        { id: 3, username: 'user', name: '普通用户', role: 'PATIENT', status: 1, createTime: '2024-01-03' }
      ],
      total: 50
    }
  }),
  '/system/admin/page': (params) => ({
    code: 200,
    msg: 'success',
    data: {
      list: [
        { id: 1, username: 'superadmin', name: '超级管理员', status: 1, createTime: '2024-01-01' },
        { id: 2, username: 'admin', name: '管理员', status: 1, createTime: '2024-01-02' }
      ],
      total: 10
    }
  })
}

export const getMockResponse = (url, data = {}) => {
  const mockFn = mockData[url]
  if (mockFn) {
    console.log(`[Mock] GET ${url}`, data)
    return Promise.resolve(mockFn(data))
  }
  return Promise.reject(new Error('No mock data for ' + url))
}
