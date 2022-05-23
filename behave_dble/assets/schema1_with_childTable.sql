-- MySQL dump 10.13  Distrib 5.7.13, for linux-glibc2.5 (x86_64)
--
-- Host: 127.0.0.1    Database: schema1
-- ------------------------------------------------------
-- Server version	5.7.13-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Position to start replication or point-in-time recovery from
--

-- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=1241;

--
-- Current Database: `schema1`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `schema1` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `schema1`;

--
-- Table structure for table `nosharding`
--

DROP TABLE IF EXISTS `nosharding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nosharding` (
  `id` int(11) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nosharding`
--

LOCK TABLES `nosharding` WRITE;
/*!40000 ALTER TABLE `nosharding` DISABLE KEYS */;
INSERT INTO `nosharding` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5);
/*!40000 ALTER TABLE `nosharding` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sharding_1_t1`
--

DROP TABLE IF EXISTS `sharding_1_t1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sharding_1_t1` (
  `id` int(11) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sharding_1_t1`
--

LOCK TABLES `sharding_1_t1` WRITE;
/*!40000 ALTER TABLE `sharding_1_t1` DISABLE KEYS */;
INSERT INTO `sharding_1_t1` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5);
/*!40000 ALTER TABLE `sharding_1_t1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sharding_2_t1`
--

DROP TABLE IF EXISTS `sharding_2_t1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sharding_2_t1` (
  `id` int(11) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sharding_2_t1`
--

LOCK TABLES `sharding_2_t1` WRITE;
/*!40000 ALTER TABLE `sharding_2_t1` DISABLE KEYS */;
INSERT INTO `sharding_2_t1` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5);
/*!40000 ALTER TABLE `sharding_2_t1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `foreign_table`
--

DROP TABLE IF EXISTS `foreign_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `foreign_table` (
  `id_key` int(11) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_key`),
  KEY `id` (`id`),
  CONSTRAINT `foreign_table_ibfk_1` FOREIGN KEY (`id`) REFERENCES `sharding_2_t1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `foreign_table`
--

LOCK TABLES `foreign_table` WRITE;
/*!40000 ALTER TABLE `foreign_table` DISABLE KEYS */;
INSERT INTO `foreign_table` VALUES (1,'Tom',30,1),(2,'Jerry',12,2),(3,'Spike',5,3),(4,'Nibbles',3,4);
/*!40000 ALTER TABLE `foreign_table` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `sharding_4_t1`
--

DROP TABLE IF EXISTS `sharding_4_t1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sharding_4_t1` (
  `id` int(11) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sharding_4_t1`
--

LOCK TABLES `sharding_4_t1` WRITE;
/*!40000 ALTER TABLE `sharding_4_t1` DISABLE KEYS */;
INSERT INTO `sharding_4_t1` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5);
/*!40000 ALTER TABLE `sharding_4_t1` ENABLE KEYS */;
UNLOCK TABLES;

DROP TABLE IF EXISTS `tb_child`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_child` (
  `id` int(11) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `child_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`child_id`),
  CONSTRAINT `foreign_table_childtable_1` FOREIGN KEY (`child_id`) REFERENCES `sharding_4_t1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_child`
--

LOCK TABLES `tb_child` WRITE;
/*!40000 ALTER TABLE `tb_child` DISABLE KEYS */;
INSERT INTO `tb_child` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5);
/*!40000 ALTER TABLE `tb_child` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test`
--

LOCK TABLES `test` WRITE;
/*!40000 ALTER TABLE `test` DISABLE KEYS */;
INSERT INTO `test` VALUES (1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5);
/*!40000 ALTER TABLE `test` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-09-24 15:33:19
