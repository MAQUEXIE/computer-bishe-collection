# 校园二手交易平台

> 基于 SpringBoot + Vue3 的校园二手物品交易平台

## ✨ 功能列表

### 用户端
- 用户注册/登录
- 发布二手商品（图片、描述、价格）
- 商品搜索与分类浏览
- 商品收藏
- 在线聊天（买家卖家沟通）
- 订单管理（下单、确认收货）
- 个人中心（我的发布、我的购买、我的出售）

### 管理员端
- 用户管理
- 商品审核（防止违规商品）
- 分类管理
- 举报处理
- 数据统计

## 🛠️ 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | SpringBoot 2.7 + MyBatis-Plus |
| 数据库 | MySQL 8.0 |
| 缓存 | Redis（商品浏览量） |
| 前端 | Vue3 + Element Plus + Vite |
| 即时通讯 | WebSocket |
| 图片存储 | 本地/OSS |

## 🚀 部署教程

### 环境要求
- JDK 1.8+
- Node.js 16+
- MySQL 8.0
- Redis 6.0+

### 步骤

**1. 启动Redis**
```bash
redis-server
```

**2. 导入数据库**
```bash
mysql -u root -p < sql/second_hand.sql
```

**3. 启动后端**
```bash
cd backend
mvn spring-boot:run
```

**4. 启动前端**
```bash
cd frontend
npm install
npm run dev
```

**5. 默认账号**
- 管理员：admin / 123456
- 用户：user / 123456

## 📄 论文参考

适合选题：
- 基于SpringBoot的校园二手交易平台设计与实现
- 前后端分离架构下的电商平台研究
- 基于WebSocket的校园即时通讯系统设计

## 📮 需要帮助？

👉 加微信：bishe_helper（备注「毕设」）
