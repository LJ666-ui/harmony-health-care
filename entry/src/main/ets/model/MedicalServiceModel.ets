@Observed
export class MedicalServiceModel {
  id: string = ''                  // 服务ID
  name: string = ''                // 服务名称
  icon: string = ''                // 服务图标
  targetPage: string = ''          // 跳转目标页面
  condition: () => boolean = () => true  // 显示条件
}
