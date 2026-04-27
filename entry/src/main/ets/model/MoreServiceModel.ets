@Observed
export class MoreServiceModel {
  id: string = ''                  // 服务ID
  name: string = ''                // 服务名称
  icon: string = ''                // 服务图标
  content: string = ''             // 服务内容
  targetPage: string = ''          // 跳转目标页面
  isExpanded: boolean = false      // 是否展开
}
