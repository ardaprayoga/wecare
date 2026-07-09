<?php
require_once 'config.php';

// Data User Dummy
$users = [
    ['Admin We Care', 'admin@test.com', 'admin123', 'admin'],
    ['Mitra Bersih', 'mitra@test.com', 'mitra123', 'mitra'],
    ['Pelanggan Setia', 'user@test.com', 'user123', 'pelanggan'],
];

foreach ($users as $u) {
    $name = $u[0];
    $email = $u[1];
    $password = password_hash($u[2], PASSWORD_DEFAULT);
    $role = $u[3];

    $stmt = $conn->prepare("INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $name, $email, $password, $role);
    $stmt->execute();
}

echo "3 User Dummy (Admin, Mitra, Pelanggan) berhasil dibuat!";
?>
