export interface HerbalInfo {
  id: string;
  name: string;
  alias: string[];
  category: string;
  nature: string;
  taste: string;
  meridian: string[];
  efficacy: string[];
  indications: string[];
  usage: string;
  dosage: string;
  caution: string;
  image: string;
  isCollected: boolean;
}

export const HERBAL_CATEGORIES: string[] = [
  '全部',
  '补气药',
  '补血药',
  '补阴药',
  '补阳药',
  '清热药'
];

export const NATURE_TYPES: string[] = ['寒', '热', '温', '凉', '平'];

export const TASTE_TYPES: string[] = ['甘', '苦', '辛', '酸', '咸', '淡', '涩'];

export const SORT_OPTIONS: string[] = ['默认排序', '名称升序', '名称降序'];

export const herbalMockData: HerbalInfo[] = [
  {
    id: '1',
    name: '人参',
    alias: ['棒槌', '神草', '地精'],
    category: '补气药',
    nature: '微温',
    taste: '甘、微苦',
    meridian: ['脾', '肺', '心', '肾'],
    efficacy: ['大补元气', '复脉固脱', '补脾益肺', '生津养血', '安神益智'],
    indications: ['体虚欲脱', '肢冷脉微', '脾虚食少', '气血津液不足', '惊悸失眠'],
    usage: '煎服，3-9g，另煎兑入',
    dosage: '3-9g',
    caution: '不宜与藜芦、五灵脂同用',
    image: '',
    isCollected: false
  },
  {
    id: '2',
    name: '黄芪',
    alias: ['黄耆', '北芪'],
    category: '补气药',
    nature: '微温',
    taste: '甘',
    meridian: ['脾', '肺'],
    efficacy: ['补气升阳', '固表止汗', '利水消肿', '生津养血', '行滞通痹', '托毒排脓', '敛疮生肌'],
    indications: ['气虚乏力', '中气下陷', '久泻脱肛', '便血崩漏', '表虚自汗'],
    usage: '煎服，9-30g',
    dosage: '9-30g',
    caution: '表实邪盛、气滞湿阻者慎用',
    image: '',
    isCollected: true
  },
  {
    id: '3',
    name: '当归',
    alias: ['秦归', '云岀', '西当归'],
    category: '补血药',
    nature: '温',
    taste: '甘、辛',
    meridian: ['肝', '心', '脾'],
    efficacy: ['补血活血', '调经止痛', '润肠通便'],
    indications: ['血虚萎黄', '眩晕心悸', '月经不调', '经闭痛经', '虚寒腹痛'],
    usage: '煎服，6-12g',
    dosage: '6-12g',
    caution: '湿盛中满、大便溏泄者慎用',
    image: '',
    isCollected: false
  },
  {
    id: '4',
    name: '熟地黄',
    alias: ['熟地'],
    category: '补血药',
    nature: '微温',
    taste: '甘',
    meridian: ['肝', '肾'],
    efficacy: ['补血滋阴', '益精填髓'],
    indications: ['血虚萎黄', '心悸怔忡', '月经不调', '崩漏下血', '肝肾阴虚'],
    usage: '煎服，9-15g',
    dosage: '9-15g',
    caution: '脾胃虚弱、气滞痰多者慎用',
    image: '',
    isCollected: true
  },
  {
    id: '5',
    name: '阿胶',
    alias: ['驴皮胶', '傅致胶'],
    category: '补血药',
    nature: '平',
    taste: '甘',
    meridian: ['肺', '肝', '肾'],
    efficacy: ['补血止血', '滋阴润燥'],
    indications: ['血虚萎黄', '眩晕心悸', '肌痿无力', '心烦不眠', '虚风内动'],
    usage: '烊化兑服，3-9g',
    dosage: '3-9g',
    caution: '脾胃虚弱、消化不良者慎用',
    image: '',
    isCollected: false
  },
  {
    id: '6',
    name: '麦冬',
    alias: ['麦门冬', '寸冬'],
    category: '补阴药',
    nature: '微寒',
    taste: '甘、微苦',
    meridian: ['肺', '胃', '心'],
    efficacy: ['养阴生津', '润肺清心'],
    indications: ['肺燥干咳', '阴虚痨嗽', '喉痹咽痛', '津伤口渴', '内热消渴'],
    usage: '煎服，6-12g',
    dosage: '6-12g',
    caution: '风寒咳嗽、脾胃虚寒者慎用',
    image: '',
    isCollected: false
  },
  {
    id: '7',
    name: '枸杞子',
    alias: ['枸杞', '苟起子'],
    category: '补阴药',
    nature: '平',
    taste: '甘',
    meridian: ['肝', '肾'],
    efficacy: ['滋补肝肾', '益精明目'],
    indications: ['虚劳精亏', '腰膝酸痛', '眩晕耳鸣', '目昏不明'],
    usage: '煎服，6-12g',
    dosage: '6-12g',
    caution: '外有实邪、脾虚有湿及泄泻者忌服',
    image: '',
    isCollected: true
  },
  {
    id: '8',
    name: '鹿茸',
    alias: ['斑龙珠'],
    category: '补阳药',
    nature: '温',
    taste: '甘、咸',
    meridian: ['肾', '肝'],
    efficacy: ['壮肾阳', '益精血', '强筋骨', '调冲任', '托疮毒'],
    indications: ['肾阳不足', '精血亏虚', '阳痿滑精', '宫冷不孕', '羸瘦神疲'],
    usage: '研末吞服，1-2g；或入丸散',
    dosage: '1-2g',
    caution: '阴虚阳亢、血分有热、胃火炽盛者禁用',
    image: '',
    isCollected: false
  },
  {
    id: '9',
    name: '杜仲',
    alias: ['思仙', '木绵'],
    category: '补阳药',
    nature: '温',
    taste: '甘',
    meridian: ['肝', '肾'],
    efficacy: ['补肝肾', '强筋骨', '安胎'],
    indications: ['肾虚腰痛', '筋骨无力', '妊娠漏血', '胎动不安', '高血压症'],
    usage: '煎服，6-10g',
    dosage: '6-10g',
    caution: '阴虚火旺者慎用',
    image: '',
    isCollected: false
  },
  {
    id: '10',
    name: '金银花',
    alias: ['忍冬花', '双花', '二宝花'],
    category: '清热药',
    nature: '寒',
    taste: '甘',
    meridian: ['肺', '心', '胃'],
    efficacy: ['清热解毒', '疏散风热'],
    indications: ['痈肿疔疮', '喉痹', '丹毒', '热毒血痢', '风热感冒', '温病发热'],
    usage: '煎服，6-15g',
    dosage: '6-15g',
    caution: '脾胃虚寒者慎用',
    image: '',
    isCollected: true
  },
  {
    id: '11',
    name: '菊花',
    alias: ['甘菊', '金蕊'],
    category: '清热药',
    nature: '微寒',
    taste: '甘、苦',
    meridian: ['肺', '肝'],
    efficacy: ['散风清热', '平肝明目', '清热解毒'],
    indications: ['风热感冒', '头痛眩晕', '目赤肿痛', '眼目昏花', '疮痈肿毒'],
    usage: '煎服，5-10g',
    dosage: '5-10g',
    caution: '气虚胃寒者慎用',
    image: '',
    isCollected: false
  },
  {
    id: '12',
    name: '甘草',
    alias: ['国老', '甜草'],
    category: '补气药',
    nature: '平',
    taste: '甘',
    meridian: ['心', '肺', '脾', '胃'],
    efficacy: ['补脾益气', '清热解毒', '祛痰止咳', '缓急止痛', '调和诸药'],
    indications: ['脾胃虚弱', '倦怠乏力', '心悸气短', '咳嗽痰多', '四肢挛急疼痛'],
    usage: '煎服，2-10g',
    dosage: '2-10g',
    caution: '不宜与大戟、芫花、甘遂同用',
    image: '',
    isCollected: true
  },
  {
    id: '13',
    name: '白术',
    alias: ['于术', '冬术'],
    category: '补气药',
    nature: '温',
    taste: '甘、苦',
    meridian: ['脾', '胃'],
    efficacy: ['健脾益气', '燥湿利水', '止汗', '安胎'],
    indications: ['脾虚食少', '腹胀泄泻', '痰饮眩悸', '水肿', '自汗'],
    usage: '煎服，6-12g',
    dosage: '6-12g',
    caution: '阴虚内热、津液亏损者慎用',
    image: '',
    isCollected: false
  },
  {
    id: '14',
    name: '山药',
    alias: ['薯蓣', '怀山药'],
    category: '补气药',
    nature: '平',
    taste: '甘',
    meridian: ['脾', '肺', '肾'],
    efficacy: ['补脾养胃', '生津益肺', '补肾涩精'],
    indications: ['脾虚食少', '久泻不止', '肺虚喘咳', '肾虚遗精', '带下尿频'],
    usage: '煎服，15-30g',
    dosage: '15-30g',
    caution: '湿盛中满者不宜单用',
    image: '',
    isCollected: false
  },
  {
    id: '15',
    name: '何首乌',
    alias: ['首乌', '地精'],
    category: '补阴药',
    nature: '微温',
    taste: '苦、甘、涩',
    meridian: ['肝', '心'],
    efficacy: ['制用：补益精血、固肾乌须；生用：解毒消痈', '润肠通便', '截疟', '祛风止痒'],
    indications: ['血虚萎黄', '眩晕耳鸣', '须发早白', '腰膝酸软', '肢体麻木'],
    usage: '煎服，制首乌6-12g，生首乌3-6g',
    dosage: '制首乌6-12g',
    caution: '大便溏泄及湿痰较重者不宜用',
    image: '',
    isCollected: false
  },
  {
    id: '16',
    name: '淫羊藿',
    alias: ['仙灵脾', '羊藿'],
    category: '补阳药',
    nature: '温',
    taste: '辛、甘',
    meridian: ['肝', '肾'],
    efficacy: ['补肾阳', '强筋骨', '祛风湿'],
    indications: ['肾阳虚衰', '阳痿遗精', '筋骨痿软', '风寒湿痹', '麻木拘挛'],
    usage: '煎服，3-10g',
    dosage: '3-10g',
    caution: '阴虚火旺者不宜服',
    image: '',
    isCollected: false
  },
  {
    id: '17',
    name: '石斛',
    alias: ['金钗石斛', '黄草'],
    category: '补阴药',
    nature: '微寒',
    taste: '甘',
    meridian: ['胃', '肾'],
    efficacy: ['益胃生津', '滋阴清热'],
    indications: ['口干烦渴', '胃阴不足', '食少干呕', '病后虚热不退', '阴虚火旺'],
    usage: '煎服，6-12g（鲜品15-30g）',
    dosage: '6-12g',
    caution: '温热病早期、脾胃虚寒者不宜用',
    image: '',
    isCollected: false
  },
  {
    id: '18',
    name: '茯苓',
    alias: ['云苓', '茯菟'],
    category: '利水渗湿药',
    nature: '平',
    taste: '甘、淡',
    meridian: ['心', '肺', '脾', '肾'],
    efficacy: ['利水渗湿', '健脾', '宁心'],
    indications: ['水肿尿少', '痰饮眩悸', '脾虚食少', '便溏泄泻', '心神不安'],
    usage: '煎服，10-15g',
    dosage: '10-15g',
    caution: '阴虚而无湿热者慎用',
    image: '',
    isCollected: true
  },
  {
    id: '19',
    name: '连翘',
    alias: ['黄花条', '连壳'],
    category: '清热药',
    nature: '微寒',
    taste: '苦',
    meridian: ['肺', '心', '小肠'],
    efficacy: ['清热解毒', '消肿散结', '疏散风热'],
    indications: ['痈疽', '瘰疬', '乳痈', '丹毒', '风热感冒', '温病初起'],
    usage: '煎服，6-15g',
    dosage: '6-15g',
    caution: '脾胃虚寒及气虚脓清者不宜用',
    image: '',
    isCollected: false
  },
  {
    id: '20',
    name: '肉苁蓉',
    alias: ['大芸', '寸芸'],
    category: '补阳药',
    nature: '温',
    taste: '甘、咸',
    meridian: ['肾', '大肠'],
    efficacy: ['补肾阳', '益精血', '润肠通便'],
    indications: ['肾阳不足', '精血亏虚', '阳痿不孕', '腰膝酸软', '肠燥便秘'],
    usage: '煎服，6-10g',
    dosage: '6-10g',
    caution: '阴虚火旺、大便溏泻者忌服',
    image: '',
    isCollected: false
  }
];

