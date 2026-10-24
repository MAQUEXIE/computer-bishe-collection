-- ============================================================
-- 06 职业技能培训平台 数据库初始化脚本
-- 库名: db_06_training  字符集: utf8mb4
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_06_training DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_06_training;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 用户表（学员/讲师/管理员）
-- ----------------------------
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录名',
  password VARCHAR(100) NOT NULL COMMENT '密码(演示明文)',
  real_name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '真实姓名',
  role VARCHAR(20) NOT NULL DEFAULT 'student' COMMENT 'admin/teacher/student',
  org_id INT DEFAULT NULL COMMENT '所属机构',
  avatar VARCHAR(255) DEFAULT '' COMMENT '头像',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ----------------------------
-- 机构表
-- ----------------------------
DROP TABLE IF EXISTS organizations;
CREATE TABLE organizations (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL COMMENT '机构名称',
  description VARCHAR(500) DEFAULT '' COMMENT '机构简介',
  contact_name VARCHAR(50) DEFAULT '' COMMENT '联系人',
  contact_phone VARCHAR(30) DEFAULT '' COMMENT '联系电话',
  status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending/approved/rejected',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训机构表';

-- ----------------------------
-- 课程表
-- ----------------------------
DROP TABLE IF EXISTS courses;
CREATE TABLE courses (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL COMMENT '课程标题',
  description TEXT COMMENT '课程简介',
  price DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '售价',
  cover_img VARCHAR(255) DEFAULT '' COMMENT '封面图',
  category VARCHAR(50) DEFAULT '综合' COMMENT '分类',
  teacher_id INT NOT NULL COMMENT '讲师',
  org_id INT NOT NULL COMMENT '所属机构',
  status VARCHAR(20) NOT NULL DEFAULT 'draft' COMMENT 'draft/published',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

-- ----------------------------
-- 章节/课时表
-- ----------------------------
DROP TABLE IF EXISTS chapters;
CREATE TABLE chapters (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL COMMENT '所属课程',
  title VARCHAR(200) NOT NULL COMMENT '章节标题',
  sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
  video_url VARCHAR(255) DEFAULT '' COMMENT '视频地址',
  duration_minutes INT DEFAULT 0 COMMENT '时长(分钟)',
  homework_title VARCHAR(200) DEFAULT '' COMMENT '作业标题',
  homework_desc TEXT COMMENT '作业要求',
  pass_score DECIMAL(5,1) DEFAULT 60.0 COMMENT '作业及格分',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='章节课时表';

-- ----------------------------
-- 订单表
-- ----------------------------
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_no VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
  student_id INT NOT NULL COMMENT '学员',
  course_id INT NOT NULL COMMENT '课程',
  amount DECIMAL(10,2) NOT NULL COMMENT '金额',
  status VARCHAR(20) NOT NULL DEFAULT 'paid' COMMENT 'paid/cancelled',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  paid_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ----------------------------
-- 学习进度表（按章节）
-- ----------------------------
DROP TABLE IF EXISTS progress;
CREATE TABLE progress (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  chapter_id INT NOT NULL,
  watched_percent INT NOT NULL DEFAULT 0 COMMENT '观看百分比0-100',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_student_chapter (student_id, chapter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习进度表';

-- ----------------------------
-- 作业提交表
-- ----------------------------
DROP TABLE IF EXISTS homework_submissions;
CREATE TABLE homework_submissions (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  chapter_id INT NOT NULL,
  content TEXT COMMENT '作业内容',
  score DECIMAL(5,1) DEFAULT NULL COMMENT '得分',
  status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending/graded',
  comment VARCHAR(500) DEFAULT '' COMMENT '批改评语',
  submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  graded_at DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作业提交表';

-- ----------------------------
-- 证书表
-- ----------------------------
DROP TABLE IF EXISTS certificates;
CREATE TABLE certificates (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  cert_no VARCHAR(50) NOT NULL UNIQUE COMMENT '证书编号',
  student_name VARCHAR(50) DEFAULT '',
  course_title VARCHAR(200) DEFAULT '',
  org_name VARCHAR(100) DEFAULT '',
  issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_student_course (student_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='结课证书表';

-- ----------------------------
-- 答疑表
-- ----------------------------
DROP TABLE IF EXISTS qa;
CREATE TABLE qa (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  student_id INT NOT NULL,
  question TEXT NOT NULL,
  teacher_id INT DEFAULT NULL,
  answer TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'unanswered' COMMENT 'unanswered/answered',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  answered_at DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='答疑表';

-- ----------------------------
-- 收益流水表
-- ----------------------------
DROP TABLE IF EXISTS revenue_records;
CREATE TABLE revenue_records (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  org_id INT NOT NULL,
  course_id INT NOT NULL,
  order_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL COMMENT '机构收益金额',
  status VARCHAR(20) NOT NULL DEFAULT 'unsettled' COMMENT 'unsettled/settled',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='机构收益流水表';

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户
INSERT INTO users (id, username, password, real_name, role, org_id) VALUES
(1, 'admin',   '123456', '超级管理员', 'admin',    NULL),
(2, 'teacher', '123456', '王讲师',     'teacher',  1),
(3, 'teacher2','123456', '李讲师',     'teacher',  2),
(4, 'student', '123456', '张同学',     'student',  1),
(5, 'student2','123456', '刘同学',     'student',  2),
(6, 'student3','123456', '陈同学',     'student',  1);

-- 机构（2家已入驻 + 1家待审核）
INSERT INTO organizations (id, name, description, contact_name, contact_phone, status) VALUES
(1, '云图职业培训学院', '专注IT与办公技能提升的职业培训机构，累计服务学员过万人。', '周院长', '13800000001', 'approved'),
(2, '启航IT实训中心',   '实战导向的IT技术实训基地，与多家名企定向输送人才。',       '吴主任', '13800000002', 'approved'),
(3, '未来工匠学堂',     '新职业技能培训方向申请入驻的机构。',                     '郑老师', '13800000003', 'pending');

-- 课程（5门已发布）
INSERT INTO courses (id, title, description, price, cover_img, category, teacher_id, org_id, status) VALUES
(1, 'Python自动化办公实战', '从零基础掌握Python，自动化处理Excel、文件与邮件，让办公效率翻倍。', 99.00, '/covers/c1.svg', '办公自动化', 2, 1, 'published'),
(2, '前端开发工程师班',     '系统学习HTML/CSS/JavaScript/Vue3，从零到一打造企业级前端项目。',     199.00,'/covers/c2.svg', '编程开发',   2, 1, 'published'),
(3, '数据分析与报表实战',   '掌握数据分析思维、SQL取数与可视化报表，成为业务决策的得力助手。',   149.00,'/covers/c3.svg', '数据分析',   2, 1, 'published'),
(4, 'Java后端开发入门',     '从Java语法到SpringBoot接口开发，夯实后端开发基本功。',             249.00,'/covers/c4.svg', '编程开发',   3, 2, 'published'),
(5, 'UI设计零基础到上岗',   '学习设计工具、色彩排版与组件规范，完成作品集顺利上岗。',           179.00,'/covers/c5.svg', '设计创意',   3, 2, 'published');

-- 章节/课时
INSERT INTO chapters (id, course_id, title, sort_order, video_url, duration_minutes, homework_title, homework_desc, pass_score) VALUES
-- 课程1 Python办公 (5节)
(1, 1, '环境搭建与Python基础', 1, '/videos/lesson01.mp4', 25, '', '', 60),
(2, 1, '自动化处理Excel',      2, '/videos/lesson02.mp4', 30, 'Excel批量统计作业', '用Python读取一个Excel文件，统计各列数据并输出汇总结果。', 60),
(3, 1, '批量文件整理脚本',    3, '/videos/lesson03.mp4', 28, '', '', 60),
(4, 1, '邮件自动发送',        4, '/videos/lesson04.mp4', 22, '自动发邮件作业', '编写一个脚本，批量向列表中的收件人发送带附件的邮件。', 60),
(5, 1, '实战项目：办公报表自动化', 5, '/videos/lesson05.mp4', 35, '', '', 60),
-- 课程2 前端班 (6节)
(6, 2, 'HTML语义化入门', 1, '/videos/lesson06.mp4', 24, '', '', 60),
(7, 2, 'CSS布局与Flex',  2, '/videos/lesson07.mp4', 26, '', '', 60),
(8, 2, 'JavaScript基础语法', 3, '/videos/lesson08.mp4', 32, 'JS练习作业', '完成数组遍历、条件判断与函数封装的三道小练习并提交代码。', 60),
(9, 2, 'Vue3框架快速上手', 4, '/videos/lesson09.mp4', 30, '', '', 60),
(10, 2,'组件化与路由',    5, '/videos/lesson10.mp4', 28, '组件拆分作业', '把一个页面拆分为至少3个组件，并配置前端路由。', 60),
(11, 2,'综合实战项目',    6, '/videos/lesson11.mp4', 40, '', '', 60),
-- 课程3 数据分析 (4节)
(12, 3, '数据分析思维',   1, '/videos/lesson12.mp4', 22, '', '', 60),
(13, 3, 'SQL取数实战',    2, '/videos/lesson13.mp4', 30, 'SQL查询作业', '编写多表关联查询SQL，统计各部门销售额排名。', 60),
(14, 3, '可视化图表制作', 3, '/videos/lesson14.mp4', 26, '', '', 60),
(15, 3, '业务报表案例',   4, '/videos/lesson15.mp4', 28, '', '', 60),
-- 课程4 Java后端 (6节)
(16, 4, 'Java语法基础',   1, '/videos/lesson16.mp4', 30, '', '', 60),
(17, 4, '面向对象',       2, '/videos/lesson17.mp4', 28, '', '', 60),
(18, 4, 'MySQL与JDBC',    3, '/videos/lesson18.mp4', 32, 'JDBC作业', '用JDBC完成用户表的增删改查并提交代码。', 60),
(19, 4, 'SpringBoot入门', 4, '/videos/lesson19.mp4', 30, '', '', 60),
(20, 4, 'RESTful接口设计', 5, '/videos/lesson20.mp4', 28, '接口设计作业', '设计一个课程管理的RESTful接口文档。', 60),
(21, 4, '项目实战',        6, '/videos/lesson21.mp4', 40, '', '', 60),
-- 课程5 UI设计 (5节)
(22, 5, '设计工具介绍',    1, '/videos/lesson22.mp4', 20, '', '', 60),
(23, 5, '色彩与排版',      2, '/videos/lesson23.mp4', 26, '配色练习作业', '为一个登录页选择配色方案并说明理由。', 60),
(24, 5, '组件设计规范',    3, '/videos/lesson24.mp4', 28, '', '', 60),
(25, 5, '原型与交互',      4, '/videos/lesson25.mp4', 26, '', '', 60),
(26, 5, '作品集打磨',      5, '/videos/lesson26.mp4', 30, '', '', 60);

-- 订单
INSERT INTO orders (id, order_no, student_id, course_id, amount, status, created_at, paid_at) VALUES
(1, 'ORD20260901001', 4, 1, 99.00,  'paid', '2026-09-01 10:00:00', '2026-09-01 10:02:00'),
(2, 'ORD20260901002', 4, 2, 199.00, 'paid', '2026-09-01 11:00:00', '2026-09-01 11:05:00'),
(3, 'ORD20260905003', 5, 4, 249.00, 'paid', '2026-09-05 09:30:00', '2026-09-05 09:31:00'),
(4, 'ORD20260910004', 6, 1, 99.00,  'paid', '2026-09-10 14:00:00', '2026-09-10 14:01:00'),
(5, 'ORD20260912005', 4, 3, 149.00, 'paid', '2026-09-12 16:20:00', '2026-09-12 16:22:00');

-- 学习进度：学员4 课程1全部看完(100%)，课程2部分，课程3第一章
INSERT INTO progress (student_id, course_id, chapter_id, watched_percent) VALUES
(4, 1, 1, 100), (4, 1, 2, 100), (4, 1, 3, 100), (4, 1, 4, 100), (4, 1, 5, 100),
(4, 2, 6, 100), (4, 2, 7, 100), (4, 2, 8, 60),
(4, 3, 12, 100),
(5, 4, 16, 80),
(6, 1, 1, 100), (6, 1, 2, 40);

-- 作业提交
INSERT INTO homework_submissions (id, student_id, course_id, chapter_id, content, score, status, comment, submitted_at, graded_at) VALUES
(1, 4, 1, 2, '已完成：使用pandas读取销售Excel，按月份汇总销售额并输出透视表，代码运行无误。', 85.0, 'graded', '脚本结构清晰，注释到位，优秀。', '2026-09-02 20:00:00', '2026-09-03 10:00:00'),
(2, 4, 1, 4, '自动发邮件脚本：使用smtplib批量发送，支持列表读取与附件挂载，已测试成功。', 90.0, 'graded', '考虑了异常重试，很棒。', '2026-09-04 21:00:00', '2026-09-05 09:00:00'),
(3, 4, 2, 8, 'JS练习：数组map/filter遍历、三元表达式与函数封装已完成，代码见作业正文。', NULL, 'pending', '', '2026-09-15 20:00:00', NULL),
(4, 6, 1, 2, '我用openpyxl读取了Excel并统计了行数，还在学习中。', NULL, 'pending', '', '2026-09-16 19:00:00', NULL);

-- 证书：学员4 已完成课程1
INSERT INTO certificates (id, student_id, course_id, cert_no, student_name, course_title, org_name, issued_at) VALUES
(1, 4, 1, 'CERT20260915001', '张同学', 'Python自动化办公实战', '云图职业培训学院', '2026-09-15 12:00:00');

-- 答疑
INSERT INTO qa (id, course_id, student_id, question, teacher_id, answer, status, created_at, answered_at) VALUES
(1, 1, 4, '老师，用Python处理几十万行的Excel时内存不足报错，有什么优化办法？', 2, '可以改用read_csv分块读取(chunksize)，或用openpyxl的read_only模式，避免一次性加载全表。', 'answered', '2026-09-06 15:00:00', '2026-09-06 18:00:00'),
(2, 4, 5, '老师好，SpringBoot启动时报端口占用错误该怎么解决？', NULL, NULL, 'unanswered', '2026-09-18 10:00:00', NULL);

-- 收益流水（机构分成80%）
INSERT INTO revenue_records (id, org_id, course_id, order_id, amount, status, created_at) VALUES
(1, 1, 1, 1, 79.20,  'settled',   '2026-09-01 10:02:00'),
(2, 1, 2, 2, 159.20, 'unsettled', '2026-09-01 11:05:00'),
(3, 2, 4, 3, 199.20, 'unsettled', '2026-09-05 09:31:00'),
(4, 1, 1, 4, 79.20,  'settled',   '2026-09-10 14:01:00'),
(5, 1, 3, 5, 119.20, 'unsettled', '2026-09-12 16:22:00');

SET FOREIGN_KEY_CHECKS = 1;
