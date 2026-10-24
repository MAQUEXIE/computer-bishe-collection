# 29 拼车出行系统

绿色出行 · 顺路拼车 · 费用动态分摊

## 技术栈

- 后端：SpringBoot 2.7.18 + MyBatis 2.3.2 + MySQL 8（JDK 1.8）
- 前端：Vue 3 + Vite 6 + Element Plus + Vue Router + Pinia + Axios
- 后端端口：9029
- 前端端口：5129（/api 代理到 http://localhost:9029）
- 数据库：db_29_carpool（utf8mb4）

## 一键启动

### 1. 初始化数据库

```powershell
Get-Content db\init.sql -Raw -Encoding UTF8 | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --user=root --password=root --default-character-set=utf8mb4
```

### 2. 启动后端

```powershell
cd backend
$env:JAVA_HOME='C:\Program Files\Amazon Corretto\jdk1.8.0_492'
mvn spring-boot:run
```

### 3. 启动前端

```powershell
cd frontend
npm install
npm run dev
```

浏览器访问 http://localhost:5129

## 测试账号

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | admin | 123456 | 行程审核、用户管理、纠纷处理、数据统计 |
| 车主 | driver | 123456 | 王师傅，发布行程、乘客审核、确认出发、评价乘客 |
| 乘客 | passenger | 123456 | 李乘客，搜索行程、申请拼车、支付、评价车主 |

开放注册：乘客注册直接可用；车主注册后待管理员审核资质。

## 功能清单与实测结果

### 管理员
- [x] 数据统计（Dashboard：用户数/行程数/进行中/纠纷数/流水）
- [x] 行程审核（通过/拒绝车主发布的行程）
- [x] 用户管理（按角色筛选、封禁/解封用户）
- [x] 纠纷处理（查看纠纷列表、填写处理结果并标记已处理）

### 车主
- [x] 发布行程（填写路线/时间/座位/全程车费，提交管理员审核）
- [x] 乘客审核（同意/拒绝乘客的拼车申请，实时显示动态均摊金额）
- [x] 确认出发（状态流转：已发布 → 已出发 → 已完成）
- [x] 行程评价（对同行乘客打分+文字评价）

### 乘客
- [x] 搜索行程（关键词/出发地/目的地/日期筛选）
- [x] 申请拼车（一键申请，顺路推荐弹窗展示相似路线）
- [x] 支付（车主同意后支付动态均摊金额）
- [x] 评价（对车主打分+文字评价）

## 创新点

1. **顺路匹配**：乘客点击"详情/顺路推荐"，后端根据当前行程的出发地/目的地关键词匹配、按时间差排序推荐相似行程。
2. **动态分摊**：车费 = 全程车费 / 座位数，在车主行程列表、乘客搜索列表、乘客审核页、我的拼车页实时显示人均均摊金额。

## 修复的 Bug（实测过程中）

1. **axios baseURL 双前缀**：`request` 实例 baseURL 已设 `/api`，但所有页面调用又写了 `/api/xxx`，导致请求打到 `/api/api/xxx` 返回 404。批量改为 `/xxx`。
2. **乘客审核页表格不显示**：`el-table v-if="currentTrip"` 但 `currentTrip` 从未赋值，load() 中补上 `currentTrip.value = { id: tripId.value }`。
3. **Element Plus 动画卡死**：全局样式加 `*{transition:none!important;animation:none!important}` 预防。

## 已知限制

- 登录态存 localStorage，后端用 `X-User-Id` 头识别用户（无 JWT，仅演示用）。
- 支付为前端模拟，未接真实支付渠道。
- 顺路匹配基于字符串 LIKE 匹配，未做地理坐标距离计算。
- 未做地图/路线展示，仅文本路线。

## 截图清单（screenshots/）

```
管理员/数据统计.png
管理员/行程审核.png
管理员/用户管理.png
管理员/纠纷处理.png
车主/发布行程.png
车主/乘客审核.png
车主/确认出发.png
车主/行程评价.png
乘客/搜索行程.png
乘客/申请拼车.png
乘客/支付.png
乘客/评价.png
```

共 12 张，MD5 全量唯一（已去重校验）。

## 代码文件数

- backend: 26 个文件
- frontend: 22 个文件
- db: 1 个文件
- 合计: 49 个
