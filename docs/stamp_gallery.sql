/*
 Navicat Premium Dump SQL

 Source Server         : stamps_gallery
 Source Server Type    : MariaDB
 Source Server Version : 120101 (12.1.1-MariaDB-log)
 Source Host           : 147.93.156.195:3306
 Source Schema         : stamps_gallery

 Target Server Type    : MariaDB
 Target Server Version : 120101 (12.1.1-MariaDB-log)
 File Encoding         : 65001

 Date: 20/10/2025 10:00:36
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for authority_counts
-- ----------------------------
DROP TABLE IF EXISTS `authority_counts`;
CREATE TABLE `authority_counts`  (
  `authority_id` int(10) UNSIGNED NOT NULL,
  `stamp_count` int(10) UNSIGNED NULL DEFAULT 0,
  `fdc_count` int(10) UNSIGNED NULL DEFAULT 0,
  `souvenir_count` int(10) UNSIGNED NULL DEFAULT 0,
  `updated_at` datetime NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`authority_id`) USING BTREE,
  CONSTRAINT `fk_authority_counts_authority` FOREIGN KEY (`authority_id`) REFERENCES `issuing_authority` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for collection_items
-- ----------------------------
DROP TABLE IF EXISTS `collection_items`;
CREATE TABLE `collection_items`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `collection_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → collections.id',
  `philatelic_item_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → philatelic_item.id',
  `acquired_at` date NULL DEFAULT NULL,
  `price_paid_text` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `condition_grade` tinyint(3) UNSIGNED NULL DEFAULT NULL,
  `condition_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `private_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `storage_location` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_status` enum('ordered','paid','shipped','delayed','cancelled','received') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ordered_at` date NULL DEFAULT NULL,
  `expected_at` date NULL DEFAULT NULL,
  `vendor_name` varchar(160) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tracking_code` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `listing_status` enum('available','reserved','sold','withdrawn') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'available',
  `asking_price_text` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `external_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `location_text` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_collection_item`(`collection_id` ASC, `philatelic_item_id` ASC) USING BTREE,
  INDEX `idx_ci_item`(`philatelic_item_id` ASC) USING BTREE,
  INDEX `idx_ci_collection`(`collection_id` ASC) USING BTREE,
  CONSTRAINT `fk_ci_collection` FOREIGN KEY (`collection_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ci_item` FOREIGN KEY (`philatelic_item_id`) REFERENCES `philatelic_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Vật phẩm philatelic (FDC, sheet, block, pair...) gắn vào collection; có metadata on_order/for_sale/for_trade' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for collection_stamps
-- ----------------------------
DROP TABLE IF EXISTS `collection_stamps`;
CREATE TABLE `collection_stamps`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `collection_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → collections.id',
  `stamp_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → stamp.id',
  `acquired_at` date NULL DEFAULT NULL COMMENT 'Ngày sở hữu (nếu có)',
  `price_paid_text` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Giá ghi chú tự do (vd: 200k VND, $8)',
  `condition_grade` tinyint(3) UNSIGNED NULL DEFAULT NULL COMMENT '0–100 (nếu bạn chấm chất lượng bản trưng bày)',
  `condition_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `private_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ghi chú riêng tư',
  `storage_location` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Vị trí lưu (album/hộp...)',
  `order_status` enum('ordered','paid','shipped','delayed','cancelled','received') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Trạng thái đơn hàng',
  `ordered_at` date NULL DEFAULT NULL,
  `expected_at` date NULL DEFAULT NULL,
  `vendor_name` varchar(160) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tracking_code` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `listing_status` enum('available','reserved','sold','withdrawn') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'available' COMMENT 'Trạng thái trưng bày',
  `asking_price_text` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Giá mong muốn (text tự do)',
  `external_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Link ngoài (FB/eBay/website...)',
  `contact_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Cách liên hệ (email/phone/handle)',
  `location_text` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Khu vực giao dịch',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_collection_stamp`(`collection_id` ASC, `stamp_id` ASC) USING BTREE,
  INDEX `idx_cs_stamp`(`stamp_id` ASC) USING BTREE,
  INDEX `idx_cs_collection`(`collection_id` ASC) USING BTREE,
  CONSTRAINT `fk_cs_collection` FOREIGN KEY (`collection_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cs_stamp` FOREIGN KEY (`stamp_id`) REFERENCES `stamps` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Tem gắn vào collection; chứa metadata cho on_order và for_sale/for_trade' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for collections
-- ----------------------------
DROP TABLE IF EXISTS `collections`;
CREATE TABLE `collections`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → members.id (chủ sở hữu)',
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Định danh URL duy nhất trong phạm vi 1 thành viên',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên bộ sưu tập',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `visibility` enum('private','public','unlisted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'private' COMMENT 'Mặc định private',
  `is_system` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = bộ hệ thống (không xóa/đổi tên ở tầng ứng dụng)',
  `system_key` enum('wishlist_private','wishlist_public','on_order','for_sale','for_trade') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Nhận dạng bộ hệ thống; NULL nếu bộ thường',
  `cover_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_collections_slug`(`member_id` ASC, `slug` ASC) USING BTREE,
  UNIQUE INDEX `uq_collections_system_key`(`member_id` ASC, `system_key` ASC) USING BTREE,
  INDEX `idx_collections_member`(`member_id` ASC) USING BTREE,
  CONSTRAINT `fk_collections_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Bộ sưu tập của thành viên (album); hỗ trợ collection hệ thống: wishlist, on_order, for_sale, for_trade' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for contribution_log
-- ----------------------------
DROP TABLE IF EXISTS `contribution_log`;
CREATE TABLE `contribution_log`  (
  `log_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID bản ghi log',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK tới members(id)',
  `contribute_type` enum('NEW_STAMP','UPDATE_FIELD','TRANSLATION','IMAGE_UPLOAD','COLLECTION_ADD') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại hành động đóng góp',
  `related_id` bigint(20) UNSIGNED NULL DEFAULT NULL COMMENT 'ID tem, bản dịch, ảnh... liên quan',
  `points_earned` int(11) NOT NULL DEFAULT 0 COMMENT 'Số điểm/Số lượng kiếm được từ hành động này',
  `field_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Tên field được cập nhật (chỉ để ghi log)',
  `is_approved` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Đã được duyệt/tính điểm',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Thời gian đóng góp',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_member_type_approved`(`member_id` ASC, `contribute_type` ASC, `is_approved` ASC) USING BTREE,
  CONSTRAINT `1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Log chi tiết các hoạt động đóng góp' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for issue
-- ----------------------------
DROP TABLE IF EXISTS `issue`;
CREATE TABLE `issue`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_base` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_base` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Mô tả chi tiết (base)',
  `issuing_authority_id` int(10) UNSIGNED NOT NULL,
  `series_id` int(10) UNSIGNED NOT NULL,
  `release_date` date NULL DEFAULT NULL COMMENT 'Ngày chính thức phát hành (FDC date)',
  `release_date_type` enum('exact','month','year','unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'exact',
  `valid_from` date NULL DEFAULT NULL COMMENT 'Ngày bắt đầu lưu hành bưu chính',
  `valid_to` date NULL DEFAULT NULL COMMENT 'Ngày kết thúc lưu hành (nếu có)',
  `release_type` enum('commemorative','definitive','airmail','postage_due','official','charity','semi_postal','parcel','revenue','single_series','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'commemorative' COMMENT 'Phân loại đợt phát hành',
  `release_status` enum('planned','issued','withdrawn','cancelled','unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'issued' COMMENT 'Trạng thái phát hành',
  `first_day_city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Địa điểm hủy ngày đầu (nếu có)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Tạo lúc',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT 'Cập nhật lúc',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_issue_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_issue_authority`(`issuing_authority_id` ASC) USING BTREE,
  INDEX `idx_issue_series`(`series_id` ASC) USING BTREE,
  INDEX `idx_issue_dates`(`release_date` ASC, `valid_from` ASC, `valid_to` ASC) USING BTREE,
  INDEX `idx_issue_type_status`(`release_type` ASC, `release_status` ASC) USING BTREE,
  INDEX `idx_issue_auth`(`issuing_authority_id` ASC) USING BTREE,
  UNIQUE INDEX `uq_issue_auth_name`(`issuing_authority_id` ASC, `name_base` ASC) USING BTREE,
  INDEX `idx_issue_auth_release`(`issuing_authority_id` ASC, `release_date` ASC) USING BTREE,
  INDEX `idx_issue_release_date`(`release_date` ASC) USING BTREE,
  INDEX `idx_issue_release_type`(`release_type` ASC) USING BTREE,
  CONSTRAINT `fk_issue_authority` FOREIGN KEY (`issuing_authority_id`) REFERENCES `issuing_authority` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_issue_series` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Đợt phát hành tem của một authority (có thể thuộc một series).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for issuing_authority
-- ----------------------------
DROP TABLE IF EXISTS `issuing_authority`;
CREATE TABLE `issuing_authority`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính, định danh duy nhất cho authority',
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_base` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('sovereign_state','colony','occupied','intl_org','intl_org_branch','city_post','local','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Phân loại cơ quan phát hành',
  `flag_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'URL hình cờ hoặc logo (SVG/PNG/WebP)',
  `base_country_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT 'Trỏ đến quốc gia nền tảng (self-reference, ví dụ: South Vietnam → Vietnam)',
  `parent_authority_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT 'Authority cha (self-reference, ví dụ: French Indochina → France)',
  `region` enum('Asia','Europe','Africa','Americas','Oceania','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Khu vực địa lý',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Thời điểm tạo bản ghi',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời điểm cập nhật gần nhất',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `slug`(`slug` ASC) USING BTREE,
  UNIQUE INDEX `uq_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_region`(`region` ASC) USING BTREE,
  INDEX `idx_base_country`(`base_country_id` ASC) USING BTREE,
  INDEX `idx_parent_authority`(`parent_authority_id` ASC) USING BTREE,
  UNIQUE INDEX `uq_issuing_authority_slug`(`slug` ASC) USING BTREE,
  CONSTRAINT `fk_authority_base_country` FOREIGN KEY (`base_country_id`) REFERENCES `issuing_authority` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_authority_parent` FOREIGN KEY (`parent_authority_id`) REFERENCES `issuing_authority` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Bảng cơ quan phát hành tem (quốc gia, vùng, tổ chức quốc tế)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for member_activity_log
-- ----------------------------
DROP TABLE IF EXISTS `member_activity_log`;
CREATE TABLE `member_activity_log`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID của bản ghi hoạt động',
  `member_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT 'FK tới members(id) - Người dùng thực hiện hành động',
  `activity_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại sự kiện',
  `activity_time` datetime NULL DEFAULT NULL COMMENT 'Thời gian xảy ra sự kiện',
  `activity_data` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Chi tiết sự kiện (ví dụ: các field được cập nhật)',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Địa chỉ IP thực hiện hành động (IPv4 hoặc IPv6)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_member_id_type`(`member_id` ASC, `activity_type` ASC) USING BTREE,
  CONSTRAINT `1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 89 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Lịch sử hoạt động chính của người dùng (Đăng ký, kích hoạt, cập nhật)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for member_identities
-- ----------------------------
DROP TABLE IF EXISTS `member_identities`;
CREATE TABLE `member_identities`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` int(10) UNSIGNED NOT NULL,
  `provider` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `provider_user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `provider_profile_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL CHECK (json_valid(`provider_profile_json`)),
  `created_at` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_provider_user`(`provider` ASC, `provider_user_id` ASC) USING BTREE,
  INDEX `idx_member`(`member_id` ASC) USING BTREE,
  CONSTRAINT `fk_member_id` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for member_password_resets
-- ----------------------------
DROP TABLE IF EXISTS `member_password_resets`;
CREATE TABLE `member_password_resets`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` int(10) UNSIGNED NOT NULL,
  `token_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT current_timestamp(),
  `created_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `token_hash`(`token_hash` ASC) USING BTREE,
  INDEX `member_id`(`member_id` ASC) USING BTREE,
  CONSTRAINT `fk_member_reset_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for member_subscriptions
-- ----------------------------
DROP TABLE IF EXISTS `member_subscriptions`;
CREATE TABLE `member_subscriptions`  (
  `sub_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID Đăng ký',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK tới members(id)',
  `plan_id` smallint(5) UNSIGNED NOT NULL COMMENT 'FK tới subscription_plans',
  `renewal_cycle` enum('MONTHLY','QUARTERLY','SEMI_ANNUAL','ANNUAL_13_MONTHS','FREE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Chu kỳ thanh toán',
  `start_date` date NOT NULL COMMENT 'Ngày bắt đầu gói',
  `end_date` date NULL DEFAULT NULL COMMENT 'Ngày hết hạn gói (NULL nếu FREE/tự gia hạn)',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Trạng thái gói hiện tại',
  PRIMARY KEY (`sub_id`) USING BTREE,
  UNIQUE INDEX `uk_member_active_sub`(`member_id` ASC, `is_active` ASC) USING BTREE,
  INDEX `plan_id`(`plan_id` ASC) USING BTREE,
  CONSTRAINT `1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `2` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`plan_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Quản lý gói dịch vụ hiện tại của người dùng' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for member_tokens
-- ----------------------------
DROP TABLE IF EXISTS `member_tokens`;
CREATE TABLE `member_tokens`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID của token',
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK tới members(id)',
  `token_type` enum('ACTIVATION','EMAIL_CHANGE','PASSWORD_RESET') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại hành động',
  `token_value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Giá trị mã thông báo (hash)',
  `new_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Email mới đang chờ xác nhận',
  `expires_at` timestamp NOT NULL COMMENT 'Thời gian hết hiệu lực',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_used` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Trạng thái đã sử dụng token',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `token_value`(`token_value` ASC) USING BTREE,
  INDEX `idx_token_value`(`token_value` ASC) USING BTREE,
  INDEX `member_id`(`member_id` ASC) USING BTREE,
  CONSTRAINT `1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Quản lý mã thông báo kích hoạt/xác nhận email' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for members
-- ----------------------------
DROP TABLE IF EXISTS `members`;
CREATE TABLE `members`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID định danh duy nhất cho mỗi thành viên',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Địa chỉ email (Bắt buộc)',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Biệt danh hoặc tên gọi tắt',
  `fullname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên đầy đủ (Bắt buộc)',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Mật khẩu đã hash (Bắt buộc)',
  `status` enum('INACTIVE','ACTIVE','SUSPENDED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'INACTIVE',
  `total_data_points` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tổng điểm Đóng góp Dữ liệu (Max 4.2 tỷ)',
  `total_translations` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tổng số Bản dịch được duyệt',
  `total_images_approved` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tổng số Hình ảnh được duyệt',
  `total_collection_size` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tổng số Tem trong Bộ sưu tập cá nhân',
  `data_rank_id` smallint(5) UNSIGNED NULL DEFAULT NULL COMMENT 'ID danh hiệu Data Contributor hiện tại',
  `translator_rank_id` smallint(5) UNSIGNED NULL DEFAULT NULL COMMENT 'ID danh hiệu Translator hiện tại',
  `image_rank_id` smallint(5) UNSIGNED NULL DEFAULT NULL COMMENT 'ID danh hiệu Image Contributor hiện tại',
  `collection_rank_id` smallint(5) UNSIGNED NULL DEFAULT NULL COMMENT 'ID danh hiệu Collection Size hiện tại',
  `social_facebook_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'ID Facebook',
  `social_twitter_handle` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Tên người dùng X (Twitter)',
  `social_instagram_handle` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Tên người dùng Instagram',
  `social_linkedin_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'URL LinkedIn',
  `social_zalo_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'ID người dùng Zalo/Số điện thoại',
  `current_plan_id` smallint(5) UNSIGNED NULL DEFAULT 1 COMMENT 'ID Gói dịch vụ hiện tại (Mặc định là 1 - FREE)',
  `password_changed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Thời gian bản ghi được tạo',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời gian bản ghi được cập nhật lần cuối',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  INDEX `fk_data_rank`(`data_rank_id` ASC) USING BTREE,
  INDEX `fk_translator_rank`(`translator_rank_id` ASC) USING BTREE,
  INDEX `fk_image_rank`(`image_rank_id` ASC) USING BTREE,
  INDEX `fk_collection_rank`(`collection_rank_id` ASC) USING BTREE,
  INDEX `fk_current_plan`(`current_plan_id` ASC) USING BTREE,
  CONSTRAINT `fk_collection_rank` FOREIGN KEY (`collection_rank_id`) REFERENCES `rank_titles` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_current_plan` FOREIGN KEY (`current_plan_id`) REFERENCES `subscription_plans` (`plan_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_data_rank` FOREIGN KEY (`data_rank_id`) REFERENCES `rank_titles` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_image_rank` FOREIGN KEY (`image_rank_id`) REFERENCES `rank_titles` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_translator_rank` FOREIGN KEY (`translator_rank_id`) REFERENCES `rank_titles` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 60 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Bảng lưu trữ thông tin thành viên' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for philatelic_item
-- ----------------------------
DROP TABLE IF EXISTS `philatelic_item`;
CREATE TABLE `philatelic_item`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Định danh URL duy nhất',
  `name_base` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên ngắn gọn (base): \"Pair\", \"Block of 4\", \"FDC Hà Nội\"...',
  `description_base` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Mô tả chi tiết (base)',
  `item_type` enum('pair','block_4','strip','corner_block','gutter_pair','se_tenant','full_sheet','souvenir_sheet','fdc','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại vật phẩm philatelic',
  `is_official` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = chính thức; 0 = tư nhân/tùy biến',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ảnh minh họa chính',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_phil_item_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_phil_item_type`(`item_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Lớp vật phẩm sưu tập: pair, block, strip, full sheet, souvenir sheet, FDC...' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for philatelic_item_fdc
-- ----------------------------
DROP TABLE IF EXISTS `philatelic_item_fdc`;
CREATE TABLE `philatelic_item_fdc`  (
  `item_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → philatelic_item.id (item_type=fdc)',
  `cancel_city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Địa danh/dấu hủy',
  `cancel_date` date NULL DEFAULT NULL COMMENT 'Ngày hủy (thường = ngày phát hành)',
  `cachet_artist` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Tác giả cachet (nếu có)',
  `front_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ảnh mặt trước',
  `back_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ảnh mặt sau',
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_fdc_item`(`item_id` ASC) USING BTREE,
  CONSTRAINT `fk_pifdc_item` FOREIGN KEY (`item_id`) REFERENCES `philatelic_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Thuộc tính đặc thù cho FDC' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for philatelic_item_issue
-- ----------------------------
DROP TABLE IF EXISTS `philatelic_item_issue`;
CREATE TABLE `philatelic_item_issue`  (
  `item_id` int(10) UNSIGNED NOT NULL,
  `issue_id` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`item_id`, `issue_id`) USING BTREE,
  INDEX `idx_pii_issue`(`issue_id` ASC) USING BTREE,
  INDEX `idx_pii_item`(`item_id` ASC) USING BTREE,
  CONSTRAINT `fk_pii_issue` FOREIGN KEY (`issue_id`) REFERENCES `issue` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pii_item` FOREIGN KEY (`item_id`) REFERENCES `philatelic_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Nối philatelic_item ↔ issue' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for philatelic_item_sheet
-- ----------------------------
DROP TABLE IF EXISTS `philatelic_item_sheet`;
CREATE TABLE `philatelic_item_sheet`  (
  `item_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → philatelic_item.id',
  `layout_rows` tinyint(3) UNSIGNED NULL DEFAULT NULL COMMENT 'Số hàng',
  `layout_cols` tinyint(3) UNSIGNED NULL DEFAULT NULL COMMENT 'Số cột',
  `total_stamps` smallint(5) UNSIGNED NULL DEFAULT NULL COMMENT 'Tổng số tem',
  `has_margin` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Có margin/trang trí?',
  `gutter_present` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Có gutter?',
  `imprint_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Dòng imprint/mã tờ (nếu có)',
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_sheet_item`(`item_id` ASC) USING BTREE,
  CONSTRAINT `fk_pisheet_item` FOREIGN KEY (`item_id`) REFERENCES `philatelic_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Thuộc tính chi tiết cho item dạng sheet/block/strip' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for philatelic_item_stamp
-- ----------------------------
DROP TABLE IF EXISTS `philatelic_item_stamp`;
CREATE TABLE `philatelic_item_stamp`  (
  `item_id` int(10) UNSIGNED NOT NULL,
  `stamp_id` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`item_id`, `stamp_id`) USING BTREE,
  INDEX `idx_pis_stamp`(`stamp_id` ASC) USING BTREE,
  CONSTRAINT `fk_pis_item` FOREIGN KEY (`item_id`) REFERENCES `philatelic_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pis_stamp` FOREIGN KEY (`stamp_id`) REFERENCES `stamps` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Nối philatelic_item ↔ stamp; lưu cả layout nếu cần' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for rank_titles
-- ----------------------------
DROP TABLE IF EXISTS `rank_titles`;
CREATE TABLE `rank_titles`  (
  `id` smallint(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID duy nhất của danh hiệu (Primary Key)',
  `category` enum('DATA','TRANSLATOR','IMAGE','COLLECTION') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại danh hiệu',
  `level` int(10) UNSIGNED NOT NULL COMMENT 'Cấp độ (1 đến 10)',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên danh hiệu (chỉ dùng tiếng Anh)',
  `required_value` int(10) UNSIGNED NOT NULL COMMENT 'Ngưỡng giá trị yêu cầu (Điểm hoặc Số lượng)',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Trạng thái hoạt động của danh hiệu',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_rank_category_level`(`category` ASC, `level` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Danh sách tất cả các danh hiệu và ngưỡng đạt được' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for series
-- ----------------------------
DROP TABLE IF EXISTS `series`;
CREATE TABLE `series`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_base` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_base` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Mô tả chung về bộ (base)',
  `issuing_authority_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT 'FK → issuing_authority.id; NULL nếu là series ĐẶC BIỆT (liên quốc gia)',
  `start_year` smallint(5) UNSIGNED NULL DEFAULT NULL COMMENT 'Năm bắt đầu series (ước lượng được)',
  `end_year` smallint(5) UNSIGNED NULL DEFAULT NULL COMMENT 'Năm kết thúc (nếu đã kết thúc)',
  `is_special` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = series ĐẶC BIỆT (Europa, Olympic, Christmas…); 0 = series thường của 1 authority',
  `special_type` enum('joint_issue','global_event','commemorative','regional','annual','single_series','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Phân loại series đặc biệt (Europa=joint_issue, Olympic=global_event, Christmas=annual, ...)',
  `notes_base` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ghi chú base (không i18n)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Thời điểm tạo',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời điểm cập nhật',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_series_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_series_authority`(`issuing_authority_id` ASC) USING BTREE,
  INDEX `idx_series_years`(`start_year` ASC, `end_year` ASC) USING BTREE,
  INDEX `idx_series_special`(`is_special` ASC, `special_type` ASC) USING BTREE,
  UNIQUE INDEX `uq_series_auth_name`(`issuing_authority_id` ASC, `name_base` ASC) USING BTREE,
  INDEX `idx_series_auth`(`issuing_authority_id` ASC) USING BTREE,
  CONSTRAINT `fk_series_authority` FOREIGN KEY (`issuing_authority_id`) REFERENCES `issuing_authority` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Bảng bộ tem (series); hỗ trợ series thường & series đặc biệt (Europa, Olympic, ...).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for stamp_holdings
-- ----------------------------
DROP TABLE IF EXISTS `stamp_holdings`;
CREATE TABLE `stamp_holdings`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → members.id',
  `stamp_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → stamp.id',
  `condition` enum('MNH','MH','MNG','UNU','USED','CTO','SPEC') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tình trạng tem',
  `quantity` smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Số lượng sở hữu ở tình trạng này',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ghi chú riêng (tuỳ chọn)',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_holdings_member_stamp_cond`(`member_id` ASC, `stamp_id` ASC, `condition` ASC) USING BTREE,
  INDEX `idx_holdings_member`(`member_id` ASC) USING BTREE,
  INDEX `idx_holdings_stamp`(`stamp_id` ASC) USING BTREE,
  CONSTRAINT `fk_holdings_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_holdings_stamp` FOREIGN KEY (`stamp_id`) REFERENCES `stamps` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Số lượng tem theo tình trạng (MNH, MH, MNG, UNU, USED, CTO, SPEC) của từng thành viên' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for stamp_topic
-- ----------------------------
DROP TABLE IF EXISTS `stamp_topic`;
CREATE TABLE `stamp_topic`  (
  `stamp_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → stamp.id',
  `topic_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → topic.id',
  `confidence` tinyint(3) UNSIGNED NULL DEFAULT NULL COMMENT 'Độ tin cậy (0–100) của việc gán topic cho tem',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`stamp_id`, `topic_id`) USING BTREE,
  INDEX `idx_stamp_topic_topic`(`topic_id` ASC) USING BTREE,
  INDEX `idx_stamp_topic_stamp`(`stamp_id` ASC) USING BTREE,
  CONSTRAINT `fk_stamp_topic_stamp` FOREIGN KEY (`stamp_id`) REFERENCES `stamps` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_stamp_topic_topic` FOREIGN KEY (`topic_id`) REFERENCES `topic` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Gắn topic cho tem (stamp)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for stamps
-- ----------------------------
DROP TABLE IF EXISTS `stamps`;
CREATE TABLE `stamps`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính định danh con tem',
  `slug` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Định danh URL duy nhất (vd: vietnam-1990-hoan-kiem-500d)',
  `issue_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → issue.id (mỗi tem thuộc 1 đợt phát hành)',
  `release_date` date NULL DEFAULT NULL,
  `release_date_type` enum('exact','month','year','unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'exact',
  `scott_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Số Scott (Scott number) nếu có',
  `caption_base` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Mô tả ngắn (caption) về hình/đề tài của tem (không phải tên chính thức)',
  `description_base` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Mô tả chi tiết hơn (bối cảnh, ý nghĩa…)',
  `denomination` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Mệnh giá kèm tiền tệ ở dạng chuẩn hiển thị, vd: 500 VND, 1.20 EUR, 5¢, 2s 6d',
  `color` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Màu sắc chủ đạo',
  `shape` enum('rectangular','square','triangular','circular','freeform') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'rectangular' COMMENT 'Hình dạng tem',
  `orientation` enum('portrait','landscape','square') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'portrait' COMMENT 'Định hướng (dọc/ngang/vuông)',
  `width_mm` decimal(6, 2) NULL DEFAULT NULL COMMENT 'Chiều rộng (mm)',
  `height_mm` decimal(6, 2) NULL DEFAULT NULL COMMENT 'Chiều cao (mm)',
  `perforation` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Mô tả răng (vd: 13×13½, imperforate)',
  `printing_method` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Phương pháp in (offset, gravure, engraved...)',
  `designer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Họa sĩ thiết kế',
  `engraver` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Người khắc (nếu có)',
  `printer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Nhà in',
  `variant_of` int(10) UNSIGNED NULL DEFAULT NULL COMMENT 'FK → stamp.id (nếu là biến thể của một tem gốc)',
  `variant_type` enum('overprint','surcharge','imperforate','color-difference','paper-difference','design-change','error','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Loại biến thể',
  `status` enum('issued','unissued','withdrawn','reprint','specimen','proof','error','essay') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'issued' COMMENT 'Trạng thái phát hành',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ảnh minh họa (CDN/URL)',
  `is_mini_sheet` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 nếu thuộc mini sheet',
  `is_souvenir_sheet` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 nếu thuộc souvenir sheet',
  `is_fdc_related` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 nếu có FDC liên quan',
  `watermark` int(10) UNSIGNED NULL DEFAULT NULL COMMENT 'FK → watermark.id (nếu có watermark cụ thể)',
  `notes_base` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ghi chú kỹ thuật/khác',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `slug`(`slug` ASC) USING BTREE,
  UNIQUE INDEX `uq_stamp_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_stamp_issue`(`issue_id` ASC) USING BTREE,
  INDEX `idx_stamp_variant_of`(`variant_of` ASC) USING BTREE,
  INDEX `idx_stamp_scott_number`(`scott_number` ASC) USING BTREE,
  INDEX `fk_stamp_watermark`(`watermark` ASC) USING BTREE,
  INDEX `idx_stamp_issue_variant`(`issue_id` ASC, `variant_of` ASC) USING BTREE,
  INDEX `idx_stamp_release_date`(`release_date` ASC) USING BTREE,
  CONSTRAINT `fk_stamp_issue` FOREIGN KEY (`issue_id`) REFERENCES `issue` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_stamp_variant` FOREIGN KEY (`variant_of`) REFERENCES `stamps` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_stamp_watermark` FOREIGN KEY (`watermark`) REFERENCES `watermark` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Bảng quản lý thông tin chi tiết từng con tem' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for subscription_plans
-- ----------------------------
DROP TABLE IF EXISTS `subscription_plans`;
CREATE TABLE `subscription_plans`  (
  `plan_id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID Gói dịch vụ',
  `plan_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên gói (FREE, PRO1, PRO2)',
  `monthly_price` decimal(10, 2) NOT NULL COMMENT 'Giá hàng tháng',
  `quarterly_price` decimal(10, 2) NOT NULL COMMENT 'Giá 3 tháng (Tặng 7 ngày)',
  `semi_annual_price` decimal(10, 2) NOT NULL COMMENT 'Giá 6 tháng (Tặng 14 ngày)',
  `annual_price` decimal(10, 2) NOT NULL COMMENT 'Giá 12 tháng (Tặng 1 tháng)',
  `max_stamps` int(10) UNSIGNED NOT NULL COMMENT 'Giới hạn Tem quản lý (0 = Vô hạn)',
  `max_collections` smallint(5) UNSIGNED NOT NULL COMMENT 'Giới hạn Bộ sưu tập (0 = Vô hạn)',
  `is_free` tinyint(1) NOT NULL COMMENT 'TRUE nếu là gói miễn phí',
  PRIMARY KEY (`plan_id`) USING BTREE,
  UNIQUE INDEX `plan_name`(`plan_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Định nghĩa các gói dịch vụ và quyền lợi' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for topic
-- ----------------------------
DROP TABLE IF EXISTS `topic`;
CREATE TABLE `topic`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính, định danh duy nhất cho topic',
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Định danh URL (ngôn ngữ trung lập, ví dụ: birds, olympics)',
  `name_base` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên gốc (thường là tiếng Anh)',
  `parent_topic_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT 'Chủ đề cha (self-reference)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Thời điểm tạo topic',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời điểm cập nhật gần nhất',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_topic_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_topic_parent`(`parent_topic_id` ASC) USING BTREE,
  CONSTRAINT `fk_topic_parent` FOREIGN KEY (`parent_topic_id`) REFERENCES `topic` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 287 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Bảng chủ đề (topic) ngữ nghĩa để gắn cho tem, series, issue, theme' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for watermark
-- ----------------------------
DROP TABLE IF EXISTS `watermark`;
CREATE TABLE `watermark`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Định danh URL duy nhất (vd: crown-double-lined)',
  `name_base` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên watermark gốc (base), ví dụ: \"Crown Double Lined\"',
  `description_base` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Mô tả chi tiết watermark (base)',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Ảnh hoặc hình minh họa watermark (vẽ hoặc chụp ngược sáng)',
  `used_by_authority` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Tên authority hoặc quốc gia thường dùng watermark này (vd: UK, India)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Tạo lúc',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT 'Cập nhật lúc',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_watermark_slug`(`slug` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Danh mục watermark (hình chìm) được dùng trong tem' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
