# 医院系统数据修复 - 技术设计文档

**版本**: v1.0
**创建日期**: 2025-01-15
**最后更新**: 2025-01-15
**作者**: System
**状态**: 草稿

## 1. 设计概述

### 1.1 设计目标

本技术设计旨在修复医院系统中的数据不一致问题，核心设计目标包括：

1. **统一数据契约**：建立前后端一致的数据字典，解决医院筛选条件不匹配问题
2. **修复SQL查询**：纠正护士查询中的字段错误，恢复护士列表功能
3. **完善数据同步**：优化家属中心与患者端的数据加载机制
4. **建立规范**：制定数据模型规范，防止类似问题再次发生

### 1.2 技术选型

| 技术领域 | 选型方案 | 选型理由 |
|---------|---------|---------|
| **前端框架** | ArkUI (HarmonyOS) | 鸿蒙原生UI框架，声明式开发 |
| **开发语言** | ArkTS | 鸿蒙官方语言，类型安全 |
| **HTTP客户端** | HttpUtil | 项目现有工具类，统一请求处理 |
| **数据存储** | RDB (Relational Database) | 鸿蒙关系型数据库，用于本地缓存 |
| **数据字典** | 常量文件 | 简单高效，易于维护 |

### 1.3 设计约束

**技术约束**：
- 必须基于HarmonyOS Next开发，支持API Version 12及以上
- 所有代码必须使用ArkTS，禁止使用any类型
- 不允许修改数据库表结构
- 前端模块大小控制在300-500行代码

**业务约束**：
- 医院等级数据必须与现有数据库值完全匹配
- 护士查询必须基于现有表结构，移除不存在的gender字段
- 家属数据需符合隐私保护要求，敏感信息脱敏显示

**性能约束**：
- 医院筛选查询响应时间 < 1秒
- 护士列表加载时间 < 500ms
- 数据字典查询时间 < 10ms

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        前端层（ArkUI）                            │
├──────────┬──────────┬──────────┬──────────┬──────────┤
│ Hospital │  Nurse   │  Family  │  Data    │  Utils   │
│   Page   │   List   │   Home   │Dictionary│          │
└──────────┴──────────┴──────────┴──────────┴──────────┘
         │           │           │           │           │
         └───────────┴───────────┴───────────┴───────────┘
                              │
                    ┌─────────▼─────────┐
                    │   HttpUtil       │
                    │  (HTTP客户端)     │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │   后端API服务     │
                    │  (Node.js/Express)│
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │   MySQL数据库     │
                    │  (hospital/nurse) │
                    └───────────────────┘
```

**架构说明**：

1. **前端层**：包含医院页面、护士列表、家属中心等业务页面
2. **数据字典层**：统一管理前后端数据映射关系
3. **HTTP客户端层**：HttpUtil工具类处理所有HTTP请求
4. **后端服务层**：Node.js + Express提供RESTful API
5. **数据存储层**：MySQL存储医院、护士等核心数据

### 2.2 模块划分

#### 2.2.1 新增模块

```
entry/src/main/ets/
├── constants/                   # 常量定义
│   └── DataDictionary.ets       # 数据字典（新增）
│
├── models/                      # 数据模型
│   ├── Hospital.ets             # 医院模型（新增）
│   ├── Nurse.ets                # 护士模型（新增）
│   └── Family.ets               # 家属模型（已有）
│
├── pages/                       # 页面
│   ├── HospitalPage.ets         # 医院列表页（修改）
│   ├── FamilyNurseListPage.ets  # 家属护士列表页（修改）
│   └── FamilyHome.ets           # 家属中心页（修改）
│
└── utils/                       # 工具函数
    └── DataMappingUtil.ets      # 数据映射工具（新增）
```

#### 2.2.2 模块职责

| 模块名称 | 职责说明 |
|---------|---------|
| DataDictionary.ets | 定义医院等级等数据的映射关系，提供前后端数据转换 |
| Hospital.ets | 定义医院数据模型，包含id、name、level等字段 |
| Nurse.ets | 定义护士数据模型，不包含不存在的gender字段 |
| Family.ets | 定义家属数据模型，包含关联患者信息 |
| DataMappingUtil.ets | 提供数据映射转换工具方法 |

### 2.3 依赖关系

```
┌─────────────────────────────────────────┐
│           页面依赖关系                    │
├─────────────────────────────────────────┤
│  HospitalPage → HttpUtil                │
│  HospitalPage → DataMappingUtil          │
│  HospitalPage → DataDictionary          │
│                                         │
│  FamilyNurseListPage → HttpUtil         │
│  FamilyNurseListPage → Nurse.ets        │
│                                         │
│  FamilyHome → HttpUtil                  │
│  FamilyHome → Family.ets                │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│           模块依赖关系                    │
├─────────────────────────────────────────┤
│  DataMappingUtil → DataDictionary       │
│  Pages → Models → Constants             │
│  Pages → Utils                          │
└─────────────────────────────────────────┘
```

**依赖原则**：
- 单向依赖，禁止循环依赖
- 页面依赖工具类和模型
- 工具类依赖常量定义

## 3. 模块详细设计

### 3.1 数据字典模块（DataDictionary）

#### 3.1.1 职责定义

负责定义系统中所有数据项的前后端映射关系，包括医院等级、科室类型等，确保前后端数据一致性。

#### 3.1.2 接口设计

```arkts
// 数据字典接口
interface IDataDictionary {
  // 医院等级映射：前端显示值 -> 后端存储值
  HOSPITAL_LEVEL_MAP: Record<string, string>;

