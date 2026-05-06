/**
 * 无障碍工具函数库
 * 提供颜色对比度计算、WCAG验证等工具函数
 */

/**
 * RGB颜色接口
 */
export interface RGB {
  r: number;
  g: number;
  b: number;
}

/**
 * WCAG验证结果接口
 */
export interface WCAGValidationResult {
  isCompliant: boolean;
  contrastRatio: number;
  level: 'Fail' | 'AA' | 'AAA';
  recommendation: string;
}

/**
 * 无障碍工具类
 */
export class AccessibilityUtils {
  /**
   * 计算两个颜色之间的对比度
   * @param color1 颜色1（HEX格式，如 #FFFFFF）
   * @param color2 颜色2（HEX格式，如 #000000）
   * @returns 对比度比值（1-21）
   */
  public static calculateContrastRatio(color1: string, color2: string): number {
    try {
      const L1 = this.calculateRelativeLuminance(color1);
      const L2 = this.calculateRelativeLuminance(color2);
      
      const lighter = Math.max(L1, L2);
      const darker = Math.min(L1, L2);
      
      // 对比度公式：(L1 + 0.05) / (L2 + 0.05)
      const ratio = (lighter + 0.05) / (darker + 0.05);
      
      return Math.round(ratio * 100) / 100; // 保留两位小数
    } catch (error) {
      console.error('[AccessibilityUtils] 计算对比度失败:', error);
      return 1;
    }
  }
  
  /**
   * 计算相对亮度（Relative Luminance）
   * @param color HEX颜色
   * @returns 相对亮度值（0-1）
   */
  private static calculateRelativeLuminance(color: string): number {
    const rgb = this.hexToRgb(color);
    
    // Gamma校正
    const R = this.gammaCorrection(rgb.r / 255);
    const G = this.gammaCorrection(rgb.g / 255);
    const B = this.gammaCorrection(rgb.b / 255);
    
    // 相对亮度公式：L = 0.2126 * R + 0.7152 * G + 0.0722 * B
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }
  
  /**
   * Gamma校正
   * @param value RGB分量值（0-1）
   * @returns 校正后的值
   */
  private static gammaCorrection(value: number): number {
    if (value <= 0.03928) {
      return value / 12.92;
    } else {
      return Math.pow((value + 0.055) / 1.055, 2.4);
    }
  }
  
