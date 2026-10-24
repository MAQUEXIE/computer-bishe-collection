# 03 生鲜配送商城（B2C + 同城配送）

> 30 个系统项目之 03 · Java 组
> 全链路：用户下单 → 商家接单备货 → 骑手抢单池抢单 → 取货 → 送达，状态机全程可追踪。

---

## 1. 技术栈

| 层 | 选型 |
|---|---|
| 后端 | Spring Boot 2.7.18 + MyBatis（注解 SQL）+ MySQL 8（JDK 1.8） |
| 前端 | Vue 3 + Vite 6 + Element Plus + Vue Router 4 + Pinia + Axios |
| 数据库 | `db_03_fresh_delivery`（utf8mb4） |
| 端口 | 后端 `9003`，前端 `5103`（/api 代理到 http://localhost:9003） |

---

## 2. 目录结构

```
03-生鲜配送商城/
├── backend/          # SpringBoot Maven 工程
├── frontend/        # Vue3 + Vite 工程
├── db/init.sql      # 建库建表 + 演示数据
├── screenshots/     # 逐角色逐功能实测截图
└── README.md
```

---

## 3. 一键启动步骤

### 3.1 建库（首次执行一次即可）

```powershell
cd D:\000-计算机项目\30个系统项目\03-生鲜配送商城
Get-Content db\init.sql -Raw -Encoding utf8 | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --user=root --password=root --default-character-set=utf8mb4
```

### 3.2 启动后端（端口 9003）

> 注意：本机 Maven 默认 JAVA_HOME 指向 JDK21，必须显式切到 JDK8，否则 SpringBoot 2.7 起不来。

```powershell
cd D:\000-计算机项目\30个系统项目\03-生鲜配送商城\backend
$env:JAVA_HOME = 'C:\Program Files\Amazon Corretto\jdk1.8.0_492'
mvn spring-boot:run
```

看到 `Started FreshApplication ... Tomcat started on port(s): 9003` 即成功。

### 3.3 启动前端（端口 5103）

```powershell
cd D:\000-计算机项目\30个系统项目\03-生鲜配送商城\frontend
npm install    # 首次
npm run dev
```

浏览器访问 http://127.0.0.1:5103

---

## 4. 测试账号（密码均为 123456）

| 角色 | 账号 | 说明 |
|---|---|---|
| 管理员 | `admin` | 数据看板 / 商家骑手审核 / 异常订单处理 |
| 用户 | `user` | 商品浏览下单 / 运费计算 / 订单跟踪 / 评价 |
| 商家 | `merchant` | 商品库存管理 / 接单备货 / 订单状态流转 |
| 骑手 | `rider` | 抢单池抢单 / 取货送达 / 配送收入 |
| 待审核商家 | `newmerchant` | 供管理员审核功能演示（status=0） |
| 待审核骑手 | `newrider` | 供管理员审核功能演示（status=0） |

开放注册：登录页"注册"标签可注册用户 / 商家 / 骑手。商家、骑手注册后默认待管理员审核，用户直接可用。

---

## 5. 核心业务流程与配送状态机

```
[用户下单]
    │  totalAmount≥39 → 免运费；否则 +5 元
    ▼
WAIT_MERCHANT   待商家接单
    │ 商家点"接单"
    ▼
PREPARING       商家备货中
    │ 商家点"备货完成"  ──► 订单进入【骑手抢单池】
    ▼
WAIT_RIDER      待骑手抢单
    │ 骑手在抢单池点"立即抢单"
    ▼
TAKEN           骑手已抢单，待取货
    │ 骑手点"确认取货"
    ▼
DELIVERING      骑手配送中
    │ 骑手点"确认送达"  ──► 生成骑手收入 ¥4.5
    ▼
DONE            已送达（用户可评价）

旁路：EXCEPTION 异常订单（管理员标记 → 处理完成 → CANCELLED）
```

---

## 6. 功能清单

### 用户（登录 user/123456）
- [ ] 商品浏览/下单（分类筛选 + 搜索 + 抽屉下单）
- [ ] 运费计算（满 39 免邮，否则 5 元，下单抽屉实时试算）
- [ ] 订单与配送跟踪（el-timeline 展示下单/接单/备货/抢单/取货/送达各时间点）
- [ ] 评价（DONE 订单可打分 + 文字评价）

