#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from reportlab.lib.pagesizes import A4, letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# Register Chinese fonts (using Arial Unicode MS which supports Traditional Chinese)
try:
    # Try Arial Unicode MS first (most reliable for Chinese support)
    pdfmetrics.registerFont(TTFont('ArialUnicode', '/System/Library/Fonts/Supplemental/Arial Unicode.ttf'))
    chinese_font = 'ArialUnicode'
    chinese_font_bold = 'ArialUnicode'
except:
    try:
        # Fallback to library fonts location
        pdfmetrics.registerFont(TTFont('ArialUnicode', '/Library/Fonts/Arial Unicode.ttf'))
        chinese_font = 'ArialUnicode'
        chinese_font_bold = 'ArialUnicode'
    except:
        # Last resort fallback
        chinese_font = 'Helvetica'
        chinese_font_bold = 'Helvetica-Bold'
        print("Warning: Chinese fonts not available, falling back to Helvetica")

# Create PDF
doc = SimpleDocTemplate(
    "/Users/ro9air/SDD_repo/output/00_meta.pdf",
    pagesize=A4,
    rightMargin=72, leftMargin=72,
    topMargin=72, bottomMargin=72
)

# Define custom styles
styles = getSampleStyleSheet()

# Title style
title_style = ParagraphStyle(
    'CustomTitle',
    parent=styles['Heading1'],
    fontName=chinese_font_bold,
    fontSize=24,
    textColor=colors.HexColor('#2E5090'),
    spaceAfter=20,
    alignment=TA_CENTER,
    leading=30
)

# Heading 1
h1_style = ParagraphStyle(
    'CustomHeading1',
    parent=styles['Heading1'],
    fontName=chinese_font_bold,
    fontSize=18,
    textColor=colors.HexColor('#2E5090'),
    spaceAfter=12,
    spaceBefore=24,
    leading=22
)

# Heading 2
h2_style = ParagraphStyle(
    'CustomHeading2',
    parent=styles['Heading2'],
    fontName=chinese_font_bold,
    fontSize=14,
    textColor=colors.HexColor('#4472C4'),
    spaceAfter=10,
    spaceBefore=18,
    leading=18
)

# Heading 3
h3_style = ParagraphStyle(
    'CustomHeading3',
    parent=styles['Heading3'],
    fontName=chinese_font_bold,
    fontSize=12,
    textColor=colors.HexColor('#5B9BD5'),
    spaceAfter=8,
    spaceBefore=12,
    leading=16
)

# Normal text
normal_style = ParagraphStyle(
    'CustomNormal',
    parent=styles['Normal'],
    fontName=chinese_font,
    fontSize=10,
    leading=14,
    alignment=TA_JUSTIFY
)

# Bullet style
bullet_style = ParagraphStyle(
    'CustomBullet',
    parent=normal_style,
    leftIndent=20,
    bulletIndent=10,
    spaceAfter=6
)

# Build content
story = []

# Title page
story.append(Paragraph("客戶洗錢風險事件摘要模型", title_style))
story.append(Paragraph("專案基本資料 (00_meta)", title_style))
story.append(Spacer(1, 0.3*inch))
story.append(Paragraph("<b>建立日期:</b> 2025-11-14 | <b>文件版本:</b> 1.0.0", normal_style))
story.append(PageBreak())

# Section 1: 專案總覽
story.append(Paragraph("專案總覽", h1_style))
story.append(Paragraph("專案識別資訊", h2_style))

# Project identification table
proj_data = [
    ['專案代號', 'RISK-AML-MDL-001'],
    ['專案名稱', '客戶洗錢風險事件摘要模型'],
    ['英文名稱', 'Customer AML Risk Event Summary Model'],
    ['發起單位', '法遵部 / 風控部'],
    ['專案類型', '新系統開發'],
    ['專案性質', '監理申報 / 法遵要求 / 風險控制']
]

proj_table = Table(proj_data, colWidths=[2*inch, 4.5*inch])
proj_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#D5E8F0')),
    ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
    ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
    ('FONTNAME', (0, 0), (0, -1), chinese_font_bold),
    ('FONTNAME', (1, 0), (1, -1), chinese_font),
    ('FONTSIZE', (0, 0), (-1, -1), 10),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CCCCCC')),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('TOPPADDING', (0, 0), (-1, -1), 8),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
]))
story.append(proj_table)
story.append(Spacer(1, 0.2*inch))

