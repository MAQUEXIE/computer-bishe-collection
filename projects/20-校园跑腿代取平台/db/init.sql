-- ============================================================
-- 20 校园跑腿代取平台 初始化脚本
-- 数据库：db_20_errand (utf8mb4)
-- 账号：admin/123456（管理员） user/123456（下单用户） runner/123456（跑腿员）
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_20_errand DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_20_errand;

-- ---------------- 用户表 ----------------
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(100) NOT NULL,
  real_name VARCHAR(50) DEFAULT '',
  role VARCHAR(20) DEFAULT 'user',           -- user / runner / admin
  phone VARCHAR(30) DEFAULT '',
  credit_score INT DEFAULT 100,               -- 跑腿信用分
  total_income DECIMAL(10,2) DEFAULT 0.00,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO users (id, username, password, real_name, role, phone, credit_score, total_income) VALUES
(1, 'admin',  '123456', '系统管理员', 'admin',  '13800000001', 100, 0.00),
(2, 'user',   '123456', '李同学',     'user',   '13800000002', 100, 0.00),
(3, 'runner', '123456', '王跑腿',     'runner', '13800000003', 115, 18.50),
(4, 'runner2','123456', '赵小慢',     'runner', '13800000004', 55,  4.00);

-- ---------------- 计费规则表 ----------------
DROP TABLE IF EXISTS fee_rules;
CREATE TABLE fee_rules (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) DEFAULT '默认计费规则',
  base_fee DECIMAL(10,2) DEFAULT 3.00,
  per_km_fee DECIMAL(10,2) DEFAULT 1.50,
  min_reward DECIMAL(10,2) DEFAULT 4.00,
  platform_fee_rate DECIMAL(5,2) DEFAULT 0.00,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO fee_rules (id, name, base_fee, per_km_fee, min_reward, platform_fee_rate) VALUES
(1, '校内默认计费规则', 3.00, 1.50, 4.00, 0.00);

-- ---------------- 任务表 ----------------
DROP TABLE IF EXISTS tasks;
CREATE TABLE tasks (
  id INT PRIMARY KEY AUTO_INCREMENT,
  task_no VARCHAR(50) NOT NULL UNIQUE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  task_type VARCHAR(30) DEFAULT '取快递',
  pickup_place VARCHAR(200) DEFAULT '',
  delivery_place VARCHAR(200) DEFAULT '',
  distance_km DECIMAL(5,1) DEFAULT 1.0,
  reward DECIMAL(10,2) DEFAULT 0.00,
  publisher_id INT NOT NULL,
  runner_id INT NULL,
  status VARCHAR(20) DEFAULT 'pending_audit',
  reject_reason VARCHAR(255) DEFAULT '',
  rating_score INT NULL,
  rating_comment VARCHAR(500) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  grabbed_at DATETIME NULL,
  delivered_at DATETIME NULL,
  confirmed_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 任务状态说明：
-- pending_audit 待审核 / available 抢单池 / taken 已抢单 / delivered 已送达
-- confirmed 已确认 / rated 已评价 / rejected 已拒绝 / complained 投诉中
INSERT INTO tasks
(id, task_no, title, description, task_type, pickup_place, delivery_place, distance_km, reward, publisher_id, runner_id, status, reject_reason, rating_score, rating_comment, created_at, grabbed_at, delivered_at, confirmed_at) VALUES
-- 1) 待审核 x2
(1, 'TW20261024090001A1', '取西门菜鸟驿站快递', '取两个中通包裹，单号尾号8821', '取快递', '西门菜鸟驿站', '3号宿舍楼', 1.5, 5.25, 2, NULL, 'pending_audit', '', NULL, '', '2026-10-24 09:00:01', NULL, NULL, NULL),
(2, 'TW20261024090502B2', '代买一杯热豆浆', '食堂三楼早餐窗口，不要加糖', '代买', '第一食堂三楼', '图书馆三楼自习室', 0.8, 4.20, 2, NULL, 'pending_audit', '', NULL, '', '2026-10-24 09:05:02', NULL, NULL, NULL),
-- 2) 抢单池 available x3
(3, 'TW20261023180003C3', '送课本到教学楼', '高数下册送到教二205教室', '送物', '5号宿舍楼', '第二教学楼205', 2.0, 6.00, 2, NULL, 'available', '', NULL, '', '2026-10-23 18:00:03', NULL, NULL, NULL),
(4, 'TW20261023181004D4', '取东门京东自提点包裹', '大件纸箱，约5kg', '取快递', '东门京东自提点', '6号宿舍楼', 2.5, 6.75, 2, NULL, 'available', '', NULL, '', '2026-10-23 18:10:04', NULL, NULL, NULL),
(5, 'TW20261023182005E5', '代取奶茶两杯', '一点点奶茶店，中杯啵啵奶绿', '代买', '后街一点点', '1号宿舍楼', 3.0, 7.50, 2, NULL, 'available', '', NULL, '', '2026-10-23 18:20:05', NULL, NULL, NULL),
-- 3) 已拒绝
(6, 'TW20261023170006F6', '代取外卖并帮带烟', '顺便帮忙校外超市买包烟', '代买', '西门外卖柜', '9号宿舍楼', 1.0, 4.50, 2, NULL, 'rejected', '平台禁止代购烟草类商品', NULL, '', '2026-10-23 17:00:06', NULL, NULL, NULL),
-- 4) 已抢单 taken
(7, 'TW20261024080007G7', '取韵达快递三个包裹', '三个小包裹，尾号1102', '取快递', '南门韵达快递点', '4号宿舍楼', 1.2, 4.80, 2, 3, 'taken', '', NULL, '', '2026-10-24 08:00:07', '2026-10-24 08:12:00', NULL, NULL),
-- 5) 已送达待确认 delivered
(8, 'TW20261024073008H8', '送雨伞到操场', '蓝色折叠伞送到田径场看台上', '送物', '2号宿舍楼', '东区田径场', 1.8, 5.70, 2, 3, 'delivered', '', NULL, '', '2026-10-24 07:30:08', '2026-10-24 07:40:00', '2026-10-24 08:05:00', NULL),
-- 6) 已确认未评价 confirmed
(9, 'TW20261023120009I9', '取顺丰文件封', '一封考研资料文件封，必须本人签收', '取快递', '北门顺丰营业点', '研究生公寓7号楼', 2.2, 6.30, 2, 3, 'confirmed', '', NULL, '', '2026-10-23 12:00:09', '2026-10-23 12:20:00', '2026-10-23 12:50:00', '2026-10-23 13:10:00'),
-- 7) 已评价 rated x2
(10, 'TW20261022190010J0', '代买水果切盒', '校门口百果园，要西瓜切盒', '代买', '百果园校门口店', '8号宿舍楼', 1.6, 5.40, 2, 3, 'rated', '', 5, '跑腿小哥特别准时，包装也没撒！', '2026-10-22 19:00:10', '2026-10-22 19:10:00', '2026-10-22 19:35:00', '2026-10-22 19:50:00'),
(11, 'TW20261022150011K1', '取邮政包裹', '中国邮政平邮包裹带证件', '取快递', '学校邮政所', '5号宿舍楼', 1.0, 4.50, 2, 3, 'rated', '', 4, '速度可以，就是稍微晚了五分钟', '2026-10-22 15:00:11', '2026-10-22 15:15:00', '2026-10-22 15:40:00', '2026-10-22 16:00:00'),
-- 8) 投诉中 complained
(12, 'TW20261023160012L2', '代取麦当劳午餐', '麦辣鸡腿堡套餐送到自习室', '代买', '麦当劳校园店', '图书馆五楼自习室', 2.8, 7.20, 2, 3, 'complained', '', NULL, '', '2026-10-23 16:00:12', '2026-10-23 16:15:00', '2026-10-23 17:00:00', NULL);

