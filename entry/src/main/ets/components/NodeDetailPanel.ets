import { GlobalTheme } from '../global';

interface NodeDetail {
  id: number;
  name: string;
  nodeType: string;
  alias: string;
  description: string;
  imageUrl: string;
  propertiesJson: string;
}

interface GraphNodeInfo {
  id: number;
  name: string;
  type: string;
  color: string;
  depthLevel: number;
}

@Component
export struct NodeDetailPanel {
  @Prop selectedNode: GraphNodeInfo | null = null;
  @Prop nodeDetail: NodeDetail | null = null;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  onClose?: () => void;
  onExpandFromNode?: (node: GraphNodeInfo) => void;

  private getTypeIcon(nodeType: string): string {
    const iconMap: Record<string, string> = {
      'DISEASE': '\uD83C\uDFE5',
      'SYMPTOM': '\uD83E\uDEA7',
      'HERBAL': '\uD83C\uDF3F',
      'PRESCRIPTION': '\uD83D\uDC8A',
      'THERAPY': '\uD83C\uDFCB'
    };
    return iconMap[nodeType] || '\uD83D\uDCCB';
  }

  private getTypeName(nodeType: string): string {
    const nameMap: Record<string, string> = {
      'DISEASE': '\u75BE\u75C5',
      'SYMPTOM': '\u75C7\u72B6',
      'HERBAL': '\u836F\u6750',
      'PRESCRIPTION': '\u65B9\u5242',
      'THERAPY': '\u7597\u6CD5'
    };
    return nameMap[nodeType] || '\u5176\u4ED6';
  }

  build() {
    Column() {
      Row() {
        Text(this.selectedNode ? this.getTypeIcon(this.selectedNode.type) : '')
          .fontSize(24)
          .margin({ right: 8 });
        Text(this.selectedNode ? this.selectedNode.name : '')
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY)
          .layoutWeight(1);

        Text('\u2715')
          .fontSize(20)
          .fontColor(GlobalTheme.TEXT_HINT)
          .onClick(() => {
            if (this.onClose) {
              this.onClose();
            }
          });
      }
      .width('100%')
      .padding({ bottom: 8 });

      if (this.selectedNode) {
        Row() {
          Text(this.getTypeName(this.selectedNode.type))
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor('#FFFFFF')
            .backgroundColor(this.selectedNode.color)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10);
          Text('级别 ' + this.selectedNode.depthLevel)
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ left: 8 });
        }
        .margin({ bottom: 8 });
      }

      if (this.nodeDetail && this.nodeDetail.description) {
        Text(this.nodeDetail.description)
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .maxLines(4)
          .margin({ bottom: 8 });
      }

      if (this.selectedNode) {
        Button('\u4EE5\u6B64\u8282\u70B9\u4E3A\u4E2D\u5FC3\u5C55\u5F00')
          .width('100%')
          .height(GlobalTheme.getButtonHeight(this.isElderMode))
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#FFFFFF')
          .backgroundColor(this.selectedNode.color)
          .borderRadius(GlobalTheme.RADIUS_LG)
          .onClick(() => {
            if (this.onExpandFromNode && this.selectedNode) {
              this.onExpandFromNode(this.selectedNode);
            }
          });
      }
    }
    .width('100%')
    .padding(GlobalTheme.getSpacingMD(this.isElderMode))
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius({ topLeft: GlobalTheme.RADIUS_LG, topRight: GlobalTheme.RADIUS_LG })
    .shadow({ radius: 12, color: '#00000012', offsetX: 0, offsetY: -2 });
  }
}

export { NodeDetail, GraphNodeInfo };
