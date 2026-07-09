<?php
header('Content-Type: application/json');
require_once 'config.php';

// 1. Hitung Total Pesanan
$orderStats = $conn->query("SELECT COUNT(*) as total, SUM(total_price) as revenue FROM orders WHERE status = 'completed'")->fetch_assoc();

// 2. Hitung Jumlah User per Role
$userStats = $conn->query("SELECT role, COUNT(*) as count FROM users GROUP BY role");
$users = [];
while($row = $userStats->fetch_assoc()) {
    $users[$row['role']] = $row['count'];
}

// 3. Ambil 5 Pesanan Terbaru
$recentOrders = $conn->query("SELECT o.*, p.package_name, u.name as customer_name
                             FROM orders o
                             JOIN service_packages p ON o.package_id = p.id
                             JOIN users u ON o.customer_id = u.id
                             ORDER BY o.created_at DESC LIMIT 5");
$latest = [];
while($row = $recentOrders->fetch_assoc()) {
    $latest[] = $row;
}

echo json_encode([
    'success' => true,
    'total_orders' => $orderStats['total'] ?? 0,
    'total_revenue' => $orderStats['revenue'] ?? 0,
    'user_counts' => $users,
    'recent_orders' => $latest
]);

$conn->close();
?>
