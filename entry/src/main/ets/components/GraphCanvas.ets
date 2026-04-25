import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { GlobalTheme } from '../global';
import { KnowledgeNode, GraphNode } from './KnowledgeNode';

class GraphEdge {
  id: number = 0;
  source: number = 0;
  target: number = 0;
  relationType: string = '';
  relationName: string = '';
  label: string = '';
  weight: number = 0;
}

class GraphData {
  centerId: number = 0;
  depth: number = 0;
  nodeCount: number = 0;
  edgeCount: number = 0;
  nodes: GraphNode[] = [];
  edges: GraphEdge[] = [];
}

class GraphRequestParams {
  centerId: number = 0;
  depth: number = 2;
}

@Component
export struct GraphCanvas {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State graphNodes: GraphNode[] = [];
  @State graphEdges: GraphEdge[] = [];
  @State isLoading: boolean = true;
  @State loadError: string = '';
  @State centerId: number = 1;
<<<<<<< HEAD
  @State depth: number = 1;
=======
  @State depth: number = 2;
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
  @State scaleValue: number = 1;
  @State panOffsetX: number = 0;
  @State panOffsetY: number = 0;
  @State canvasWidth: number = 360;
  @State canvasHeight: number = 500;
  @State autoScale: number = 1;
  @State baseOffsetX: number = 0;
  @State baseOffsetY: number = 0;
  @Prop startCenterId: number = 1;
<<<<<<< HEAD
  @State selectedNode: GraphNode | null = null;
  @State showNodePanel: boolean = false;
  private currentRenderKey: number = 0;
=======
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
  private draggingNodeId: number = -1;
  private lastDragX: number = 0;
  private lastDragY: number = 0;
  private lastPanX: number = 0;
  private lastPanY: number = 0;
  private layoutTimer: number = -1;
  private simulationSteps: number = 0;

  aboutToAppear(): void {
<<<<<<< HEAD
    this.currentRenderKey = this.startCenterId;
=======
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
    this.centerId = this.startCenterId;
    this.fetchGraph();
  }

  aboutToDisappear(): void {
    this.clearTimer();
  }

  private clearTimer(): void {
    if (this.layoutTimer !== -1) {
      try { clearInterval(this.layoutTimer); } catch (e) {}
      this.layoutTimer = -1;
    }
  }

