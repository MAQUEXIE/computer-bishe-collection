# 20 校园跑腿代取平台

校内即时跑腿服务：任务发布 → 管理员审核 → 抢单池抢单 → 跑腿送达 → 用户确认 → 评价，并配套计费规则与跑腿信用分体系。

## 技术栈
- 后端：FastAPI + SQLAlchemy 2.0 + PyMySQL + Pydantic（端口 **9020**）
- 前端：Vue3 + Vite + Element Plus + Vue Router + Pinia + Axios（端口 **5120**，`/api` 代理到 9020）
- 数据库：MySQL `db_20_errand`（utf8mb4）

## 一键启动
```powershell
# 1) 初始化数据库（先确保 MySQL80 服务在运行）
Get-Content D:\000-计算机项目\30个系统项目\20-校园跑腿代取平台\db\init.sql -Raw -Encoding UTF8 | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --user=root --password=root --default-character-set=utf8mb4

# 2) 启动后端（首次先 pip3 install fastapi uvicorn sqlalchemy pymysql）
cd D:\000-计算机项目\30个系统项目\20-校园跑腿代取平台\backend
python -m uvicorn main:app --host 0.0.0.0 --port 9020

# 3) 启动前端（首次先 npm install）
cd D:\000-计算机项目\30个系统项目\20-校园跑腿代取平台\frontend
node node_modules\vite\bin\vite.js
```
浏览器打开 http://localhost:5120

## 测试账号
| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | admin | 123456 | 任务审核 / 计费规则 / 投诉处理 |
| 下单用户 | user | 123456 | 发布任务 / 查看接单 / 送达确认 / 评价 |
| 跑腿员 | runner | 123456 | 抢单池抢单 / 任务完成 / 收入与信用分 |
| 跑腿员(低信用演示) | runner2 | 123456 | 信用分 55 < 60，抢单被拦截 |

开放注册：登录页点击「立即注册」可选「下单用户」或「跑腿员」。

## 功能与状态机
发布任务（待审核 pending_audit）→ 管理员通过（进入抢单池 available）→ 跑腿员抢单（taken）→ 跑腿员标记送达（delivered）→ 下单人确认送达（confirmed，酬劳结算+信用分+5）→ 下单人评价（rated）。审核拒绝 rejected；任一方可投诉 → complained → 管理员处理后回退到 confirmed/rated。

## 创新点
- **抢单池**：审核通过的任务统一进抢单池（`GET /api/tasks/pool`），按发布时间倒序，跑腿员一键抢单，后端用状态校验防止并发抢走。
- **跑腿信用分**：初始 100，每完成一单确认 +5；投诉核实成立由管理员扣分（如 -10）；信用分 < 60 禁止抢单（`grab` 接口统一拦截）。
- **自动计费**：按管理员配置的「起步价 + 每公里加价 × 距离」计算，不低于最低酬劳；`GET /api/fee-rule` 公共接口让下单页实时预览。

## 逐角色功能测试结果（本机实测）
### 管理员
- ✓ 任务审核：通过待审核任务（含新发布 2 条），通过后任务进入抢单池
- ✓ 计费规则：编辑起步价 3.00→3.50 保存成功，发布任务按新规则重算酬劳
- ✓ 投诉处理：对「麦当劳送餐洒漏」投诉填写处理结果、扣信用分 10 分并办结
### 下单用户
- ✓ 发布跑腿任务：表单发布成功，预估酬劳实时随计费规则联动
- ✓ 查看接单：我的任务列表展示接单跑腿员、状态、编号
- ✓ 送达确认：对「送雨伞到操场」确认送达，跑腿员即时入账 ¥5.70
- ✓ 评价：5 星 + 文字评价提交成功，列表显示 5 星
### 跑腿员
- ✓ 抢单池抢单：抢单池 6 条可接任务，抢「取南门顺丰快递」成功
- ✓ 任务完成：标记送达成功，状态变为「已送达待确认」
- ✓ 收入与信用分：累计收入 ¥24.20、信用分 110、完成 5 单，流水含完成任务/投诉扣款两类

## 实测中修复的 Bug
1. **models.py 漏 `from database import Base`** → 后端启动报 NameError，已补上（参考项目 06 写法）。
2. **发布页预估酬劳与后端实际计费不一致**（前端写死费率显示 ¥5.25，后端按新规则算 ¥5.75）→ 新增公共接口 `GET /api/fee-rule`，前端发布页 onMounted 实时拉取，预览与实际一致。
3. **PowerShell 无法用 `Start-Process npm`**（npm 是 cmd 垫片）→ 改用 `node node_modules\vite\bin\vite.js` 启动前端。
4. **ElMessageBox 确认弹窗在自动化下偶发不点中** → 改用 `bu.js` 直接点击弹窗「确定」按钮完成确认。

## 已知限制
- 登录 token 存内存，重启后端需重新登录（演示用）。
- 无真实支付，酬劳为虚拟结算。
- 距离/预估距离由发布人填写，未接地图。
- 图片资源仅用项目内 SVG logo 与 Element Plus 内置图标，无外链，离线可用。

## 截图清单（screenshots/，共 10 张，MD5 已两两去重）
- 下单用户/发布跑腿任务.png、查看接单.png、送达确认.png、评价.png
- 跑腿员/抢单池抢单.png、任务完成.png、收入与信用分.png
- 管理员/任务审核.png、计费规则.png、投诉处理.png
