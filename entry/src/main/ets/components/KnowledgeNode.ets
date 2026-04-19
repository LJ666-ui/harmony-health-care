interface GraphNode {
  id: number;
  label: string;
  name: string;
  type: string;
  color: string;
  radius: number;
  x: number;
  y: number;
  depthLevel: number;
  description: string;
  isCoreNode: number;
}

@Component
export struct KnowledgeNode {
  @Prop node: GraphNode = {} as GraphNode;
  @Prop scaleValue: number = 1;
  @Prop offsetX: number = 0;
  @Prop offsetY: number = 0;
  onNodeClick?: (node: GraphNode) => void;

  private mapX(originalX: number): number {
    return (originalX * this.scaleValue) + this.offsetX;
  }

  private mapY(originalY: number): number {
    return (originalY * this.scaleValue) + this.offsetY;
  }

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

  private getNodeSize(depthLevel: number): number {
    return depthLevel === 0 ? 56 : 44;
  }

  private getNodeRadius(depthLevel: number): number {
    return depthLevel === 0 ? 28 : 22;
  }

  private getBorderWidth(depthLevel: number): number {
    return depthLevel === 0 ? 2.5 : 1.5;
  }

  private getIconSize(depthLevel: number): number {
    return depthLevel === 0 ? 18 : 14;
  }

  private getNameSize(depthLevel: number): number {
    return depthLevel === 0 ? 11 : 9;
  }

  private getShadowRadius(depthLevel: number): number {
    return depthLevel === 0 ? 8 : 4;
  }

  build() {
    Column() {
      Text(this.getTypeIcon(this.node.type))
        .fontSize(this.getIconSize(this.node.depthLevel));
      Text(this.node.name.length > 4 ? this.node.name.substring(0, 4) : this.node.name)
        .fontSize(this.getNameSize(this.node.depthLevel))
        .fontColor(this.node.color)
        .maxLines(1);
    }
    .width(this.getNodeSize(this.node.depthLevel))
    .height(this.getNodeSize(this.node.depthLevel))
    .borderRadius(this.getNodeRadius(this.node.depthLevel))
    .backgroundColor('#FFFFFF')
    .border({
      width: this.getBorderWidth(this.node.depthLevel),
      color: this.node.color
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .shadow({
      radius: this.getShadowRadius(this.node.depthLevel),
      color: this.node.color + '30',
      offsetX: 0,
      offsetY: 2
    })
    .position({
      x: this.mapX(this.node.x) - this.getNodeRadius(this.node.depthLevel),
      y: this.mapY(this.node.y) - this.getNodeRadius(this.node.depthLevel)
    })
    .onClick(() => {
      if (this.onNodeClick) {
        this.onNodeClick(this.node);
      }
    });
  }
}

export { GraphNode };
