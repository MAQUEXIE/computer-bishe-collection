-- ============================================================
-- 02 社区团购系统 数据库初始化脚本
-- DB: db_02_group_buy (utf8mb4)
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_02_group_buy DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_02_group_buy;

-- ---------- 用户表 ----------
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  role VARCHAR(20) NOT NULL COMMENT 'ADMIN/LEADER/RESIDENT/SUPPLIER',
  real_name VARCHAR(64),
  phone VARCHAR(20),
  status TINYINT DEFAULT 1 COMMENT '1启用 0禁用',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ---------- 供应商 ----------
DROP TABLE IF EXISTS supplier;
CREATE TABLE supplier (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  company_name VARCHAR(128) NOT NULL,
  contact_phone VARCHAR(20),
  address VARCHAR(255),
  status VARCHAR(20) DEFAULT 'pending' COMMENT 'pending/approved/rejected',
  remark VARCHAR(255),
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商';

-- ---------- 团长资料 ----------
DROP TABLE IF EXISTS leader_profile;
CREATE TABLE leader_profile (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  community_name VARCHAR(128) NOT NULL,
  pickup_addr VARCHAR(255),
  phone VARCHAR(20),
  status VARCHAR(20) DEFAULT 'pending' COMMENT 'pending/approved/rejected',
  remark VARCHAR(255),
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='团长资料';

-- ---------- 商品 ----------
DROP TABLE IF EXISTS product;
CREATE TABLE product (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  category VARCHAR(64),
  image VARCHAR(255),
  base_price DECIMAL(10,2) NOT NULL,
  stock INT DEFAULT 0,
  description VARCHAR(500),
  supplier_id BIGINT,
  status TINYINT DEFAULT 1 COMMENT '1上架 0下架',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品';

-- ---------- 团（开团） ----------
DROP TABLE IF EXISTS group_buy;
CREATE TABLE group_buy (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  product_id BIGINT NOT NULL,
  leader_id BIGINT NOT NULL COMMENT '团长 user_id',
  title VARCHAR(255) NOT NULL,
  target_people INT DEFAULT 5 COMMENT '成团目标人数',
  current_count INT DEFAULT 0 COMMENT '当前已参团件数',
  end_time DATETIME NOT NULL,
  status VARCHAR(20) DEFAULT 'open' COMMENT 'open/closed/completed',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='团';

-- ---------- 阶梯价 ----------
DROP TABLE IF EXISTS group_tier;
CREATE TABLE group_tier (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  group_id BIGINT NOT NULL,
  min_count INT NOT NULL COMMENT '达到N件',
  price DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='阶梯价';

-- ---------- 提货点 ----------
DROP TABLE IF EXISTS pickup_point;
CREATE TABLE pickup_point (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  leader_id BIGINT NOT NULL,
  name VARCHAR(128) NOT NULL,
  address VARCHAR(255),
  contact_phone VARCHAR(20),
  community_name VARCHAR(128),
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提货点';

-- ---------- 社群 ----------
DROP TABLE IF EXISTS community;
CREATE TABLE community (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  leader_id BIGINT NOT NULL,
  name VARCHAR(128) NOT NULL,
  member_count INT DEFAULT 0,
  notice VARCHAR(500),
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社群';

-- ---------- 订单 ----------
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_no VARCHAR(64) NOT NULL UNIQUE,
  resident_id BIGINT NOT NULL,
  group_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  pickup_point_id BIGINT,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending_paid'
    COMMENT 'pending_paid/paid/picked/completed/after_sale/refunded/canceled',
  pay_time DATETIME NULL,
  pickup_time DATETIME NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单';

-- ---------- 佣金流水 ----------
DROP TABLE IF EXISTS commission;
CREATE TABLE commission (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  leader_id BIGINT NOT NULL,
  group_id BIGINT NOT NULL,
  order_id BIGINT,
  order_amount DECIMAL(10,2) NOT NULL,
  rate DECIMAL(5,2) NOT NULL DEFAULT 10.00 COMMENT '佣金率%',
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' COMMENT 'pending/settled',
  settle_time DATETIME NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='佣金流水';

-- ---------- 售后申请 ----------
DROP TABLE IF EXISTS after_sale;
CREATE TABLE after_sale (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id BIGINT NOT NULL,
  resident_id BIGINT NOT NULL,
  reason VARCHAR(500) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' COMMENT 'pending/approved/rejected/resolved',
  remark VARCHAR(500),
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  handle_time DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='售后申请';

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户：admin / resident / leader / supplier（密码均 123456，明文演示）
INSERT INTO sys_user(username,password,role,real_name,phone,status) VALUES
('admin','123456','ADMIN','系统管理员','13800000001',1),
('resident','123456','RESIDENT','张居民','13900000002',1),
('resident2','123456','RESIDENT','李居民','13900000003',1),
('leader','123456','LEADER','王团长','13700000004',1),
('leader_pending','123456','LEADER','赵团长（待审）','13700000005',1),
('supplier','123456','SUPPLIER','新鲜优选','13600000006',1),
('supplier_pending','123456','SUPPLIER','田园直供','13600000007',1);

-- 供应商审核状态
INSERT INTO supplier(user_id,company_name,contact_phone,address,status,remark) VALUES
(6,'新鲜优选蔬菜供应','13600000006','XX市农产品批发市场A区12号','approved','资质齐全'),
(7,'田园直供农业','13600000007','XX市郊区蔬菜基地','pending','等待审核');

-- 团长资料
INSERT INTO leader_profile(user_id,community_name,pickup_addr,phone,status,remark) VALUES
(4,'阳光花园社区','阳光花园3栋1单元101室','13700000004','approved','已审核通过'),
(5,'翠湖名邸','翠湖名邸快递驿站旁','13700000005','pending','等待审核');

-- 商品（≥5 个）
INSERT INTO product(name,category,image,base_price,stock,description,supplier_id,status) VALUES
('有机番茄 500g','蔬菜','/images/product/tomato.png',12.00,200,'沙瓤多汁，自然成熟，当日采摘',1,1),
('散养土鸡蛋 30枚','禽蛋','/images/product/egg.png',35.00,300,'农家散养，蛋黄橙红，现捡现发',1,1),
('农家小白菜 500g','蔬菜','/images/product/cabbage.png',6.00,500,'露天种植，鲜嫩无农药',1,1),
('东北珍珠米 5kg','粮油','/images/product/rice.png',45.00,150,'当年新米，颗粒饱满',1,1),
('红颜草莓 500g','水果','/images/product/strawberry.png',28.00,100,'奶油草莓，现摘现发',1,1),
('散养土鸡 1只','禽肉','/images/product/chicken.png',68.00,80,'林下散养180天',1,1);

-- 提货点（团长）
INSERT INTO pickup_point(leader_id,name,address,contact_phone,community_name) VALUES
(4,'阳光花园自提点','阳光花园3栋1单元101室（王团长家）','13700000004','阳光花园社区');

-- 社群
INSERT INTO community(leader_id,name,member_count,notice) VALUES
(4,'阳光花园团购1群',128,'每周二、周五开团，次日下午4点后到点自提');

-- 团（≥2 个进行中）
INSERT INTO group_buy(product_id,leader_id,title,target_people,current_count,end_time,status) VALUES
(1,4,'【当日采摘】有机番茄 500g 拼团特惠',5,2,'2026-10-26 18:00:00','open'),
(2,4,'【农家直供】散养土鸡蛋30枚 成团更低价',10,3,'2026-10-26 20:00:00','open'),
(5,4,'【奶油草莓】红颜草莓500g 限时拼团',8,0,'2026-10-27 18:00:00','open'),
(4,4,'【东北新米】珍珠米5kg 上次爆款返场',10,12,'2026-10-20 18:00:00','completed');

-- 阶梯价
INSERT INTO group_tier(group_id,min_count,price) VALUES
(1,1,12.00),(1,3,10.00),(1,5,8.00),
(2,1,25.00),(2,6,22.00),(2,11,20.00),
(3,1,32.00),(3,4,30.00),(3,8,28.00),
(4,1,48.00),(4,6,46.00),(4,11,45.00);

-- 演示订单（居民 resident）
INSERT INTO orders(order_no,resident_id,group_id,product_id,pickup_point_id,quantity,unit_price,total_amount,status,pay_time,create_time) VALUES
('GB20261020001',2,4,4,1,2,45.00,90.00,'completed','2026-10-19 10:00:00','2026-10-19 09:30:00'),
('GB20261021001',2,2,2,1,1,25.00,25.00,'paid','2026-10-21 11:00:00','2026-10-21 10:50:00');

-- 佣金流水（成团自动结算演示）
INSERT INTO commission(leader_id,group_id,order_id,order_amount,rate,amount,status,settle_time) VALUES
(4,4,1,90.00,10.00,9.00,'settled','2026-10-21 09:00:00'),
(4,2,2,25.00,10.00,2.50,'pending',NULL);

-- 一条售后演示（已完成的那条被申请售后）
INSERT INTO after_sale(order_id,resident_id,reason,status,remark,handle_time) VALUES
(1,2,'东北米有一小袋漏气，希望补发或退款','resolved','已补发新米一袋','2026-10-21 09:30:00');