# Timeline table
story.append(Paragraph("關鍵時程", h2_style))
timeline_data = [
    ['里程碑', '預定日期', '狀態', '備註'],
    ['需求確認完成', '2025-12-15', '規劃中', '包含模型設計與資料需求'],
    ['設計審查通過', '2026-01-31', '規劃中', '技術架構與模型演算法審查'],
    ['開發完成', '2026-04-15', '規劃中', '含單元測試與整合測試'],
    ['UAT 測試完成', '2026-05-15', '規劃中', '法遵部與風控部驗收'],
    ['正式上線', '2026-05-31', '規劃中', '配合監理申報時程']
]

timeline_table = Table(timeline_data, colWidths=[1.6*inch, 1.4*inch, 1.2*inch, 2.3*inch])
timeline_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#D5E8F0')),
    ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
    ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
    ('ALIGN', (0, 1), (-1, -1), 'LEFT'),
    ('FONTNAME', (0, 0), (-1, 0), chinese_font_bold),
    ('FONTNAME', (0, 1), (-1, -1), chinese_font),
    ('FONTSIZE', (0, 0), (-1, -1), 9),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CCCCCC')),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('TOPPADDING', (0, 0), (-1, -1), 6),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
]))
story.append(timeline_table)
story.append(Spacer(1, 0.2*inch))

# Benefits
story.append(Paragraph("預期效益", h2_style))
story.append(Paragraph("量化效益", h3_style))
story.append(Paragraph("• 減少人工風險分析時間: 預估節省 60% 以上", bullet_style))
story.append(Paragraph("• 提升洗錢風險識別準確率: 目標提升至 85% 以上", bullet_style))
story.append(Paragraph("• 加速風險事件摘要產出: 從 3 天縮短至即時生成", bullet_style))
story.append(Spacer(1, 0.15*inch))

story.append(Paragraph("質化效益", h3_style))
story.append(Paragraph("• 符合金融監理機關反洗錢法規要求", bullet_style))
story.append(Paragraph("• 強化客戶風險管控能力，降低法遵風險", bullet_style))
story.append(Paragraph("• 提供管理層即時風險儀表板，支援決策", bullet_style))
story.append(Paragraph("• 建立可追溯的風險評估記錄，滿足稽核要求", bullet_style))

story.append(PageBreak())

# Section 2: 專案背景
story.append(Paragraph("專案背景", h1_style))
story.append(Paragraph("問題陳述", h2_style))
story.append(Paragraph("<b>現行痛點:</b>", normal_style))
story.append(Paragraph("• 客戶洗錢風險事件分散於多個系統，缺乏整合性摘要", bullet_style))
story.append(Paragraph("• 人工彙整風險事件耗時且容易遺漏關鍵資訊", bullet_style))
story.append(Paragraph("• 風險評分標準不一致，依賴人工判斷，缺乏客觀性", bullet_style))
story.append(Paragraph("• 無法即時掌握高風險客戶動態，影響預警能力", bullet_style))
story.append(Paragraph("• 監理申報準備作業繁複，資料品質難以保證", bullet_style))
story.append(Spacer(1, 0.2*inch))

story.append(Paragraph("業務驅動因素", h2_style))
story.append(Paragraph("法規要求", h3_style))
story.append(Paragraph("• 遵循《洗錢防制法》及相關子法規定", bullet_style))
story.append(Paragraph("• 滿足金融監理機關（如金管會）對於洗錢防制的監理要求", bullet_style))
story.append(Paragraph("• 配合國際反洗錢標準（FATF 建議）的持續演進", bullet_style))
story.append(Spacer(1, 0.15*inch))

story.append(Paragraph("風險管理需求", h3_style))
story.append(Paragraph("• 強化客戶風險分級管理機制", bullet_style))
story.append(Paragraph("• 建立可量化、可追溯的風險評估模型", bullet_style))
story.append(Paragraph("• 提升異常交易偵測與預警能力", bullet_style))

story.append(PageBreak())

