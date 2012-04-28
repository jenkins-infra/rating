# Database schema

# Creating database and user
CREATE DATABASE jenkins_ratings;
GRANT ALL PRIVILEGES ON jenkins_ratings.* TO 'jenkins'@'localhost' IDENTIFIED BY 'jenkins';
FLUSH PRIVILEGES;
USE jenkins_ratings;

# Creating ratings tables
CREATE TABLE ratings (
  id int(11) AUTO_INCREMENT NOT NULL, 
  jenkins_version varchar(10) NOT NULL, 
  plugin_name varchar(50) NOT NULL, 
  plugin_version varchar(10) NOT NULL, 
  status tinyint NOT NULL, 
  voter_ip varchar(50), 
  issue_id int(11), 
  PRIMARY KEY (id) 
) ENGINE = MyISAM CHARACTER SET utf8 COLLATE utf8_bin AUTO_INCREMENT = 1;

# Index for when searching by plug-in name and version from Jenkins UI

CREATE INDEX plugin_name_version_jenkins_version_idx ON ratings(jenkins_version, plugin_name, plugin_version);

