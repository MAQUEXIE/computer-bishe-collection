-- ============================================================
-- 12 健身房会员管理系统 初始化脚本
-- 库名: db_12_gym  后端端口: 9012  前端端口: 5112
-- 账号: admin/123456(管理员) coach/123456(教练) member/123456(会员)
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_12_gym DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_12_gym;

DROP TABLE IF EXISTS t_checkin;
DROP TABLE IF EXISTS t_body_test;
DROP TABLE IF EXISTS t_booking;
DROP TABLE IF EXISTS t_member_card;
DROP TABLE IF EXISTS t_card_type;
DROP TABLE IF EXISTS t_user;

-- ---------- 用户（管理员/教练/会员） ----------
CREATE TABLE t_user (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(50) NOT NULL UNIQUE,
  password    VARCHAR(50) NOT NULL,
  name        VARCHAR(50) NOT NULL,
  phone       VARCHAR(30) DEFAULT '',
  gender      VARCHAR(10) DEFAULT '男',
  role        VARCHAR(20) NOT NULL COMMENT 'ADMIN/COACH/MEMBER',
  status      INT DEFAULT 1 COMMENT '1正常 0禁用',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 卡种套餐 ----------
CREATE TABLE t_card_type (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(50) NOT NULL,
  price       DECIMAL(10,2) NOT NULL,
  valid_days  INT DEFAULT 0 COMMENT '有效天数，次卡为0',
  times       INT DEFAULT 0 COMMENT '总次数，不限次为0',
  description VARCHAR(255) DEFAULT '',
  status      INT DEFAULT 1 COMMENT '1上架 0下架',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 会员购卡记录 ----------
CREATE TABLE t_member_card (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  member_id    BIGINT NOT NULL,
  member_name  VARCHAR(50) NOT NULL,
  card_type_id BIGINT NOT NULL,
  card_name    VARCHAR(50) NOT NULL,
  price        DECIMAL(10,2) NOT NULL,
  start_date   DATE NOT NULL,
  end_date     DATE NOT NULL,
  total_times  INT DEFAULT 0 COMMENT '总次数，不限次为0',
  remain_times INT DEFAULT 0 COMMENT '剩余次数，不限次为0',
  created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 私教约课 ----------
CREATE TABLE t_booking (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  member_id   BIGINT NOT NULL,
  member_name VARCHAR(50) NOT NULL,
  coach_id    BIGINT NOT NULL,
  coach_name  VARCHAR(50) NOT NULL,
  class_name  VARCHAR(50) DEFAULT '私教课',
  class_date  DATE NOT NULL,
  start_time  VARCHAR(10) NOT NULL,
  end_time    VARCHAR(10) NOT NULL,
  status      VARCHAR(20) DEFAULT 'BOOKED' COMMENT 'BOOKED/DONE/CANCELLED',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 体测记录 ----------
CREATE TABLE t_body_test (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  member_id   BIGINT NOT NULL,
  member_name VARCHAR(50) NOT NULL,
  coach_name  VARCHAR(50) DEFAULT '',
  test_date   DATE NOT NULL,
  height      DECIMAL(5,1),
  weight      DECIMAL(5,1),
  body_fat    DECIMAL(4,1) COMMENT '体脂率%',
  muscle      DECIMAL(4,1) COMMENT '肌肉量kg',
  bmi         DECIMAL(4,1),
  chest       DECIMAL(5,1),
  waist       DECIMAL(5,1),
  hip         DECIMAL(5,1),
  note        VARCHAR(255) DEFAULT '',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 入场签到 ----------
CREATE TABLE t_checkin (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  member_id    BIGINT NOT NULL,
  member_name  VARCHAR(50) NOT NULL,
  checkin_time DATETIME NOT NULL,
  type         VARCHAR(10) DEFAULT '入场'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================= 初始化账号 =================
INSERT INTO t_user(username,password,name,phone,gender,role,status) VALUES
('admin','123456','系统管理员','13800000000','男','ADMIN',1),
('coach','123456','王教练','13800000001','男','COACH',1),
('coach2','123456','李教练','13800000002','女','COACH',1),
('coach3','123456','赵教练','13800000003','男','COACH',1),
('coach4','123456','陈教练','13800000004','女','COACH',1),
('member','123456','张伟','13900000001','男','MEMBER',1),
('member2','123456','刘洋','13900000002','男','MEMBER',1),
('member3','123456','陈静','13900000003','女','MEMBER',1),
('member4','123456','杨帆','13900000004','男','MEMBER',1),
('member5','123456','周婷','13900000005','女','MEMBER',1);

-- ================= 卡种套餐（5 种） =================
INSERT INTO t_card_type(name,price,valid_days,times,description,status) VALUES
('周卡',   99.00,  7,  0, '7天内不限次健身，适合短期体验', 1),
('月卡',  299.00, 30,  0, '30天不限次健身，最受欢迎',       1),
('季卡',  799.00, 90,  0, '90天不限次健身，平均每天不到9元',1),
('年卡', 2399.00,365,  0, '365天不限次健身，赠送体测2次',   1),
('私教10次卡',1800.00,365,10,'10节一对一私教课，有效期一年', 1);

-- ================= 会员购卡记录 =================
-- 张伟：月卡，10天后到期（到期预警演示）
INSERT INTO t_member_card(member_id,member_name,card_type_id,card_name,price,start_date,end_date,total_times,remain_times)
SELECT 6,'张伟',2,'月卡',299.00, DATE_SUB(CURDATE(),INTERVAL 20 DAY), DATE_ADD(CURDATE(),INTERVAL 10 DAY), 0,0;
-- 刘洋：年卡，265天后到期
INSERT INTO t_member_card(member_id,member_name,card_type_id,card_name,price,start_date,end_date,total_times,remain_times)
SELECT 7,'刘洋',4,'年卡',2399.00, DATE_SUB(CURDATE(),INTERVAL 100 DAY), DATE_ADD(CURDATE(),INTERVAL 265 DAY), 0,0;
-- 陈静：季卡，已过期10天
INSERT INTO t_member_card(member_id,member_name,card_type_id,card_name,price,start_date,end_date,total_times,remain_times)
SELECT 8,'陈静',3,'季卡',799.00, DATE_SUB(CURDATE(),INTERVAL 100 DAY), DATE_SUB(CURDATE(),INTERVAL 10 DAY), 0,0;
-- 杨帆：私教10次卡，剩余6次
INSERT INTO t_member_card(member_id,member_name,card_type_id,card_name,price,start_date,end_date,total_times,remain_times)
SELECT 9,'杨帆',5,'私教10次卡',1800.00, DATE_SUB(CURDATE(),INTERVAL 30 DAY), DATE_ADD(CURDATE(),INTERVAL 335 DAY), 10,6;
-- 周婷：月卡，25天后到期（到期预警演示）
INSERT INTO t_member_card(member_id,member_name,card_type_id,card_name,price,start_date,end_date,total_times,remain_times)
SELECT 10,'周婷',2,'月卡',299.00, DATE_SUB(CURDATE(),INTERVAL 5 DAY), DATE_ADD(CURDATE(),INTERVAL 25 DAY), 0,0;

-- ================= 私教约课 =================
-- 张伟预约王教练明天 10:00（会员可取消）
INSERT INTO t_booking(member_id,member_name,coach_id,coach_name,class_name,class_date,start_time,end_time,status)
SELECT 6,'张伟',2,'王教练','力量塑形私教课', DATE_ADD(CURDATE(),INTERVAL 1 DAY), '10:00','11:00','BOOKED';
-- 张伟已完成李教练一节课
INSERT INTO t_booking(member_id,member_name,coach_id,coach_name,class_name,class_date,start_time,end_time,status)
SELECT 6,'张伟',3,'李教练','有氧燃脂私教课', DATE_SUB(CURDATE(),INTERVAL 3 DAY), '19:00','20:00','DONE';
-- 刘洋预约赵教练后天 14:00
INSERT INTO t_booking(member_id,member_name,coach_id,coach_name,class_name,class_date,start_time,end_time,status)
SELECT 7,'刘洋',4,'赵教练','增肌训练私教课', DATE_ADD(CURDATE(),INTERVAL 2 DAY), '14:00','15:00','BOOKED';
-- 陈静已取消
INSERT INTO t_booking(member_id,member_name,coach_id,coach_name,class_name,class_date,start_time,end_time,status)
SELECT 8,'陈静',2,'王教练','体态评估私教课', DATE_SUB(CURDATE(),INTERVAL 5 DAY), '10:00','11:00','CANCELLED';
-- 杨帆已完成陈教练一节课
INSERT INTO t_booking(member_id,member_name,coach_id,coach_name,class_name,class_date,start_time,end_time,status)
SELECT 9,'杨帆',5,'陈教练','拉伸放松私教课', DATE_SUB(CURDATE(),INTERVAL 1 DAY), '18:00','19:00','DONE';
-- 周婷预约王教练后天 09:00
INSERT INTO t_booking(member_id,member_name,coach_id,coach_name,class_name,class_date,start_time,end_time,status)
SELECT 10,'周婷',2,'王教练','瑜伽私教课', DATE_ADD(CURDATE(),INTERVAL 1 DAY), '09:00','10:00','BOOKED';

-- ================= 体测记录（张伟 3 次，用于曲线对比） =================
INSERT INTO t_body_test(member_id,member_name,coach_name,test_date,height,weight,body_fat,muscle,bmi,chest,waist,hip,note)
SELECT 6,'张伟','王教练', DATE_SUB(CURDATE(),INTERVAL 110 DAY), 176.0, 78.5, 28.0, 38.0, 25.3, 102.0, 92.0, 100.0, '初始体测，体脂偏高';
INSERT INTO t_body_test(member_id,member_name,coach_name,test_date,height,weight,body_fat,muscle,bmi,chest,waist,hip,note)
SELECT 6,'张伟','王教练', DATE_SUB(CURDATE(),INTERVAL 60 DAY), 176.0, 76.2, 25.5, 39.5, 24.6, 103.0, 88.0, 99.0, '坚持训练2个月，腰围下降';
INSERT INTO t_body_test(member_id,member_name,coach_name,test_date,height,weight,body_fat,muscle,bmi,chest,waist,hip,note)
SELECT 6,'张伟','李教练', DATE_SUB(CURDATE(),INTERVAL 4 DAY), 176.0, 74.0, 22.8, 41.0, 23.8, 104.0, 85.0, 98.0, '效果显著，体脂率达标';
-- 刘洋、陈静各 1 次
INSERT INTO t_body_test(member_id,member_name,coach_name,test_date,height,weight,body_fat,muscle,bmi,chest,waist,hip,note)
SELECT 7,'刘洋','赵教练', DATE_SUB(CURDATE(),INTERVAL 20 DAY), 170.0, 65.0, 24.0, 35.0, 22.5, 98.0, 82.0, 96.0, '基础体测';
INSERT INTO t_body_test(member_id,member_name,coach_name,test_date,height,weight,body_fat,muscle,bmi,chest,waist,hip,note)
SELECT 8,'陈静','王教练', DATE_SUB(CURDATE(),INTERVAL 40 DAY), 162.0, 55.0, 26.0, 24.0, 21.0, 88.0, 70.0, 92.0, '基础体测';

-- ================= 签到记录 =================
INSERT INTO t_checkin(member_id,member_name,checkin_time,type) VALUES
(6,'张伟', CONCAT(CURDATE(),' 09:15:00'), '入场'),
(7,'刘洋', CONCAT(CURDATE(),' 08:50:00'), '入场'),
(10,'周婷', CONCAT(CURDATE(),' 10:05:00'), '入场'),
(8,'陈静', CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 18:20:00'), '入场'),
(9,'杨帆', CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 19:00:00'), '入场');
