# 05 智慧校园选课系统

课程发布、选课退课、冲突检测、课表生成、绩点计算，教务一站式。
30 个系统项目 · 第 5 个（Java 组）。

## 系统功能

### 1. 管理员

登录、个人信息、修改密码、管理后台管理系统所有数据。

- **学生管理**：管理所有学生信息
- **教师管理**：管理教师信息
- **课程管理**：开设课程，设置学分
- **排课管理**：安排上课时间教室
- **选课管理**：设置选课时间开放
- **专业管理**：管理专业班级
- **数据统计**：选课情况统计报表

### 2. 教师

登录、个人信息、修改密码。

- **课程查询**：查看自己教的课
- **学生名单**：查看选课学生
- **成绩录入**：录入学生成绩
- **课表查看**：查看自己的课表
- **教学公告**：发布课程通知

### 3. 学生

注册、登录、个人信息、修改密码、查看系统公告。

- **选课**：浏览可选课程，选课
- **退课**：退掉已选课程
- **课表查询**：查看个人课表
- **成绩查询**：查看自己的成绩
- **培养方案**：查看专业培养计划
- **候补递补**：满员课程候补排队

## 技术栈

- 后端：SpringBoot 2.7.18 + MyBatis 2.3.2 + MySQL 8（JDK 1.8），端口 **9005**
- 前端：Vue 3 + Vite + Element Plus + Vue Router + Pinia + Axios，端口 **5105**（`/api` 代理到 http://localhost:9005）
- 数据库：**db_05_course**（utf8mb4）

## 一键启动（PowerShell）

```powershell
# 1) 建库建表 + 演示数据
Get-Content db\init.sql -Raw -Encoding UTF8 | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --user=root --password=root --default-character-set=utf8mb4

# 2) 启动后端（Maven 必须用 JDK8）
cd backend
$env:JAVA_HOME='C:\Program Files\Amazon Corretto\jdk1.8.0_492'; mvn spring-boot:run

# 3) 启动前端（新窗口）
cd frontend
npm install
npm run dev
```

浏览器打开 http://localhost:5105 。

## 测试账号

| 角色 | 账号 | 密码 | 说明 |
|------|------|------|------|
| 教务 | admin | 123456 | 课程审核/规则配置/容量先修/候补管理 |
| 教师 | teacher | 123456 | 王建国，开课申请/学生名单/成绩录入 |
| 学生 | student | 123456 | 张小明 |
| 学生 | student2 | 123456 | 刘芳（演示候补递补用） |
| 学生 | student3 | 123456 | 陈强 |
| 教师 | teacher2 | 123456 | 李华 |

登录页可开放注册（学生/教师自助注册，立即可用）。

## 功能与逐角色实测结果

### 学生（student）
- ✓ 浏览课程（9→11门已发布课程，含搜索、名额标签、先修信息）
- ✓ 选课/退课（正常选课 C005 线性代数成功；满员课 C008 自动进候补队列）
- ✓ 课表与绩点查询（周一至周五 × 6 节网格课表；已修学分 10、GPA 3.58，按 85→3.7 / 92→4.0 / 78→3.0 加权计算正确）
- ✓ 教学评价（对 Java程序设计 打 5 星并提交评语，保存后回显）
- ✓ **创新点1 冲突检测**：C011 现代软件工程（周一3-4节）与已选 C002 大学英语（周一3-4节）同时段，系统拒绝并提示「与已选课程【大学英语】时间冲突」
- ✓ **创新点2 候补自动递补**：student2（刘芳）退掉 C008 后，队首张小明自动递补（数据库核验：t_enrollment 新增张小明记录 status=1，t_waitlist 置为 2 已递补，enrolled 仍为 2/2）

### 教师（teacher / 王建国）
- ✓ 开课申请（提交 C011 现代软件工程 → 待审核，我的开课列表状态正确）
- ✓ 学生名单（选 C008 高级Java实训 → 刘芳、陈强 名单含选课时间与成绩状态）
- ✓ 成绩录入（C005 线性代数给张小明录 88 分，保存成功并回显）

### 教务（admin）
- ✓ 课程审核（C010 人工智能导论、C011 现代软件工程 待审核通过，状态流转已发布）
- ✓ 选课规则配置（最大学分 25 / 先修校验开关 / 选课通道开关，可保存）
- ✓ 容量与先修限制（逐课程调整容量、设置/解除先修课，容量小于已选人数有校验）
- ✓ 候补管理（查看候补队列、可手动移除候补记录）

## 修复的 Bug（实测发现并修复）

1. **登录拦截白名单路径错误**：浏览接口实际路径为 `/api/student/courses/browse`，初版白名单写成 `/api/courses/browse` 导致免登录浏览被拦截 → 已修正 WebConfig 白名单。
2. **预置数据 enrolled 人数不一致**：init.sql 插入 t_enrollment 后未同步 t_course.enrolled，导致课程名额显示 0/N → init.sql 末尾增加 `UPDATE t_course SET enrolled = ...` 同步语句，并已在当前库执行。

## 已知限制

- 会话为内存态（前端 localStorage 存 userId + 请求头 `X-User-Id`），重启后端需重新登录。
- 一门课仅一个上课时间段（weekday + startSection/endSection），未支持分段/单周双周。
- 先修校验仅查「成绩≥60」通过记录，未处理先修课未选的其他业务分支提示。
- 递补时若队首学生与释放名额后的课表冲突，自动跳过该学生继续递补下一位（已在后端实现）。

## 截图清单（screenshots/，共 13 张，MD5 全量去重无重复）

```
学生/浏览课程.png
学生/选课退课.png
学生/课表与绩点查询.png
学生/教学评价.png
学生/冲突检测拒绝.png        ← 创新点1佐证
学生/候补自动递补.png        ← 创新点2佐证
教师/开课申请.png
教师/学生名单.png
教师/成绩录入.png
教务/课程审核.png
教务/选课规则配置.png
教务/容量与先修限制.png
教务/候补管理.png
```

## 代码结构

- backend/：SpringBoot 工程（21 个 Java 文件 + application.yml）
  - controller：Auth / Student / Teacher / Admin 四个 REST 控制器
  - mapper：MyBatis 注解版，全部 `#{}` 预编译 + 显式 `@Param`
  - common：统一返回体 R、全局异常、UserContext 线程上下文
  - config：CORS、登录拦截器（白名单精确到登录/注册/课程浏览）
- frontend/：Vite 工程（19 个 src 文件）
  - views/student：BrowseCourses、MyCourses、ScheduleGrades、Evaluation
  - views/teacher：CourseApply、Roster、GradeInput
  - views/admin：CourseAudit、RuleConfig、CourseSetting、WaitlistManage
- db/init.sql：建库建表 + 三角色账号 + 11 门课程 + 选课/成绩/评价/候补演示数据
