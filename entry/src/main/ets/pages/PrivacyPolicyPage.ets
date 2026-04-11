import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

@Entry
@Component
struct PrivacyPolicyPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  handleAgree(): void {
    router.back();
  }

  build() {
    Column() {
      Header({
        title: '隐私政策',
        showBack: true
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('星云医疗助手隐私政策')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) })
            .textAlign(TextAlign.Center);

          Text(`更新日期：2026年4月1日

生效日期：2026年4月1日

版本：V1.0`)
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .margin({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('引言')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333');

            Text(`欢迎使用星云医疗助手（以下简称"本应用"）。我们深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠。我们致力于维持您对我们的信任，恪守以下原则，保护您的个人信息：权责一致原则、目的明确原则、选择同意原则、最少够用原则、确保安全原则、主体参与原则、公开透明原则等。`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666')
              .lineHeight(22);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('一、我们如何收集和使用您的个人信息')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333');

            Text(`1. 健康数据收集
我们会根据您的主动操作收集您的健康数据，包括但不限于血压、血糖、心率、体重等生理指标数据。

2. 设备信息
为提供健康监测服务，我们需要收集与您关联的智能设备信息，包括设备型号、连接状态等。

3. 位置信息
在您使用附近医疗机构查询功能时，我们会请求获取您的位置信息，以便为您提供精准的服务推荐。

4. 使用日志
我们会自动收集您在使用本应用过程中的操作日志，用于优化产品体验和服务质量。`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666')
              .lineHeight(22);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('二、我们如何共享、转让、公开披露您的个人信息')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333');

            Text(`1. 共享
未经您事先同意，我们不会与任何第三方共享您的个人信息。在以下情形中，我们可能会共享必要的个人信息：
• 获得您的明确授权或同意；
• 根据法律法规的要求；
* 与关联公司或合作伙伴共享，但仅限于业务需要且经过脱敏处理的信息。

2. 转让
我们不会将您的个人信息转让给任何公司、组织和个人，但以下情况除外：
• 获得您的明确同意；
• 涉及合并、收购或破产清算时。

3. 公开披露
我们仅会在以下情况下，公开披露您的个人信息：
• 获得您的单独同意；
• 基于法律法规的强制性要求。`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666')
              .lineHeight(22);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('三、我们如何保护您的个人信息')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333');

            Text(`1. 数据安全技术措施
我们采用符合行业标准的安全防护措施，包括建立合理的制度规范、安全技术来防止您的个人信息遭到未经授权的访问、使用、修改，避免数据的损坏或丢失。

2. 数据安全管理措施
我们会采取合理可行的措施，尽力避免收集无关的个人信息；我们会在达成本政策所述目的所需的期限内保留您的个人信息。

3. 安全事件通知
在不幸发生信息安全事件后，我们将按照法律法规的要求，及时向您告知：安全事件的基本情况和可能的影响、我们已采取或将要采取的处置措施、您可自主防范和降低风险的建议等。`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666')
              .lineHeight(22);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('四、您的权利')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333');

            Text(`按照中国相关的法律、法规、标准，以及其他国家、地区的通行做法，我们保障您对自己的个人信息行使以下权利：

1. 访问您的个人信息
2. 更正您的个人信息
3. 删除您的个人信息
4. 改变授权范围
5. 撤回授权
6. 注销账户
7. 获取个人信息副本

您可以通过"隐私设置"页面中的相关功能行使上述权利。`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666')
              .lineHeight(22);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('五、未成年人保护')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333');

            Text(`我们非常重视对未成年人个人信息的保护。若您是18周岁以下的未成年人，在使用我们的产品/服务前，应事先取得您家长或法定监护人的同意。如果您是未成年人的监护人，当您对您所监护的未成年人处理个人信息的相关事宜有相关疑问时，请通过本政策公布的联系方式与我们联系。`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666')
              .lineHeight(22);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('六、联系我们')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333');

            Text(`如果您对本隐私政策有任何疑问、意见或建议，请通过以下方式与我们联系：

邮箱：privacy@yunyomedical.com
电话：400-888-XXXX
地址：北京市海淀区XX路XX号XX大厦

我们将在15个工作日内回复您的请求。`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666')
              .lineHeight(22);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Button('同意并继续')
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(12)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) })
            .onClick(() => this.handleAgree());
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
