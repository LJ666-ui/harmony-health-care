import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Input } from '../components/Input';

@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';

  build() {
    Column() {
      // 顶部导航栏
      Header({ 
        title: '登录', 
        showBack: true
      })
      
      // 中间内容区
      Column({ space: 24 }) {
        // 账号输入框
        Input({
          placeholder: '请输入账号',
          inputType: 'text',
          text: $username,
          onChange: (value) => {
            console.log('账号变化:', value);
          }
        })
        
        // 密码输入框
        Input({
          placeholder: '请输入密码',
          inputType: 'password',
          text: $password,
          onChange: (value) => {
            console.log('密码变化:', value);
          }
        })
        
        // 登录按钮
        Button('登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight('medium')
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .onClick(() => {
            // 路由跳转到HomePage页面
            router.pushUrl({
              url: 'pages/HomePage'
            });
          })
        
        // 忘记密码
        Text('忘记密码')
          .fontSize(14)
          .fontColor('#1677FF')
          .onClick(() => {
            console.log('忘记密码点击');
          })
      }
      .flexGrow(1)
      .width('80%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      
      // 底部Tab栏
      Footer({ activeIndex: 1 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
