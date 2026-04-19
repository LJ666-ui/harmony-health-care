export type KnowledgeNodeType = 'Disease' | 'Symptom' | 'Herbal' | 'Prescription' | 'Therapy';
export type KnowledgeRelationType = 'HAS_SYMPTOM' | 'RELIEVED_BY_HERBAL' | 'PART_OF_PRESCRIPTION' | 'RECOMMENDS_THERAPY' | 'TREATS_DISEASE' | 'COMBINES_WITH';

export interface KnowledgeNode {
  id: string;
  name: string;
  type: KnowledgeNodeType;
  description: string;
  detail: string;
  radius: number;
  x?: number;
  y?: number;
  vx?: number;
  vy?: number;
}

export interface KnowledgeEdge {
  id: string;
  sourceId: string;
  targetId: string;
  relation: KnowledgeRelationType;
  label: string;
  weight: number;
}

export interface KnowledgeGraphData {
  nodes: KnowledgeNode[];
  edges: KnowledgeEdge[];
  centerId: string;
  summary: string;
  explanation: string;
  relationTypes: string[];
}

const diseaseNodes: KnowledgeNode[] = [
  { id: 'd1', name: '高血压', type: 'Disease', description: '常见慢性心血管疾病', detail: '以体循环动脉压增高为主要特征的临床综合征', radius: 22 },
  { id: 'd2', name: '糖尿病', type: 'Disease', description: '代谢性疾病', detail: '因胰岛素分泌缺陷或其生物作用受损引起的代谢性疾病', radius: 22 },
  { id: 'd3', name: '冠心病', type: 'Disease', description: '冠状动脉粥样硬化性心脏病', detail: '冠状动脉发生粥样硬化引起管腔狭窄或闭塞', radius: 22 },
  { id: 'd4', name: '失眠', type: 'Disease', description: '睡眠障碍', detail: '入睡困难、睡眠维持障碍导致睡眠质量下降', radius: 20 },
  { id: 'd5', name: '胃炎', type: 'Disease', description: '胃黏膜炎症', detail: '各种病因引起的胃黏膜急性或慢性炎症', radius: 20 },
  { id: 'd6', name: '颈椎病', type: 'Disease', description: '颈椎退行性疾病', detail: '颈椎椎间盘退行性变及其继发性椎间关节退行性变', radius: 20 },
  { id: 'd7', name: '关节炎', type: 'Disease', description: '关节炎症性疾病', detail: '关节及其周围组织的炎性疾病', radius: 20 },
  { id: 'd8', name: '感冒', type: 'Disease', description: '上呼吸道感染', detail: '病毒引起的急性上呼吸道感染', radius: 18 }
];

const symptomNodes: KnowledgeNode[] = [
  { id: 's1', name: '头痛', type: 'Symptom', description: '头部疼痛症状', detail: '头颅上半部的疼痛', radius: 16 },
  { id: 's2', name: '头晕', type: 'Symptom', description: '眩晕感', detail: '空间定位障碍引起的自我或周围物体运动幻觉', radius: 16 },
  { id: 's3', name: '心悸', type: 'Symptom', description: '心跳异常感', detail: '自觉心跳快而强并伴有心前区不适感', radius: 16 },
  { id: 's4', name: '乏力', type: 'Symptom', description: '疲劳无力', detail: '自觉身体疲乏、精神倦怠', radius: 16 },
  { id: 's5', name: '多饮', type: 'Symptom', description: '口渴多饮', detail: '饮水次数和量明显增多', radius: 16 },
  { id: 's6', name: '多尿', type: 'Symptom', description: '尿频尿多', detail: '排尿次数和尿量明显增多', radius: 16 },
  { id: 's7', name: '胸痛', type: 'Symptom', description: '胸部疼痛', detail: '胸骨后或心前区疼痛', radius: 16 },
  { id: 's8', name: '胃痛', type: 'Symptom', description: '胃部疼痛', detail: '上腹部疼痛不适', radius: 16 },
  { id: 's9', name: '颈痛', type: 'Symptom', description: '颈部疼痛', detail: '颈部酸痛、僵硬', radius: 16 },
  { id: 's10', name: '关节痛', type: 'Symptom', description: '关节疼痛', detail: '关节部位疼痛肿胀', radius: 16 },
  { id: 's11', name: '咳嗽', type: 'Symptom', description: '咳嗽症状', detail: '呼吸道受刺激引起的保护性反射', radius: 16 },
  { id: 's12', name: '发热', type: 'Symptom', description: '体温升高', detail: '体温超过正常范围', radius: 16 }
];

