# 30 智慧停车场系统

SpringBoot 2.7 + MyBatis + MySQL 8 + Vue3 + Vite + Element Plus。
实现：入场识别（模拟摄像头）、自动计费、离场支付、电子发票、车位管理、费率设置、实时监控、数据报表；创新点：**无感支付**（绑定车牌自动扣费离场）+ **车位导航**（按区域/楼层实时余位引导）。

## 一键启动

### 1. 建库
PowerShell（MySQL 8，root/root）：
```powershell
Get-Content D:\000-计算机项目\30个系统项目\30-智慧停车场系统\db\init.sql -Raw -Encoding UTF8 | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --user=root --password=root --default-character-set=utf8mb4
```

### 2. 启动后端（端口 9030）
```powershell
cd D:\000-计算机项目\30个系统项目\30-智慧停车场系统\backend
$env:JAVA_HOME='C:\Program Files\Amazon Corretto\jdk1.8.0_492'; mvn spring-boot:run
```

### 3. 启动前端（端口 5130）
```powershell
cd D:\000-计算机项目\30个系统项目\30-智慧停车场系统\frontend
npm install
npm run dev
```
浏览器打开 http://localhost:5130

## 测试账号
| 角色 | 账号 | 密码 |
|------|------|------|
| 管理员 | admin | 123456 |
| 车主 | driver | 123456（已绑定车牌 闽D12345，已开启无感支付） |

车主支持开放注册（登录页「车主注册」）。

## 功能与实测结果

### 管理员
| 功能 | 结果 |
|------|------|
| 实时监控（车位全览 + 在场车辆） | ✓ |
| 车位管理（列表/筛选/新增/编辑/删除） | ✓ |
| 费率设置（免费时长/每小时/日封顶，保存生效） | ✓ |
| 数据报表（占用/在场/营收/无感次数/近7日趋势/区域统计） | ✓ |

### 车主
| 功能 | 结果 |
|------|------|
| 停车入场（输入车牌模拟摄像头识别，自动分配车位并导航） | ✓ |
| 自动计费（实时时长/金额，15分钟免费后按小时，日封顶40元） | ✓ |
| 离场支付（人工缴费，缴费后抬杆放行释放车位） | ✓ |
| 无感支付（绑定车牌离场自动扣费，已开启） | ✓ |
| 电子发票（离场缴费后申请开票） | ✓ |
| 余位导航（按 A/B/C 区、B1/1F/2F 楼层实时显示空位） | ✓ |

## 计费规则
- 入场 15 分钟内免费；
- 超出后每小时 5 元（不足 1 小时按 1 小时计）；
- 单日封顶 40 元；
- 费率可在「管理员 → 费率设置」修改并实时生效。

## 实测修复的 Bug
1. 后端编译错误：`Invoice` 实体误写 `setPassword(null)`，已删除。
2. 前端 store 导入路径错误（`../store` 目录无 index），全部改为 `../store/user`（router、Layout、Login、4 个车主页共 7 处）。
3. Element Plus 按钮偶发点击无效，统一用 `bu.js` 触发点击。

## 已知限制
- 「入场识别」为输入车牌号模拟摄像头，非真实车牌识别。
- 无感支付为演示流程：绑定车牌并开启自动扣费后，离场时后端自动生成支付流水并抬杆。
- 自动计费为前端 15s 轮询刷新，非 WebSocket 实时推送。
- 月卡/预约等清单提及功能未纳入本期实现，以本 README 功能表为准。

## 目录结构
```
30-智慧停车场系统/
├── backend/        SpringBoot + MyBatis（端口 9030）
├── frontend/       Vue3 + Vite + Element Plus（端口 5130，/api 代理到 9030）
├── db/init.sql     建库 db_30_parking + 账号 + 32 车位 + 演示数据
├── screenshots/    逐角色逐功能截图（8 张，MD5 已去重）
└── README.md
```