# Section 3: 專案範圍
story.append(Paragraph("專案範圍", h1_style))
story.append(Paragraph("範圍內 (In Scope)", h2_style))
story.append(Paragraph("功能範圍", h3_style))
story.append(Paragraph("• 客戶風險事件資料整合引擎（從多個來源系統擷取）", bullet_style))
story.append(Paragraph("• 洗錢風險評分模型（基於規則與機器學習）", bullet_style))
story.append(Paragraph("• 客戶風險事件摘要自動產生功能", bullet_style))
story.append(Paragraph("• 風險等級分類與標註（高/中/低風險）", bullet_style))
story.append(Paragraph("• 風險儀表板與視覺化介面", bullet_style))
story.append(Paragraph("• 風險趨勢分析與統計報表", bullet_style))
story.append(Paragraph("• 高風險客戶自動預警通知", bullet_style))
story.append(Paragraph("• 監理申報資料匯出功能", bullet_style))
story.append(Paragraph("• 稽核追蹤記錄（評分歷程與變更記錄）", bullet_style))
story.append(Spacer(1, 0.2*inch))

story.append(Paragraph("範圍外 (Out of Scope)", h2_style))
story.append(Paragraph("• 不包含實時交易監控功能（由既有交易監控系統負責）", bullet_style))
story.append(Paragraph("• 不包含客戶盡職調查(KYC)流程管理（由既有 KYC 系統負責）", bullet_style))
story.append(Paragraph("• 不包含可疑交易申報(STR/SAR)的案件調查流程", bullet_style))
story.append(Paragraph("• 不包含帳戶凍結或交易阻擋功能", bullet_style))
story.append(Paragraph("• 不涉及客戶身分驗證(eKYC)機制", bullet_style))
story.append(Paragraph("• 不包含反洗錢教育訓練管理", bullet_style))
story.append(Paragraph("• 第一期不包含跨境交易風險分析（未來期程評估）", bullet_style))

story.append(PageBreak())

# Section 4: 優先順序與風險
story.append(Paragraph("優先順序與依賴", h1_style))
story.append(Paragraph("專案優先級", h2_style))

priority_data = [
    ['優先等級', 'P0-Critical'],
    ['優先級理由', '• 屬於法遵強制要求，關係到監理合規\n• 影響組織法遵風險與聲譽風險\n• 監理機關持續加強反洗錢檢查力度\n• 若未符合要求可能面臨裁罰或業務限制']
]

priority_table = Table(priority_data, colWidths=[2*inch, 4.5*inch])
priority_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#D5E8F0')),
    ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
    ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
    ('FONTNAME', (0, 0), (0, -1), chinese_font_bold),
    ('FONTNAME', (1, 0), (1, -1), chinese_font),
    ('FONTSIZE', (0, 0), (-1, -1), 10),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CCCCCC')),
    ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ('TOPPADDING', (0, 0), (-1, -1), 8),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
]))
story.append(priority_table)
story.append(Spacer(1, 0.2*inch))

# Risk table
story.append(Paragraph("高階風險", h2_style))
risk_data = [
    ['風險ID', '風險描述', '機率', '影響', '應對策略'],
    ['R001', '資料品質不佳導致模型準確度低', '高', '高', '前期進行資料品質評估，建立資料清理機制'],
    ['R002', '跨系統資料整合複雜度高於預期', '中', '高', '提前進行技術可行性驗證(POC)，預留緩衝時程'],
    ['R003', '模型可解釋性不足無法通過稽核', '中', '高', '採用可解釋的模型演算法，建立模型文件化機制'],
    ['R004', '關鍵人力（資料科學家）取得困難', '中', '高', '提前啟動人力招募，或考慮外部顧問支援']
]

risk_table = Table(risk_data, colWidths=[0.8*inch, 1.8*inch, 0.7*inch, 0.7*inch, 2.5*inch])
risk_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#D5E8F0')),
    ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
    ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
    ('ALIGN', (0, 1), (-1, -1), 'LEFT'),
    ('ALIGN', (2, 1), (3, -1), 'CENTER'),
    ('FONTNAME', (0, 0), (-1, 0), chinese_font_bold),
    ('FONTNAME', (0, 1), (-1, -1), chinese_font),
    ('FONTSIZE', (0, 0), (-1, -1), 8),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CCCCCC')),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('TOPPADDING', (0, 0), (-1, -1), 6),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
]))
story.append(risk_table)

story.append(PageBreak())

