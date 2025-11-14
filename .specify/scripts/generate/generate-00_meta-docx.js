const fs = require('fs');
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        AlignmentType, HeadingLevel, BorderStyle, WidthType, LevelFormat,
        ShadingType, VerticalAlign, PageBreak } = require('docx');

const tableBorder = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const cellBorders = { top: tableBorder, bottom: tableBorder, left: tableBorder, right: tableBorder };

const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 24 } } },
    paragraphStyles: [
      { id: "Title", name: "Title", basedOn: "Normal",
        run: { size: 56, bold: true, color: "000000", font: "Arial" },
        paragraph: { spacing: { before: 240, after: 120 }, alignment: AlignmentType.CENTER } },
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, color: "2E5090", font: "Arial" },
        paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 28, bold: true, color: "4472C4", font: "Arial" },
        paragraph: { spacing: { before: 180, after: 100 }, outlineLevel: 1 } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 24, bold: true, color: "5B9BD5", font: "Arial" },
        paragraph: { spacing: { before: 120, after: 80 }, outlineLevel: 2 } }
    ]
  },
  numbering: {
    config: [
      { reference: "bullet-list",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] }
    ]
  },
  sections: [{
    properties: {
      page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } }
    },
    children: [
      // Title
      new Paragraph({
        heading: HeadingLevel.TITLE,
        children: [new TextRun("客戶洗錢風險事件摘要模型")]
      }),
      new Paragraph({
        heading: HeadingLevel.TITLE,
        children: [new TextRun("專案基本資料 (00_meta)")]
      }),

      // Document info
      new Paragraph({
        spacing: { before: 200, after: 200 },
        children: [
          new TextRun({ text: "建立日期: ", bold: true }), new TextRun("2025-11-14"),
          new TextRun({ text: " | 文件版本: ", bold: true }), new TextRun("1.0.0")
        ]
      }),

      new Paragraph({ children: [new PageBreak()] }),

      // Section 1: 專案總覽
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("專案總覽")] }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("專案識別資訊")] }),
      new Table({
        columnWidths: [3120, 6240],
        margins: { top: 100, bottom: 100, left: 180, right: 180 },
        rows: [
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
              children: [new Paragraph({ children: [new TextRun({ text: "專案代號", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 6240, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("RISK-AML-MDL-001")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
              children: [new Paragraph({ children: [new TextRun({ text: "專案名稱", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 6240, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("客戶洗錢風險事件摘要模型")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
              children: [new Paragraph({ children: [new TextRun({ text: "英文名稱", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 6240, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Customer AML Risk Event Summary Model")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
              children: [new Paragraph({ children: [new TextRun({ text: "發起單位", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 6240, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("法遵部 / 風控部")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
              children: [new Paragraph({ children: [new TextRun({ text: "專案類型", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 6240, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("新系統開發")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
              children: [new Paragraph({ children: [new TextRun({ text: "專案性質", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 6240, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("監理申報 / 法遵要求 / 風險控制")] })] })
          ]})
        ]
      }),

      new Paragraph({ spacing: { before: 200 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("關鍵時程")] }),
      new Table({
        columnWidths: [2340, 2340, 2340, 2340],
        margins: { top: 100, bottom: 100, left: 180, right: 180 },
        rows: [
          new TableRow({ tableHeader: true, children: [
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "里程碑", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "預定日期", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "狀態", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "備註", bold: true })] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("需求確認完成")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("2025-12-15")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("規劃中")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("包含模型設計與資料需求")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("設計審查通過")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("2026-01-31")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("規劃中")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("技術架構與模型演算法審查")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("開發完成")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("2026-04-15")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("規劃中")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("含單元測試與整合測試")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("UAT 測試完成")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("2026-05-15")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("規劃中")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("法遵部與風控部驗收")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("正式上線")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("2026-05-31")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("規劃中")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("配合監理申報時程")] })] })
          ]})
        ]
      }),

      new Paragraph({ spacing: { before: 200 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("預期效益")] }),
      new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("量化效益")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("減少人工風險分析時間: 預估節省 60% 以上")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("提升洗錢風險識別準確率: 目標提升至 85% 以上")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("加速風險事件摘要產出: 從 3 天縮短至即時生成")] }),

      new Paragraph({ spacing: { before: 150 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("質化效益")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("符合金融監理機關反洗錢法規要求")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("強化客戶風險管控能力，降低法遵風險")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("提供管理層即時風險儀表板，支援決策")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("建立可追溯的風險評估記錄，滿足稽核要求")] }),

      new Paragraph({ children: [new PageBreak()] }),

      // Section 2: 專案背景
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("專案背景")] }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("問題陳述")] }),
      new Paragraph({ children: [new TextRun({ text: "現行痛點:", bold: true })] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("客戶洗錢風險事件分散於多個系統，缺乏整合性摘要")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("人工彙整風險事件耗時且容易遺漏關鍵資訊")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("風險評分標準不一致，依賴人工判斷，缺乏客觀性")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("無法即時掌握高風險客戶動態，影響預警能力")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("監理申報準備作業繁複，資料品質難以保證")] }),

      new Paragraph({ spacing: { before: 200 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("業務驅動因素")] }),
      new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("法規要求")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("遵循《洗錢防制法》及相關子法規定")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("滿足金融監理機關（如金管會）對於洗錢防制的監理要求")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("配合國際反洗錢標準（FATF 建議）的持續演進")] }),

      new Paragraph({ spacing: { before: 150 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("風險管理需求")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("強化客戶風險分級管理機制")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("建立可量化、可追溯的風險評估模型")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("提升異常交易偵測與預警能力")] }),

      new Paragraph({ children: [new PageBreak()] }),

      // Section 3: 專案範圍
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("專案範圍")] }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("範圍內 (In Scope)")] }),
      new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("功能範圍")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("客戶風險事件資料整合引擎（從多個來源系統擷取）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("洗錢風險評分模型（基於規則與機器學習）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("客戶風險事件摘要自動產生功能")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("風險等級分類與標註（高/中/低風險）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("風險儀表板與視覺化介面")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("風險趨勢分析與統計報表")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("高風險客戶自動預警通知")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("監理申報資料匯出功能")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("稽核追蹤記錄（評分歷程與變更記錄）")] }),

      new Paragraph({ spacing: { before: 200 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("範圍外 (Out of Scope)")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("不包含實時交易監控功能（由既有交易監控系統負責）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("不包含客戶盡職調查(KYC)流程管理（由既有 KYC 系統負責）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("不包含可疑交易申報(STR/SAR)的案件調查流程")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("不包含帳戶凍結或交易阻擋功能")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("不涉及客戶身分驗證(eKYC)機制")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("不包含反洗錢教育訓練管理")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("第一期不包含跨境交易風險分析（未來期程評估）")] }),

      new Paragraph({ children: [new PageBreak()] }),

      // Section 4: 專案優先級與風險
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("優先順序與依賴")] }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("專案優先級")] }),
      new Table({
        columnWidths: [3120, 6240],
        margins: { top: 100, bottom: 100, left: 180, right: 180 },
        rows: [
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
              children: [new Paragraph({ children: [new TextRun({ text: "優先等級", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 6240, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("P0-Critical")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
              children: [new Paragraph({ children: [new TextRun({ text: "優先級理由", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 6240, type: WidthType.DXA },
              children: [
                new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
                  children: [new TextRun("屬於法遵強制要求，關係到監理合規")] }),
                new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
                  children: [new TextRun("影響組織法遵風險與聲譽風險")] }),
                new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
                  children: [new TextRun("監理機關持續加強反洗錢檢查力度")] }),
                new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
                  children: [new TextRun("若未符合要求可能面臨裁罰或業務限制")] })
              ]
            })
          ]})
        ]
      }),

      new Paragraph({ spacing: { before: 200 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("高階風險")] }),
      new Table({
        columnWidths: [1560, 2340, 1560, 1560, 2340],
        margins: { top: 100, bottom: 100, left: 180, right: 180 },
        rows: [
          new TableRow({ tableHeader: true, children: [
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "風險ID", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "風險描述", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "機率", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "影響", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "應對策略", bold: true })] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("R001")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("資料品質不佳導致模型準確度低")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun("高")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun("高")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("前期進行資料品質評估，建立資料清理機制")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("R002")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("跨系統資料整合複雜度高於預期")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun("中")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun("高")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("提前進行技術可行性驗證(POC)，預留緩衝時程")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("R003")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("模型可解釋性不足無法通過稽核")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun("中")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun("高")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("採用可解釋的模型演算法，建立模型文件化機制")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("R004")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("關鍵人力（資料科學家）取得困難")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun("中")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun("高")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 2340, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("提前啟動人力招募，或考慮外部顧問支援")] })] })
          ]})
        ]
      }),

      new Paragraph({ children: [new PageBreak()] }),

      // Section 5: 成功標準
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("成功標準")] }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("專案成功指標")] }),
      new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("完成標準 (Definition of Done)")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("所有範圍內功能開發完成並通過測試")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("風險模型準確率達到設定門檻（目標 ≥ 85%）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("UAT 測試通過率 ≥ 95%")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("效能測試符合 SLA 要求（風險評分運算時間 < 5 分鐘/批次）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("資安測試通過（無高風險與中風險弱點）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("所有高階與中階風險已關閉或轉移")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("文件交付完整（使用者手冊、模型文件、維運手冊、技術文件、API 文件）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("正式上線後穩定運行 30 天無重大異常")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("使用者滿意度調查 ≥ 4.0 分（5 分量表）")] }),

      new Paragraph({ spacing: { before: 200 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("驗收標準 (Acceptance Criteria)")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("法遵部與風控部簽核業務驗收")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("模型驗證委員會通過模型驗證")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("資安檢測通過（弱點掃描、滲透測試）")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("稽核部確認稽核追蹤機制符合要求")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("技術文件審查通過")] }),
      new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
        children: [new TextRun("災難復原演練通過")] }),

      new Paragraph({ children: [new PageBreak()] }),

      // Section 6: 附錄
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("附錄")] }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("專有名詞與縮寫")] }),
      new Table({
        columnWidths: [1872, 3120, 4368],
        margins: { top: 100, bottom: 100, left: 180, right: 180 },
        rows: [
          new TableRow({ tableHeader: true, children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "名詞", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "全名", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "說明", bold: true })] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("AML")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Anti-Money Laundering")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("反洗錢")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("KYC")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Know Your Customer")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("認識你的客戶（客戶盡職調查）")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("STR")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Suspicious Transaction Report")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("可疑交易報告")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("FATF")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Financial Action Task Force")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("防制洗錢金融行動工作組織")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("PEP")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Politically Exposed Persons")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("政治公眾人物")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("ML")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Machine Learning")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("機器學習")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("UAT")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("User Acceptance Testing")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("使用者驗收測試")] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("SLA")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 3120, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Service Level Agreement")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4368, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("服務水準協議")] })] })
          ]})
        ]
      }),

      new Paragraph({ spacing: { before: 300 } }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("版本歷史")] }),
      new Table({
        columnWidths: [1560, 1872, 1872, 4056],
        margins: { top: 100, bottom: 100, left: 180, right: 180 },
        rows: [
          new TableRow({ tableHeader: true, children: [
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "版本", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "日期", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "修訂者", bold: true })] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4056, type: WidthType.DXA },
              shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
              children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "修訂內容", bold: true })] })] })
          ]}),
          new TableRow({ children: [
            new TableCell({ borders: cellBorders, width: { size: 1560, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("1.0.0")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("2025-11-14")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 1872, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("Claude (SpecKit Meta)")] })] }),
            new TableCell({ borders: cellBorders, width: { size: 4056, type: WidthType.DXA },
              children: [new Paragraph({ children: [new TextRun("初版建立，透過 /speckit.meta 自動產生")] })] })
          ]})
        ]
      })
    ]
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("/Users/ro9air/SDD_repo/output/00_meta.docx", buffer);
  console.log("DOCX document generated successfully: /Users/ro9air/SDD_repo/output/00_meta.docx");
});
