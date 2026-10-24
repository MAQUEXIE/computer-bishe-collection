-- 28 校园共享单车系统 初始化脚本
CREATE DATABASE IF NOT EXISTS db_28_bike DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_28_bike;

-- ----------------------------
-- 用户表
-- ----------------------------
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(100) NOT NULL,
  real_name VARCHAR(50) DEFAULT '',
  role VARCHAR(20) DEFAULT 'student',
  credit_score INT DEFAULT 100,
  balance DECIMAL(10,2) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 单车主表
-- ----------------------------
CREATE TABLE IF NOT EXISTS bikes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  bike_no VARCHAR(20) NOT NULL UNIQUE,
  status VARCHAR(20) DEFAULT 'available',
  area VARCHAR(50) DEFAULT '',
  lng DECIMAL(10,6) DEFAULT 0,
  lat DECIMAL(10,6) DEFAULT 0,
  battery INT DEFAULT 100,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 骑行记录表
-- ----------------------------
CREATE TABLE IF NOT EXISTS rides (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ride_no VARCHAR(40) NOT NULL UNIQUE,
  student_id INT NOT NULL,
  bike_id INT NOT NULL,
  start_area VARCHAR(50) DEFAULT '',
  end_area VARCHAR(50) DEFAULT '',
  start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  end_time DATETIME NULL,
  duration_minutes INT DEFAULT 0,
  cost DECIMAL(10,2) DEFAULT 0,
  status VARCHAR(20) DEFAULT 'ongoing',
  illegal_stop TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 调度任务表
-- ----------------------------
CREATE TABLE IF NOT EXISTS dispatch_tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_no VARCHAR(40) NOT NULL UNIQUE,
  bike_id INT NOT NULL,
  from_area VARCHAR(50) DEFAULT '',
  to_area VARCHAR(50) DEFAULT '',
  reason VARCHAR(200) DEFAULT '',
  source VARCHAR(20) DEFAULT 'auto',
  status VARCHAR(20) DEFAULT 'pending',
  dispatcher_id INT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  finished_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 运维报修表
-- ----------------------------
CREATE TABLE IF NOT EXISTS repairs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  bike_id INT NOT NULL,
  description VARCHAR(500) DEFAULT '',
  result VARCHAR(20) DEFAULT '',
  reply VARCHAR(500) DEFAULT '',
  status VARCHAR(20) DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  handled_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 信用积分流水表
-- ----------------------------
CREATE TABLE IF NOT EXISTS credit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  `change` INT NOT NULL,
  reason VARCHAR(200) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 计费规则表
-- ----------------------------
CREATE TABLE IF NOT EXISTS billing_rules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) DEFAULT '校园标准价',
  base_fee DECIMAL(10,2) DEFAULT 1.5,
  per_minute DECIMAL(10,2) DEFAULT 0.1,
  free_minutes INT DEFAULT 15
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 演示数据
-- ============================================================
-- 账号：admin/123456（调度管理员） student/123456（学生） dispatcher/123456（调度员）
INSERT INTO users (username, password, real_name, role, credit_score, balance, created_at) VALUES
('admin', '123456', '王管理', 'admin', 100, 0.00, '2026-10-15 09:00:00'),
('student', '123456', '李同学', 'student', 100, 3.50, '2026-10-15 09:05:00'),
('dispatcher', '123456', '赵调度', 'dispatcher', 100, 0.00, '2026-10-15 09:10:00'),
('lisi', '123456', '刘同学', 'student', 95, 5.20, '2026-10-16 10:00:00');