const herbalNodes: KnowledgeNode[] = [
  { id: 'h1', name: '黄芪', type: 'Herbal', description: '补气要药', detail: '补气固表、利尿托毒、排脓敛疮生肌', radius: 18 },
  { id: 'h2', name: '丹参', type: 'Herbal', description: '活血化瘀', detail: '活血祛瘀、通经止痛、清心除烦、凉血消痈', radius: 18 },
  { id: 'h3', name: '天麻', type: 'Herbal', description: '息风止痉', detail: '息风止痉、平抑肝阳、祛风通络', radius: 18 },
  { id: 'h4', name: '酸枣仁', type: 'Herbal', description: '养心安神', detail: '养心补肝、宁心安神、敛汗生津', radius: 18 },
  { id: 'h5', name: '山楂', type: 'Herbal', description: '消食化积', detail: '消食健胃、行气散瘀、化浊降脂', radius: 17 },
  { id: 'h6', name: '葛根', type: 'Herbal', description: '解肌退热', detail: '解肌退热、透疹、生津止渴、升阳止泻', radius: 17 },
  { id: 'h7', name: '当归', type: 'Herbal', description: '补血活血', detail: '补血活血、调经止痛、润肠通便', radius: 18 },
  { id: 'h8', name: '川芎', type: 'Herbal', description: '活血行气', detail: '活血行气、祛风止痛', radius: 17 },
  { id: 'h9', name: '茯苓', type: 'Herbal', description: '利水渗湿', detail: '利水渗湿、健脾宁心', radius: 17 },
  { id: 'h10', name: '甘草', type: 'Herbal', description: '调和诸药', detail: '补脾益气、清热解毒、祛痰止咳、缓急止痛', radius: 17 },
  { id: 'h11', name: '枸杞子', type: 'Herbal', description: '滋补肝肾', detail: '滋补肝肾、益精明目', radius: 17 },
  { id: 'h12', name: '菊花', type: 'Herbal', description: '清热明目', detail: '疏散风热、平抑肝阳、清肝明目、清热解毒', radius: 16 },
  { id: 'h13', name: '金银花', type: 'Herbal', description: '清热解毒', detail: '清热解毒、疏散风热', radius: 16 },
  { id: 'h14', name: '桂枝', type: 'Herbal', description: '发汗解肌', detail: '发汗解肌、温通经脉、助阳化气、平冲降逆', radius: 17 },
  { id: 'h15', name: '白芍', type: 'Herbal', description: '养血柔肝', detail: '养血调经、敛阴止汗、柔肝止痛、平抑肝阳', radius: 17 },
  { id: 'h16', name: '杜仲', type: 'Herbal', description: '补肝肾强筋骨', detail: '补肝肾、强筋骨、安胎', radius: 17 },
  { id: 'h17', name: '牛膝', type: 'Herbal', description: '逐瘀通经', detail: '逐瘀通经、补肝肾、强筋骨、利尿通淋、引血下行', radius: 16 },
  { id: 'h18', name: '独活', type: 'Herbal', description: '祛风除湿', detail: '祛风除湿、通痹止痛', radius: 16 },
  { id: 'h19', name: '防风', type: 'Herbal', description: '解表祛风', detail: '祛风解表、胜湿止痛、止痉', radius: 16 },
  { id: 'h20', name: '生姜', type: 'Herbal', description: '发汗解表', detail: '解表散寒、温中止呕、化痰止咳、解鱼蟹毒', radius: 16 }
];

