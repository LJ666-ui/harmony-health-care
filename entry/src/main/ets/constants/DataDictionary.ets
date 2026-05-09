/**
 * 数据字典接口
 * 定义前后端数据映射关系
 */
export interface IDataDictionary {
  HOSPITAL_LEVEL_MAP: Record<string, string>;
  HOSPITAL_LEVEL_REVERSE_MAP: Record<string, string>;
  HOSPITAL_LEVELS: string[];
}

/**
 * 数据字典常量
 * 包含医院等级的前后端映射关系
 */
export const DataDictionary: IDataDictionary = {
  HOSPITAL_LEVEL_MAP: {
    '全部': '',
    '三级甲等': '三级甲等医院',
    '综合医院': '综合医院',
    '社区医院': '社区医院',
    '专科医院': '专科医院',
    '卫生院': '卫生院',
    '保健机构': '保健机构',
    '诊所': '诊所'
  },
  HOSPITAL_LEVEL_REVERSE_MAP: {
    '': '全部',
    '三级甲等医院': '三级甲等',
    '综合医院': '综合医院',
    '社区医院': '社区医院',
    '专科医院': '专科医院',
    '卫生院': '卫生院',
    '保健机构': '保健机构',
    '诊所': '诊所'
  },
  HOSPITAL_LEVELS: [
    '全部',
    '三级甲等',
    '综合医院',
    '社区医院',
    '专科医院',
    '卫生院',
    '保健机构',
    '诊所'
  ]
}

/**
 * 将前端显示的医院等级转换为后端存储值
 * @param displayLevel 前端显示值（如"三级甲等"）
 * @returns 后端存储值（如"三级甲等医院"）
 */
export function convertLevelToDbValue(displayLevel: string): string {
  return DataDictionary.HOSPITAL_LEVEL_MAP[displayLevel] || '';
}

/**
 * 将后端存储的医院等级转换为前端显示值
 * @param dbLevel 后端存储值（如"三级甲等医院"）
 * @returns 前端显示值（如"三级甲等"）
 */
export function convertLevelToDisplayValue(dbLevel: string): string {
  return DataDictionary.HOSPITAL_LEVEL_REVERSE_MAP[dbLevel] || '全部';
}
