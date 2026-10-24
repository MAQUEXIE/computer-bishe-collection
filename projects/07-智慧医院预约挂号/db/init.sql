-- ============================================================
-- 07 智慧医院预约挂号 初始化脚本
-- 库名：db_07_hospital (utf8mb4)
-- 账号：admin/123456（管理员） doctor/123456（医生-张伟） patient/123456（患者-李华）
--       doc2..doc6 / patient2 密码均 123456
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_07_hospital DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_07_hospital;

DROP TABLE IF EXISTS t_notification;
DROP TABLE IF EXISTS t_bill;
DROP TABLE IF EXISTS t_prescription;
DROP TABLE IF EXISTS t_medical_record;
DROP TABLE IF EXISTS t_appointment;
DROP TABLE IF EXISTS t_schedule;
DROP TABLE IF EXISTS t_doctor;
DROP TABLE IF EXISTS t_department;
DROP TABLE IF EXISTS t_user;

-- ---------------- 用户 ----------------
CREATE TABLE t_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64) NOT NULL,
  phone VARCHAR(32) DEFAULT '',
  role VARCHAR(16) NOT NULL COMMENT 'ADMIN/DOCTOR/PATIENT',
  status TINYINT DEFAULT 1 COMMENT '1正常 0停用',
  created_at DATETIME DEFAULT NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 科室 ----------------