const prescriptionNodes: KnowledgeNode[] = [
  { id: 'p1', name: '六味地黄丸', type: 'Prescription', description: '滋阴补肾经典方', detail: '熟地黄、山茱萸、山药等组成', radius: 19 },
  { id: 'p2', name: '归脾汤', type: 'Prescription', description: '益气补血健脾养心方', detail: '白术、茯神、黄芪等组成', radius: 19 },
  { id: 'p3', name: '血府逐瘀汤', type: 'Prescription', description: '活血化瘀代表方', detail: '桃仁、红花、当归、川芎等组成', radius: 19 },
  { id: 'p4', name: '半夏泻心汤', type: 'Prescription', description: '调和肠胃方', detail: '半夏、黄芩、干姜等组成', radius: 18 },
  { id: 'p5', name: '羌活胜湿汤', type: 'Prescription', description: '祛风胜湿方', detail: '羌活、独活、藁本等组成', radius: 18 },
  { id: 'p6', name: '银翘散', type: 'Prescription', description: '辛凉解表方', detail: '金银花、连翘、薄荷等组成', radius: 18 }
];

const therapyNodes: KnowledgeNode[] = [
  { id: 't1', name: '针灸疗法', type: 'Therapy', description: '传统中医疗法', detail: '通过针刺或艾灸人体穴位治疗疾病', radius: 18 },
  { id: 't2', name: '推拿按摩', type: 'Therapy', description: '手法治疗', detail: '运用手法作用于人体表面穴位进行治疗', radius: 18 },
  { id: 't3', name: '太极拳', type: 'Therapy', description: '养生功法', detail: '中国传统拳术，具有健身养生功效', radius: 17 }
];

let edgeIdCounter: number = 1;

function addEdge(edges: KnowledgeEdge[], sourceId: string, targetId: string, relation: KnowledgeRelationType, label: string, weight?: number): void {
  edges.push({
    id: 'e' + edgeIdCounter++,
    sourceId: sourceId,
    targetId: targetId,
    relation: relation,
    label: label,
    weight: weight || 1
  });
}