# Section 5: 成功標準
story.append(Paragraph("成功標準", h1_style))
story.append(Paragraph("專案成功指標", h2_style))
story.append(Paragraph("完成標準 (Definition of Done)", h3_style))
story.append(Paragraph("• 所有範圍內功能開發完成並通過測試", bullet_style))
story.append(Paragraph("• 風險模型準確率達到設定門檻（目標 ≥ 85%）", bullet_style))
story.append(Paragraph("• UAT 測試通過率 ≥ 95%", bullet_style))
story.append(Paragraph("• 效能測試符合 SLA 要求（風險評分運算時間 < 5 分鐘/批次）", bullet_style))
story.append(Paragraph("• 資安測試通過（無高風險與中風險弱點）", bullet_style))
story.append(Paragraph("• 所有高階與中階風險已關閉或轉移", bullet_style))
story.append(Paragraph("• 文件交付完整（使用者手冊、模型文件、維運手冊、技術文件、API 文件）", bullet_style))
story.append(Paragraph("• 正式上線後穩定運行 30 天無重大異常", bullet_style))
story.append(Paragraph("• 使用者滿意度調查 ≥ 4.0 分（5 分量表）", bullet_style))
story.append(Spacer(1, 0.15*inch))

story.append(Paragraph("驗收標準 (Acceptance Criteria)", h3_style))
story.append(Paragraph("• 法遵部與風控部簽核業務驗收", bullet_style))
story.append(Paragraph("• 模型驗證委員會通過模型驗證", bullet_style))
story.append(Paragraph("• 資安檢測通過（弱點掃描、滲透測試）", bullet_style))
story.append(Paragraph("• 稽核部確認稽核追蹤機制符合要求", bullet_style))
story.append(Paragraph("• 技術文件審查通過", bullet_style))
story.append(Paragraph("• 災難復原演練通過", bullet_style))

story.append(PageBreak())

# Section 6: 附錄
story.append(Paragraph("附錄", h1_style))
story.append(Paragraph("專有名詞與縮寫", h2_style))

terms_data = [
    ['名詞', '全名', '說明'],
    ['AML', 'Anti-Money Laundering', '反洗錢'],
    ['KYC', 'Know Your Customer', '認識你的客戶（客戶盡職調查）'],
    ['STR', 'Suspicious Transaction Report', '可疑交易報告'],
    ['FATF', 'Financial Action Task Force', '防制洗錢金融行動工作組織'],
    ['PEP', 'Politically Exposed Persons', '政治公眾人物'],
    ['ML', 'Machine Learning', '機器學習'],
    ['UAT', 'User Acceptance Testing', '使用者驗收測試'],
    ['SLA', 'Service Level Agreement', '服務水準協議']
]

terms_table = Table(terms_data, colWidths=[1*inch, 2.5*inch, 3*inch])
terms_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#D5E8F0')),
    ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
    ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
    ('ALIGN', (0, 1), (-1, -1), 'LEFT'),
    ('FONTNAME', (0, 0), (-1, 0), chinese_font_bold),
    ('FONTNAME', (0, 1), (-1, -1), chinese_font),
    ('FONTSIZE', (0, 0), (-1, -1), 9),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CCCCCC')),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('TOPPADDING', (0, 0), (-1, -1), 6),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
]))
story.append(terms_table)
story.append(Spacer(1, 0.3*inch))

# Version history
story.append(Paragraph("版本歷史", h2_style))
version_data = [
    ['版本', '日期', '修訂者', '修訂內容'],
    ['1.0.0', '2025-11-14', 'Claude (SpecKit Meta)', '初版建立，透過 /speckit.meta 自動產生']
]

version_table = Table(version_data, colWidths=[1*inch, 1.3*inch, 1.7*inch, 2.5*inch])
version_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#D5E8F0')),
    ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
    ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
    ('ALIGN', (0, 1), (-1, -1), 'LEFT'),
    ('FONTNAME', (0, 0), (-1, 0), chinese_font_bold),
    ('FONTNAME', (0, 1), (-1, -1), chinese_font),
    ('FONTSIZE', (0, 0), (-1, -1), 9),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CCCCCC')),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('TOPPADDING', (0, 0), (-1, -1), 6),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
]))
story.append(version_table)

# Build PDF
doc.build(story)
print("PDF document generated successfully: /Users/ro9air/SDD_repo/output/00_meta.pdf")
