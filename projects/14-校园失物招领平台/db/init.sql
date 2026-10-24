-- 14 校园失物招领平台 初始化 SQL
DROP DATABASE IF EXISTS db_14_lostfound;
CREATE DATABASE db_14_lostfound DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_14_lostfound;

-- ---------------- users ----------------
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(100) NOT NULL,
  real_name VARCHAR(50) DEFAULT '',
  role VARCHAR(20) DEFAULT 'student',
  student_no VARCHAR(30) DEFAULT '',
  phone VARCHAR(30) DEFAULT '',
  created_at DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO users (id, username, password, real_name, role, student_no, phone, created_at) VALUES
(1, 'admin',   '123456', '平台管理员', 'admin',   '',           '',           '2026-09-01 09:00:00'),
(2, 'student',  '123456', '张同学',     'student', '2023001001', '13800000001','2026-09-01 09:10:00'),
(3, 'liming',   '123456', '李明',       'student', '2023001002', '13800000002','2026-09-02 10:00:00'),
(4, 'wangfang', '123456', '王芳',       'student', '2023001003', '13800000003','2026-09-03 11:00:00');

-- ---------------- items ----------------
CREATE TABLE items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  type VARCHAR(10) NOT NULL,
  title VARCHAR(200) NOT NULL,
  category VARCHAR(50) DEFAULT '其他',
  color VARCHAR(50) DEFAULT '',
  location VARCHAR(200) DEFAULT '',
  happened_at DATETIME,
  description TEXT,
  image VARCHAR(255) DEFAULT '',
  owner_id INT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  audit_remark VARCHAR(255) DEFAULT '',
  created_at DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- type: lost=寻物启事(我丢了), found=失物招领(我捡到)
INSERT INTO items (id, type, title, category, color, location, happened_at, description, image, owner_id, status, audit_remark, created_at) VALUES
-- 已通过审核、可被搜索的失物/招领
(1, 'lost',  '丢失校园卡一张',           '证件',     '蓝色',   '第一教学楼3楼',  '2026-10-20 14:30', '卡面有照片，姓名拼音 ZHANG，卡号尾号 8899，内夹二十元现金。', '/covers/card.svg',     2, 'approved', '', '2026-10-20 15:00:00'),
(2, 'found', '捡到校园卡一张',           '证件',     '蓝色',   '第一教学楼2楼',  '2026-10-20 15:10', '在第一教学楼2楼走廊长椅上捡到，卡套为蓝色，已交至招领处。', '/covers/card.svg',     3, 'approved', '', '2026-10-20 16:00:00'),
(3, 'lost',  '丢失黑色无线耳机',         '电子设备', '黑色',   '图书馆三楼',     '2026-10-18 20:00', '蓝牙耳机，充电盒有划痕，品牌为某果，耳机仓内侧贴有小白贴纸。', '/covers/earphone.svg', 2, 'approved', '', '2026-10-18 21:00:00'),
(4, 'found', '捡到无线耳机一只',         '电子设备', '白色',   '图书馆二楼',     '2026-10-19 10:00', '在图书馆二楼自习区捡到一只耳机，非充电盒。', '/covers/earphone.svg', 4, 'approved', '', '2026-10-19 11:00:00'),
(5, 'lost',  '丢失一串宿舍钥匙',         '钥匙',     '银色',   '宿舍区7号楼',    '2026-10-15 18:00', '共3把钥匙，带粉色小熊挂件，另有一个U盘。', '/covers/keys.svg',      3, 'approved', '', '2026-10-15 19:00:00'),
(6, 'found', '捡到一串钥匙',             '钥匙',     '银色',   '宿舍区5号楼',    '2026-10-16 09:00', '一串钥匙共4把，挂有蓝色塑料牌。', '/covers/keys.svg',      4, 'approved', '', '2026-10-16 10:00:00'),
(7, 'lost',  '丢失天蓝色雨伞',           '其他',     '蓝色',   '第二食堂门口',    '2026-10-12 12:30', '折叠伞，伞柄处有磕碰掉漆。', '/covers/umbrella.svg', 2, 'approved', '', '2026-10-12 13:00:00'),
(8, 'found', '捡到黑色双肩包',           '箱包',     '黑色',   '操场看台',       '2026-10-10 17:00', '运动双肩包，内有一本《高等数学》课本。', '/covers/bag.svg',       3, 'approved', '', '2026-10-10 18:00:00'),
(9, 'lost',  '丢失《数据结构》课本',      '图书',     '白色',   '实验楼B座',      '2026-10-08 15:00', '书内有笔记，扉页签名"李明"。', '/covers/book.svg',      3, 'approved', '', '2026-10-08 16:00:00'),
(10,'found', '捡到一件灰色外套',         '衣物',     '灰色',   '体育馆更衣室',   '2026-10-05 20:00', '连帽卫衣，左袖口有小破洞。', '/covers/cloth.svg',     4, 'approved', '', '2026-10-05 21:00:00'),
-- 待审核（管理员待处理）
(11,'lost',  '丢失Apple Watch手表',      '电子设备', '黑色',   '操场跑道',       '2026-10-22 08:00', '表盘44mm，表带为运动黑色。', '/covers/watch.svg',     2, 'pending',  '', '2026-10-22 09:00:00'),
(12,'found', '捡到粉色保温杯',           '其他',     '粉色',   '第一食堂',       '2026-10-22 12:30', '不锈钢保温杯，杯身印卡通兔子。', '/covers/cup.svg',       3, 'pending',  '', '2026-10-22 13:00:00'),
-- 已驳回示例
(13,'lost',  '求借一辆自行车',           '其他',     '',       '校门',           NULL,               '本人近期想借一辆自行车代步，非失物。', '/covers/default.svg',   4, 'rejected', '该内容非失物招领范畴', '2026-10-21 10:00:00'),
-- 已认领闭环示例
(14,'found', '捡到一个蓝色笔记本',       '图书',     '蓝色',   '第一教学楼1楼',  '2026-09-28 09:00', '硬皮本，内有课程笔记。', '/covers/book.svg',      4, 'claimed',  '', '2026-09-28 10:00:00');