  fetchGraph(): void {
    this.isLoading = true;
    this.loadError = '';
    this.panOffsetX = 0;
    this.panOffsetY = 0;
    this.scaleValue = 1;
    this.clearTimer();

    const graphParams: GraphRequestParams = new GraphRequestParams();
    graphParams.centerId = this.centerId;
    graphParams.depth = this.depth;

    HttpUtil.get<GraphData>(ApiConstants.KNOWLEDGE_GRAPH, graphParams)
      .then((response: BaseResponse<GraphData>) => {
        if (response.success && response.data) {
          const data: GraphData = response.data;
          this.graphNodes = data.nodes || [];
          this.graphEdges = data.edges || [];
          this.centerId = data.centerId;
          this.calculateAutoFit();
          this.startForceSimulation();
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

  navigateToCenter(nodeId: number): void {
    this.centerId = nodeId;
    this.fetchGraph();
  }

  private calculateAutoFit(): void {
    if (this.graphNodes.length === 0) {
      return;
    }
    let minX: number = Infinity;
    let maxX: number = -Infinity;
    let minY: number = Infinity;
    let maxY: number = -Infinity;
    for (let i = 0; i < this.graphNodes.length; i++) {
      const n: GraphNode = this.graphNodes[i];
      if (n.x < minX) { minX = n.x; }
      if (n.x > maxX) { maxX = n.x; }
      if (n.y < minY) { minY = n.y; }
      if (n.y > maxY) { maxY = n.y; }
    }
    const padding: number = 50;
    const gw: number = maxX - minX + padding * 2;
    const gh: number = maxY - minY + padding * 2;
    const sx: number = this.canvasWidth / gw;
    const sy: number = this.canvasHeight / gh;
    this.autoScale = Math.min(sx, sy, 1.0);
    const cx: number = (minX + maxX) / 2;
    const cy: number = (minY + maxY) / 2;
    this.baseOffsetX = this.canvasWidth / 2 - cx * this.autoScale;
    this.baseOffsetY = this.canvasHeight / 2 - cy * this.autoScale;
  }

  private startForceSimulation(): void {
<<<<<<< HEAD
    this.clearTimer();
    this.simulationSteps = 0;
    const cx: number = this.canvasWidth / 2;
    const cy: number = this.canvasHeight / 2;
    const minDim: number = Math.min(this.canvasWidth, this.canvasHeight);
    const maxRadius: number = minDim * 0.38;
    const levelGroups: GraphNode[][] = [];
    let maxDepth: number = 0;
    for (let i: number = 0; i < this.graphNodes.length; i++) {
      const d: number = this.graphNodes[i].depthLevel;
      if (d > maxDepth) { maxDepth = d; }
      if (!levelGroups[d]) { levelGroups[d] = []; }
      levelGroups[d].push(this.graphNodes[i]);
    }
    for (let lv: number = 0; lv <= maxDepth; lv++) {
      if (!levelGroups[lv]) { continue; }
      const group: GraphNode[] = levelGroups[lv];
      const count: number = group.length;
      if (lv === 0 && count > 0) {
        group[0].x = cx;
        group[0].y = cy;
      } else {
        const ringRadius: number = maxRadius * (lv / Math.max(maxDepth, 1));
        const actualR: number = Math.max(ringRadius, minDim * 0.12);
        for (let j: number = 0; j < count; j++) {
          const angle: number = (2 * Math.PI * j) / count - Math.PI / 2 + (Math.random() * 0.3 - 0.15);
          group[j].x = cx + actualR * Math.cos(angle);
          group[j].y = cy + actualR * Math.sin(angle);
        }
      }
    }
    try {
      this.layoutTimer = setInterval(() => {
        this.simulationSteps++;
        if (this.simulationSteps > 20) {
=======
    this.simulationSteps = 0;
    const maxSteps: number = 80;
    const cx: number = this.canvasWidth / 2;
    const cy: number = this.canvasHeight / 2;
    try {
      this.layoutTimer = setInterval(() => {
        this.simulationSteps++;
        if (this.simulationSteps > maxSteps) {
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
          this.clearTimer();
          this.calculateAutoFit();
          return;
        }
<<<<<<< HEAD
        const alpha: number = Math.max(0.02, 1 - this.simulationSteps / 20);
        const nodes: GraphNode[] = this.graphNodes;
        for (let i: number = 0; i < nodes.length; i++) {
          if (nodes[i].id === this.centerId || nodes[i].id === this.draggingNodeId) { continue; }
          let fx: number = 0;
          let fy: number = 0;
          for (let j: number = 0; j < nodes.length; j++) {
=======
        const alpha: number = Math.max(0.01, 1 - this.simulationSteps / maxSteps);
        const nodes: GraphNode[] = this.graphNodes;
        const minDist: number = 80;
        for (let i = 0; i < nodes.length; i++) {
          if (nodes[i].id === this.centerId || nodes[i].id === this.draggingNodeId) {
            continue;
          }
          let fx: number = 0;
          let fy: number = 0;
          const dx: number = nodes[i].x - cx;
          const dy: number = nodes[i].y - cy;
          const dist: number = Math.sqrt(dx * dx + dy * dy);
          const idealDist: number = 80 + nodes[i].depthLevel * 80;
          if (dist > 0) {
            fx -= (dist - idealDist) * 0.006 * alpha * dx / dist;
            fy -= (dist - idealDist) * 0.006 * alpha * dy / dist;
          }
          for (let j = 0; j < nodes.length; j++) {
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
            if (i === j) { continue; }
            const ddx: number = nodes[i].x - nodes[j].x;
            const ddy: number = nodes[i].y - nodes[j].y;
            const d: number = Math.sqrt(ddx * ddx + ddy * ddy);
<<<<<<< HEAD
            if (d < 55) {
              const repulse: number = (55 - d) * (55 - d) * 0.04 * alpha;
              fx += repulse * ddx / Math.max(d, 0.1);
              fy += repulse * ddy / Math.max(d, 0.1);
            }
          }
          const moveLen: number = Math.sqrt(fx * fx + fy * fy);
          const maxMove: number = 3 * alpha;
=======
            if (d < 1) {
              fx += (Math.random() - 0.5) * 10;
              fy += (Math.random() - 0.5) * 10;
            } else if (d < minDist) {
              const repulse: number = (minDist - d) * (minDist - d) * 0.03 * alpha;
              fx += repulse * ddx / d;
              fy += repulse * ddy / d;
            }
          }
          for (let e = 0; e < this.graphEdges.length; e++) {
            const edge: GraphEdge = this.graphEdges[e];
            let other: GraphNode | null = null;
            if (edge.source === nodes[i].id) { other = this.findNode(edge.target); }
            else if (edge.target === nodes[i].id) { other = this.findNode(edge.source); }
            if (other) {
              const ex: number = other.x - nodes[i].x;
              const ey: number = other.y - nodes[i].y;
              const ed: number = Math.sqrt(ex * ex + ey * ey);
              const springLen: number = minDist + (nodes[i].depthLevel + other.depthLevel) * 20;
              if (ed > 0) {
                const spring: number = (ed - springLen) * 0.003 * alpha;
                fx += spring * ex / ed;
                fy += spring * ey / ed;
              }
            }
          }
          const maxMove: number = 6 * alpha;
          const moveLen: number = Math.sqrt(fx * fx + fy * fy);
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
          if (moveLen > maxMove) {
            fx = fx / moveLen * maxMove;
            fy = fy / moveLen * maxMove;
          }
          nodes[i].x += fx;
          nodes[i].y += fy;
        }
        const newNodes: GraphNode[] = [];
        for (let k: number = 0; k < nodes.length; k++) { newNodes.push(nodes[k]); }
        this.graphNodes = newNodes;
<<<<<<< HEAD
      }, 25);
=======
      }, 16);
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
    } catch (e) {}
  }

  findNode(nodeId: number): GraphNode | null {
    for (let i = 0; i < this.graphNodes.length; i++) {
      if (this.graphNodes[i].id === nodeId) { return this.graphNodes[i]; }
    }
    return null;
  }

  mapX(originalX: number): number {
    return originalX * this.autoScale * this.scaleValue + this.panOffsetX + this.baseOffsetX;
  }

  mapY(originalY: number): number {
    return originalY * this.autoScale * this.scaleValue + this.panOffsetY + this.baseOffsetY;
  }

  private createMappedNode(original: GraphNode): GraphNode {
    const mapped: GraphNode = new GraphNode();
    mapped.id = original.id;
    mapped.label = original.label;
    mapped.name = original.name;
    mapped.type = original.type;
    mapped.color = original.color;
    mapped.radius = original.radius;
    mapped.x = this.mapX(original.x);
    mapped.y = this.mapY(original.y);
    mapped.depthLevel = original.depthLevel;
    mapped.description = original.description;
    mapped.isCoreNode = original.isCoreNode;
    return mapped;
  }

  handleNodeClick(node: GraphNode): void {
<<<<<<< HEAD
    this.selectedNode = node;
    this.showNodePanel = true;
  }

  expandAroundNode(nodeId: number): void {
    this.showNodePanel = false;
    this.centerId = nodeId;
    this.fetchGraph();
  }

  navigateToDetail(node: GraphNode): void {
    this.showNodePanel = false;
    if (node.type === 'HERBAL') {
      try {
        router.pushUrl({ url: 'pages/HerbalDetailPage', params: { herbalId: String(node.id) } });
      } catch (e) {}
    }
  }

  closeNodePanel(): void {
    this.showNodePanel = false;
    this.selectedNode = null;
  }

  handleNodeDragStart(node: GraphNode): void {
    this.draggingNodeId = node.id;
    this.lastDragX = 0;
    this.lastDragY = 0;
  }

  handleNodeDragUpdate(node: GraphNode, offsetX: number, offsetY: number): void {
    const dx: number = offsetX - this.lastDragX;
    const dy: number = offsetY - this.lastDragY;
    this.lastDragX = offsetX;
    this.lastDragY = offsetY;
    node.x += dx / (this.autoScale * this.scaleValue);
    node.y += dy / (this.autoScale * this.scaleValue);
    const idx: number = this.graphNodes.findIndex((n: GraphNode) => n.id === node.id);
    if (idx >= 0) {
      const newNode: GraphNode = this.createCopyNode(node);
      const arr: GraphNode[] = [];
      for (let i: number = 0; i < this.graphNodes.length; i++) {
        arr.push(i === idx ? newNode : this.graphNodes[i]);
      }
      this.graphNodes = arr;
    }
  }

=======
    if (node.type === 'HERBAL') {
      try {
        router.pushUrl({ url: 'pages/HerbalDetailPage', params: { herbalId: String(node.id) } });
      } catch (e) {}
    }
  }

  handleNodeDragStart(node: GraphNode): void {
    this.draggingNodeId = node.id;
    this.lastDragX = 0;
    this.lastDragY = 0;
  }

  handleNodeDragUpdate(node: GraphNode, offsetX: number, offsetY: number): void {
    const dx: number = offsetX - this.lastDragX;
    const dy: number = offsetY - this.lastDragY;
    this.lastDragX = offsetX;
    this.lastDragY = offsetY;
    node.x += dx / (this.autoScale * this.scaleValue);
    node.y += dy / (this.autoScale * this.scaleValue);
    const idx: number = this.graphNodes.findIndex((n: GraphNode) => n.id === node.id);
    if (idx >= 0) {
      const newNode: GraphNode = this.createCopyNode(node);
      const arr: GraphNode[] = [];
      for (let i: number = 0; i < this.graphNodes.length; i++) {
        arr.push(i === idx ? newNode : this.graphNodes[i]);
      }
      this.graphNodes = arr;
    }
  }

>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
  private createCopyNode(src: GraphNode): GraphNode {
    const copy: GraphNode = new GraphNode();
    copy.id = src.id;
    copy.label = src.label;
    copy.name = src.name;
    copy.type = src.type;
    copy.color = src.color;
    copy.radius = src.radius;
    copy.x = src.x;
    copy.y = src.y;
    copy.depthLevel = src.depthLevel;
    copy.description = src.description;
    copy.isCoreNode = src.isCoreNode;
    return copy;
  }

<<<<<<< HEAD
  handleNodeDragEnd(draggedNode: GraphNode): void {
    this.draggingNodeId = -1;
    this.lastDragX = 0;
    this.lastDragY = 0;
    const cx: number = this.canvasWidth / 2;
    const cy: number = this.canvasHeight / 2;
    let closestNode: GraphNode | null = null;
    let closestDist: number = Infinity;
    for (let i: number = 0; i < this.graphNodes.length; i++) {
      const n: GraphNode = this.graphNodes[i];
      const dx: number = n.x - cx;
      const dy: number = n.y - cy;
      const dist: number = Math.sqrt(dx * dx + dy * dy);
      if (dist < closestDist) {
        closestDist = dist;
        closestNode = n;
      }
    }
    if (closestNode != null && closestNode.id !== this.centerId) {
      this.centerId = closestNode.id;
      this.fetchGraph();
    }
  }

  getNodeRadius(node: GraphNode): number {
    if (node.depthLevel === 0) { return 30; }
    if (node.depthLevel === 1) { return 24; }
    return 20;
  }

  getNodeOpacity(node: GraphNode): number {
    if (node.depthLevel === 0) { return 1.0; }
    if (node.depthLevel === 1) { return 0.92; }
    return 0.80;
=======
  handleNodeDragEnd(): void {
    this.draggingNodeId = -1;
    this.lastDragX = 0;
    this.lastDragY = 0;
  }

  getNodeRadius(node: GraphNode): number {
    return node.depthLevel === 0 ? 26 : 20;
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
  }

  getEdgeStartX(edge: GraphEdge): number {
    const s: GraphNode | null = this.findNode(edge.source);
    const t: GraphNode | null = this.findNode(edge.target);
    if (s == null || t == null) { return 0; }
    const sx: number = this.mapX(s.x);
    const sy: number = this.mapY(s.y);
    const tx: number = this.mapX(t.x);
    const ty: number = this.mapY(t.y);
    const r: number = this.getNodeRadius(s);
    const d: number = Math.sqrt((tx - sx) * (tx - sx) + (ty - sy) * (ty - sy));
    if (d < r * 2) { return sx; }
    return sx + (tx - sx) / d * r;
  }

  getEdgeStartY(edge: GraphEdge): number {
    const s: GraphNode | null = this.findNode(edge.source);
    const t: GraphNode | null = this.findNode(edge.target);
    if (s == null || t == null) { return 0; }
    const sx: number = this.mapX(s.x);
    const sy: number = this.mapY(s.y);
    const tx: number = this.mapX(t.x);
    const ty: number = this.mapY(t.y);
    const r: number = this.getNodeRadius(s);
    const d: number = Math.sqrt((tx - sx) * (tx - sx) + (ty - sy) * (ty - sy));
    if (d < r * 2) { return sy; }
    return sy + (ty - sy) / d * r;
  }

  getEdgeEndX(edge: GraphEdge): number {
    const s: GraphNode | null = this.findNode(edge.source);
    const t: GraphNode | null = this.findNode(edge.target);
    if (s == null || t == null) { return 0; }
    const sx: number = this.mapX(s.x);
    const sy: number = this.mapY(s.y);
    const tx: number = this.mapX(t.x);
    const ty: number = this.mapY(t.y);
    const r: number = this.getNodeRadius(t);
    const d: number = Math.sqrt((tx - sx) * (tx - sx) + (ty - sy) * (ty - sy));
    if (d < r * 2) { return tx; }
    return tx - (tx - sx) / d * r;
  }

  getEdgeEndY(edge: GraphEdge): number {
    const s: GraphNode | null = this.findNode(edge.source);
    const t: GraphNode | null = this.findNode(edge.target);
    if (s == null || t == null) { return 0; }
    const sx: number = this.mapX(s.x);
    const sy: number = this.mapY(s.y);
    const tx: number = this.mapX(t.x);
    const ty: number = this.mapY(t.y);
    const r: number = this.getNodeRadius(t);
    const d: number = Math.sqrt((tx - sx) * (tx - sx) + (ty - sy) * (ty - sy));
    if (d < r * 2) { return ty; }
    return ty - (ty - sy) / d * r;
  }

  getEdgeMidX(edge: GraphEdge): number {
    return (this.getEdgeStartX(edge) + this.getEdgeEndX(edge)) / 2;
  }

  getEdgeMidY(edge: GraphEdge): number {
    return (this.getEdgeStartY(edge) + this.getEdgeEndY(edge)) / 2;
  }

  getEdgeColor(edge: GraphEdge): string {
    const node: GraphNode | null = this.findNode(edge.source);
    return node != null ? node.color : '#CCCCCC';
  }

  getEdgeLabelText(edge: GraphEdge): string {
    if (edge.label.length > 4) { return edge.label.substring(0, 4); }
    return edge.label;
  }

  hasEdgeLabel(edge: GraphEdge): boolean {
    return edge.label != null && edge.label.length > 0;
  }

  isEdgeValid(edge: GraphEdge): boolean {
    return this.findNode(edge.source) != null && this.findNode(edge.target) != null;
  }

  private getTypeName(nodeType: string): string {
    if (nodeType === 'DISEASE') { return '疾病'; }
    if (nodeType === 'SYMPTOM') { return '症状'; }
    if (nodeType === 'HERBAL') { return '药材'; }
    if (nodeType === 'PRESCRIPTION') { return '方剂'; }
    if (nodeType === 'THERAPY') { return '疗法'; }
    return '其他';
  }

  @Builder
  buildEdgeLine(edge: GraphEdge) {
    if (this.isEdgeValid(edge)) {
      Stack() {
        Line()
          .width('100%')
          .height('100%')
          .startPoint([this.getEdgeStartX(edge), this.getEdgeStartY(edge)])
          .endPoint([this.getEdgeMidX(edge), this.getEdgeMidY(edge)])
          .strokeWidth(1.5)
          .strokeDashArray([4, 3])
          .stroke(this.getEdgeColor(edge) + '80');
        Line()
          .width('100%')
          .height('100%')
          .startPoint([this.getEdgeMidX(edge), this.getEdgeMidY(edge)])
          .endPoint([this.getEdgeEndX(edge), this.getEdgeEndY(edge)])
<<<<<<< HEAD
          .strokeWidth(2)
          .stroke(this.getEdgeColor(edge) + 'BB');
        if (this.hasEdgeLabel(edge)) {
          Text(this.getEdgeLabelText(edge))
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getEdgeColor(edge))
            .backgroundColor('#FFFFFFEE')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(6)
            .border({ width: 1, color: this.getEdgeColor(edge) + '60' })
            .position({ x: this.getEdgeMidX(edge), y: this.getEdgeMidY(edge) })
            .translate({ x: '-50%', y: '-50%' })
            .markAnchor({ x: '50%', y: '50%' });
        }
      }
      .width('100%')
      .height('100%')
      .clip(true)
=======
          .strokeWidth(1.5)
          .strokeDashArray([4, 3])
          .stroke(this.getEdgeColor(edge) + '80');
        if (this.hasEdgeLabel(edge)) {
          Text(this.getEdgeLabelText(edge))
            .fontSize(9)
            .fontColor(this.getEdgeColor(edge))
            .backgroundColor('#FFFFFF')
            .padding({ left: 5, right: 5, top: 1, bottom: 1 })
            .borderRadius(6)
            .border({ width: 0.5, color: this.getEdgeColor(edge) + '40' });
        }
      }
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
      .position({ x: 0, y: 0 });
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(48).height(48).color(GlobalTheme.THEME_COLOR);
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
          Text('⚠️').fontSize(48).margin({ bottom: 10 });
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
      } else {
        Stack() {
<<<<<<< HEAD
          Column()
            .width('100%')
            .height('100%')
            .radialGradient({
              center: ['50%', '50%'],
              radius: '70%',
              colors: [['#F0F5FF', 0], ['#E8EEFA', 0.4], ['#EDEFF5', 1]]
            });

          Column() {
            ForEach(this.graphEdges, (edge: GraphEdge) => {
              this.buildEdgeLine(edge);
            }, (edge: GraphEdge) => 'edge-' + edge.id);
          }
          .width('100%')
          .height('100%');

          Column() {
            ForEach(this.graphNodes, (node: GraphNode) => {
              KnowledgeNode({
                node: this.createMappedNode(node),
                opacityValue: this.getNodeOpacity(node),
                onNodeClick: (clickedNode: GraphNode) => {
                  this.handleNodeClick(clickedNode);
                },
                onNodeDragStart: (_draggedNode: GraphNode) => {
                  this.handleNodeDragStart(node);
                },
                onNodeDragUpdate: (_draggedNode: GraphNode, offsetX: number, offsetY: number) => {
                  this.handleNodeDragUpdate(node, offsetX, offsetY);
                },
                onNodeDragEnd: (_draggedNode: GraphNode) => {
                  this.handleNodeDragEnd(node);
=======
          Column() {
            ForEach(this.graphEdges, (edge: GraphEdge) => {
              this.buildEdgeLine(edge);
            }, (edge: GraphEdge) => 'edge-' + edge.id);
          }
          .width('100%')
          .height('100%');

          Column() {
            ForEach(this.graphNodes, (node: GraphNode) => {
              KnowledgeNode({
                node: this.createMappedNode(node),
                opacityValue: 1.0,
                onNodeClick: (clickedNode: GraphNode) => {
                  this.handleNodeClick(node);
                },
                onNodeDragStart: (draggedNode: GraphNode) => {
                  this.handleNodeDragStart(node);
                },
                onNodeDragUpdate: (draggedNode: GraphNode, offsetX: number, offsetY: number) => {
                  this.handleNodeDragUpdate(node, offsetX, offsetY);
                },
                onNodeDragEnd: () => {
                  this.handleNodeDragEnd();
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
                }
              });
            }, (node: GraphNode) => 'node-' + node.id);
          }
          .width('100%')
          .height('100%');
        }
        .width('100%')
        .layoutWeight(1)
        .clip(true)
        .gesture(
          PanGesture({ fingers: 1, distance: 5 })
            .onActionStart(() => {
              this.lastPanX = 0;
              this.lastPanY = 0;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.panOffsetX += event.offsetX - this.lastPanX;
              this.panOffsetY += event.offsetY - this.lastPanY;
              this.lastPanX = event.offsetX;
              this.lastPanY = event.offsetY;
            })
        )
        .onAreaChange((_oldArea: Area, newArea: Area) => {
          const w: number = Number(newArea.width);
          const h: number = Number(newArea.height);
          if (w > 0 && h > 0) {
            this.canvasWidth = w;
            this.canvasHeight = h;
            this.calculateAutoFit();
          }
        });

        Row() {
<<<<<<< HEAD
          Text('● ' + this.graphNodes.length + ' 节点')
            .fontSize(10).fontColor('#888888');
          Text('  ○ ' + this.graphEdges.length + ' 关系')
            .fontSize(10).fontColor('#888888');
          Row({ space: 6 }) {
            Text('＋')
              .fontSize(15).fontColor('#1677FF').fontWeight(FontWeight.Bold)
              .padding({ left: 4, right: 4 })
              .onClick(() => { this.scaleValue = Math.min(this.scaleValue + 0.12, 2.0); });
            Text('－')
              .fontSize(16).fontColor('#1677FF').fontWeight(FontWeight.Bold)
              .padding({ left: 4, right: 4 })
              .onClick(() => { this.scaleValue = Math.max(this.scaleValue - 0.12, 0.5); });
            Text('⟲')
              .fontSize(14).fontColor('#52C41A')
              .padding({ left: 4, right: 4 })
              .onClick(() => {
=======
          Text('节点: ' + this.graphNodes.length)
            .fontSize(11).fontColor('#999999');
          Text(' | 关系: ' + this.graphEdges.length)
            .fontSize(11).fontColor('#999999');
          Row({ space: 8 }) {
            Text('🔍+')
              .fontSize(14).fontColor('#1677FF')
              .onClick(() => {
                this.scaleValue = Math.min(this.scaleValue + 0.1, 2.0);
              });
            Text('🔍-')
              .fontSize(14).fontColor('#1677FF')
              .onClick(() => {
                this.scaleValue = Math.max(this.scaleValue - 0.1, 0.5);
              });
            Text('🔄')
              .fontSize(14).fontColor('#1677FF')
              .onClick(() => {
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
                this.panOffsetX = 0;
                this.panOffsetY = 0;
                this.scaleValue = 1;
                this.calculateAutoFit();
              });
          }
          .margin({ left: 8 });
        }
        .width('100%')
<<<<<<< HEAD
        .padding({ left: 10, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#FAFBFC')
        .border({ width: { top: 0.5 }, color: '#E8E8E8' })
=======
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#FFFFFF')
>>>>>>> be2e94180e922d2dd2370b7cce99c77ea7f8eaba
        .justifyContent(FlexAlign.SpaceBetween);

        if (this.showNodePanel && this.selectedNode) {
          Stack() {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#00000044')
              .onClick(() => {
                this.closeNodePanel();
              });

            Column() {
              Row() {
                Column({ space: 4 }) {
                  Text(this.selectedNode.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333');
                  Text(this.getTypeName(this.selectedNode.type) + ' · ID:' + this.selectedNode.id)
                    .fontSize(12)
                    .fontColor('#999999');
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);

                Text('✕')
                  .fontSize(18)
                  .fontColor('#999999')
                  .padding(8)
                  .onClick(() => {
                    this.closeNodePanel();
                  });
              }
              .width('100%')
              .padding({ left: 20, right: 16, top: 16, bottom: 12 });

              if (this.selectedNode.description && this.selectedNode.description.length > 0) {
                Text(this.selectedNode.description)
                  .fontSize(13)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .textAlign(TextAlign.Start)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .padding({ left: 20, right: 20, bottom: 12 });
              }

              Divider().color('#F0F0F0');

              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text('📄')
                    .fontSize(22);
                  Text('显示详情')
                    .fontSize(11)
                    .fontColor('#1677FF');
                }
                .layoutWeight(1)
                .height(64)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#F0F7FF')
                .borderRadius(12)
                .onClick(() => {
                  this.navigateToDetail(this.selectedNode!);
                });

                Column({ space: 4 }) {
                  Text('🔍')
                    .fontSize(22);
                  Text('以该节点为中心展开')
                    .fontSize(11)
                    .fontColor('#52C41A');
                }
                .layoutWeight(1)
                .height(64)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#F6FFED')
                .borderRadius(12)
                .onClick(() => {
                  this.expandAroundNode(this.selectedNode!.id);
                });
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 16, bottom: 24 });
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius({ topLeft: 20, topRight: 20 })
            .alignItems(HorizontalAlign.Center)
            .position({ x: 0, y: '40%' });
          }
          .width('100%')
          .height('100%')
          .position({ x: 0, y: 0 });
        }
      }
    }
    .width('100%')
    .height('100%');
  }
}
