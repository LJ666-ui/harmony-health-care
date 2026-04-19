import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { GlobalTheme } from '../global';
import { KnowledgeNode, GraphNode } from './KnowledgeNode';
import { NodeDetailPanel, NodeDetail, GraphNodeInfo } from './NodeDetailPanel';

interface GraphEdge {
  id: number;
  source: number;
  target: number;
  relationType: string;
  relationName: string;
  label: string;
  weight: number;
}

interface GraphData {
  centerId: number;
  depth: number;
  nodeCount: number;
  edgeCount: number;
  nodes: GraphNode[];
  edges: GraphEdge[];
}

interface GraphNodeDetail {
  id: number;
  name: string;
  nodeType: string;
  alias: string;
  description: string;
  imageUrl: string;
  propertiesJson: string;
}

interface GraphRequestParams {
  centerId: number;
  depth: number;
}

function convertToGraphNodeInfo(node: GraphNode): GraphNodeInfo {
  return {
    id: node.id,
    name: node.name,
    type: node.type,
    color: node.color,
    depthLevel: node.depthLevel
  };
}

function convertToGraphNode(nodeInfo: GraphNodeInfo): GraphNode {
  return {
    id: nodeInfo.id,
    label: nodeInfo.name,
    name: nodeInfo.name,
    type: nodeInfo.type,
    color: nodeInfo.color,
    radius: 20,
    x: 0,
    y: 0,
    depthLevel: nodeInfo.depthLevel,
    description: '',
    isCoreNode: 0
  };
}

@Component
export struct GraphCanvas {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State graphNodes: GraphNode[] = [];
  @State graphEdges: GraphEdge[] = [];
  @State isLoading: boolean = true;
  @State loadError: string = '';
  @State selectedNode: GraphNode | null = null;
  @State nodeDetail: GraphNodeDetail | null = null;
  @State centerId: number = 1;
  @State depth: number = 2;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State scaleValue: number = 1;
  @State showDetail: boolean = false;

  aboutToAppear(): void {
    this.fetchGraph();
  }

  fetchGraph(): void {
    this.isLoading = true;
    this.loadError = '';
    this.showDetail = false;
    this.selectedNode = null;

    const graphParams: GraphRequestParams = {
      centerId: this.centerId,
      depth: this.depth
    };

    HttpUtil.get<GraphData>(ApiConstants.KNOWLEDGE_GRAPH, graphParams)
      .then((response: BaseResponse<GraphData>) => {
        if (response.success && response.data) {
          const data: GraphData = response.data;
          this.graphNodes = data.nodes || [];
          this.graphEdges = data.edges || [];
          this.centerId = data.centerId;
        } else {
          this.loadError = response.message || '加载图谱失败';
        }
        this.isLoading = false;
      })
      .catch((error: Error) => {
        this.loadError = error.message || '网络请求失败';
        this.isLoading = false;
      });
  }

  findNode(nodeId: number): GraphNode | null {
    for (let i = 0; i < this.graphNodes.length; i++) {
      if (this.graphNodes[i].id === nodeId) {
        return this.graphNodes[i];
      }
    }
    return null;
  }

  mapX(originalX: number): number {
    return (originalX * this.scaleValue) + this.offsetX;
  }

  mapY(originalY: number): number {
    return (originalY * this.scaleValue) + this.offsetY;
  }

  handleNodeClick(node: GraphNode): void {
    this.selectedNode = node;
    this.showDetail = true;

    HttpUtil.get<GraphNodeDetail>(ApiConstants.KNOWLEDGE_NODE_DETAIL + node.id)
      .then((response: BaseResponse<GraphNodeDetail>) => {
        if (response.success && response.data) {
          this.nodeDetail = response.data;
        }
      })
      .catch(() => {
        this.nodeDetail = null;
      });
  }

  handleExpandFromNode(node: GraphNode): void {
    this.centerId = node.id;
    this.offsetX = 0;
    this.offsetY = 0;
    this.scaleValue = 1;
    this.fetchGraph();
  }

  getEdgeSourceNode(edge: GraphEdge): GraphNode | null {
    return this.findNode(edge.source);
  }

  getEdgeTargetNode(edge: GraphEdge): GraphNode | null {
    return this.findNode(edge.target);
  }

  getEdgeStartX(edge: GraphEdge): number {
    const node = this.getEdgeSourceNode(edge);
    return node != null ? this.mapX(node.x) : 0;
  }

  getEdgeStartY(edge: GraphEdge): number {
    const node = this.getEdgeSourceNode(edge);
    return node != null ? this.mapY(node.y) : 0;
  }

  getEdgeEndX(edge: GraphEdge): number {
    const node = this.getEdgeTargetNode(edge);
    return node != null ? this.mapX(node.x) : 0;
  }

  getEdgeEndY(edge: GraphEdge): number {
    const node = this.getEdgeTargetNode(edge);
    return node != null ? this.mapY(node.y) : 0;
  }

  getEdgeColorStr(edge: GraphEdge): string {
    const node = this.getEdgeSourceNode(edge);
    return node != null ? node.color + '60' : '#CCCCCC60';
  }

