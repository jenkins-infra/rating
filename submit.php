<?php
  /* @author Alan Harder */
  if ($_GET['version']) {
    require_once('/usr/share/drupal6/sites/default/dbconfig.php');
    $db = @pg_connect("user=$dbuser password=$dbpass host=$dbserver dbname=mindless");
    if (!$db) die('DB error');
    $voter = $_SERVER['HTTP_X_FORWARDED_FOR'];
    if (empty($voter)) $voter = $_SERVER['REMOTE_ADDR'];
    if ($_GET['rating'] == 1) {
      pg_insert($db, 'hudson_good', array('version' => $_GET['version'], 'voter' => $voter));
    } else {
      $row = array('version' => $_GET['version'], 'voter' => $voter,
                   'rollback' => $_GET['rating'] == -1);
      $issue = (int)preg_replace('/^HUDSON-/i', '', $_GET['issue']);
      if ($issue > 0) $row['issue'] = $issue;
      pg_insert($db, 'hudson_bad', $row);
    }
    pg_close($db);
  }
?>
