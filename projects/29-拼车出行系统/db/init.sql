-- ============================================
-- 29 拼车出行系统 数据库初始化
-- 库名: db_29_carpool
-- ============================================
CREATE DATABASE IF NOT EXISTS db_29_carpool DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_29_carpool;

-- ---------- 用户表 ----------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64),
  phone VARCHAR(32),
  role VARCHAR(16) NOT NULL COMMENT 'ADMIN/DRIVER/PASSENGER',
  status INT DEFAULT 1 COMMENT '0待审核 1正常 2拒绝',
  car_no VARCHAR(16) COMMENT '车主车牌',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 行程表 ----------
DROP TABLE IF EXISTS t_trip;
CREATE TABLE t_trip (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  driver_id BIGINT NOT NULL,
  start_point VARCHAR(128) NOT NULL,
  end_point VARCHAR(128) NOT NULL,
  start_time DATETIME NOT NULL,
  seats_total INT NOT NULL DEFAULT 3 COMMENT '总座位数(含车主)',
  seats_used INT NOT NULL DEFAULT 0 COMMENT '已确认乘客数',
  price_total DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '全程车费预估',
  status INT NOT NULL DEFAULT 0 COMMENT '0待审核 1已发布 2已满员 3已出发 4已完成 5已取消 6审核拒绝',
  remark VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 拼车申请表 ----------
DROP TABLE IF EXISTS t_application;
CREATE TABLE t_application (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  trip_id BIGINT NOT NULL,
  passenger_id BIGINT NOT NULL,
  status INT NOT NULL DEFAULT 0 COMMENT '0待审核 1已同意 2已拒绝 3已取消',
  paid INT NOT NULL DEFAULT 0 COMMENT '0未支付 1已支付',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 支付记录表 ----------
DROP TABLE IF EXISTS t_payment;
CREATE TABLE t_payment (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  application_id BIGINT NOT NULL,
  trip_id BIGINT NOT NULL,
  passenger_id BIGINT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  status INT NOT NULL DEFAULT 1 COMMENT '1已支付',
  pay_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 评价表 ----------
DROP TABLE IF EXISTS t_review;
CREATE TABLE t_review (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  trip_id BIGINT NOT NULL,
  reviewer_id BIGINT NOT NULL,
  reviewee_id BIGINT NOT NULL,
  rating INT NOT NULL DEFAULT 5,
  content VARCHAR(255),
  direction VARCHAR(32) COMMENT 'DRIVER_TO_PASSENGER / PASSENGER_TO_DRIVER',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 纠纷表 ----------
DROP TABLE IF EXISTS t_dispute;
CREATE TABLE t_dispute (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  trip_id BIGINT NOT NULL,
  reporter_id BIGINT NOT NULL,
  reason VARCHAR(255),
  status INT NOT NULL DEFAULT 0 COMMENT '0待处理 1已处理',
  handle_note VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 初始数据
-- ============================================

-- 用户: admin / driver / passenger
INSERT INTO t_user(id, username, password, nickname, phone, role, status, car_no) VALUES
(1, 'admin', '123456', '系统管理员', '13800000001', 'ADMIN', 1, NULL),
(2, 'driver', '123456', '王师傅', '13800000002', 'DRIVER', 1, '闽D·A12345'),
(3, 'passenger', '123456', '李乘客', '13800000003', 'PASSENGER', 1, NULL),
(4, 'driver2', '123456', '刘师傅', '13800000004', 'DRIVER', 1, '闽D·B66666'),
(5, 'passenger2', '123456', '张同学', '13800000005', 'PASSENGER', 1, NULL),
(6, 'passenger3', '123456', '陈女士', '13800000006', 'PASSENGER', 1, NULL),
(7, 'driver3', '123456', '陈师傅', '13800000007', 'DRIVER', 1, '闽D·C88888');

-- 行程: 8条以上
-- 状态: 0待审核 1已发布 2已满员 3已出发 4已完成 5已取消 6审核拒绝
INSERT INTO t_trip(id, driver_id, start_point, end_point, start_time, seats_total, seats_used, price_total, status, remark) VALUES
-- driver(2) 王师傅
(1, 2, '厦门北站', '软件二期地铁站', '2026-10-25 08:00:00', 3, 1, 60.00, 1, '早高峰通勤，顺路捎带'),
(2, 2, '思明区市政府', '翔安南路理工学院', '2026-10-25 14:00:00', 4, 0, 80.00, 1, '周末返乡，可放行李'),
(3, 2, '海沧大桥', '集美大学', '2026-10-24 18:00:00', 3, 2, 50.00, 3, '下班顺路'),
(4, 2, '湖里万达', '同安方特梦幻王国', '2026-10-26 09:30:00', 4, 0, 100.00, 0, '待管理员审核'),
-- driver2(4) 刘师傅
(5, 4, '会展中心', '厦门高崎机场T3', '2026-10-25 11:00:00', 3, 2, 90.00, 2, '已满员，仅候补'),
(6, 4, '五缘湾运动馆', '东渡邮轮中心', '2026-10-24 07:30:00', 3, 2, 45.00, 4, '已完成行程'),
-- driver3(7) 陈师傅
(7, 7, '鼓浪屿轮渡码头', '厦门大学漳州校区', '2026-10-25 16:00:00', 4, 1, 70.00, 1, '跨城拼车，价格实惠'),
(8, 7, '厦门站南广场', '泉州万达广场', '2026-10-26 13:00:00', 3, 0, 120.00, 6, '路线偏离太远，审核拒绝');

-- 拼车申请
INSERT INTO t_application(id, trip_id, passenger_id, status, paid) VALUES
-- trip1 王师傅厦门北站->软件园: passenger(3)已同意已支付, passenger(5)待审核
(1, 1, 3, 1, 1),
(2, 1, 5, 0, 0),
-- trip3 王师傅海沧->集大: passenger(5)同意已支付, passenger(6)同意已支付
(3, 3, 5, 1, 1),
(4, 3, 6, 1, 1),
-- trip5 刘师傅会展->机场: passenger(3)同意已支付, passenger(6)同意已支付
(5, 5, 3, 1, 1),
(6, 5, 6, 1, 1),
-- trip6 刘师傅五缘湾->东渡: passenger(5)同意已支付
(7, 6, 5, 1, 1),
-- trip7 陈师傅轮渡->漳校区: passenger(3)同意已支付
(8, 7, 3, 1, 1),
-- trip2 王师傅->理工: passenger(5)申请待审核
(9, 2, 5, 0, 0);

-- 支付记录
INSERT INTO t_payment(application_id, trip_id, passenger_id, amount, status) VALUES
(1, 1, 3, 20.00, 1),   -- trip1 price60, 车主+1乘客=2人, 60/3? 实际动态分摊按 seats_total=3, 已确认1人, 60/3=20
(3, 3, 5, 25.00, 1),    -- trip3 price50, seats_total=3, 已确认2人, 50/2? 展示用动态分摊
(4, 3, 6, 25.00, 1),
(5, 5, 3, 45.00, 1),    -- trip5 price90 seats_total=3
(6, 5, 6, 45.00, 1),
(7, 6, 5, 45.00, 1),    -- trip6 price45
(8, 7, 3, 23.33, 1);    -- trip7 price70 seats_total=4

-- 评价
INSERT INTO t_review(trip_id, reviewer_id, reviewee_id, rating, content, direction) VALUES
(6, 5, 4, 5, '刘师傅开车很稳，准时到达，好评！', 'PASSENGER_TO_DRIVER'),
(6, 4, 5, 5, '张同学很守时，下车还帮忙清理了座位，下次还载。', 'DRIVER_TO_PASSENGER');

-- 纠纷
INSERT INTO t_dispute(trip_id, reporter_id, reason, status, handle_note) VALUES
(5, 6, '车主临时改变上车点，导致我多走了1公里，要求退部分费用', 0, NULL),
(3, 5, '乘客未按时到达，耽误了我15分钟', 1, '已协调双方，车主下次注意提前提醒，乘客已道歉');
