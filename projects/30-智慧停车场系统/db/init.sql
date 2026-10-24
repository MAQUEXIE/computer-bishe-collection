-- ============================================================
-- 30 智慧停车场系统 初始化脚本
-- 数据库：db_30_parking (utf8mb4)
-- ============================================================
DROP DATABASE IF EXISTS db_30_parking;
CREATE DATABASE db_30_parking DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_30_parking;

-- ---------- 用户 ----------
CREATE TABLE t_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64),
  phone VARCHAR(32),
  role VARCHAR(16) NOT NULL COMMENT 'ADMIN/DRIVER',
  plate_no VARCHAR(32) DEFAULT '',
  auto_pay INT DEFAULT 0 COMMENT '0关闭 1开启无感支付',
  status INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO t_user(username,password,nickname,phone,role,plate_no,auto_pay,status) VALUES
('admin','123456','系统管理员','13800000000','ADMIN','',0,1),
('driver','123456','张车主','13900000001','DRIVER','闽D12345',1,1);

-- ---------- 车位 ----------
CREATE TABLE t_space (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  space_no VARCHAR(32) NOT NULL UNIQUE,
  area VARCHAR(8) NOT NULL COMMENT '区域 A/B/C',
  floor VARCHAR(8) NOT NULL COMMENT '楼层 B1/1F/2F',
  status VARCHAR(16) NOT NULL DEFAULT 'FREE' COMMENT 'FREE/OCCUPIED/MAINTAIN',
  type VARCHAR(16) NOT NULL DEFAULT 'normal' COMMENT 'normal/electric'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- A区 B1 层 8 位
INSERT INTO t_space(space_no,area,floor,status,type) VALUES
('A-B1-01','A','B1','OCCUPIED','normal'),
('A-B1-02','A','B1','FREE','normal'),
('A-B1-03','A','B1','FREE','normal'),
('A-B1-04','A','B1','FREE','electric'),
('A-B1-05','A','B1','OCCUPIED','normal'),
('A-B1-06','A','B1','FREE','normal'),
('A-B1-07','A','B1','FREE','normal'),
('A-B1-08','A','B1','MAINTAIN','normal');
-- A区 1F 层 8 位
INSERT INTO t_space(space_no,area,floor,status,type) VALUES
('A-1F-01','A','1F','FREE','normal'),
('A-1F-02','A','1F','FREE','normal'),
('A-1F-03','A','1F','OCCUPIED','normal'),
('A-1F-04','A','1F','FREE','electric'),
('A-1F-05','A','1F','FREE','normal'),
('A-1F-06','A','1F','FREE','normal'),
('A-1F-07','A','1F','FREE','normal'),
('A-1F-08','A','1F','FREE','normal');
-- B区 1F 层 8 位
INSERT INTO t_space(space_no,area,floor,status,type) VALUES
('B-1F-01','B','1F','FREE','normal'),
('B-1F-02','B','1F','FREE','normal'),
('B-1F-03','B','1F','OCCUPIED','normal'),
('B-1F-04','B','1F','FREE','electric'),
('B-1F-05','B','1F','FREE','normal'),
('B-1F-06','B','1F','FREE','normal'),
('B-1F-07','B','1F','FREE','normal'),
('B-1F-08','B','1F','OCCUPIED','normal');
-- C区 2F 层 8 位
INSERT INTO t_space(space_no,area,floor,status,type) VALUES
('C-2F-01','C','2F','FREE','normal'),
('C-2F-02','C','2F','FREE','normal'),
('C-2F-03','C','2F','FREE','electric'),
('C-2F-04','C','2F','FREE','normal'),
('C-2F-05','C','2F','FREE','normal'),
('C-2F-06','C','2F','OCCUPIED','normal'),
('C-2F-07','C','2F','FREE','normal'),
('C-2F-08','C','2F','FREE','normal');

-- ---------- 费率规则 ----------
CREATE TABLE t_fee_rule (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  free_minutes INT DEFAULT 15 COMMENT '免费时长(分钟)',
  price_per_hour DECIMAL(10,2) DEFAULT 5.00 COMMENT '每小时费用(元)',
  day_max DECIMAL(10,2) DEFAULT 40.00 COMMENT '每日封顶(元)',
  remark VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO t_fee_rule(free_minutes,price_per_hour,day_max,remark) VALUES
(15,5.00,40.00,'入场15分钟内免费；超出后每小时5元；单日封顶40元');

-- ---------- 停车记录 ----------
CREATE TABLE t_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  plate_no VARCHAR(32) NOT NULL,
  space_no VARCHAR(32) NOT NULL,
  area VARCHAR(8),
  floor VARCHAR(8),
  entry_time DATETIME,
  exit_time DATETIME,
  duration_minutes INT,
  amount DECIMAL(10,2),
  status VARCHAR(16) NOT NULL DEFAULT 'PARKING' COMMENT 'PARKING/EXIT',
  pay_type VARCHAR(16) DEFAULT 'NONE' COMMENT 'NONE/MANUAL/AUTO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 在场记录
INSERT INTO t_record(plate_no,space_no,area,floor,entry_time,exit_time,duration_minutes,amount,status,pay_type) VALUES
('闽D12345','A-B1-01','A','B1','2026-10-24 08:20:00',NULL,NULL,NULL,'PARKING','NONE'),
('闽E88888','B-1F-03','B','1F','2026-10-24 10:15:00',NULL,NULL,NULL,'PARKING','NONE');

-- 已离场历史记录（近几日）
INSERT INTO t_record(plate_no,space_no,area,floor,entry_time,exit_time,duration_minutes,amount,status,pay_type) VALUES
('闽C66666','A-1F-03','A','1F','2026-10-23 09:00:00','2026-10-23 11:40:00',160,10.00,'EXIT','MANUAL'),
('闽D12345','C-2F-06','C','2F','2026-10-22 14:00:00','2026-10-22 17:30:00',210,15.00,'EXIT','AUTO'),
('闽F99999','B-1F-08','B','1F','2026-10-23 19:00:00','2026-10-23 20:10:00',70,5.00,'EXIT','MANUAL'),
('闽A55555','A-B1-05','A','B1','2026-10-21 08:30:00','2026-10-21 18:00:00',570,40.00,'EXIT','AUTO'),
('闽E88888','C-2F-06','C','2F','2026-10-20 11:00:00','2026-10-20 12:20:00',80,5.00,'EXIT','MANUAL');

-- ---------- 支付流水 ----------
CREATE TABLE t_payment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  record_id BIGINT,
  plate_no VARCHAR(32),
  amount DECIMAL(10,2),
  pay_type VARCHAR(16),
  pay_time DATETIME,
  status VARCHAR(16)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO t_payment(record_id,plate_no,amount,pay_type,pay_time,status) VALUES
(3,'闽C66666',10.00,'MANUAL','2026-10-23 11:40:00','SUCCESS'),
(4,'闽D12345',15.00,'AUTO','2026-10-22 17:30:00','SUCCESS'),
(5,'闽F99999',5.00,'MANUAL','2026-10-23 20:10:00','SUCCESS'),
(6,'闽A55555',40.00,'AUTO','2026-10-21 18:00:00','SUCCESS'),
(7,'闽E88888',5.00,'MANUAL','2026-10-20 12:20:00','SUCCESS');

-- ---------- 电子发票 ----------
CREATE TABLE t_invoice (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  record_id BIGINT,
  plate_no VARCHAR(32),
  amount DECIMAL(10,2),
  title VARCHAR(128),
  tax_no VARCHAR(64),
  invoice_no VARCHAR(64),
  create_time DATETIME,
  status VARCHAR(16)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO t_invoice(record_id,plate_no,amount,title,tax_no,invoice_no,create_time,status) VALUES
(4,'闽D12345',15.00,'张三个人','','INV20261022001','2026-10-22 17:35:00','已开具'),
(6,'闽A55555',40.00,'厦门科技有限公司','91350200MA1XXXX123','INV20261021002','2026-10-21 18:10:00','已开具');
