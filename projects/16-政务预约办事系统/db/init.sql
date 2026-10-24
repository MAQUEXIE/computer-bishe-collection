-- ============================================================
-- 16 政务预约办事系统  初始化脚本
-- 库: db_16_gov  utf8mb4
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_16_gov DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_16_gov;

DROP TABLE IF EXISTS t_review;
DROP TABLE IF EXISTS t_queue;
DROP TABLE IF EXISTS t_material;
DROP TABLE IF EXISTS t_appointment;
DROP TABLE IF EXISTS t_schedule;
DROP TABLE IF EXISTS t_window;
DROP TABLE IF EXISTS t_item;
DROP TABLE IF EXISTS t_user;

-- ---------- 用户 ----------
CREATE TABLE t_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64) NOT NULL,
  phone VARCHAR(32) DEFAULT '',
  role VARCHAR(16) NOT NULL COMMENT 'ADMIN/CLERK/CITIZEN',
  status INT DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 办事事项 ----------
CREATE TABLE t_item (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  category VARCHAR(64) DEFAULT '',
  description VARCHAR(512) DEFAULT '',
  materials_req VARCHAR(512) DEFAULT '' COMMENT '所需材料，逗号分隔',
  duration_minutes INT DEFAULT 20,
  status INT DEFAULT 1 COMMENT '1启用 0停用',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 窗口 ----------
CREATE TABLE t_window (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  clerk_id BIGINT DEFAULT NULL,
  status INT DEFAULT 1 COMMENT '1开放 0暂停'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 窗口排班 ----------
CREATE TABLE t_schedule (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  window_id BIGINT NOT NULL,
  work_date DATE NOT NULL,
  morning_range VARCHAR(32) DEFAULT '09:00-12:00',
  afternoon_range VARCHAR(32) DEFAULT '14:00-17:00',
  note VARCHAR(128) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 预约单 ----------
CREATE TABLE t_appointment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  appt_no VARCHAR(32) NOT NULL,
  user_id BIGINT NOT NULL,
  item_id BIGINT NOT NULL,
  clerk_id BIGINT DEFAULT NULL,
  appt_date DATE NOT NULL,
  time_slot VARCHAR(32) NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'BOOKED' COMMENT 'BOOKED/PROCESSING/DONE/CANCELLED',
  finish_remark VARCHAR(255) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 材料预审 ----------
CREATE TABLE t_material (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  appointment_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_type VARCHAR(64) DEFAULT '',
  file_data MEDIUMTEXT COMMENT 'base64内容',
  status VARCHAR(16) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED',
  audit_remark VARCHAR(255) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  audited_at DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 叫号队列 ----------
CREATE TABLE t_queue (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  appointment_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  window_id BIGINT DEFAULT NULL,
  queue_no VARCHAR(16) NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'WAITING' COMMENT 'WAITING/CALLED/PROCESSING/DONE/CANCELLED',
  called_at DATETIME DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 办结评价 ----------
CREATE TABLE t_review (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  appointment_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  rating INT NOT NULL DEFAULT 5,
  attitude INT DEFAULT 5,
  efficiency INT DEFAULT 5,
  content VARCHAR(512) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 演示数据
-- ============================================================

-- 用户：管理员 / 窗口人员 / 市民
INSERT INTO t_user(id,username,password,nickname,phone,role,status) VALUES
(1,'admin','123456','系统管理员','13800000001','ADMIN',1),
(2,'clerk','123456','王窗口','13800000002','CLERK',1),
(3,'citizen','123456','张三','13900000001','CITIZEN',1),
(4,'lisi','123456','李四','13900000002','CITIZEN',1);

-- 6 个办事事项
INSERT INTO t_item(id,name,category,description,materials_req,duration_minutes,status) VALUES
(1,'居民身份证办理','公安户政','首次申领或换领居民身份证，现场拍照采集指纹。','身份证照片,户口本原件,申请表',20,1),
(2,'居住证签注','公安户政','居住证到期前30日内办理签注，连续居住年限累计计算。','居住证原件,房屋租赁合同,身份证复印件',15,1),
(3,'社保参保登记','社会保障','单位或个人办理社会保险参保登记，生成社保编号。','身份证原件,免冠照片,参保登记表',25,1),
(4,'不动产登记查询','不动产','查询本人名下不动产登记信息，出具查询结果证明。','身份证原件,婚姻状况证明',10,1),
(5,'医保报销申请','医疗保障','门诊或住院费用手工报销，提交票据审核后拨付。','医疗费用发票,费用明细清单,出院小结,银行卡复印件',30,1),
(6,'个体工商户营业执照办理','市场监管','申请个体工商户设立登记，领取营业执照。','身份证原件,经营场所证明,申请书,1寸照片',40,1);

-- 窗口
INSERT INTO t_window(id,name,clerk_id,status) VALUES
(1,'1号综合窗口',2,1),
(2,'2号社保窗口',NULL,0);

-- 窗口排班
INSERT INTO t_schedule(window_id,work_date,morning_range,afternoon_range,note) VALUES
(1,'2026-10-24','09:00-12:00','14:00-17:00','正常班'),
(1,'2026-10-25','09:00-12:00','14:00-16:00','提前下班'),
(2,'2026-10-24','09:00-12:00','休息','培训暂停服务');

-- 预约单（今日 2026-10-24 的进入叫号队列）
INSERT INTO t_appointment(id,appt_no,user_id,item_id,clerk_id,appt_date,time_slot,status,finish_remark) VALUES
(1,'YW202610240001',3,1,NULL,'2026-10-24','09:00-09:30','BOOKED',''),
(2,'YW202610240002',4,3,NULL,'2026-10-24','09:30-10:00','BOOKED',''),
(3,'YW202610240003',4,2,2,'2026-10-24','10:00-10:30','PROCESSING',''),
(4,'YW202610230004',3,4,2,'2026-10-23','14:00-14:30','DONE','材料齐全，当场办结'),
(5,'YW202610230005',4,5,2,'2026-10-23','15:00-15:30','DONE','票据审核通过，等待拨付');

-- 材料预审记录
INSERT INTO t_material(appointment_id,user_id,file_name,file_type,file_data,status,audit_remark) VALUES
(1,3,'身份证正反面.jpg','image/jpeg','','PENDING',''),
(3,4,'居住证原件扫描.pdf','application/pdf','','APPROVED','材料齐全，核对无误'),
(4,3,'房产证照片.png','image/png','','REJECTED','照片模糊、边角缺失，请重新上传清晰件');

-- 叫号队列（今日）
INSERT INTO t_queue(appointment_id,user_id,window_id,queue_no,status,called_at) VALUES
(1,3,NULL,'A01','WAITING',NULL),
(2,4,NULL,'A02','WAITING',NULL),
(3,4,1,'A03','PROCESSING',NOW());

-- 办结评价
INSERT INTO t_review(appointment_id,user_id,rating,attitude,efficiency,content) VALUES
(4,3,5,5,4,'查询当场出结果，窗口人员很耐心'),
(5,4,4,4,5,'报销流程清楚，希望拨付再快一点');
