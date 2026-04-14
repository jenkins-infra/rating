<?php
require_once('/config/dbconfig.php');
$db = @pg_connect("user=$dbuser password=$dbpass host=$dbserver dbname=$dbname");
if (!$db) {
  http_response_code(500);
  echo "db not ready";
  exit;
}
echo "ok";
