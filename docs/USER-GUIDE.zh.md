# zcode-obsidian 使用与维护手册

> 版本 1.0（2026-09-03）· 适用于 zcode-obsidian v0.1（上游 claude-obsidian v2.1.1）
> 本文是唯一真源，存于仓库 `docs/USER-GUIDE.zh.md`，全文镜像于知识库 `wiki/concepts/zcode-obsidian 使用手册`。

---

## 1. 项目简介

zcode-obsidian 是 Zcode 的 AI 知识库插件化方案：把开源项目 [claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian)（Claude Code 插件，MIT）完整移植到 Zcode，实现"**本地优先、来源可溯、事务安全**的个人第二大脑"。

核心理念（Karpathy LLM Wiki 模式）：不做 RAG——**让 AI 像图书管理员一样直接维护一个 Obsidian 维基**。你只负责"存"和"用"，AI 负责建链、索引、日志、溯源，一切写入可预览、可回滚、可追责。

### 组件全景

```
Windows 桌面
├── ZCode ─────────── 日常入口:15 个 obsidian-* 技能 + SessionStart 自动上下文
├── Obsidian KB ───── 可视化(WSLg 渲染的 Linux 版 1.13.7,桌面快捷方式「Obsidian KB」)
└── GitHub yongzhi-xyz/zcode-obsidian(私有) ── 代码资产:upstream/ vendored + port/ 移植层
         │ 全部落在 WSL Ubuntu 22.04(Python 3.14)
         ├── ~/repos/zcode-obsidian     代码单源(upstream/ 即运行副本)
         │   ├── port/wsl/kb.sh         WSL 桥(所有引擎调用的统一入口)
         │   ├── port/skills/           15 个 Zcode 技能(真源,install.ps1 装配)
         │   ├── port/hooks/            SessionStart 上下文注入
         │   └── port/agents/           3 个子代理提示词模板
         └── ~/vaults/kb                知识资产(唯一不可再生的东西)
```

### 硬性环境事实（改动前必读）

- vault **必须**在 WSL ext4 内（`~/vaults/kb`）。放 `/mnt/*`（NTFS 挂载）会因权限位缺失触发 `RESULT_DRIFT` 回滚（实测教训）。
- Windows 版 Obsidian 打不开该 vault（9p 文件监视器 EISDIR 崩溃，`W:` 盘符同样）。可视化只能用 WSLg 的 Linux 版。
- 出网走代理桥（如需）：WSL2 默认 NAT 模式下，WSL 访问宿主代理需在 Windows 侧做端口转发（`netsh` 或代理软件的"允许局域网连接"），端口按你所用代理软件自定；`mirrored` 网络模式若可用则更省事（部分 Windows 版本/网卡不支持，失败可回滚）。
- Windows 版与 Linux 版 Obsidian **不得同时打开 kb 仓库**。

---

## 2. 在 ZCode 中使用（详细教程）

技能已装于 `~/.zcode/skills/`（15 个，新会话生效）。触发方式两种：斜杠命令（`/obsidian-save` 等）或自然语言命中 description 里的触发词。每次新会话开始，SessionStart hook 会自动把 `wiki/hot.md` 热缓存注入上下文——AI 一开口就知道库里有什么。

### 2.1 摄入素材（obsidian-ingest）

| 步骤 | 操作 |
|---|---|
| 投料 | 把文章/ PDF/ 代码放进 `inbox/`（Obsidian 里直接拖拽或新建粘贴；手机端未来经同步投递）|
| 发起 | 对 Zcode 说：「把 inbox 里的材料摄入知识库」|
| AI 做 | SHA-256 查重 → 分类 → 提取断言/实体/概念/矛盾 → 原文存 `.raw/captured/<哈希>.md`（不可变）→ 起草源页+概念页+实体页，互链进现有网络 |
| 你做 | 看 inspect 预览（全部变更路径+断言评级+矛盾点+预算消耗）→ 确认 → apply |
| 收尾 | 建议「更新检索索引」（大变更后） |

约束：URL 抓取需明确同意域名；PDF/OCR 依赖宿主能力，不可用会如实说明；同一材料绝不重复摄入。

### 2.2 保存对话结论（obsidian-save）

说「**保存这个结论**」/「把刚才的分析存档」。AI 查重 → 选最小笔记类型（synthesis/concept/decision/session）→ 起草**四件耦合**：笔记 + `index.md` 条目 + `log.md` 顶条 + `hot.md` 刷新 → 预览 → 确认 → apply。会话结束**绝不**自动保存；想留什么必须明说。

### 2.3 知识库问答（obsidian-query，严格只读）

说「**根据知识库，X 和 Y 什么关系？**」。流程：hot/index 定位 → BM25 检索（`--no-rerank`）→ 读最相关页 → 带引用回答（`[[页面#小节]]`）。证据五级标注：accepted（已确立）/ provisional（单来源，明说）/ contested（矛盾并陈不站队）/ unsupported（直说无据，不用模型记忆填补）/ deprecated。索引坏了自动降级为目录导航并告知。**本技能零写入**；想留住答案 → 转 obsidian-save。

