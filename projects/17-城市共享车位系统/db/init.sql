-- ============================================================
-- 17 城市共享车位系统 数据库初始化脚本
-- 库名: db_17_parking  字符集: utf8mb4
-- 测试账号: admin/123456(管理员) driver/123456(车主) owner/123456(车位主)
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_17_parking DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_17_parking;

DROP TABLE IF EXISTS t_dispute;
DROP TABLE IF EXISTS t_park_record;
DROP TABLE IF EXISTS t_booking_order;
DROP TABLE IF EXISTS t_price_rule;
DROP TABLE IF EXISTS t_parking_space;
DROP TABLE IF EXISTS t_user;

-- ---------- 用户表 ----------
CREATE TABLE t_user (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  username    VARCHAR(50) NOT NULL UNIQUE COMMENT '登录名',
  password    VARCHAR(50) NOT NULL,
  nickname    VARCHAR(50) COMMENT '昵称',
  phone       VARCHAR(20),
  role        VARCHAR(20) NOT NULL COMMENT 'ADMIN管理员/DRIVER车主/OWNER车位主',
  status      INT DEFAULT 1 COMMENT '1正常',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ---------- 车位表 ----------
CREATE TABLE t_parking_space (
  id            BIGINT PRIMARY KEY AUTO_INCREMENT,
  owner_id      BIGINT NOT NULL COMMENT '车位主用户ID',
  title         VARCHAR(100) NOT NULL COMMENT '车位标题',
  address       VARCHAR(200) COMMENT '详细地址',
  area          VARCHAR(50) COMMENT '所属区域',
  map_x         INT DEFAULT 500 COMMENT '地图示意坐标x(0-1000)',
  map_y         INT DEFAULT 300 COMMENT '地图示意坐标y(0-600)',
  space_type    VARCHAR(20) DEFAULT '地面' COMMENT '地面/地下/立体',
  price_hour    DECIMAL(10,2) DEFAULT 0 COMMENT '参考价 元/小时',
  free_period   VARCHAR(100) COMMENT '可预约时段描述',
  status        VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING待审核/APPROVED已通过可预约/REJECTED已拒绝/OFFLINE已下线',
  reject_reason VARCHAR(200),
  description   VARCHAR(500),
  create_time   DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='共享车位表';

-- ---------- 费率规则表(分时计价) ----------
CREATE TABLE t_price_rule (
  id              BIGINT PRIMARY KEY AUTO_INCREMENT,
  rule_name       VARCHAR(100) COMMENT '规则名称',
  peak_rate       DECIMAL(10,2) COMMENT '高峰时段单价 元/小时',
  offpeak_rate    DECIMAL(10,2) COMMENT '非高峰时段单价 元/小时',
  peak_start      INT DEFAULT 8 COMMENT '高峰开始小时(24制)',
  peak_end        INT DEFAULT 20 COMMENT '高峰结束小时',
  free_minutes    INT DEFAULT 15 COMMENT '免费时长(分钟)',
  tier1_hours     INT DEFAULT 2 COMMENT '前N小时按原价',
  tier2_discount  DECIMAL(4,2) DEFAULT 0.80 COMMENT '超出N小时后单价折扣',
  platform_fee_rate DECIMAL(4,2) DEFAULT 0.10 COMMENT '平台抽成比例',
  enabled         INT DEFAULT 1,
  update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='费率规则表';

-- ---------- 预约订单表 ----------
CREATE TABLE t_booking_order (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_no     VARCHAR(40) NOT NULL UNIQUE COMMENT '订单号',
  space_id     BIGINT NOT NULL,
  driver_id    BIGINT NOT NULL COMMENT '车主ID',
  owner_id     BIGINT NOT NULL COMMENT '车位主ID',
  reserve_desc VARCHAR(100) COMMENT '预约时段描述',
  in_time      DATETIME NULL COMMENT '实际进场时间',
  out_time     DATETIME NULL COMMENT '实际出场时间',
  minutes      INT DEFAULT 0 COMMENT '计费分钟数',
  amount       DECIMAL(10,2) DEFAULT 0 COMMENT '应付总额(元)',
  platform_fee DECIMAL(10,2) DEFAULT 0 COMMENT '平台抽成',
  owner_income DECIMAL(10,2) DEFAULT 0 COMMENT '车位主收益',
  status       VARCHAR(20) DEFAULT 'BOOKED' COMMENT 'BOOKED已预约/IN_PARKING停车中/FINISHED已完成/CANCELLED已取消',
  remark       VARCHAR(200),
  create_time  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约订单表';

-- ---------- 停车流水表 ----------
CREATE TABLE t_park_record (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id     BIGINT NOT NULL,
  space_id     BIGINT NOT NULL,
  driver_id    BIGINT NOT NULL,
  owner_id     BIGINT NOT NULL,
  in_time      DATETIME,
  out_time     DATETIME,
  minutes      INT COMMENT '停车分钟数',
  amount       DECIMAL(10,2) COMMENT '本次收费',
  platform_fee DECIMAL(10,2) COMMENT '平台抽成',
  owner_income DECIMAL(10,2) COMMENT '车位主收益',
  create_time  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='停车流水表';

-- ---------- 纠纷表 ----------
CREATE TABLE t_dispute (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id      BIGINT,
  reporter_id   BIGINT,
  reporter_name VARCHAR(50),
  reason       VARCHAR(500),
  status       VARCHAR(20) DEFAULT 'OPEN' COMMENT 'OPEN待处理/RESOLVED已解决/CLOSED已关闭',
  solution     VARCHAR(500),
  create_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_time  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='纠纷记录表';

-- ============================================================
-- 初始化数据
-- ============================================================
-- 用户: 1管理员 2车主 3车位主
INSERT INTO t_user(id,username,password,nickname,phone,role,status) VALUES
(1,'admin','123456','平台管理员','13800000000','ADMIN',1),
(2,'driver','123456','张伟(车主)','13911112222','DRIVER',1),
(3,'owner','123456','李芳(车位主)','13733334444','OWNER',1),
(4,'owner2','123456','王强(车位主)','13755556666','OWNER',1);

-- 车位: owner_id=3(owner) 11个, 覆盖5个区域
INSERT INTO t_parking_space(id,owner_id,title,address,area,map_x,map_y,space_type,price_hour,free_period,status,reject_reason,description) VALUES
(1,3,'城东阳光花园-地下B2-088','阳光花园小区B2层088号','城东商圈',180,150,'地下',6.00,'工作日19:00-次日8:00 全天可约','APPROVED',NULL,'家有新能源车位,带充电桩,进出方便'),
(2,3,'高新科技园-地面A区12','高新科技园地面停车场A12号','高新区',520,110,'地面',8.00,'工作日9:00-17:00 白天可约','APPROVED',NULL,'靠近写字楼东门,通勤首选'),
(3,3,'大学城书香苑-地面3栋车位','书香苑3栋楼下划线车位','大学城',300,430,'地面',4.00,'全天可约(闲时共享)','APPROVED',NULL,'学生校外停车,月租短租均可'),
(4,3,'滨江公园-地下C-210','滨江公园地下车库C区210','滨江公园',760,300,'地下',7.00,'周末全天可约','APPROVED',NULL,'公园旁,周末出游停车好去处'),
(5,3,'市中心人民广场-立体车位05','人民广场立体停车楼05层','市中心',640,230,'立体',9.00,'工作日18:00后可约','APPROVED',NULL,'立体机械车位,需配合引导'),
(6,3,'城东阳光花园-地下B1-032','阳光花园小区B1层032号','城东商圈',210,190,'地下',5.50,'工作日20:00-次日7:00 夜间可约','APPROVED',NULL,'离单元门近,女士友好'),
(7,3,'高新软件园-地面B-07','软件园二期地面B区07号','高新区',560,160,'地面',7.50,'工作日10:00-16:00 闲时可约','APPROVED',NULL,'闲时共享,性价比高'),
(8,3,'城南幸福里-地下D-15','幸福里小区D区15号','大学城',340,470,'地下',5.00,'全天可约','PENDING',NULL,'新装修车位,首次发布待审核'),
(9,3,'城北锦绣天地-地面09','锦绣天地一期地面09号','市中心',690,180,'地面',6.50,'工作日19:00后可约','PENDING',NULL,'靠近地铁口,即将上线'),
(10,3,'东湖春晓-地下A-66','东湖春晓A区66号','滨江公园',800,250,'地下',8.50,'周末全天可约','PENDING',NULL,'湖景车位,环境安静'),
(11,3,'城西老机床厂-地面露天','老机床厂旧址露天车位','大学城',260,380,'地面',3.00,'全天可约','REJECTED','车位无划线,存在安全隐患,请整改后重新发布','露天无硬化地面');

-- 费率规则: 高峰8:00-20:00 8元/小时, 非高峰5元/小时, 15分钟内免费, 前2小时原价 超出8折, 平台抽成10%
INSERT INTO t_price_rule(id,rule_name,peak_rate,offpeak_rate,peak_start,peak_end,free_minutes,tier1_hours,tier2_discount,platform_fee_rate,enabled) VALUES
(1,'城市共享标准费率',8.00,5.00,8,20,15,2,0.80,0.10,1);

-- 订单: driver(2) 历史停车订单
INSERT INTO t_booking_order(id,order_no,space_id,driver_id,owner_id,reserve_desc,in_time,out_time,minutes,amount,platform_fee,owner_income,status,remark) VALUES
(1,'PK202610200915001',1,2,3,'2026-10-20 09:00-12:00','2026-10-20 09:12:00','2026-10-20 11:48:00',156,20.00,2.00,18.00,'FINISHED','商务拜访停车'),
(2,'PK202610221430002',4,2,3,'2026-10-22 14:00-18:00','2026-10-22 14:20:00','2026-10-22 18:05:00',210,27.00,2.70,24.30,'FINISHED','周末公园游玩'),
(3,'PK202610240900003',2,2,3,'2026-10-24 09:30-12:00',NULL,NULL,0,0.00,0.00,0.00,'BOOKED','今日已预约,待进场'),
(4,'PK202610241030004',7,2,3,'2026-10-24 10:30-12:30','2026-10-24 10:32:00',NULL,0,0.00,0.00,0.00,'IN_PARKING','停车中,待结束');

-- 停车流水: 对应已完成订单
INSERT INTO t_park_record(order_id,space_id,driver_id,owner_id,in_time,out_time,minutes,amount,platform_fee,owner_income) VALUES
(1,1,2,3,'2026-10-20 09:12:00','2026-10-20 11:48:00',156,20.00,2.00,18.00),
(2,4,2,3,'2026-10-22 14:20:00','2026-10-22 18:05:00',210,27.00,2.70,24.30);

-- 纠纷: 1条待处理 1条已解决
INSERT INTO t_dispute(id,order_id,reporter_id,reporter_name,reason,status,solution) VALUES
(1,1,2,'张伟(车主)','订单结束后车位主以占用过久为由要求额外收费20元,与计费规则不符,申请平台介入。','OPEN',NULL),
(2,2,2,'张伟(车主)','车位现场与描述不符,实际为立体车位,新手停车困难,希望退还部分费用。','RESOLVED','经协调车位主退还5元,平台补偿2元代金券,双方达成一致。');
