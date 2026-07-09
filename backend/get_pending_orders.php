<?php
header('Content-Type: application/json');
require_once 'config.php';

// Ambil pesanan yang statusnya masih pending dan belum ada mitra_id
$query = "SELECT o.*, p.package_name, u.name as customer_name
          FROM orders o
          JOIN service_packages p ON o.package_id = p.id
          JOIN users u ON o.customer_id = u.id
          WHERE o.status = 'pending' AND o.mitra_id IS NULL
          ORDER BY o.created_at DESC";

$result = $conn->query($query);
$orders = [];

while ($row = $result->fetch_assoc()) {
    $orders[] = $row;
}

echo json_encode([
    'success' => true,
    'data' => $orders
]);

$conn->close();
?>
