-- ============================================================
-- 26 企业绩效考核系统 初始化 SQL
-- 库名: db_26_performance  (utf8mb4)
-- 角色: ADMIN / HR / MANAGER / STAFF
-- 创新点: 360度评价（自评20%+同事互评20%+主管评分60%）+ 申诉闭环
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_26_performance DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_26_performance;

DROP TABLE IF EXISTS t_appeal;
DROP TABLE IF EXISTS t_result;
DROP TABLE IF EXISTS t_score;
DROP TABLE IF EXISTS t_plan;
DROP TABLE IF EXISTS t_weekly;
DROP TABLE IF EXISTS t_task;
DROP TABLE IF EXISTS t_user;
DROP TABLE IF EXISTS t_dept;

-- ---------- 部门/团队 ----------
CREATE TABLE t_dept (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL COMMENT '团队名称',
  manager_id BIGINT COMMENT '团队主管用户ID'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门团队';

-- ---------- 用户 ----------
CREATE TABLE t_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64) NOT NULL,
  role VARCHAR(16) NOT NULL COMMENT 'ADMIN/HR/MANAGER/STAFF',
  dept_id BIGINT,
  manager_id BIGINT COMMENT '所属主管',
  phone VARCHAR(32),
  status INT DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户';

-- ---------- 任务 ----------
CREATE TABLE t_task (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(128) NOT NULL,
  content VARCHAR(512),
  assigner_id BIGINT COMMENT '主管',
  assignee_id BIGINT COMMENT '员工',
  cycle VARCHAR(16) COMMENT '考核周期',
  status VARCHAR(16) DEFAULT 'TODO' COMMENT 'TODO/DOING/DONE',
  deadline DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务';

-- ---------- 周报 ----------
CREATE TABLE t_weekly (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  week_range VARCHAR(16) NOT NULL COMMENT '如 2026-W43',
  content VARCHAR(1024) COMMENT '本周工作',
  achievements VARCHAR(1024) COMMENT '成果与数据',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='周报';

-- ---------- 考核方案（含360度权重） ----------
CREATE TABLE t_plan (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  cycle VARCHAR(16) NOT NULL COMMENT '如 2026-Q3',
  self_weight INT DEFAULT 20 COMMENT '自评权重%',
  peer_weight INT DEFAULT 20 COMMENT '同事互评权重%',
  manager_weight INT DEFAULT 60 COMMENT '主管评分权重%',
  status VARCHAR(16) DEFAULT 'DRAFT' COMMENT 'DRAFT/PUBLISHED',
  description VARCHAR(512),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考核方案';

-- ---------- 360度评分记录 ----------
CREATE TABLE t_score (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  plan_id BIGINT NOT NULL,
  target_user_id BIGINT NOT NULL COMMENT '被评人',
  rater_id BIGINT NOT NULL COMMENT '评分人',
  rater_type VARCHAR(16) NOT NULL COMMENT 'SELF/PEER/MANAGER',
  score INT NOT NULL COMMENT '0-100',
  comment VARCHAR(512),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评分记录';

-- ---------- 绩效结果 ----------
CREATE TABLE t_result (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  plan_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL COMMENT '被考核员工',
  total_score DOUBLE COMMENT '加权总分',
  grade VARCHAR(4) COMMENT 'S/A/B/C',
  status VARCHAR(16) DEFAULT 'PENDING' COMMENT 'PENDING/PUBLISHED/CHANGED',
  manager_comment VARCHAR(512),
  hr_comment VARCHAR(512),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效结果';

-- ---------- 绩效申诉 ----------
CREATE TABLE t_appeal (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  result_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL COMMENT '申诉员工',
  reason VARCHAR(1024) NOT NULL,
  status VARCHAR(32) DEFAULT 'PENDING_MANAGER'
    COMMENT 'PENDING_MANAGER/PENDING_HR/CLOSED/REJECTED',
  manager_reply VARCHAR(512),
  hr_reply VARCHAR(512),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效申诉';

-- ============================================================
-- 演示数据
-- ============================================================

-- 部门
INSERT INTO t_dept(id,name,manager_id) VALUES
(1,'技术研发部',3);

-- 用户：admin/123456, hr/123456, manager/123456, staff/123456 + 6名员工
INSERT INTO t_user(id,username,password,nickname,role,dept_id,manager_id,phone,status) VALUES
(1,'admin','123456','系统管理员','ADMIN',NULL,NULL,'13800000001',1),
(2,'hr','123456','王人事','HR',NULL,NULL,'13800000002',1),
(3,'manager','123456','李主管','MANAGER',1,NULL,'13800000003',1),
(4,'staff','123456','陈晓','STAFF',1,3,'13800000004',1),
(5,'zhangwei','123456','张伟','STAFF',1,3,'13800000005',1),
(6,'lina','123456','李娜','STAFF',1,3,'13800000006',1),
(7,'wangqiang','123456','王强','STAFF',1,3,'13800000007',1),
(8,'liuyang','123456','刘洋','STAFF',1,3,'13800000008',1),
(9,'chenjing','123456','陈静','STAFF',1,3,'13800000009',1),
(10,'zhaolei','123456','赵磊','STAFF',1,3,'13800000010',1);

-- 任务（主管分配）
INSERT INTO t_task(id,title,content,assigner_id,assignee_id,cycle,status,deadline) VALUES
(1,'完成绩效考核系统需求文档','输出Q4绩效考核系统需求规格说明书并组织评审',3,4,'2026-Q4','DOING','2026-11-15'),
(2,'Q3项目版本上线支持','负责支付模块上线与全量回归测试',3,5,'2026-Q3','DONE','2026-10-10'),
(3,'代码评审与技术方案整理','完成核心模块技术方案评审3次并输出结论',3,6,'2026-Q4','DOING','2026-11-30'),
(4,'用户调研与竞品分析','输出3份竞品分析报告并组织内部分享',3,7,'2026-Q4','TODO','2026-12-01'),
(5,'接口联调与缺陷修复','完成20个核心接口联调，修复阻塞缺陷',3,8,'2026-Q3','DONE','2026-10-20'),
(6,'数据看板搭建','搭建团队任务完成率与周报提交率看板',3,9,'2026-Q4','TODO','2026-12-10');

-- 周报
INSERT INTO t_weekly(id,user_id,week_range,content,achievements) VALUES
(1,4,'2026-W42','完成登录与权限模块开发，联调通过，修复3个缺陷','代码覆盖率85%，通过技术评审'),
(2,5,'2026-W42','完成支付模块回归测试，支持Q3版本顺利上线','发现并修复缺陷12个，线上零事故'),
(3,6,'2026-W43','完成技术方案文档初稿并组织评审','方案评审一次通过，进入开发排期');

-- 考核方案（360度权重：自评20% + 同事互评20% + 主管评分60%）
INSERT INTO t_plan(id,name,cycle,self_weight,peer_weight,manager_weight,status,description) VALUES
(1,'2026年第三季度绩效考核方案','2026-Q3',20,20,60,'PUBLISHED',
 '360度评价：自评20% + 同事互评20% + 主管评分60%；等级 S(>=90)/A(>=80)/B(>=70)/C(<70)');

-- 评分记录（360度）
INSERT INTO t_score(plan_id,target_user_id,rater_id,rater_type,score,comment) VALUES
(1,4,4,'SELF',85,'本季度按计划推进需求文档工作'),
(1,4,5,'PEER',88,'协作积极，响应及时'),
(1,4,3,'MANAGER',90,'任务推进稳健，文档质量高'),
(1,5,5,'SELF',90,'独立完成支付模块上线支持'),
(1,5,4,'PEER',92,'技术能力强，乐于助人'),
(1,5,3,'MANAGER',93,'关键任务交付质量优秀'),
(1,6,6,'SELF',80,'完成技术方案初稿'),
(1,6,4,'PEER',84,'评审准备充分'),
(1,6,3,'MANAGER',82,'方案质量良好，需加强主动沟通'),
(1,7,7,'SELF',75,'完成竞品调研阶段性工作'),
(1,7,4,'PEER',78,'报告结构清晰'),
(1,7,3,'MANAGER',72,'进度略滞后于计划');

-- 绩效结果（按权重计算：user4=88.6 A, user5=92.2 S, user6=82.0 A, user7=73.8 B）
INSERT INTO t_result(id,plan_id,user_id,total_score,grade,status,manager_comment,hr_comment) VALUES
(1,1,4,88.6,'A','PUBLISHED','任务推进稳健，建议保持','同意发布'),
(2,1,5,92.2,'S','PUBLISHED','关键任务交付优秀','同意发布'),
(3,1,6,82.0,'A','PENDING','方案质量良好，待HR审核',''),
(4,1,7,73.8,'B','PUBLISHED','进度需改进','同意发布');

-- 申诉记录：王强(id=7) 对自己的结果(id=4) 发起申诉，待主管复核
INSERT INTO t_appeal(result_id,user_id,reason,status) VALUES
(4,7,'本季度加班完成了版本上线支持工作，但主管评分偏低，请求复核调整','PENDING_MANAGER');
