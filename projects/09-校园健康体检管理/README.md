# 09 校园健康体检管理

校园体检全流程管理系统：学生套餐选择与预约、查看报告与复查提醒；校医批量导入名单、体检项目录入、异常自动标记与复查提醒；管理员套餐/机构配置与统计分析。

## 技术栈
- 后端：FastAPI + SQLAlchemy 2.0 + PyMySQL + Pydantic（端口 **9009**）
- 前端：Vue3 + Vite + Element Plus + Vue Router + Pinia + Axios（端口 **5109**，`/api` 代理到 9009）
- 数据库：MySQL 8，库名 **db_09_physical**（utf8mb4）

## 一键启动
```powershell
# 1. 建库 + 初始化数据
Get-Content D:\000-计算机项目\30个系统项目\09-校园健康体检管理\db\init.sql -Raw -Encoding UTF8 | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --user=root --password=root --default-character-set=utf8mb4

# 2. 后端（首次先 pip3 install fastapi uvicorn sqlalchemy pymysql pydantic python-multipart）
cd D:\000-计算机项目\30个系统项目\09-校园健康体检管理\backend
python -m uvicorn main:app --host 0.0.0.0 --port 9009

# 3. 前端（另开终端，首次先 npm install）
cd D:\000-计算机项目\30个系统项目\09-校园健康体检管理\frontend
npm run dev
```
浏览器打开 http://localhost:5109

## 测试账号
| 角色 | 用户名 | 密码 |
|---|---|---|
| 管理员 | admin | 123456 |
| 校医 | medic | 123456 |
| 学生 | student | 123456 |

学生开放注册（注册页 `/register`，默认角色 student）。CSV 批量导入建档的学生初始密码统一为 123456。
CSV 导入模板：`db/students_import_template.csv`（列：username,real_name,gender,student_no,class_name,phone），校医端页面也可直接下载。

## 功能清单与实测结果
### 学生端
- 套餐选择 ✓（4 个套餐卡片、项目明细弹窗、参考区间展示）
- 预约体检 ✓（选机构+日期+时段，重复预约同日同套餐拦截，取消预约）
- 查看报告 ✓（报告列表、异常项数量标记、报告详情弹窗逐项判定、我的复查提醒）

### 校医端
- 批量导入名单 ✓（上传 CSV 批量建档，成功/跳过结果提示，学生名单实时刷新）
- 体检项目录入 ✓（待体检预约开始录入 → 逐项填结果 → 提交；系统自动对照正常值区间判定偏高/偏低/异常）
- 异常标记与复查提醒 ✓（自动生成的提醒列表、按待复查/已复查筛选、标记已复查、改建议）

### 管理员端
- 套餐配置 ✓（套餐增删改、项目配置：数值区间/定性正常值、新增/删除项目）
- 机构管理 ✓（机构增删改、启用/停用、预约数统计，实测新增 1 个机构成功）
- 统计分析 ✓（学生/预约/报告/异常检出率、套餐分布、机构分布、待复查提醒数）

## 创新点实现说明
1. **批量导入建档**：校医上传 CSV（带表头），解析后批量创建学生账号（默认密码 123456），已存在用户名自动跳过并反馈。
2. **异常项自动标记 + 复查提醒自动生成**：录入数值结果时，后端对照套餐项目的 normal_min/normal_max 区间判定 high/low；定性项目对照 normal_text 判定 abnormal_text；命中异常即在 `exam_results.judge` 打标，并自动在 `alerts` 表生成一条待复查提醒（含建议文案与建议复查日期），学生端与校医端同步可见。

## 修复的 bug
1. **预约可选择过去日期**（实测发现）：学生预约日期选到了 2026-09-28（今天之前）仍成功。已在 `POST /api/appointments` 增加日期校验，过去日期返回 400 并提示。已重启后端生效。
2. **Edit 工具对 main.py 失效**：改用补丁脚本完成上述修改（文件本身无问题）。

## 已知限制
- 登录 token 存内存，重启后端后所有登录态清空（演示环境可接受）。
- 数据报表使用 Element Plus 表格展示，未引入图表库。
- 种子数据中存在一条男生（吴十）预约了"女生关爱套餐"，为演示数据混搭，不影响功能；可在管理员端调整。
- 批量导入仅支持 CSV（不依赖 Excel 三方库），Excel 可另存为 CSV 后导入。

## 截图清单（screenshots/）
- 学生/套餐选择.png、学生/预约体检.png、学生/查看报告.png
- 校医/批量导入名单.png、校医/体检项目录入.png、校医/异常标记与复查提醒.png
- 管理员/套餐配置.png、管理员/机构管理.png、管理员/统计分析.png

共 9 张，MD5 全部唯一。
