<?php
  /* @author Alan Harder */
  if (isset($_GET['version'])) {
    require_once('/config/dbconfig.php');
    $db = @pg_connect("user=$dbuser password=$dbpass host=$dbserver dbname=$dbname");
    if (!$db) die('DB error');
    $voter = getenv('HTTP_X_FORWARDED_FOR');
    if (empty($voter)) $voter = getenv('REMOTE_ADDR');
    if ($_GET['rating'] == 1) {
      pg_insert($db, 'jenkins_good', array('version' => $_GET['version'], 'voter' => $voter));
    } else {
      $row = array('version' => $_GET['version'], 'voter' => $voter,
                   'rollback' => $_GET['rating'] == -1);
      $issue = (int)preg_replace('/^(JENKINS|HUDSON)-/i', '', $_GET['issue']);
      if ($issue > 0) $row['issue'] = $issue;
      pg_insert($db, 'jenkins_bad', $row);
    }
    pg_close($db);
  }
?>
