<?php
header('Content-Type: application/json');
require_once 'config.php';

$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$phone = $_POST['phone'] ?? '';
$role = $_POST['role'] ?? 'pelanggan'; // Default role is pelanggan

if (empty($name) || empty($email) || empty($password)) {
    echo json_encode([
        'success' => false,
        'message' => 'Nama, Email, dan Password wajib diisi'
    ]);
    exit;
}

// Cek apakah email sudah terdaftar
$checkEmail = $conn->prepare("SELECT id FROM users WHERE email = ?");
$checkEmail->bind_param("s", $email);
$checkEmail->execute();
$result = $checkEmail->get_result();

if ($result->num_rows > 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Email sudah terdaftar'
    ]);
    exit;
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Simpan user baru
$stmt = $conn->prepare("INSERT INTO users (name, email, password, phone, role) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("sssss", $name, $email, $hashedPassword, $phone, $role);

if ($stmt->execute()) {
    $userId = $conn->insert_id;
    echo json_encode([
        'success' => true,
        'message' => 'Registrasi berhasil',
        'user_id' => $userId
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Gagal melakukan registrasi: ' . $conn->error
    ]);
}

$stmt->close();
$conn->close();
?>
