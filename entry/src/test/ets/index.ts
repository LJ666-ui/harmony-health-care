/**
 * 测试入口
 * 运行所有测试
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { TestRunner } from './TestFramework';
import { PerformanceMonitorTest } from './unit/PerformanceMonitorTest';

/**
 * 运行所有测试
 */
async function runAllTests(): Promise<void> {
  const runner = new TestRunner();
  
  // 添加测试套件
  runner.addSuite(new PerformanceMonitorTest());
  
  // 运行所有测试
  await runner.runAll();
}

// 导出测试运行函数
export { runAllTests };

// 如果直接运行此文件
if (require.main === module) {
  runAllTests().catch(error => {
    console.error('测试运行失败:', error);
    process.exit(1);
  });
}
