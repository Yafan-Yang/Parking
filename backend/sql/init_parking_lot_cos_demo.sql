-- Reverse-engineered from the current codebase on 2026-04-02.
-- Full bootstrap script with schema, permissions, default accounts,
-- and complete demo data for every table in the project.
-- Demo account passwords are all: 123456

CREATE DATABASE IF NOT EXISTS `parking_lot_cos`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `parking_lot_cos`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET @now = NOW();
SET @admin_password = 'bfc62b3f67a4c3e57df84dad8cc48a3b';
SET @fank_password = '5cfdfa876f1908a8432c752c67b3c748';
SET @staff01_password = '31deb7c9dc72b861848eb77d68e8dca6';
SET @user01_password = 'bab5f0128c49d7557133b6a17ac4fbef';
SET @user02_password = '56c41fc98a82e7133a3a7fe0986701f4';

CREATE TABLE IF NOT EXISTS `t_dept` (
  `dept_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `parent_id` BIGINT NOT NULL DEFAULT 0 COMMENT '父部门ID',
  `dept_name` VARCHAR(64) NOT NULL COMMENT '部门名称',
  `order_num` DOUBLE DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `modify_time` DATETIME DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`dept_id`),
  KEY `idx_t_dept_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='部门表';

CREATE TABLE IF NOT EXISTS `t_role` (
  `role_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` VARCHAR(64) NOT NULL COMMENT '角色名称',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '角色描述',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `modify_time` DATETIME DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uk_t_role_role_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色表';

CREATE TABLE IF NOT EXISTS `t_menu` (
  `menu_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `parent_id` BIGINT NOT NULL DEFAULT 0 COMMENT '父菜单ID',
  `menu_name` VARCHAR(64) NOT NULL COMMENT '菜单名称',
  `path` VARCHAR(255) DEFAULT NULL COMMENT '路由地址',
  `component` VARCHAR(255) DEFAULT NULL COMMENT '前端组件路径',
  `perms` VARCHAR(100) DEFAULT NULL COMMENT '权限标识',
  `icon` VARCHAR(100) DEFAULT NULL COMMENT '图标',
  `type` CHAR(1) NOT NULL DEFAULT '0' COMMENT '0菜单 1按钮',
  `order_num` DOUBLE DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `modify_time` DATETIME DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`menu_id`),
  KEY `idx_t_menu_parent_id` (`parent_id`),
  KEY `idx_t_menu_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='菜单表';

CREATE TABLE IF NOT EXISTS `t_user` (
  `user_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(64) NOT NULL COMMENT '用户名',
  `password` VARCHAR(128) NOT NULL COMMENT '密码',
  `dept_id` BIGINT DEFAULT NULL COMMENT '部门ID',
  `email` VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
  `mobile` VARCHAR(32) DEFAULT NULL COMMENT '手机号',
  `status` CHAR(1) NOT NULL DEFAULT '1' COMMENT '状态 0锁定 1有效',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `modify_time` DATETIME DEFAULT NULL COMMENT '修改时间',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `ssex` CHAR(1) NOT NULL DEFAULT '2' COMMENT '性别 0男 1女 2保密',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '个人描述',
  `avatar` VARCHAR(255) DEFAULT 'default.jpg' COMMENT '头像',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_t_user_username` (`username`),
  KEY `idx_t_user_dept_id` (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统用户表';

CREATE TABLE IF NOT EXISTS `t_user_role` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`),
  KEY `idx_t_user_role_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户角色关联表';

CREATE TABLE IF NOT EXISTS `t_role_menu` (
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `menu_id` BIGINT NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`),
  KEY `idx_t_role_menu_menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色菜单关联表';

CREATE TABLE IF NOT EXISTS `t_user_config` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `theme` VARCHAR(32) NOT NULL DEFAULT 'dark' COMMENT '主题',
  `layout` VARCHAR(32) NOT NULL DEFAULT 'side' COMMENT '布局',
  `multi_page` CHAR(1) NOT NULL DEFAULT '0' COMMENT '多标签页',
  `fix_siderbar` CHAR(1) NOT NULL DEFAULT '1' COMMENT '固定侧边栏',
  `fix_header` CHAR(1) NOT NULL DEFAULT '1' COMMENT '固定头部',
  `color` VARCHAR(64) NOT NULL DEFAULT 'rgb(66, 185, 131)' COMMENT '主题色',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户个性化配置表';

CREATE TABLE IF NOT EXISTS `t_login_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` VARCHAR(64) DEFAULT NULL COMMENT '用户名',
  `login_time` DATETIME DEFAULT NULL COMMENT '登录时间',
  `location` VARCHAR(255) DEFAULT NULL COMMENT '登录地点',
  `ip` VARCHAR(64) DEFAULT NULL COMMENT 'IP地址',
  PRIMARY KEY (`id`),
  KEY `idx_t_login_log_username` (`username`),
  KEY `idx_t_login_log_login_time` (`login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='登录日志表';

CREATE TABLE IF NOT EXISTS `t_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` VARCHAR(64) DEFAULT NULL COMMENT '操作人',
  `operation` VARCHAR(255) DEFAULT NULL COMMENT '操作描述',
  `time` BIGINT DEFAULT NULL COMMENT '耗时',
  `method` VARCHAR(500) DEFAULT NULL COMMENT '执行方法',
  `params` TEXT COMMENT '方法参数',
  `ip` VARCHAR(64) DEFAULT NULL COMMENT 'IP地址',
  `create_time` DATETIME DEFAULT NULL COMMENT '操作时间',
  `location` VARCHAR(255) DEFAULT NULL COMMENT '操作地点',
  PRIMARY KEY (`id`),
  KEY `idx_t_log_username` (`username`),
  KEY `idx_t_log_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统日志表';

CREATE TABLE IF NOT EXISTS `t_dict` (
  `dict_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '字典ID',
  `keyy` VARCHAR(64) NOT NULL COMMENT '键',
  `valuee` VARCHAR(255) NOT NULL COMMENT '值',
  `table_name` VARCHAR(64) NOT NULL COMMENT '表名',
  `field_name` VARCHAR(64) NOT NULL COMMENT '字段名',
  PRIMARY KEY (`dict_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='字典表';

CREATE TABLE IF NOT EXISTS `t_test` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `field1` VARCHAR(20) DEFAULT NULL COMMENT '字段1',
  `field2` INT DEFAULT NULL COMMENT '字段2',
  `field3` VARCHAR(50) DEFAULT NULL COMMENT '字段3',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Excel导入导出演示表';

CREATE TABLE IF NOT EXISTS `user_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` VARCHAR(64) NOT NULL COMMENT '用户编号',
  `name` VARCHAR(64) NOT NULL COMMENT '用户昵称',
  `images` VARCHAR(500) DEFAULT NULL COMMENT '头像',
  `user_images` VARCHAR(500) DEFAULT NULL COMMENT '人脸头像',
  `sex` INT DEFAULT NULL COMMENT '性别 1男 2女',
  `create_date` DATETIME DEFAULT NULL COMMENT '创建时间',
  `phone` VARCHAR(32) DEFAULT NULL COMMENT '联系方式',
  `email` VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
  `user_id` INT NOT NULL COMMENT '系统用户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_info_code` (`code`),
  UNIQUE KEY `uk_user_info_user_id` (`user_id`),
  UNIQUE KEY `uk_user_info_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='停车用户信息表';

CREATE TABLE IF NOT EXISTS `vehicle_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `vehicle_no` VARCHAR(64) NOT NULL COMMENT '车辆编号',
  `vehicle_number` VARCHAR(64) NOT NULL COMMENT '车牌号',
  `vehicle_color` VARCHAR(64) DEFAULT NULL COMMENT '车辆颜色',
  `name` VARCHAR(64) DEFAULT NULL COMMENT '车辆名称',
  `engine_no` VARCHAR(128) DEFAULT NULL COMMENT '发动机号',
  `emission_standard` VARCHAR(64) DEFAULT NULL COMMENT '排放标准',
  `fuel_type` VARCHAR(16) DEFAULT NULL COMMENT '燃料类型',
  `images` VARCHAR(500) DEFAULT NULL COMMENT '车辆照片',
  `content` TEXT COMMENT '备注',
  `create_date` DATETIME DEFAULT NULL COMMENT '创建时间',
  `user_id` INT NOT NULL COMMENT '所属用户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_vehicle_info_vehicle_no` (`vehicle_no`),
  UNIQUE KEY `uk_vehicle_info_vehicle_number` (`vehicle_number`),
  KEY `idx_vehicle_info_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='车辆信息表';

CREATE TABLE IF NOT EXISTS `space_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` VARCHAR(64) NOT NULL COMMENT '车位编号',
  `name` VARCHAR(64) NOT NULL COMMENT '车位名称',
  `space` VARCHAR(255) NOT NULL COMMENT '车位位置',
  `create_date` DATETIME DEFAULT NULL COMMENT '创建时间',
  `images` VARCHAR(500) DEFAULT NULL COMMENT '位置图片',
  `price` DECIMAL(10,2) DEFAULT 0.00 COMMENT '价格/小时',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_space_info_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='车位信息表';

CREATE TABLE IF NOT EXISTS `space_status_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `space_id` INT NOT NULL COMMENT '车位ID',
  `status` VARCHAR(8) NOT NULL DEFAULT '0' COMMENT '状态 -1预约中 0空闲 1停车中',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_space_status_info_space_id` (`space_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='车位状态表';

CREATE TABLE IF NOT EXISTS `reserve_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `space_id` INT NOT NULL COMMENT '车位ID',
  `vehicle_id` INT NOT NULL COMMENT '车辆ID',
  `start_date` DATETIME DEFAULT NULL COMMENT '开始预约时间',
  `end_date` DATETIME DEFAULT NULL COMMENT '预约结束时间',
  `status` VARCHAR(8) NOT NULL DEFAULT '1' COMMENT '状态 0结束 1预约中',
  PRIMARY KEY (`id`),
  KEY `idx_reserve_info_space_id` (`space_id`),
  KEY `idx_reserve_info_vehicle_id` (`vehicle_id`),
  KEY `idx_reserve_info_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='预约信息表';

CREATE TABLE IF NOT EXISTS `park_order_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `space_id` INT NOT NULL COMMENT '车位ID',
  `vehicle_id` INT NOT NULL COMMENT '车辆ID',
  `code` VARCHAR(64) NOT NULL COMMENT '订单编号',
  `start_date` DATETIME DEFAULT NULL COMMENT '开始停车时间',
  `end_date` DATETIME DEFAULT NULL COMMENT '结束停车时间',
  `total_time` DECIMAL(10,2) DEFAULT NULL COMMENT '总时长(分钟)',
  `price` DECIMAL(10,2) DEFAULT NULL COMMENT '单价',
  `total_price` DECIMAL(10,2) DEFAULT NULL COMMENT '总价',
  `pay_date` DATETIME DEFAULT NULL COMMENT '支付时间',
  `status` VARCHAR(8) NOT NULL DEFAULT '0' COMMENT '状态 0未支付 1已支付',
  `content` TEXT COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_park_order_info_code` (`code`),
  KEY `idx_park_order_info_space_id` (`space_id`),
  KEY `idx_park_order_info_vehicle_id` (`vehicle_id`),
  KEY `idx_park_order_info_status` (`status`),
  KEY `idx_park_order_info_pay_date` (`pay_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='停车订单表';

CREATE TABLE IF NOT EXISTS `rule_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` VARCHAR(64) NOT NULL COMMENT '会员名称',
  `code` VARCHAR(64) NOT NULL COMMENT '会员编号',
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '价格',
  `days` INT NOT NULL DEFAULT 0 COMMENT '天数',
  `create_date` DATETIME DEFAULT NULL COMMENT '创建时间',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rule_info_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='会员规则表';

CREATE TABLE IF NOT EXISTS `member_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` INT NOT NULL COMMENT '用户ID',
  `member_level` VARCHAR(32) NOT NULL COMMENT '会员等级(实际存rule_info.id)',
  `start_date` DATETIME DEFAULT NULL COMMENT '会员开始时间',
  `end_date` DATETIME DEFAULT NULL COMMENT '会员结束时间',
  `price` DECIMAL(10,2) DEFAULT NULL COMMENT '价格',
  `pay_date` DATETIME DEFAULT NULL COMMENT '支付时间',
  PRIMARY KEY (`id`),
  KEY `idx_member_info_user_id` (`user_id`),
  KEY `idx_member_info_member_level` (`member_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='会员信息表';

CREATE TABLE IF NOT EXISTS `member_record_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` VARCHAR(64) NOT NULL COMMENT '订单编号',
  `member_id` INT NOT NULL COMMENT '会员规则ID',
  `price` DECIMAL(10,2) DEFAULT NULL COMMENT '价格',
  `status` VARCHAR(8) NOT NULL DEFAULT '0' COMMENT '状态 0未支付 1已支付',
  `pay_date` DATETIME DEFAULT NULL COMMENT '支付时间',
  `user_id` INT NOT NULL COMMENT '用户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_member_record_info_code` (`code`),
  KEY `idx_member_record_info_user_id` (`user_id`),
  KEY `idx_member_record_info_member_id` (`member_id`),
  KEY `idx_member_record_info_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='会员购买记录表';

CREATE TABLE IF NOT EXISTS `message_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` INT NOT NULL COMMENT '用户ID',
  `content` VARCHAR(500) DEFAULT NULL COMMENT '消息内容',
  `status` VARCHAR(8) NOT NULL DEFAULT '0' COMMENT '状态 0未读 1已读',
  `create_date` DATETIME DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_message_info_user_id` (`user_id`),
  KEY `idx_message_info_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='消息通知表';

CREATE TABLE IF NOT EXISTS `staff_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` VARCHAR(64) NOT NULL COMMENT '员工编号',
  `name` VARCHAR(64) NOT NULL COMMENT '员工姓名',
  `sex` INT DEFAULT NULL COMMENT '性别 1男 2女',
  `status` INT DEFAULT 1 COMMENT '状态 1在职 2离职',
  `phone` VARCHAR(32) DEFAULT NULL COMMENT '联系方式',
  `images` VARCHAR(500) DEFAULT NULL COMMENT '照片',
  `create_date` DATETIME DEFAULT NULL COMMENT '创建时间',
  `user_id` BIGINT DEFAULT NULL COMMENT '所属系统账户',
  `resign_date` DATETIME DEFAULT NULL COMMENT '离职时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_staff_info_code` (`code`),
  UNIQUE KEY `uk_staff_info_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='员工信息表';

CREATE TABLE IF NOT EXISTS `bulletin_info` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `title` VARCHAR(128) NOT NULL COMMENT '标题',
  `content` TEXT COMMENT '内容',
  `date` DATETIME DEFAULT NULL COMMENT '公告时间',
  `images` VARCHAR(500) DEFAULT NULL COMMENT '图册',
  `rack_up` INT DEFAULT 1 COMMENT '上下架 0下架 1发布',
  `type` INT DEFAULT 1 COMMENT '类型',
  `publisher` VARCHAR(64) DEFAULT NULL COMMENT '发布人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='公告信息表';

INSERT INTO `t_dept` (`dept_id`, `parent_id`, `dept_name`, `order_num`, `create_time`, `modify_time`)
VALUES
  (1, 0, '平台管理', 1, @now, @now),
  (2, 1, '停车运营中心', 2, @now, @now),
  (3, 1, '客户服务中心', 3, @now, @now)
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `dept_name` = VALUES(`dept_name`),
  `order_num` = VALUES(`order_num`),
  `modify_time` = VALUES(`modify_time`);

INSERT INTO `t_role` (`role_id`, `role_name`, `remark`, `create_time`, `modify_time`)
VALUES
  (74, '管理员', '系统管理员角色', @now, @now),
  (75, '普通用户', '注册用户角色', @now, @now),
  (76, '停车员工', '停车场工作人员角色', @now, @now)
ON DUPLICATE KEY UPDATE
  `role_name` = VALUES(`role_name`),
  `remark` = VALUES(`remark`),
  `modify_time` = VALUES(`modify_time`);

INSERT INTO `t_menu` (`menu_id`, `parent_id`, `menu_name`, `path`, `component`, `perms`, `icon`, `type`, `order_num`, `create_time`, `modify_time`)
VALUES
  (120, 300, '角色管理', '/system/role', 'system/role/Role', 'role:view', 'safety', '0', 13, @now, @now),
  (121, 120, '新增', NULL, NULL, 'role:add', NULL, '1', 1, @now, @now),
  (122, 120, '修改', NULL, NULL, 'role:update', NULL, '1', 2, @now, @now),
  (123, 120, '删除', NULL, NULL, 'role:delete', NULL, '1', 3, @now, @now),
  (124, 120, '导出', NULL, NULL, 'role:export', NULL, '1', 4, @now, @now),
  (130, 300, '菜单管理', '/system/menu', 'system/menu/Menu', 'menu:view', 'bars', '0', 14, @now, @now),
  (131, 130, '新增', NULL, NULL, 'menu:add', NULL, '1', 1, @now, @now),
  (132, 130, '修改', NULL, NULL, 'menu:update', NULL, '1', 2, @now, @now),
  (133, 130, '删除', NULL, NULL, 'menu:delete', NULL, '1', 3, @now, @now),
  (134, 130, '导出', NULL, NULL, 'menu:export', NULL, '1', 4, @now, @now),

  (300, 0, '系统管理', '/manage', 'PageView', NULL, 'setting', '0', 1, @now, @now),
  (420, 300, '系统公告', '/manage/bulletin', 'manage/bulletin/Bulletin', NULL, 'bell', '0', 1, @now, @now),
  (380, 300, '会员管理', '/manage/member', 'manage/member/Member', NULL, 'crown', '0', 2, @now, @now),
  (400, 300, '用户消息', '/manage/message', 'manage/message/Message', NULL, 'message', '0', 3, @now, @now),
  (360, 300, '订单管理', '/manage/order', 'manage/order/Order', NULL, 'profile', '0', 4, @now, @now),
  (350, 300, '车位预约', '/manage/reserve', 'manage/reserve/Reserve', NULL, 'schedule', '0', 5, @now, @now),
  (370, 300, '会员价格', '/manage/rule', 'manage/rule/Rule', NULL, 'dollar', '0', 6, @now, @now),
  (330, 300, '车位管理', '/manage/space', 'manage/space/Space', NULL, 'environment', '0', 7, @now, @now),
  (340, 300, '车位状态', '/manage/spaceStatus', 'manage/spaceStatus/SpaceStatus', NULL, 'dashboard', '0', 8, @now, @now),
  (310, 300, '用户管理', '/manage/user', 'manage/user/User', NULL, 'user', '0', 9, @now, @now),
  (320, 300, '车辆管理', '/manage/vehicle', 'manage/vehicle/Vehicle', NULL, 'car', '0', 10, @now, @now),
  (390, 300, '会员订单', '/manage/record', 'manage/record/Record', NULL, 'file-done', '0', 11, @now, @now),
  (410, 300, '员工管理', '/manage/staff', 'manage/staff/Staff', NULL, 'team', '0', 12, @now, @now),

  (500, 0, '数据统计', '/statistics', 'PageView', NULL, 'bar-chart', '0', 2, @now, @now),
  (510, 500, '月份统计', '/statistics/month', 'statistics/month/Month', NULL, 'bar-chart', '0', 1, @now, @now),
  (520, 500, '车位实时状态', '/statistics/check', 'statistics/check/Check', NULL, 'dashboard', '0', 2, @now, @now),

  (600, 0, '我的信息', '/user', 'PageView', NULL, 'user', '0', 1, @now, @now),
  (605, 600, '个人信息', '/user/personal', 'user/personal/Personal', NULL, 'user', '0', 1, @now, @now),
  (610, 600, '我的车辆', '/user/vehicle', 'user/vehicle/Vehicle', NULL, 'car', '0', 2, @now, @now),
  (620, 600, '车位预约', '/user/reserve', 'user/reserve/Reserve', NULL, 'schedule', '0', 3, @now, @now),
  (630, 600, '我的订单', '/user/order', 'user/order/Order', NULL, 'profile', '0', 4, @now, @now),
  (640, 600, '我的会员', '/user/member', 'user/member/Member', NULL, 'crown', '0', 5, @now, @now),
  (650, 600, '我的消息', '/user/message', 'user/message/Message', NULL, 'message', '0', 6, @now, @now),
  (660, 600, '缴费成功', '/user/pay', 'user/pay/Pay', NULL, 'pay-circle', '0', 7, @now, @now)
ON DUPLICATE KEY UPDATE
  `parent_id` = VALUES(`parent_id`),
  `menu_name` = VALUES(`menu_name`),
  `path` = VALUES(`path`),
  `component` = VALUES(`component`),
  `perms` = VALUES(`perms`),
  `icon` = VALUES(`icon`),
  `type` = VALUES(`type`),
  `order_num` = VALUES(`order_num`),
  `modify_time` = VALUES(`modify_time`);

INSERT INTO `t_user` (`user_id`, `username`, `password`, `dept_id`, `email`, `mobile`, `status`, `create_time`, `modify_time`, `last_login_time`, `ssex`, `description`, `avatar`)
VALUES
  (1, 'admin', @admin_password, 1, 'admin@example.com', '13800000000', '1', @now, @now, @now, '0', '系统管理员', 'default.jpg'),
  (2, 'fank', @fank_password, 3, 'fank@example.com', '13900000000', '1', @now, @now, @now, '2', '默认演示用户', 'default.jpg'),
  (3, 'staff01', @staff01_password, 2, 'staff01@example.com', '13700000001', '1', @now, @now, DATE_SUB(@now, INTERVAL 2 HOUR), '0', '停车场值班员工', 'default.jpg'),
  (4, 'user01', @user01_password, 3, 'user01@example.com', '13700000002', '1', @now, @now, DATE_SUB(@now, INTERVAL 3 HOUR), '0', '演示普通用户-张三', 'default.jpg'),
  (5, 'user02', @user02_password, 3, 'user02@example.com', '13700000003', '1', @now, @now, DATE_SUB(@now, INTERVAL 5 HOUR), '1', '演示普通用户-李四', 'default.jpg')
ON DUPLICATE KEY UPDATE
  `password` = VALUES(`password`),
  `dept_id` = VALUES(`dept_id`),
  `email` = VALUES(`email`),
  `mobile` = VALUES(`mobile`),
  `status` = VALUES(`status`),
  `modify_time` = VALUES(`modify_time`),
  `last_login_time` = VALUES(`last_login_time`),
  `ssex` = VALUES(`ssex`),
  `description` = VALUES(`description`),
  `avatar` = VALUES(`avatar`);

INSERT IGNORE INTO `t_user_role` (`user_id`, `role_id`)
VALUES
  (1, 74),
  (2, 75),
  (3, 76),
  (4, 75),
  (5, 75);

INSERT INTO `t_user_config` (`user_id`, `theme`, `layout`, `multi_page`, `fix_siderbar`, `fix_header`, `color`)
VALUES
  (1, 'dark', 'side', '0', '1', '1', 'rgb(66, 185, 131)'),
  (2, 'dark', 'side', '0', '1', '1', 'rgb(66, 185, 131)'),
  (3, 'dark', 'side', '0', '1', '1', 'rgb(66, 185, 131)'),
  (4, 'dark', 'side', '0', '1', '1', 'rgb(66, 185, 131)'),
  (5, 'dark', 'side', '0', '1', '1', 'rgb(66, 185, 131)')
ON DUPLICATE KEY UPDATE
  `theme` = VALUES(`theme`),
  `layout` = VALUES(`layout`),
  `multi_page` = VALUES(`multi_page`),
  `fix_siderbar` = VALUES(`fix_siderbar`),
  `fix_header` = VALUES(`fix_header`),
  `color` = VALUES(`color`);

INSERT IGNORE INTO `t_role_menu` (`role_id`, `menu_id`)
VALUES
  (74, 120), (74, 121), (74, 122), (74, 123), (74, 124),
  (74, 130), (74, 131), (74, 132), (74, 133), (74, 134),
  (74, 300), (74, 310), (74, 320), (74, 330), (74, 340), (74, 350), (74, 360),
  (74, 370), (74, 380), (74, 390), (74, 400), (74, 410), (74, 420),
  (74, 500), (74, 510), (74, 520),
  (75, 600), (75, 605), (75, 610), (75, 620), (75, 630), (75, 640), (75, 650), (75, 660),
  (76, 300), (76, 330), (76, 340), (76, 350), (76, 360), (76, 400), (76, 420),
  (76, 500), (76, 510), (76, 520);

INSERT INTO `t_login_log` (`id`, `username`, `login_time`, `location`, `ip`)
VALUES
  (1, 'admin', DATE_SUB(@now, INTERVAL 2 DAY), '上海市', '127.0.0.1'),
  (2, 'staff01', DATE_SUB(@now, INTERVAL 1 DAY), '上海市', '192.168.1.20'),
  (3, 'fank', DATE_SUB(@now, INTERVAL 6 HOUR), '上海市', '192.168.1.21'),
  (4, 'user01', DATE_SUB(@now, INTERVAL 3 HOUR), '上海市', '192.168.1.22'),
  (5, 'user02', DATE_SUB(@now, INTERVAL 90 MINUTE), '上海市', '192.168.1.23')
ON DUPLICATE KEY UPDATE
  `username` = VALUES(`username`),
  `login_time` = VALUES(`login_time`),
  `location` = VALUES(`location`),
  `ip` = VALUES(`ip`);

INSERT INTO `t_log` (`id`, `username`, `operation`, `time`, `method`, `params`, `ip`, `create_time`, `location`)
VALUES
  (1, 'admin', '管理员登录系统', 125, 'cc.mrbird.febs.system.controller.LoginController.login()', '{"username":"admin"}', '127.0.0.1', DATE_SUB(@now, INTERVAL 2 DAY), '上海市'),
  (2, 'admin', '发布停车公告', 210, 'cc.mrbird.febs.cos.controller.BulletinInfoController.save()', '{"title":"清明假期停车提醒"}', '127.0.0.1', DATE_SUB(@now, INTERVAL 1 DAY), '上海市'),
  (3, 'staff01', '查看车位状态看板', 86, 'cc.mrbird.febs.cos.controller.SpaceStatusInfoController.selectStatusCheck()', '{}', '192.168.1.20', DATE_SUB(@now, INTERVAL 12 HOUR), '上海市'),
  (4, 'fank', '提交车位预约', 158, 'cc.mrbird.febs.cos.controller.ReserveInfoController.save()', '{"spaceId":5,"vehicleId":1}', '192.168.1.21', DATE_SUB(@now, INTERVAL 10 MINUTE), '上海市'),
  (5, 'user02', '查询停车订单', 93, 'cc.mrbird.febs.cos.controller.ParkOrderInfoController.page()', '{"status":"0"}', '192.168.1.23', DATE_SUB(@now, INTERVAL 75 MINUTE), '上海市')
ON DUPLICATE KEY UPDATE
  `username` = VALUES(`username`),
  `operation` = VALUES(`operation`),
  `time` = VALUES(`time`),
  `method` = VALUES(`method`),
  `params` = VALUES(`params`),
  `ip` = VALUES(`ip`),
  `create_time` = VALUES(`create_time`),
  `location` = VALUES(`location`);

INSERT INTO `t_dict` (`dict_id`, `keyy`, `valuee`, `table_name`, `field_name`)
VALUES
  (1, 'sex', '1-男', 'user_info', 'sex'),
  (2, 'sex', '2-女', 'user_info', 'sex'),
  (3, 'fuel_type', '1-燃油', 'vehicle_info', 'fuel_type'),
  (4, 'fuel_type', '3-油电混动', 'vehicle_info', 'fuel_type'),
  (5, 'fuel_type', '4-电能', 'vehicle_info', 'fuel_type'),
  (6, 'space_status', '-1-预约中', 'space_status_info', 'status'),
  (7, 'space_status', '0-空闲', 'space_status_info', 'status'),
  (8, 'space_status', '1-停车中', 'space_status_info', 'status'),
  (9, 'reserve_status', '0-结束', 'reserve_info', 'status'),
  (10, 'reserve_status', '1-预约中', 'reserve_info', 'status'),
  (11, 'order_status', '0-未支付', 'park_order_info', 'status'),
  (12, 'order_status', '1-已支付', 'park_order_info', 'status'),
  (13, 'message_status', '0-未读', 'message_info', 'status'),
  (14, 'message_status', '1-已读', 'message_info', 'status'),
  (15, 'staff_status', '1-在职', 'staff_info', 'status'),
  (16, 'staff_status', '2-离职', 'staff_info', 'status')
ON DUPLICATE KEY UPDATE
  `keyy` = VALUES(`keyy`),
  `valuee` = VALUES(`valuee`),
  `table_name` = VALUES(`table_name`),
  `field_name` = VALUES(`field_name`);

INSERT INTO `t_test` (`id`, `field1`, `field2`, `field3`, `create_time`)
VALUES
  (1, '演示数据A', 10, '用于 Excel 导入导出测试', DATE_SUB(@now, INTERVAL 9 DAY)),
  (2, '演示数据B', 20, '用于分页展示', DATE_SUB(@now, INTERVAL 5 DAY)),
  (3, '演示数据C', 30, '用于统计报表示例', DATE_SUB(@now, INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  `field1` = VALUES(`field1`),
  `field2` = VALUES(`field2`),
  `field3` = VALUES(`field3`),
  `create_time` = VALUES(`create_time`);

INSERT INTO `user_info` (`id`, `code`, `name`, `images`, `user_images`, `sex`, `create_date`, `phone`, `email`, `user_id`)
VALUES
  (1, 'U-202604010001', 'fank', 'user-fank.jpg', 'user-fank.jpg', 1, DATE_SUB(@now, INTERVAL 30 DAY), '13900000000', 'fank@example.com', 2),
  (2, 'U-202604010002', '张三', 'user-zhangsan.jpg', 'user-zhangsan.jpg', 1, DATE_SUB(@now, INTERVAL 20 DAY), '13700000002', 'user01@example.com', 4),
  (3, 'U-202604010003', '李四', 'user-lisi.jpg', 'user-lisi.jpg', 2, DATE_SUB(@now, INTERVAL 15 DAY), '13700000003', 'user02@example.com', 5)
ON DUPLICATE KEY UPDATE
  `code` = VALUES(`code`),
  `name` = VALUES(`name`),
  `images` = VALUES(`images`),
  `user_images` = VALUES(`user_images`),
  `sex` = VALUES(`sex`),
  `create_date` = VALUES(`create_date`),
  `phone` = VALUES(`phone`),
  `email` = VALUES(`email`);

INSERT INTO `rule_info` (`id`, `name`, `code`, `price`, `days`, `create_date`, `remark`)
VALUES
  (1, '月会员', 'RU-202604010001', 100.00, 30, @now, '默认月度会员方案'),
  (2, '年会员', 'RU-202604010002', 999.00, 365, @now, '默认年度会员方案'),
  (3, '季会员', 'RU-202604010003', 269.00, 90, @now, '默认季度会员方案')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `code` = VALUES(`code`),
  `price` = VALUES(`price`),
  `days` = VALUES(`days`),
  `create_date` = VALUES(`create_date`),
  `remark` = VALUES(`remark`);

INSERT INTO `vehicle_info` (`id`, `vehicle_no`, `vehicle_number`, `vehicle_color`, `name`, `engine_no`, `emission_standard`, `fuel_type`, `images`, `content`, `create_date`, `user_id`)
VALUES
  (1, 'VEH-202604010001', '沪A12345', '白色', '特斯拉 Model 3', 'ENG-TM3001', '新能源', '4', 'vehicle-1.jpg,vehicle-2.jpg', '默认演示车辆，已完成预约', DATE_SUB(@now, INTERVAL 18 DAY), 1),
  (2, 'VEH-202604010002', '沪B56789', '黑色', '比亚迪 汉 DM-i', 'ENG-BYD002', '国六', '3', 'vehicle-2.jpg,vehicle-1.jpg', '用于历史已支付订单演示', DATE_SUB(@now, INTERVAL 16 DAY), 2),
  (3, 'VEH-202604010003', '沪C24680', '银色', '大众 朗逸', 'ENG-VW003', '国六', '1', 'vehicle-3.jpg,vehicle-4.jpg', '当前有一笔未完成停车订单', DATE_SUB(@now, INTERVAL 14 DAY), 3),
  (4, 'VEH-202604010004', '沪D13579', '蓝色', '五菱 缤果', 'ENG-WL004', '新能源', '4', 'vehicle-4.jpg,vehicle-3.jpg', '预留给用户多车辆场景演示', DATE_SUB(@now, INTERVAL 7 DAY), 2)
ON DUPLICATE KEY UPDATE
  `vehicle_no` = VALUES(`vehicle_no`),
  `vehicle_number` = VALUES(`vehicle_number`),
  `vehicle_color` = VALUES(`vehicle_color`),
  `name` = VALUES(`name`),
  `engine_no` = VALUES(`engine_no`),
  `emission_standard` = VALUES(`emission_standard`),
  `fuel_type` = VALUES(`fuel_type`),
  `images` = VALUES(`images`),
  `content` = VALUES(`content`),
  `create_date` = VALUES(`create_date`),
  `user_id` = VALUES(`user_id`);

INSERT INTO `space_info` (`id`, `code`, `name`, `space`, `create_date`, `images`, `price`)
VALUES
  (1, 'SP-A01', 'A01', 'A区-01车位', DATE_SUB(@now, INTERVAL 30 DAY), 'space-a01.jpg,space-a02.jpg', 8.00),
  (2, 'SP-A02', 'A02', 'A区-02车位', DATE_SUB(@now, INTERVAL 30 DAY), 'space-a02.jpg,space-a01.jpg', 8.00),
  (3, 'SP-B01', 'B01', 'B区-01车位', DATE_SUB(@now, INTERVAL 28 DAY), 'space-b01.jpg,space-b02.jpg', 10.00),
  (4, 'SP-B02', 'B02', 'B区-02车位', DATE_SUB(@now, INTERVAL 28 DAY), 'space-b02.jpg,space-b01.jpg', 10.00),
  (5, 'SP-C01', 'C01', 'C区-01车位', DATE_SUB(@now, INTERVAL 25 DAY), 'space-c01.jpg,space-c02.jpg', 12.00),
  (6, 'SP-C02', 'C02', 'C区-02车位', DATE_SUB(@now, INTERVAL 25 DAY), 'space-c02.jpg,space-c01.jpg', 12.00)
ON DUPLICATE KEY UPDATE
  `code` = VALUES(`code`),
  `name` = VALUES(`name`),
  `space` = VALUES(`space`),
  `create_date` = VALUES(`create_date`),
  `images` = VALUES(`images`),
  `price` = VALUES(`price`);

INSERT INTO `space_status_info` (`id`, `space_id`, `status`)
VALUES
  (1, 1, '0'),
  (2, 2, '0'),
  (3, 3, '0'),
  (4, 4, '1'),
  (5, 5, '-1'),
  (6, 6, '0')
ON DUPLICATE KEY UPDATE
  `status` = VALUES(`status`);

INSERT INTO `reserve_info` (`id`, `space_id`, `vehicle_id`, `start_date`, `end_date`, `status`)
VALUES
  (1, 5, 1, DATE_SUB(@now, INTERVAL 10 MINUTE), DATE_ADD(@now, INTERVAL 20 MINUTE), '1'),
  (2, 6, 2, DATE_SUB(@now, INTERVAL 7 DAY), DATE_ADD(DATE_SUB(@now, INTERVAL 7 DAY), INTERVAL 30 MINUTE), '0')
ON DUPLICATE KEY UPDATE
  `space_id` = VALUES(`space_id`),
  `vehicle_id` = VALUES(`vehicle_id`),
  `start_date` = VALUES(`start_date`),
  `end_date` = VALUES(`end_date`),
  `status` = VALUES(`status`);

INSERT INTO `park_order_info` (`id`, `space_id`, `vehicle_id`, `code`, `start_date`, `end_date`, `total_time`, `price`, `total_price`, `pay_date`, `status`, `content`)
VALUES
  (1, 1, 2, 'ORD-202604010001', DATE_SUB(@now, INTERVAL 8 DAY), DATE_ADD(DATE_SUB(@now, INTERVAL 8 DAY), INTERVAL 120 MINUTE), 120.00, 8.00, 16.00, DATE_ADD(DATE_SUB(@now, INTERVAL 8 DAY), INTERVAL 125 MINUTE), '1', '历史已支付订单'),
  (2, 2, 3, 'ORD-202604010002', DATE_SUB(@now, INTERVAL 4 DAY), DATE_ADD(DATE_SUB(@now, INTERVAL 4 DAY), INTERVAL 90 MINUTE), 90.00, 8.00, 12.00, DATE_ADD(DATE_SUB(@now, INTERVAL 4 DAY), INTERVAL 95 MINUTE), '1', '临停订单，已完成支付'),
  (3, 3, 1, 'ORD-202604010003', DATE_SUB(@now, INTERVAL 1 DAY), DATE_ADD(DATE_SUB(@now, INTERVAL 1 DAY), INTERVAL 180 MINUTE), 180.00, 10.00, 0.00, DATE_ADD(DATE_SUB(@now, INTERVAL 1 DAY), INTERVAL 185 MINUTE), '1', '会员免费停车订单'),
  (4, 4, 3, 'ORD-202604010004', DATE_SUB(@now, INTERVAL 45 MINUTE), NULL, NULL, 10.00, NULL, NULL, '0', '车辆在场，待驶出后结算')
ON DUPLICATE KEY UPDATE
  `space_id` = VALUES(`space_id`),
  `vehicle_id` = VALUES(`vehicle_id`),
  `code` = VALUES(`code`),
  `start_date` = VALUES(`start_date`),
  `end_date` = VALUES(`end_date`),
  `total_time` = VALUES(`total_time`),
  `price` = VALUES(`price`),
  `total_price` = VALUES(`total_price`),
  `pay_date` = VALUES(`pay_date`),
  `status` = VALUES(`status`),
  `content` = VALUES(`content`);

INSERT INTO `member_info` (`id`, `user_id`, `member_level`, `start_date`, `end_date`, `price`, `pay_date`)
VALUES
  (1, 1, '1', DATE_SUB(@now, INTERVAL 5 DAY), DATE_ADD(@now, INTERVAL 25 DAY), 100.00, DATE_SUB(@now, INTERVAL 5 DAY)),
  (2, 3, '1', DATE_SUB(@now, INTERVAL 45 DAY), DATE_SUB(@now, INTERVAL 15 DAY), 100.00, DATE_SUB(@now, INTERVAL 45 DAY)),
  (3, 2, '3', DATE_SUB(@now, INTERVAL 2 DAY), DATE_ADD(@now, INTERVAL 88 DAY), 269.00, DATE_SUB(@now, INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE
  `user_id` = VALUES(`user_id`),
  `member_level` = VALUES(`member_level`),
  `start_date` = VALUES(`start_date`),
  `end_date` = VALUES(`end_date`),
  `price` = VALUES(`price`),
  `pay_date` = VALUES(`pay_date`);

INSERT INTO `member_record_info` (`id`, `code`, `member_id`, `price`, `status`, `pay_date`, `user_id`)
VALUES
  (1, 'MEM-202604010001', 1, 100.00, '1', DATE_SUB(@now, INTERVAL 5 DAY), 1),
  (2, 'MEM-202604010002', 3, 269.00, '1', DATE_SUB(@now, INTERVAL 2 DAY), 2),
  (3, 'MEM-202604010003', 2, 999.00, '0', NULL, 3)
ON DUPLICATE KEY UPDATE
  `code` = VALUES(`code`),
  `member_id` = VALUES(`member_id`),
  `price` = VALUES(`price`),
  `status` = VALUES(`status`),
  `pay_date` = VALUES(`pay_date`),
  `user_id` = VALUES(`user_id`);

INSERT INTO `message_info` (`id`, `user_id`, `content`, `status`, `create_date`)
VALUES
  (1, 1, '您好，您的沪A12345已成功预约 C01 车位，请在 30 分钟内到场。', '0', DATE_SUB(@now, INTERVAL 10 MINUTE)),
  (2, 1, '您好，您的会员权益已生效，可享受停车优惠。', '1', DATE_SUB(@now, INTERVAL 5 DAY)),
  (3, 2, '您好，您的季会员购买成功，会员已自动开通。', '0', DATE_SUB(@now, INTERVAL 2 DAY)),
  (4, 2, '您好，您的车辆沪B56789停车订单已支付完成。', '1', DATE_SUB(@now, INTERVAL 8 DAY)),
  (5, 3, '您好，您的车辆沪C24680已驶入停车场，订单正在进行中。', '0', DATE_SUB(@now, INTERVAL 45 MINUTE)),
  (6, 3, '您好，您有一笔年会员订单待支付，请及时处理。', '0', DATE_SUB(@now, INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  `user_id` = VALUES(`user_id`),
  `content` = VALUES(`content`),
  `status` = VALUES(`status`),
  `create_date` = VALUES(`create_date`);

INSERT INTO `staff_info` (`id`, `code`, `name`, `sex`, `status`, `phone`, `images`, `create_date`, `user_id`, `resign_date`)
VALUES
  (1, 'STF-202604010001', '陈志强', 1, 1, '13700010001', 'staff-chen.jpg', DATE_SUB(@now, INTERVAL 60 DAY), 3, NULL),
  (2, 'STF-202604010002', '王敏', 2, 2, '13700010002', 'staff-wang.jpg', DATE_SUB(@now, INTERVAL 120 DAY), NULL, DATE_SUB(@now, INTERVAL 20 DAY))
ON DUPLICATE KEY UPDATE
  `code` = VALUES(`code`),
  `name` = VALUES(`name`),
  `sex` = VALUES(`sex`),
  `status` = VALUES(`status`),
  `phone` = VALUES(`phone`),
  `images` = VALUES(`images`),
  `create_date` = VALUES(`create_date`),
  `user_id` = VALUES(`user_id`),
  `resign_date` = VALUES(`resign_date`);

INSERT INTO `bulletin_info` (`id`, `title`, `content`, `date`, `images`, `rack_up`, `type`, `publisher`)
VALUES
  (1, '系统公告', '欢迎使用停车场管理系统，完整演示数据已经初始化完成。', DATE_SUB(@now, INTERVAL 7 DAY), 'bulletin-system.jpg', 1, 1, 'admin'),
  (2, '清明假期停车提醒', '节假日期间车流量较大，请提前预约车位并留意场内引导。', DATE_SUB(@now, INTERVAL 2 DAY), 'bulletin-holiday.jpg', 1, 1, 'admin'),
  (3, '设备维护通知', 'B 区道闸将于今晚 23:00 进行例行维护，届时请绕行 A 区入口。', DATE_SUB(@now, INTERVAL 12 HOUR), 'bulletin-maintenance.jpg', 0, 2, 'staff01')
ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `content` = VALUES(`content`),
  `date` = VALUES(`date`),
  `images` = VALUES(`images`),
  `rack_up` = VALUES(`rack_up`),
  `type` = VALUES(`type`),
  `publisher` = VALUES(`publisher`);

SET FOREIGN_KEY_CHECKS = 1;