-- ---------------- claims ----------------
CREATE TABLE claims (
  id INT PRIMARY KEY AUTO_INCREMENT,
  item_id INT NOT NULL,
  applicant_id INT NOT NULL,
  proof_desc TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  handle_remark VARCHAR(255) DEFAULT '',
  created_at DATETIME,
  handled_at DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO claims (id, item_id, applicant_id, proof_desc, status, handle_remark, created_at, handled_at) VALUES
-- student(2) 申请认领 item 2（蓝色校园卡）——待管理员处理
(1, 2, 2, '卡面姓名拼音 ZHANG，卡号尾号8899，内夹20元。', 'pending', '', '2026-10-21 10:00:00', NULL),
-- 已通过示例：item14 蓝色笔记本被李明认领
(2, 14, 3, '笔记本内第3页写有"数据结构作业"字样，扉页签名李明。', 'approved', '特征核对一致', '2026-09-29 09:00:00', '2026-09-29 15:00:00'),
-- 已驳回示例
(3, 6, 2, '钥匙上有粉色小熊挂件。', 'rejected', '该钥匙为银色4把带蓝色牌，与描述不符', '2026-10-17 09:00:00', '2026-10-17 16:00:00');

-- ---------------- notices ----------------
CREATE TABLE notices (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  ntype VARCHAR(20) DEFAULT 'system',
  is_read INT DEFAULT 0,
  created_at DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO notices (user_id, title, content, ntype, is_read, created_at) VALUES
(2, '欢迎使用失物招领平台', '请在发布前准确填写物品类别、颜色与丢失地点，系统会自动为你匹配相似信息。', 'system', 0, '2026-10-15 09:00:00'),
(2, '你的发布已通过审核', '「丢失校园卡一张」已通过审核并公开展示。', 'audit', 0, '2026-10-20 15:30:00'),
(2, '收到新的认领申请', '有人对你招领的物品提交了认领申请，请留意。', 'claim', 1, '2026-10-21 10:05:00'),
(3, '发现与你物品高度匹配的信息', '「捡到校园卡一张」与你发布的「丢失校园卡一张」匹配度 70 分：类别一致、颜色一致、地点相近。', 'match', 0, '2026-10-20 16:30:00'),
(3, '认领申请通过', '你对「捡到一个蓝色笔记本」的认领申请已通过，请联系招领人线下领取。', 'claim', 1, '2026-09-29 15:00:00');

-- ---------------- announcements ----------------
CREATE TABLE announcements (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  publisher VARCHAR(50) DEFAULT '管理员',
  status VARCHAR(20) DEFAULT 'published',
  created_at DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO announcements (title, content, publisher, status, created_at) VALUES
('失物招领平台上线公告', '为提升校园失物找回效率，本平台正式上线。师生可发布寻物/招领信息，系统将按类别、颜色、地点自动匹配，请及时查收站内通知。', '平台管理员', 'published', '2026-10-01 10:00:00'),
('线下领取地点通知', '所有招领物品统一存放于学生活动中心102招领处，工作时间为工作日 9:00-17:00，请携带有效证件前往领取。', '平台管理员', 'published', '2026-10-10 09:30:00'),
('请勿发布非失物信息', '为保证信息质量，平台仅受理真实的失物/招领信息，求借、广告等内容将被驳回并通知。', '平台管理员', 'published', '2026-10-15 14:00:00');