  getEdgeLabelX(edge: GraphEdge): number {
    return (this.getEdgeStartX(edge) + this.getEdgeEndX(edge)) / 2 - 12;
  }

  getEdgeLabelY(edge: GraphEdge): number {
    return (this.getEdgeStartY(edge) + this.getEdgeEndY(edge)) / 2 - 6;
  }

  getEdgeLabelText(edge: GraphEdge): string {
    if (edge.label.length > 4) {
      return edge.label.substring(0, 4);
    }
    return edge.label;
  }

  isEdgeValid(edge: GraphEdge): boolean {
    return this.getEdgeSourceNode(edge) != null && this.getEdgeTargetNode(edge) != null;
  }

  @Builder
  buildEdge(edge: GraphEdge) {
    if (this.isEdgeValid(edge)) {
      Column() {
        Line()
          .width('100%')
          .height('100%')
          .startPoint([this.getEdgeStartX(edge), this.getEdgeStartY(edge)])
          .endPoint([this.getEdgeEndX(edge), this.getEdgeEndY(edge)])
          .strokeWidth(1.5)
          .stroke(this.getEdgeColorStr(edge));

        if (edge.label.length > 0) {
          Text(this.getEdgeLabelText(edge))
            .fontSize(8)
            .fontColor('#999999')
            .backgroundColor('#FFFFFFCC')
            .padding({ left: 2, right: 2, top: 0, bottom: 0 })
            .borderRadius(2)
            .position({
              x: this.getEdgeLabelX(edge),
              y: this.getEdgeLabelY(edge)
            });
        }
      }
      .width('100%')
      .height('100%');
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(GlobalTheme.THEME_COLOR)
            .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
          Text('正在加载知识图谱...')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY);
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else if (this.loadError) {
        Column() {
          Text('⚠️')
            .fontSize(48)
            .margin({ bottom: 10 });
          Text(this.loadError)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.ERROR_COLOR)
            .textAlign(TextAlign.Center);
          Button('重新加载')
            .margin({ top: 16 })
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#FFFFFF')
            .backgroundColor(GlobalTheme.THEME_COLOR)
            .borderRadius(GlobalTheme.RADIUS_LG)
            .onClick(() => this.fetchGraph());
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding(GlobalTheme.getSpacingLG(this.isElderMode));
      } else if (this.graphNodes.length === 0) {
        Column() {
          Text('📭')
            .fontSize(48)
            .margin({ bottom: 10 });
          Text('暂无图谱数据')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY);
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Stack() {
          Stack() {
            ForEach(this.graphEdges, (edge: GraphEdge) => {
              Row() {
                this.buildEdge(edge);
              }
              .width('100%')
              .height('100%');
            }, (edge: GraphEdge) => 'edge-' + edge.id);

            ForEach(this.graphNodes, (node: GraphNode) => {
              KnowledgeNode({
                node: node,
                scaleValue: this.scaleValue,
                offsetX: this.offsetX,
                offsetY: this.offsetY,
                onNodeClick: (clickedNode: GraphNode) => {
                  this.handleNodeClick(clickedNode);
                }
              });
            }, (node: GraphNode) => 'node-' + node.id);
          }
          .width('100%')
          .height('100%')
          .clip(true);

          if (this.showDetail && this.selectedNode) {
            Column() {
              Blank()
                .layoutWeight(1);
              NodeDetailPanel({
                selectedNode: convertToGraphNodeInfo(this.selectedNode),
                nodeDetail: this.nodeDetail,
                onClose: () => {
                  this.showDetail = false;
                },
                onExpandFromNode: (node: GraphNodeInfo) => {
                  this.handleExpandFromNode(convertToGraphNode(node));
                }
              });
            }
            .width('100%')
            .height('100%');
          }
        }
        .width('100%')
        .layoutWeight(1);

        Row() {
          Text('节点: ' + this.graphNodes.length)
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY);
          Text(' | 关系: ' + this.graphEdges.length)
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY);
          Text(' | 深度: ' + this.depth)
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY);
          Row({ space: 4 }) {
            Text('🔍+')
              .fontSize(14)
              .fontColor(GlobalTheme.THEME_COLOR)
              .onClick(() => {
                this.scaleValue = Math.min(this.scaleValue + 0.2, 2.0);
              });
            Text('🔍-')
              .fontSize(14)
              .fontColor(GlobalTheme.THEME_COLOR)
              .onClick(() => {
                this.scaleValue = Math.max(this.scaleValue - 0.2, 0.4);
              });
            Text('🔄')
              .fontSize(14)
              .fontColor(GlobalTheme.THEME_COLOR)
              .onClick(() => {
                this.offsetX = 0;
                this.offsetY = 0;
                this.scaleValue = 1;
              });
          }
          .margin({ left: 8 });
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(GlobalTheme.CARD_BG)
        .justifyContent(FlexAlign.SpaceBetween);
      }
    }
    .width('100%')
    .height('100%');
  }
}