-- ---------------- 收入记录表 ----------------
DROP TABLE IF EXISTS income_records;
CREATE TABLE income_records (
  id INT PRIMARY KEY AUTO_INCREMENT,
  runner_id INT NOT NULL,
  task_id INT NULL,
  amount DECIMAL(10,2) NOT NULL,
  type VARCHAR(30) DEFAULT '完成任务',
  remark VARCHAR(255) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO income_records (id, runner_id, task_id, amount, type, remark, created_at) VALUES
(1, 3, 10, 5.40, '完成任务', '完成任务 TW20261022190010J0', '2026-10-22 19:50:00'),
(2, 3, 11, 4.50, '完成任务', '完成任务 TW20261022150011K1', '2026-10-22 16:00:00'),
(3, 3, 9,  6.30, '完成任务', '完成任务 TW20261023120009I9', '2026-10-23 13:10:00'),
(4, 3, NULL, 2.30, '完成任务', '历史订单补录（上周取件）',     '2026-10-21 20:00:00'),
(5, 4, NULL, 4.00, '完成任务', 'runner2 历史完成一单',         '2026-10-20 18:00:00');

-- ---------------- 投诉表 ----------------
DROP TABLE IF EXISTS complaints;
CREATE TABLE complaints (
  id INT PRIMARY KEY AUTO_INCREMENT,
  task_id INT NOT NULL,
  complainant_id INT NOT NULL,
  respondent_id INT NOT NULL,
  reason VARCHAR(500) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  result VARCHAR(500) DEFAULT '',
  credit_adjust INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  resolved_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 一条待处理投诉（针对任务12，用户投诉跑腿员），一条已处理投诉（runner2 被投诉扣10分，故信用分55）
INSERT INTO complaints (id, task_id, complainant_id, respondent_id, reason, status, result, credit_adjust, created_at, resolved_at) VALUES
(1, 12, 2, 3, '送的麦当劳套餐饮料洒了一半，联系跑腿员不回复', 'pending', '', 0, '2026-10-23 17:30:00', NULL),
(2, 11, 2, 4, 'runner2 取快递迟到40分钟，害我错过取件时间', 'resolved', '核实属实，对跑腿员扣信用分10分', -10, '2026-10-18 10:00:00', '2026-10-18 15:00:00');
