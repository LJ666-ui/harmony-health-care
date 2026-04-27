@Observed
export class BannerModel {
  id: string = ''              // Banner ID
  title: string = ''           // 标题
  subtitle: string = ''        // 副标题
  startColor: string = '#9B59B6'  // 背景渐变起始色
  endColor: string = '#8E44AD'    // 背景渐变结束色
  icon: string = '🤖'          // 图标
  targetPage: string = ''      // 跳转目标页面
  condition: () => boolean = () => true  // 显示条件
}
