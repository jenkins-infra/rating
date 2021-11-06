<?php
  header('Cache-control: no-cache');
  require_once('/config/dbconfig.php');
  $data = array();
  function isVersionNumber($val) {
    if (preg_match('/^[0-9.rc]+$/', $val)) { return true; }
    return false;
  }
  function addRow(&$data, $key, $type, $count = 1) {
    $keyToCol = array('good' => 0, 'nolike' => 1, 'rollback' => 2);
    if (!isVersionNumber($key)) { return; }
    if (!isset($data[$key])) { $data[$key] = array(0,0,0); }
    $data[$key][$keyToCol[$type]] += $count;
  }

  function addIssue(&$data, $key, $issue, $count = 1) {
    if (!isVersionNumber($key)) { return; }
    // find the issue in the array already and increase value
    for ($i = 3; $i < count($data[$key]); $i+=2) {
      if ($data[$key][$i] == $issue) {
        $data[$key][$i + 1] += $count;
        return;
      }
    }
    $data[$key][] = $issue;
    $data[$key][] = $count;
  }

  $db = @pg_connect("user=$dbuser password=$dbpass host=$dbserver dbname=$dbname");
  if (!$db) die('DB error');
  $q = pg_query($db, 'select version, count(*) from jenkins_good group by version');
  while ($row = pg_fetch_row($q)) {
    addRow($data, $row[0], 'good', $row[1]);
  }
  $q = pg_query($db, 'select version, rollback, issue from jenkins_bad order by version');
  while ($row = pg_fetch_row($q)) {
    addRow($data, $row[0], $row[1]=='t' ? 'rollback' : 'nolike');
    if ($row[2]) {
      addIssue($data, $row[0], $row[2]);
    }
  }
  pg_close($db);

  $json = json_encode($data);
  if ($_GET['callback']) {
    header('Content-type: application/javascript');
    echo $_GET['callback'] . '(' . $json . ');';
  } else if ($_GET['json']) {
    header('Content-type: application/json');
    echo $json;
  } else {
    header('Content-type: application/javascript');
    echo 'var data = ' . $json . ';';
  }
