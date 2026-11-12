# 事项跟踪

在 `HeShian/nixos` 的 GitHub Issues 中管理事项和规格说明。使用 `gh` 操作。首次写入前运行 `gh repo view --json nameWithOwner` 核对目标。如果默认仓库不同，在命令中显式指定 `--repo HeShian/nixos`。下方 API 路径中的 `<owner>/<repo>` 使用 `HeShian/nixos`。

## 事项操作

- 创建事项时运行 `gh issue create --title "..." --body-file <文件>`。技能要求发布到事项跟踪器时，创建 GitHub Issue。
- 读取事项时运行 `gh issue view <编号> --json number,title,body,labels,comments`。技能要求获取工单时，使用同一命令。
- 列出事项时运行 `gh issue list --state open --json number,title,body,labels,comments`，按需调整 `--state` 和 `--label`。
- 留言时运行 `gh issue comment <编号> --body "..."`。关闭前先留言说明原因，再运行 `gh issue close <编号>`。事项已经关闭时，仍可用留言命令补充说明。
- 更新标签时使用 `gh issue edit <编号> --add-label "标签"` 或 `--remove-label "标签"`。分流时查阅 [分流标签](triage-labels.md)。

## 父子事项与依赖

- 添加子事项时使用 `gh issue create --parent <父事项> ...` 或 `gh issue edit <父事项> --add-sub-issue <子事项>`。旧版 CLI 可用 `gh api --method POST repos/<owner>/<repo>/issues/<父事项>/sub_issues -F sub_issue_id=<子事项数据库ID>`。如果仓库不支持子事项，在父事项中添加任务清单条目，并在子事项正文开头写 `Part of #<父事项>`。
- 设置阻塞关系时使用 GitHub 原生依赖。创建时用 `gh issue create --blocked-by <编号>,<编号> ...`，创建后用 `gh issue edit <子事项> --add-blocked-by <阻塞事项>`。旧版 CLI 可用 `gh api --method POST repos/<owner>/<repo>/issues/<子事项>/dependencies/blocked_by -F issue_id=<阻塞事项数据库ID>`。如果原生依赖不可用，在事项正文开头写 `Blocked by: #<编号>, #<编号>`。
- 获取事项的数据库 ID 时运行 `gh api repos/<owner>/<repo>/issues/<编号> --jq .id`。查询未关闭的阻塞事项数量时，将筛选条件换成 `.issue_dependencies_summary.blocked_by`。使用 `gh issue view <编号> --json blockedBy` 时，筛选 `.blockedBy.nodes[]` 中状态为 `OPEN` 的事项。所有阻塞事项关闭后，当前事项即可开始。

## PR 分流

**PRs as a request surface: no.**

启用后，外部 PR 使用与事项相同的分流标签和状态。用 `gh pr view <编号>` 阅读正文，用 `gh pr view <编号> --comments` 阅读评论，用 `gh pr diff <编号>` 查看差异。通过 `gh api --paginate 'repos/{owner}/{repo}/pulls?state=open'` 列出开放 PR，并排除 `author_association` 为 `OWNER`、`MEMBER` 或 `COLLABORATOR` 的记录。使用 `gh pr comment`、`gh pr edit --add-label`、`gh pr edit --remove-label` 和 `gh pr close` 更新 PR。GitHub 的事项与 PR 共用编号，遇到类型未明确的编号时先尝试 `gh pr view`，再尝试 `gh issue view`。

## Wayfinder

- 用带 `wayfinder:map` 标签的事项保存 Notes、Decisions-so-far 和 Fog。
- 将工单关联为该事项的子事项，标签为 `wayfinder:<类型>`。类型可为 `research`、`prototype`、`grilling` 或 `task`。
- 按地图顺序选择首个开放、未分配且没有未关闭阻塞项的子事项。
- 领取时先运行 `gh issue edit <编号> --add-assignee @me`。
- 完成时先留言记录结论，再关闭事项，然后把结论摘要和链接补到地图的 Decisions-so-far。
