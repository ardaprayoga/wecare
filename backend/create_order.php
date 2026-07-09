<?php
header('Content-Type: application/json');
require_once 'config.php';

$customer_id = $_POST['customer_id'] ?? '';
$package_id = $_POST['package_id'] ?? '';
$address = $_POST['address'] ?? '';
$service_date = $_POST['service_date'] ?? '';
$service_time = $_POST['service_time'] ?? '';
$total_price = $_POST['total_price'] ?? '';
$payment_method = $_POST['payment_method'] ?? '';
$additional_notes = $_POST['additional_notes'] ?? '';

if (empty($customer_id) || empty($package_id) || empty($address) || empty($service_date) || empty($service_time)) {
    echo json_encode([
        'success' => false,
        'message' => 'Data pesanan tidak lengkap'
    ]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO orders (customer_id, package_id, address, service_date, service_time, total_price, payment_method, additional_notes, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending')");
$stmt->bind_param("iissssss", $customer_id, $package_id, $address, $service_date, $service_time, $total_price, $payment_method, $additional_notes);

if ($stmt->execute()) {
    echo json_encode([
        'success' => true,
        'message' => 'Pesanan berhasil dibuat',
        'order_id' => $conn->insert_id
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Gagal menyimpan pesanan: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
