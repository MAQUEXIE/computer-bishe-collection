-- =============================================================
-- 01 多商户二手交易平台 数据库初始化脚本
-- 库名: db_01_second_hand  (utf8mb4)
-- 账号: admin/123456(管理员)  buyer/123456(买家)  seller/123456(卖家)
--       zhangsan/123456  lisi/123456
-- =============================================================

CREATE DATABASE IF NOT EXISTS db_01_second_hand
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_01_second_hand;

-- ---------------- 用户表 ----------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(64)  NOT NULL UNIQUE COMMENT '登录账号',
  password    VARCHAR(64)  NOT NULL COMMENT '密码(演示明文)',
  nickname    VARCHAR(64)  NOT NULL COMMENT '昵称',
  role        VARCHAR(16)  NOT NULL DEFAULT 'USER' COMMENT 'ADMIN/USER',
  avatar      VARCHAR(255) DEFAULT '' COMMENT '头像URL',
  credit_score INT         NOT NULL DEFAULT 100 COMMENT '信用分(初始100)',
  status      INT          NOT NULL DEFAULT 1 COMMENT '1正常 0禁用',
  created_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ---------------- 商品表 ----------------
DROP TABLE IF EXISTS product;
CREATE TABLE product (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  seller_id    BIGINT      NOT NULL COMMENT '卖家用户ID',
  title        VARCHAR(128) NOT NULL COMMENT '标题',
  description  TEXT COMMENT '描述',
  price        DECIMAL(10,2) NOT NULL COMMENT '标价',
  category     VARCHAR(32) DEFAULT '其他' COMMENT '分类',
  image        VARCHAR(255) DEFAULT '' COMMENT '主图',
  status       VARCHAR(16) NOT NULL DEFAULT 'PENDING'
               COMMENT 'PENDING待审核/ON_SALE在售/REJECTED已驳回/OFF_SHELF已下架/SOLD已售出',
  audit_remark VARCHAR(255) DEFAULT '' COMMENT '审核备注',
  views        INT DEFAULT 0 COMMENT '浏览量',
  created_at   DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- ---------------- 收藏表 ----------------
DROP TABLE IF EXISTS favorite;
CREATE TABLE favorite (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  created_at DATETIME,
  UNIQUE KEY uk_user_product (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- ---------------- 关注表 ----------------
DROP TABLE IF EXISTS follow;
CREATE TABLE follow (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT NOT NULL COMMENT '买家(关注者)',
  seller_id   BIGINT NOT NULL COMMENT '被关注卖家',
  created_at  DATETIME,
  UNIQUE KEY uk_user_seller (user_id, seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='关注表';

-- ---------------- 议价表 ----------------
DROP TABLE IF EXISTS offer;
CREATE TABLE offer (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id    BIGINT NOT NULL,
  buyer_id      BIGINT NOT NULL,
  offered_price DECIMAL(10,2) NOT NULL COMMENT '买家出价',
  status        VARCHAR(16) NOT NULL DEFAULT 'PENDING'
                COMMENT 'PENDING待处理/ACCEPTED已接受/REJECTED已拒绝',
  created_at    DATETIME,
  replied_at    DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='议价表';

-- ---------------- 订单表(担保交易) ----------------
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_no    VARCHAR(32) NOT NULL UNIQUE COMMENT '订单号',
  product_id  BIGINT NOT NULL,
  buyer_id    BIGINT NOT NULL,
  seller_id   BIGINT NOT NULL,
  amount      DECIMAL(10,2) NOT NULL COMMENT '成交金额(担保冻结金额)',
  status      VARCHAR(16) NOT NULL DEFAULT 'UNPAID'
              COMMENT 'UNPAID待支付/PAID已支付待发货/SHIPPED已发货待收货/COMPLETED已完成/CANCELED已取消',
  created_at  DATETIME,
  paid_at     DATETIME NULL,
  shipped_at  DATETIME NULL,
  completed_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ---------------- 担保资金流水 ----------------
DROP TABLE IF EXISTS fund_flow;
CREATE TABLE fund_flow (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id   BIGINT NOT NULL,
  flow_type  VARCHAR(16) NOT NULL COMMENT 'FREEZE冻结/UNFREEZE解冻给卖家/REFUND退款',
  amount     DECIMAL(10,2) NOT NULL,
  remark     VARCHAR(255) DEFAULT '',
  created_at DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='担保资金流水';

-- ---------------- 信用互评 ----------------
DROP TABLE IF EXISTS review;
CREATE TABLE review (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id      BIGINT NOT NULL,
  reviewer_id  BIGINT NOT NULL COMMENT '评价人',
  reviewee_id  BIGINT NOT NULL COMMENT '被评价人',
  direction     VARCHAR(16) NOT NULL COMMENT 'B2S买家评卖家/S2B卖家评买家',
  rating       INT NOT NULL COMMENT '1-5星',
  content      VARCHAR(500) DEFAULT '',
  credit_change INT NOT NULL DEFAULT 0 COMMENT '信用分变动',
  created_at   DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';

-- ---------------- 交易纠纷 ----------------
DROP TABLE IF EXISTS dispute;
CREATE TABLE dispute (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id       BIGINT NOT NULL,
  complainant_id BIGINT NOT NULL COMMENT '投诉人',
  reason         VARCHAR(500) NOT NULL,
  status         VARCHAR(16) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING处理中/RESOLVED已解决',
  handle_note    VARCHAR(500) DEFAULT '',
  created_at     DATETIME,
  resolved_at    DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='交易纠纷表';

-- =============================================================
-- 演示数据
-- =============================================================

-- 用户
INSERT INTO `user`(id, username, password, nickname, role, avatar, credit_score, status, created_at) VALUES
(1, 'admin',  '123456', '平台管理员', 'ADMIN', '/images/avatar/admin.svg', 100, 1, '2026-09-01 10:00:00'),
(2, 'buyer',  '123456', '小买家阿福',  'USER',  '/images/avatar/buyer.svg',  102, 1, '2026-09-02 10:00:00'),
(3, 'seller', '123456', '数码闲置铺',  'USER',  '/images/avatar/seller.svg', 105, 1, '2026-09-03 10:00:00'),
(4, 'zhangsan','123456', '张三杂货铺', 'USER',  '/images/avatar/z.svg',      100, 1, '2026-09-04 10:00:00'),
(5, 'lisi',   '123456', '李四二手严选','USER', '/images/avatar/l.svg',      110, 1, '2026-09-05 10:00:00');

-- 商品(在售8件 + 待审核2件 + 已售出1件)
INSERT INTO product(id, seller_id, title, description, price, category, image, status, audit_remark, views, created_at) VALUES
(1, 3, '95新 iPhone 13 128G 星光色', '自用一手,无拆无修,电池健康88%,配件齐全,附赠三个手机壳。面交或包邮。', 3299.00, '手机数码', '/images/products/p1.svg', 'ON_SALE', '', 126, '2026-10-01 09:00:00'),
(2, 3, '任天堂 Switch OLED 白色主机', ' OLED屏无划痕,带底座和原装手柄,另送一张塞尔达卡带。', 1450.00, '游戏影音', '/images/products/p2.svg', 'ON_SALE', '', 88, '2026-10-02 09:00:00'),
(3, 4, '罗技 MX Master 3S 无线鼠标', '公司配发重复了,拆封试用过一次,几乎全新,静音静音很安静。', 380.00, '电脑配件', '/images/products/p3.svg', 'ON_SALE', '', 65, '2026-10-03 09:00:00'),
(4, 5, '小米空气净化器4 Pro', '搬家带不走,使用半年,滤芯还剩60%,正常使用无故障。', 450.00, '家用电器', '/images/products/p4.svg', 'ON_SALE', '', 42, '2026-10-04 09:00:00'),
(5, 3, 'Kindle Paperwhite 5 电子书阅读器', '几乎全新,已换屏保,送保护套,吃灰出掉。', 520.00, '图书文娱', '/images/products/p5.svg', 'ON_SALE', '', 33, '2026-10-05 09:00:00'),
(6, 3, 'Dell U2419H 24寸显示器', '专业校色屏,IPS,出厂校色报告都在,无坏点。', 700.00, '电脑配件', '/images/products/p6.svg', 'ON_SALE', '', 51, '2026-10-06 09:00:00'),
(7, 5, '九成新捷安特ATX860自行车', '山地车,12速,骑了不到500公里,无摔车。', 899.00, '运动户外', '/images/products/p7.svg', 'ON_SALE', '', 28, '2026-10-07 09:00:00'),
(8, 4, '优衣库羽绒服 M码 仅试穿', '买大了,M码,吊牌已剪仅试穿一次,藏青色。', 199.00, '服饰鞋包', '/images/products/p8.svg', 'PENDING', '', 5, '2026-10-23 09:00:00'),
(9, 5, '宜家贝达电视柜 黑色', '自提,宽180cm,结构稳固,使用两年。', 260.00, '家居家具', '/images/products/p9.svg', 'PENDING', '', 3, '2026-10-23 10:00:00'),
(10, 4, '罗技K380蓝牙键盘 白色', '成色好,按键无油光,配套附赠。', 120.00, '电脑配件', '/images/products/p10.svg', 'SOLD', '', 74, '2026-09-20 09:00:00');

-- 收藏: buyer收藏了 p1,p2
INSERT INTO favorite(user_id, product_id, created_at) VALUES (2,1,'2026-10-10 10:00:00'),(2,2,'2026-10-11 10:00:00');

-- 关注: buyer关注了 seller(3) 和 lisi(5)
INSERT INTO follow(user_id, seller_id, created_at) VALUES (2,3,'2026-10-10 10:00:00'),(2,5,'2026-10-11 10:00:00');

-- 议价
INSERT INTO offer(id, product_id, buyer_id, offered_price, status, created_at, replied_at) VALUES
(1, 2, 2, 1300.00, 'PENDING',  '2026-10-20 10:00:00', NULL),
(2, 5, 4, 480.00,  'PENDING',  '2026-10-21 10:00:00', NULL),
(3, 1, 2, 3100.00, 'REJECTED','2026-10-15 10:00:00', '2026-10-16 10:00:00'),
(4, 3, 5, 350.00,  'ACCEPTED','2026-10-18 10:00:00', '2026-10-19 10:00:00');

-- 订单(覆盖四种状态)
INSERT INTO orders(id, order_no, product_id, buyer_id, seller_id, amount, status, created_at, paid_at, shipped_at, completed_at) VALUES
(1, 'ORD20261024001', 6, 2, 3, 700.00, 'UNPAID',     '2026-10-24 08:00:00', NULL, NULL, NULL),
(2, 'ORD20261022002', 3, 2, 4, 350.00, 'PAID',       '2026-10-22 09:00:00', '2026-10-22 09:30:00', NULL, NULL),
(3, 'ORD20261021003', 4, 4, 5, 450.00, 'SHIPPED',    '2026-10-21 09:00:00', '2026-10-21 09:30:00', '2026-10-22 09:00:00', NULL),
(4, 'ORD20261010004', 10, 2, 4, 120.00, 'COMPLETED',  '2026-10-10 09:00:00', '2026-10-10 09:30:00', '2026-10-11 09:00:00', '2026-10-13 09:00:00');

-- 担保资金流水: PAID冻结, COMPLETED解冻
INSERT INTO fund_flow(order_id, flow_type, amount, remark, created_at) VALUES
(2, 'FREEZE',   350.00, '买家担保支付,资金由平台冻结', '2026-10-22 09:30:00'),
(3, 'FREEZE',   450.00, '买家担保支付,资金由平台冻结', '2026-10-21 09:30:00'),
(4, 'FREEZE',   120.00, '买家担保支付,资金由平台冻结', '2026-10-10 09:30:00'),
(4, 'UNFREEZE', 120.00, '买家确认收货,冻结资金解冻给卖家(张三杂货铺)', '2026-10-13 09:00:00');

-- 信用互评(订单4双方已互评)
INSERT INTO review(order_id, reviewer_id, reviewee_id, direction, rating, content, credit_change, created_at) VALUES
(4, 2, 4, 'B2S', 5, '卖家发货很快,包装仔细,商品与描述一致,好评!', 2, '2026-10-13 10:00:00'),
(4, 4, 2, 'S2B', 5, '爽快买家,沟通顺畅,确认收货也很快。', 2, '2026-10-13 11:00:00');

-- 交易纠纷: 订单3买家已投诉,待管理员处理
INSERT INTO dispute(order_id, complainant_id, reason, status, handle_note, created_at, resolved_at) VALUES
(3, 4, '收到的空气净化器外观有明显划痕,与卖家描述的"无故障、成色新"不符,要求退款。', 'PENDING', '', '2026-10-23 09:00:00', NULL);
