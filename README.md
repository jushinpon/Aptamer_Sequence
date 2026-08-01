# Aptamer_Sequence

適配體（Aptamer）序列設計工具集。

整合 DLGSCPSO、MC 等優化演算法進行適配體序列設計。

## 程式功能說明

| 腳本 | 功能 |
|---|---|
| `DLGSCPSO_SeqDesign.pl` | DLGSCPSO 序列設計 |
| `LGSCPSO_SeqDesign.pl` | LGSCPSO 序列設計 |
| `MC_seqDesign.pl` | 蒙特卡羅序列設計 |
| `LGSCPSO_fitting.pl` | 擬合優化 |
| `00Train_Evaluation.pl` | 訓練評估 |

## 依賴環境

| 項目 | 需求 |
|---|---|
| 語言 | Perl 5.x |

## AI Agent 操控指南

```
任務: 適配體序列設計
步驟:
1. perl DLGSCPSO_SeqDesign.pl 執行優化
2. perl 00Train_Evaluation.pl 評估結果
```
