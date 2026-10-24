# 图书管理系统

> 基于 SpringBoot + Vue3 的图书馆图书管理系统

## ✨ 功能列表

### 管理员端
- 图书分类管理
- 图书信息管理（增删改查、导入导出）
- 读者管理
- 借阅管理（借书、还书、续借）
- 罚款管理
- 统计报表（借阅排行、热门图书）

### 读者端
- 图书检索
- 在线借阅/续借
- 我的借阅记录
- 收藏图书

## 🛠️ 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | SpringBoot 2.7 + MyBatis-Plus |
| 数据库 | MySQL 8.0 |
| 前端 | Vue3 + Element Plus + Vite |
| 权限 | JWT |

## 🚀 部署教程

### 环境要求
- JDK 1.8+
- Node.js 16+
- MySQL 8.0

### 步骤

**1. 导入数据库**
```bash
mysql -u root -p < sql/book_management.sql
```

**2. 启动后端**
```bash
cd backend
mvn spring-boot:run
```

**3. 启动前端**
```bash
cd frontend
npm install
npm run dev
```

**4. 默认账号**
- 管理员：admin / 123456
- 读者：reader / 123456

## 📄 论文参考

适合选题：
- 基于SpringBoot的图书管理系统设计与实现
- 前后端分离架构在图书管理系统中的应用
- 基于Vue.js的图书馆管理系统前端设计与实现

## 📮 需要帮助？

👉 加微信：hmma2026（备注「毕设」）
