-- ============================================================
-- 18 图书馆智慧管理系统  数据库初始化脚本
-- DB: db_18_library  utf8mb4
-- 执行: Get-Content db\init.sql -Raw -Encoding UTF8 | mysql --user=root --password=root --default-character-set=utf8mb4
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_18_library DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_18_library;

-- ---------------------------- 用户表 ----------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(64) NOT NULL,
  nickname VARCHAR(64) NOT NULL,
  phone VARCHAR(32) DEFAULT '',
  role VARCHAR(16) NOT NULL COMMENT 'ADMIN/LIBRARIAN/READER',
  status INT DEFAULT 1 COMMENT '1正常 0停用',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 图书分类 ----------------------------
DROP TABLE IF EXISTS t_category;
CREATE TABLE t_category (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 图书 ----------------------------
DROP TABLE IF EXISTS t_book;
CREATE TABLE t_book (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(128) NOT NULL,
  author VARCHAR(64) DEFAULT '',
  isbn VARCHAR(32) DEFAULT '',
  publisher VARCHAR(128) DEFAULT '',
  category_id BIGINT DEFAULT 0,
  price DECIMAL(10,2) DEFAULT 0.00,
  total INT DEFAULT 0 COMMENT '馆藏总数',
  stock INT DEFAULT 0 COMMENT '可借库存',
  location VARCHAR(64) DEFAULT '' COMMENT '馆藏位置',
  cover VARCHAR(128) DEFAULT '' COMMENT '封面图片(项目内)',
  description VARCHAR(512) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 借阅记录 ----------------------------
DROP TABLE IF EXISTS t_borrow;
CREATE TABLE t_borrow (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  book_id BIGINT NOT NULL,
  borrow_time DATETIME NOT NULL,
  due_time DATETIME NOT NULL,
  return_time DATETIME DEFAULT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'BORROWED' COMMENT 'BORROWED借阅中 / RETURNED已归还',
  overdue_days INT DEFAULT 0 COMMENT '逾期天数(自动计费)',
  fine_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT '逾期费用(自动计算)',
  fine_status VARCHAR(16) DEFAULT 'NONE' COMMENT 'NONE/UNPAID/PAID',
  renew_count INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 图书预约(预约借书) ----------------------------
DROP TABLE IF EXISTS t_reservation;
CREATE TABLE t_reservation (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  book_id BIGINT NOT NULL,
  reserve_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(16) DEFAULT 'WAITING' COMMENT 'WAITING/FULFILLED/CANCELLED'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 座位 ----------------------------
DROP TABLE IF EXISTS t_seat;
CREATE TABLE t_seat (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  seat_no VARCHAR(16) NOT NULL UNIQUE,
  area VARCHAR(32) NOT NULL,
  status VARCHAR(16) DEFAULT 'AVAILABLE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 座位预约 ----------------------------
DROP TABLE IF EXISTS t_seat_booking;
CREATE TABLE t_seat_booking (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  seat_id BIGINT NOT NULL,
  booking_date DATE NOT NULL,
  time_slot VARCHAR(32) NOT NULL,
  status VARCHAR(16) DEFAULT 'BOOKED' COMMENT 'BOOKED/CANCELLED/COMPLETED',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 读者荐购 ----------------------------
DROP TABLE IF EXISTS t_recommend;
CREATE TABLE t_recommend (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  title VARCHAR(128) NOT NULL,
  author VARCHAR(64) DEFAULT '',
  reason VARCHAR(512) DEFAULT '',
  status VARCHAR(16) DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED',
  reply VARCHAR(256) DEFAULT '',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 逾期计费规则 ----------------------------
DROP TABLE IF EXISTS t_fine_rule;
CREATE TABLE t_fine_rule (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  free_days INT DEFAULT 0 COMMENT '逾期宽限期(天)',
  fine_per_day DECIMAL(10,2) DEFAULT 0.50 COMMENT '每超期一天罚款金额(元)',
  max_fine DECIMAL(10,2) DEFAULT 20.00 COMMENT '单笔逾期费用上限(元)',
  description VARCHAR(256) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 初始化数据
-- ============================================================

-- 账号: admin/123456 管理员  librarian/123456 馆员  reader/123456 读者  reader2/123456 读者
INSERT INTO t_user(username,password,nickname,phone,role,status) VALUES
('admin','123456','系统管理员','13800000001','ADMIN',1),
('librarian','123456','王馆员','13800000002','LIBRARIAN',1),
('reader','123456','张小阅','13900000001','READER',1),
('reader2','123456','李读者','13900000002','READER',1);

INSERT INTO t_category(name) VALUES
('计算机'),('文学'),('历史'),('社科'),('科普'),('艺术');

-- 14 本图书
INSERT INTO t_book(title,author,isbn,publisher,category_id,price,total,stock,location,cover,description) VALUES
('深入理解计算机系统','Randal E. Bryant','9787111544937','机械工业出版社',1,139.00,5,5,'计算机区A-01','/images/covers/c1.svg','从程序员视角讲解计算机系统的经典教材'),
('代码大全(第2版)','Steve McConnell','9787121022992','电子工业出版社',1,128.00,3,3,'计算机区A-02','/images/covers/c2.svg','软件构建领域的百科全书'),
('数据结构与算法分析','Mark Allen Weiss','9787111407010','机械工业出版社',1,79.00,4,4,'计算机区A-03','/images/covers/c3.svg','C语言描述的数据结构经典教材'),
('设计模式','GoF','9787111211266','机械工业出版社',1,49.00,2,2,'计算机区A-04','/images/covers/c4.svg','可复用面向对象软件的基础'),
('三体(全三册)','刘慈欣','9787536692930','重庆出版社',2,168.00,6,6,'文学区B-01','/images/covers/c5.svg','雨果奖获奖作品,中国科幻里程碑'),
('活着','余华','9787506365437','作家出版社',2,45.00,5,4,'文学区B-02','/images/covers/c6.svg','讲述人与命运之间的温情故事'),
('红楼梦(上下)','曹雪芹','9787020002207','人民文学出版社',2,59.70,4,4,'文学区B-03','/images/covers/c7.svg','中国古典四大名著之一'),
('百年孤独','加西亚·马尔克斯','9787544253994','南海出版公司',2,55.00,3,3,'文学区B-04','/images/covers/c8.svg','魔幻现实主义文学代表作'),
('平凡的世界(全三册)','路遥','9787530216781','北京十月文艺出版社',2,108.00,2,2,'文学区B-05','/images/covers/c1.svg','茅盾文学奖获奖作品'),
('明朝那些事儿(全7册)','当年明月','9787801656087','中国海关出版社',3,358.00,4,4,'历史区C-01','/images/covers/c2.svg','通俗明史的现象级读物'),
('人类简史','尤瓦尔·赫拉利','9787508647357','中信出版社',4,68.00,5,5,'社科区D-01','/images/covers/c3.svg','从动物到上帝的人类发展史'),
('乡土中国','费孝通','9787208061603','上海人民出版社',4,22.00,3,3,'社科区D-02','/images/covers/c4.svg','了解中国基层社会的必读经典'),
('时间简史','史蒂芬·霍金','9787535732309','湖南科学技术出版社',5,45.00,4,4,'科普区E-01','/images/covers/c5.svg','探索宇宙与时间本质的科普经典'),
('沉默的大多数','王小波','9787544259705','南海出版公司',2,39.50,1,0,'文学区B-06','/images/covers/c6.svg','王小波杂文集(当前已全部借出,可预约)');

-- 借阅记录(含在借/逾期/已归还历史,用于借阅热榜与逾期计费演示)
-- 读者 reader(id=3) 当前在借: book5 未逾期
INSERT INTO t_borrow(user_id,book_id,borrow_time,due_time,status,overdue_days,fine_amount,fine_status,renew_count) VALUES
(3,5,'2026-10-10 09:30:00','2026-10-30 23:59:59','BORROWED',0,0.00,'NONE',0),
-- 读者 reader(id=3) 逾期未还: book1, 应还 2026-09-21, 截至 2026-10-24 逾期33天, 33*0.5=16.50
(3,1,'2026-09-01 10:00:00','2026-09-21 23:59:59','BORROWED',33,16.50,'UNPAID',0),
-- 读者 reader2(id=4) 逾期未还: book6, 应还 2026-09-25, 逾期29天, 29*0.5=14.50
(4,6,'2026-09-05 14:00:00','2026-09-25 23:59:59','BORROWED',29,14.50,'UNPAID',0),
-- 已归还历史(借阅热榜数据)
(3,5,'2026-08-01 09:00:00','2026-08-21 23:59:59','RETURNED',0,0.00,'NONE',0),
(3,6,'2026-07-05 09:00:00','2026-07-25 23:59:59','RETURNED',0,0.00,'NONE',0),
(4,5,'2026-07-10 10:00:00','2026-07-30 23:59:59','RETURNED',0,0.00,'NONE',0),
(4,10,'2026-06-01 10:00:00','2026-06-21 23:59:59','RETURNED',0,0.00,'NONE',0),
(3,13,'2026-05-01 10:00:00','2026-05-21 23:59:59','RETURNED',4,2.00,'PAID',0),
(4,5,'2026-05-15 10:00:00','2026-06-04 23:59:59','RETURNED',0,0.00,'NONE',0),
(3,11,'2026-04-02 10:00:00','2026-04-22 23:59:59','RETURNED',0,0.00,'NONE',0),
(4,6,'2026-03-10 10:00:00','2026-03-30 23:59:59','RETURNED',0,0.00,'NONE',0);

-- 图书预约: reader 预约了库存为0的 book14
INSERT INTO t_reservation(user_id,book_id,reserve_time,status) VALUES
(3,14,'2026-10-20 15:00:00','WAITING');

-- 座位: 3 个阅览区共 16 个座位
INSERT INTO t_seat(seat_no,area) VALUES
('A-01','阅览区A'),('A-02','阅览区A'),('A-03','阅览区A'),('A-04','阅览区A'),('A-05','阅览区A'),('A-06','阅览区A'),
('B-01','阅览区B'),('B-02','阅览区B'),('B-03','阅览区B'),('B-04','阅览区B'),
('E-01','电子阅览区'),('E-02','电子阅览区'),('E-03','电子阅览区'),('E-04','电子阅览区');

-- 座位预约: 明天(2026-10-25) A-01、A-02 已被约
INSERT INTO t_seat_booking(user_id,seat_id,booking_date,time_slot,status) VALUES
(3,1,'2026-10-25','09:00-12:00','BOOKED'),
(4,7,'2026-10-25','14:00-17:00','BOOKED');

-- 读者荐购
INSERT INTO t_recommend(user_id,title,author,reason,status,reply) VALUES
(3,'置身事内：中国政府与经济发展','兰小欢','课程参考资料需要,希望馆藏补充','PENDING',''),
(3,'浪潮之巅','吴军','拓展阅读,讲解IT产业发展史','APPROVED','已批准采购,预计下月到馆'),
(4,'算法导论','Thomas H. Cormen','计算机专业考研参考','PENDING','');

-- 逾期计费规则: 宽限0天, 每天0.5元, 单笔上限20元
INSERT INTO t_fine_rule(free_days,fine_per_day,max_fine,description) VALUES
(0,0.50,20.00,'逾期自动计费: 超出应还日期每天0.5元,单笔最高20元');
