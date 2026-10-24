-- ============================================================
-- 19 快递驿站管理系统 数据库初始化脚本
-- 库名: db_19_express  utf8mb4
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_19_express DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_19_express;

-- ---------------- 用户表 ----------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  nickname VARCHAR(50),
  phone VARCHAR(20),
  role VARCHAR(20) NOT NULL COMMENT 'USER 用户 / STATION 站长快递员 / ADMIN 管理员',
  station_id BIGINT DEFAULT 0,
  status INT DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 驿站表 ----------------
DROP TABLE IF EXISTS t_station;
CREATE TABLE t_station (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200),
  phone VARCHAR(20),
  manager VARCHAR(50),
  status INT DEFAULT 1 COMMENT '1 营业 0 停业',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 包裹（代收件）表 ----------------
DROP TABLE IF EXISTS t_package;
CREATE TABLE t_package (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  waybill_no VARCHAR(50) NOT NULL COMMENT '运单号',
  company VARCHAR(50) COMMENT '快递公司',
  sender_name VARCHAR(50),
  sender_phone VARCHAR(20),
  receiver_name VARCHAR(50),
  receiver_phone VARCHAR(20),
  station_id BIGINT,
  pickup_code VARCHAR(20) COMMENT '取件码',
  status VARCHAR(20) DEFAULT 'IN_STOCK' COMMENT 'IN_STOCK 在库待取 / STAYED 滞留 / ABNORMAL 异常 / RETURNED 已退件 / PICKED_UP 已签收',
  abnormal_type VARCHAR(50) COMMENT '异常类型: 破损/无人认领/拒收/错分',
  abnormal_remark VARCHAR(255),
  collect_confirm INT DEFAULT 0 COMMENT '代收确认 0未确认 1已确认',
  storage_time DATETIME COMMENT '入库时间',
  pickup_time DATETIME NULL COMMENT '签收出库时间',
  remark VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 寄件订单表 ----------------
DROP TABLE IF EXISTS t_send_order;
CREATE TABLE t_send_order (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_no VARCHAR(50) NOT NULL,
  user_id BIGINT,
  station_id BIGINT,
  sender_name VARCHAR(50),
  sender_phone VARCHAR(20),
  sender_addr VARCHAR(200),
  receiver_name VARCHAR(50),
  receiver_phone VARCHAR(20),
  receiver_addr VARCHAR(200),
  company VARCHAR(50),
  weight DECIMAL(10,2) DEFAULT 0,
  fee DECIMAL(10,2) DEFAULT 0,
  status VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING 待受理 / ACCEPTED 已受理 / SHIPPED 已寄出 / CANCELLED 已取消',
  remark VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  accept_time DATETIME NULL,
  ship_time DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 站内通知表（取件码通知/滞留提醒） ----------------
DROP TABLE IF EXISTS t_notice;
CREATE TABLE t_notice (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT,
  title VARCHAR(100),
  content VARCHAR(500),
  type VARCHAR(30) COMMENT 'PICKUP_CODE 取件码通知 / STAY 滞留提醒 / ABNORMAL 异常通知',
  is_read INT DEFAULT 0,
  ref_id BIGINT COMMENT '关联包裹ID',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 费用流水表 ----------------
DROP TABLE IF EXISTS t_fee_flow;
CREATE TABLE t_fee_flow (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  station_id BIGINT,
  type VARCHAR(30) COMMENT 'SEND_FEE 寄件收入 / STORAGE_FEE 滞留服务费 / PENALTY 罚款',
  amount DECIMAL(10,2) DEFAULT 0,
  biz_no VARCHAR(50),
  remark VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户：admin/123456 管理员；station/123456 站长；user/123456 用户(张三)
INSERT INTO t_user(username,password,nickname,phone,role,station_id,status) VALUES
('admin','123456','系统管理员','13900000000','ADMIN',0,1),
('station','123456','李站长','13900000001','STATION',1,1),
('user','123456','张三','13800000001','USER',0,1);

-- 驿站
INSERT INTO t_station(name,address,phone,manager,status) VALUES
('阳光小区驿站','阳光小区东门商铺101','0596-8200001','李站长',1),
('幸福里驿站','幸福里北门商业街8号','0596-8200002','王店长',1);

-- 包裹（≥12个，含在库/滞留/异常/已签收多种状态；用户张三手机 13800000001）
INSERT INTO t_package(waybill_no,company,sender_name,sender_phone,receiver_name,receiver_phone,station_id,pickup_code,status,abnormal_type,abnormal_remark,collect_confirm,storage_time,pickup_time,remark) VALUES
('SF10245001','顺丰速运','广州白云电商仓','18602011001','张三','13800000001',1,'A1-101','IN_STOCK',NULL,NULL,0,NOW() - INTERVAL 2 HOUR,NULL,'生鲜保鲜箱'),
('YT10246002','圆通速递','杭州西湖服饰店','18602011002','张三','13800000001',1,'A1-102','IN_STOCK',NULL,NULL,0,NOW() - INTERVAL 5 HOUR,NULL,'冬季外套'),
('ZT10247003','中通快递','义乌小商品城','18602011003','张三','13800000001',1,'B2-201','STAYED',NULL,NULL,0,NOW() - INTERVAL 6 DAY,NULL,'超3天未取，已滞留'),
('JD10248004','京东物流','苏州五金机电城','18602011004','张三','13800000001',1,'B2-202','ABNORMAL','破损','外包装挤压变形，内件待用户确认',0,NOW() - INTERVAL 2 DAY,NULL,'已拍照留证'),
('STO10249005','申通快递','深圳华强北','18602011005','张三','13800000001',1,'C3-301','PICKED_UP',NULL,NULL,1,NOW() - INTERVAL 3 DAY,NOW() - INTERVAL 1 DAY,'已本人签收'),
('EMS1025006','邮政EMS','上海浦东新区','18602011006','李四','13900000002',1,'C3-302','IN_STOCK',NULL,NULL,0,NOW() - INTERVAL 1 HOUR,NULL, NULL),
('JT10251007','极兔速递','成都武侯数码城','18602011007','李四','13900000002',1,'D1-401','IN_STOCK',NULL,NULL,0,NOW() - INTERVAL 8 HOUR,NULL, NULL),
('DB10252008','德邦快递','佛山家具厂','18602011008','王五','13700000003',2,'E2-501','STAYED',NULL,NULL,0,NOW() - INTERVAL 8 DAY,NULL,'大件家具，超期滞留'),
('SF10253009','顺丰速运','宁波北仑文具厂','18602011009','王五','13700000003',2,'E2-502','ABNORMAL','拒收','收件人电话拒接后拒收，等待退回发件方',0,NOW() - INTERVAL 4 DAY,NULL, NULL),
('YT10254010','圆通速递','南京江宁食品园','18602011010','赵六','13600000004',2,'F1-601','PICKED_UP',NULL,NULL,1,NOW() - INTERVAL 5 DAY,NOW() - INTERVAL 2 DAY,'家人代取'),
('ZT10255011','中通快递','武汉汉正街','18602011011','赵六','13600000004',2,'F1-602','IN_STOCK',NULL,NULL,0,NOW() - INTERVAL 3 HOUR,NULL, NULL),
('JD10256012','京东物流','北京中关村','18602011012','孙七','13500000005',1,'G3-701','STAYED',NULL,NULL,0,NOW() - INTERVAL 10 DAY,NULL,'长期无人认领'),
('STO10257013','申通快递','厦门同安食品厂','18602011013','孙七','13500000005',1,'G3-702','IN_STOCK',NULL,NULL,0,NOW() - INTERVAL 6 HOUR,NULL,'闽南特产');

-- 寄件订单
INSERT INTO t_send_order(order_no,user_id,station_id,sender_name,sender_phone,sender_addr,receiver_name,receiver_phone,receiver_addr,company,weight,fee,status,remark,created_at,accept_time,ship_time) VALUES
('SO20261024001',3,1,'张三','13800000001','阳光小区3栋502','刘女士','13100000001','北京市海淀区中关村大街1号','顺丰速运',1.50,0,'PENDING','文件资料',NOW() - INTERVAL 30 MINUTE,NULL,NULL),
('SO20261023002',3,1,'张三','13800000001','阳光小区3栋502','陈先生','13200000002','上海市浦东新区陆家嘴环路1000号','中通快递',3.00,12.00,'ACCEPTED','特产一箱',NOW() - INTERVAL 5 HOUR,NOW() - INTERVAL 4 HOUR,NULL),
('SO20261020003',NULL,2,'周先生','13300000003','幸福里9栋201','吴女士','13400000004','广州市天河区体育西路103号','圆通速递',2.00,15.00,'SHIPPED',NULL,NOW() - INTERVAL 4 DAY,NOW() - INTERVAL 3 DAY,NOW() - INTERVAL 2 DAY);

-- 站内通知（取件码通知 + 滞留提醒）
INSERT INTO t_notice(user_id,title,content,type,is_read,ref_id,created_at) VALUES
(3,'取件码通知：您有包裹到达','您的顺丰速运包裹已到达阳光小区驿站，取件码 A1-101，请凭取件码取件。','PICKUP_CODE',0,1,NOW() - INTERVAL 2 HOUR),
(3,'取件码通知：您有包裹到达','您的圆通速递包裹已到达阳光小区驿站，取件码 A1-102，请凭取件码取件。','PICKUP_CODE',0,2,NOW() - INTERVAL 5 HOUR),
(3,'滞留提醒：包裹已超期未取','您的中通快递包裹（取件码 B2-201）入库已超过3天，请尽快到阳光小区驿站取件，超期将收取滞留服务费。','STAY',0,3,NOW() - INTERVAL 1 DAY);

-- 费用流水
INSERT INTO t_fee_flow(station_id,type,amount,biz_no,remark,created_at) VALUES
(1,'SEND_FEE',12.00,'SO20261023002','寄件受理收入-中通3kg',NOW() - INTERVAL 4 HOUR),
(1,'STORAGE_FEE',5.00,'PKG-B2-201','滞留服务费-包裹超期保管',NOW() - INTERVAL 1 DAY),
(2,'SEND_FEE',15.00,'SO20261020003','寄件收入-圆通2kg',NOW() - INTERVAL 3 DAY),
(2,'PENALTY',3.00,'PKG-E2-502','拒收件退回罚款',NOW() - INTERVAL 2 DAY);