  // 医院等级映射：后端存储值 -> 前端显示值
  HOSPITAL_LEVEL_REVERSE_MAP: Record<string, string>;

  // 所有医院等级列表（前端显示值）
  HOSPITAL_LEVELS: string[];
}

// 数据字典常量
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
    '三级甲等医院': '三级甲等',
    '综合医院': '综合医院',
    '社区医院': '社区医院',
    '专科医院': '专科医院',
    '卫生院': '卫生院',
    '保健机构': '保健机构',
    '诊所': '诊所'
  },
  HOSPITAL_LEVELS: ['全部', '三级甲等', '综合医院', '社区医院', '专科医院', '卫生院', '保健机构', '诊所']
};
```

#### 3.1.3 关键方法

```arkts
/**
 * 将前端显示的医院等级转换为后端存储值
 * @param displayLevel 前端显示值，如"三级甲等"
 * @returns 后端存储值，如"三级甲等医院"
 */
export function convertLevelToDbValue(displayLevel: string): string {
  return DataDictionary.HOSPITAL_LEVEL_MAP[displayLevel] || displayLevel;
}

/**
 * 将后端存储的医院等级转换为前端显示值
 * @param dbLevel 后端存储值，如"三级甲等医院"
 * @returns 前端显示值，如"三级甲等"
 */
export function convertLevelToDisplayValue(dbLevel: string): string {
  return DataDictionary.HOSPITAL_LEVEL_REVERSE_MAP[dbLevel] || dbLevel;
}
```

#### 3.1.4 数据流

```
用户点击筛选标签 "三级甲等"
    ↓
前端调用 convertLevelToDbValue("三级甲等")
    ↓
查询数据字典 HOSPITAL_LEVEL_MAP
    ↓
返回 "三级甲等医院"
    ↓
发送HTTP请求 GET /hospital/page?level=三级甲等医院
    ↓
后端查询数据库 level字段
    ↓
返回匹配的医院列表
    ↓
前端调用 convertLevelToDisplayValue("三级甲等医院")
    ↓
显示 "三级甲等"
```

### 3.2 医院模型模块（Hospital Model）

#### 3.2.1 职责定义

定义医院数据的标准模型，确保前端接收的数据结构一致。

#### 3.2.2 接口设计

```arkts
export interface Hospital {
  id: number;
  name: string;
  address: string;
  phone: string;
  level: string; // 数据库存储值：三级甲等医院、综合医院等
  department: string;
  description: string;
}

export interface HospitalPageData {
  records: Hospital[];
}
```

### 3.3 护士模型模块（Nurse Model）

#### 3.3.1 职责定义

定义护士数据的标准模型，明确字段列表，避免SQL查询错误。

#### 3.3.2 接口设计

```arkts
export interface Nurse {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
  phone: string;
  department: string;
  title: string;
  workYears: number;
  avatar: string;
  status: number;
}
```

**重要说明**：此模型不包含gender字段，因为数据库nurse表中不存在该字段。

### 3.4 医院页面模块（HospitalPage）

#### 3.4.1 职责定义

负责医院列表展示和筛选功能，使用数据字典进行前后端数据转换。

#### 3.4.2 关键修改

```arkts
import { convertLevelToDbValue, convertLevelToDisplayValue } from '../constants/DataDictionary';
import type { Hospital, HospitalPageData } from '../models/Hospital';

class HospitalItem {
  id: number = 0;
  name: string = '';
  address: string = '';
  phone: string = '';
  level: string = '';
  department: string = '';
  description: string = '';
}

@Entry
@Component
struct HospitalPage {
  @State hospitals: HospitalItem[] = [];
  @State selectedLevel: string = '全部';
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';

  private levels: string[] = ['全部', '三级甲等', '综合医院', '社区医院', '专科医院', '卫生院', '保健机构', '诊所'];
  private isRequesting: boolean = false;

