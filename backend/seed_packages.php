<?php
require_once 'config.php';

$packages = [
    ['Pembersihan Standar', 'Pembersihan harian untuk rumah tinggal.', 120, 150000, 'Menyapu, mengepel, membersihkan debu.'],
    ['Deep Cleaning', 'Pembersihan menyeluruh termasuk area sulit.', 240, 350000, 'Standard + pembersihan kerak kamar mandi, jendela.'],
    ['Cuci Sofa & Kasur', 'Pembersihan khusus furnitur dengan alat vakum.', 180, 200000, 'Vakum debu, pencucian kain sofa/kasur.'],
];

foreach ($packages as $p) {
    $stmt = $conn->prepare("INSERT INTO service_packages (package_name, description, duration_minutes, base_price, scope_of_work) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("ssids", $p[0], $p[1], $p[2], $p[3], $p[4]);
    $stmt->execute();
}

echo "3 Paket Layanan berhasil ditambahkan!";
?>
