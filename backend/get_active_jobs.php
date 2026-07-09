<?php
header('Content-Type: application/json');
require_once 'config.php';

$mitra_id = $_GET['mitra_id'] ?? '';

if (empty($mitra_id)) {
    echo json_encode(['success' => false, 'message' => 'Mitra ID tidak ditemukan']);
    exit;
}

// Ambil pesanan milik mitra ini yang belum selesai/dibatalkan
$query = "SELECT o.*, p.package_name, u.name as customer_name, u.phone as customer_phone
          FROM orders o
          JOIN service_packages p ON o.package_id = p.id
          JOIN users u ON o.customer_id = u.id
          WHERE o.mitra_id = ? AND o.status IN ('confirmed', 'on_way', 'in_progress')
          ORDER BY o.service_date ASC, o.service_time ASC";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $mitra_id);
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