  async loadHospitalList(filterLevel?: string): Promise<void> {
    if (this.isRequesting) {
      console.log('[HospitalPage] 请求进行中，跳过重复请求');
      return;
    }

    this.isRequesting = true;
    this.isLoading = true;
    this.hasError = false;

    try {
      // 先尝试从缓存读取
      const cachedHospitals = await hospitalCacheManager.getHospitalsByLevel(this.convertLevelToDbValue(filterLevel || '全部'));
      const isCacheValid = await hospitalCacheManager.isCacheValid();

      if (cachedHospitals.length > 0 && isCacheValid) {
        console.log('[HospitalPage] 使用缓存数据，数量：', cachedHospitals.length);
        this.hospitals = cachedHospitals.map((item: HospitalCacheItem): HospitalItem => {
          const hospital: HospitalItem = {
            id: item.id,
            name: item.name,
            address: item.address,
            phone: item.phone,
            level: item.level,
            department: item.department,
            description: item.description
          };
          return hospital;
        });
        this.isLoading = false;
        this.isRequesting = false;
        return;
      }

      // 缓存无效或为空，从服务器获取
      console.log('[HospitalPage] 缓存无效，从服务器获取数据');

      let url: string = ApiConstants.HOSPITAL_LIST;
      let queryParams: Record<string, string> | undefined = undefined;

      if (filterLevel && filterLevel !== '全部') {
        url = ApiConstants.HOSPITAL_PAGE;
        queryParams = {
          'level': this.convertLevelToDbValue(filterLevel),
          'page': '1',
          'size': '500'
        };
      }

      let response: BaseResponse<HospitalItem[]>;

      if (queryParams) {
        response = await HttpUtil.request<HospitalItem[]>(
          HttpMethod.GET,
          url,
          undefined,
          queryParams,
          { showLoading: false, loadingText: '加载医院列表...' }
        );
      } else {
        response = await HttpUtil.request<HospitalItem[]>(
          HttpMethod.GET,
          url,
          undefined,
          undefined,
          { showLoading: false, loadingText: '加载医院列表...' }
        );
      }

      if (response.success && response.data) {
        let hospitalList: HospitalItem[] = [];
        const data: Object = response.data;

        if (Array.isArray(data)) {
          hospitalList = data;
        } else if (data && typeof data === 'object') {
          const pageData = data as HospitalPageData;
          if (pageData.records && Array.isArray(pageData.records)) {
            hospitalList = pageData.records;
          }
        }

        if (hospitalList.length > 0) {
          this.hospitals = hospitalList;

          // 保存到缓存
          const cacheItems: HospitalCacheItem[] = hospitalList.map((item: HospitalItem): HospitalCacheItem => {
            const cacheItem: HospitalCacheItem = {
              id: item.id,
              name: item.name,
              address: item.address || '',
              phone: item.phone || '',
              level: item.level || '',
              department: item.department || '',
              description: item.description || '',
              longitude: 0,
              latitude: 0,
              cached_time: Date.now(),
              data_source: 'server'
            };
            return cacheItem;
          });

          await hospitalCacheManager.saveHospitals(cacheItems);
          console.log('[HospitalPage] 已保存到缓存，数量：', cacheItems.length);
        } else {
          this.hospitals = [];
          this.errorMessage = '暂无医院数据';
        }
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载医院列表失败';
        ToastUtil.showError(this.errorMessage, 2000);
      }
    } catch (error) {
      this.hasError = true;
      const err = error as Error;
      this.errorMessage = err?.message || '网络错误，请检查网络连接';
      console.error('[HospitalPage] 加载医院列表失败:', error);
      ToastUtil.showError(this.errorMessage, 2000);
    } finally {
      this.isLoading = false;
      this.isRequesting = false;
    }
  }

  onLevelSelect(level: string): void {
    this.selectedLevel = level;
    this.loadHospitalList(level);
  }

  // 将前端显示的筛选标签转换为数据库中实际存储的值
  // 注意：数据库中使用 department 字段存储医院类型/等级
  private convertLevelToDbValue(level: string): string {
    const levelMap: Record<string, string> = {
      '全部': '',
      '三级甲等': '三级甲等医院',
      '综合医院': '综合医院',
      '社区医院': '社区医院',
      '专科医院': '专科医院',
      '卫生院': '卫生院',
      '保健机构': '保健机构',
      '诊所': '诊所'
    };
    return levelMap[level] || level;
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadHospitalList();
  }

  openARNavigation(): void {
    router.pushUrl({ url: 'pages/DestinationSelectPage' }).catch((error: Error) => {
      console.error('导航失败:', error.message);
    });
  }

  build() {
    Column() {
      Header({ title: '医院列表', showBack: true });

      if (this.isLoading) {
        Loading({ text: '加载中...' })
      } else if (this.hasError) {
        EmptyState({
          title: '加载失败',
          description: this.errorMessage,
          buttonText: '重新加载',
          onAdd: () => this.loadHospitalList(this.selectedLevel !== '全部' ? this.selectedLevel : undefined)
        })
      } else {
        Scroll() {
          Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
            Text('医院列表')
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Button('🧭 院内AR导航')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#FFFFFF')
              .backgroundColor(GlobalTheme.THEME_COLOR)
              .borderRadius(GlobalTheme.RADIUS_LG)
              .onClick(() => this.openARNavigation());

            Text('按等级筛选')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .margin({ top: GlobalTheme.getSpacingSM(this.isElderMode), bottom: GlobalTheme.getSpacingXS(this.isElderMode) })
              .alignSelf(ItemAlign.Start)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.levels, (level: string, index: number) => {
                Text(level)
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor(this.selectedLevel === level ? '#FFFFFF' : GlobalTheme.THEME_COLOR)
                  .backgroundColor(this.selectedLevel === level ? GlobalTheme.THEME_COLOR : '#F5F5F5')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .borderRadius(20)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.onLevelSelect(level);
                  })
              }, (level: string, index: number) => `${index}_${level}`)
            }
            .width('100%')