### 商家（登录 merchant/123456）
- [ ] 商品与库存管理（表格 + 新增/编辑/上下架）
- [ ] 接单备货（WAIT_MERCHANT → PREPARING）
- [ ] 订单状态流转（PREPARING → WAIT_RIDER 入抢单池）

### 骑手（登录 rider/123456）
- [ ] 抢单池接单（WAIT_RIDER 订单卡片，点"立即抢单"）
- [ ] 取货/送达确认（TAKEN → DELIVERING → DONE）
- [ ] 配送收入（历史明细 + 累计金额 + 单量统计）

### 管理员（登录 admin/123456）
- [ ] 商家/骑手审核（通过 / 拒绝）
- [ ] 数据看板（用户/商家/骑手/订单/GMV/待审核/状态分布）
- [ ] 异常订单处理（标记异常 → 处理完成关闭订单）

---

## 7. 实测记录（逐角色逐功能）

### 管理员 admin/123456
| 功能 | 结果 |
|---|---|
| 数据看板（用户/商家/骑手/订单/GMV/状态分布） | ✓ |
| 商家/骑手审核（通过 newmerchant，待审核从 2 变 1） | ✓ |
| 异常订单处理（EXCEPTION 订单 1007 标记→处理完成→CANCELLED） | ✓ |

### 商家 merchant/123456
| 功能 | 结果 |
|---|---|
| 商品与库存管理（10 商品列表 / 编辑西兰花库存 90→120 / 上下架切换） | ✓ |
| 接单备货（订单 1001 WAIT_MERCHANT → PREPARING） | ✓ |
| 订单状态流转（备货完成 → 进入骑手抢单池 WAIT_RIDER） | ✓ |

### 骑手 rider/123456
| 功能 | 结果 |
|---|---|
| 抢单池接单（抢到订单 1003，WAIT_RIDER → TAKEN） | ✓ |
| 取货/送达确认（1003 取货→送达；1005 送达） | ✓ |
| 配送收入（累计 ¥18 / 4 单 / 每单 ¥4.5） | ✓ |

### 用户 user/123456
| 功能 | 结果 |
|---|---|
| 商品浏览下单（10 商品 / 分类筛选 / 搜索 / 抽屉下单） | ✓ |
| 运费计算（¥12.5 小计 → +¥5 运费 → 实付 ¥17.5，满 39 免邮规则实时提示） | ✓ |
| 订单与配送跟踪（el-timeline 展示下单/接单/备货/抢单/取货/送达各节点） | ✓ |
| 评价（DONE 订单打分 + 文字评价提交成功） | ✓ |

### 实测中发现并修复的 Bug
1. **【已修复】前后端字段命名不一致**：后端 MyBatis 开启 `map-underscore-to-camel-case`，JSON 返回驼峰字段（orderNo/payAmount/productImage/receiverAddress/createdAt 等），但前端模板误写成下划线（order_no/pay_amount/product_image 等），导致订单号、金额、收货地址、商品图、入账时间在表格里全部空白。批量替换 6 个 Vue 文件共 24 处，修复后所有数据正常渲染。
2. **【已修复】el-timeline-item 属性绑定**：初版用 `timestamp="{{ cur.created_at }}"` Mustache 写法，Vue3 应改为 `:timestamp="cur.created_at"` 动态绑定。

### 已知限制
1. 登录态未做 JWT/Session，前端把用户信息存 localStorage，每次请求带 userId——演示项目简化处理。
2. 金额单位为 DECIMAL(10,2)，运费规则固定：满 39 元免邮，否则 5 元；骑手每单配送费 4.5 元。
3. 商品图片为项目内 SVG 矢量图（frontend/public/images/products/），离线可加载，不裂图。
4. 支付为模拟支付，下单即视为已付款。
5. 骑手收入"入账时间"列显示 ISO 时间字符串（含时区 +00:00），未做前端格式化，功能正常但展示略糙。
