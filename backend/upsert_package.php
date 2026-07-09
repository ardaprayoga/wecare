<?php
header('Content-Type: application/json');
require_once 'config.php';

$id = $_POST['id'] ?? null;
$name = $_POST['package_name'] ?? '';
$desc = $_POST['description'] ?? '';
$dur = $_POST['duration_minutes'] ?? 0;
$price = $_POST['base_price'] ?? 0;
$scope = $_POST['scope_of_work'] ?? '';

if (empty($name) || empty($price)) {
    echo json_encode(['success' => false, 'message' => 'Nama dan Harga wajib diisi']);
    exit;
}

if ($id) {
    // Update paket yang sudah ada
    $stmt = $conn->prepare("UPDATE service_packages SET package_name=?, description=?, duration_minutes=?, base_price=?, scope_of_work=? WHERE id=?");
    $stmt->bind_param("ssidsi", $name, $desc, $dur, $price, $scope, $id);
} else {
    // Tambah paket baru
    $stmt = $conn->prepare("INSERT INTO service_packages (package_name, description, duration_minutes, base_price, scope_of_work) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("ssids", $name, $desc, $dur, $price, $scope);
}

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Paket berhasil disimpan']);
} else {
    echo json_encode(['success' => false, 'message' => 'Gagal menyimpan: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
