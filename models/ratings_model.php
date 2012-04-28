<?php
# for status, 0 is good, 1 is bad
class Rating extends ActiveRecord\Model {
	static $validates_presence_of = array(
		array('plugin_name', 'plugin_version', 'jenkins_version', 'status')
	);
} 
?>