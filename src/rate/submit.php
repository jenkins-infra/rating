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

      if (isset($_GET['issue']) && preg_match('#^https://github\.com/jenkinsci/[a-zA-Z0-9._-]+/issues/(\d+)$#', $_GET['issue'], $matches)) {
        $row['issue'] = $_GET['issue'];
      } else {
        $issue = (int)preg_replace('/^(JENKINS|HUDSON)-/i', '', $_GET['issue']);
        if ($issue > 0) $row['issue'] = $issue;
      }
      pg_insert($db, 'jenkins_bad', $row);
    }
    pg_close($db);
  }
?>
