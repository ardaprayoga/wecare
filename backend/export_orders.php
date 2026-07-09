<?php
require_once 'config.php';

// Nama file yang akan diunduh
$filename = "Laporan_WeCare_" . date('Y-m-d') . ".csv";

// Header agar browser mendownload file sebagai CSV
header("Content-Type: text/csv");
header("Content-Disposition: attachment; filename=\"$filename\"");

// Buka output stream
$output = fopen("php://output", "w");

// Tulis Judul Kolom (Header CSV)
fputcsv($output, ['ID Pesanan', 'Tanggal', 'Pelanggan', 'Paket Layanan', 'Mitra', 'Metode Bayar', 'Total Harga', 'Status']);

// Ambil data pesanan yang sudah selesai
$query = "SELECT o.id, o.service_date, u.name as customer, p.package_name, m.name as mitra, o.payment_method, o.total_price, o.status
          FROM orders o
          JOIN users u ON o.customer_id = u.id
          JOIN service_packages p ON o.package_id = p.id
          LEFT JOIN users m ON o.mitra_id = m.id
          WHERE o.status = 'completed'
          ORDER BY o.service_date DESC";

$result = $conn->query($query);

while ($row = $result->fetch_assoc()) {
    fputcsv($output, [
        $row['id'],
        $row['service_date'],
        $row['customer'],
        $row['package_name'],
        $row['mitra'] ?? 'N/A',
        $row['payment_method'],
        $row['total_price'],
        $row['status']
    ]);
}

fclose($output);
$conn->close();
?>
