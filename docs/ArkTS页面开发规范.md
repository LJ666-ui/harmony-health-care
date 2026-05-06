# ArkTS标准页面开发规范

## 版本信息
- **DevEco Studio**: 6.0.2
- **HarmonyOS SDK API**: 22
- **开发语言**: ArkTS (TypeScript超集)

## 一、页面基本结构

### 1.1 标准页面模板

```typescript
import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

/**
 * 页面说明
 * @author 开发者
 * @date 创建日期
 */
@Entry
@Component
export struct PageName {
  // 状态管理
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = false;
  @State dataList: DataItem[] = [];

  // 配置实例
  private theme: AccessibilityConfig = new AccessibilityConfig();

  // 生命周期
  aboutToAppear(): void {
    this.theme = AccessibilityConfig.getInstance();
    this.loadData();
  }

  aboutToDisappear(): void {
    // 清理资源
  }

  // 数据加载
  private async loadData(): Promise<void> {
    try {
      this.isLoading = true;
      // 网络请求逻辑
      // const response = await HttpUtil.get('/api/data');
      // this.dataList = response.data;
    } catch (error) {
      console.error('数据加载失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 页面构建
  build() {
    Column() {
      Header({ title: '页面标题' })

      if (this.isLoading) {
        this.buildLoadingState()
      } else if (this.dataList.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildContent()
      }

      Footer({ activeIndex: 0 })
    }
    .height('100%')
    .backgroundColor(AccessibilityConfig.getBackgroundColor())
  }

  // 加载状态
  @Builder buildLoadingState(): void {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#3498DB')

      Text('加载中...')
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 空状态
  @Builder buildEmptyState(): void {
    Column() {
      Text('📭')
        .fontSize(60)

      Text('暂无数据')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 内容区域
  @Builder buildContent(): void {
    Scroll() {
      Column({ space: this.isElderMode ? 16 : 12 }) {
        ForEach(this.dataList, (item: DataItem) => {
          this.buildItemCard(item)
        })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  // 列表项卡片
  @Builder buildItemCard(item: DataItem): void {
    Column() {
      Text(item.title)
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
    .onClick(() => {
      this.handleItemClick(item);
    })
  }

  // 事件处理
  private handleItemClick(item: DataItem): void {
    router.pushUrl({
      url: 'pages/DetailPage',
      params: { id: item.id }
    }).catch((error: Error) => {
      console.error('页面跳转失败:', error);
    });
  }
}

// 数据类型定义
interface DataItem {
  id: string;
  title: string;
  // 其他字段...
}
```

## 二、核心规范要点

### 2.1 装饰器使用

| 装饰器 | 用途 | 示例 |
|--------|------|------|
| `@Entry` | 页面入口 | 必须标注在页面struct上 |
| `@Component` | 组件定义 | 必须标注在struct上 |
| `@State` | 组件内部状态 | `@State count: number = 0` |
| `@Prop` | 父→子单向传递 | `@Prop title: string` |
| `@Link` | 父子双向绑定 | `@Link @Watch('onChange') value: number` |
| `@StorageLink` | 全局状态 | `@StorageLink('key') value: Type` |
| `@Builder` | 构建函数 | `@Builder buildContent(): void` |

### 2.2 路由跳转规范

```typescript
// ✅ 正确：使用pushUrl
router.pushUrl({
  url: 'pages/TargetPage',
  params: { id: '123', name: 'test' }
}).catch((error: Error) => {
  console.error('跳转失败:', error);
});

// ❌ 错误：不要使用push（已废弃）
// router.push({ url: 'pages/TargetPage' });

// 返回上一页
router.back();

// 替换当前页面
router.replaceUrl({
  url: 'pages/NewPage'
});
```

### 2.3 网络请求规范