  /**
   * HEX颜色转RGB
   * @param hex HEX颜色（如 #FFFFFF 或 #FFF）
   * @returns RGB对象
   */
  public static hexToRgb(hex: string): RGB {
    // 移除#号
    hex = hex.replace(/^#/, '');
    
    // 处理简写形式（#FFF -> #FFFFFF）
    if (hex.length === 3) {
      hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    
    // 解析RGB分量
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);
    
    if (isNaN(r) || isNaN(g) || isNaN(b)) {
      throw new Error(`Invalid HEX color: #${hex}`);
    }
    
    return { r, g, b };
  }
  
  /**
   * RGB转HEX颜色
   * @param rgb RGB对象
   * @returns HEX颜色（如 #FFFFFF）
   */
  public static rgbToHex(rgb: RGB): string {
    const r = Math.round(rgb.r).toString(16).padStart(2, '0');
    const g = Math.round(rgb.g).toString(16).padStart(2, '0');
    const b = Math.round(rgb.b).toString(16).padStart(2, '0');
    return `#${r}${g}${b}`.toUpperCase();
  }
  
  /**
   * 解析颜色（支持多种格式）
   * @param color 颜色字符串（HEX、RGB、RGBA）
   * @returns RGB对象
   */
  public static parseColor(color: string): RGB {
    // 移除空格
    color = color.trim();
    
    // HEX格式
    if (color.startsWith('#')) {
      return this.hexToRgb(color);
    }
    
    // RGB格式：rgb(r, g, b)
    if (color.startsWith('rgb(')) {
      const match = color.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
      if (match) {
        return {
          r: parseInt(match[1]),
          g: parseInt(match[2]),
          b: parseInt(match[3])
        };
      }
    }
    
    // RGBA格式：rgba(r, g, b, a)
    if (color.startsWith('rgba(')) {
      const match = color.match(/rgba\((\d+),\s*(\d+),\s*(\d+),\s*[\d.]+\)/);
      if (match) {
        return {
          r: parseInt(match[1]),
          g: parseInt(match[2]),
          b: parseInt(match[3])
        };
      }
    }
    
    throw new Error(`Unsupported color format: ${color}`);
  }
  
  /**
   * 验证WCAG AA级标准
   * @param foregroundColor 前景色（文字颜色）
   * @param backgroundColor 背景色
   * @param isLargeText 是否为大文字（字体≥18pt或粗体≥14pt）
   * @returns 验证结果
   */
  public static isWCAGAACompliant(
    foregroundColor: string,
    backgroundColor: string,
    isLargeText: boolean = false
  ): WCAGValidationResult {
    const contrastRatio = this.calculateContrastRatio(foregroundColor, backgroundColor);
    
    // WCAG AA级标准：
    // - 普通文字：对比度 ≥ 4.5:1
    // - 大文字：对比度 ≥ 3:1
    const requiredRatio = isLargeText ? 3.0 : 4.5;
    
    const isCompliant = contrastRatio >= requiredRatio;
    
    // 判断等级
    let level: 'Fail' | 'AA' | 'AAA';
    const aaaRequiredRatio = isLargeText ? 4.5 : 7.0;
    
    if (contrastRatio >= aaaRequiredRatio) {
      level = 'AAA';
    } else if (isCompliant) {
      level = 'AA';
    } else {
      level = 'Fail';
    }
    
    // 生成建议
    let recommendation = '';
    if (!isCompliant) {
      const deficit = requiredRatio - contrastRatio;
      recommendation = `对比度不足，需要提升至少${deficit.toFixed(2)}。建议调整前景色或背景色以提高对比度。`;
    } else if (level === 'AA') {
      recommendation = '符合WCAG AA级标准。如需更高级别，可进一步提升对比度至' + aaaRequiredRatio.toFixed(1) + ':1。';
    } else {
      recommendation = '符合WCAG AAA级标准，对比度优秀。';
    }
    
    return {
      isCompliant,
      contrastRatio,
      level,
      recommendation
    };
  }
  
  /**
   * 获取推荐的前景色（基于背景色）
   * @param backgroundColor 背景色
   * @returns 推荐的前景色（黑色或白色）
   */
  public static getRecommendedForegroundColor(backgroundColor: string): string {
    const bgRgb = this.parseColor(backgroundColor);
    
    // 计算背景色的相对亮度
    const luminance = this.calculateRelativeLuminance(backgroundColor);
    
    // 如果背景色较亮，使用黑色文字；否则使用白色文字
    return luminance > 0.5 ? '#000000' : '#FFFFFF';
  }
  
  /**
   * 调整颜色亮度
   * @param color 原始颜色
   * @param percent 亮度百分比（-100到100）
   * @returns 调整后的颜色
   */
  public static adjustBrightness(color: string, percent: number): string {
    const rgb = this.parseColor(color);
    
    const factor = percent / 100;
    
    const r = Math.min(255, Math.max(0, rgb.r + (255 * factor)));
    const g = Math.min(255, Math.max(0, rgb.g + (255 * factor)));
    const b = Math.min(255, Math.max(0, rgb.b + (255 * factor)));
    
    return this.rgbToHex({ r, g, b });
  }
  
  /**
   * 混合两个颜色
   * @param color1 颜色1
   * @param color2 颜色2
   * @param weight 权重（0-1，0为color1，1为color2）
   * @returns 混合后的颜色
   */
  public static blendColors(color1: string, color2: string, weight: number): string {
    const rgb1 = this.parseColor(color1);
    const rgb2 = this.parseColor(color2);
    
    const r = Math.round(rgb1.r * (1 - weight) + rgb2.r * weight);
    const g = Math.round(rgb1.g * (1 - weight) + rgb2.g * weight);
    const b = Math.round(rgb1.b * (1 - weight) + rgb2.b * weight);
    
    return this.rgbToHex({ r, g, b });
  }
  
  /**
   * 计算颜色色相
   * @param color 颜色
   * @returns 色相值（0-360）
   */
  public static getHue(color: string): number {
    const rgb = this.parseColor(color);
    const r = rgb.r / 255;
    const g = rgb.g / 255;
    const b = rgb.b / 255;
    
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    const diff = max - min;
    
    if (diff === 0) {
      return 0; // 灰色
    }
    
    let hue = 0;
    
    if (max === r) {
      hue = ((g - b) / diff) % 6;
    } else if (max === g) {
      hue = (b - r) / diff + 2;
    } else {
      hue = (r - g) / diff + 4;
    }
    
    hue = Math.round(hue * 60);
    if (hue < 0) {
      hue += 360;
    }
    
    return hue;
  }
  
  /**
   * 计算颜色饱和度
   * @param color 颜色
   * @returns 饱和度（0-100）
   */
  public static getSaturation(color: string): number {
    const rgb = this.parseColor(color);
    const r = rgb.r / 255;
    const g = rgb.g / 255;
    const b = rgb.b / 255;
    
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    
    if (max === 0) {
      return 0;
    }
    
    const saturation = ((max - min) / max) * 100;
    return Math.round(saturation);
  }
  
  /**
   * 检查颜色是否为深色
   * @param color 颜色
   * @returns 是否为深色
   */
  public static isDarkColor(color: string): boolean {
    const luminance = this.calculateRelativeLuminance(color);
    return luminance < 0.5;
  }
  
  /**
   * 生成高对比度颜色对
   * @param baseColor 基础颜色
   * @returns 颜色对（前景色和背景色）
   */
  public static generateHighContrastPair(baseColor: string): { foreground: string; background: string } {
    const isDark = this.isDarkColor(baseColor);
    
    return {
      foreground: isDark ? '#FFFFFF' : '#000000',
      background: baseColor
    };
  }
}
