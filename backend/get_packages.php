<?php
header('Content-Type: application/json');
require_once 'config.php';

$query = "SELECT * FROM service_packages WHERE is_available = 1";
$result = $conn->query($query);

$packages = [];
while ($row = $result->fetch_assoc()) {
    $packages[] = $row;
}

echo json_encode([
    'success' => true,
    'data' => $packages
]);

$conn->close();
?>
