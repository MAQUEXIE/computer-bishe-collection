-- ============================================================
-- 11 食堂智慧结算系统  数据库初始化脚本
-- 库名：db_11_canteen  端口：后端 9011 / 前端 5111
-- ============================================================
SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS db_11_canteen DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_11_canteen;

-- ---------------- 用户（师生/档口/管理员） ----------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  username   VARCHAR(64)  NOT NULL COMMENT '登录名',
  password   VARCHAR(64)  NOT NULL,
  name       VARCHAR(64)  NOT NULL COMMENT '姓名',
  card_no    VARCHAR(32)  DEFAULT NULL COMMENT '校园卡号/消费码',
  role       VARCHAR(16)  NOT NULL COMMENT 'ADMIN/STUDENT/STALL',
  balance    DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '餐补余额',
  status     TINYINT      NOT NULL DEFAULT 1 COMMENT '1正常 0冻结',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_username (username),
  UNIQUE KEY uk_card_no (card_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ---------------- 档口 ----------------
DROP TABLE IF EXISTS t_stall;
CREATE TABLE t_stall (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  name       VARCHAR(64) NOT NULL COMMENT '档口名称',
  location   VARCHAR(64) DEFAULT '' COMMENT '位置',
  owner_id   BIGINT      DEFAULT NULL COMMENT '档口账号(t_user.id)',
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='档口表';

-- ---------------- 菜品（含营养数据） ----------------
DROP TABLE IF EXISTS t_dish;
CREATE TABLE t_dish (
  id         BIGINT        NOT NULL AUTO_INCREMENT,
  stall_id   BIGINT        NOT NULL,
  name       VARCHAR(64)   NOT NULL,
  price      DECIMAL(10,2) NOT NULL,
  calories   DOUBLE        DEFAULT 0 COMMENT '热量 kcal/份',
  protein    DOUBLE        DEFAULT 0 COMMENT '蛋白质 g/份',
  carb       DOUBLE        DEFAULT 0 COMMENT '碳水 g/份',
  fat        DOUBLE        DEFAULT 0 COMMENT '脂肪 g/份',
  image      VARCHAR(128)  DEFAULT 'default.svg',
  status     TINYINT       NOT NULL DEFAULT 1 COMMENT '1上架 0下架',
  created_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品表';

-- ---------------- 消费流水 ----------------
DROP TABLE IF EXISTS t_consume;
CREATE TABLE t_consume (
  id          BIGINT        NOT NULL AUTO_INCREMENT,
  user_id     BIGINT        NOT NULL,
  stall_id    BIGINT        NOT NULL,
  dish_id     BIGINT        NOT NULL,
  user_name   VARCHAR(64)   DEFAULT '',
  stall_name  VARCHAR(64)   DEFAULT '',
  dish_name   VARCHAR(64)   DEFAULT '',
  amount      DECIMAL(10,2) NOT NULL,
  calories    DOUBLE        DEFAULT 0,
  protein     DOUBLE        DEFAULT 0,
  carb        DOUBLE        DEFAULT 0,
  fat         DOUBLE        DEFAULT 0,
  pay_type    VARCHAR(16)   DEFAULT '刷卡',
  consume_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user (user_id),
  KEY idx_stall (stall_id),
  KEY idx_time (consume_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消费流水表';

-- ---------------- 充值/餐补发放流水 ----------------
DROP TABLE IF EXISTS t_recharge;
CREATE TABLE t_recharge (
  id         BIGINT        NOT NULL AUTO_INCREMENT,
  user_id    BIGINT        NOT NULL,
  user_name  VARCHAR(64)   DEFAULT '',
  amount     DECIMAL(10,2) NOT NULL,
  type       VARCHAR(16)   NOT NULL COMMENT 'MANUAL/AUTO',
  remark     VARCHAR(255)  DEFAULT '',
  created_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='充值流水表';

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户：1 admin / 2 张同学 / 3 王档主 / 4 李同学
INSERT INTO t_user (id, username, password, name, card_no, role, balance, status) VALUES
 (1, 'admin',  '123456', '系统管理员', NULL,          'ADMIN',   0.00, 1),
 (2, 'student','123456', '张同学',     'C20260001',   'STUDENT', 128.50, 1),
 (3, 'stall',  '123456', '王档主',     NULL,          'STALL',   0.00, 1),
 (4, 'lihua',  '123456', '李同学',     'C20260002',   'STUDENT', 86.00, 1);

-- 4 个档口
INSERT INTO t_stall (id, name, location, owner_id) VALUES
 (1, '川湘窗口',   '食堂一楼A区', 3),
 (2, '面食粥铺',   '食堂一楼B区', NULL),
 (3, '减脂轻食',   '食堂二楼C区', NULL),
 (4, '特色烧烤',   '食堂二楼D区', NULL);

-- 11 道菜（含营养数据）
INSERT INTO t_dish (id, stall_id, name, price, calories, protein, carb, fat, image, status) VALUES
 (1,  1, '红烧肉',     15.00, 520, 28, 12, 45, 'meat.svg',     1),
 (2,  1, '麻婆豆腐',   10.00, 280, 14, 18, 16, 'tofu.svg',      1),
 (3,  1, '青椒肉丝',   12.00, 320, 20, 15, 18, 'veg.svg',       1),
 (4,  2, '牛肉拉面',   14.00, 450, 22, 60, 12, 'noodle.svg',    1),
 (5,  2, '皮蛋瘦肉粥',  8.00, 180,  8, 30,  4, 'porridge.svg',  1),
 (6,  2, '葱油拌面',    9.00, 350, 10, 55,  8, 'noodle.svg',    1),
 (7,  3, '鸡胸肉沙拉', 16.00, 260, 32, 14,  8, 'salad.svg',     1),
 (8,  3, '紫薯糙米饭', 11.00, 300,  8, 55,  3, 'rice.svg',      1),
 (9,  4, '烤鸡翅(一对)',13.00, 380, 22,  5, 30, 'chicken.svg',   1),
 (10, 4, '烤茄子',       7.00, 150,  4, 15,  8, 'eggplant.svg',  1),
 (11, 4, '烤玉米',       6.00, 120,  3, 25,  2, 'corn.svg',      1);

-- 消费流水（近 6 天，张同学 id=2，含营养快照）
INSERT INTO t_consume (user_id, stall_id, dish_id, user_name, stall_name, dish_name, amount, calories, protein, carb, fat, pay_type, consume_time) VALUES
 (2, 1, 1, '张同学', '川湘窗口', '红烧肉',     15.00, 520, 28, 12, 45, '刷卡', DATE_SUB(NOW(), INTERVAL 6 DAY)),
 (2, 2, 4, '张同学', '面食粥铺', '牛肉拉面',   14.00, 450, 22, 60, 12, '刷卡', DATE_SUB(NOW(), INTERVAL 5 DAY)),
 (2, 2, 5, '张同学', '面食粥铺', '皮蛋瘦肉粥',  8.00, 180,  8, 30,  4, '扫码', DATE_SUB(NOW(), INTERVAL 5 DAY)),
 (2, 3, 7, '张同学', '减脂轻食', '鸡胸肉沙拉', 16.00, 260, 32, 14,  8, '扫码', DATE_SUB(NOW(), INTERVAL 4 DAY)),
 (2, 1, 3, '张同学', '川湘窗口', '青椒肉丝',   12.00, 320, 20, 15, 18, '刷卡', DATE_SUB(NOW(), INTERVAL 3 DAY)),
 (2, 4, 9, '张同学', '特色烧烤', '烤鸡翅(一对)',13.00, 380, 22,  5, 30, '扫码', DATE_SUB(NOW(), INTERVAL 2 DAY)),
 (2, 4, 11,'张同学', '特色烧烤', '烤玉米',      6.00, 120,  3, 25,  2, '扫码', DATE_SUB(NOW(), INTERVAL 2 DAY)),
 (2, 2, 6, '张同学', '面食粥铺', '葱油拌面',    9.00, 350, 10, 55,  8, '刷卡', DATE_SUB(NOW(), INTERVAL 1 DAY)),
 (4, 3, 8, '李同学', '减脂轻食', '紫薯糙米饭', 11.00, 300,  8, 55,  3, '刷卡', DATE_SUB(NOW(), INTERVAL 2 DAY)),
 (4, 1, 2, '李同学', '川湘窗口', '麻婆豆腐',   10.00, 280, 14, 18, 16, '扫码', DATE_SUB(NOW(), INTERVAL 1 DAY)),
 (4, 4, 10,'李同学', '特色烧烤', '烤茄子',      7.00, 150,  4, 15,  8, '刷卡', DATE_SUB(NOW(), INTERVAL 0 DAY));

-- 充值流水（初始手动发放 + 上月自动餐补）
INSERT INTO t_recharge (user_id, user_name, amount, type, remark, created_at) VALUES
 (2, '张同学', 200.00, 'MANUAL', '开学初餐补初始化', DATE_SUB(NOW(), INTERVAL 30 DAY)),
 (4, '李同学', 200.00, 'MANUAL', '开学初餐补初始化', DATE_SUB(NOW(), INTERVAL 30 DAY)),
 (2, '张同学', 150.00, 'AUTO',   '每月餐补自动充值 150.00 元', DATE_SUB(NOW(), INTERVAL 25 DAY)),
 (4, '李同学', 150.00, 'AUTO',   '每月餐补自动充值 150.00 元', DATE_SUB(NOW(), INTERVAL 25 DAY));
