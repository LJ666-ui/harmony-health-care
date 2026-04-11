// 全局样式系统

// 颜色类型
interface TextColors {
  primary: string;
  secondary: string;
  white: string;
}

interface ColorsType {
  primary: string;
  background: string;
  text: TextColors;
}

// 字体大小类型
interface FontSizesType {
  title: number;
  body: number;
  button: number;
}

// 间距类型
interface SpacingType {
  large: number;
  medium: number;
  small: number;
}

// 页面容器样式类型
interface PageContainerStyle {
  width: string;
  height: string;
  justifyContent: string;
  alignItems: string;
  backgroundColor: string;
}

// 标题样式类型
interface TitleStyle {
  fontSize: number;
  fontWeight: number;
  fontColor: string;
  marginBottom: number;
}

// 按钮样式类型
interface ButtonStyle {
  width: number;
  height: number;
  fontSize: number;
  fontWeight: number;
  fontColor: string;
  backgroundColor: string;
  borderRadius: number;
}

// 样式类类型
interface StylesType {
  pageContainer: PageContainerStyle;
  title: TitleStyle;
  primaryButton: ButtonStyle;
}

// 颜色变量
export const Colors: ColorsType = {
  // 主色
  primary: '#1677FF',
  // 背景色
  background: '#F5F7FA',
  // 文字色
  text: {
    primary: '#333333',
    secondary: '#666666',
    white: '#FFFFFF'
  }
};

// 字体大小变量
export const FontSizes: FontSizesType = {
  title: 32,
  body: 18,
  button: 18
};

// 间距变量
export const Spacing: SpacingType = {
  large: 40,
  medium: 20,
  small: 10
};

// 通用样式类
export const Styles: StylesType = {
  // 页面容器样式（居中Column）
  pageContainer: {
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: Colors.background
  },
  
  // 标题样式
  title: {
    fontSize: FontSizes.title,
    fontWeight: 700,
    fontColor: Colors.primary,
    marginBottom: Spacing.large
  },
  
  // 主按钮样式
  primaryButton: {
    width: 220,
    height: 50,
    fontSize: FontSizes.button,
    fontWeight: 500,
    fontColor: Colors.text.white,
    backgroundColor: Colors.primary,
    borderRadius: 8
  }
};