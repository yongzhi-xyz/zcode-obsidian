# port/ 移植层

本目录是本项目自有的全部代码。上游的 15 个技能与 hooks 绑定 Claude Code 宿主，这里做 Zcode 适配。

## 五个宿主绑定点（技能重建清单）

| # | 绑定点 | 现状 | 适配方案 |
|---|---|---|---|
| 1 | SKILL.md 的 `PRODUCT_ROOT` 推导 | ✅ 15 技能全部走 WSL 桥 | 改为 Zcode 插件目录结构 + 经 `port/wsl/kb.sh` 桥接 |
| 2 | 检索前缀 Tier 2 依赖 `claude -p` | ✅ 固定 --no-llm | 固定 `--no-llm`（本地合成前缀，零外发）或接 Zcode 等价物 |
| 3 | hooks 适配 | ✅ SessionStart 热上下文注入(config.json process 钩子,已双侧验证) | — |
| 4 | agents 子代理模板 | ✅ port/agents/{verifier,wiki-ingest,wiki-lint}.md | — |
| 5 | 插件清单 | 待做（当前以用户级技能目录安装，已可用） | — |

## 技能映射

15 个上游技能 → Zcode 技能（命名空间 `zcode-obsidian:*`），工作流逻辑（先预览后应用、耦合写入、溯源规则、预算控制）全部保留，只改上述绑定点：

- [x] wiki（总编排）→ zcode-obsidian:wiki
- [x] save → zcode-obsidian:save
- [x] wiki-ingest → zcode-obsidian:ingest
- [x] wiki-query → zcode-obsidian:query
- [x] wiki-lint → zcode-obsidian:lint
- [x] wiki-fold / wiki-mode / wiki-retrieve / wiki-cli → obsidian-fold/mode/retrieve/cli
- [x] autoresearch / canvas / defuddle → obsidian-autoresearch/canvas/defuddle
- [x] obsidian-markdown / obsidian-bases / think → obsidian-markdown/bases/think

## 已验证

- 2026-09-03（晚）：hooks 双侧实测(1008B JSON,防注入包装);vault git 基线与 checkpoint 端到端验证(精确操作提交)均通过;累计 7 笔事务,lint 全绿。

- 2026-09-03：路线 C 手动验证通过——Zcode 会话内按上游 save 技能契约手动编排 CLI，完成首次事务入库（`save-YYYYMMDD-<slug>` 形式操作号，4 耦合写入，lint 零问题，中文检索命中）。
