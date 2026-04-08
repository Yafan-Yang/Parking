-- Reverse-engineered from the current codebase on 2026-04-01.
-- This script creates the core system tables, business tables,
-- required roles/menus, default accounts, and a small amount of demo data.

CREATE DATABASE IF NOT EXISTS `parking_lot_cos`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `parking_lot_cos`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET @now = NOW();
SET @admin_password = 'bfc62b3f67a4c3e57df84dad8cc48a3b';
SET @fank_password = '5cfdfa876f1908a8432c752c67b3c748';

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
  (1, 0, '平台管理', 1, @now, @now)
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
  (2, 'fank', @fank_password, 1, 'fank@example.com', '13900000000', '1', @now, @now, @now, '2', '默认演示用户', 'default.jpg')
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
  (2, 75);

INSERT INTO `t_user_config` (`user_id`, `theme`, `layout`, `multi_page`, `fix_siderbar`, `fix_header`, `color`)
VALUES
  (1, 'dark', 'side', '0', '1', '1', 'rgb(66, 185, 131)'),
  (2, 'dark', 'side', '0', '1', '1', 'rgb(66, 185, 131)')
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

INSERT INTO `user_info` (`id`, `code`, `name`, `images`, `user_images`, `sex`, `create_date`, `phone`, `email`, `user_id`)
VALUES
  (1, 'U-202604010001', 'fank', 'user-fank.jpg', 'user-fank.jpg', 1, @now, '13900000000', 'fank@example.com', 2)
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
  (2, '年会员', 'RU-202604010002', 999.00, 365, @now, '默认年度会员方案')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `code` = VALUES(`code`),
  `price` = VALUES(`price`),
  `days` = VALUES(`days`),
  `create_date` = VALUES(`create_date`),
  `remark` = VALUES(`remark`);

INSERT INTO `space_info` (`id`, `code`, `name`, `space`, `create_date`, `images`, `price`)
VALUES
  (1, 'SP-A01', 'A01', 'A区-01车位', @now, 'space-a01.jpg,space-a02.jpg', 8.00),
  (2, 'SP-A02', 'A02', 'A区-02车位', @now, 'space-a02.jpg,space-a01.jpg', 8.00),
  (3, 'SP-B01', 'B01', 'B区-01车位', @now, 'space-b01.jpg,space-b02.jpg', 10.00),
  (4, 'SP-B02', 'B02', 'B区-02车位', @now, 'space-b02.jpg,space-b01.jpg', 10.00)
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
  (4, 4, '0')
ON DUPLICATE KEY UPDATE
  `status` = VALUES(`status`);

INSERT INTO `bulletin_info` (`id`, `title`, `content`, `date`, `images`, `rack_up`, `type`, `publisher`)
VALUES
  (1, '系统公告', '欢迎使用停车场管理系统，默认数据已经初始化完成。', @now, 'bulletin-system.jpg', 1, 1, 'admin')
ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `content` = VALUES(`content`),
  `date` = VALUES(`date`),
  `images` = VALUES(`images`),
  `rack_up` = VALUES(`rack_up`),
  `type` = VALUES(`type`),
  `publisher` = VALUES(`publisher`);

SET FOREIGN_KEY_CHECKS = 1;
