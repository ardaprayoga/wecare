<?php
header('Content-Type: application/json');
require_once 'config.php';

$customer_id = $_GET['customer_id'] ?? '';

if (empty($customer_id)) {
    echo json_encode(['success' => false, 'message' => 'Customer ID tidak ditemukan']);
    exit;
}

// Ambil pesanan milik pelanggan ini, urutkan dari yang terbaru
$query = "SELECT o.*, p.package_name, u.name as mitra_name, u.phone as mitra_phone
          FROM orders o
          JOIN service_packages p ON o.package_id = p.id
          LEFT JOIN users u ON o.mitra_id = u.id
          WHERE o.customer_id = ?
          ORDER BY o.created_at DESC";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $customer_id);
$stmt->execute();
$result = $stmt->get_result();

$orders = [];
while ($row = $result->fetch_assoc()) {
    $orders[] = $row;
}

echo json_encode(['success' => true, 'data' => $orders]);
$stmt->close();
$conn->close();
?>
