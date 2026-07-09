<?php
header('Content-Type: application/json');
require_once 'config.php';

$order_id = $_POST['order_id'] ?? '';
$new_status = $_POST['status'] ?? '';
$user_id = $_POST['user_id'] ?? ''; // ID Mitra yang mengubah

if (empty($order_id) || empty($new_status)) {
    echo json_encode(['success' => false, 'message' => 'Data tidak lengkap']);
    exit;
}

$conn->begin_transaction();

try {
    // 1. Update status di tabel orders
    $stmt = $conn->prepare("UPDATE orders SET status = ? WHERE id = ?");
    $stmt->bind_param("si", $new_status, $order_id);
    $stmt->execute();

    // 2. Catat di history
    $stmtHist = $conn->prepare("INSERT INTO order_status_history (order_id, status, changed_by) VALUES (?, ?, ?)");
    $stmtHist->bind_param("isi", $order_id, $new_status, $user_id);
    $stmtHist->execute();

    $conn->commit();
    echo json_encode(['success' => true, 'message' => 'Status berhasil diperbarui']);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['success' => false, 'message' => 'Gagal: ' . $e->getMessage()]);
}

$conn->close();
?>
