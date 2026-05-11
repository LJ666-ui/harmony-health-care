#!/bin/bash
echo "========================================="
echo "后端API测试"
echo "========================================="
echo ""

echo "1. 测试API连通性..."
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://172.26.96.1:8080/user/list

echo ""
echo "2. 测试患者数据数量..."
PATIENT_COUNT=$(curl -s http://172.26.96.1:8080/user/list | python -c "import sys,json; d=json.load(sys.stdin); print(len([u for u in d.get('data',[]) if u.get('userType')==0]))")
echo "患者数量: $PATIENT_COUNT"

echo ""
echo "3. 查看第一个患者数据..."
curl -s http://172.26.96.1:8080/user/list | python -c "import sys,json; d=json.load(sys.stdin); p=[u for u in d['data'] if u['userType']==0][0]; print('ID:', p['id']); print('姓名:', p.get('realName', '未知')); print('年龄:', p.get('age', '未知')); print('手机:', p.get('phone', '未知'))"

echo ""
echo "========================================="
echo "测试完成！"
echo "========================================="