-- 18 辆单车：东门富余 8 辆（潮汐可调出），图书馆仅 1 辆（潮汐缺车）
INSERT INTO bikes (bike_no, status, area, lng, lat, battery) VALUES
('B001', 'available', '东门', 118.081000, 24.470000, 96),
('B002', 'available', '东门', 118.081100, 24.470100, 88),
('B003', 'available', '东门', 118.081200, 24.470200, 75),
('B004', 'available', '东门', 118.081300, 24.470300, 90),
('B005', 'available', '东门', 118.081400, 24.470400, 66),
('B006', 'available', '东门', 118.081500, 24.470500, 82),
('B007', 'available', '东门', 118.081600, 24.470600, 91),
('B008', 'available', '东门', 118.081700, 24.470700, 79),
('B009', 'available', '图书馆', 118.090000, 24.465000, 85),
('B010', 'available', '宿舍区', 118.070000, 24.480000, 93),
('B011', 'available', '宿舍区', 118.070100, 24.480100, 70),
('B012', 'available', '教学楼', 118.085000, 24.460000, 88),
('B013', 'available', '食堂广场', 118.075000, 24.475000, 97),
('B014', 'available', '体育馆', 118.060000, 24.455000, 64),
('B015', 'maintenance', '东门', 118.081800, 24.470800, 40),
('B016', 'in_use', '教学楼', 118.085100, 24.460100, 77),
('B017', 'available', '教学楼', 118.085200, 24.460200, 81),
('B018', 'available', '宿舍区', 118.070200, 24.480200, 89);

-- 骑行记录：student(id=2) 4 条历史已完成 + lisi(id=4) 1 条进行中
INSERT INTO rides (ride_no, student_id, bike_id, start_area, end_area, start_time, end_time, duration_minutes, cost, status, illegal_stop, created_at) VALUES
('R20261020083001', 2, 12, '东门', '图书馆', '2026-10-20 08:20:00', '2026-10-20 08:38:00', 18, 1.80, 'finished', 0, '2026-10-20 08:20:00'),
('R20261021123002', 2, 3, '宿舍区', '食堂广场', '2026-10-21 12:15:00', '2026-10-21 12:27:00', 12, 1.50, 'finished', 0, '2026-10-21 12:15:00'),
('R20261022183003', 2, 7, '教学楼', '宿舍区', '2026-10-22 18:10:00', '2026-10-22 18:41:00', 31, 3.10, 'finished', 1, '2026-10-22 18:10:00'),
('R20261023200004', 2, 1, '图书馆', '东门', '2026-10-23 20:05:00', '2026-10-23 20:22:00', 17, 1.70, 'finished', 0, '2026-10-23 20:05:00'),
('R20261024090005', 4, 16, '宿舍区', '', '2026-10-24 09:00:00', NULL, 0, 0.00, 'ongoing', 0, '2026-10-24 09:00:00');

-- 调度任务：1 条待处理 + 1 条已完成
INSERT INTO dispatch_tasks (task_no, bike_id, from_area, to_area, reason, source, status, dispatcher_id, created_at, finished_at) VALUES
('T20261023100001', 2, '东门', '图书馆', '潮汐调度：东门车辆富余，图书馆时段用车紧张（建议调拨）', 'auto', 'pending', NULL, '2026-10-23 10:00:00', NULL),
('T20261022100002', 9, '食堂广场', '宿舍区', '人工调度：夜间宿舍区用车需求大', 'manual', 'done', 3, '2026-10-22 10:00:00', '2026-10-22 11:30:00');

-- 运维报修：1 条待处理 + 1 条已处理
INSERT INTO repairs (student_id, bike_id, description, result, reply, status, created_at, handled_at) VALUES
(2, 15, '刹车失灵，下坡刹不住，请尽快检修', '', '', 'pending', '2026-10-23 16:00:00', NULL),
(4, 3, '车胎没气了', 'fixed', '已更换内胎，恢复可用', 'done', '2026-10-21 14:00:00', '2026-10-21 17:00:00');

-- 信用积分流水（student id=2）
INSERT INTO credit_logs (student_id, `change`, reason, created_at) VALUES
(2, 1, '行程R20261020083001规范还车', '2026-10-20 08:38:00'),
(2, 1, '行程R20261021123002规范还车', '2026-10-21 12:27:00'),
(2, -5, '行程R20261022183003违停还车', '2026-10-22 18:41:00'),
(2, 1, '行程R20261023200004规范还车', '2026-10-23 20:22:00');

-- 计费规则：起步价1.5元含15分钟，超出0.1元/分钟
INSERT INTO billing_rules (name, base_fee, per_minute, free_minutes) VALUES
('校园标准价', 1.5, 0.1, 15);