function buildEdges(): KnowledgeEdge[] {
  const edges: KnowledgeEdge[] = [];

  addEdge(edges, 'd1', 's1', 'HAS_SYMPTOM', '引起', 2);
  addEdge(edges, 'd1', 's2', 'HAS_SYMPTOM', '引起', 2);
  addEdge(edges, 'd1', 's7', 'HAS_SYMPTOM', '引起', 1);
  addEdge(edges, 'd1', 'h1', 'RELIEVED_BY_HERBAL', '缓解', 2);
  addEdge(edges, 'd1', 'h2', 'RELIEVED_BY_HERBAL', '缓解', 2);
  addEdge(edges, 'd1', 'h6', 'RELIEVED_BY_HERBAL', '缓解', 2);
  addEdge(edges, 'd1', 'p3', 'RECOMMENDS_THERAPY', '推荐', 2);
  addEdge(edges, 'd1', 't1', 'RECOMMENDS_THERAPY', '辅助', 1);

  addEdge(edges, 'd2', 's5', 'HAS_SYMPTOM', '引起', 2);
  addEdge(edges, 'd2', 's6', 'HAS_SYMPTOM', '引起', 2);
  addEdge(edges, 'd2', 's4', 'HAS_SYMPTOM', '引起', 1);
  addEdge(edges, 'd2', 'h1', 'RELIEVED_BY_HERBAL', '调节', 2);
  addEdge(edges, 'd2', 'h11', 'RELIEVED_BY_HERBAL', '滋补', 1);
  addEdge(edges, 'd2', 'p1', 'RECOMMENDS_THERAPY', '调理', 2);

  addEdge(edges, 'd3', 's3', 'HAS_SYMPTOM', '典型症状', 2);
  addEdge(edges, 'd3', 's7', 'HAS_SYMPTOM', '典型症状', 2);
  addEdge(edges, 'd3', 'h2', 'RELIEVED_BY_HERBAL', '改善', 2);
  addEdge(edges, 'd3', 'h7', 'RELIEVED_BY_HERBAL', '活血', 2);
  addEdge(edges, 'd3', 'h8', 'RELIEVED_BY_HERBAL', '行气', 1);
  addEdge(edges, 'd3', 'p3', 'RECOMMENDS_THERAPY', '主方', 3);
  addEdge(edges, 'd3', 't2', 'RECOMMENDS_THERAPY', '辅助', 1);

  addEdge(edges, 'd4', 's1', 'HAS_SYMPTOM', '伴发', 1);
  addEdge(edges, 'd4', 's4', 'HAS_SYMPTOM', '主要表现', 2);
  addEdge(edges, 'd4', 'h3', 'RELIEVED_BY_HERBAL', '安神', 2);
  addEdge(edges, 'd4', 'h4', 'RELIEVED_BY_HERBAL', '助眠', 2);
  addEdge(edges, 'd4', 'h9', 'RELIEVED_BY_HERBAL', '健脾', 1);
  addEdge(edges, 'd4', 'p2', 'RECOMMENDS_THERAPY', '主方', 3);
  addEdge(edges, 'd4', 't1', 'RECOMMENDS_THERAPY', '有效', 2);

  addEdge(edges, 'd5', 's8', 'HAS_SYMPTOM', '主要症状', 2);
  addEdge(edges, 'd5', 'h5', 'RELIEVED_BY_HERBAL', '消食', 2);
  addEdge(edges, 'd5', 'h9', 'RELIEVED_BY_HERBAL', '和胃', 1);
  addEdge(edges, 'd5', 'p4', 'RECOMMENDS_THERAPY', '主方', 2);

  addEdge(edges, 'd6', 's9', 'HAS_SYMPTOM', '典型症状', 2);
  addEdge(edges, 'd6', 's1', 'HAS_SYMPTOM', '伴发', 1);
  addEdge(edges, 'd6', 'h2', 'RELIEVED_BY_HERBAL', '活血', 1);
  addEdge(edges, 'd6', 'h16', 'RELIEVED_BY_HERBAL', '强筋', 2);
  addEdge(edges, 'd6', 'h17', 'RELIEVED_BY_HERBAL', '通络', 1);
  addEdge(edges, 'd6', 't2', 'RECOMMENDS_THERAPY', '推荐', 2);
  addEdge(edges, 'd6', 't3', 'RECOMMENDS_THERAPY', '锻炼', 2);

  addEdge(edges, 'd7', 's10', 'HAS_SYMPTOM', '主要症状', 2);
  addEdge(edges, 'd7', 's4', 'HAS_SYMPTOM', '伴发', 1);
  addEdge(edges, 'd7', 'h16', 'RELIEVED_BY_HERBAL', '强筋骨', 2);
  addEdge(edges, 'd7', 'h17', 'RELIEVED_BY_HERBAL', '引血下行', 1);
  addEdge(edges, 'd7', 'h18', 'RELIEVED_BY_HERBAL', '祛风湿', 2);
  addEdge(edges, 'd7', 'h19', 'RELIEVED_BY_HERBAL', '止痛', 1);
  addEdge(edges, 'd7', 'p5', 'RECOMMENDS_THERAPY', '主方', 2);
  addEdge(edges, 'd7', 't2', 'RECOMMENDS_THERAPY', '辅助', 2);

  addEdge(edges, 'd8', 's11', 'HAS_SYMPTOM', '主要症状', 2);
  addEdge(edges, 'd8', 's12', 'HAS_SYMPTOM', '常见症状', 2);
  addEdge(edges, 'd8', 's4', 'HAS_SYMPTOM', '伴发', 1);
  addEdge(edges, 'd8', 'h13', 'RELIEVED_BY_HERBAL', '清热', 2);
  addEdge(edges, 'd8', 'h14', 'RELIEVED_BY_HERBAL', '解表', 2);
  addEdge(edges, 'd8', 'h19', 'RELIEVED_BY_HERBAL', '祛风', 1);
  addEdge(edges, 'd8', 'h20', 'RELIEVED_BY_HERBAL', '发汗', 2);
  addEdge(edges, 'd8', 'p6', 'RECOMMENDS_THERAPY', '主方', 3);

  addEdge(edges, 'p1', 'h1', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p1', 'h11', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p1', 'h9', 'PART_OF_PRESCRIPTION', '含', 1);
  addEdge(edges, 'p2', 'h1', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p2', 'h4', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p2', 'h9', 'PART_OF_PRESCRIPTION', '含', 1);
  addEdge(edges, 'p3', 'h2', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p3', 'h7', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p3', 'h8', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p4', 'h5', 'COMBINES_WITH', '配伍', 1);
  addEdge(edges, 'p4', 'h9', 'COMBINES_WITH', '配伍', 1);
  addEdge(edges, 'p5', 'h18', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p5', 'h19', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p6', 'h13', 'PART_OF_PRESCRIPTION', '含', 2);
  addEdge(edges, 'p6', 'h12', 'PART_OF_PRESCRIPTION', '含', 2);

  addEdge(edges, 'h1', 'h10', 'COMBINES_WITH', '常配', 2);
  addEdge(edges, 'h2', 'h8', 'COMBINES_WITH', '常配', 2);
  addEdge(edges, 'h7', 'h8', 'COMBINES_WITH', '常配', 2);
  addEdge(edges, 'h14', 'h15', 'COMBINES_WITH', '常配', 2);

  return edges;
}

function concatArrays<T>(arr1: T[], arr2: T[]): T[] {
  const result: T[] = [];
  for (let i = 0; i < arr1.length; i++) { result.push(arr1[i]); }
  for (let j = 0; j < arr2.length; j++) { result.push(arr2[j]); }
  return result;
}

export function buildKnowledgeGraphMock(): KnowledgeGraphData {
  const allNodes: KnowledgeNode[] = [];
  allNodes = concatArrays(allNodes, diseaseNodes);
  allNodes = concatArrays(allNodes, symptomNodes);
  allNodes = concatArrays(allNodes, herbalNodes);
  allNodes = concatArrays(allNodes, prescriptionNodes);
  allNodes = concatArrays(allNodes, therapyNodes);

  const edges: KnowledgeEdge[] = buildEdges();

  const summary: string = '中医知识图谱包含' + allNodes.length + '个节点（' + diseaseNodes.length + '种疾病、' + symptomNodes.length + '个症状、' + herbalNodes.length + '味药材、' + prescriptionNodes.length + '个方剂、' + therapyNodes.length + '种疗法）和' + edges.length + '条关系边';

  return {
    nodes: allNodes,
    edges: edges,
    centerId: 'd1',
    summary: summary,
    explanation: '该图谱展示了中医领域疾病-症状-药材-方剂-疗法之间的关联关系，可用于健康知识学习和智能问答。',
    relationTypes: ['HAS_SYMPTOM', 'RELIEVED_BY_HERBAL', 'PART_OF_PRESCRIPTION', 'RECOMMENDS_THERAPY', 'TREATS_DISEASE', 'COMBINES_WITH']
  };
}

function filterNodesByIds(allNodes: KnowledgeNode[], ids: string[]): KnowledgeNode[] {
  const result: KnowledgeNode[] = [];
  for (let i = 0; i < allNodes.length; i++) {
    for (let j = 0; j < ids.length; j++) {
      if (allNodes[i].id === ids[j]) {
        result.push(allNodes[i]);
        break;
      }
    }
  }
  return result;
}

function filterEdgesByNodeIds(edges: KnowledgeEdge[], nodeIds: string[]): KnowledgeEdge[] {
  const result: KnowledgeEdge[] = [];
  for (let i = 0; i < edges.length; i++) {
    let hasSource = false;
    let hasTarget = false;
    for (let j = 0; j < nodeIds.length; j++) {
      if (edges[i].sourceId === nodeIds[j]) { hasSource = true; }
      if (edges[i].targetId === nodeIds[j]) { hasTarget = true; }
    }
    if (hasSource && hasTarget) {
      result.push(edges[i]);
    }
  }
  return result;
}

function extractUniqueRelations(edges: KnowledgeEdge[]): string[] {
  const seen: Record<string, boolean> = {};
  const result: string[] = [];
  for (let i = 0; i < edges.length; i++) {
    const r = edges[i].relation;
    if (!seen[r]) {
      seen[r] = true;
      result.push(r);
    }
  }
  return result;
}

function findDiseaseNode(nodes: KnowledgeNode[]): KnowledgeNode | undefined {
  for (let i = 0; i < nodes.length; i++) {
    if (nodes[i].type === 'Disease') { return nodes[i]; }
  }
  return nodes.length > 0 ? nodes[0] : undefined;
}

export function exploreKnowledgeGraph(question: string, maxNodes?: number): KnowledgeGraphData {
  const limit: number = maxNodes || 50;
  const fullGraph: KnowledgeGraphData = buildKnowledgeGraphMock();
  const questionLower: string = question.toLowerCase();
  let filteredNodes: KnowledgeNode[] = [];
  const nodeIds: string[] = [];

  if (questionLower.indexOf('高血压') >= 0 || questionLower.indexOf('血压') >= 0) {
    const allowedIds = ['d1','s1','s2','s7','h1','h2','h6','p3','t1'];
    filteredNodes = filterNodesByIds(fullGraph.nodes, allowedIds);
  } else if (questionLower.indexOf('失眠') >= 0 || questionLower.indexOf('睡眠') >= 0) {
    const allowedIds = ['d4','s1','s4','h3','h4','h9','p2','t1'];
    filteredNodes = filterNodesByIds(fullGraph.nodes, allowedIds);
  } else if (questionLower.indexOf('胃炎') >= 0 || questionLower.indexOf('胃') >= 0) {
    const allowedIds = ['d5','s8','h5','h9','p4'];
    filteredNodes = filterNodesByIds(fullGraph.nodes, allowedIds);
  } else if (questionLower.indexOf('颈椎') >= 0 || questionLower.indexOf('颈') >= 0) {
    const allowedIds = ['d6','s9','h2','h16','h17','t2','t3'];
    filteredNodes = filterNodesByIds(fullGraph.nodes, allowedIds);
  } else if (questionLower.indexOf('感冒') >= 0 || questionLower.indexOf('咳嗽') >= 0) {
    const allowedIds = ['d8','s11','s12','h13','h14','h19','h20','p6'];
    filteredNodes = filterNodesByIds(fullGraph.nodes, allowedIds);
  } else {
    filteredNodes = fullGraph.nodes.slice(0, limit);
  }

  for (let i = 0; i < filteredNodes.length; i++) {
    nodeIds.push(filteredNodes[i].id);
  }

  const filteredEdges: KnowledgeEdge[] = filterEdgesByNodeIds(fullGraph.edges, nodeIds);
  const centerNode: KnowledgeNode | undefined = findDiseaseNode(filteredNodes);
  const relationTypes: string[] = extractUniqueRelations(filteredEdges);

  const cid: string = centerNode ? centerNode.id : (filteredNodes.length > 0 ? filteredNodes[0].id : '');
  const summary2: string = '根据"' + question + '"找到' + filteredNodes.length + '个相关节点和' + filteredEdges.length + '条关系';
  const explanation2: string = '已为您展开与"' + question + '"相关的中医知识子图，包含疾病、症状、药材、方剂等多维度信息。可点击节点查看详情，双击展开更多关联内容。';

  return {
    nodes: filteredNodes,
    edges: filteredEdges,
    centerId: cid,
    summary: summary2,
    explanation: explanation2,
    relationTypes: relationTypes
  };
}

export function buildKnowledgeSummaryText(graph: KnowledgeGraphData): string {
  if (!graph || !graph.nodes || graph.nodes.length === 0) {
    return '暂无知识图谱数据';
  }

  let diseaseCount: number = 0;
  let symptomCount: number = 0;
  let herbalCount: number = 0;
  let prescriptionCount: number = 0;
  let therapyCount: number = 0;

  for (let i: number = 0; i < graph.nodes.length; i++) {
    if (graph.nodes[i].type === 'Disease') { diseaseCount++; }
    else if (graph.nodes[i].type === 'Symptom') { symptomCount++; }
    else if (graph.nodes[i].type === 'Herbal') { herbalCount++; }
    else if (graph.nodes[i].type === 'Prescription') { prescriptionCount++; }
    else if (graph.nodes[i].type === 'Therapy') { therapyCount++; }
  }

  return '当前图谱包含：' + diseaseCount + '种疾病、' + symptomCount + '个症状、' + herbalCount + '味药材、' + prescriptionCount + '个方剂、' + therapyCount + '种疗法，共' + graph.edges.length + '条关联关系';
}