```typescript
import { http } from '@kit.NetworkKit';

// GET请求
private async fetchData(): Promise<void> {
  try {
    const response = await http.request(
      'http://api.example.com/data',
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token'
        }
      }
    );

    if (response.responseCode === 200) {
      const data = JSON.parse(response.result as string);
      // 处理数据
    }
  } catch (error) {
    console.error('请求失败:', error);
    // 错误处理
  }
}

// POST请求
private async postData(params: Record<string, Object>): Promise<void> {
  try {
    const response = await http.request(
      'http://api.example.com/create',
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: params
      }
    );
    // 处理响应
  } catch (error) {
    console.error('提交失败:', error);
  }
}
```

### 2.4 无障碍支持规范

```typescript
// 使用AccessibilityConfig工具类
private theme: AccessibilityConfig = AccessibilityConfig.getInstance();

// 字体大小（支持老年模式）
.fontSize(this.isElderMode ? 20 : 16)

// 间距（支持老年模式）
.padding(this.isElderMode ? 20 : 16)

// 背景色（支持高对比度）
.backgroundColor(AccessibilityConfig.getBackgroundColor())

// 文字颜色（支持高对比度）
.fontColor(AccessibilityConfig.getTextColor())

// 最小触控区域（44x44dp）
.width(44)
.height(44)
```

### 2.5 类型安全规范

```typescript
// ✅ 正确：定义明确的接口
interface UserInfo {
  id: string;
  name: string;
  age: number;
  avatar?: string; // 可选属性
}

// ✅ 正确：使用泛型
private dataList: UserInfo[] = [];

// ❌ 错误：避免使用any
// private data: any = {};

// ✅ 正确：使用Record定义对象类型
private params: Record<string, string | number> = {};

// ✅ 正确：函数返回类型
private async getData(): Promise<UserInfo[]> {
  return [];
}
```

## 三、常用布局组件

### 3.1 Column（纵向布局）

```typescript
Column({ space: 12 }) { // 子元素间距
  Text('标题')
  Text('内容')
}
.width('100%')
.height('100%')
.justifyContent(FlexAlign.Center) // 主轴对齐
.alignItems(HorizontalAlign.Center) // 交叉轴对齐
.padding(16)
.backgroundColor('#FFFFFF')
```

### 3.2 Row（横向布局）

```typescript
Row({ space: 8 }) {
  Text('左侧')
  Blank() // 占位，推开后续元素
  Text('右侧')
}
.width('100%')
.justifyContent(FlexAlign.SpaceBetween)
.alignItems(VerticalAlign.Center)
```

### 3.3 Flex（弹性布局）

```typescript
Flex({
  direction: FlexDirection.Row,
  wrap: FlexWrap.Wrap,
  justifyContent: FlexAlign.Start,
  alignItems: ItemAlign.Center
}) {
  Text('项目1')
  Text('项目2')
  Text('项目3')
}
.width('100%')
```

### 3.4 Grid（网格布局）

```typescript
Grid() {
  ForEach(this.items, (item: Item) => {
    GridItem() {
      Column() {
        Text(item.title)
      }
    }
  })
}
.columnsTemplate('1fr 1fr 1fr') // 三列
.rowsGap(12) // 行间距
.columnsGap(12) // 列间距
.width('100%')
```

## 四、生命周期函数

```typescript
@Entry
@Component
struct PageName {
  // 组件即将出现
  aboutToAppear(): void {
    console.log('页面即将显示');
    // 初始化数据
  }

  // 组件即将消失
  aboutToDisappear(): void {
    console.log('页面即将消失');
    // 清理资源
  }

  // 页面显示
  onPageShow(): void {
    console.log('页面已显示');
  }

  // 页面隐藏
  onPageHide(): void {
    console.log('页面已隐藏');
  }

  // 返回键拦截
  onBackPress(): boolean {
    console.log('按下返回键');
    return false; // false=默认处理，true=拦截
  }

  build() {
    Column() {
      Text('Content')
    }
  }
}
```

## 五、性能优化建议

### 5.1 状态管理优化

