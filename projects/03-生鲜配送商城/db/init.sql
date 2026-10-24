-- ============================================================
-- 03 生鲜配送商城 数据库初始化脚本
-- 库名: db_03_fresh_delivery  (utf8mb4)
-- 账号: admin/123456  user/123456  merchant/123456  rider/123456
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_03_fresh_delivery DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_03_fresh_delivery;

-- ----------------------------
-- 用户表（用户/商家/骑手/管理员 统一账号）
-- ----------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '登录名',
  password    VARCHAR(50)  NOT NULL COMMENT '密码(演示明文)',
  nickname    VARCHAR(50)  COMMENT '昵称/店名/骑手名',
  phone       VARCHAR(20)  COMMENT '手机号',
  address     VARCHAR(200) COMMENT '收货地址(用户)/店铺地址(商家)',
  role        VARCHAR(20)  NOT NULL COMMENT 'CUSTOMER/MERCHANT/RIDER/ADMIN',
  status      INT          NOT NULL DEFAULT 1 COMMENT '0=待审核 1=正常 2=拒绝',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户账号表';

-- ----------------------------
-- 商品分类
-- ----------------------------
DROP TABLE IF EXISTS t_category;
CREATE TABLE t_category (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 商品
-- ----------------------------
DROP TABLE IF EXISTS t_product;
CREATE TABLE t_product (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  merchant_id BIGINT      NOT NULL COMMENT '所属商家',
  category_id BIGINT      NOT NULL,
  name        VARCHAR(100) NOT NULL,
  description VARCHAR(500),
  price       DECIMAL(10,2) NOT NULL,
  stock       INT          NOT NULL DEFAULT 0,
  unit        VARCHAR(20)  DEFAULT '份',
  image       VARCHAR(200),
  sales       INT          DEFAULT 0,
  status      INT          DEFAULT 1 COMMENT '1=上架 0=下架',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 订单主表（配送状态机）
--   WAIT_MERCHANT 待商家接单
--   PREPARING     商家备货中
--   WAIT_RIDER    商家备货完成，进入骑手抢单池
--   TAKEN         骑手已抢单，待取货
--   DELIVERING    骑手已取货，配送中
--   DONE          已送达完成
--   EXCEPTION     异常订单(管理员处理)
--   CANCELLED     已取消
-- ----------------------------
DROP TABLE IF EXISTS t_order;
CREATE TABLE t_order (
  id               BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_no         VARCHAR(32) NOT NULL UNIQUE,
  user_id          BIGINT   NOT NULL,
  merchant_id      BIGINT   NOT NULL,
  rider_id         BIGINT   DEFAULT NULL,
  total_amount     DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '商品总额',
  freight          DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '运费',
  pay_amount       DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '实付=总额+运费',
  receiver_name    VARCHAR(50),
  receiver_phone   VARCHAR(20),
  receiver_address VARCHAR(200),
  remark           VARCHAR(200),
  status           VARCHAR(20) NOT NULL DEFAULT 'WAIT_MERCHANT',
  created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
  accept_at        DATETIME NULL COMMENT '商家接单时间',
  prepare_at       DATETIME NULL COMMENT '备货完成时间',
  taken_at         DATETIME NULL COMMENT '骑手抢单时间',
  picked_at        DATETIME NULL COMMENT '骑手取货时间',
  delivered_at     DATETIME NULL COMMENT '送达时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 订单明细
-- ----------------------------
DROP TABLE IF EXISTS t_order_item;
CREATE TABLE t_order_item (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id     BIGINT NOT NULL,
  product_id   BIGINT NOT NULL,
  product_name VARCHAR(100),
  product_image VARCHAR(200),
  price        DECIMAL(10,2),
  quantity     INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 评价
-- ----------------------------
DROP TABLE IF EXISTS t_review;
CREATE TABLE t_review (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id    BIGINT NOT NULL,
  user_id     BIGINT NOT NULL,
  merchant_id BIGINT NOT NULL,
  rating      INT NOT NULL DEFAULT 5 COMMENT '1-5星',
  content     VARCHAR(500),
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 骑手配送收入（送达时生成）
-- ----------------------------
DROP TABLE IF EXISTS t_rider_income;
CREATE TABLE t_rider_income (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  rider_id    BIGINT NOT NULL,
  order_id    BIGINT NOT NULL,
  order_no    VARCHAR(32),
  amount      DECIMAL(10,2) NOT NULL COMMENT '配送费收入',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 初始化数据
-- ============================================================

-- 账号：admin / user / merchant / rider + 两个待审核演示账号
INSERT INTO t_user (id, username, password, nickname, phone, address, role, status) VALUES
(1, 'admin',    '123456', '平台管理员', '13800000000', '平台运营中心',   'ADMIN',    1),
(2, 'user',     '123456', '张小明',     '13911112222', '漳州市芗城区胜利路88号幸福小区3栋502', 'CUSTOMER', 1),
(3, 'merchant', '123456', '鲜丰蔬果直营店', '13733334444', '漳州市芗城区农贸市场A区12号', 'MERCHANT', 1),
(4, 'rider',    '123456', '骑手小王',   '13655556666', '漳州市龙文区',   'RIDER',    1),
(5, 'newmerchant', '123456', '绿源精品肉铺', '13566667777', '漳州市龙文区肉品市场B区3号', 'MERCHANT', 0),
(6, 'newrider', '123456', '骑手小李',   '13588889999', '漳州市芗城区',   'RIDER',    0);

-- 分类
INSERT INTO t_category (id, name) VALUES (1,'新鲜蔬菜'),(2,'时令水果'),(3,'肉禽蛋品'),(4,'海鲜水产'),(5,'乳品烘焙');

-- 商品（image 为项目内 SVG 图片，frontend/public/images/products/）
INSERT INTO t_product (id, merchant_id, category_id, name, description, price, stock, unit, image, sales, status) VALUES
(1, 3, 1, '有机上海青', '当季有机种植，叶片鲜嫩，清晨直采', 5.90, 200, '500g/份', '/images/products/vegetable1.svg', 356, 1),
(2, 3, 1, '本地小番茄', '千禧小番茄，酸甜多汁，生吃首选', 8.80, 150, '500g/份', '/images/products/tomato.svg', 521, 1),
(3, 3, 2, '海南贵妃芒果', '树上熟贵妃芒，核薄肉厚，香甜多汁', 15.90, 80, '1.5kg/份', '/images/products/mango.svg', 432, 1),
(4, 3, 2, '阳光玫瑰葡萄', '无籽脆甜，玫瑰香气，冷链直达', 29.90, 60, '1kg/份', '/images/products/grape.svg', 289, 1),
(5, 3, 3, '农家土鸡蛋', '散养土鸡蛋，谷物喂养，蛋黄橙红', 12.50, 300, '30枚/板', '/images/products/egg.svg', 674, 1),
(6, 3, 3, '冷鲜猪前腿肉', '当日现宰冷鲜肉，肥瘦相间', 18.80, 100, '500g/份', '/images/products/pork.svg', 198, 1),
(7, 3, 4, '鲜活基围虾', '活虾现捞，急速冰鲜锁鲜', 36.00, 40, '500g/份', '/images/products/shrimp.svg', 167, 1),
(8, 3, 5, '原味鲜牛奶', '牧场直供巴氏鲜奶，72℃杀菌', 9.90, 120, '950ml/瓶', '/images/products/milk.svg', 445, 1),
(9, 3, 2, '智利进口车厘子', 'JJ级大果，脆甜爽口，节日尝鲜', 59.90, 30, '2斤/盒', '/images/products/cherry.svg', 88, 1),
(10, 3, 1, '有机西兰花', '青花紧实，富含维C，清炒焯水皆宜', 7.50, 90, '400g/份', '/images/products/broccoli.svg', 156, 0);

-- 订单演示数据（覆盖状态机各节点）
INSERT INTO t_order (id, order_no, user_id, merchant_id, rider_id, total_amount, freight, pay_amount, receiver_name, receiver_phone, receiver_address, remark, status, created_at, accept_at, prepare_at, taken_at, picked_at, delivered_at) VALUES
(1001, 'FD20261024001', 2, 3, NULL,    24.70,  5.00, 29.70, '张小明', '13911112222', '漳州市芗城区胜利路88号幸福小区3栋502', '请轻拿轻放', 'WAIT_MERCHANT', '2026-10-24 09:10:00', NULL, NULL, NULL, NULL, NULL),
(1002, 'FD20261024002', 2, 3, NULL,    45.80,  0.00, 45.80, '张小明', '13911112222', '漳州市芗城区胜利路88号幸福小区3栋502', '',             'PREPARING',     '2026-10-24 08:30:00', '2026-10-24 08:35:00', NULL, NULL, NULL, NULL),
(1003, 'FD20261024003', 2, 3, NULL,    39.80,  0.00, 39.80, '张小明', '13911112222', '漳州市芗城区胜利路88号幸福小区3栋502', '生鲜类尽快送', 'WAIT_RIDER',   '2026-10-24 07:50:00', '2026-10-24 07:55:00', '2026-10-24 08:20:00', NULL, NULL, NULL),
(1004, 'FD20261024004', 2, 3, 4,       59.90,  5.00, 64.90, '张小明', '13911112222', '漳州市芗城区胜利路88号幸福小区3栋502', '',             'TAKEN',         '2026-10-24 07:20:00', '2026-10-24 07:25:00', '2026-10-24 07:40:00', '2026-10-24 07:55:00', NULL, NULL),
(1005, 'FD20261023005', 2, 3, 4,       18.80,  5.00, 23.80, '张小明', '13911112222', '漳州市芗城区胜利路88号幸福小区3栋502', '',             'DELIVERING',    '2026-10-23 18:00:00', '2026-10-23 18:05:00', '2026-10-23 18:25:00', '2026-10-23 18:40:00', '2026-10-23 19:00:00', NULL),
(1006, 'FD20261023006', 2, 3, 4,       22.40,  5.00, 27.40, '张小明', '13911112222', '漳州市芗城区胜利路88号幸福小区3栋502', '',             'DONE',          '2026-10-23 12:00:00', '2026-10-23 12:05:00', '2026-10-23 12:20:00', '2026-10-23 12:35:00', '2026-10-23 12:50:00', '2026-10-23 13:05:00'),
(1007, 'FD20261023007', 2, 3, NULL,    36.00,  5.00, 41.00, '张小明', '13911112222', '漳州市芗城区胜利路88号幸福小区3栋502', '',             'EXCEPTION',     '2026-10-23 10:00:00', '2026-10-23 10:05:00', '2026-10-23 10:30:00', NULL, NULL, NULL);

-- 订单明细
INSERT INTO t_order_item (order_id, product_id, product_name, product_image, price, quantity) VALUES
(1001, 1, '有机上海青', '/images/products/vegetable1.svg', 5.90, 2),
(1001, 2, '本地小番茄', '/images/products/tomato.svg', 8.80, 1),
(1002, 3, '海南贵妃芒果', '/images/products/mango.svg', 15.90, 2),
(1003, 5, '农家土鸡蛋', '/images/products/egg.svg', 12.50, 1),
(1003, 6, '冷鲜猪前腿肉', '/images/products/pork.svg', 18.80, 1),
(1004, 9, '智利进口车厘子', '/images/products/cherry.svg', 59.90, 1),
(1005, 6, '冷鲜猪前腿肉', '/images/products/pork.svg', 18.80, 1),
(1006, 8, '原味鲜牛奶', '/images/products/milk.svg', 9.90, 1),
(1006, 1, '有机上海青', '/images/products/vegetable1.svg', 5.90, 1),
(1007, 7, '鲜活基围虾', '/images/products/shrimp.svg', 36.00, 1);

-- 已有评价
INSERT INTO t_review (order_id, user_id, merchant_id, rating, content) VALUES
(1006, 2, 3, 5, '牛奶很新鲜，配送很快，包装也干净，下次还买！');

-- 骑手历史收入
INSERT INTO t_rider_income (rider_id, order_id, order_no, amount) VALUES
(4, 1006, 'FD20261023006', 4.50),
(4, 1005, 'FD20261023005', 4.50);
