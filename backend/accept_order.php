<?php
header('Content-Type: application/json');
require_once 'config.php';

$order_id = $_POST['order_id'] ?? '';
$mitra_id = $_POST['mitra_id'] ?? '';

if (empty($order_id) || empty($mitra_id)) {
    echo json_encode(['success' => false, 'message' => 'Data tidak lengkap']);
    exit;
}

// Update status pesanan dan set mitra_id
$stmt = $conn->prepare("UPDATE orders SET status = 'confirmed', mitra_id = ? WHERE id = ? AND mitra_id IS NULL");
$stmt->bind_param("ii", $mitra_id, $order_id);

if ($stmt->execute() && $stmt->affected_rows > 0) {
    echo json_encode(['success' => true, 'message' => 'Pesanan berhasil diambil']);
} else {
    echo json_encode(['success' => false, 'message' => 'Gagal mengambil pesanan. Mungkin sudah diambil mitra lain.']);
}

$stmt->close();
$conn->close();
?>