```typescript
// ✅ 减少不必要的@State
// 只在需要触发UI刷新时使用@State

// ✅ 使用@ObjectLink传递复杂对象
@ObjectLink
data: DataObject;

// ✅ 使用@Watch监听特定变化
@State @Watch('onCountChange')
count: number = 0;

onCountChange(newValue: number, oldValue: number): void {
  console.log(`count从${oldValue}变为${newValue}`);
}
```

### 5.2 列表渲染优化

```typescript
// ✅ 使用LazyForEach处理大数据列表
LazyForEach(
  this.dataSource,
  (item: DataItem) => {
    ListItem() {
      this.buildItem(item)
    }
  },
  (item: DataItem) => item.id // 唯一键
)

// ✅ 列表项使用@ComponentV2（API 11+）
@ComponentV2
struct ListItemComponent {
  @Param item: DataItem;

  build() {
    Row() {
      Text(this.item.title)
    }
  }
}
```

### 5.3 条件渲染优化

```typescript
// ✅ 使用if-else而不是三元运算符
if (this.isLoading) {
  this.buildLoading()
} else {
  this.buildContent()
}

// ❌ 避免
// this.isLoading ? this.buildLoading() : this.buildContent()
```

## 六、错误处理最佳实践

### 6.1 网络请求错误处理

```typescript
private async fetchData(): Promise<void> {
  try {
    this.isLoading = true;
    const response = await http.request(/* ... */);

    if (response.responseCode === 200) {
      // 成功处理
    } else if (response.responseCode === 401) {
      // 未授权，跳转登录
      router.replaceUrl({ url: 'pages/Login' });
    } else if (response.responseCode === 404) {
      // 资源不存在
      this.errorMessage = '数据不存在';
    } else {
      // 其他错误
      this.errorMessage = '请求失败，请稍后重试';
    }
  } catch (error) {
    console.error('网络请求异常:', error);
    this.errorMessage = '网络异常，请检查网络连接';
  } finally {
    this.isLoading = false;
  }
}
```

### 6.2 路由跳转错误处理

```typescript
private navigateTo(url: string, params?: Record<string, Object>): void {
  router.pushUrl({
    url: url,
    params: params
  }).catch((error: Error) => {
    console.error('页面跳转失败:', error);
    // 提示用户
    AlertDialog.show({
      title: '提示',
      message: '页面跳转失败，请重试',
      autoCancel: true
    });
  });
}
```

## 七、代码组织建议

### 7.1 文件结构

```
pages/
├── HomePage.ets          # 首页
├── DetailPage.ets        # 详情页
└── ...

components/
├── Header.ets            # 页头组件
├── Footer.ets            # 页脚组件
├── Card.ets              # 卡片组件
└── ...

utils/
├── AccessibilityConfig.ets  # 无障碍配置
├── HttpUtil.ets             # 网络请求工具
└── ...

models/
├── User.ets             # 用户模型
└── ...
```

### 7.2 命名规范

- **页面**: PascalCase + Page后缀，如 `HomePage.ets`
- **组件**: PascalCase，如 `Header.ets`
- **函数**: camelCase，如 `loadData()`
- **变量**: camelCase，如 `dataList`
- **常量**: UPPER_SNAKE_CASE，如 `MAX_COUNT`
- **接口**: PascalCase，如 `UserInfo`

## 八、DevEco Studio 6.0.2 特性

### 8.1 新特性支持

- **API 22**: 支持最新的HarmonyOS API
- **ArkUI增强**: 更强大的声明式UI能力
- **性能优化**: 更快的编译和运行速度
- **调试增强**: 更完善的调试工具

### 8.2 编译配置

确保 `build-profile.json5` 配置正确：

```json
{
  "app": {
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compatibleSdkVersion": "22",
        "targetSdkVersion": "22"
      }
    ]
  }
}
```

---

**最后更新**: 2026-05-06
**适用版本**: DevEco Studio 6.0.2, HarmonyOS SDK API 22
