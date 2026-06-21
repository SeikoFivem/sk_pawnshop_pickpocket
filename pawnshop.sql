CREATE TABLE IF NOT EXISTS `sk_reputation` (
  `identifier` varchar(60) NOT NULL,
  `xp` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
