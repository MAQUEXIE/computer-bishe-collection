-- ============================================================
-- 27 固定资产管理系统 初始化 SQL
-- 库名: db_27_asset   字符集: utf8mb4
-- 账号: admin/123456(管理员)  asset/123456(资产管理员)
--       leader/123456(领导)   staff/123456(员工)
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_27_asset DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_27_asset;

-- ----------------------------
-- 用户表
-- ----------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  username    VARCHAR(64)  NOT NULL UNIQUE COMMENT '登录名',
  password    VARCHAR(64)  NOT NULL COMMENT '密码',
  nickname    VARCHAR(64)  NOT NULL COMMENT '姓名',
  phone       VARCHAR(32)  DEFAULT '' COMMENT '电话',
  role        VARCHAR(16)  NOT NULL COMMENT 'ADMIN管理员/ASSET资产管理员/LEADER领导/STAFF员工',
  dept        VARCHAR(64)  DEFAULT '' COMMENT '部门',
  status      INT          DEFAULT 1 COMMENT '1正常 0停用',
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ----------------------------
-- 资产表
-- ----------------------------
DROP TABLE IF EXISTS t_asset;
CREATE TABLE t_asset (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  asset_no     VARCHAR(32)  NOT NULL UNIQUE COMMENT '资产编号(二维码内容)',
  name         VARCHAR(128) NOT NULL COMMENT '资产名称',
  category     VARCHAR(32)  NOT NULL COMMENT '分类',
  brand        VARCHAR(64)  DEFAULT '' COMMENT '品牌',
  model        VARCHAR(64)  DEFAULT '' COMMENT '型号',
  spec         VARCHAR(128) DEFAULT '' COMMENT '规格',
  dept         VARCHAR(64)  DEFAULT '' COMMENT '所属部门',
  location     VARCHAR(128) DEFAULT '' COMMENT '存放地点',
  status       VARCHAR(16)  NOT NULL DEFAULT 'IDLE' COMMENT 'IDLE闲置/IN_USE在用/BORROWED借出/REPAIR维修中/DISPOSED已处置',
  user_id      BIGINT       DEFAULT NULL COMMENT '当前使用人',
  price        DECIMAL(12,2) DEFAULT 0 COMMENT '原值',
  purchase_date DATE        DEFAULT NULL COMMENT '购入日期',
  use_years    INT          DEFAULT 5 COMMENT '预计使用年限',
  remark       VARCHAR(255) DEFAULT '' COMMENT '备注',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产表';

-- ----------------------------
-- 申领/借用申请表
-- ----------------------------
DROP TABLE IF EXISTS t_apply;
CREATE TABLE t_apply (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  asset_id     BIGINT       NOT NULL,
  user_id      BIGINT       NOT NULL COMMENT '申请人',
  type         VARCHAR(16)  NOT NULL COMMENT 'APPLY申领/BORROW借用',
  reason       VARCHAR(255) DEFAULT '' COMMENT '申请事由',
  status       VARCHAR(16)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待审批/APPROVED已通过/REJECTED已驳回',
  approver     VARCHAR(64)  DEFAULT '' COMMENT '审批人',
  approve_remark VARCHAR(255) DEFAULT '' COMMENT '审批意见',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='申领/借用申请表';

-- ----------------------------
-- 报修单表
-- ----------------------------
DROP TABLE IF EXISTS t_repair;
CREATE TABLE t_repair (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  asset_id     BIGINT       NOT NULL,
  user_id      BIGINT       NOT NULL COMMENT '报修人',
  title        VARCHAR(128) NOT NULL COMMENT '故障标题',
  content      VARCHAR(500) DEFAULT '' COMMENT '故障描述',
  status       VARCHAR(16)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待受理/REPAIRING维修中/DONE已修复',
  handler      VARCHAR(64)  DEFAULT '' COMMENT '维修处理人',
  result       VARCHAR(255) DEFAULT '' COMMENT '处理结果',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  done_at      DATETIME     DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报修单表';

-- ----------------------------
-- 调拨记录表
-- ----------------------------
DROP TABLE IF EXISTS t_transfer;
CREATE TABLE t_transfer (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  asset_id     BIGINT       NOT NULL,
  from_dept    VARCHAR(64)  DEFAULT '',
  to_dept      VARCHAR(64)  DEFAULT '',
  handler      VARCHAR(64)  DEFAULT '' COMMENT '经手人(资产管理员)',
  remark       VARCHAR(255) DEFAULT '',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产调拨记录表';

-- ----------------------------
-- 处置单表
-- ----------------------------
DROP TABLE IF EXISTS t_dispose;
CREATE TABLE t_dispose (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  asset_id     BIGINT       NOT NULL,
  way          VARCHAR(16)  NOT NULL DEFAULT '报废' COMMENT '报废/出售',
  reason       VARCHAR(255) DEFAULT '',
  status       VARCHAR(16)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待审批/APPROVED已批准/DONE已处置/REJECTED已驳回',
  approver     VARCHAR(64)  DEFAULT '',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产处置单表';

-- ----------------------------
-- 盘点批次表
-- ----------------------------
DROP TABLE IF EXISTS t_inventory_batch;
CREATE TABLE t_inventory_batch (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  name         VARCHAR(128) NOT NULL COMMENT '盘点批次名称',
  status       VARCHAR(16)  NOT NULL DEFAULT 'DOING' COMMENT 'DOING盘点中/DONE已完成',
  creator      VARCHAR(64)  DEFAULT '',
  remark       VARCHAR(255) DEFAULT '',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='盘点批次表';

-- ----------------------------
-- 盘点明细表
-- ----------------------------
DROP TABLE IF EXISTS t_inventory_item;
CREATE TABLE t_inventory_item (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  batch_id     BIGINT       NOT NULL,
  asset_id     BIGINT       NOT NULL,
  expect_dept  VARCHAR(64)  DEFAULT '' COMMENT '账面部门',
  expect_user  VARCHAR(64)  DEFAULT '' COMMENT '账面使用人',
  check_status VARCHAR(16)  NOT NULL DEFAULT 'UNCHECKED' COMMENT 'UNCHECKED未盘/MATCH一致/DIFF盘异',
  check_remark VARCHAR(255) DEFAULT '',
  checker      VARCHAR(64)  DEFAULT '',
  checked_at   DATETIME     DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='盘点明细表';

-- ----------------------------
-- 预算表
-- ----------------------------
DROP TABLE IF EXISTS t_budget;
CREATE TABLE t_budget (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  year         INT          NOT NULL COMMENT '预算年度',
  total_amount DECIMAL(12,2) NOT NULL COMMENT '年度预算总额',
  remark       VARCHAR(255) DEFAULT '',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产预算表';

-- ----------------------------
-- 支出/收入记录表
-- ----------------------------
DROP TABLE IF EXISTS t_expense;
CREATE TABLE t_expense (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  asset_id     BIGINT       DEFAULT NULL,
  type         VARCHAR(16)  NOT NULL COMMENT '采购/维修/处置收入',
  amount       DECIMAL(12,2) NOT NULL,
  happen_date  DATE         NOT NULL,
  remark       VARCHAR(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产收支记录表';

-- ----------------------------
-- 资产生命周期日志表
-- ----------------------------
DROP TABLE IF EXISTS t_log;
CREATE TABLE t_log (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  asset_id     BIGINT       NOT NULL,
  action       VARCHAR(16)  NOT NULL COMMENT '登记/申领/借用/归还/调拨/报修/维修完成/处置',
  detail       VARCHAR(500) DEFAULT '',
  operator     VARCHAR(64)  DEFAULT '',
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产生命周期日志表';

-- ============================================================
-- 演示数据
-- ============================================================

-- 用户: admin/123456  asset/123456  leader/123456  staff/123456(张伟)  lisi/123456(李思)
INSERT INTO t_user(username,password,nickname,phone,role,dept) VALUES
('admin',  '123456', '系统管理员', '13800000001', 'ADMIN',  '信息中心'),
('asset',  '123456', '王资产',     '13800000002', 'ASSET',  '行政后勤部'),
('leader', '123456', '刘总',       '13800000003', 'LEADER', '总经理室'),
('staff',  '123456', '张伟',       '13800000004', 'STAFF',  '研发一部'),
('lisi',   '123456', '李思',       '13800000005', 'STAFF',  '市场部');

-- 资产 14 件
INSERT INTO t_asset(asset_no,name,category,brand,model,spec,dept,location,status,user_id,price,purchase_date,use_years,remark) VALUES
('ZC-2026-0001','ThinkPad X1 笔记本电脑','电子设备','联想','X1 Carbon i7','16G/512G','研发一部','3F-研发区','IN_USE',4,12999.00,'2025-03-12',5,'开发主力机'),
('ZC-2026-0002','MacBook Pro 14','电子设备','苹果','MPHFX3CH/A','18G/512G','研发一部','3F-研发区','IN_USE',5,16999.00,'2025-04-20',5,'设计用'),
('ZC-2026-0003','戴尔 U2723QE 显示器','电子设备','戴尔','U2723QE','27寸4K','研发一部','3F-工位','IDLE',NULL,3499.00,'2025-05-08',6,'备用显示器'),
('ZC-2026-0004','HP LaserJet Pro 打印机','办公设备','惠普','M404d','黑白激光','行政后勤部','2F-文印室','IN_USE',2,2199.00,'2024-11-15',6,'全院共享'),
('ZC-2026-0005','爱普生投影仪','办公设备','爱普生','CB-FH52','1080P','市场部','4F-大会议室','BORROWED',5,5999.00,'2024-06-01',6,'李思借用中'),
('ZC-2026-0006','人体工学办公椅','办公家具','赫曼米勒','Aeron','黑色网布','研发一部','3F-工位','IN_USE',4,8500.00,'2024-09-10',8,''),
('ZC-2026-0007','会议桌','办公家具','圣奥','2400*1200','胡桃木色','总经理室','5F-小会议室','IN_USE',NULL,4200.00,'2023-12-01',10,''),
('ZC-2026-0008','Dell PowerEdge 服务器','IT设备','戴尔','R750','双路至强','信息中心','6F-机房','IN_USE',1,68000.00,'2024-03-18',8,'核心业务机'),
('ZC-2026-0009','格力立式空调','电器设备','格力','RF12.6WPd','5匹','行政后勤部','1F-大厅','REPAIR',NULL,8900.00,'2023-08-22',10,'不制冷报修中'),
('ZC-2026-0010','得力碎纸机','办公设备','得力','9912','4级保密','行政后勤部','2F-文印室','IDLE',NULL,1299.00,'2025-01-10',5,''),
('ZC-2026-0011','iPad Pro 12.9','电子设备','苹果','MTED3CH/A','256G WiFi','市场部','4F-市场部','IDLE',NULL,8499.00,'2025-02-14',5,'外出演示备用'),
('ZC-2026-0012','夏普复印机','办公设备','夏普','BP-M2322R','A3复合机','行政后勤部','2F-文印室','DISPOSED',NULL,15000.00,'2020-05-30',6,'已报废处置'),
('ZC-2026-0013','罗技 MX Master 3S 鼠标','电子设备','罗技','MX2300','黑色','研发一部','3F-工位','IN_USE',4,699.00,'2025-07-01',4,''),
('ZC-2026-0014','华为 MateView 显示器','电子设备','华为','HSN-CB','28.2寸','市场部','4F-市场部','IDLE',NULL,2699.00,'2025-09-19',6,'新采购待用');

-- 申领/借用单
INSERT INTO t_apply(asset_id,user_id,type,reason,status,approver,approve_remark) VALUES
(3, 4, 'APPLY', '工位新增一台4K显示器提升开发效率', 'APPROVED', '刘总', '同意采购配发'),
(11,5, 'BORROW', '下周客户演示需要用平板展示方案', 'APPROVED', '刘总', '注意爱护，用完归还'),
(10,4,'BORROW', '部门季度文件销毁需要碎纸机', 'PENDING', '', ''),
(14,5,'APPLY', '市场部设计岗新显示器申请', 'PENDING', '', '');

-- 报修单
INSERT INTO t_repair(asset_id,user_id,title,content,status,handler,result,done_at) VALUES
(9, 2, '立式空调不制冷', '大厅空调出风常温，压缩机疑似故障', 'REPAIRING', '王资产', '', NULL),
(1, 4, '笔记本键盘失灵', 'X 键偶发粘连，影响编码', 'DONE', '王资产', '已更换键盘键帽并重装系统', '2025-09-02 16:30:00'),
(3, 5, '显示器闪屏待受理', '备用显示器接上后偶尔黑屏', 'PENDING', '', '', NULL);

-- 调拨记录
INSERT INTO t_transfer(asset_id,from_dept,to_dept,handler,remark) VALUES
(5,'行政后勤部','市场部','王资产','市场部年会活动借用调配'),
(14,'信息中心','市场部','王资产','新购显示器由信息中心移交市场部');

-- 处置单
INSERT INTO t_dispose(asset_id,way,reason,status,approver) VALUES
(12,'报废','主板老化频繁卡纸，维修无价值，批准报废','DONE','刘总'),
(9,'报废','压缩机已无维修价值，申请报废残值处理','PENDING','');

-- 盘点批次: 2026Q3 固定资产大盘点
INSERT INTO t_inventory_batch(name,status,creator,remark) VALUES
('2026年第三季度固定资产大盘点','DOING','王资产','覆盖全公司在用/闲置资产');

-- 盘点明细
INSERT INTO t_inventory_item(batch_id,asset_id,expect_dept,expect_user,check_status,check_remark,checker,checked_at) VALUES
(1,1,'研发一部','张伟','MATCH','账实相符','王资产','2026-10-20 10:10:00'),
(1,2,'研发一部','李思','MATCH','账实相符','王资产','2026-10-20 10:20:00'),
(1,3,'研发一部','','MATCH','存放于研发区备品柜','王资产','2026-10-20 10:35:00'),
(1,4,'行政后勤部','','DIFF','实际移至1F前台工位，台账未更新','王资产','2026-10-20 11:00:00'),
(1,5,'市场部','李思','UNCHECKED','','',NULL),
(1,6,'研发一部','张伟','UNCHECKED','','',NULL),
(1,8,'信息中心','系统管理员','MATCH','机房在位正常','王资产','2026-10-20 14:00:00'),
(1,11,'市场部','','UNCHECKED','','',NULL);

-- 预算
INSERT INTO t_budget(year,total_amount,remark) VALUES
(2026, 500000.00, '2026年度固定资产购置与维修总预算');

-- 收支记录
INSERT INTO t_expense(asset_id,type,amount,happen_date,remark) VALUES
(1,'采购',12999.00,'2025-03-12','研发一部笔记本采购'),
(2,'采购',16999.00,'2025-04-20','MacBook Pro 采购'),
(3,'采购',3499.00,'2025-05-08','显示器采购'),
(8,'采购',68000.00,'2024-03-18','机房服务器采购'),
(14,'采购',2699.00,'2025-09-19','华为显示器采购'),
(9,'维修',1200.00,'2026-08-10','空调冷媒补充'),
(1,'维修',350.00,'2025-09-02','笔记本键盘更换'),
(12,'处置收入',800.00,'2026-06-30','旧复印机废品回收');

-- 生命周期日志(部分资产全链路留痕示例)
INSERT INTO t_log(asset_id,action,detail,operator) VALUES
(1,'登记','新资产入库登记，资产编号 ZC-2026-0001','王资产'),
(1,'申领','张伟申领通过，配发至研发一部','刘总'),
(1,'报修','键盘失灵报修受理','张伟'),
(1,'维修完成','已更换键盘，恢复在用','王资产'),
(5,'登记','新资产入库登记，资产编号 ZC-2026-0005','王资产'),
(5,'借用','李思借用投影仪用于客户演示','刘总'),
(5,'调拨','由行政后勤部调拨至市场部','王资产'),
(12,'登记','新资产入库登记，资产编号 ZC-2026-0012','王资产'),
(12,'处置','批准报废，残值回收800元','刘总'),
(14,'登记','新资产入库登记，资产编号 ZC-2026-0014','王资产'),
(14,'调拨','由信息中心调拨至市场部待用','王资产');
