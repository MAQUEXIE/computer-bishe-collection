-- ======================================================================
-- 04 在线考试系统 初始化脚本
-- 库名: db_04_exam   字符集: utf8mb4
-- 账号: admin/123456(管理员) teacher/123456(教师) student/123456(学生)
-- ======================================================================

CREATE DATABASE IF NOT EXISTS db_04_exam DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_04_exam;

-- ---------------------------- 用户 ----------------------------
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '登录名',
  password    VARCHAR(100) NOT NULL COMMENT '密码(演示明文)',
  real_name   VARCHAR(50)  NOT NULL DEFAULT '' COMMENT '姓名',
  role        VARCHAR(20)  NOT NULL DEFAULT 'STUDENT' COMMENT 'ADMIN/TEACHER/STUDENT',
  class_id    BIGINT       NULL COMMENT '学生所属班级',
  subject_id  BIGINT       NULL COMMENT '教师任教科目',
  status      TINYINT      NOT NULL DEFAULT 1 COMMENT '0待审核 1正常 2拒绝',
  create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ---------------------------- 班级 ----------------------------
DROP TABLE IF EXISTS biz_class;
CREATE TABLE biz_class (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(50) NOT NULL COMMENT '班级名',
  grade       VARCHAR(20) NOT NULL DEFAULT '' COMMENT '年级',
  create_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级表';

-- ---------------------------- 学科 ----------------------------
DROP TABLE IF EXISTS biz_subject;
CREATE TABLE biz_subject (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(50) NOT NULL COMMENT '学科名',
  create_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学科表';

-- ---------------------------- 题目 ----------------------------
DROP TABLE IF EXISTS biz_question;
CREATE TABLE biz_question (
  id            BIGINT PRIMARY KEY AUTO_INCREMENT,
  subject_id    BIGINT       NOT NULL COMMENT '学科',
  q_type        VARCHAR(20)  NOT NULL COMMENT 'SINGLE单选 MULTI多选 JUDGE判断',
  content       VARCHAR(1000) NOT NULL COMMENT '题干',
  option_a      VARCHAR(500) NULL,
  option_b      VARCHAR(500) NULL,
  option_c      VARCHAR(500) NULL,
  option_d      VARCHAR(500) NULL,
  answer        VARCHAR(50)  NOT NULL COMMENT '标准答案: A / ABD / T / F',
  analysis      VARCHAR(1000) NULL DEFAULT '' COMMENT '解析',
  difficulty    TINYINT      NOT NULL DEFAULT 2 COMMENT '1易 2中 3难',
  default_score INT         NOT NULL DEFAULT 5 COMMENT '默认分值',
  teacher_id    BIGINT       NULL COMMENT '录入教师',
  create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题目表';

-- ---------------------------- 试卷 ----------------------------
DROP TABLE IF EXISTS biz_paper;
CREATE TABLE biz_paper (
  id            BIGINT PRIMARY KEY AUTO_INCREMENT,
  title         VARCHAR(100) NOT NULL COMMENT '试卷名称',
  subject_id    BIGINT       NOT NULL,
  teacher_id    BIGINT       NOT NULL COMMENT '组卷教师',
  duration_min  INT          NOT NULL DEFAULT 30 COMMENT '考试时长(分钟)',
  total_score   INT          NOT NULL DEFAULT 100,
  pass_score    INT          NOT NULL DEFAULT 60,
  warn_limit    INT          NOT NULL DEFAULT 3 COMMENT '切屏警告上限,超过自动交卷',
  status        VARCHAR(20)  NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT草稿 PUBLISHED已发布 CLOSED已结束',
  create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='试卷表';

-- ---------------------------- 试卷题目关联 ----------------------------
DROP TABLE IF EXISTS biz_paper_question;
CREATE TABLE biz_paper_question (
  id         BIGINT PRIMARY KEY AUTO_INCREMENT,
  paper_id   BIGINT NOT NULL,
  question_id BIGINT NOT NULL,
  score      INT    NOT NULL DEFAULT 5 COMMENT '该题在本卷分值',
  sort_no    INT    NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='试卷题目关联表';

-- ---------------------------- 考试记录 ----------------------------
DROP TABLE IF EXISTS biz_exam_record;
CREATE TABLE biz_exam_record (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  paper_id    BIGINT   NOT NULL,
  student_id  BIGINT   NOT NULL,
  start_time  DATETIME NULL,
  submit_time DATETIME NULL,
  score       INT      NULL COMMENT '最终得分',
  warn_count  INT      NOT NULL DEFAULT 0 COMMENT '切屏警告次数',
  status      VARCHAR(20) NOT NULL DEFAULT 'ONGOING' COMMENT 'ONGOING进行中 SUBMITTED已交卷'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试记录表';

-- ---------------------------- 答题明细 ----------------------------
DROP TABLE IF EXISTS biz_answer;
CREATE TABLE biz_answer (
  id             BIGINT PRIMARY KEY AUTO_INCREMENT,
  record_id      BIGINT NOT NULL,
  question_id    BIGINT NOT NULL,
  student_answer VARCHAR(50)  NOT NULL DEFAULT '' COMMENT '学生作答',
  score          INT     NOT NULL DEFAULT 0 COMMENT '本题得分',
  is_correct     TINYINT NOT NULL DEFAULT 0 COMMENT '1对 0错'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='答题明细表';

-- ---------------------------- 系统配置 ----------------------------
DROP TABLE IF EXISTS biz_config;
CREATE TABLE biz_config (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  config_key   VARCHAR(50)  NOT NULL UNIQUE,
  config_value VARCHAR(200) NOT NULL DEFAULT '',
  remark       VARCHAR(200) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- ======================================================================
-- 演示数据
-- ======================================================================

-- 班级
INSERT INTO biz_class (id, name, grade) VALUES
 (1, '高一(1)班', '高一'),
 (2, '高一(2)班', '高一');

-- 学科
INSERT INTO biz_subject (id, name) VALUES
 (1, '数学'),
 (2, '语文'),
 (3, '英语');

-- 用户
INSERT INTO sys_user (id, username, password, real_name, role, class_id, subject_id, status) VALUES
 (1, 'admin',   '123456', '系统管理员', 'ADMIN',   NULL, NULL, 1),
 (2, 'teacher', '123456', '王老师',     'TEACHER', NULL, 1,    1),
 (3, 'student', '123456', '李学生',     'STUDENT', 1,    NULL, 1),
 (4, 'liuyang',  '123456', '刘洋',       'STUDENT', 1,    NULL, 1),
 (5, 'wangfang', '123456', '王芳',       'STUDENT', 2,    NULL, 1),
 (6, 'newteacher','123456','赵老师',    'TEACHER', NULL, 2,    0);

-- 题目(22道)
INSERT INTO biz_question (id, subject_id, q_type, content, option_a, option_b, option_c, option_d, answer, analysis, difficulty, default_score, teacher_id) VALUES
 (1, 1, 'SINGLE', '1 + 1 = ?', '1', '2', '3', '4', 'B', '加法基础运算', 1, 5, 2),
 (2, 1, 'SINGLE', '下列哪个数是偶数？', '3', '5', '8', '7', 'C', '能被2整除的整数为偶数', 1, 5, 2),
 (3, 1, 'SINGLE', '直角三角形中一个锐角为30°，另一个锐角是？', '45°', '60°', '90°', '30°', 'B', '两锐角和为90°', 2, 5, 2),
 (4, 1, 'SINGLE', '一元二次方程 x² - 5x + 6 = 0 的解为？', 'x=2或x=3', 'x=-2或x=-3', 'x=1或x=6', 'x=2或x=-3', 'A', '因式分解 (x-2)(x-3)=0', 2, 5, 2),
 (5, 1, 'SINGLE', '圆的面积公式 S = ?', '2πr', 'πr²', 'πd', '2πr²', 'B', '面积为 π 乘以半径平方', 1, 5, 2),
 (6, 1, 'MULTI', '下列哪些数是质数？', '2', '9', '7', '15', 'AC', '质数只能被1和自身整除', 2, 5, 2),
 (7, 1, 'MULTI', '下列图形中是轴对称图形的有？', '等边三角形', '平行四边形', '正方形', '圆', 'ACD', '平行四边形不是轴对称图形', 2, 5, 2),
 (8, 1, 'JUDGE', '0 是自然数。', NULL, NULL, NULL, NULL, 'T', '现行教材规定0是自然数', 1, 5, 2),
 (9, 1, 'JUDGE', '所有的质数都是奇数。', NULL, NULL, NULL, NULL, 'F', '2是质数但它是偶数', 2, 5, 2),
 (10,1, 'JUDGE', '三角形的内角和为180度。', NULL, NULL, NULL, NULL, 'T', '平面几何基本定理', 1, 5, 2),
 (11,2, 'SINGLE', '《静夜思》的作者是？', '杜甫', '李白', '白居易', '王维', 'B', '李白代表作', 1, 5, 2),
 (12,2, 'SINGLE', '"床前明月光"的下一句是？', '疑是地上霜', '举头望明月', '低头思故乡', '月是故乡明', 'A', '出自《静夜思》', 1, 5, 2),
 (13,2, 'SINGLE', '下列词语中没有错别字的是？', '按部就班', '穿流不息', '再接再励', '迫不急待', 'A', 'B应为川流不息 C应为再接再厉 D应为迫不及待', 2, 5, 2),
 (14,2, 'MULTI', '下列属于"唐宋八大家"的有？', '韩愈', '李白', '苏轼', '欧阳修', 'ACD', '李白不在唐宋八大家之列', 3, 5, 2),
 (15,2, 'JUDGE', '《红楼梦》的作者是曹雪芹。', NULL, NULL, NULL, NULL, 'T', '四大名著常识', 1, 5, 2),
 (16,2, 'JUDGE', '"春眠不觉晓"出自杜甫的《春夜喜雨》。', NULL, NULL, NULL, NULL, 'F', '出自孟浩然《春晓》', 2, 5, 2),
 (17,3, 'SINGLE', '"apple" 的中文意思是？', '香蕉', '苹果', '橙子', '葡萄', 'B', '基础词汇', 1, 5, 2),
 (18,3, 'SINGLE', '选择正确时态：He ___ to school every day.', 'go', 'goes', 'went', 'going', 'B', '一般现在时第三人称单数', 2, 5, 2),
 (19,3, 'SINGLE', '回答 "Thank you" 的恰当用语是？', "You're welcome.", "I'm fine.", 'Nice to meet you.', 'See you.', 'A', '交际用语', 1, 5, 2),
 (20,3, 'MULTI', '下列哪些是英语元音字母？', 'A', 'B', 'E', 'O', 'ACD', '元音字母为 A E I O U', 2, 5, 2),
 (21,3, 'JUDGE', '"good" 的比较级是 "better"。', NULL, NULL, NULL, NULL, 'T', '不规则变化', 1, 5, 2),
 (22,3, 'JUDGE', '"I is a student" 语法正确。', NULL, NULL, NULL, NULL, 'F', 'I 应搭配 am', 1, 5, 2);

-- 试卷(2套已发布)
INSERT INTO biz_paper (id, title, subject_id, teacher_id, duration_min, total_score, pass_score, warn_limit, status) VALUES
 (1, '高一期中数学测验', 1, 2, 30, 100, 60, 3, 'PUBLISHED'),
 (2, '数学第一单元练习',   1, 2, 20, 50,  30, 3, 'PUBLISHED');

-- 试卷1题目(10题 x 10分 = 100)
INSERT INTO biz_paper_question (paper_id, question_id, score, sort_no) VALUES
 (1, 1, 10, 1), (1, 2, 10, 2), (1, 3, 10, 3), (1, 4, 10, 4), (1, 5, 10, 5),
 (1, 6, 10, 6), (1, 7, 10, 7), (1, 8, 10, 8), (1, 9, 10, 9), (1, 10, 10, 10);

-- 试卷2题目(10题 x 5分 = 50)
INSERT INTO biz_paper_question (paper_id, question_id, score, sort_no) VALUES
 (2, 1, 5, 1), (2, 2, 5, 2), (2, 3, 5, 3), (2, 4, 5, 4), (2, 5, 5, 5),
 (2, 6, 5, 6), (2, 7, 5, 7), (2, 8, 5, 8), (2, 9, 5, 9), (2, 10, 5, 10);

-- 考试记录(已交卷)
INSERT INTO biz_exam_record (id, paper_id, student_id, start_time, submit_time, score, warn_count, status) VALUES
 (1, 1, 3, '2026-10-20 09:00:00', '2026-10-20 09:25:00', 80, 1, 'SUBMITTED'),
 (2, 1, 4, '2026-10-20 09:00:00', '2026-10-20 09:28:00', 60, 0, 'SUBMITTED'),
 (3, 1, 5, '2026-10-20 09:00:00', '2026-10-20 09:20:00', 90, 0, 'SUBMITTED'),
 (4, 2, 3, '2026-10-22 15:00:00', '2026-10-22 15:15:00', 45, 0, 'SUBMITTED');

-- 李学生(record_id=1)的答题明细: 第5题错(选D),第7题错(选AC),其余对 => 80分
INSERT INTO biz_answer (record_id, question_id, student_answer, score, is_correct) VALUES
 (1, 1, 'B', 10, 1),
 (1, 2, 'C', 10, 1),
 (1, 3, 'B', 10, 1),
 (1, 4, 'A', 10, 1),
 (1, 5, 'D', 0, 0),
 (1, 6, 'AC', 10, 1),
 (1, 7, 'AC', 0, 0),
 (1, 8, 'T', 10, 1),
 (1, 9, 'T', 10, 1),
 (1, 10,'T', 10, 1);

-- 刘洋(record_id=2) 60分: 错4题
INSERT INTO biz_answer (record_id, question_id, student_answer, score, is_correct) VALUES
 (2, 1, 'B', 10, 1),
 (2, 2, 'A', 0, 0),
 (2, 3, 'B', 10, 1),
 (2, 4, 'B', 0, 0),
 (2, 5, 'B', 10, 1),
 (2, 6, 'A', 0, 0),
 (2, 7, 'ACD', 10, 1),
 (2, 8, 'T', 10, 1),
 (2, 9, 'F', 0, 0),
 (2, 10,'T', 10, 1);

-- 王芳(record_id=3) 90分: 错1题
INSERT INTO biz_answer (record_id, question_id, student_answer, score, is_correct) VALUES
 (3, 1, 'B', 10, 1),
 (3, 2, 'C', 10, 1),
 (3, 3, 'B', 10, 1),
 (3, 4, 'A', 10, 1),
 (3, 5, 'B', 10, 1),
 (3, 6, 'AC', 10, 1),
 (3, 7, 'AB', 0, 0),
 (3, 8, 'T', 10, 1),
 (3, 9, 'T', 10, 1),
 (3, 10,'T', 10, 1);

-- 李学生(record_id=4) 45分: 错1题
INSERT INTO biz_answer (record_id, question_id, student_answer, score, is_correct) VALUES
 (4, 1, 'B', 5, 1), (4, 2, 'C', 5, 1), (4, 3, 'B', 5, 1), (4, 4, 'A', 5, 1), (4, 5, 'B', 5, 1),
 (4, 6, 'AC', 5, 1), (4, 7, 'B', 0, 0), (4, 8, 'T', 5, 1), (4, 9, 'T', 5, 1), (4, 10,'T', 5, 1);

-- 系统配置
INSERT INTO biz_config (config_key, config_value, remark) VALUES
 ('register_approve', '1', '新教师注册是否需要管理员审核(1需要 0直接激活)'),
 ('warn_limit', '3', '单场考试切屏警告次数上限,超过自动交卷'),
 ('exam_title', '智慧在线考试平台', '系统名称');