### 2.4 体检与修复（obsidian-lint）

说「**体检一下知识库**」。确定性检查：死链、孤儿页、frontmatter 缺失、空小节、过期索引、台账违规。**只报不修**；你选定要修的条目后，AI 起草修复事务（新 operation_id）→ 预览 → apply → 复检对比。

### 2.5 日志折叠（obsidian-fold）

说「**折叠日志**」。对 `log.md` 做 16 条一批的摘录式归总 → `wiki/folds/fold-k4-from-...-to-...-n16.md`，三件耦合（fold 页+目录+日志），不改子条目、可幂等重放。月度做一次即可。

### 2.6 方法论模式（obsidian-mode）

「**现在什么模式**」/「**切换到 zettelkasten**」。查询只读；切换是 configuration 事务（两段式），只影响未来新笔记的归档路由，永不移动旧笔记。本项目当前 generic。

### 2.7 联网研究（obsidian-autoresearch）

说「**调研 X**」。先谈契约：主题/排除项/是否批准外发/预算（默认 ≤3 轮、每轮 ≤5 源）/停止条件。产物是**草稿 dossier**（引用完整）→ 单独审查入库；对既有页面的更新是**第二笔独立事务**，可拒绝而不丢研究成果。

### 2.8 其他

- `obsidian-retrieve`：索引构建/诊断细节（日常由 wiki/save 的收尾建议触发即可）
- `obsidian-canvas`：JSON Canvas 白板读写（事务）
- `obsidian-defuddle`：网页正文清洗规划（configured 状态需人工审查 runner，绝不冒充 verified）
- `obsidian-markdown` / `obsidian-bases`：语法参考与起草校验
- `obsidian-think`：十阶段决策推理（纯只读）
- `obsidian-wiki`：总编排/诊断入口（doctor/lint/检索维护）

### 2.9 git 存档点（可选但推荐）

```bash
wsl -d Ubuntu -- bash ~/repos/zcode-obsidian/port/wsl/kb.sh checkpoint <OPERATION_ID>
```

把一笔已完成事务落成**精确对应**的 git 提交（事务结果哈希+树哈希双校验）。前提：vault 里已有基线提交（初始化完成后手动做一次全量提交即可）。重要操作后做一次，历史即清晰。

---

## 3. 知识组织结构

### 3.1 四层目录（写入规则各不相同）

| 目录 | 谁写 | 规则 |
|---|---|---|
| `inbox/` | 你 | 投递口，AI 只读；消化后材料仍留在原地（归你管理） |
| `daily/` | 你 | 日记（Obsidian Daily Notes，`YYYY-MM-DD.md`），AI 只在生成周报时读 |
| `.raw/captured/` | AI | 原始证据，按内容哈希命名，**create-only 永不改写** |
| `wiki/` | AI | 知识层，**只经事务写入**（见下） |
| `.vault-meta/` | 引擎 | 锁/事务日志/检索索引/地址计数器——派生态，可重建，**永不同步、永不入 git** |

### 3.2 generic 模式的页面类型

| 类型 | 目录 | 放什么 | 例子 |
|---|---|---|---|
| source | `wiki/sources/` | 每份外部材料一篇"它说了什么+我怎么看" | 某本读完的书 |
| concept | `wiki/concepts/` | 可复用知识/概念 | 卡片盒笔记法 |
| entity | `wiki/entities/` | 人物/产品/组织 | 某位常引用的作者 |
| question | `wiki/questions/` | 追踪中的开放问题 | — |
| session | `wiki/sessions/` | 会话综合结论/决策/周报 | 项目启动会话 |
| meta | `wiki/` 根 | index/log/hot/overview 四件套 | — |

选型原则：**类型判定客观**（AI 失误率最低）、跨职业稳定；主题组织靠 `[[双向链接]]` 和后期长出的 MOC，标签只做状态粗筛（≤5 个），不预设主题标签体系。

### 3.3 frontmatter 约定

`type / title / created / updated / status(developing→mature) / tags / related / sources`。每页可携带引擎分配的稳定地址 `address: c-NNNNNN`（ingest 时经 `address_requests` 自动分配，重命名不失效）。

### 3.4 溯源双台账

- `wiki/meta/ledgers/source-ledger.json`：来源身份（规范 `src-` ID=哈希(origin+内容)）、authority（official/primary/secondary/community/synthetic/unknown）、review_status、retrieved_at/refresh_due、关联页面。
- `wiki/meta/ledgers/claim-ledger.json`：断言（`clm-` ID）、text、risk(normal/high)、五级 assessment、confidence、location（必须指向真实页面+真实锚点）、evidence[]（source_id+relation supports/contradicts/context）。
- 硬规则：accepted 需新鲜活跃非合成来源；高风险 accepted 需两个独立来源；矛盾必须并陈；**绝不编造引用**。

### 3.5 事务模型（一切写入的安全网）

