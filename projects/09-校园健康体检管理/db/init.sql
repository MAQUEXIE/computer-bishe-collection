-- 09 校园健康体检管理 初始化脚本
CREATE DATABASE IF NOT EXISTS db_09_physical DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_09_physical;

-- ----------------------------
-- 用户表
-- ----------------------------
CREATE TABLE IF NOT EXISTS users (
  id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(100) NOT NULL,
  real_name VARCHAR(50) DEFAULT '',
  role VARCHAR(20) DEFAULT 'student',
  gender VARCHAR(4) DEFAULT '',
  student_no VARCHAR(30) DEFAULT '',
  class_name VARCHAR(50) DEFAULT '',
  phone VARCHAR(30) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 体检机构
-- ----------------------------
CREATE TABLE IF NOT EXISTS institutions (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(20) DEFAULT '校医院',
  address VARCHAR(200) DEFAULT '',
  contact_phone VARCHAR(30) DEFAULT '',
  status VARCHAR(20) DEFAULT 'enabled',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 体检套餐
-- ----------------------------
CREATE TABLE IF NOT EXISTS packages (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(500) DEFAULT '',
  price DECIMAL(10,2) DEFAULT 0,
  apply_gender VARCHAR(4) DEFAULT '不限',
  status VARCHAR(20) DEFAULT 'published',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 套餐项目（含正常值区间）
-- ----------------------------
CREATE TABLE IF NOT EXISTS package_items (
  id INT NOT NULL AUTO_INCREMENT,
  package_id INT NOT NULL,
  item_name VARCHAR(100) NOT NULL,
  unit VARCHAR(20) DEFAULT '',
  item_type VARCHAR(20) DEFAULT 'numeric',
  normal_min DECIMAL(10,2) NULL,
  normal_max DECIMAL(10,2) NULL,
  normal_text VARCHAR(100) DEFAULT '',
  sort_order INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 预约
-- ----------------------------
CREATE TABLE IF NOT EXISTS appointments (
  id INT NOT NULL AUTO_INCREMENT,
  student_id INT NOT NULL,
  package_id INT NOT NULL,
  institution_id INT NOT NULL,
  appoint_date VARCHAR(20) DEFAULT '',
  time_slot VARCHAR(20) DEFAULT '上午',
  status VARCHAR(20) DEFAULT 'booked',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 体检主记录
-- ----------------------------
CREATE TABLE IF NOT EXISTS exam_records (
  id INT NOT NULL AUTO_INCREMENT,
  record_no VARCHAR(50) NOT NULL UNIQUE,
  student_id INT NOT NULL,
  package_id INT NOT NULL,
  appointment_id INT NULL,
  institution_id INT NOT NULL,
  exam_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  doctor_id INT NULL,
  overall_conclusion VARCHAR(500) DEFAULT '',
  status VARCHAR(20) DEFAULT 'entering',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 体检结果明细
-- ----------------------------
CREATE TABLE IF NOT EXISTS exam_results (
  id INT NOT NULL AUTO_INCREMENT,
  record_id INT NOT NULL,
  package_item_id INT NOT NULL,
  item_name VARCHAR(100) NOT NULL,
  unit VARCHAR(20) DEFAULT '',
  value_num DECIMAL(10,2) NULL,
  value_text VARCHAR(100) DEFAULT '',
  judge VARCHAR(20) DEFAULT 'normal',
  note VARCHAR(200) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 异常记录 / 复查提醒
-- ----------------------------
CREATE TABLE IF NOT EXISTS alerts (
  id INT NOT NULL AUTO_INCREMENT,
  result_id INT NULL,
  record_id INT NOT NULL,
  student_id INT NOT NULL,
  item_name VARCHAR(100) NOT NULL,
  abnormal_type VARCHAR(20) DEFAULT 'high',
  value_desc VARCHAR(100) DEFAULT '',
  advice VARCHAR(300) DEFAULT '',
  remind_date VARCHAR(20) DEFAULT '',
  status VARCHAR(20) DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 初始化账号：admin / medic / student + 12 名学生
-- ----------------------------
INSERT INTO users (username, password, real_name, role, gender, student_no, class_name, phone) VALUES
('admin',  '123456', '系统管理员', 'admin',  '',    '',           '',           ''),
('medic',  '123456', '王校医',     'medic',  '女',  '',           '',           '0596-6666666'),
('student','123456', '张三',       'student','男',  '20240101',   '高一(1)班',  '13900000001'),
('student1','123456', '李四',      'student','男',  '20240102',   '高一(1)班',  '13900000002'),
('student2','123456', '王五',      'student','女',  '20240103',   '高一(2)班',  '13900000003'),
('student3','123456', '孙八',      'student','男',  '20240104',   '高一(2)班',  '13900000004'),
('student4','123456', '周九',      'student','女',  '20240105',   '高一(3)班',  '13900000005'),
('student5','123456', '吴十',      'student','男',  '20240106',   '高一(3)班',  '13900000006'),
('student6','123456', '郑一',      'student','女',  '20240201',   '高二(1)班',  '13900000007'),
('student7','123456', '冯二',      'student','男',  '20240202',   '高二(1)班',  '13900000008'),
('student8','123456', '陈三',      'student','女',  '20240203',   '高二(2)班',  '13900000009'),
('student9','123456', '褚四',      'student','男',  '20240204',   '高二(2)班',  '13900000010'),
('student10','123456','卫五',      'student','女',  '20240205',   '高二(3)班',  '13900000011'),
('student11','123456','蒋六',      'student','男',  '20240206',   '高二(3)班',  '13900000012');

-- ----------------------------
-- 体检机构
-- ----------------------------
INSERT INTO institutions (name, category, address, contact_phone, status) VALUES
('校医院门诊部',   '校医院',   '校内东区1号楼1层',   '0596-8800001', 'enabled'),
('市第一人民医院体检中心', '合作医院', '市区健康路88号', '0596-8800002', 'enabled'),
('区妇幼保健院',   '合作医院', '区中山路120号',      '0596-8800003', 'disabled');

-- ----------------------------
-- 体检套餐（4 个）
-- ----------------------------
INSERT INTO packages (name, description, price, apply_gender, status) VALUES
('基础体检套餐',   '身高体重、血压、心率、视力，适合常规入学体检',  50.00,  '不限', 'published'),
('中学生标准套餐', '在基础项目上增加血常规、血糖、尿常规、肝功能', 120.00, '不限', 'published'),
('女生关爱套餐',   '针对女生的专项体检：含血红蛋白、血糖、妇科常规', 150.00, '女',   'published'),
('全面深度套餐',   '全套血生化、胸片、心电图，适合毕业班重点监测', 280.00, '不限', 'published');

-- ----------------------------
-- 套餐项目：正常值区间
-- ----------------------------
-- 套餐1 基础
INSERT INTO package_items (package_id, item_name, unit, item_type, normal_min, normal_max, normal_text, sort_order) VALUES
(1, '身高',     'cm',   'numeric', NULL,   NULL,   '',   1),
(1, '体重',     'kg',   'numeric', NULL,   NULL,   '',   2),
(1, '收缩压',   'mmHg', 'numeric', 90,     140,    '',   3),
(1, '舒张压',   'mmHg', 'numeric', 60,     90,     '',   4),
(1, '心率',     '次/分','numeric', 60,     100,    '',   5),
(1, '左眼视力', '',     'numeric', 4.0,    5.3,    '',   6),
(1, '右眼视力', '',     'numeric', 4.0,    5.3,    '',   7);

-- 套餐2 标准
INSERT INTO package_items (package_id, item_name, unit, item_type, normal_min, normal_max, normal_text, sort_order) VALUES
(2, '身高',     'cm',   'numeric', NULL,   NULL,   '',   1),
(2, '体重',     'kg',   'numeric', NULL,   NULL,   '',   2),
(2, '收缩压',   'mmHg', 'numeric', 90,     140,    '',   3),
(2, '舒张压',   'mmHg', 'numeric', 60,     90,     '',   4),
(2, '血红蛋白', 'g/L',  'numeric', 120,    160,    '',   5),
(2, '空腹血糖', 'mmol/L','numeric',3.9,    6.1,    '',   6),
(2, '尿常规蛋白','',    'text',    NULL,   NULL,   '阴性', 7),
(2, '谷丙转氨酶','U/L', 'numeric', 0,      40,     '',   8);

-- 套餐3 女生关爱
INSERT INTO package_items (package_id, item_name, unit, item_type, normal_min, normal_max, normal_text, sort_order) VALUES
(3, '身高',     'cm',   'numeric', NULL,   NULL,   '',   1),
(3, '体重',     'kg',   'numeric', NULL,   NULL,   '',   2),
(3, '收缩压',   'mmHg', 'numeric', 90,     140,    '',   3),
(3, '血红蛋白', 'g/L',  'numeric', 110,    150,    '',   4),
(3, '空腹血糖', 'mmol/L','numeric',3.9,    6.1,    '',   5),
(3, '白带常规', '',     'text',    NULL,   NULL,   '正常', 6);

-- 套餐4 深度
INSERT INTO package_items (package_id, item_name, unit, item_type, normal_min, normal_max, normal_text, sort_order) VALUES
(4, '收缩压',   'mmHg', 'numeric', 90,     140,    '',   1),
(4, '舒张压',   'mmHg', 'numeric', 60,     90,     '',   2),
(4, '血红蛋白', 'g/L',  'numeric', 120,    160,    '',   3),
(4, '空腹血糖', 'mmol/L','numeric',3.9,    6.1,    '',   4),
(4, '谷丙转氨酶','U/L', 'numeric', 0,      40,     '',   5),
(4, '总胆固醇', 'mmol/L','numeric',2.8,    5.2,    '',   6),
(4, '尿酸',     'μmol/L','numeric',208,    428,    '',   7),
(4, '胸片',     '',     'text',    NULL,   NULL,   '未见异常', 8),
(4, '心电图',   '',     'text',    NULL,   NULL,   '窦性心律', 9);

-- ----------------------------
-- 预约演示数据
-- ----------------------------
INSERT INTO appointments (student_id, package_id, institution_id, appoint_date, time_slot, status) VALUES
(3, 1, 1, '2026-10-25', '上午', 'booked'),   -- student 张三 待体检
(4, 2, 1, '2026-10-20', '上午', 'done'),     -- 李四 已体检
(5, 1, 1, '2026-10-25', '下午', 'booked'),   -- 王五 待体检
(6, 4, 2, '2026-10-26', '上午', 'booked'),   -- 孙八 待体检
(7, 2, 1, '2026-10-21', '下午', 'done'),     -- 周九 已体检
(8, 3, 1, '2026-10-27', '上午', 'booked');   -- 郑一 待体检

-- ----------------------------
-- 体检记录：student(3) 已有一份完成报告；student1(4) 已有一份完成报告
-- ----------------------------
INSERT INTO exam_records (record_no, student_id, package_id, appointment_id, institution_id, exam_date, doctor_id, overall_conclusion, status) VALUES
('EXAM20260915001', 3, 2, NULL, 1, '2026-09-15 09:30:00', 2, '血压偏高，建议监测后复查', 'done'),
('EXAM20261020002', 4, 2, 2,    1, '2026-10-20 10:00:00', 2, '基本正常，视力略低',       'done');

-- student(3) 报告明细：收缩压偏高(145)、心率偏高(105)，其余正常
INSERT INTO exam_results (record_id, package_item_id, item_name, unit, value_num, value_text, judge, note) VALUES
(1, 9,  '身高',     'cm',    172.0, '', 'normal', ''),
(1, 10, '体重',     'kg',    62.0,  '', 'normal', ''),
(1, 11, '收缩压',   'mmHg',  145.0, '', 'high',   ''),
(1, 12, '舒张压',   'mmHg',  92.0,  '', 'high',   ''),
(1, 13, '血红蛋白', 'g/L',   145.0, '', 'normal', ''),
(1, 14, '空腹血糖', 'mmol/L',5.1,   '', 'normal', ''),
(1, 15, '尿常规蛋白','',     NULL,  '阴性','normal',''),
(1, 16, '谷丙转氨酶','U/L',  22.0,  '', 'normal', '');

-- student1(4) 报告明细：左眼视力偏低(4.0) 边界内 normal；血红蛋白偏低
INSERT INTO exam_results (record_id, package_item_id, item_name, unit, value_num, value_text, judge, note) VALUES
(2, 9,  '身高',     'cm',    168.0, '', 'normal', ''),
(2, 10, '体重',     'kg',    58.0,  '', 'normal', ''),
(2, 11, '收缩压',   'mmHg',  120.0, '', 'normal', ''),
(2, 12, '舒张压',   'mmHg',  78.0,  '', 'normal', ''),
(2, 13, '血红蛋白', 'g/L',   108.0, '', 'low',    '低于正常下限'),
(2, 14, '空腹血糖', 'mmol/L',5.3,   '', 'normal', ''),
(2, 15, '尿常规蛋白','',     NULL,  '阴性','normal',''),
(2, 16, '谷丙转氨酶','U/L',  18.0,  '', 'normal', '');

-- ----------------------------
-- 异常 / 复查提醒
-- ----------------------------
INSERT INTO alerts (result_id, record_id, student_id, item_name, abnormal_type, value_desc, advice, remind_date, status) VALUES
(3, 1, 3, '收缩压', 'high', '145 mmHg', '指标偏高，建议清淡饮食、一周后复查', '2026-09-22', 'pending'),
(4, 1, 3, '舒张压', 'high', '92 mmHg',  '指标偏高，建议清淡饮食、一周后复查', '2026-09-22', 'pending'),
(13,2, 4, '血红蛋白','low', '108 g/L',  '指标偏低，注意营养补充并复查',       '2026-10-27', 'pending');
