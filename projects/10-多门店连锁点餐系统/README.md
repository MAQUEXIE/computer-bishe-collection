# 10-多门店连锁点餐系统

扫码点餐、多门店独立管理、总部统一报表的餐饮连锁数字化系统。

- **后端端口**：9010
- **前端端口**：5110（`/api` 代理到 `http://localhost:9010`）
- **数据库**：`db_10_restaurant`（utf8mb4）
- **技术栈**：SpringBoot 2.7.18 + MyBatis + MySQL 8（JDK8）；Vue3 + Vite + Element Plus + Pinia + Axios

## 一键启动

### 1. 初始化数据库（PowerShell）

```powershell
Get-Content D:\000-计算机项目\30个系统项目\10-多门店连锁点餐系统\db\init.sql -Raw -Encoding UTF8 | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --user=root --password=root --default-character-set=utf8mb4
```

### 2. 启动后端（PowerShell，必须切 JDK8）

```powershell
cd D:\000-计算机项目\30个系统项目\10-多门店连锁点餐系统\backend
$env:JAVA_HOME='C:\Program Files\Amazon Corretto\jdk1.8.0_492'
mvn -DskipTests spring-boot:run
```

### 3. 启动前端

```powershell
cd D:\000-计算机项目\30个系统项目\10-多门店连锁点餐系统\frontend
npm install
npm run dev
```

浏览器打开 http://localhost:5110

## 测试账号

| 角色 | 账号 | 密码 | 说明 |
|------|------|------|------|
| 总部管理员 | admin | 123456 | 门店管理 / 统一菜品库 / 经营数据汇总 |
| 门店店长 | store | 123456 | 万象城旗舰店；菜品管理 / 接单出餐 / 叫号 / 门店报表 |
| 顾客 | customer | 123456 | 扫码点餐；顾客也可在登录页开放注册 |

预置数据：3 家门店（万象城旗舰店、中山路店、西湖店）、统一菜品库 10 道菜、各门店选品、4 笔演示订单与支付流水。

## 功能与逐角色实测结果

### 顾客（登录 customer/123456）
- ✓ 扫码点餐：选择门店（扫码入口）、浏览分类菜品、加购物车
- ✓ 堂食/外卖：堂食填桌号、外卖隐藏桌号
- ✓ 在线支付：提交订单后微信/支付宝模拟支付
- ✓ 订单跟踪：订单列表、状态流转、叫号展示、确认完成

### 门店（登录 store/123456，万象城旗舰店）
- ✓ 菜品管理：本店菜单、调售价、上下架（售罄）、从总部统一库选品（实测把番茄炒蛋、排骨米线加入本店）
- ✓ 接单出餐：待接单订单一键接单（PAID→MAKING）
- ✓ 叫号：出餐时弹出叫号（MAKING→SERVED，分配叫号）
- ✓ 门店报表：订单数、营业额、客单价、状态分布、本店菜品销量排行

### 总部（登录 admin/123456）
- ✓ 门店管理：门店列表、新增门店（实测新增"台江万达店"）、编辑
- ✓ 统一菜品库：10 道菜列表、新增/编辑、上下架
- ✓ 经营数据汇总（创新点）：跨门店订单数/营业额汇总 + 占比进度条 + 菜品销量排行（全连锁）+ 支付流水

## 创新点实现

1. **多门店数据汇总**：`OrderMapper.storeSummary()` 按门店 GROUP BY 统计订单数与营业额，总部页展示各门店占比（el-progress）。
2. **菜品销量分析**：`OrderMapper.dishSalesRank(storeId)` 按菜品汇总销量与销售额排行，门店报表与总部汇总均展示（总部为全连锁、门店为单店）。

## 实测中修复的 Bug

1. **前端 import 路径错误**（Vite overlay 阻塞页面）：
   - `views/customer/OrderPage.vue` 在 customer 子目录，误写 `'../api'`/`'../store/user'`，已改为 `'../../api'`/`'../../store/user'`。
   - `components/Layout.vue` 在 components 目录，误写 `'../../store/user'`，已改为 `'../store/user'`。
2. **StoreDishMapper 缺少 `Dish` 实体 import**，编译报错，已补 import。
3. **MyBatis 动态 SQL 未用 `<script>` 包裹**（`dishSalesRank` 的 `<if>`），已修正，避免启动报错。

## 已知限制

- 在线支付为前端模拟，未接真实第三方支付网关。
- 门店叫号为随机分配（10-99），未按门店按日严格自增。
- 未做登录态 token/JWT，角色信息存 localStorage；刷新后端需重新登录。
- 图片为内置 SVG 占位图（public/dishes/*.svg），无外链，离线可加载。

## 截图清单（screenshots/，共 11 张，MD5 已去重，内容唯一）

- 顾客/扫码点餐.png、顾客/堂食外卖.png、顾客/在线支付.png、顾客/订单跟踪.png
- 门店/菜品管理.png、门店/接单出餐.png、门店/叫号.png、门店/门店报表.png
- 总部/门店管理.png、总部/统一菜品库.png、总部/经营数据汇总.png
