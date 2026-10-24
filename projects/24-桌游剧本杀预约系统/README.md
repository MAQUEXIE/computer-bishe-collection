# 24 桌游剧本杀预约系统

桌游 / 剧本杀门店预约平台，支持玩家浏览预约、拼车组队、支付核销；店家管理游戏与场次、确认预约；管理员审核店铺、配置类目、抽成结算与数据报表。

## 技术栈

- 后端：SpringBoot 2.7.18 + MyBatis + MySQL 8（JDK 1.8）
- 前端：Vue 3 + Vite + Element Plus + Vue Router + Pinia + Axios
- 后端端口：**9024**；前端端口：**5124**（`/api` 代理到 `http://localhost:9024`）
- 数据库：**db_24_boardgame**（utf8mb4）

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

### 3. 启动前端（新终端）

```powershell
cd frontend
npm install
npm run dev
```

浏览器访问 http://localhost:5124

## 测试账号

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | admin | 123456 | 平台运营 |
| 店家 | shop | 123456 | 老司机桌游吧 |
| 玩家 | player | 123456 | 爱本家小张 |

玩家开放注册（登录页"玩家注册"Tab）。

## 功能清单与测试结果

### 玩家（✓ 全部通过）
- ✓ 桌游浏览（首页卡片列表，按桌游/剧本杀筛选、类目、关键词搜索）
- ✓ 游戏详情（封面、描述、人数、时长、实时余位场次表，满场不可约）
- ✓ 预约下单（选场次、选人数、自动算价、占座）
- ✓ 支付（模拟微信支付，订单状态 UNPAID→PAID）
- ✓ 取消预约（释放座位）
- ✓ 拼车组队（拼车池卡片、加入拼车自动下单、进度条、满员成局）
- ✓ 我的预约（订单列表、支付/取消按钮）

### 店家（✓ 全部通过）
- ✓ 桌游剧本管理（列表、新增、编辑、上下架、删除、封面图选择）
- ✓ 场次管理（开场、编辑、删除、实时余位 booked/total、满场自动标记）
- ✓ 预约确认（按状态筛选、到场核销 PAID→VERIFIED）
- ✓ 我的结算（查看本店铺抽成记录）

### 管理员（✓ 全部通过）
- ✓ 数据报表（玩家数、店铺数、待审数、游戏数、订单数、累计流水、各店经营表）
- ✓ 店铺审核（待审列表、通过/拒绝，状态实时切换）
- ✓ 类目配置（桌游/剧本杀分类 CRUD）
- ✓ 抽成结算（按店铺生成一期结算、10% 抽成、确认打款）

## 创新点实现

1. **拼车组队**：玩家在拼车池看到未满的场次，一键加入后自动生成预约订单并占座；`t_carpool.joined_seats` 原子加座，满员自动置 FULL。
2. **场次空位实时**：`t_session.booked_seats` 与 `total_seats` 在下单/取消时原子增减；满员自动 `status=2 已满`，玩家端预约按钮 disabled；取消后若原已满自动恢复 `status=1 开放`。

## 修复的 Bug（实测过程中）

1. `Layout.vue` 用了 `<router-view/>` 但路由未嵌套，导致页面内容空白 → 改为 `<slot/>`。
2. `BookingController` 中 `new SimpleDateFormat(...).format(new Date)` 漏了 `()` → 编译错误。
3. `AdminController.dashboard` 中 `countByShop(1)` 传 int 给 Long 参数 → 改为 `1L`。
4. `Session.sessionDate` 是 `Date`，Jackson 序列化为 ISO 长串 → 改为 `String`，前端直接显示 `yyyy-MM-dd`。
5. Element Plus `el-tag` 进入动画类 `el-zoom-in-center-enter-from` 在禁用动画后卡在 opacity:0，导致余位/状态标签不可见 → 全局 CSS 加 `.el-tag{opacity:1!important;transform:none!important}`，实测时再用 `bu.js` 清除残留动画类。
6. `bu.click(ref)` 对部分 Element Plus 按钮偶发无效 → 改用 `bu.js("document.querySelectorAll('button')...el.click()")` 触发。

## 已知限制

- 支付为前端模拟弹窗，未接入真实支付网关。
- 拼车"加入"后直接生成 1 人订单（需再支付），未做"先占座后支付"的预占逻辑。
- 店家注册未开放（由管理员预置 shop 账号）；玩家注册开放。
- 场次日期固定为当天（CURDATE()），跨天未做清理。
- 报表数据为实时聚合查询，未做缓存。

## 截图清单（screenshots/）

```
screenshots/
├── 玩家/
│   ├── 桌游浏览.png
│   ├── 预约.png
│   ├── 拼车组队.png
│   └── 支付.png
├── 店家/
│   ├── 桌游剧本管理.png
│   ├── 场次管理.png
│   └── 预约确认.png
└── 管理员/
    ├── 店铺审核.png
    ├── 类目配置.png
    ├── 抽成结算.png
    └── 数据报表.png
```

11 张截图 MD5 全部唯一（已比对）。
