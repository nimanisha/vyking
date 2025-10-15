<?php
header("Content-Type: application/json");

$db_host = getenv('DB_HOST');
$db_name = getenv('DB_NAME');
$db_user = getenv('DB_USER');
$db_pass = getenv('DB_PASSWORD');

$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "DB connection failed: " . $conn->connect_error]);
    exit;
}

// Ensure clicks table exists
$conn->query("CREATE TABLE IF NOT EXISTS clicks (id INT AUTO_INCREMENT PRIMARY KEY, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $conn->query("INSERT INTO clicks () VALUES ()");
}

$result = $conn->query("SELECT COUNT(*) AS total FROM clicks");
$row = $result->fetch_assoc();

echo json_encode(["clicks" => (int)$row['total']]);
$conn->close();