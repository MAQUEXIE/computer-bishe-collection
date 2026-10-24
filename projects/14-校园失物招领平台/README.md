# 14 校园失物招领平台

失物登记、特征匹配、认领申请、站内通知，快速闭环。

- 后端端口：`9014`
- 前端端口：`5114`（`/api` 代理到 `http://localhost:9014`）
- 数据库：`db_14_lostfound`（utf8mb4）
- 技术栈：FastAPI + SQLAlchemy 2.0 + PyMySQL + Pydantic；Vue3 + Vite + Element Plus + Vue Router + Pinia + Axios

---

## 一键启动

### 1. 建库（PowerShell）

```powershell
Get-Content D:\000-计算机项目\30个系统项目\14-校园失物招领平台\db\init.sql -Raw -Encoding UTF8 | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --user=root --password=root --default-character-set=utf8mb4
```

### 2. 启动后端（项目 backend 目录）

```powershell
pip3 install fastapi uvicorn sqlalchemy pymysql
cd D:\000-计算机项目\30个系统项目\14-校园失物招领平台\backend
python -m uvicorn main:app --host 0.0.0.0 --port 9014
```

### 3. 启动前端（项目 frontend 目录，新开 PowerShell）

```powershell
cd D:\000-计算机项目\30个系统项目\14-校园失物招领平台\frontend
npm install
npm run dev
```

浏览器访问 http://localhost:5114

---

## 测试账号

| 角色 | 用户名 | 密码 |
| --- | --- | --- |
| 管理员 | admin | 123456 |
| 师生 | student | 123456（张同学） |
| 师生 | liming / wangfang | 123456 |

开放注册：登录页点击「立即注册」即可创建新师生账号。

---

## 功能清单与测试结果

### 师生（student / 123456）

| 功能 | 结果 | 截图 |
| --- | --- | --- |
| 发布寻物/失物 | ✓ 发布「丢失蓝色保温杯」成功，进入待审核状态，自动收到站内通知 | screenshots/师生/发布寻物失物.png |
| 特征搜索 | ✓ 按关键词「图书馆」过滤出 2 条相关物品（寻物 + 招领），类别/颜色/地点/类型/关键词多条件可用 | screenshots/师生/特征搜索.png |
| 认领申请 | ✓ 对「捡到无线耳机一只」提交认领凭证描述，申请进入待处理，双方均收到站内通知 | screenshots/师生/认领申请.png |
| 消息通知 | ✓ 审核结果（通过/驳回）、认领结果（通过/驳回）、匹配提醒、系统通知全部展示，未读角标实时刷新 | screenshots/师生/消息通知.png |

### 管理员（admin / 123456）

| 功能 | 结果 | 截图 |
| --- | --- | --- |
| 信息审核 | ✓ 通过 1 条、驳回 1 条（填写驳回原因），发布人收到对应站内通知 | screenshots/管理员/信息审核.png |
| 匹配推荐 | ✓ 系统按类别(40)+颜色(30)+地点(30) 自动计算 lost/found 配对分数，100 分/70 分/60 分/40 分多档展示命中原因 | screenshots/管理员/匹配推荐.png |
| 认领确认 | ✓ 通过 1 条认领申请，对应招领物品自动标记为「已认领」，申请人与招领人双方通知 | screenshots/管理员/认领确认.png |
| 公告 | ✓ 发布新公告「国庆假期失物招领延时通知」，师生端失物大厅顶部即时展示 | screenshots/管理员/公告.png |

---

## 创新点

1. **物品特征自动匹配**：发布/审核通过后，系统按「类别一致 +40、颜色一致 +30、地点相近（教学楼/食堂/宿舍/图书馆/操场/体育馆/实验楼/行政楼/校门 关键词）+30」自动计算 opposite-type 物品匹配分，≥50 分自动给对方发站内匹配提醒。
2. **站内消息通知**：审核结果、认领结果、匹配提醒、系统公告四类通知落库，未读角标实时显示，可单条/全部标为已读。

---

## 实测修复的 Bug

1. **前端 /covers 资源裂图**：初版 vite.config.js 误加了 `/covers -> http://localhost:5114` 的自代理，造成代理环回，所有物品图标加载超时为空白。修复：删除该自代理条目，Vite 直接把 `frontend/public/covers/` 作为静态目录提供。重启 dev server 后图标正常。
2. Element Plus 过渡动画在自动化环境偶发卡死：按经验在 `styles.css` 全局加 `*{transition:none!important;animation:none!important}` 规避。

---

## 已知限制

- 登录 token 存内存（重启后端即清空），符合演示项目定位；
- 物品图片用内置 SVG emoji 图标（public/covers/*.svg），未做真实图片上传；
- 匹配算法为规则加权（类别/颜色/地点），未做语义向量匹配；
- 无实名/学籍校验，认领闭环依赖线下领取环节。
