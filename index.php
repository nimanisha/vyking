<?php
$db_host = getenv('DB_HOST');
$db_port = getenv('DB_PORT');
$db_user = getenv('DB_USER');
$db_pass = getenv('DB_PASSWORD');
$db_name = 'demo_db';

$mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name);

if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

$result = $mysqli->query("SELECT * FROM demo_table");

echo "<h1>MySQL Data</h1><ul>";
while($row = $result->fetch_assoc()) {
    echo "<li>" . implode(", ", $row) . "</li>";
}
echo "</ul>";
?>
