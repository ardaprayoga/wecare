<?php
header('Content-Type: application/json');
require_once 'config.php';

$id = $_POST['id'] ?? '';
$name = $_POST['name'] ?? '';
$phone = $_POST['phone'] ?? '';

if (empty($id) || empty($name)) {
    echo json_encode(['success' => false, 'message' => 'ID dan Nama wajib diisi']);
    exit;
}

$stmt = $conn->prepare("UPDATE users SET name = ?, phone = ? WHERE id = ?");
$stmt->bind_param("ssi", $name, $phone, $id);

if ($stmt->execute()) {
    // Ambil data terbaru untuk dikirim balik ke Flutter
    $res = $conn->query("SELECT id, name, email, role, phone FROM users WHERE id = $id");
    $user = $res->fetch_assoc();

    echo json_encode([
        'success' => true,
        'message' => 'Profil berhasil diperbarui',
        'user' => $user
    ]);
} else {
    echo json_encode(['success' => false, 'message' => 'Gagal memperbarui profil']);
}

$stmt->close();
$conn->close();
?>
