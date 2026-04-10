import os
import zipfile
import xml.etree.ElementTree as ET

# 输入和输出目录
doc_dir = 'e:\HMOS6.0\harmonyhealthcare\doc'
md_dir = 'e:\HMOS6.0\harmonyhealthcare\doc_md'

# 创建输出目录
os.makedirs(md_dir, exist_ok=True)

# 获取所有docx文件
docx_files = [f for f in os.listdir(doc_dir) if f.endswith('.docx')]

print(f'找到 {len(docx_files)} 个docx文件')

# 方法1: 使用python-docx（原方法）
try:
    from docx import Document
    def method1(doc_path):
        doc = Document(doc_path)
        md_content = []
        for para in doc.paragraphs:
            if para.text.strip():
                md_content.append(para.text)
        return md_content
except ImportError:
    method1 = None

# 方法2: 直接解析docx的XML结构
def method2(doc_path):
    md_content = []
    try:
        with zipfile.ZipFile(doc_path, 'r') as zf:
            # 读取document.xml
            with zf.open('word/document.xml') as f:
                tree = ET.parse(f)
                root = tree.getroot()
                
                # 命名空间
                ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
                
                # 提取所有段落
                for para in root.findall('.//w:p', ns):
                    text = ''
                    for run in para.findall('.//w:t', ns):
                        if run.text:
                            text += run.text
                    if text.strip():
                        md_content.append(text)
    except Exception as e:
        print(f'方法2失败: {str(e)}')
    return md_content

for docx_file in docx_files:
    try:
        doc_path = os.path.join(doc_dir, docx_file)
        md_content = []
        
        # 尝试方法1
        if method1:
            try:
                md_content = method1(doc_path)
                if md_content:
                    print(f'使用方法1成功转换: {docx_file}')
                else:
                    raise Exception('方法1未提取到内容')
            except Exception as e:
                print(f'方法1失败 {docx_file}: {str(e)}')
                # 尝试方法2
                md_content = method2(doc_path)
                if md_content:
                    print(f'使用方法2成功转换: {docx_file}')
                else:
                    raise Exception('所有方法都失败')
        else:
            # 直接使用方法2
            md_content = method2(doc_path)
            if md_content:
                print(f'使用方法2成功转换: {docx_file}')
            else:
                raise Exception('方法2失败')
        
        # 生成md文件名
        md_file = os.path.splitext(docx_file)[0] + '.md'
        md_path = os.path.join(md_dir, md_file)
        
        # 写入md文件
        with open(md_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(md_content))
        
        print(f'成功保存: {md_file}')
        
    except Exception as e:
        print(f'转换失败 {docx_file}: {str(e)}')

print('转换完成！')