            Text(`当前显示: ${this.selectedLevel} (${this.hospitals.length}家)`)
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })

            if (this.hospitals.length === 0) {
              EmptyState({
                icon: '🏥',
                title: '暂无数据',
                description: this.selectedLevel === '全部' ? '暂无医院数据' : `暂无${this.selectedLevel}医院`
              })
                .width('100%')
                .height(200)
            } else {
              List({ space: 10 }) {
                ForEach(this.hospitals, (item: HospitalItem, index: number) => {
                  ListItem() {
                    Button() {
                      Column() {
                        Row() {
                          Text(item.name || '未知医院')
                            .fontSize(this.isElderMode ? 17 : 14)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#333333')
                            .textAlign(TextAlign.Start)
                          Blank()
                          Text('查看科室 >')
                            .fontSize(this.isElderMode ? 14 : 12)
                            .fontColor('#1677FF')
                        }
                        .width('100%')

                        if (item.level && item.level !== '') {
                          Text(item.level)
                            .fontSize(this.isElderMode ? 13 : 11)
                            .fontColor('#1677FF')
                            .width('100%')
                            .textAlign(TextAlign.Start)
                            .margin({ top: 4 })
                        }

                        if (item.address && item.address !== '') {
                          Text(item.address)
                            .fontSize(this.isElderMode ? 13 : 11)
                            .fontColor('#666666')
                            .width('100%')
                            .textAlign(TextAlign.Start)
                            .margin({ top: 2 })
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .height('auto')
                    .backgroundColor('#FFFFFF')
                    .borderRadius(10)
                    .padding(14)
                    .type(ButtonType.Normal)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/HospitalDepartmentPage',
                        params: {
                          hospitalId: item.id,
                          hospitalName: item.name
                        }
                      }).catch((err: Error) => {
                        console.error('[跳转失败]', err.message);
                      });
                    })
                  }
                }, (item: HospitalItem, index: number) => `${item.id}_${index}`)
              }
              .width('100%')
              .layoutWeight(1)
              .padding({ left: 8, right: 8 })
            }
          }
          .width('85%')
          .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
```

#### 3.4.3 数据流

```
用户点击筛选标签
    ↓
调用 onLevelSelect(level)
    ↓
调用 convertLevelToDbValue(level) 转换数据
    ↓
调用 loadHospitalList(filterLevel)
    ↓
检查缓存 → 缓存有效则返回
    ↓
缓存无效 → 发送HTTP请求
    ↓
接收响应数据
    ↓
保存到本地缓存
    ↓
更新UI显示
```

### 3.5 护士列表模块（FamilyNurseListPage）

#### 3.5.1 职责定义

负责护士列表展示和搜索功能，使用正确的护士数据模型。

#### 3.5.2 关键修改

```arkts
import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import type { Nurse } from '../models/Nurse';

