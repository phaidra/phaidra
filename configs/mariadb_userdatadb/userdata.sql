
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;


--
-- Table structure for table `metadata_templates`
--

CREATE TABLE IF NOT EXISTS `metadata_templates` (
  `TEMPID` int(11) NOT NULL AUTO_INCREMENT,
  `uname` varchar(128) NOT NULL,
  `template_name` varchar(128) NOT NULL,
  `metadata` mediumblob NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`TEMPID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=857 ;

-- --------------------------------------------------------

--
-- Table structure for table `quota`
--

CREATE TABLE IF NOT EXISTS `quota` (
  `username` varchar(128) DEFAULT NULL,
  `inum` varchar(10) DEFAULT NULL,
  `fakcode` varchar(10) DEFAULT NULL,
  `quota` bigint(20) NOT NULL,
  `used_space` bigint(20) DEFAULT NULL,
  KEY `idx_username` (`username`),
  KEY `idx_fakcode` (`fakcode`),
  KEY `idx_inum` (`inum`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `search_pattern`
--

CREATE TABLE IF NOT EXISTS `search_pattern` (
  `SID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(2048) DEFAULT NULL,
  `session_id` varchar(128) NOT NULL,
  `pattern` mediumblob NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`SID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=10013609 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_metadata`
--

CREATE TABLE IF NOT EXISTS `user_metadata` (
  `UMID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(128) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `data` mediumblob NOT NULL,
  `namespaces` mediumblob NOT NULL,
  `PID` varchar(50) CHARACTER SET latin1 NOT NULL,
  `isocode` varchar(10) NOT NULL DEFAULT 'de',
  PRIMARY KEY (`UMID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=50367 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE IF NOT EXISTS `user_preferences` (
  `username` varchar(128) NOT NULL DEFAULT '',
  `prefkey` varchar(50) NOT NULL,
  `prefvalue` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`username`,`prefkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `user_terms`
--

CREATE TABLE IF NOT EXISTS `user_terms` (
  `username` varchar(128) NOT NULL DEFAULT '',
  `version` int(11) NOT NULL,
  `agreed` datetime NOT NULL,
  PRIMARY KEY (`username`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `watch_list`
--

CREATE TABLE IF NOT EXISTS `watch_list` (
  `WLID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(128) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`WLID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2031 ;

-- --------------------------------------------------------

--
-- Table structure for table `watch_list_item`
--

CREATE TABLE IF NOT EXISTS `watch_list_item` (
  `WLIID` int(11) NOT NULL AUTO_INCREMENT,
  `PID` varchar(20) NOT NULL,
  `title` varchar(512) NOT NULL,
  `WLID` int(11) NOT NULL,
  PRIMARY KEY (`WLIID`),
  UNIQUE KEY `NoDup` (`WLID`,`PID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=771895 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
