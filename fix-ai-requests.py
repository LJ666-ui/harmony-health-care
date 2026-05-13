#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量修复 AI 集成错误的脚本
"""

import os
import re
from pathlib import Path

# 需要修复的文件列表
FILES_TO_FIX = [
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\AIAssistantPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\AITestPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\AddHealthRecord.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\AiChatPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\AiConsultationPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\ConsultationPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\DoctorChatPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\DoctorFamilyChatPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\FamilyChatListPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\HealthRecordDetail.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\HealthRecords.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\MedicationDetailPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\MedicationPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\Medications.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\NurseChatPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\PatientDoctorChatPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\PatientNurseChatPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\Rehab3DPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\RehabListPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\RehabPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\RehabilitationPage.ets",
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\VoiceAssistantPage.ets",
]

def add_import_if_needed(content):
    """添加 AIRequestBuilder 导入"""
    import_pattern = r"import { AIOrchestrator } from '.*?';"
    new_import = "import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';\nimport { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';"

    if "AIRequestBuilder" not in content:
        content = re.sub(import_pattern, new_import, content)

    return content

def fix_orchestrator_process_calls(content):
    """修复 orchestrator.process 调用"""

    # 模式1: { type: 'text', content: '...', intent: '...' }
    pattern1 = r"this\.orchestrator\.process\(\{\s*type:\s*['\"]text['\"],\s*content:\s*([^,]+),\s*intent:\s*['\"]([^'\"]+)['\"]\s*\}\)"

    def replace1(match):
        content_expr = match.group(1).strip()
        intent = match.group(2)
        return f"""AIRequestBuilder.createDataRequest(
        {content_expr},
        '{intent}',
        String(this.userId)
      )"""

    content = re.sub(pattern1, replace1, content, flags=re.DOTALL)

    # 模式2: { type: 'data', content: '...', intent: '...' }
    pattern2 = r"this\.orchestrator\.process\(\{\s*type:\s*['\"]data['\"],\s*content:\s*([^,]+),\s*intent:\s*['\"]([^'\"]+)['\"]\s*\}\)"

    def replace2(match):
        content_expr = match.group(1).strip()
        intent = match.group(2)
        return f"""AIRequestBuilder.createDataRequest(
        {content_expr},
        '{intent}',
        String(this.userId)
      )"""

    content = re.sub(pattern2, replace2, content, flags=re.DOTALL)

    return content

def fix_response_content_access(content):
    """修复 response.output.content 的访问"""
    # 将 response.output.content 替换为类型安全的访问
    pattern = r"response\.output\.content"

    # 检查是否已经在 typeof 检查中
    if "typeof response.output.content === 'string'" not in content:
        # 简单替换（需要根据上下文调整）
        pass

    return content

def fix_file(file_path):
    """修复单个文件"""
    print(f"正在处理: {file_path}")

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content

        # 添加导入
        content = add_import_if_needed(content)

        # 修复 orchestrator.process 调用
        content = fix_orchestrator_process_calls(content)

        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ 已修复")
        else:
            print(f"  - 无需修改")

    except Exception as e:
        print(f"  ✗ 错误: {e}")

def main():
    print("=" * 60)
    print("批量修复 AI 集成错误")
    print("=" * 60)

    for file_path in FILES_TO_FIX:
        if os.path.exists(file_path):
            fix_file(file_path)
        else:
            print(f"文件不存在: {file_path}")

    print("\n修复完成！")

if __name__ == "__main__":
    main()
