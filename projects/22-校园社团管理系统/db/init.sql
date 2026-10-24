-- ============================================================
-- 22-校园社团管理系统 数据库初始化脚本
-- 库名: db_22_club  (utf8mb4)
-- 账号: admin/123456(团委), leader/123456(社长), member/123456(社员)
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_22_club DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_22_club;

-- ----------------------------
-- 用户表: role = ADMIN(团委) / LEADER(社长) / STUDENT(社员)
-- ----------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(64) NOT NULL UNIQUE,
  password    VARCHAR(64) NOT NULL,
  nickname    VARCHAR(64) NOT NULL,
  phone       VARCHAR(32) DEFAULT '',
  role        VARCHAR(16) NOT NULL,
  status      INT DEFAULT 1 COMMENT '1正常 0禁用',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 社团表: status = PENDING待审/APPROVED通过/REJECTED驳回; star 1-5星
-- ----------------------------
DROP TABLE IF EXISTS t_club;
CREATE TABLE t_club (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(128) NOT NULL,
  category    VARCHAR(64) DEFAULT '',
  description VARCHAR(1024) DEFAULT '',
  emoji       VARCHAR(16) DEFAULT '🎈',
  leader_id   BIGINT,
  status      VARCHAR(16) DEFAULT 'PENDING',
  star        INT DEFAULT 0,
  balance     DECIMAL(10,2) DEFAULT 0.00 COMMENT '经费余额',
  audit_remark VARCHAR(255) DEFAULT '',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 社团成员关系: membership.status = PENDING待批/APPROVED已入社/QUIT已退出
--              fee_status = UNPAID未缴/PAID已缴社费
-- ----------------------------
DROP TABLE IF EXISTS t_membership;
CREATE TABLE t_membership (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  club_id    BIGINT NOT NULL,
  user_id    BIGINT NOT NULL,
  status     VARCHAR(16) DEFAULT 'PENDING',
  fee_status VARCHAR(16) DEFAULT 'UNPAID',
  join_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_club_user (club_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 活动表: status = PENDING待审批/APPROVED已通过/REJECTED已驳回
-- ----------------------------
DROP TABLE IF EXISTS t_activity;
CREATE TABLE t_activity (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  club_id       BIGINT NOT NULL,
  title         VARCHAR(128) NOT NULL,
  content       VARCHAR(1024) DEFAULT '',
  location      VARCHAR(128) DEFAULT '',
  activity_time DATETIME,
  quota         INT DEFAULT 50 COMMENT '报名上限',
  status        VARCHAR(16) DEFAULT 'PENDING',
  create_time   DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 活动报名: status = SIGNED已报名/CANCELLED已取消
-- ----------------------------
DROP TABLE IF EXISTS t_signup;
CREATE TABLE t_signup (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  activity_id BIGINT NOT NULL,
  user_id     BIGINT NOT NULL,
  status      VARCHAR(16) DEFAULT 'SIGNED',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_act_user (activity_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 经费申请: status = PENDING待审批/APPROVED已通过/REJECTED已驳回
-- ----------------------------
DROP TABLE IF EXISTS t_fund;
CREATE TABLE t_fund (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  club_id      BIGINT NOT NULL,
  title        VARCHAR(128) NOT NULL,
  amount       DECIMAL(10,2) NOT NULL,
  reason       VARCHAR(1024) DEFAULT '',
  status       VARCHAR(16) DEFAULT 'PENDING',
  approve_remark VARCHAR(255) DEFAULT '',
  create_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
  approve_time DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 支出登记(台账): 从社团余额中支出
-- ----------------------------
DROP TABLE IF EXISTS t_expense;
CREATE TABLE t_expense (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  club_id       BIGINT NOT NULL,
  title         VARCHAR(128) NOT NULL,
  amount        DECIMAL(10,2) NOT NULL,
  remark        VARCHAR(512) DEFAULT '',
  expense_time  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 社费缴纳记录
-- ----------------------------
DROP TABLE IF EXISTS t_dues;
CREATE TABLE t_dues (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT NOT NULL,
  club_id    BIGINT NOT NULL,
  amount     DECIMAL(10,2) NOT NULL,
  pay_time   DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 演示数据
-- ============================================================

-- 用户: 1 admin(团委) 2 leader(吉他社社长) 3 member(社员) 4 student2 5 student3
--       6 leader2(摄影社长) 7 leader3(篮球社长) 8 leader4(文学社社长) 9 leader5(动漫社社长)
INSERT INTO t_user(id,username,password,nickname,phone,role,status) VALUES
(1,'admin','123456','校团委管理员','13800000001','ADMIN',1),
(2,'leader','123456','张弦','13800000002','LEADER',1),
(3,'member','123456','李同学','13800000003','STUDENT',1),
(4,'student2','123456','王同学','13800000004','STUDENT',1),
(5,'student3','123456','赵同学','13800000005','STUDENT',1),
(6,'leader2','123456','陈快门','13800000006','LEADER',1),
(7,'leader3','123456','刘中锋','13800000007','LEADER',1),
(8,'leader4','123456','苏墨','13800000008','LEADER',1),
(9,'leader5','123456','周漫','13800000009','LEADER',1);

-- 社团: 5个已过审(含星级) + 1个待审核 + 1个已驳回
INSERT INTO t_club(id,name,category,description,emoji,leader_id,status,star,balance,create_time) VALUES
(1,'吉他社','文艺体育','招热爱吉他的同学，每周四晚集训，定期举办校园音乐会。','🎸',2,'APPROVED',5,1500.00,'2025-09-01 18:00:00'),
(2,'摄影协会','文艺体育','用镜头记录校园，拥有摄影器材库，定期组织外拍与影展。','📷',6,'APPROVED',4,800.00,'2025-09-02 18:00:00'),
(3,'篮球社','文艺体育','院际篮球联赛承办方，每周固定训练，欢迎各级水平同学加入。','🏀',7,'APPROVED',4,600.00,'2025-09-03 18:00:00'),
(4,'文学社','学术科技','读书分享、征文比赛、校园刊物编辑，以文会友。','📖',8,'APPROVED',3,200.00,'2025-09-04 18:00:00'),
(5,'编程爱好者协会','学术科技','算法刷题组队、开源项目实战、ACM 竞赛集训。','💻',2,'APPROVED',2,0.00,'2025-09-05 18:00:00'),
(6,'动漫社','兴趣爱好','新番研讨、Cosplay 外景、校园漫展协办，待团委审核入驻。','🎌',9,'PENDING',0,0.00,'2026-10-20 10:00:00'),
(7,'魔术社','兴趣爱好','魔术表演与教学交流（演示数据：曾被驳回的社团）。','🪄',9,'REJECTED',0,0.00,'2025-09-06 18:00:00');

-- 成员关系
INSERT INTO t_membership(club_id,user_id,status,fee_status,join_time) VALUES
(1,3,'APPROVED','PAID','2025-09-10 12:00:00'),
(1,4,'APPROVED','UNPAID','2025-09-11 12:00:00'),
(1,2,'APPROVED','PAID','2025-09-01 18:00:00'),
(2,5,'APPROVED','PAID','2025-09-12 12:00:00'),
(2,6,'APPROVED','PAID','2025-09-02 18:00:00'),
(3,7,'APPROVED','PAID','2025-09-03 18:00:00'),
(4,8,'APPROVED','PAID','2025-09-04 18:00:00'),
(5,2,'APPROVED','PAID','2025-09-05 18:00:00'),
(4,3,'APPROVED','UNPAID','2025-09-15 12:00:00'),
-- 待社长审核的入社申请
(3,3,'PENDING','UNPAID','2026-10-22 09:30:00'),
(4,4,'PENDING','UNPAID','2026-10-23 14:00:00'),
(1,5,'PENDING','UNPAID','2026-10-24 09:10:00');

-- 活动: 已通过 / 待审批 混合
INSERT INTO t_activity(club_id,title,content,location,activity_time,quota,status,create_time) VALUES
(1,'秋日校园音乐会排演','吉他社季度音乐会集中排演，参演成员请准时到场。','大学生活动中心 301','2026-10-28 19:00:00',40,'APPROVED','2026-10-15 10:00:00'),
(1,'周末吉他公益体验课','面向全校的零基础吉他体验课，提供共享吉他。','大学生活动中心 205','2026-11-01 15:00:00',30,'APPROVED','2026-10-16 10:00:00'),
(2,'秋日银杏大道外拍','摄影协会秋季外景实拍活动，提供相机借用。','学校西门银杏大道','2026-10-26 09:00:00',25,'APPROVED','2026-10-12 10:00:00'),
(3,'新生篮球邀请赛','社团招新后首届队内邀请赛，三分/扣篮表演。','东区体育馆篮球场','2026-10-27 16:00:00',60,'PENDING','2026-10-21 11:00:00'),
(1,'跨年晚会节目初审','为校跨年晚会准备节目，提交吉他弹唱节目单。','大礼堂排练厅','2026-11-05 14:00:00',20,'PENDING','2026-10-23 16:00:00');

-- 活动报名记录
INSERT INTO t_signup(activity_id,user_id,status,create_time) VALUES
(1,3,'SIGNED','2026-10-16 09:00:00'),
(1,4,'SIGNED','2026-10-16 09:05:00'),
(2,3,'SIGNED','2026-10-17 10:00:00'),
(3,5,'SIGNED','2026-10-13 09:00:00');

-- 经费申请: 已通过/待审批混合
INSERT INTO t_fund(club_id,title,amount,reason,status,approve_time,create_time) VALUES
(1,'音乐会琴弦耗材采购',600.00,'秋季音乐会需更换琴弦、拨片等耗材。','APPROVED','2026-10-16 15:00:00','2026-10-15 10:30:00'),
(2,'外拍活动交通与门票',300.00,'秋季外拍集体交通与场地门票补贴。','APPROVED','2026-10-13 11:00:00','2026-10-12 10:00:00'),
(1,'跨年晚会节目道具费',800.00,'演出音响租用、乐谱打印与道具制作。','PENDING',NULL,'2026-10-23 16:30:00'),
(3,'新生篮球赛饮用水与奖品',450.00,'比赛饮用水、奖牌与小奖品采购。','PENDING',NULL,'2026-10-22 09:00:00');

-- 支出登记(台账)
INSERT INTO t_expense(club_id,title,amount,remark,expense_time) VALUES
(1,'琴弦拨片采购',380.00,'京东乐器店采购 010 规格琴弦 10 套。','2026-10-18 14:00:00'),
(2,'外拍交通补贴',220.00,'集体打车 2 辆，凭票报销。','2026-10-14 18:00:00');

-- 社费缴纳记录
INSERT INTO t_dues(user_id,club_id,amount,pay_time) VALUES
(3,1,20.00,'2025-09-10 12:05:00'),
(2,1,20.00,'2025-09-01 18:10:00'),
(5,2,20.00,'2025-09-12 12:10:00'),
(6,2,20.00,'2025-09-02 18:10:00'),
(7,3,20.00,'2025-09-03 18:10:00');
