-- 24 桌游剧本杀预约系统 初始化 SQL
DROP DATABASE IF EXISTS db_24_boardgame;
CREATE DATABASE db_24_boardgame DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_24_boardgame;

-- ========== 用户 ==========
CREATE TABLE t_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64),
  phone VARCHAR(32),
  role VARCHAR(16) NOT NULL COMMENT 'PLAYER/SHOP/ADMIN',
  shop_id BIGINT DEFAULT NULL COMMENT '店家账号关联店铺',
  status INT DEFAULT 1 COMMENT '0待审核 1正常 2拒绝',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 店铺 ==========
CREATE TABLE t_shop (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  address VARCHAR(255),
  phone VARCHAR(32),
  description VARCHAR(500),
  owner_id BIGINT,
  status INT DEFAULT 0 COMMENT '0待审核 1通过 2拒绝',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 类目 ==========
CREATE TABLE t_category (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  type VARCHAR(16) NOT NULL COMMENT 'BOARDGAME/SCRIPT',
  sort INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 桌游/剧本 ==========
CREATE TABLE t_game (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  shop_id BIGINT NOT NULL,
  category_id BIGINT,
  name VARCHAR(128) NOT NULL,
  type VARCHAR(16) NOT NULL COMMENT 'BOARDGAME/SCRIPT',
  description VARCHAR(1000),
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  duration_min INT DEFAULT 180 COMMENT '时长分钟',
  min_players INT DEFAULT 4,
  max_players INT DEFAULT 6,
  cover_image VARCHAR(255),
  difficulty VARCHAR(16) DEFAULT '中等' COMMENT '新手/简单/中等/困难/烧脑',
  status INT DEFAULT 1 COMMENT '1上架 0下架',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 场次 ==========
CREATE TABLE t_session (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  game_id BIGINT NOT NULL,
  shop_id BIGINT NOT NULL,
  session_date DATE NOT NULL,
  start_time VARCHAR(16) NOT NULL,
  end_time VARCHAR(16),
  total_seats INT NOT NULL DEFAULT 6,
  booked_seats INT NOT NULL DEFAULT 0,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  status INT DEFAULT 1 COMMENT '1开放 2已满 3取消',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 预约 ==========
CREATE TABLE t_booking (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  booking_no VARCHAR(64) NOT NULL UNIQUE,
  session_id BIGINT NOT NULL,
  game_id BIGINT NOT NULL,
  shop_id BIGINT NOT NULL,
  player_id BIGINT NOT NULL,
  player_count INT DEFAULT 1,
  amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  status VARCHAR(16) DEFAULT 'UNPAID' COMMENT 'UNPAID已待支付 PAID已支付 CANCELLED已取消 VERIFIED已核销 CARPOOLING拼车中',
  is_carpool INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  paid_at DATETIME NULL,
  verified_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 拼车 ==========
CREATE TABLE t_carpool (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  session_id BIGINT NOT NULL,
  game_id BIGINT NOT NULL,
  shop_id BIGINT NOT NULL,
  leader_id BIGINT NOT NULL,
  needed_seats INT NOT NULL DEFAULT 4 COMMENT '本局需要总人数',
  joined_seats INT NOT NULL DEFAULT 1 COMMENT '已上车人数(含队长)',
  status VARCHAR(16) DEFAULT 'OPEN' COMMENT 'OPEN组队中 FULL已满成局 CANCELLED已取消',
  note VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 抽成结算 ==========
CREATE TABLE t_settlement (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  shop_id BIGINT NOT NULL,
  period VARCHAR(32) NOT NULL COMMENT '如 2026-10',
  total_amount DECIMAL(10,2) DEFAULT 0 COMMENT '该期间总流水',
  commission_rate DECIMAL(5,2) DEFAULT 0.10 COMMENT '抽成比例',
  commission_amount DECIMAL(10,2) DEFAULT 0 COMMENT '平台抽成',
  shop_amount DECIMAL(10,2) DEFAULT 0 COMMENT '店家实收',
  status VARCHAR(16) DEFAULT 'PENDING' COMMENT 'PENDING待结算 SETTLED已结算',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 初始化账号 ==========
INSERT INTO t_user(username,password,nickname,phone,role,status) VALUES
('admin','123456','平台管理员','13800000000','ADMIN',1),
('shop','123456','桌游老司机店长','13900000001','SHOP',1),
('player','123456','爱本家小张','13700000001','PLAYER',1);

-- ========== 店铺（2家，一家通过一家待审） ==========
INSERT INTO t_shop(id,name,address,phone,description,owner_id,status) VALUES
(1,'老司机桌游吧','漳州市芗城区南昌路 88 号','0596-2888888','五年老店，专注硬核剧本杀与德式桌游，包厢氛围一流。',2,1),
(2,'聚友桌游俱乐部','漳州市龙文区碧湖路 12 号','0596-2666666','新开网红店，主打情感本与团建轰趴。',NULL,0);

-- 把 shop 用户绑定到店铺1
UPDATE t_user SET shop_id=1 WHERE username='shop';

-- ========== 类目 ==========
INSERT INTO t_category(name,type,sort) VALUES
('德式策略','BOARDGAME',1),('美式聚会','BOARDGAME',2),('卡牌对战','BOARDGAME',3),
('硬核推理','SCRIPT',1),('情感沉浸','SCRIPT',2),('欢乐机制','SCRIPT',3),('恐怖惊悚','SCRIPT',4);

-- ========== 桌游/剧本（≥8个） ==========
INSERT INTO t_game(shop_id,category_id,name,type,description,price,duration_min,min_players,max_players,cover_image,difficulty,status) VALUES
(1,1,'璀璨宝石','BOARDGAME','经典德式宝石商人，收集宝石购买贵族，轻度策略。',88.00,90,2,4,'/images/games/gems.svg','简单',1),
(1,1,' agricola 农场主','BOARDGAME','农场经营德式重策，工人放置经典之作。',128.00,150,1,5,'/images/games/farm.svg','困难',1),
(1,2,'阿瓦隆','BOARDGAME','身份隐藏聚会桌游，梅林与莫德雷德的较量。',58.00,60,5,10,'/images/games/avalon.svg','中等',1),
(1,3,'三国杀','BOARDGAME','国民卡牌对战，身份局激战。',48.00,90,4,10,'/images/games/sanguosha.svg','简单',1),
(1,4,'年轮','SCRIPT','硬核推理本，三幕反转，时长 6 小时烧脑。',168.00,360,3,6,'/images/games/yearring.svg','烧脑',1),
(1,5,'你好，李焕英','SCRIPT','情感沉浸本，亲情线哭到崩溃。',158.00,240,3,6,'/images/games/lihuanying.svg','中等',1),
(1,6,'大富翁之深夜食堂','SCRIPT','欢乐机制本，爆笑跑团。',138.00,180,4,8,'/images/games/canteen.svg','简单',1),
(1,7,'红衣坊','SCRIPT','恐怖惊悚本，NPC 演绎拉满。',188.00,200,4,7,'/images/games/redhouse.svg','困难',1);

-- ========== 场次 ==========
-- 游戏1璀璨宝石：今日下午场（有余位）、今晚场（满）
INSERT INTO t_session(game_id,shop_id,session_date,start_time,end_time,total_seats,booked_seats,price,status) VALUES
(1,1,CURDATE(),'14:00','16:00',4,2,88.00,1),
(1,1,CURDATE(),'19:00','21:00',4,4,88.00,2),
(2,1,CURDATE(),'19:30','22:00',4,1,128.00,1),
(3,1,CURDATE(),'20:00','21:30',8,3,58.00,1),
(5,1,CURDATE(),'19:00','23:00',6,2,168.00,1),
(6,1,CURDATE(),'19:00','22:30',6,1,158.00,1),
(7,1,CURDATE(),'20:00','23:00',8,0,138.00,1),
(8,1,CURDATE(),'21:00','23:30',7,2,188.00,1);

-- ========== 预约记录（player 已支付一条，待支付一条） ==========
INSERT INTO t_booking(booking_no,session_id,game_id,shop_id,player_id,player_count,amount,status,is_carpool,paid_at) VALUES
('BK202610240001',1,1,1,3,2,176.00,'PAID',0,NOW()),
('BK202610240002',3,2,1,3,1,128.00,'UNPAID',0,NULL);

-- ========== 拼车记录（1个组队中，1个已满） ==========
INSERT INTO t_carpool(session_id,game_id,shop_id,leader_id,needed_seats,joined_seats,status,note) VALUES
(3,2,1,3,4,2,'OPEN','还差 2 位，硬核玩家速来！'),
(5,5,1,3,6,6,'FULL','已开一车，欢迎围观');

-- ========== 抽成结算 ==========
INSERT INTO t_settlement(shop_id,period,total_amount,commission_rate,commission_amount,shop_amount,status) VALUES
(1,'2026-09',5860.00,0.10,586.00,5274.00,'SETTLED'),
(1,'2026-10',2440.00,0.10,244.00,2196.00,'PENDING');
