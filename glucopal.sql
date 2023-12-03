-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 03, 2023 at 02:22 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `glucopal`
--

-- --------------------------------------------------------

--
-- Table structure for table `data_nf`
--

CREATE TABLE `data_nf` (
  `id_datanf` int(255) NOT NULL,
  `id_food` int(255) NOT NULL,
  `carbo` int(255) NOT NULL,
  `protein` int(255) NOT NULL,
  `lemak` int(255) NOT NULL,
  `calorie` int(255) NOT NULL,
  `serving_size` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `data_nf`
--

INSERT INTO `data_nf` (`id_datanf`, `id_food`, `carbo`, `protein`, `lemak`, `calorie`, `serving_size`) VALUES
(1, 1, 10, 10, 10, 10, 10),
(2, 2, 15, 15, 15, 15, 15);

-- --------------------------------------------------------

--
-- Table structure for table `food`
--

CREATE TABLE `food` (
  `id_food` int(255) NOT NULL,
  `id_food_category` int(255) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `food`
--

INSERT INTO `food` (`id_food`, `id_food_category`, `name`) VALUES
(1, 1, 'Indomie'),
(2, 1, 'Supermie');

-- --------------------------------------------------------

--
-- Table structure for table `food_category`
--

CREATE TABLE `food_category` (
  `id_food_category` int(255) NOT NULL,
  `name_food_category` varchar(255) NOT NULL,
  `GI_food_category` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `food_category`
--

INSERT INTO `food_category` (`id_food_category`, `name_food_category`, `GI_food_category`) VALUES
(1, 'Noodles', 10);

-- --------------------------------------------------------

--
-- Table structure for table `gl_classification`
--

CREATE TABLE `gl_classification` (
  `id_classification` int(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `range_start` int(11) NOT NULL,
  `range_end` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `gl_classification`
--

INSERT INTO `gl_classification` (`id_classification`, `name`, `range_start`, `range_end`) VALUES
(1, 'Medium', 20, 50);

-- --------------------------------------------------------

--
-- Table structure for table `gl_result`
--

CREATE TABLE `gl_result` (
  `id_result` int(255) NOT NULL,
  `id_classification` int(255) NOT NULL,
  `id_nf` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `gl_result`
--

INSERT INTO `gl_result` (`id_result`, `id_classification`, `id_nf`) VALUES
(1, 1, 1),
(2, 1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `history`
--

CREATE TABLE `history` (
  `id_history` int(255) NOT NULL,
  `id_user` int(255) NOT NULL,
  `id_result` int(255) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `history`
--

INSERT INTO `history` (`id_history`, `id_user`, `id_result`, `timestamp`) VALUES
(1, 1, 1, '2023-12-02 10:48:33'),
(2, 1, 2, '2023-12-02 11:14:18');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `registered` datetime NOT NULL,
  `last_login` datetime NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `gender` char(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `registered`, `last_login`, `password`, `email`, `gender`) VALUES
(1, 'didan', '2023-12-02 17:34:05', '2023-12-02 18:47:51', '$2a$10$k78/nujcHiw2/hDYCJJFee1ChQRd28PtRHDWMLuOmSmcDXNaY4uI2', 'didan@gmail.com', 'L');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `data_nf`
--
ALTER TABLE `data_nf`
  ADD PRIMARY KEY (`id_datanf`),
  ADD KEY `FOREIGNFOOD` (`id_food`);

--
-- Indexes for table `food`
--
ALTER TABLE `food`
  ADD PRIMARY KEY (`id_food`),
  ADD KEY `FOREIGNCATEGORY` (`id_food_category`);

--
-- Indexes for table `food_category`
--
ALTER TABLE `food_category`
  ADD PRIMARY KEY (`id_food_category`);

--
-- Indexes for table `gl_classification`
--
ALTER TABLE `gl_classification`
  ADD PRIMARY KEY (`id_classification`);

--
-- Indexes for table `gl_result`
--
ALTER TABLE `gl_result`
  ADD PRIMARY KEY (`id_result`),
  ADD KEY `FOREIGNCLASS` (`id_classification`),
  ADD KEY `FOREIGNNF` (`id_nf`);

--
-- Indexes for table `history`
--
ALTER TABLE `history`
  ADD PRIMARY KEY (`id_history`),
  ADD KEY `FOREIGNUSER` (`id_user`),
  ADD KEY `FOREIGNRESULT` (`id_result`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `data_nf`
--
ALTER TABLE `data_nf`
  MODIFY `id_datanf` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `food`
--
ALTER TABLE `food`
  MODIFY `id_food` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `food_category`
--
ALTER TABLE `food_category`
  MODIFY `id_food_category` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `gl_classification`
--
ALTER TABLE `gl_classification`
  MODIFY `id_classification` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `gl_result`
--
ALTER TABLE `gl_result`
  MODIFY `id_result` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `history`
--
ALTER TABLE `history`
  MODIFY `id_history` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `data_nf`
--
ALTER TABLE `data_nf`
  ADD CONSTRAINT `FOREIGNFOOD` FOREIGN KEY (`id_food`) REFERENCES `food` (`id_food`);

--
-- Constraints for table `food`
--
ALTER TABLE `food`
  ADD CONSTRAINT `FOREIGNCATEGORY` FOREIGN KEY (`id_food_category`) REFERENCES `food_category` (`id_food_category`);

--
-- Constraints for table `gl_result`
--
ALTER TABLE `gl_result`
  ADD CONSTRAINT `FOREIGNCLASS` FOREIGN KEY (`id_classification`) REFERENCES `gl_classification` (`id_classification`),
  ADD CONSTRAINT `FOREIGNNF` FOREIGN KEY (`id_nf`) REFERENCES `data_nf` (`id_datanf`);

--
-- Constraints for table `history`
--
ALTER TABLE `history`
  ADD CONSTRAINT `FOREIGNRESULT` FOREIGN KEY (`id_result`) REFERENCES `gl_result` (`id_result`),
  ADD CONSTRAINT `FOREIGNUSER` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
