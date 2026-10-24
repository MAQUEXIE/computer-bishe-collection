-- ============================================================
-- 13 智慧物业管理系统 初始化脚本
-- 库名: db_13_property  字符集: utf8mb4
-- 账号: admin/123456(管理员)  property/123456(物业)  owner/123456(业主)
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_13_property DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_13_property;

-- ---------- 用户/账号 ----------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  username    VARCHAR(50)  NOT NULL COMMENT '登录名',
  password    VARCHAR(50)  NOT NULL,
  nickname    VARCHAR(50)  NOT NULL COMMENT '姓名/昵称',
  phone       VARCHAR(20)  DEFAULT '',
  role        VARCHAR(20)  NOT NULL COMMENT 'ADMIN管理员 / PROPERTY物业 / OWNER业主',
  status      INT          NOT NULL DEFAULT 1 COMMENT '1正常 0停用',
  house_id    BIGINT       DEFAULT NULL COMMENT '业主绑定的房屋',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户账号';

-- ---------- 楼栋 ----------
DROP TABLE IF EXISTS t_building;
CREATE TABLE t_building (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  name        VARCHAR(50)  NOT NULL COMMENT '楼栋名,如 1栋',
  floors      INT          NOT NULL DEFAULT 6,
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='楼栋';

-- ---------- 房屋 ----------
DROP TABLE IF EXISTS t_house;
CREATE TABLE t_house (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  building_id BIGINT       NOT NULL,
  room_no     VARCHAR(30)  NOT NULL COMMENT '房号 如 1-101',
  area        DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '面积(㎡)',
  owner_id    BIGINT       DEFAULT NULL COMMENT '业主 user id, 空=未入住',
  status      VARCHAR(20)  NOT NULL DEFAULT 'LIVE' COMMENT 'LIVE自住 VACANT空置',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='房屋';

-- ---------- 报修工单(状态机: PENDING->DISPATCHED->ACCEPTED->FINISHED->EVALUATED) ----------
DROP TABLE IF EXISTS t_repair;
CREATE TABLE t_repair (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  owner_id    BIGINT       NOT NULL,
  house_id    BIGINT       DEFAULT NULL,
  title       VARCHAR(100) NOT NULL,
  category    VARCHAR(30)  NOT NULL DEFAULT '水电' COMMENT '水电/门窗/电梯/公共设施/其他',
  content     VARCHAR(500) NOT NULL,
  status      VARCHAR(20)  NOT NULL DEFAULT 'PENDING'
              COMMENT 'PENDING待派单 DISPATCHED已派单 ACCEPTED维修中 FINISHED待评价 EVALUATED已评价',
  handler_id  BIGINT       DEFAULT NULL COMMENT '派单的物业人员',
  score       INT          DEFAULT NULL COMMENT '业主评分1-5',
  remark      VARCHAR(500) DEFAULT NULL COMMENT '维修说明/业主评价',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  finished_at DATETIME     DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报修工单';

-- ---------- 缴费账单 ----------
DROP TABLE IF EXISTS t_bill;
CREATE TABLE t_bill (
  id          BIGINT        NOT NULL AUTO_INCREMENT,
  house_id    BIGINT        NOT NULL,
  owner_id    BIGINT        DEFAULT NULL,
  type        VARCHAR(30)   NOT NULL COMMENT '物业费/水费/电费/停车费',
  amount      DECIMAL(10,2) NOT NULL,
  period      VARCHAR(30)   NOT NULL COMMENT '账期 如 2026-10',
  due_date    DATE          NOT NULL COMMENT '到期日',
  status      VARCHAR(20)   NOT NULL DEFAULT 'UNPAID' COMMENT 'UNPAID未缴 PAID已缴',
  paid_at     DATETIME      DEFAULT NULL,
  created_at  DATETIME      DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='缴费账单';

-- ---------- 车位 ----------
DROP TABLE IF EXISTS t_parking;
CREATE TABLE t_parking (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  code        VARCHAR(30)  NOT NULL COMMENT '车位编号 A-001',
  zone        VARCHAR(30)  NOT NULL DEFAULT '地下车库',
  status      VARCHAR(20)  NOT NULL DEFAULT 'FREE' COMMENT 'FREE空闲 OCCUPIED已租',
  owner_id    BIGINT       DEFAULT NULL,
  plate       VARCHAR(20)  DEFAULT '' COMMENT '车牌',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='车位';

-- ---------- 访客申请 ----------
DROP TABLE IF EXISTS t_visitor;
CREATE TABLE t_visitor (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  owner_id     BIGINT       NOT NULL,
  visitor_name VARCHAR(50)  NOT NULL COMMENT '访客姓名',
  phone        VARCHAR(20)  NOT NULL,
  visit_date   DATE         NOT NULL COMMENT '来访日期',
  time_range   VARCHAR(30)  NOT NULL DEFAULT '全天' COMMENT '来访时段',
  status       VARCHAR(20)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待审批 APPROVED已批准 REJECTED已拒绝',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='访客申请';

-- ---------- 投诉建议 ----------
DROP TABLE IF EXISTS t_complaint;
CREATE TABLE t_complaint (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  owner_id    BIGINT       NOT NULL,
  title       VARCHAR(100) NOT NULL,
  content     VARCHAR(500) NOT NULL,
  reply       VARCHAR(500) DEFAULT NULL COMMENT '物业回复',
  status      VARCHAR(20)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待处理 RESOLVED已回复',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='投诉建议';

-- ---------- 公告 ----------
DROP TABLE IF EXISTS t_notice;
CREATE TABLE t_notice (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  title       VARCHAR(100) NOT NULL,
  content     VARCHAR(1000) NOT NULL,
  publisher   VARCHAR(50)  NOT NULL DEFAULT '物业服务中心',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告';

-- ============================================================
-- 演示数据
-- ============================================================

-- 账号: id=1 管理员, id=2 物业, id=3 业主owner(绑定1-101), id=4 李四(绑定1-102), id=5 王五(绑定1-201)
INSERT INTO t_user(id,username,password,nickname,phone,role,status,house_id) VALUES
 (1,'admin','123456','系统管理员','13800000001','ADMIN',1,NULL),
 (2,'property','123456','张管家','13800000002','PROPERTY',1,NULL),
 (3,'owner','123456','张业主','13800000003','OWNER',1,1),
 (4,'lisi','123456','李四','13800000004','OWNER',1,2),
 (5,'wangwu','123456','王五','13800000005','OWNER',1,3);

-- 楼栋
INSERT INTO t_building(id,name,floors) VALUES
 (1,'1栋',6),(2,'2栋',6),(3,'3栋',11);

-- 房屋 8 户
INSERT INTO t_house(id,building_id,room_no,area,owner_id,status) VALUES
 (1,1,'1-101',89.50,3,'LIVE'),
 (2,1,'1-102',76.00,4,'LIVE'),
 (3,1,'1-201',98.20,5,'LIVE'),
 (4,2,'2-101',65.30,NULL,'VACANT'),
 (5,2,'2-102',89.50,NULL,'VACANT'),
 (6,2,'2-201',120.00,NULL,'VACANT'),
 (7,3,'3-101',55.00,NULL,'VACANT'),
 (8,3,'3-201',143.80,NULL,'VACANT');

-- 报修工单(覆盖多个状态, 含一条待派单、一条已派单、一条维修中、一条待评价、一条已评价)
INSERT INTO t_repair(owner_id,house_id,title,category,content,status,handler_id,score,remark,finished_at) VALUES
 (3,1,'厨房水管漏水','水电','水槽下方接口持续渗水,地面积水','PENDING',NULL,NULL,NULL,NULL),
 (4,2,'主卧窗户关不严','门窗','大风时窗户有啸叫声,密封条老化','DISPATCHED',2,NULL,NULL,NULL),
 (5,3,'电梯异响','电梯','早高峰时电梯运行有金属摩擦声','ACCEPTED',2,NULL,NULL,NULL),
 (3,1,'客厅灯不亮','水电','更换过灯泡仍不亮,疑似线路问题','FINISHED',2,4,'师傅很专业,半小时修好', '2026-10-20 15:30:00'),
 (4,2,'楼道灯损坏','公共设施','1-2楼楼梯间灯坏了一周','EVALUATED',2,5,'修得很及时', '2026-10-15 10:00:00');

-- 缴费账单(含 已逾期 / 7天内到期 / 已缴)
INSERT INTO t_bill(house_id,owner_id,type,amount,period,due_date,status,paid_at) VALUES
 (1,3,'物业费',268.50,'2026-Q3','2026-10-01','UNPAID',NULL),          -- 已逾期(欠费)
 (1,3,'电费',86.20,'2026-10','2026-10-28','UNPAID',NULL),               -- 7天内到期(即将提醒)
 (2,4,'物业费',228.00,'2026-Q3','2026-10-05','UNPAID',NULL),           -- 已逾期
 (3,5,'水费',45.80,'2026-09','2026-09-25','PAID','2026-09-20 09:10:00'),-- 已缴
 (1,3,'水费',32.00,'2026-09','2026-09-25','PAID','2026-09-20 09:12:00');

-- 车位
INSERT INTO t_parking(code,zone,status,owner_id,plate) VALUES
 ('A-001','地下车库','OCCUPIED',3,'闽D12345'),
 ('A-002','地下车库','OCCUPIED',4,'闽D67890'),
 ('A-003','地下车库','FREE',NULL,''),
 ('B-101','地面车位','FREE',NULL,''),
 ('B-102','地面车位','FREE',NULL,'');

-- 访客申请
INSERT INTO t_visitor(owner_id,visitor_name,phone,visit_date,time_range,status) VALUES
 (3,'赵朋友','13900000001','2026-10-25','14:00-18:00','PENDING'),
 (4,'钱家人','13900000002','2026-10-22','全天','APPROVED'),
 (5,'孙同事','13900000003','2026-10-21','09:00-12:00','APPROVED');

-- 投诉建议
INSERT INTO t_complaint(owner_id,title,content,reply,status) VALUES
 (3,'建议增加健身器材','小区广场希望增加老年健身器材','已上报经理,列入明年改造计划','RESOLVED'),
 (4,'夜间路灯太暗','2栋后巷夜间路灯昏暗,存在安全隐患',NULL,'PENDING'),
 (5,'希望延长快递柜使用时间','快递柜晚上10点后无法取件',NULL,'PENDING');

-- 公告
INSERT INTO t_notice(title,content,publisher) VALUES
 ('关于10月垃圾分类专项检查的通知','请各业主于10月31日前完成定时定点投放,物业服务中心将联合社区进行检查。','物业服务中心'),
 ('2026年第三季度物业费催缴公告','尚未缴纳Q3物业费的业主请于10月31日前通过系统在线缴纳,逾期将产生滞纳金。','物业服务中心'),
 ('小区游泳馆冬季开放时间调整','自11月1日起,游泳馆开放时间调整为 08:00-21:00,请相互转告。','物业服务中心');