@Entry
@Component
struct FamilyNurseListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State nurses: Nurse[] = [];
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';
  @State familyId: number = 0;

  aboutToAppear(): void {
    const params: Object | undefined = router.getParams();
    if (params) {
      const p: Record<string, Object> = params as Record<string, Object>;
      this.familyId = p['familyId'] as number || this.currentUserId;
    }
    this.loadNurses();
  }

  private async loadNurses(): Promise<void> {
    this.isLoading = true;
    try {
      const params: Record<string, string> = {};
      if (this.searchKeyword && this.searchKeyword.trim() !== '') {
        params['keyword'] = this.searchKeyword.trim();
      }

      const response: BaseResponse<Nurse[]> = await HttpUtil.get<Nurse[]>('/nurse/list', params);

      if (response.success && response.data) {
        this.nurses = response.data;
      } else {
        ToastUtil.showError(response.message || '获取护士列表失败');
      }
    } catch (error) {
      console.error('加载护士列表失败:', error);
      ToastUtil.showError('加载护士列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  private handleNurseClick(nurse: Nurse): void {
    router.pushUrl({
      url: 'pages/FamilyNurseChatPage',
      params: {
        familyId: this.familyId,
        nurseId: nurse.id,
        nurseName: nurse.name,
        relatedPatientName: ''
      }
    });
  }

  private getDepartmentIcon(department: string): string {
    const iconMap: Record<string, string> = {
      '内科': '🏥',
      '外科': '🔪',
      '儿科': '👶',
      '妇产科': '👩',
      '急诊科': '🚑',
      'ICU': '❤️‍🩹',
      '护理部': '💉'
    };
    return iconMap[department] || '🏥';
  }

  build() {
    Column() {
      Header({ title: '选择护士', showBack: true })

      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索护士姓名或工号...', text: this.searchKeyword })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.loadNurses();
          })

        Button('搜索')
          .height(36)
          .padding({ left: 16, right: 16 })
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(18)
          .margin({ left: 8 })
          .onClick(() => {
            this.loadNurses();
          });
      }
      .width('95%')
      .margin({ top: 15, bottom: 10 })

      // 护士列表
      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.nurses.length === 0) {
        Column() {
          Text('👩‍⚕️')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无可用护士')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('请稍后再试或联系管理员')
            .fontSize(14)
            .fontColor('#BBBBBB')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.nurses, (nurse: Nurse) => {
            ListItem() {
              Row() {
                // 头像
                Image(nurse.avatar || $r('app.media.startIcon'))
                  .width(50)
                  .height(50)
                  .borderRadius(25)
                  .backgroundColor('#E8F5E9')

                // 信息
                Column() {
                  Row() {
                    Text(nurse.name)
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(GlobalTheme.TEXT_PRIMARY)
                      .layoutWeight(1)

                    Text(nurse.nurseNo || 'N' + nurse.id)
                      .fontSize(12)
                      .fontColor('#722ED1')
                      .backgroundColor('#F9F0FF')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(4)
                  }
                  .width('100%')

                  Row() {
                    Text(`${this.getDepartmentIcon(nurse.department)} ${nurse.department}`)
                      .fontSize(13)
                      .fontColor('#52C41A')

                    if (nurse.title) {
                      Text(`  ${nurse.title}`)
                        .fontSize(13)
                        .fontColor('#666666')
                    }
                  }
                  .width('100%')
                  .margin({ top: 4 })

                  if (nurse.workYears && nurse.workYears > 0) {
                    Text(`工作年限: ${nurse.workYears}年`)
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ top: 2 })
                  }

                  Text(`工号: ${nurse.nurseNo}`)
                    .fontSize(11)
                    .fontColor('#BBBBBB')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12 })

                // 箭头
                Text('>')
                  .fontSize(20)
                  .fontColor('#CCCCCC')
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                this.handleNurseClick(nurse);
              })
            }
          })
        }
        .width('95%')
        .layoutWeight(1)
        .padding({ top: 8, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
```

### 3.6 家属中心模块（FamilyHome）

#### 3.6.1 职责定义

负责家属信息展示和关联患者数据加载，确保数据完整显示。

#### 3.6.2 关键修改

```arkts
@Entry
@Component
struct FamilyHome {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('familyInfo') familyInfo: FamilyInfo | null = null;
  @StorageLink('isFamilyLoggedIn') isFamilyLoggedIn: boolean = false;

  @State isLoading: boolean = false;
  @State relatedUser: RelatedUser | null = null;
  @State healthRecords: HealthRecord[] = [];
  @State activeTab: number = 0; // 0: 个人信息, 1: 健康记录, 2: 关联用户

  async aboutToAppear(): Promise<void> {
    // 检查登录状态
    if (!this.isFamilyLoggedIn) {
      router.replaceUrl({ url: 'pages/FamilyLogin' });
      return;
    }

    // 加载数据
    await this.loadData();
  }

  // 加载数据
  private async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // 获取家属详细信息
      const options: RequestOptions = { skipAuth: false };
      const response = await HttpUtil.get<FamilyInfo>('/family/info', options);

      if (response.success && response.data) {
        this.familyInfo = response.data;
        AppStorage.setOrCreate<FamilyInfo>('familyInfo', response.data);

        // 获取关联患者信息
        if (response.data.userId) {
          this.relatedUser = {
            id: response.data.userId,
            username: '',
            realName: '',
            phone: ''
          };
          await this.loadRelatedUserInfo(response.data.userId);
        }
      }
    } catch (error) {
      console.error('加载家属信息失败:', error);
      ToastUtil.showError('加载信息失败');
    } finally {
      this.isLoading = false;
    }
  }

  private async loadRelatedUserInfo(userId: number): Promise<void> {
    try {
      const response = await HttpUtil.get<RelatedUser>(`/user/${userId}`);
      if (response.success && response.data) {
        this.relatedUser = response.data;
        AppStorage.setOrCreate<RelatedUser>('relatedUser', response.data);
      }
    } catch (error) {
      console.error('加载关联用户信息失败:', error);
    }
  }

  // 退出登录
  private async handleLogout(): Promise<void> {
    try {
      const settings = SettingsUtil.getInstance();
      await settings.clearFamilyAuth();

      AppStorage.setOrCreate<string>('familyToken', '');
      AppStorage.setOrCreate<FamilyInfo | null>('familyInfo', null);
      AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);

      ToastUtil.showSuccess('已退出登录');
      router.replaceUrl({ url: 'pages/Login' });
    } catch (error) {
      console.error('退出登录失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Header({
        title: '家属中心',
        showBack: false,
        rightAction: {
          icon: '🚪',
          label: '退出',
          onClick: () => {
            this.handleLogout();
          }
        }
      })

      // 主要内容区域
      Column() {
        // 家属信息卡片
        if (this.familyInfo) {
          Column() {
            // 头像和姓名
            Row() {
              Image($r('app.media.startIcon'))
                .width(60)
                .height(60)
                .borderRadius(30)
                .margin({ right: 15 })

              Column() {
                Text(this.familyInfo.name)
                  .fontSize(this.isElderMode ? 22 : 18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)

                Text(this.getRelationText(this.familyInfo.relation))
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 5 })

                if (this.familyInfo.isEmergencyContact === 1) {
                  Text('紧急联系人')
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#FF5722')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(4)
                    .margin({ top: 5 })
                }
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(15)

            // 基本信息
            Row() {
              this.InfoItem('手机号', this.familyInfo.phone || '未设置')
              Divider().vertical(true).height(30).color('#E0E0E0')
              this.InfoItem('年龄', this.familyInfo.age ? `${this.familyInfo.age}岁` : '未设置')
              Divider().vertical(true).height(30).color('#E0E0E0')
              this.InfoItem('性别', this.getGenderText(this.familyInfo.gender))
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .padding({ top: 10, bottom: 10 })
            .backgroundColor('#FAFAFA')

            // 健康状况
            if (this.familyInfo.healthCondition) {
              Column() {
                Text('健康状况')
                  .fontSize(14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ bottom: 5 })

                Text(this.familyInfo.healthCondition)
                  .fontSize(this.isElderMode ? 18 : 16)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(15)
              .backgroundColor('#FFFFFF')
              .margin({ top: 10 })
            }
          }
          .width('95%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 15 })
          .shadow({ radius: 5, color: '#E0E0E0', offsetX: 0, offsetY: 2 })

        // 关联患者信息卡片
        if (this.relatedUser) {
          Column() {
            Text('👤 关联患者')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .width('100%')
              .margin({ bottom: 15 })

            Row() {
              Image($r('app.media.startIcon'))
                .width(50)
                .height(50)
                .borderRadius(25)
                .margin({ right: 15 })

              Column() {
                Text(this.relatedUser.realName || this.relatedUser.username || '患者')
                  .fontSize(this.isElderMode ? 20 : 18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)

                Text(`ID: ${this.relatedUser.id}`)
                  .fontSize(12)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 5 })

                if (this.relatedUser.phone) {
                  Text(`电话: ${this.relatedUser.phone}`)
                    .fontSize(12)
                    .fontColor(GlobalTheme.TEXT_SECONDARY)
                    .margin({ top: 2 })
                }
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Button('查看详情')
                .height(32)
                .fontSize(12)
                .fontColor('#3498DB')
                .backgroundColor('#E8F4FD')
                .borderRadius(16)
                .onClick(() => {
                  if (this.relatedUser) {
                    router.pushUrl({
                      url: 'pages/FamilyHealthRecords',
                      params: { userId: this.relatedUser.id }
                    });
                  }
                })
            }
            .width('100%')
            .padding(15)
          }
          .width('95%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 15 })
          .shadow({ radius: 5, color: '#E0E0E0', offsetX: 0, offsetY: 2 })
        }
        }

        // 功能菜单
        Column() {
          Text('功能菜单')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ bottom: 15 })

          // 菜单项
          Column() {
            this.MenuItem('📋 查看健康记录', '查看您和关联用户的健康记录', () => {
              router.pushUrl({ url: 'pages/FamilyHealthRecords' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('👥 查看关联用户', '查看关联用户的信息', () => {
              router.pushUrl({ url: 'pages/FamilyPage' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('💬 咨询聊天', '与医护人员在线沟通', () => {
              router.pushUrl({ url: 'pages/FamilyChatListPage' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('💊 用药管理', '查看和管理用药信息', () => {
              router.pushUrl({ url: 'pages/FamilyMedication' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('🏥 医疗记录', '查看关联患者的就诊记录', () => {
              router.pushUrl({ url: 'pages/FamilyMedicalRecords' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('📊 健康监测', '查看健康数据和趋势', () => {
              router.pushUrl({ url: 'pages/FamilyHealthRecords' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('🔔 消息通知', '查看健康提醒和通知', () => {
              ToastUtil.showInfo('消息通知功能开发中');
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('🔐 修改密码', '修改登录密码', () => {
              ToastUtil.showInfo('修改密码功能开发中');
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('👨‍👩‍👧 家属管理', '管理家属成员信息', () => {
              router.pushUrl({ url: 'pages/FamilyPage' });
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }
        .width('95%')
        .margin({ top: 20 })
        .padding(15)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 5, color: '#E0E0E0', offsetX: 0, offsetY: 2 })

        // 底部提示
        Text('家属登录功能 v1.0')
          .fontSize(12)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .margin({ top: 30, bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F5F5')

      // Loading遮罩
      if (this.isLoading) {
        Loading()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 信息项组件
  @Builder
  InfoItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor(GlobalTheme.TEXT_SECONDARY)

      Text(value)
        .fontSize(this.isElderMode ? 18 : 16)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .margin({ top: 5 })
    }
  }

  // 菜单项组件
  @Builder
  MenuItem(title: string, description: string, onClick: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(this.isElderMode ? 18 : 16)
          .fontColor(GlobalTheme.TEXT_PRIMARY)

        Text(description)
          .fontSize(12)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(20)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(15)
    .onClick(onClick)
  }

  // 获取关系文本
  private getRelationText(relation: string): string {
    const relationMap: Record<string, string> = {
      '配偶': '配偶',
      '子女': '子女',
      '父母': '父母',
      '兄弟姐妹': '兄弟姐妹',
      '其他': '其他'
    };
    return relationMap[relation] || relation;
  }

  // 获取性别文本
  private getGenderText(gender?: number): string {
    if (gender === 1) return '男';
    if (gender === 2) return '女';
    return '未知';
  }
}
```

## 4. 数据模型设计

### 4.1 核心数据结构

```arkts
// 医院数据模型
export interface Hospital {
  id: number;
  name: string;
  address: string;
  phone: string;
  level: string; // 数据库存储值：三级甲等医院、综合医院等
  department: string;
  description: string;
}

// 护士数据模型
export interface Nurse {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
  phone: string;
  department: string;
  title: string;
  workYears: number;
  avatar: string;
  status: number;
}

// 家属信息模型
export interface FamilyInfo {
  id: number;
  name: string;
  phone: string;
  relation: string;
  age?: number;
  gender?: number;
  healthCondition?: string;
  isEmergencyContact: number;
  userId: number;
}

// 关联用户模型
export interface RelatedUser {
  id: number;
  username: string;
  realName?: string;
  phone?: string;
}

// 健康记录模型
export interface HealthRecord {
  id: number;
  recordType: string;
  value: string;
  unit: string;
  recordTime: string;
  remark?: string;
}
```

### 4.2 数据关系

```
┌─────────────┐         ┌─────────────┐
│   Family    │─────────│    User     │
└─────────────┘         └─────────────┘
      │                        │
      │ userId                 │
      ▼                        ▼
┌─────────────┐         ┌─────────────┐
│  Patient    │─────────│  Hospital   │
└─────────────┘         └─────────────┘
      │
      │
┌─────▼─────┐
│  Nurse    │
└───────────┘
```

### 4.3 数据存储

#### 4.3.1 本地缓存（RDB）

**存储内容**：医院列表缓存

**表设计**：
```sql
CREATE TABLE local_hospital_cache (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  level TEXT,
  department TEXT,
  description TEXT,
  longitude REAL,
  latitude REAL,
  cached_time INTEGER NOT NULL,
  data_source TEXT DEFAULT 'server'
)
```

**索引策略**：
- `idx_hospital_level` - level字段索引
- `idx_hospital_name` - name字段索引

## 5. API设计

### 5.1 内部API

#### 5.1.1 医院列表API

```arkts
// GET /hospital/list
// 获取所有医院列表
Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "北京协和医院",
      "address": "北京市东城区东单帅府园1号",
      "phone": "010-69156699",
      "level": "三级甲等医院",
      "department": "综合医院",
      "description": "综合性三级甲等医院"
    }
  ]
}

// GET /hospital/page
// 分页查询医院列表
Query: {
  "level": "三级甲等医院",
  "page": 1,
  "size": 500
}
Response:
{
  "success": true,
  "data": {
    "records": [],
    "total": 100
  }
}
```

#### 5.1.2 护士列表API

```arkts
// GET /nurse/list
// 获取护士列表
Query: {
  "keyword": "张三"
}
Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "userId": 1001,
      "nurseNo": "N001",
      "name": "张三",
      "phone": "13800138000",
      "department": "内科",
      "title": "主管护师",
      "workYears": 5,
      "avatar": "https://example.com/avatar.jpg",
      "status": 1
    }
  ]
}
```

#### 5.1.3 家属信息API

```arkts
// GET /family/info
// 获取家属信息
Response:
{
  "success": true,
  "data": {
    "id": 1,
    "name": "李四",
    "phone": "13900139000",
    "relation": "配偶",
    "age": 35,
    "gender": 2,
    "healthCondition": "良好",
    "isEmergencyContact": 1,
    "userId": 2001
  }
}

// GET /user/{userId}
// 获取用户信息
Response:
{
  "success": true,
  "data": {
    "id": 2001,
    "username": "patient001",
    "realName": "王五",
    "phone": "13700137000"
  }
}
```

### 5.2 API规范

#### 5.2.1 请求格式

```arkts
Headers: {
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json"
}
```

#### 5.2.2 响应格式

```arkts
// 成功响应
{
  "success": true,
  "data": {},
  "message": "操作成功"
}

// 错误响应
{
  "success": false,
  "message": "错误描述"
}
```

## 6. 关键算法设计

### 6.1 医院等级数据转换算法

#### 算法原理

通过数据字典实现前端显示值与后端存储值的双向转换，确保筛选功能正常工作。

#### 伪代码

```
算法: convertLevelToDbValue(displayLevel)
输入: displayLevel - 前端显示值，如"三级甲等"
输出: dbLevel - 后端存储值，如"三级甲等医院"

1. 查询数据字典 HOSPITAL_LEVEL_MAP
2. 如果 displayLevel 存在于映射表中:
   返回对应的 dbLevel
3. 否则:
   返回 displayLevel（原样返回）
```

#### 复杂度分析

- 时间复杂度：O(1) - 哈希表查找
- 空间复杂度：O(n) - n为医院等级数量

## 7. UI/UX设计

### 7.1 页面结构

```
医院列表页面
├── 顶部导航栏
├── AR导航按钮
├── 筛选标签区
│   ├── 全部
│   ├── 三级甲等
│   ├── 综合医院
│   └── ...
├── 医院列表
│   └── 医院卡片
│       ├── 医院名称
│       ├── 医院等级
│       └── 医院地址
└── 底部导航栏
```

### 7.2 组件设计

| 组件名称 | 属性 | 说明 |
|---------|------|------|
| HospitalCard | hospital: Hospital | 医院卡片组件 |
| FilterTag | level: string, selected: boolean | 筛选标签组件 |
| NurseCard | nurse: Nurse | 护士卡片组件 |

### 7.3 交互流程

```
用户点击筛选标签
    ↓
标签高亮显示
    ↓
发送筛选请求
    ↓
显示加载状态
    ↓
更新医院列表
    ↓
显示筛选结果数量
```

## 8. 性能设计

### 8.1 性能目标

| 指标 | 目标值 | 测量方法 |
|-----|-------|---------|
| 医院筛选查询响应时间 | < 1秒 | 从点击筛选到列表更新 |
| 护士列表加载时间 | < 500ms | 从进入页面到数据显示 |
| 数据字典查询时间 | < 10ms | 哈希表查找时间 |

### 8.2 优化策略

1. **本地缓存**：使用RDB缓存医院列表，减少网络请求
2. **数据字典**：使用哈希表存储映射关系，O(1)时间复杂度
3. **懒加载**：医院列表使用虚拟滚动，减少渲染压力

### 8.3 监控方案

- 记录API请求耗时
- 监控缓存命中率
- 统计页面加载时间

## 9. 安全设计

### 9.1 数据安全

- 敏感信息（手机号）前端脱敏显示
- HTTP请求使用HTTPS传输
- 本地缓存数据加密存储

### 9.2 权限控制

- 护士列表查询需验证用户登录状态
- 家属查看患者数据需验证授权关系

## 10. 测试设计

### 10.1 测试策略

- **单元测试**：测试数据字典转换函数
- **集成测试**：测试医院筛选、护士列表功能
- **UI测试**：测试页面交互和数据显示

### 10.2 测试用例

| 用例ID | 测试场景 | 预期结果 |
|--------|---------|---------|
| TC-001 | 点击"三级甲等"筛选 | 显示所有level字段包含"三级甲等"的医院 |
| TC-002 | 护士列表加载 | 显示护士姓名、科室、职称等信息 |
| TC-003 | 家属中心加载 | 显示家属信息和关联患者信息 |

### 10.3 Mock数据

```arkts
// Mock医院数据
const mockHospitals: Hospital[] = [
  {
    id: 1,
    name: "北京协和医院",
    address: "北京市东城区东单帅府园1号",
    phone: "010-69156699",
    level: "三级甲等医院",
    department: "综合医院",
    description: "综合性三级甲等医院"
  }
];

// Mock护士数据
const mockNurses: Nurse[] = [
  {
    id: 1,
    userId: 1001,
    nurseNo: "N001",
    name: "张三",
    phone: "13800138000",
    department: "内科",
    title: "主管护师",
    workYears: 5,
    avatar: "https://example.com/avatar.jpg",
    status: 1
  }
];
```

## 11. 部署设计

### 11.1 环境要求

- HarmonyOS SDK API Version 12+
- DevEco Studio 5.0+
- Node.js 18+

### 11.2 配置管理

```arkts
// module.json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": ["default", "tablet"]
  }
}
```

### 11.3 发布流程

1. 代码审查
2. 单元测试
3. 集成测试
4. 构建打包
5. 真机测试
6. 发布上线

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|-----|------|
| 数据字典 | 系统中所有数据项的定义和映射关系 |
| 数据契约 | 前后端之间约定的数据格式和取值范围 |
| RDB | Relational Database，关系型数据库 |

### 12.2 参考资料

- HarmonyOS应用开发指南
- ArkTS语言规范
- 项目现有代码结构

### 12.3 变更历史

| 版本 | 日期 | 变更内容 | 变更人 |
|-----|------|---------|--------|
| v1.0 | 2025-01-15 | 初始版本，完成技术设计文档 | System |
