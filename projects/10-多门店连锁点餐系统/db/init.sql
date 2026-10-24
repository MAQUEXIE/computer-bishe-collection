-- ============================================================
-- 10-多门店连锁点餐系统  数据库初始化脚本
-- 库名: db_10_restaurant
-- 账号: admin/123456(总部)  store/123456(门店-万象城)  customer/123456(顾客)
-- ============================================================

DROP DATABASE IF EXISTS db_10_restaurant;
CREATE DATABASE db_10_restaurant DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_10_restaurant;

-- ---------- 用户 ----------
CREATE TABLE t_user (
  id BIGINT NOT NULL AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64),
  phone VARCHAR(32),
  role VARCHAR(20) NOT NULL COMMENT 'ADMIN总部/STORE门店/CUSTOMER顾客',
  store_id BIGINT NULL,
  status TINYINT DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 门店 ----------
CREATE TABLE t_store (
  id BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  address VARCHAR(256),
  phone VARCHAR(32),
  status TINYINT DEFAULT 1,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 总部统一菜品库 ----------
CREATE TABLE t_dish (
  id BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  category VARCHAR(32),
  price DECIMAL(10,2) NOT NULL,
  image VARCHAR(256),
  description VARCHAR(256),
  status TINYINT DEFAULT 1 COMMENT '1上架 0下架',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 门店菜品（门店从统一库选品） ----------
CREATE TABLE t_store_dish (
  id BIGINT NOT NULL AUTO_INCREMENT,
  store_id BIGINT NOT NULL,
  dish_id BIGINT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  available TINYINT DEFAULT 1 COMMENT '1在售 0售罄',
  PRIMARY KEY (id),
  UNIQUE KEY uk_store_dish (store_id, dish_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 订单 ----------
CREATE TABLE t_order (
  id BIGINT NOT NULL AUTO_INCREMENT,
  order_no VARCHAR(64) NOT NULL,
  user_id BIGINT NOT NULL,
  store_id BIGINT NOT NULL,
  order_type VARCHAR(20) NOT NULL COMMENT 'DINE_IN堂食/TAKEAWAY外卖',
  table_no VARCHAR(20),
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL COMMENT 'UNPAID/PAID/MAKING/SERVED/COMPLETED',
  call_no INT NULL,
  created_at DATETIME,
  paid_at DATETIME,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 订单明细 ----------
CREATE TABLE t_order_item (
  id BIGINT NOT NULL AUTO_INCREMENT,
  order_id BIGINT NOT NULL,
  dish_id BIGINT NOT NULL,
  dish_name VARCHAR(128),
  price DECIMAL(10,2),
  quantity INT,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 支付记录 ----------
CREATE TABLE t_payment (
  id BIGINT NOT NULL AUTO_INCREMENT,
  order_id BIGINT NOT NULL,
  order_no VARCHAR(64),
  amount DECIMAL(10,2),
  pay_method VARCHAR(20),
  status VARCHAR(20),
  paid_at DATETIME,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户账号
INSERT INTO t_user(username,password,nickname,phone,role,store_id,status) VALUES
('admin','123456','总部管理员','13900000000','ADMIN',NULL,1),
('store','123456','店长','13900000001','STORE',1,1),
('customer','123456','张三','13900000002','CUSTOMER',NULL,1);

-- 3 家门店
INSERT INTO t_store(name,address,phone,status) VALUES
('万象城旗舰店','漳州市龙文区万象城L5层','0596-2000001',1),
('中山路店','漳州市芗城区中山路88号','0596-2000002',1),
('西湖店','漳州市芗城区西湖公园正门旁','0596-2000003',1);

-- 统一菜品库 10 道菜
INSERT INTO t_dish(name,category,price,image,description,status) VALUES
('经典红烧肉','热菜',32.00,'/dishes/dish1.svg','肥而不腻，入口即化',1),
('宫保鸡丁','热菜',26.00,'/dishes/dish2.svg','糊辣荔枝味，下饭首选',1),
('麻婆豆腐','热菜',18.00,'/dishes/dish3.svg','麻辣鲜香，嫩烫酥',1),
('番茄炒蛋','热菜',14.00,'/dishes/dish4.svg','家常菜，酸甜可口',1),
('扬州炒饭','主食',16.00,'/dishes/dish5.svg','粒粒分明，配料丰富',1),
('牛肉拉面','主食',22.00,'/dishes/dish6.svg','汤浓面劲，牛肉大片',1),
('排骨米线','主食',20.00,'/dishes/dish7.svg','骨汤慢熬，米线爽滑',1),
('冰镇酸梅汤','饮品',6.00,'/dishes/dish8.svg','解腻解暑，冰镇畅饮',1),
('鲜榨橙汁','饮品',12.00,'/dishes/dish9.svg','当季鲜橙，无添加',1),
('紫菜蛋花汤','汤品',8.00,'/dishes/dish10.svg','清淡暖胃',1);

-- 门店菜品：万象城店(id=1) 选 8 道，价格微调
INSERT INTO t_store_dish(store_id,dish_id,price,available) VALUES
(1,1,32.00,1),(1,2,26.00,1),(1,3,18.00,1),(1,5,16.00,1),
(1,6,22.00,1),(1,8,6.00,1),(1,9,12.00,1),(1,10,8.00,1);
-- 中山路店(id=2) 选 6 道
INSERT INTO t_store_dish(store_id,dish_id,price,available) VALUES
(2,2,25.00,1),(2,3,18.00,1),(2,4,14.00,1),(2,5,15.00,1),
(2,8,6.00,1),(2,10,8.00,0);
-- 西湖店(id=3) 选 5 道
INSERT INTO t_store_dish(store_id,dish_id,price,available) VALUES
(3,1,33.00,1),(3,6,23.00,1),(3,7,20.00,1),(3,9,12.00,1),(3,4,14.00,1);

-- 演示订单（覆盖各状态，便于报表与接单演示）
-- 订单1：万象城 堂食 已完成
INSERT INTO t_order(order_no,user_id,store_id,order_type,table_no,total_amount,status,call_no,created_at,paid_at)
VALUES('R20261001001',3,1,'DINE_IN','A01',54.00,'COMPLETED',5,'2026-10-20 11:20:00','2026-10-20 11:21:00');
INSERT INTO t_order_item(order_id,dish_id,dish_name,price,quantity) VALUES
(1,1,'经典红烧肉',32.00,1),(1,8,'冰镇酸梅汤',6.00,1),(1,5,'扬州炒饭',16.00,1);
INSERT INTO t_payment(order_id,order_no,amount,pay_method,status,paid_at) VALUES
(1,'R20261001001',54.00,'WECHAT','SUCCESS','2026-10-20 11:21:00');

-- 订单2：中山路 外卖 已出餐
INSERT INTO t_order(order_no,user_id,store_id,order_type,table_no,total_amount,status,call_no,created_at,paid_at)
VALUES('R20261002002',3,2,'TAKEAWAY','',39.00,'SERVED',12,'2026-10-21 12:05:00','2026-10-21 12:06:00');
INSERT INTO t_order_item(order_id,dish_id,dish_name,price,quantity) VALUES
(2,2,'宫保鸡丁',25.00,1),(2,5,'扬州炒饭',15.00,1),(2,8,'冰镇酸梅汤',6.00,1);
INSERT INTO t_payment(order_id,order_no,amount,pay_method,status,paid_at) VALUES
(2,'R20261002002',39.00,'ALIPAY','SUCCESS','2026-10-21 12:06:00');

-- 订单3：西湖店 堂食 制作中
INSERT INTO t_order(order_no,user_id,store_id,order_type,table_no,total_amount,status,call_no,created_at,paid_at)
VALUES('R20261003003',3,3,'DINE_IN','B2',46.00,'MAKING',NULL,'2026-10-22 18:30:00','2026-10-22 18:31:00');
INSERT INTO t_order_item(order_id,dish_id,dish_name,price,quantity) VALUES
(3,6,'牛肉拉面',23.00,2);
INSERT INTO t_payment(order_id,order_no,amount,pay_method,status,paid_at) VALUES
(3,'R20261003003',46.00,'WECHAT','SUCCESS','2026-10-22 18:31:00');

-- 订单4：万象城 已支付待接单（供门店接单演示）
INSERT INTO t_order(order_no,user_id,store_id,order_type,table_no,total_amount,status,call_no,created_at,paid_at)
VALUES('R20261024004',3,1,'DINE_IN','A08',40.00,'PAID',NULL,'2026-10-24 12:00:00','2026-10-24 12:01:00');
INSERT INTO t_order_item(order_id,dish_id,dish_name,price,quantity) VALUES
(4,2,'宫保鸡丁',26.00,1),(4,9,'鲜榨橙汁',12.00,1),(4,10,'紫菜蛋花汤',8.00,1);
INSERT INTO t_payment(order_id,order_no,amount,pay_method,status,paid_at) VALUES
(4,'R20261024004',40.00,'WECHAT','SUCCESS','2026-10-24 12:01:00');
