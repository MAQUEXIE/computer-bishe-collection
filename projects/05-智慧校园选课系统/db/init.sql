-- ============================================================
-- 05 智慧校园选课系统 数据库初始化脚本
-- DB: db_05_course (utf8mb4)
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_05_course DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_05_course;

-- ---------------- 用户表 ----------------
DROP TABLE IF EXISTS t_enrollment;
DROP TABLE IF EXISTS t_waitlist;
DROP TABLE IF EXISTS t_course;
DROP TABLE IF EXISTS t_rule;
DROP TABLE IF EXISTS t_user;

CREATE TABLE t_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
  password VARCHAR(50) NOT NULL,
  real_name VARCHAR(50) NOT NULL COMMENT '姓名',
  role VARCHAR(20) NOT NULL COMMENT 'STUDENT/TEACHER/ADMIN',
  status INT DEFAULT 1 COMMENT '1正常',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ---------------- 课程表 ----------------
CREATE TABLE t_course (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  course_code VARCHAR(20) NOT NULL COMMENT '课程号',
  course_name VARCHAR(100) NOT NULL COMMENT '课程名',
  credit INT NOT NULL DEFAULT 2 COMMENT '学分',
  capacity INT NOT NULL DEFAULT 50 COMMENT '容量',
  enrolled INT NOT NULL DEFAULT 0 COMMENT '已选人数',
  teacher_id BIGINT COMMENT '授课教师ID',
  teacher_name VARCHAR(50) COMMENT '授课教师',
  weekday INT COMMENT '1周一..7周日',
  start_section INT COMMENT '开始节次',
  end_section INT COMMENT '结束节次',
  semester VARCHAR(30) DEFAULT '2026春季学期',
  pre_course_id BIGINT COMMENT '先修课程ID',
  pre_course_name VARCHAR(100) COMMENT '先修课程名',
  category VARCHAR(50) COMMENT '类别',
  description VARCHAR(500) COMMENT '简介',
  status INT DEFAULT 0 COMMENT '0待审核 1已发布 2已拒绝',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

-- ---------------- 选课记录表 ----------------
CREATE TABLE t_enrollment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  student_id BIGINT NOT NULL,
  course_id BIGINT NOT NULL,
  enroll_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  status INT DEFAULT 1 COMMENT '1已选课 0已退课',
  grade INT NULL COMMENT '成绩',
  review_score INT NULL COMMENT '教学评价星级1-5',
  review_comment VARCHAR(500) NULL COMMENT '评价评语'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='选课记录表';

-- ---------------- 候补队列表 ----------------
CREATE TABLE t_waitlist (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  course_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  queue_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  status INT DEFAULT 1 COMMENT '1候补中 2已递补 0已退出'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='候补队列表';

-- ---------------- 选课规则配置表 ----------------
CREATE TABLE t_rule (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  rule_key VARCHAR(50) NOT NULL UNIQUE,
  rule_value VARCHAR(200),
  remark VARCHAR(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='选课规则配置表';

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户：admin/123456 教师teacher/123456 学生student/123456
INSERT INTO t_user (username,password,real_name,role,status) VALUES
('admin','123456','教务管理员','ADMIN',1),
('teacher','123456','王建国','TEACHER',1),
('student','123456','张小明','STUDENT',1),
('teacher2','123456','李华','TEACHER',1),
('student2','123456','刘芳','STUDENT',1),
('student3','123456','陈强','STUDENT',1);

-- 课程（id 1-10）
INSERT INTO t_course (id,course_code,course_name,credit,capacity,enrolled,teacher_id,teacher_name,weekday,start_section,end_section,pre_course_id,pre_course_name,category,description,status) VALUES
(1,'C001','高等数学A',4,120,0,2,'王建国',1,1,2,NULL,NULL,'公共基础','微积分、级数与常微分方程，理工各学科基础必修课。',1),
(2,'C002','大学英语',3,80,0,2,'王建国',1,3,4,NULL,NULL,'公共基础','大学英语综合课程，侧重读写与听说训练。',1),
(3,'C003','Java程序设计',3,40,0,2,'王建国',2,1,2,NULL,NULL,'专业核心','Java 语法、面向对象、集合框架与异常处理。',1),
(4,'C004','数据结构',4,60,0,4,'李华',3,3,4,3,'Java程序设计','专业核心','线性表、树、图、排序与查找，先修 Java程序设计。',1),
(5,'C005','线性代数',3,100,0,2,'王建国',5,1,2,NULL,NULL,'公共基础','行列式、矩阵、向量空间与特征值。',1),
(6,'C006','体育（篮球）',1,30,0,4,'李华',4,1,2,NULL,NULL,'公共体育','篮球基本技术与战术配合。',1),
(7,'C007','计算机网络',3,50,0,4,'李华',2,3,4,NULL,NULL,'专业核心','TCP/IP 体系结构、路由与应用层协议。',1),
(8,'C008','高级Java实训',2,2,2,2,'王建国',4,3,4,3,'Java程序设计','专业实训','Java 项目实战，容量小易满员，先修 Java程序设计。',1),
(9,'C009','操作系统',3,50,0,4,'李华',3,1,2,NULL,NULL,'专业核心','进程管理、内存管理、文件系统与并发。',1),
(10,'C010','人工智能导论',3,60,0,2,'王建国',5,3,4,NULL,NULL,'专业选修','机器学习与深度学习概览（待教务审核）。',0);

-- 选课记录：张小明(3) 已选 C001/C002/C003 含成绩与评价；刘芳(5)/陈强(6) 占满 C008 名额
INSERT INTO t_enrollment (student_id,course_id,status,grade,review_score,review_comment) VALUES
(3,1,1,85,5,'王老师讲课条理清晰，板书工整。'),
(3,2,1,92,NULL,NULL),
(3,3,1,78,NULL,NULL),
(5,8,1,NULL,NULL,NULL),
(6,8,1,NULL,NULL,NULL),
(5,6,1,NULL,NULL,NULL);

-- 候补队列：张小明(3) 在 C008(8) 候补中（容量已被占满，演示候补递补）
INSERT INTO t_waitlist (course_id,student_id,status) VALUES
(8,3,1);

-- 选课规则
INSERT INTO t_rule (rule_key,rule_value,remark) VALUES
('max_credits','25','每学生每学期最大学分上限'),
('require_pre_course','1','是否校验先修课程（1开启 0关闭）'),
('enroll_open','1','选课是否开放（1开放 0关闭）');

-- 同步课程已选人数（与 t_enrollment 一致，避免预置数据不一致）
UPDATE t_course SET enrolled = (SELECT COUNT(*) FROM t_enrollment WHERE course_id = t_course.id AND status = 1);
