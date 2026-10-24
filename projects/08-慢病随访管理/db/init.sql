-- ============================================================
-- 08 慢病随访管理系统 初始化脚本
-- 库: db_08_chronic  utf8mb4
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_08_chronic DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_08_chronic;

-- ---------- 用户表 ----------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64),
  phone VARCHAR(32),
  gender VARCHAR(8),
  age INT,
  role VARCHAR(16) NOT NULL COMMENT 'ADMIN/DOCTOR/PATIENT',
  status INT DEFAULT 1,
  group_id BIGINT DEFAULT 0,
  disease_type VARCHAR(32) COMMENT 'HYPERTENSION高血压/DIABETES糖尿病/CORONARY冠心病',
  risk_level VARCHAR(16) COMMENT 'LOW/MID/HIGH',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 患者分组 ----------
DROP TABLE IF EXISTS t_group;
CREATE TABLE t_group (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(64) NOT NULL,
  disease_type VARCHAR(32),
  description VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 随访计划模板 ----------
DROP TABLE IF EXISTS t_plan_template;
CREATE TABLE t_plan_template (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(64) NOT NULL,
  disease_type VARCHAR(32),
  risk_level VARCHAR(16),
  interval_days INT COMMENT '随访间隔天数',
  content VARCHAR(500),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 随访计划 ----------
DROP TABLE IF EXISTS t_followup_plan;
CREATE TABLE t_followup_plan (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  doctor_id BIGINT,
  template_id BIGINT,
  plan_date DATE,
  content VARCHAR(500),
  status VARCHAR(16) DEFAULT 'PENDING' COMMENT 'PENDING待随访/DONE已完成/MISSED已逾期',
  reply_content VARCHAR(500),
  reply_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 指标记录 ----------
DROP TABLE IF EXISTS t_indicator;
CREATE TABLE t_indicator (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  type VARCHAR(24) NOT NULL COMMENT 'BP_SYSTOLIC收缩压/BP_DIASTOLIC舒张压/GLUCOSE空腹血糖/HEART_RATE心率/WEIGHT体重',
  value DECIMAL(10,2),
  measured_at DATETIME,
  status VARCHAR(16) DEFAULT 'NORMAL' COMMENT 'NORMAL/ABNORMAL',
  remark VARCHAR(255),
  review_status VARCHAR(16) DEFAULT 'PENDING' COMMENT 'PENDING待审核/APPROVED已通过/REJECTED已驳回',
  review_remark VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 预警记录 ----------
DROP TABLE IF EXISTS t_warning;
CREATE TABLE t_warning (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  indicator_id BIGINT,
  level VARCHAR(16) DEFAULT 'MID' COMMENT 'LOW/MID/HIGH',
  content VARCHAR(500),
  status VARCHAR(16) DEFAULT 'UNPROCESSED' COMMENT 'UNPROCESSED/PROCESSED',
  handler_id BIGINT,
  handle_remark VARCHAR(500),
  handled_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 用药提醒 ----------
DROP TABLE IF EXISTS t_medication;
CREATE TABLE t_medication (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  drug_name VARCHAR(64),
  dosage VARCHAR(64),
  frequency VARCHAR(64),
  remind_time VARCHAR(32),
  status VARCHAR(16) DEFAULT 'ON' COMMENT 'ON/OFF',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 演示数据
-- ============================================================

-- 用户：管理员/医生/患者
INSERT INTO t_user(username,password,nickname,phone,gender,age,role,status,group_id,disease_type,risk_level) VALUES
('admin','123456','系统管理员','13800000000','男',35,'ADMIN',1,0,NULL,NULL),
('doctor','123456','李医生','13900000001','女',42,'DOCTOR',1,0,NULL,NULL),
('patient','123456','王大爷','13700000002','男',62,'PATIENT',1,1,'HYPERTENSION','MID'),
('zhangwei','123456','张伟','13700000003','男',55,'PATIENT',1,1,'HYPERTENSION','HIGH'),
('liuyang','123456','刘洋','13700000004','女',48,'PATIENT',1,2,'DIABETES','MID'),
('chenjing','123456','陈静','13700000005','女',60,'PATIENT',1,2,'DIABETES','HIGH'),
('zhaolei','123456','赵磊','13700000006','男',68,'PATIENT',1,3,'CORONARY','LOW');

-- 患者分组（≥3）
INSERT INTO t_group(name,disease_type,description) VALUES
('高血压管理组','HYPERTENSION','原发性高血压患者日常血压监测与用药指导'),
('糖尿病管理组','DIABETES','2型糖尿病患者血糖监测与饮食运动干预'),
('冠心病管理组','CORONARY','冠心病术后/稳定期患者随访与康复指导');

-- 计划模板（按病种+风险等级）
INSERT INTO t_plan_template(name,disease_type,risk_level,interval_days,content) VALUES
('高血压低危随访模板','HYPERTENSION','LOW',90,'每3个月随访一次，测量血压、心率，评估用药依从性，给予生活方式指导'),
('高血压中危随访模板','HYPERTENSION','MID',30,'每月随访一次，监测血压变化，调整降压药方案，关注头晕头痛等症状'),
('高血压高危随访模板','HYPERTENSION','HIGH',14,'每2周随访一次，密切监测血压，警惕高血压急症，必要时转诊上级医院'),
('糖尿病低危随访模板','DIABETES','LOW',90,'每3个月随访一次，复查空腹血糖、糖化血红蛋白，饮食运动指导'),
('糖尿病中危随访模板','DIABETES','MID',30,'每月随访一次，监测空腹/餐后血糖，评估降糖药效果，预防低血糖'),
('糖尿病高危随访模板','DIABETES','HIGH',14,'每2周随访一次，强化血糖监测，筛查糖尿病并发症，调整胰岛素方案'),
('冠心病常规随访模板','CORONARY','LOW',90,'每3个月随访一次，评估心绞痛发作情况，复查心电图，指导康复运动');

-- 用药提醒
INSERT INTO t_medication(patient_id,drug_name,dosage,frequency,remind_time,status) VALUES
(3,'苯磺酸氨氯地平片','5mg/次','每日一次','08:00','ON'),
(3,'阿司匹林肠溶片','100mg/次','每日一次','20:00','ON'),
(4,'缬沙坦胶囊','80mg/次','每日两次','08:00/20:00','ON'),
(4,'硝苯地平控释片','30mg/次','每日一次','08:00','ON'),
(5,'二甲双胍片','0.5g/次','每日三次','08:00/12:00/18:00','ON'),
(6,'格列美脲片','2mg/次','每日一次','早餐前','ON'),
(6,'甘精胰岛素','12IU/次','每日一次','睡前22:00','ON'),
(7,'单硝酸异山梨酯','20mg/次','每日两次','08:00/20:00','ON');

-- 指标记录（含正常与异常）
INSERT INTO t_indicator(patient_id,type,value,measured_at,status,remark,review_status) VALUES
-- 王大爷 patient=3 高血压
(3,'BP_SYSTOLIC',145.00,'2026-10-20 08:00:00','ABNORMAL','晨起自测','PENDING'),
(3,'BP_DIASTOLIC',92.00,'2026-10-20 08:00:00','ABNORMAL','晨起自测','PENDING'),
(3,'HEART_RATE',78.00,'2026-10-20 08:00:00','NORMAL','','APPROVED'),
(3,'BP_SYSTOLIC',138.00,'2026-10-10 08:00:00','NORMAL','','APPROVED'),
-- 张伟 patient=4 高血压高危
(4,'BP_SYSTOLIC',168.00,'2026-10-21 08:00:00','ABNORMAL','头晕伴恶心','PENDING'),
(4,'BP_DIASTOLIC',105.00,'2026-10-21 08:00:00','ABNORMAL','头晕伴恶心','PENDING'),
-- 刘洋 patient=5 糖尿病
(5,'GLUCOSE',6.20,'2026-10-20 07:30:00','NORMAL','空腹','APPROVED'),
(5,'GLUCOSE',8.50,'2026-10-15 07:30:00','ABNORMAL','空腹偏高','PENDING'),
-- 陈静 patient=6 糖尿病高危
(6,'GLUCOSE',11.80,'2026-10-22 07:30:00','ABNORMAL','口渴多饮','PENDING'),
(6,'GLUCOSE',5.60,'2026-10-10 07:30:00','NORMAL','','APPROVED'),
-- 赵磊 patient=7 冠心病
(7,'HEART_RATE',72.00,'2026-10-18 09:00:00','NORMAL','','APPROVED'),
(7,'BP_SYSTOLIC',125.00,'2026-10-18 09:00:00','NORMAL','','APPROVED');

-- 预警记录（由异常指标自动生成）
INSERT INTO t_warning(patient_id,indicator_id,level,content,status) VALUES
(3,1,'MID','王大爷 收缩压145mmHg 舒张压92mmHg，超出正常范围，建议调整用药并复测','UNPROCESSED'),
(4,5,'HIGH','张伟 收缩压168mmHg 舒张压105mmHg，伴头晕恶心，属高血压急症风险，建议立即联系患者','UNPROCESSED'),
(5,8,'MID','刘洋 空腹血糖8.5mmol/L，偏高，建议饮食控制并复测','UNPROCESSED'),
(6,9,'HIGH','陈静 空腹血糖11.8mmol/L，伴口渴多饮，警惕酮症酸中毒，建议尽快就诊','UNPROCESSED');

-- 随访计划
INSERT INTO t_followup_plan(patient_id,doctor_id,template_id,plan_date,content,status,reply_content,reply_at) VALUES
(3,2,2,'2026-11-05','每月随访一次，监测血压变化，调整降压药方案，关注头晕头痛等症状','PENDING',NULL,NULL),
(4,2,3,'2026-10-30','每2周随访一次，密切监测血压，警惕高血压急症，必要时转诊上级医院','PENDING',NULL,NULL),
(5,2,5,'2026-11-05','每月随访一次，监测空腹/餐后血糖，评估降糖药效果，预防低血糖','PENDING',NULL,NULL),
(6,2,6,'2026-10-30','每2周随访一次，强化血糖监测，筛查糖尿病并发症，调整胰岛素方案','PENDING',NULL,NULL),
(7,2,7,'2026-12-20','每3个月随访一次，评估心绞痛发作情况，复查心电图，指导康复运动','DONE','近期无胸闷胸痛，按时服药，运动良好','2026-10-15 10:00:00');
