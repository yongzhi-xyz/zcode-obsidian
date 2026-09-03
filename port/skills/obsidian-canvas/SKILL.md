---
name: obsidian-canvas
description: "创建、检视、更新 Obsidian JSON Canvas 白板：文本/文件/链接/分组/边节点。读取只读；一切变更走可恢复事务。触发词：白板、canvas、可视化地图、把这个放到白板上、状态板。"
---

# Canvas 白板

canvas 是 vault 范围内的 JSON Canvas 文档。读只读；变更走一个可恢复事务。

## 范围

- 白板存 `wiki/canvases/`；未命名时默认 `wiki/canvases/main.canvas`；`wiki/canvases/index.md` 是可选目录，仅创建/改名/删除时更新。
- `file`/`background` 用 vault 相对路径；拒绝绝对路径、`..` 穿越、home 快捷方式、symlink 逃逸。只引用 vault 内已有文件。
- `link` 节点只收 HTTPS URL；创建 JSON 不发请求，但 Obsidian 打开时可能向该 host 发 Open Graph 元数据请求——披露该渲染期外发，不可接受就用含 URL 的文本节点。
- 语法规范以 JSON Canvas 1.0（jsoncanvas.org）为准。

## 只读操作

状态/列表请求：解析所选 `.canvas`，报告节点数、分组标签、断边、缺失的文件目标。默认白板缺失时如实报告并提供创建预览，**不在状态请求中顺手创建**。

## 起草变更

1. 整读 canvas 与目录目标，记录每个目标的 SHA-256（必须缺失的记 null）。
2. 保留未知 JSON 字段与数组顺序（节点数组自底向上为 z 序）。
3. 新节点/边：唯一 ID（16 位小写十六进制，验证未占用）；每个节点整数 x/y/width/height；边端点必须引用存在或新起草的节点。
4. 布局有意为之：分组内边距 20px、间距 40px，需要时换行，分组扩容先预览。

## 事务（operation_type: canvas）

校验后构建 bundle：JSON 可解析、节点类型合法、ID 唯一、边端点存在、尺寸正整数、file/background 路径安全且存在、新节点不无故重叠/溢出。canvas 与目录变更同 bundle。inspect → 预览 → 确认 → apply（经 WSL 桥）。删除/替换/改名等破坏性变更须预览后明确同意。报告 operation_id、变更路径、节点 ID 与最终位置。不 commit git。
