<?php
# Constant for including/requiring other files
define('__ROOT__', dirname(__FILE__));
# ActiveRecord for database ORM models
require_once __ROOT__.'/php-activerecord/ActiveRecord.php';
# Slim for lean RESTful server with logs
require_once __ROOT__.'/php-slim/Slim/Slim.php';
# Applicaion database models
require_once __ROOT__.'/models/ratings_model.php';
# Application logger (Slim)
require_once __ROOT__.'/TimestampLogFileWriter.php';

# Initializing ActiveRecord configuration

$connections = array(
	'development' => 	'mysql://jenkins:jenkins@localhost/jenkins_ratings;charset=utf8', 
	'production' => ''
);

ActiveRecord\Config::initialize(function($cfg) use($connections)
{
	$cfg->set_model_directory('models');
	$cfg->set_connections($connections);
	
	$cfg->set_default_connection('development');
});

# Initializing Slim RESTful server
$app = new Slim(array(
		'log.enable' => true,
		'log.level' => 4, // 4_DEBUG, 3_INFO, 2_WARN, 1_ERROR, 0_FATAL 
		'log.writer' => new TimestampLogFileWriter(),
		'debug' => true,
		'mode' => 'development' // change to production, when in production
		//'view' => 'MyCustomViewClassName'
));

#
# Application mappings
#

$app->get('/', function() {
});

$app->get('/pluginStatus', function() use ($app) {
	$app->contentType('application/json');
	$log = $app->getLog();
	try {
		// $log->debug("Retrieving ratings...");
		$ratings = Rating::all(array('group' => 'jenkins_version, plugin_name, plugin_version'));
		$r = array();
		foreach($ratings as $rating) {
			$errorStatuses = Rating::all(array('conditions' => "jenkins_version='".$rating->jenkins_version."' AND plugin_name='".$rating->plugin_name."' AND plugin_version='".$rating->plugin_version."' AND status=1"));
			if($errorStatuses && count($errorStatuses) >0) {
				$rating->status = 1;
			} else {
				$rating->status = 0;
			}
			$issues = Rating::all(array(
					'conditions' => "jenkins_version='".$rating->jenkins_version."' AND plugin_name='".$rating->plugin_name."' AND plugin_version='".$rating->plugin_version."' AND issue_id IS NOT NULL",
					'select' => 'issue_id'
			));
			$issuesString = '';
			foreach($issues as $issue) {
				$issuesString .= "<a href='https://issues.jenkins-ci.org/browse/JENKINS-$issue->issue_id'>JENKINS-$issue->issue_id</a><br/>";
			}
			$ratingArr = $rating->to_array();
			$ratingArr['issues'] = $issuesString;
			$r[] = $ratingArr;
		}
		// ActiveRecord is great, but it doesn't handle JSON very well yet
		echo json_encode($r);
	} catch ( Exception $e ) {
		$log->error( $e->getMessage() );
	}
});

$app->get('/ratings', function() use ($app) {
	$app->contentType('application/json');
	$log = $app->getLog();
	try {
		// $log->debug("Retrieving ratings...");
		$ratings = Rating::all();
		$r = array();
		foreach($ratings as $rating) {
			$r[] = $rating->to_array();
		}
		// ActiveRecord is great, but it doesn't handle JSON very well yet
		echo json_encode($r);
	} catch ( Exception $e ) {
		$log->error( $e->getMessage() );
	}
});

$app->post('/ratings', function() use ($app) {
	$app->contentType('application/json');
	$log = $app->getLog();
	
	try {
		$request = $app->request();
		$rating = new Rating();
		
		// No need to escapa since PHP 5.3.0
		$rating->plugin_name = $_POST['plugin_name'];
		$rating->plugin_version = $_POST['plugin_version'];
		$rating->jenkins_version = $_POST['jenkins_version'];
		$rating->status = $_POST['status'];
		$rating->voter_ip = (empty($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['REMOTE_ADDR'] : $_SERVER['HTTP_X_FORWARDED_FOR']);
		$rating->issue_id = ((isset($_POST['issue_id']) && !empty($_POST['issue_id'])) ? (int)preg_replace('/^(JENKINS|HUDSON)-/i', '', $_POST['issue_id']) : null);
		
		if($rating->is_valid()) { // just checking if the NOT NULL's are right
			$rating->save();
			echo json_encode(array('Message' => 'OkeyDokey!'));
		} else {
			echo json_encode(array('Message' => 'Invalid data!'));
		}
	} catch ( Exception $e ) {
		// TBD: improve error handling. Here we are getting a bunch of different errors
		// that could be treated separatedly.
		$log->error( $e->getMessage() );
	}
});

# Executing the application
$app->run();

?>