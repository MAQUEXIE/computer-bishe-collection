-- ============================================================
-- 21-供应链采购系统 初始化脚本
-- 库: db_21_supply (utf8mb4)
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_21_supply DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_21_supply;

DROP TABLE IF EXISTS t_evaluate;
DROP TABLE IF EXISTS t_payment;
DROP TABLE IF EXISTS t_receipt;
DROP TABLE IF EXISTS t_order;
DROP TABLE IF EXISTS t_inquiry;
DROP TABLE IF EXISTS t_demand;
DROP TABLE IF EXISTS t_price;
DROP TABLE IF EXISTS t_material;
DROP TABLE IF EXISTS t_supplier;
DROP TABLE IF EXISTS t_user;

-- ---------- 用户 ----------
CREATE TABLE t_user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64),
  phone VARCHAR(32),
  role VARCHAR(16) NOT NULL,           -- ADMIN/BUYER/SUPPLIER/WAREHOUSE
  status INT DEFAULT 1,                -- 0待审核 1正常 2拒绝
  supplier_id BIGINT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 供应商 ----------
CREATE TABLE t_supplier (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(128) NOT NULL UNIQUE,
  contact VARCHAR(64),
  phone VARCHAR(32),
  address VARCHAR(255),
  status INT DEFAULT 0,                -- 0待审核 1合格 2淘汰
  score_price DECIMAL(5,1) DEFAULT 80,
  score_quality DECIMAL(5,1) DEFAULT 80,
  score_delivery DECIMAL(5,1) DEFAULT 80,
  total_score DECIMAL(5,1) DEFAULT 80,
  order_count INT DEFAULT 0,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 物料目录 ----------
CREATE TABLE t_material (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(32) NOT NULL UNIQUE,
  name VARCHAR(128) NOT NULL,
  spec VARCHAR(128),
  category VARCHAR(64),
  unit VARCHAR(16)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 价格库 ----------
CREATE TABLE t_price (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  material_id BIGINT NOT NULL,
  supplier_id BIGINT NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_mat_sup (material_id, supplier_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 采购需求 ----------
CREATE TABLE t_demand (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  demand_no VARCHAR(32) NOT NULL UNIQUE,
  material_id BIGINT NOT NULL,
  qty INT NOT NULL,
  reason VARCHAR(255),
  applicant VARCHAR(64),
  status VARCHAR(16) DEFAULT 'PENDING',  -- PENDING待询价/INQUIRING询价中/ORDERED已下单/CLOSED已关闭
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 询价记录 ----------
CREATE TABLE t_inquiry (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  demand_id BIGINT NOT NULL,
  material_id BIGINT NOT NULL,
  supplier_id BIGINT NOT NULL,
  quoted_price DECIMAL(12,2) NULL,
  note VARCHAR(255),
  status VARCHAR(16) DEFAULT 'WAIT',     -- WAIT待报价/QUOTED已报价/ADOPTED已采纳/LOST已落选
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  quote_time DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 采购订单 ----------
CREATE TABLE t_order (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_no VARCHAR(32) NOT NULL UNIQUE,
  demand_id BIGINT NULL,
  material_id BIGINT NOT NULL,
  supplier_id BIGINT NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  qty INT NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  status VARCHAR(16) DEFAULT 'WAIT_SHIP', -- WAIT_SHIP待发货/SHIPPED已发货/ACCEPTED已验收/STOCKED已入库/CLOSED
  buyer VARCHAR(64),
  expect_date DATE NULL,
  ship_time DATETIME NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 到货验收/入库记录 ----------
CREATE TABLE t_receipt (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  recv_qty INT NOT NULL,
  quality_score INT,
  note VARCHAR(255),
  receiver VARCHAR(64),
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 付款对账 ----------
CREATE TABLE t_payment (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  supplier_id BIGINT NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  status VARCHAR(16) DEFAULT 'WAIT',      -- WAIT待付款/PAID已付款
  pay_time DATETIME NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 供应商评价 ----------
CREATE TABLE t_evaluate (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  supplier_id BIGINT NOT NULL,
  order_id BIGINT NULL,
  price_score INT,
  quality_score INT,
  delivery_score INT,
  comment VARCHAR(255),
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 初始数据
-- ============================================================

-- 用户账号
INSERT INTO t_user(username,password,nickname,phone,role,status,supplier_id) VALUES
('admin','123456','系统管理员','13900000001','ADMIN',1,NULL),
('buyer','123456','采购员小王','13900000002','BUYER',1,NULL),
('warehouse','123456','仓管老周','13900000003','WAREHOUSE',1,NULL),
('supplier','123456','华原钢铁-王建国','13800001111','SUPPLIER',1,1);

-- 供应商（4家，均合格）
INSERT INTO t_supplier(name,contact,phone,address,status,score_price,score_quality,score_delivery,total_score,order_count) VALUES
('华原钢铁有限公司','王建国','13800001111','上海市宝山区友谊路100号',1,86.0,88.5,84.0,86.2,1),
('顺达电子科技','李娜','13800002222','苏州市工业园区星湖街328号',1,90.5,92.0,89.0,90.5,0),
('精诚五金制品','张伟','13800003333','宁波市北仑区大港工业城',1,78.5,80.0,76.5,78.3,1),
('恒信包装材料','陈静','13800004444','东莞市虎门镇怀德社区',1,82.0,85.0,88.0,85.0,0);

-- 物料目录（10种）
INSERT INTO t_material(code,name,spec,category,unit) VALUES
('WL-001','热轧钢板','Q235 2.0mm','金属材料','张'),
('WL-002','不锈钢管','304 DN50','金属材料','米'),
('WL-003','铜芯电缆','YJV-3x95','电气材料','米'),
('WL-004','六角螺栓','M12x50 8.8级','五金件','盒'),
('WL-005','深沟球轴承','6204-2RS','机械件','套'),
('WL-006','LED驱动电源','24V5A 120W','电气件','个'),
('WL-007','五层瓦楞纸箱','400x300x300','包装','个'),
('WL-008','气泡膜','宽50cm 加厚','包装','卷'),
('WL-009','三相异步电机','1.5kW 4级 B5','机械件','台'),
('WL-010','铝型材','4040欧标','型材','根');

-- 价格库（多供应商同品报价）
INSERT INTO t_price(material_id,supplier_id,price) VALUES
(1,1,420.50),(1,3,405.00),
(2,1,88.00),(2,3,92.50),
(3,1,68.50),(3,2,65.00),
(4,3,12.50),(4,2,13.80),
(5,3,22.00),(5,2,24.50),
(6,2,35.00),
(7,4,3.20),(7,3,3.45),(7,2,3.60),
(8,4,28.00),(8,3,30.50),
(9,1,655.00),(9,2,620.00),
(10,1,55.00),(10,3,58.50);

-- 采购需求
INSERT INTO t_demand(demand_no,material_id,qty,reason,applicant,status,create_time) VALUES
('XD2026001',4,100,'产线维修紧固件备用库存补充','采购员小王','ORDERED',NOW() - INTERVAL 7 DAY),
('XD2026002',7,500,'新批次产品外包装箱采购','采购员小王','INQUIRING',NOW() - INTERVAL 2 DAY),
('XD2026003',9,10,'车间风机更新改造项目','采购员小王','PENDING',NOW() - INTERVAL 1 HOUR);

-- 询价记录：XD2026002 四家供应商已报价
INSERT INTO t_inquiry(demand_id,material_id,supplier_id,quoted_price,note,status,create_time,quote_time) VALUES
(2,7,1,3.30,'含运费送到厂','QUOTED',NOW() - INTERVAL 2 DAY,NOW() - INTERVAL 1 DAY),
(2,7,2,3.60,'标准价，量大可再谈','QUOTED',NOW() - INTERVAL 2 DAY,NOW() - INTERVAL 1 DAY),
(2,7,3,3.45,'交期3天','QUOTED',NOW() - INTERVAL 2 DAY,NOW() - INTERVAL 20 HOUR),
(2,7,4,3.25,'本厂直供，交期2天','QUOTED',NOW() - INTERVAL 2 DAY,NOW() - INTERVAL 18 HOUR);

-- 历史采购订单：A 电机5台 s1 已入库
INSERT INTO t_order(order_no,demand_id,material_id,supplier_id,price,qty,amount,status,buyer,expect_date,ship_time,create_time) VALUES
('PO2026001',NULL,9,1,655.00,5,3275.00,'STOCKED','采购员小王',DATE(NOW()-INTERVAL 5 DAY),NOW()-INTERVAL 9 DAY,NOW()-INTERVAL 10 DAY),
-- B 螺栓100 s3 已入库
('PO2026002',1,4,3,12.50,100,1250.00,'STOCKED','采购员小王',DATE(NOW()-INTERVAL 4 DAY),NOW()-INTERVAL 6 DAY,NOW()-INTERVAL 7 DAY),
-- C LED电源20 s2 已发货在途（待仓库验收）
('PO2026003',NULL,6,2,35.00,20,700.00,'SHIPPED','采购员小王',DATE(NOW()-INTERVAL 1 DAY),NOW()-INTERVAL 1 DAY,NOW()-INTERVAL 3 DAY);

-- 验收记录
INSERT INTO t_receipt(order_id,recv_qty,quality_score,note,receiver,create_time) VALUES
(1,5,92,'外观完好，试机正常','仓管老周',NOW()-INTERVAL 8 DAY),
(2,100,90,'数量核对无误','仓管老周',NOW()-INTERVAL 5 DAY);

-- 供应商历史评价
INSERT INTO t_evaluate(supplier_id,order_id,price_score,quality_score,delivery_score,comment,create_time) VALUES
(1,1,88,92,85,'价格适中，送货及时',NOW()-INTERVAL 8 DAY),
(3,2,78,80,76,'包装一般，略有磕碰',NOW()-INTERVAL 5 DAY);

-- 付款记录
INSERT INTO t_payment(order_id,supplier_id,amount,status,pay_time,create_time) VALUES
(1,1,3275.00,'PAID',NOW()-INTERVAL 7 DAY,NOW()-INTERVAL 10 DAY),
(2,3,1250.00,'PAID',NOW()-INTERVAL 4 DAY,NOW()-INTERVAL 7 DAY),
(3,2,700.00,'WAIT',NULL,NOW()-INTERVAL 3 DAY);
