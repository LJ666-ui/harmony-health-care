import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

/**
 * 数据选择器组件
 * 支持从数据库中选择数据（患者、医生、医院等）
 */
@Component
export struct DataSelector {
  @Prop dataType: string = 'patient';  // 'patient', 'doctor', 'hospital'
  @Prop placeholder: string = '请选择';
  @Prop title: string = '选择数据';
  @Link selectedId: number;
  @Link selectedName: string;
  
  @State dataList: any[] = [];
  @State keyword: string = '';
  @State isLoading: boolean = false;
  @State showDialog: boolean = false;
  @State filteredList: any[] = [];

  async aboutToAppear() {
    await this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    try {
      let url = '';
      if (this.dataType === 'patient') {
        url = '/data/patients';
      } else if (this.dataType === 'doctor') {
        url = '/data/doctors';
      } else if (this.dataType === 'hospital') {
        url = '/data/hospitals';
      }

      const params: Record<string, string> = {};
      if (this.keyword) {
        params['keyword'] = this.keyword;
      }

      const response = await HttpUtil.get<any[]>(url, params as Object);
      if (response.success && response.data) {
        this.dataList = response.data;
        this.filteredList = this.dataList;
      } else {
        ToastUtil.showError(response.message || '加载数据失败');
      }
    } catch (error) {
      console.error('加载数据失败:', error);
      ToastUtil.showError('加载数据失败');
    } finally {
      this.isLoading = false;
    }
  }

  onSearch() {
    if (!this.keyword) {
      this.filteredList = this.dataList;
      return;
    }
    
    this.filteredList = this.dataList.filter((item: any) => {
      const name = item.name || '';
      return name.toLowerCase().includes(this.keyword.toLowerCase());
    });
  }

  onSelect(item: any) {
    this.selectedId = item.id;
    this.selectedName = item.name || '';
    this.showDialog = false;
  }

  build() {
    Column() {
      // 选择器触发按钮
      Row() {
        Text(this.selectedName || this.placeholder)
          .fontSize(16)
          .fontColor(this.selectedName ? '#333333' : '#999999')
          .layoutWeight(1)
        
        Text('▼')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 8 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .border({ width: 1, color: '#E0E0E0' })
      .onClick(() => {
        this.showDialog = true;
        this.loadData();
      })

      // 选择对话框
      if (this.showDialog) {
        Column() {
          // 标题栏
          Row() {
            Text('取消')
              .fontSize(16)
              .fontColor('#666666')
              .onClick(() => {
                this.showDialog = false;
              })
            
            Text(this.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            
            Text('确定')
              .fontSize(16)
              .fontColor('#007DFF')
              .onClick(() => {
                this.showDialog = false;
              })
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })

          // 搜索框
          Row() {
            TextInput({ placeholder: '搜索...', text: this.keyword })
              .fontSize(16)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.keyword = value;
                this.onSearch();
              })
            
            if (this.keyword) {
              Text('×')
                .fontSize(20)
                .fontColor('#999999')
                .margin({ left: 8 })
                .onClick(() => {
                  this.keyword = '';
                  this.filteredList = this.dataList;
                })
            }
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#F5F5F5')
          .margin({ bottom: 8 })

          // 数据列表
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(48)
                .height(48)
                .color('#007DFF')
              
              Text('加载中...')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          } else if (this.filteredList.length === 0) {
            Column() {
              Text('暂无数据')
                .fontSize(16)
                .fontColor('#999999')
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          } else {
            List() {
              ForEach(this.filteredList, (item: any) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(item.name || '')
                        .fontSize(16)
                        .fontColor('#333333')
                      
                      if (this.dataType === 'patient') {
                        Text(`手机号: ${item.phone || '无'}`)
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ top: 4 })
                      } else if (this.dataType === 'doctor') {
                        Text(`${item.department || ''} | ${item.title || ''}`)
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ top: 4 })
                      } else if (this.dataType === 'hospital') {
                        Text(item.address || '')
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ top: 4 })
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    
                    if (this.selectedId === item.id) {
                      Text('✓')
                        .fontSize(20)
                        .fontColor('#007DFF')
                    }
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(this.selectedId === item.id ? '#F0F8FF' : '#FFFFFF')
                }
                .onClick(() => {
                  this.onSelect(item);
                })
              })
            }
            .width('100%')
            .layoutWeight(1)
            .divider({ strokeWidth: 1, color: '#E0E0E0' })
          }
        }
        .width('100%')
        .height('80%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 16, topRight: 16 })
        .position({ x: 0, y: '20%' })
        .shadow({ radius: 20, color: '#000000', offsetX: 0, offsetY: -5 })
      }
    }
    .width('100%')
  }
}
