<?php
header('Content-Type: application/json');
require_once 'config.php';

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode([
        'success' => false,
        'message' => 'Email dan Password wajib diisi'
    ]);
    exit;
}

// Mencari user berdasarkan email
$stmt = $conn->prepare("SELECT id, name, email, password, role FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    // Verifikasi password (menggunakan password_verify untuk keamanan)
    if (password_verify($password, $user['password'])) {
        // Hapus password dari array sebelum dikirim ke Flutter
        unset($user['password']);

        // Token dummy untuk sesi (bisa dikembangkan menggunakan JWT)
        $user['token'] = bin2hex(random_bytes(16));

        echo json_encode([
            'success' => true,
            'message' => 'Login berhasil',
            'user' => $user
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Password salah'
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Akun tidak ditemukan'
    ]);
}

$stmt->close();
$conn->close();
?>
