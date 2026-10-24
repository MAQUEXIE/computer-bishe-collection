-- ============================================================
-- 25-小微企业进销存系统  数据库初始化脚本
-- 库名: db_25_inventory (utf8mb4)
-- 账号: admin/123456 管理员  boss/123456 老板  staff/123456 员工
-- ============================================================
CREATE DATABASE IF NOT EXISTS db_25_inventory DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_25_inventory;

-- ---------------------------- 用户表 ----------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(50) NOT NULL,
  nickname VARCHAR(50),
  phone VARCHAR(30),
  role VARCHAR(20) NOT NULL DEFAULT 'STAFF' COMMENT 'STAFF员工/BOSS老板/ADMIN管理员',
  status INT NOT NULL DEFAULT 0 COMMENT '0待审核 1正常 2禁用',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 商品分类 ----------------------------
DROP TABLE IF EXISTS t_category;
CREATE TABLE t_category (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  remark VARCHAR(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 供应商 ----------------------------
DROP TABLE IF EXISTS t_supplier;
CREATE TABLE t_supplier (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  contact VARCHAR(50),
  phone VARCHAR(30),
  address VARCHAR(200),
  remark VARCHAR(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 客户 ----------------------------
DROP TABLE IF EXISTS t_customer;
CREATE TABLE t_customer (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  contact VARCHAR(50),
  phone VARCHAR(30),
  address VARCHAR(200),
  remark VARCHAR(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 商品 ----------------------------
DROP TABLE IF EXISTS t_product;
CREATE TABLE t_product (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category_id BIGINT,
  supplier_id BIGINT,
  unit VARCHAR(20) DEFAULT '件',
  cost_price DECIMAL(10,2) DEFAULT 0,
  sale_price DECIMAL(10,2) DEFAULT 0,
  stock INT DEFAULT 0,
  safety_stock INT DEFAULT 10,
  image VARCHAR(200) DEFAULT '/images/product.svg',
  remark VARCHAR(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 采购入库单 ----------------------------
DROP TABLE IF EXISTS t_purchase;
CREATE TABLE t_purchase (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  purchase_no VARCHAR(40) NOT NULL,
  supplier_id BIGINT,
  total_amount DECIMAL(12,2) DEFAULT 0,
  operator_id BIGINT,
  operator_name VARCHAR(50),
  remark VARCHAR(200),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS t_purchase_item;
CREATE TABLE t_purchase_item (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  purchase_id BIGINT,
  product_id BIGINT,
  product_name VARCHAR(100),
  quantity INT,
  cost_price DECIMAL(10,2),
  subtotal DECIMAL(12,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 销售单 ----------------------------
DROP TABLE IF EXISTS t_sale;
CREATE TABLE t_sale (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  sale_no VARCHAR(40) NOT NULL,
  customer_id BIGINT,
  customer_name VARCHAR(80),
  total_amount DECIMAL(12,2) DEFAULT 0,
  cost_amount DECIMAL(12,2) DEFAULT 0,
  profit DECIMAL(12,2) DEFAULT 0,
  operator_id BIGINT,
  operator_name VARCHAR(50),
  remark VARCHAR(200),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS t_sale_item;
CREATE TABLE t_sale_item (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  sale_id BIGINT,
  product_id BIGINT,
  product_name VARCHAR(100),
  quantity INT,
  sale_price DECIMAL(10,2),
  cost_price DECIMAL(10,2),
  subtotal DECIMAL(12,2),
  profit DECIMAL(12,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 库存流水 ----------------------------
DROP TABLE IF EXISTS t_stock_log;
CREATE TABLE t_stock_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT,
  product_name VARCHAR(100),
  change_type VARCHAR(10) COMMENT 'IN入库/OUT出库',
  quantity INT,
  before_stock INT,
  after_stock INT,
  ref_no VARCHAR(40),
  remark VARCHAR(200),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------- 系统设置 ----------------------------
DROP TABLE IF EXISTS t_setting;
CREATE TABLE t_setting (
  skey VARCHAR(50) PRIMARY KEY,
  svalue VARCHAR(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户：管理员 / 老板 / 员工（密码均 123456），另加2个待审核账号演示开放注册
INSERT INTO t_user(username,password,nickname,phone,role,status) VALUES
('admin','123456','系统管理员','13800000001','ADMIN',1),
('boss','123456','王老板','13800000002','BOSS',1),
('staff','123456','小李','13800000003','STAFF',1),
('zhangwei','123456','张伟','13800000004','STAFF',0),
('liuyang','123456','刘洋','13800000005','STAFF',0);

-- 商品分类
INSERT INTO t_category(name,remark) VALUES
('日用百货','纸巾、洗护、清洁用品'),
('食品饮料','休闲零食、饮料酒水'),
('办公用品','文具、打印耗材'),
('五金工具','电工、手动工具');

-- 供应商
INSERT INTO t_supplier(name,contact,phone,address,remark) VALUES
('旺旺日用品批发','陈经理','13911112222','义乌国际商贸城A区','长期合作'),
('鲜饮食品渠道','刘总','13922223333','郑州食品城B12','账期月结'),
('晨光文具经销处','赵老板','13933334444','石家庄南三条','现货充足'),
('通达五金机电','孙工','13944445555','临沂五金城','量大从优'),
('宝洁区域代理','周经理','13955556666','广州白云区','品牌直供');

-- 客户
INSERT INTO t_customer(name,contact,phone,address,remark) VALUES
('社区便利店-张姐','张姐','13711112222','幸福路22号','每周补货'),
('写字楼茶水间','吴主管','13722223333','科技大厦15层','月结客户'),
('永辉超市采购','林采购','13733334444','高新区永辉超市','大客户'),
('校园超市','王店长','13744445555','学院路88号','学生客群'),
('街边小卖部','老马','13755556666','建设街3号','现金结算');

-- 商品（12个，含库存/安全库存；其中3个低于安全库存用于预警演示）
INSERT INTO t_product(name,category_id,supplier_id,unit,cost_price,sale_price,stock,safety_stock,image,remark) VALUES
('抽纸 3层120抽',1,1,'提',6.50,9.90,200,50,'/images/product.svg','常用'),
('蓝月亮洗衣液3kg',1,5,'瓶',22.00,32.90,3,20,'/images/product.svg','库存紧张'),
('舒肤佳香皂115g',1,5,'块',3.20,5.50,80,20,'/images/product.svg',''),
('可口可乐330ml*6',2,2,'组',15.00,22.50,120,30,'/images/product.svg','夏季热销'),
('康师傅红烧牛肉面',2,2,'桶',3.00,5.00,10,40,'/images/product.svg','库存紧张'),
('旺仔牛奶245ml',2,2,'罐',3.50,6.00,150,30,'/images/product.svg',''),
('A4打印纸500张',3,3,'包',16.00,25.00,60,20,'/images/product.svg',''),
('中性笔0.5mm黑',3,3,'支',1.20,2.50,2,100,'/images/product.svg','库存紧张'),
('订书机标准型',3,3,'个',8.00,15.00,45,10,'/images/product.svg',''),
('十字螺丝刀PH2',4,4,'把',5.50,12.00,38,10,'/images/product.svg',''),
('绝缘胶带10m',4,4,'卷',1.80,4.50,200,30,'/images/product.svg',''),
('电笔测电螺丝刀',4,4,'支',9.00,18.00,25,10,'/images/product.svg','');

-- 采购入库单（历史）
INSERT INTO t_purchase(purchase_no,supplier_id,total_amount,operator_id,operator_name,remark,created_at) VALUES
('CG20261018093001',1,1945.00,3,'小李','10月中旬补货',DATE_SUB(NOW(),INTERVAL 6 DAY)),
('CG20261020142002',2,3600.00,3,'小李','饮料整箱采购',DATE_SUB(NOW(),INTERVAL 4 DAY)),
('CG20261022101503',3,2080.00,3,'小李','办公耗材',DATE_SUB(NOW(),INTERVAL 2 DAY));

INSERT INTO t_purchase_item(purchase_id,product_id,product_name,quantity,cost_price,subtotal) VALUES
(1,1,'抽纸 3层120抽',200,6.50,1300.00),
(1,3,'舒肤佳香皂115g',200,3.20,640.00),
(2,4,'可口可乐330ml*6',100,15.00,1500.00),
(2,5,'康师傅红烧牛肉面',300,3.00,900.00),
(2,6,'旺仔牛奶245ml',300,3.50,1050.00),
(3,7,'A4打印纸500张',100,16.00,1600.00),
(3,8,'中性笔0.5mm黑',400,1.20,480.00);

-- 销售单（近一周多笔，便于销售报表/利润分析/员工业绩展示）
-- 单1
INSERT INTO t_sale(sale_no,customer_id,customer_name,total_amount,cost_amount,profit,operator_id,operator_name,remark,created_at) VALUES
('XS20261021101201',1,'社区便利店-张姐',495.00,325.00,170.00,3,'小李','日常补货',DATE_SUB(NOW(),INTERVAL 3 DAY));
INSERT INTO t_sale_item(sale_id,product_id,product_name,quantity,sale_price,cost_price,subtotal,profit) VALUES
(1,1,'抽纸 3层120抽',30,9.90,6.50,297.00,102.00),
(1,4,'可口可乐330ml*6',8,22.50,15.00,180.00,60.00),
(1,6,'旺仔牛奶245ml',3,6.00,3.50,18.00,7.50);

-- 单2
INSERT INTO t_sale(sale_no,customer_id,customer_name,total_amount,cost_amount,profit,operator_id,operator_name,remark,created_at) VALUES
('XS20261022153002',2,'写字楼茶水间',1250.00,820.00,430.00,3,'小李','月结配送',DATE_SUB(NOW(),INTERVAL 2 DAY));
INSERT INTO t_sale_item(sale_id,product_id,product_name,quantity,sale_price,cost_price,subtotal,profit) VALUES
(2,7,'A4打印纸500张',20,25.00,16.00,500.00,180.00),
(2,4,'可口可乐330ml*6',20,22.50,15.00,450.00,150.00),
(2,5,'康师傅红烧牛肉面',60,5.00,3.00,300.00,120.00);

-- 单3
INSERT INTO t_sale(sale_no,customer_id,customer_name,total_amount,cost_amount,profit,operator_id,operator_name,remark,created_at) VALUES
('XS20261023094503',3,'永辉超市采购',2450.00,1645.00,805.00,3,'小李','大单配送',DATE_SUB(NOW(),INTERVAL 1 DAY));
INSERT INTO t_sale_item(sale_id,product_id,product_name,quantity,sale_price,cost_price,subtotal,profit) VALUES
(3,1,'抽纸 3层120抽',100,9.90,6.50,990.00,340.00),
(3,6,'旺仔牛奶245ml',150,6.00,3.50,900.00,375.00),
(3,3,'舒肤佳香皂115g',100,5.50,3.20,550.00,230.00);

-- 单4
INSERT INTO t_sale(sale_no,customer_id,customer_name,total_amount,cost_amount,profit,operator_id,operator_name,remark,created_at) VALUES
('XS20261023162004',4,'校园超市',890.00,596.00,294.00,3,'小李','开学季',DATE_SUB(NOW(),INTERVAL 1 DAY));
INSERT INTO t_sale_item(sale_id,product_id,product_name,quantity,sale_price,cost_price,subtotal,profit) VALUES
(4,5,'康师傅红烧牛肉面',100,5.00,3.00,500.00,200.00),
(4,4,'可口可乐330ml*6',10,22.50,15.00,225.00,75.00),
(4,8,'中性笔0.5mm黑',50,2.50,1.20,125.00,65.00),
(4,9,'订书机标准型',3,15.00,8.00,45.00,21.00);

-- 单5（今天，演示当日流水）
INSERT INTO t_sale(sale_no,customer_id,customer_name,total_amount,cost_amount,profit,operator_id,operator_name,remark,created_at) VALUES
('XS20261024091505',5,'街边小卖部',220.00,148.00,72.00,3,'小李','现金',NOW());
INSERT INTO t_sale_item(sale_id,product_id,product_name,quantity,sale_price,cost_price,subtotal,profit) VALUES
(5,11,'绝缘胶带10m',20,4.50,1.80,90.00,54.00),
(5,10,'十字螺丝刀PH2',5,12.00,5.50,60.00,32.50),
(5,12,'电笔测电螺丝刀',4,18.00,9.00,72.00,36.00);

-- 库存流水（最近记录）
INSERT INTO t_stock_log(product_id,product_name,change_type,quantity,before_stock,after_stock,ref_no,remark,created_at) VALUES
(1,'抽纸 3层120抽','OUT',30,330,300,'XS20261021101201','销售出库',DATE_SUB(NOW(),INTERVAL 3 DAY)),
(1,'抽纸 3层120抽','OUT',100,300,200,'XS20261023094503','销售出库',DATE_SUB(NOW(),INTERVAL 1 DAY)),
(5,'康师傅红烧牛肉面','OUT',60,160,100,'XS20261022153002','销售出库',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(5,'康师傅红烧牛肉面','OUT',100,100,0,'XS20261023162004','销售出库',DATE_SUB(NOW(),INTERVAL 1 DAY)),
(8,'中性笔0.5mm黑','OUT',50,52,2,'XS20261023162004','销售出库',DATE_SUB(NOW(),INTERVAL 1 DAY)),
(2,'蓝月亮洗衣液3kg','OUT',17,20,3,'XS20261020120001','销售出库',DATE_SUB(NOW(),INTERVAL 4 DAY)),
(10,'十字螺丝刀PH2','OUT',5,43,38,'XS20261024091505','销售出库',NOW()),
(11,'绝缘胶带10m','OUT',20,220,200,'XS20261024091505','销售出库',NOW());

-- 系统设置
INSERT INTO t_setting(skey,svalue) VALUES
('company_name','兴旺商贸有限公司'),
('company_phone','0596-8888888'),
('company_address','漳州市芗城区新华北路128号'),
('low_stock_remind','开启'),
('profit_rule','按销售价-进货成本核算毛利');