`claude-obsidian.transaction.v1` bundle（全部变更+预期哈希）→ `transaction inspect`（产出 approval_sha256，绑定计划与 vault 身份）→ **人工预览确认** → `apply`（全库锁+逐文件验哈希+日志+可回滚）。冲突 exit 75 = 重读重建，绝不硬闯；中断 `transaction recover`。耦合写入强制：改笔记必须同笔带上索引/日志/热缓存。

---

## 4. 标准工作流（端到端）

### 4.1 收集 → 沉淀 → 输出

```
平时:素材丢 inbox(手机端未来经同步) ─┐
                                     ├→ 「摄入」→ 源页+概念页织网
对话结论 ──「保存这个」──────────────┘
要输出: 「根据知识库,XX 已有什么素材」→ 素材清单(含证据分级)
     → 「基于素材出大纲/初稿」→ 对话内迭代(草稿不进库)
     → 发布后「把最终稿和新结论存进去」→ 文章作为新来源回流
```

### 4.2 周报 / 长期回顾

每天 5 分钟日记（`daily/`，Obsidian 快捷键）；周日「读取本周日记，结合知识库生成周报，存成笔记」（save 事务，链到相关概念页）；每月「折叠日志」；年底一条 query 读全年周报+folds 生成年度回顾。

### 4.3 体量感参考（示例数字，非运行数据）

一个用了一个月的个人库大致是：10-20 页（几个会话页 + 几个概念页 + 1-2 个源页 + 4 元数据页）；断言个位数、全部 provisional 起步；事务 10 笔上下；git 历史两位数提交。体量无关紧要，链接质量才是关键。

---

## 5. 与上游项目（claude-obsidian v2.1.1）的差异

**设计原则：upstream/ 逐字节 vendored 永不修改；一切适配在 port/。**

| 维度 | 上游（Claude Code） | 本项目（Zcode） |
|---|---|---|
| 分发 | `.claude-plugin` 插件/marketplace | 独立仓库 vendored + `port/`；技能装用户级 `~/.zcode/skills/` |
| 引擎调用 | 技能内直接 `python3` | 统一经 `port/wsl/kb.sh`（自动选定 vault） |
| 检索前缀 | 三级：Anthropic API/`claude -p`/本地合成 | 固定本地合成（`--no-llm`，零外发） |
| hooks | Claude 事件 + `${CLAUDE_PLUGIN_ROOT}` | Zcode 7 事件 schema，process 型钩子经 wsl.exe 调桥 |
| 子代理 | Claude Code agents 格式 | `port/agents/*.md` Zcode Agent 提示词模板 |
| 平台 | macOS/Linux/WSL | Windows 宿主 + WSL 全能力（含 WSLg 桌面） |
| 插件清单 | `.claude-plugin/plugin.json` | 暂无（用户级技能目录已可用；打包待做） |

**完整保留**：事务模型、审批哈希、耦合写入、溯源双台账、能力检测、防注入条款、检索栈。**未移植**：Local REST API / MCP 外部读通道评估（无需求）。

## 6. 维护指南

### 6.1 上游更新（UPSTREAM.md 四铁律）

订阅 releases.atom → 新版 ZIP 与 `upstream/` diff → 整体替换+重生成 manifest → 提交 → `kb.sh lint` 验证兼容。**永不手改 upstream/**；上游 bug 走 fork 提 PR。重点盯 CLI 子命令签名、config schema、SKILL.md 规程变化。

### 6.2 备份与迁移

- 唯一资产 = vault 文件夹（`~/vaults/kb`）；`.vault-meta/` 可弃。
- 日常：git 历史（基线+checkpoint）在本机；跨机建议坚果云/移动硬盘拷贝 vault。
- 换机：新机装 WSL+Python3.11+ → clone 本仓库 → vault 拷入 `~/vaults/kb` → `kb.sh lint` → Obsidian(Linux) 打开。可选 `wsl --export` 整体搬环境。

### 6.3 故障速查

| 症状 | 原因 | 处置 |
|---|---|---|
| apply 报 RESULT_DRIFT | vault 在 /mnt/* 上 | 移回 ext4（已定位 ~/vaults/kb，勿迁出） |
| Obsidian 打开报 EISDIR | 用了 Windows 版开 WSL 路径 | 用桌面「Obsidian KB」快捷方式（WSLg 版） |
| git push 连接重置 | 代理客户端没开 / 网关 IP 变了 | 开代理；`repush` 前重读网关 IP 更新 http.proxy |
| hook 没触发 | config.json 被改动 | 检查 `hooks.enabled: true` 与 process 段完整 |
| exit 75 | vault 被并发修改 | 正常防护：重读重建 bundle 再走一遍 |
| 中文检索不准 | 索引过期 | 跑 obsidian-retrieve 的构建三连 |

### 6.4 已知边界

- 原生 Windows 对 vault 只读（引擎设计使然，写必须 WSL）。
- 手机同步未配置（已明确推迟；方案已定：Remotely Save + WebDAV/坚果云，排除 `.vault-meta/`）。
- 插件化打包未做（当前用户级技能目录方式完全可用）。
