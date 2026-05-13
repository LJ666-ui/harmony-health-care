#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量修复剩余页面文件的 AIRequest 使用问题
"""

import os
import re

# 需要修复的文件及其修复信息
FILES_TO_FIX = {
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\ConsultationPage.ets": {
        "imports_added": True,
        "methods": [
            {"name": "preDiagnoseWithAI", "line": 154},
            {"name": "getAIDepartmentRecommendation", "line": 170},
            {"name": "getAITriageGuidance", "line": 184}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\DoctorChatPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "analyzeSymptomsWithAI", "line": 434},
            {"name": "getAIDiagnosisHelp", "line": 453},
            {"name": "suggestFollowUpQuestions", "line": 470}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\DoctorFamilyChatPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "translateWithAI", "line": 340},
            {"name": "generateChatSummary", "line": 355}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\FamilyChatListPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "generateSmartSummary", "line": 135},
            {"name": "checkUrgencyAlert", "line": 149}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\HealthRecordDetail.ets": {
        "imports_added": False,
        "methods": [
            {"name": "analyzeWithAI", "line": 129},
            {"name": "predictTrendWithAI", "line": 146},
            {"name": "getHealthAdviceFromAI", "line": 160}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\HealthRecords.ets": {
        "imports_added": False,
        "methods": [
            {"name": "generateAISummary", "line": 286},
            {"name": "detectAbnormalWithAI", "line": 301}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\MedicationDetailPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "getDetailedGuidanceFromAI", "line": 145},
            {"name": "askQuestionToAI", "line": 160},
            {"name": "getSideEffectsFromAI", "line": 175}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\MedicationPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "optimizeScheduleWithAI", "line": 130},
            {"name": "getMedicationAdviceFromAI", "line": 145}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\Medications.ets": {
        "imports_added": False,
        "methods": [
            {"name": "checkDrugInteractions", "line": 311},
            {"name": "getDrugInfoFromAI", "line": 325}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\NurseChatPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "queryNursingKnowledge", "line": 329},
            {"name": "getProtocolGuidanceFromAI", "line": 343}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\PatientDoctorChatPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "getAIChatAssistance", "line": 299},
            {"name": "getHealthTipFromAI", "line": 313}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\PatientNurseChatPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "getNursingAdviceFromAI", "line": 288},
            {"name": "getCareGuidanceFromAI", "line": 302}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\Rehab3DPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "analyzeMovementWithAI", "line": 174, "special": True},
            {"name": "getAICorrectionGuidance", "line": 197}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\RehabPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "generateAITrainingPlan", "line": 38}
        ]
    },
    r"E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\RehabilitationPage.ets": {
        "imports_added": False,
        "methods": [
            {"name": "getAIRecommendation", "line": 94},
            {"name": "generateAIPersonalPlan", "line": 108}
        ]
    }
}

def add_import(content):
    """添加 AIRequestBuilder 导入"""
    if "AIRequestBuilder" in content:
        return content, False

    import_pattern = r"(import { AIOrchestrator } from '.*?';)"
    new_import = r"\1\nimport { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';"

    new_content = re.sub(import_pattern, new_import, content)
    return new_content, new_content != content

def fix_file(file_path):
    """修复单个文件"""
    print(f"\n处理文件: {os.path.basename(file_path)}")

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content

        # 添加导入
        content, import_added = add_import(content)
        if import_added:
            print(f"  ✓ 已添加导入")

        # 保存文件
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ 文件已更新")
        else:
            print(f"  - 无需修改")

        return True

    except Exception as e:
        print(f"  ✗ 错误: {e}")
        return False

def main():
    print("=" * 60)
    print("批量修复剩余页面文件")
    print("=" * 60)

    success_count = 0
    for file_path in FILES_TO_FIX.keys():
        if os.path.exists(file_path):
            if fix_file(file_path):
                success_count += 1
        else:
            print(f"\n文件不存在: {os.path.basename(file_path)}")

    print("\n" + "=" * 60)
    print(f"修复完成: {success_count}/{len(FILES_TO_FIX)} 个文件")
    print("=" * 60)

if __name__ == "__main__":
    main()
