-- 23 短视频分享社区 初始化脚本
CREATE DATABASE IF NOT EXISTS db_23_short_video DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_23_short_video;

DROP TABLE IF EXISTS income_records;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS follows;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS videos;
DROP TABLE IF EXISTS users;

-- 用户表
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  nickname VARCHAR(50) DEFAULT '',
  role VARCHAR(20) DEFAULT 'user',
  avatar VARCHAR(255) DEFAULT '',
  status VARCHAR(20) DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 视频表
CREATE TABLE videos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  cover_img VARCHAR(255) DEFAULT '',
  video_url VARCHAR(255) DEFAULT '',
  category VARCHAR(50) DEFAULT '生活',
  creator_id INT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  play_count INT DEFAULT 0,
  like_count INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 点赞表
CREATE TABLE likes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  video_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_like (user_id, video_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 评论表
CREATE TABLE comments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  video_id INT NOT NULL,
  user_id INT NOT NULL,
  content VARCHAR(500) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 关注表
CREATE TABLE follows (
  id INT PRIMARY KEY AUTO_INCREMENT,
  follower_id INT NOT NULL,
  followee_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_follow (follower_id, followee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 私信表
CREATE TABLE messages (
  id INT PRIMARY KEY AUTO_INCREMENT,
  from_id INT NOT NULL,
  to_id INT NOT NULL,
  content VARCHAR(500) NOT NULL,
  is_read INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 审核记录表
CREATE TABLE audit_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  video_id INT NOT NULL,
  admin_id INT NOT NULL,
  action VARCHAR(20) NOT NULL,
  remark VARCHAR(255) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创作者收益表
CREATE TABLE income_records (
  id INT PRIMARY KEY AUTO_INCREMENT,
  creator_id INT NOT NULL,
  video_id INT NOT NULL,
  play_income DECIMAL(10,2) DEFAULT 0,
  like_income DECIMAL(10,2) DEFAULT 0,
  total_income DECIMAL(10,2) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============ 用户数据 ============
INSERT INTO users (id, username, password, nickname, role, avatar, status) VALUES
(1, 'admin',   '123456', '平台管理员',     'admin',   '', 'active'),
(2, 'creator',  '123456', '短视频达人小创', 'creator', '', 'active'),
(3, 'user',     '123456', '普通用户小明',   'user',    '', 'active'),
(4, 'travelbud','123456', '旅行博主阿游',   'creator', '', 'active'),
(5, 'cookmaster','123456','美食厨神老周',   'creator', '', 'active'),
(6, 'musicfan', '123456', '音乐少女小鹿',   'creator', '', 'active'),
(7, 'techgeek', '123456', '科技极客大鹏',   'creator', '', 'active'),
(8, 'user2',    '123456', '追剧女孩丽丽',   'user',    '', 'active'),
(9, 'user3',    '123456', '健身教练阿强',   'user',    '', 'disabled');

-- ============ 视频数据（12 条） ============
INSERT INTO videos (id, title, description, cover_img, video_url, category, creator_id, status, play_count, like_count) VALUES
(1,  '深夜食堂·一碗治愈的云吞面', '下班后来一碗热乎的云吞面，疲惫都被治愈了。', '/covers/cover1.svg',  '/videos/sample.mp4', '美食', 2, 'approved', 12800, 1560),
(2,  'vlog 周末 Citywalk 实录',  '一个人逛街、喝咖啡、看路人，城市的小确幸。',   '/covers/cover2.svg',  '/videos/sample.mp4', '生活', 2, 'approved', 8600, 720),
(3,  '新手剪辑教程 3 分钟学会',  '从零开始讲剪辑，适合纯新手的入门指南。',      '/covers/cover3.svg',  '/videos/sample.mp4', '知识', 2, 'pending', 0, 0),
(4,  '川西自驾｜雪山下的日落',   '开车 8 小时就为了这一眼雪山日落，值了！',     '/covers/cover4.svg',  '/videos/sample.mp4', '旅行', 4, 'approved', 23500, 3200),
(5,  '海岛潜水初体验',          '第一次下水就看到了彩色珊瑚和鱼群！',           '/covers/cover5.svg',  '/videos/sample.mp4', '旅行', 4, 'approved', 15200, 1890),
(6,  '边境小城慢生活',          '节奏很慢，适合躺平的小城（含违规取景镜头）。',  '/covers/cover6.svg',  '/videos/sample.mp4', '旅行', 4, 'rejected', 300, 25),
(7,  '家常菜·番茄炒蛋的灵魂做法','先炒蛋还是先炒番茄？答案都在这里。',           '/covers/cover7.svg',  '/videos/sample.mp4', '美食', 5, 'approved', 18900, 2450),
(8,  '烘焙初体验：戚风蛋糕不塌腰','失败三次终于成功！分享我的踩坑经验。',         '/covers/cover8.svg',  '/videos/sample.mp4', '美食', 5, 'pending', 0, 0),
(9,  '吉他弹唱《晴天》翻唱',     '午休时间录了一段，献给所有学生时代。',         '/covers/cover9.svg',  '/videos/sample.mp4', '音乐', 6, 'approved', 31000, 4500),
(10, '卧室音乐节·深夜钢琴',      '深夜十一点，弹一首安静的曲子陪你入睡。',       '/covers/cover10.svg', '/videos/sample.mp4', '音乐', 6, 'approved', 9800, 960),
(11, '新手机深度评测：值不值得买','用了两周之后，说说真实体验和优缺点。',          '/covers/cover11.svg','/videos/sample.mp4', '科技', 7, 'approved', 27600, 3100),
(12, 'AI 工具实测：效率翻倍',     '亲测 5 个 AI 工具，第 3 个真的很香。',         '/covers/cover12.svg','/videos/sample.mp4', '科技', 7, 'pending', 0, 0);

-- ============ 点赞数据 ============
INSERT INTO likes (user_id, video_id) VALUES
(3, 1), (3, 4), (3, 9),
(8, 1), (8, 2), (8, 9), (8, 10),
(2, 4), (2, 7), (2, 11),
(4, 1), (4, 9),
(5, 2), (5, 10),
(6, 7), (6, 11);

-- ============ 评论数据 ============
INSERT INTO comments (video_id, user_id, content) VALUES
(1, 3, '看着就饿了，今晚就照着做！'),
(1, 8, '深夜放毒系列，已收藏'),
(4, 3, '这个日落也太绝了，求路线'),
(4, 8, '川西我去过，秋天更美'),
(9, 3, '翻唱比原唱还有感觉'),
(9, 8, '青春回来了呜呜呜'),
(7, 2, '老周的番茄炒蛋是下饭神器'),
(11, 3, 'UP 主很客观，参考了'),
(2, 8, 'Citywalk 真的很解压');

-- ============ 关注关系 ============
INSERT INTO follows (follower_id, followee_id) VALUES
(3, 2), (3, 4), (3, 6),
(8, 2), (8, 6), (8, 5),
(2, 4), (2, 7),
(4, 2),
(5, 4);

-- ============ 私信数据 ============
INSERT INTO messages (from_id, to_id, content, is_read) VALUES
(3, 2, 'UP 主你好，你的云吞面视频有拍教程吗？', 1),
(2, 3, '有的呀，下周会出详细教程～', 1),
(3, 4, '请问川西自驾是几月份去的？', 0),
(4, 3, '建议 9-10 月去，秋色正好！', 0),
(8, 2, '关注你很久啦，每一期都看！', 1),
(2, 8, '谢谢丽丽的支持！', 1);

-- ============ 审核记录 ============
INSERT INTO audit_logs (video_id, admin_id, action, remark) VALUES
(1, 1, 'approved', '内容健康，推荐'),
(4, 1, 'approved', '风景类优质内容'),
(6, 1, 'rejected', '取景镜头涉及敏感区域，不予通过'),
(9, 1, 'approved', '音乐翻唱合规'),
(11, 1, 'approved', '评测内容客观');

-- ============ 创作者收益（播放×0.001 + 点赞×0.01） ============
INSERT INTO income_records (creator_id, video_id, play_income, like_income, total_income) VALUES
(2, 1, 12.80, 15.60, 28.40),
(2, 2, 8.60, 7.20, 15.80),
(4, 4, 23.50, 32.00, 55.50),
(4, 5, 15.20, 18.90, 34.10),
(5, 7, 18.90, 24.50, 43.40),
(6, 9, 31.00, 45.00, 76.00),
(6, 10, 9.80, 9.60, 19.40),
(7, 11, 27.60, 31.00, 58.60);
