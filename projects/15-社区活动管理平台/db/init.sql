-- ============================================================
-- 15-社区活动管理平台 数据库初始化脚本
-- 库名: db_15_community  utf8mb4
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_15_community DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_15_community;

-- ----------------------------
-- 用户表
-- ----------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(100) NOT NULL,
  nickname VARCHAR(50),
  phone VARCHAR(20),
  role VARCHAR(20) NOT NULL COMMENT 'ADMIN管理员 ORGANIZER组织者 RESIDENT居民',
  status INT DEFAULT 1 COMMENT '1正常',
  points INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 活动表
-- ----------------------------
DROP TABLE IF EXISTS t_activity;
CREATE TABLE t_activity (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(100) NOT NULL,
  description TEXT,
  category VARCHAR(30),
  location VARCHAR(100),
  start_time DATETIME,
  end_time DATETIME,
  quota INT DEFAULT 0 COMMENT '总名额',
  enrolled_count INT DEFAULT 0 COMMENT '已报名人数',
  image VARCHAR(200),
  organizer_id BIGINT,
  organizer_name VARCHAR(50),
  status VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING待审核 APPROVED已通过 REJECTED已拒绝',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 报名表（报名→签到码核销闭环）
-- ----------------------------
DROP TABLE IF EXISTS t_signup;
CREATE TABLE t_signup (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  activity_id BIGINT,
  user_id BIGINT,
  username VARCHAR(50),
  sign_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'REGISTERED' COMMENT 'REGISTERED已报名 CHECKED_IN已签到 CANCELLED已取消',
  checkin_code VARCHAR(10) COMMENT '个人签到核销码',
  checkin_time DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 积分规则表
-- ----------------------------
DROP TABLE IF EXISTS t_point_rule;
CREATE TABLE t_point_rule (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  event_type VARCHAR(30) NOT NULL UNIQUE COMMENT 'SIGN_UP报名 CHECK_IN签到 ALBUM相册',
  points INT NOT NULL,
  description VARCHAR(100),
  enabled INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 积分流水表
-- ----------------------------
DROP TABLE IF EXISTS t_point_log;
CREATE TABLE t_point_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT,
  username VARCHAR(50),
  change_points INT,
  balance INT,
  type VARCHAR(30),
  remark VARCHAR(200),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 活动相册表
-- ----------------------------
DROP TABLE IF EXISTS t_album_photo;
CREATE TABLE t_album_photo (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  activity_id BIGINT,
  activity_title VARCHAR(100),
  user_id BIGINT,
  username VARCHAR(50),
  image_url VARCHAR(500),
  caption VARCHAR(200),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 预置数据
-- ============================================================

-- 用户：admin/123456  organizer/123456  resident/123456  zhangwei/123456
INSERT INTO t_user(username,password,nickname,phone,role,status,points) VALUES
('admin','123456','系统管理员','13800000001','ADMIN',1,0),
('organizer','123456','社区张干事','13800000002','ORGANIZER',1,0),
('resident','123456','李居民','13800000003','RESIDENT',1,40),
('zhangwei','123456','张阿姨','13800000004','RESIDENT',1,25);

-- 活动：7个，覆盖 已通过/待审核/已拒绝 三种状态
INSERT INTO t_activity(title,description,category,location,start_time,end_time,quota,enrolled_count,image,organizer_id,organizer_name,status) VALUES
('周末瑜伽公益课','由社区健身队王教练带领，在小区中心花园开展免费瑜伽体验课，欢迎全体居民参加，请自带瑜伽垫或毛巾。','健康','小区中心花园', '2026-11-01 09:00:00','2026-11-01 10:30:00',30,12,'/images/activities/yoga.svg',2,'社区张干事','APPROVED'),
('亲子绘本读书会','每周日上午在社区书屋开展亲子共读，由志愿者老师带领孩子们阅读经典绘本，培养阅读习惯。','文化','社区书屋二楼', '2026-11-02 10:00:00','2026-11-02 11:30:00',20,8,'/images/activities/reading.svg',2,'社区张干事','APPROVED'),
('社区免费义诊','联合辖区医院开展免费测血压、血糖、健康咨询活动，65岁以上老人优先，欢迎居民前来咨询。','健康','社区卫生服务站', '2026-11-05 08:30:00','2026-11-05 11:30:00',50,30,'/images/activities/clinic.svg',2,'社区张干事','APPROVED'),
('老年书法培训班','面向社区中老年居民的免费书法培训班，笔墨纸砚由社区提供，每周三下午上课。','文化','社区活动中心301室', '2026-11-04 14:00:00','2026-11-04 16:00:00',25,0,'/images/activities/calligraphy.svg',2,'社区张干事','PENDING'),
('秋季广场舞大赛','各小区舞蹈队报名参加的广场舞大赛，设一、二、三等奖，欢迎居民组队报名。','文体','社区文化广场', '2026-11-08 19:00:00','2026-11-08 21:00:00',40,0,'/images/activities/dance.svg',2,'社区张干事','PENDING'),
('商家产品推广讲座','某商家进入社区开展产品销售推广讲座（含商业推销内容）。','商业','社区活动中心201室', '2026-11-06 15:00:00','2026-11-06 17:00:0',100,0,'/images/activities/promo.svg',2,'社区张干事','REJECTED'),
('环保志愿行·垃圾分类宣传','志愿者带队在小区内开展垃圾分类宣传与垃圾清扫志愿活动，欢迎热心居民报名参加。','志愿','小区南门集合', '2026-11-07 09:00:00','2026-11-07 11:00:00',20,20,'/images/activities/eco.svg',2,'社区张干事','APPROVED');

-- 报名记录：含已签到/待签到两种状态，各带个人签到核销码
INSERT INTO t_signup(activity_id,user_id,username,sign_time,status,checkin_code,checkin_time) VALUES
(1,3,'李居民','2026-10-20 19:30:00','REGISTERED','R8X2K1',NULL),
(2,3,'李居民','2026-10-21 10:00:00','CHECKED_IN','M4N9Q7','2026-11-02 10:05:00'),
(7,3,'李居民','2026-10-22 09:15:00','REGISTERED','T5W8E2',NULL),
(1,4,'张阿姨','2026-10-20 20:00:00','CHECKED_IN','P3L6M0','2026-11-01 09:05:00'),
(3,4,'张阿姨','2026-10-23 08:40:00','REGISTERED','Q7W9E4',NULL);

-- 积分规则（管理员可配置）
INSERT INTO t_point_rule(event_type,points,description,enabled) VALUES
('SIGN_UP',5,'成功报名活动奖励积分',1),
('CHECK_IN',20,'活动现场扫码签到核销奖励积分',1),
('ALBUM',10,'上传活动相册照片奖励积分',1);

-- 积分流水（居民李居民 累计40分）
INSERT INTO t_point_log(user_id,username,change_points,balance,type,remark) VALUES
(3,'李居民',5,5,'SIGN_UP','报名活动《周末瑜伽公益课》'),
(3,'李居民',20,25,'CHECK_IN','签到核销《亲子绘本读书会》'),
(3,'李居民',5,30,'SIGN_UP','报名活动《环保志愿行·垃圾分类宣传》'),
(3,'李居民',10,40,'ALBUM','上传《周末瑜伽公益课》活动相册'),
(4,'张阿姨',20,20,'CHECK_IN','签到核销《周末瑜伽公益课》'),
(4,'张阿姨',5,25,'SIGN_UP','报名活动《社区免费义诊》');

-- 活动相册图片
INSERT INTO t_album_photo(activity_id,activity_title,user_id,username,image_url,caption) VALUES
(1,'周末瑜伽公益课',3,'李居民','/images/album/album1.svg','清晨的瑜伽时光，大家都很投入'),
(2,'亲子绘本读书会',4,'张阿姨','/images/album/album2.svg','孩子们认真读书的样子真可爱'),
(3,'社区免费义诊',3,'李居民','/images/album/album3.svg','义诊现场排队的居民不少');