CREATE TABLE t_department (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  description VARCHAR(255) DEFAULT '',
  created_at DATETIME DEFAULT NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 医生 ----------------
CREATE TABLE t_doctor (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  name VARCHAR(64) NOT NULL,
  title VARCHAR(32) DEFAULT '主治医师',
  department_id BIGINT NOT NULL,
  specialty VARCHAR(128) DEFAULT '',
  intro VARCHAR(512) DEFAULT '',
  fee DECIMAL(10,2) DEFAULT 20.00,
  status TINYINT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 排班/号源（分时段） ----------------
CREATE TABLE t_schedule (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  doctor_id BIGINT NOT NULL,
  department_id BIGINT NOT NULL,
  work_date DATE NOT NULL COMMENT '出诊日期',
  time_slot VARCHAR(32) NOT NULL COMMENT '时段 如 08:00-09:00',
  total_quota INT NOT NULL DEFAULT 10 COMMENT '该时段总号源',
  booked_count INT NOT NULL DEFAULT 0 COMMENT '已挂出号源',
  status VARCHAR(16) DEFAULT 'NORMAL' COMMENT 'NORMAL正常 CANCELLED停诊',
  note VARCHAR(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 挂号记录 ----------------
CREATE TABLE t_appointment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  appointment_no VARCHAR(32) NOT NULL,
  patient_id BIGINT NOT NULL,
  doctor_id BIGINT NOT NULL,
  department_id BIGINT NOT NULL,
  schedule_id BIGINT NULL,
  work_date DATE NOT NULL,
  time_slot VARCHAR(32) NOT NULL,
  fee DECIMAL(10,2) DEFAULT 0,
  status VARCHAR(16) DEFAULT 'REGISTERED' COMMENT 'REGISTERED已挂号/CALLED已叫号/COMPLETED已完成/CANCELLED已取消/RESCHEDULED已改约',
  queue_no INT DEFAULT 0,
  notify_msg VARCHAR(512) DEFAULT NULL,
  created_at DATETIME DEFAULT NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 病历 ----------------
CREATE TABLE t_medical_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  appointment_id BIGINT NOT NULL,
  patient_id BIGINT NOT NULL,
  doctor_id BIGINT NOT NULL,
  department_id BIGINT NOT NULL,
  work_date DATE,
  diagnosis VARCHAR(255) DEFAULT '',
  advice VARCHAR(512) DEFAULT '',
  created_at DATETIME DEFAULT NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 处方 ----------------
CREATE TABLE t_prescription (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  record_id BIGINT NOT NULL,
  patient_id BIGINT NOT NULL,
  doctor_id BIGINT NOT NULL,
  drug_name VARCHAR(128) NOT NULL,
  dosage VARCHAR(128) DEFAULT '',
  days INT DEFAULT 1,
  note VARCHAR(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 费用账单 ----------------
CREATE TABLE t_bill (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  appointment_id BIGINT,
  doctor_id BIGINT,
  department_id BIGINT,
  item_name VARCHAR(128) NOT NULL,
  amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  pay_status VARCHAR(16) DEFAULT 'UNPAID' COMMENT 'UNPAID/PAID',
  created_at DATETIME DEFAULT NOW(),
  paid_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------- 站内通知 ----------------
CREATE TABLE t_notification (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  title VARCHAR(128) NOT NULL,
  content VARCHAR(512) DEFAULT '',
  is_read TINYINT DEFAULT 0,
  created_at DATETIME DEFAULT NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户账号（密码均 123456）
INSERT INTO t_user(id,username,password,nickname,phone,role,status) VALUES
(1,'admin','123456','系统管理员','13800000001','ADMIN',1),
(2,'doctor','123456','张伟','13800000002','DOCTOR',1),
(3,'patient','123456','李华','13900000003','PATIENT',1),
(4,'doc2','123456','王芳','13800000004','DOCTOR',1),
(5,'doc3','123456','李强','13800000005','DOCTOR',1),
(6,'doc4','123456','赵丽','13800000006','DOCTOR',1),
(7,'doc5','123456','孙明','13800000007','DOCTOR',1),
(8,'doc6','123456','陈静','13800000008','DOCTOR',1),
(9,'patient2','123456','王五','13900000009','PATIENT',1);

-- 科室（6个）
INSERT INTO t_department(id,name,description) VALUES
(1,'心血管内科','高血压、冠心病、心律失常等心血管疾病诊疗'),
(2,'普外科','胃肠、肝胆、甲状腺等常见外科手术'),
(3,'儿科','儿童呼吸、消化、保健与预防接种'),
(4,'眼科','白内障、青光眼、近视矫正与眼底病'),
(5,'口腔科','补牙、拔牙、种植牙、牙齿矫正'),
(6,'妇产科','围产保健、妇科炎症与孕期检查');

-- 医生（6位，含登录账号）
INSERT INTO t_doctor(id,user_id,name,title,department_id,specialty,intro,fee,status) VALUES
(1,2,'张伟','主任医师',1,'冠心病/高血压/心律失常','从事心血管内科临床25年，主持心脏介入手术2000余例。',50.00,1),
(2,4,'王芳','副主任医师',2,'胃肠外科/疝修补','擅长腹腔镜微创手术，在胃肠肿瘤规范化治疗方面经验丰富。',30.00,1),
(3,5,'李强','主任医师',3,'儿童呼吸/小儿咳喘','儿科临床20年，擅长儿童呼吸道感染、哮喘规范管理。',40.00,1),
(4,6,'赵丽','主治医师',4,'白内障/近视矫正','专注眼科常见病诊疗，完成白内障超声乳化手术千余例。',25.00,1),
(5,7,'孙明','副主任医师',5,'种植牙/口腔修复','擅长各类复杂牙列缺损种植修复与无痛拔牙。',35.00,1),
(6,8,'陈静','主任医师',6,'围产保健/高危妊娠','妇产科工作23年，擅长高危妊娠管理与产科合并症处理。',45.00,1);

-- 排班号源（相对当前日期，保证始终有可约号源）
-- 张伟(doctor1, dept1)：今天有候诊队列数据；+1/+2/+3 有未来号源；104 已被李华挂号（演示停诊改约）
INSERT INTO t_schedule(id,doctor_id,department_id,work_date,time_slot,total_quota,booked_count,status,note) VALUES
(100,1,1,CURDATE(),        '09:00-10:00', 5, 2, 'NORMAL', '今日门诊'),
(101,1,1,CURDATE()+INTERVAL 1 DAY, '08:00-09:00', 5, 0, 'NORMAL', ''),
(102,1,1,CURDATE()+INTERVAL 1 DAY, '09:00-10:00', 5, 0, 'NORMAL', ''),
(103,1,1,CURDATE()+INTERVAL 1 DAY, '10:00-11:00', 3, 0, 'NORMAL', ''),
(104,1,1,CURDATE()+INTERVAL 2 DAY, '14:00-15:00', 4, 1, 'NORMAL', ''),
(105,1,1,CURDATE()+INTERVAL 2 DAY, '15:00-16:00', 4, 0, 'NORMAL', ''),
(106,1,1,CURDATE()+INTERVAL 3 DAY, '08:00-09:00', 5, 0, 'NORMAL', ''),
(201,2,2,CURDATE()+INTERVAL 1 DAY, '08:00-09:00', 5, 0, 'NORMAL', ''),
(202,2,2,CURDATE()+INTERVAL 1 DAY, '09:00-10:00', 5, 0, 'NORMAL', ''),
(301,3,3,CURDATE()+INTERVAL 1 DAY, '09:00-10:00', 6, 0, 'NORMAL', ''),
(302,3,3,CURDATE()+INTERVAL 2 DAY, '10:00-11:00', 6, 0, 'NORMAL', ''),
(401,4,4,CURDATE()+INTERVAL 1 DAY, '14:00-15:00', 5, 0, 'NORMAL', ''),
(501,5,5,CURDATE()+INTERVAL 2 DAY, '08:00-09:00', 5, 0, 'NORMAL', ''),
(601,6,6,CURDATE()+INTERVAL 3 DAY, '09:00-10:00', 5, 0, 'NORMAL', '');

-- 挂号记录
-- id=1：李华挂了 104（+2天下午），将在管理员停诊 104 时演示自动改约
-- id=3,4：李华、王五今天在张伟的候诊队列（演示叫号/接诊）
-- id=2：历史已完成就诊（演示病历与费用）
INSERT INTO t_appointment(id,appointment_no,patient_id,doctor_id,department_id,schedule_id,work_date,time_slot,fee,status,queue_no,notify_msg) VALUES
(1,'GH20261020001',3,1,1,104,CURDATE()+INTERVAL 2 DAY,'14:00-15:00',50.00,'REGISTERED',1001,NULL),
(2,'GH20261021002',3,3,3,NULL,CURDATE()-INTERVAL 3 DAY,'09:00-10:00',40.00,'COMPLETED',2001,NULL),
(3,'GH20261024003',3,1,1,100,CURDATE(),'09:00-10:00',50.00,'REGISTERED',3001,NULL),
(4,'GH20261024004',9,1,1,100,CURDATE(),'09:00-10:00',50.00,'REGISTERED',3002,NULL);

-- 病历（对应 id=2 历史就诊）
INSERT INTO t_medical_record(id,appointment_id,patient_id,doctor_id,department_id,work_date,diagnosis,advice) VALUES
(1,2,3,3,3,CURDATE()-INTERVAL 3 DAY,'上呼吸道感染','多饮水，注意保暖与休息，按时服药，若发热持续超过3天请复诊。');

-- 处方
INSERT INTO t_prescription(id,record_id,patient_id,doctor_id,drug_name,dosage,days,note) VALUES
(1,1,3,3,'感冒清热颗粒','一次1袋 一日3次 开水冲服',3,'饭后服用'),
(2,1,3,3,'布洛芬缓释胶囊','一次1粒 一日2次',2,'体温超过38.5℃时服用');

-- 账单（id=2 历史就诊费用，均已支付）
INSERT INTO t_bill(id,patient_id,appointment_id,doctor_id,department_id,item_name,amount,pay_status,paid_at) VALUES
(1,3,2,3,3,'挂号费',40.00,'PAID',NOW()),
(2,3,2,3,3,'诊疗费',20.00,'PAID',NOW());

ALTER TABLE t_user AUTO_INCREMENT=100;
ALTER TABLE t_department AUTO_INCREMENT=100;
ALTER TABLE t_doctor AUTO_INCREMENT=100;
ALTER TABLE t_schedule AUTO_INCREMENT=1000;
ALTER TABLE t_appointment AUTO_INCREMENT=100;
ALTER TABLE t_medical_record AUTO_INCREMENT=100;
ALTER TABLE t_prescription AUTO_INCREMENT=100;
ALTER TABLE t_bill AUTO_INCREMENT=100;
ALTER TABLE t_notification AUTO_INCREMENT=100;