export function getHerbalList(): HerbalInfo[] {
  return herbalMockData;
}

export function getHerbalById(id: string): HerbalInfo | undefined {
  for (let i = 0; i < herbalMockData.length; i++) {
    if (herbalMockData[i].id === id) {
      return herbalMockData[i];
    }
  }
  return undefined;
}

export function filterHerbals(
  category: string,
  nature?: string,
  taste?: string,
  searchKey?: string
): HerbalInfo[] {
  let filtered: HerbalInfo[] = [];

  for (let i = 0; i < herbalMockData.length; i++) {
    const herb = herbalMockData[i];
    let match = true;

    if (category && category !== '全部') {
      if (herb.category !== category) {
        match = false;
      }
    }

    if (match && nature) {
      let hasNature = false;
      for (let n = 0; n < herb.nature.length; n++) {
        if (herb.nature[n] === nature) {
          hasNature = true;
          break;
        }
      }
      if (!hasNature) {
        match = false;
      }
    }

    if (match && taste) {
      let hasTaste = false;
      for (let t = 0; t < herb.taste.length; t++) {
        if (herb.taste[t] === taste) {
          hasTaste = true;
          break;
        }
      }
      if (!hasTaste) {
        match = false;
      }
    }

    if (match && searchKey && searchKey.trim() !== '') {
      const key: string = searchKey.trim().toLowerCase();
      let found = false;

      if (herb.name.toLowerCase().indexOf(key) >= 0) {
        found = true;
      } else {
        for (let a = 0; a < herb.alias.length; a++) {
          if (herb.alias[a].toLowerCase().indexOf(key) >= 0) {
            found = true;
            break;
          }
        }
      }

      if (!found && herb.category.indexOf(key) >= 0) {
        found = true;
      }

      if (!found) {
        for (let e = 0; e < herb.efficacy.length; e++) {
          if (herb.efficacy[e].indexOf(key) >= 0) {
            found = true;
            break;
          }
        }
      }

      if (!found) {
        match = false;
      }
    }

    if (match) {
      filtered.push(herb);
    }
  }

  return filtered;
}
