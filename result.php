<?php
  header('Content-type: text/javascript');
  header('Cache-control: no-cache');
  require_once('/usr/share/drupal6/sites/default/dbconfig.php');
  $db = @pg_connect("user=$dbuser password=$dbpass host=$dbserver dbname=mindless");
  if (!$db) die('DB error');
  $data = array();
  $q = pg_query($db,
    'select version, count(*) from jenkins_good group by version');
  while ($row = pg_fetch_row($q)) {
    $data[$row[0]] = array('good' => $row[1]);
  }
  $q = pg_query($db,
    'select version, rollback, issue from jenkins_bad order by version');
  while ($row = pg_fetch_row($q)) {
    $data[$row[0]][$row[1]=='t' ? 'rollback' : 'nolike']++;
    if ($row[2]) $data[$row[0]]['issues'][] = $row[2];
  }
  pg_close($db);
  print 'var data = {';
  $first = true;
  foreach ($data as $version => $info) {
    if ($first) $first = false; else print ",\n";
    foreach (array('good','rollback','nolike') as $key) if (!isset($info[$key])) $info[$key] = 0;
    print json_encode($version) . ": [$info[good],$info[nolike],$info[rollback]";
    if ($info[issues]) foreach (array_count_values($info['issues']) as $issue => $counts) print ",$issue,$counts";
    print "]";
  }
  print "\n};\n";
?>
