<?php
header('Content-Type: application/json');
require_once 'config.php';

$order_id = $_POST['order_id'] ?? '';
$customer_id = $_POST['customer_id'] ?? '';
$mitra_id = $_POST['mitra_id'] ?? '';
$rating = $_POST['rating'] ?? 0;
$comment = $_POST['comment'] ?? '';

if (empty($order_id) || empty($rating)) {
    echo json_encode(['success' => false, 'message' => 'Data tidak lengkap']);
    exit;
}

$stmt = $conn->prepare("INSERT INTO reviews (order_id, customer_id, mitra_id, rating, comment) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("iiiis", $order_id, $customer_id, $mitra_id, $rating, $comment);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Terima kasih atas ulasannya!']);
} else {
    echo json_encode(['success' => false, 'message' => 'Gagal menyimpan ulasan: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
