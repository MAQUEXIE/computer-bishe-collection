# 01 多商户二手交易平台(闲置换 · C2C 二手交易)

闲鱼式 C2C 二手交易平台:闲置发布、议价、担保交易、信用互评。30 个系统项目之第 1 个。

## 技术栈

- 后端:SpringBoot 2.7.x + MyBatis(注解式,无 XML)+ MySQL 8(JDK8)
- 前端:Vue3 + Vite + Element Plus + Vue Router + Pinia + Axios
- 端口:后端 9001,前端 5101(前端 `/api` 代理到 `http://localhost:9001`)
- 数据库:`db_01_second_hand`(utf8mb4)

## 一键启动(本机 Windows / PowerShell)

```powershell
# 1. 建库(只需一次)
cd D:\000-计算机项目\30个系统项目\01-多商户二手交易平台
Get-Content db\init.sql -Raw -Encoding UTF8 | & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" --user=root --password=root

# 2. 后端(9001)
cd backend; mvn spring-boot:run

# 3. 前端(5101),新开一个 PowerShell
cd frontend; npm install; npm run dev

# 4. 浏览器访问
# http://localhost:5101
```

## 测试账号(密码均为 123456)

| 账号 | 角色 | 店铺/昵称 | 初始信用分 |
|---|---|---|---|
| admin | 管理员 | 平台管理员 | 100 |
| buyer | 买家 | 小买家阿福 | 102 |
| seller | 卖家 | 数码闲置铺 | 105(实测后 107) |
| zhangsan | 买家兼卖家 | 张三杂货铺 | 100 |
| lisi | 卖家 | 李四二手严选 | 110 |

开放注册,首页右上角可自行注册新账号。

## 功能范围与实测结果

### 买家(6 项)— 全部 ✓
| 功能 | 结果 | 说明 |
|---|---|---|
| 浏览搜索商品 | ✓ | 首页商品列表、分类筛选、关键词搜索、商品详情页正常 |
| 收藏与关注 | ✓ | 收藏 Switch/iPhone,关注数码闲置铺/李四二手严选,我的收藏关注页正常 |
| 发起议价 | ✓ | 对 Kindle 发起议价 ¥480,进入议价记录列表 |
| 下单担保支付 | ✓ | Dell 显示器 ¥700 下单→担保支付成功,资金由平台冻结(fund_flow 冻结流水可见) |
| 确认收货 | ✓ | 卖家发货后买家确认收货,冻结资金解冻给卖家(解冻流水可见,ORD20261024001) |
| 评价卖家 | ✓ | 5 星评价提交成功,卖家信用分 105→107(+2),防止重复评价 |

### 卖家(5 项)— 全部 ✓
| 功能 | 结果 | 说明 |
|---|---|---|
| 发布闲置 | ✓ | 发布 Sony 降噪耳机 ¥699,进入待审核队列 |
| 店铺与商品管理 | ✓ | 待审核/已售出/在售/已下架全状态列表正常 |
| 议价回复 | ✓ | 接受买家 zhangsan 对 Kindle 的议价 ¥480 |
| 发货管理 | ✓ | 对待发货订单执行发货,买家端状态变更为待收货 |
| 信用分查看 | ✓ | 数码闲置铺信用分展示,收到评价后 105→107 |

### 管理员(4 项)— 全部 ✓
| 功能 | 结果 | 说明 |
|---|---|---|
| 商品审核 | ✓ | 审核队列 4 件:通过 1 件上架、驳回 1 件(原因"图片模糊,请上传清晰实物图") |
| 交易纠纷处理 | ✓ | 对纠纷 d1(小米空气净化器 ¥450,外观划痕投诉)执行"处理并结案",结案后状态更新 |
| 用户与信用管理 | ✓ | 列表 5 个用户,+5/-5 人工调整信用(buyer 102→107)、禁用/恢复按钮可用 |
| 数据统计 | ✓ | 实时统计:注册用户 5、待审核商品 2、已完成订单 2、担保交易 GMV ¥820、处理中纠纷 0 |

## 创新点实现

1. **担保交易资金流**:买家下单后资金由平台冻结(fund_flow 记录 FROZEN),买家确认收货后自动解冻给卖家(记录 RELEASED);纠纷未结案前资金保持冻结。资金流水在买家订单页逐单可见。
2. **买卖双方信用互评**:初始信用 100;交易完成后买卖双方互评,4-5 星 +2 分、1-2 星 -3 分;管理员可人工 ±5 调整,信用分展示在顶栏与卖家店铺页。

## 实测中修复的 Bug(4 个)

1. **担保支付 500(OrderMapper.toPaid)**:SQL 引用了未传入的 `#{status}` 参数,MyBatis 报 BindingException。改为字面量 `'PAID'` 后支付成功。
2. **发布商品 seller_id 为 null**:WebConfig 曾把整个 `/api/products` 路径排除在登录拦截器外,导致 POST 发布时当前用户为空。改为拦截器策略——GET 请求免登录(带 token 则解析登录态)、POST/PUT/DELETE 必须登录;WebConfig 仅排除 `/api/auth/login` 与 `/api/auth/register`。同时 ProductMapper.insert 改为显式 @Param 参数签名。
3. **店铺商品管理只显示在售**:ProductMapper.search 在 status 为空时强制过滤 ON_SALE。删除该分支,公共列表控制器显式传 "ON_SALE",卖家"我的商品"传 null 返回全部状态。
4. **Element Plus 组件在自动化环境动画卡死**:el-tag 停在 enter-from 态(width:0 不可见)、MessageBox 遮罩 opacity:0 弹窗不可见。在 App.vue 全局样式中对相关动画类强制 opacity:1/transform:none/transition:none 后全部恢复正常。

## 已知限制

- 认证为内存 token(SessionStore ConcurrentHashMap),重启后端后所有登录态失效,需重新登录;未接入 Redis/JWT 持久化。
- 商品图片为项目内置本地 SVG 占位图,未做真实图片上传;发布表单"商品图片"为下拉选择内置图。
- 担保资金为平台内部记账(fund_flow 表),未对接真实支付渠道;金额单位为元。
- 管理员审核队列的商品标题列在窄屏下文字换行偏窄(展示问题,不影响功能)。
- 无前端单元测试,质量保障以浏览器逐功能实测为准。

## 目录结构

```
01-多商户二手交易平台/
├── backend/                # SpringBoot 2.7 + MyBatis,端口 9001
├── frontend/               # Vue3 + Vite + Element Plus,端口 5101
├── db/init.sql            # 建库 + 9 表 + 演示数据(已执行)
├── screenshots/           # 15 张逐功能实测截图(买家6/卖家5/管理员4)
└── README.md
```
