<?php
/**
 * Yomi API - Single-file REST API
 * 
 * Endpoints (via ?action= parameter):
 * 
 * AUTH:
 *   POST ?action=register       { email, password }
 *   POST ?action=login          { email, password }
 * 
 * NOVELS:
 *   GET  ?action=get_novels
 *   GET  ?action=get_novel&id=<novel_id>
 *   GET  ?action=get_chapters&novel_id=<novel_id>
 * 
 * LIBRARY:
 *   GET  ?action=get_library&user_id=<user_id>
 *   POST ?action=add_to_library       { user_id, novel_id }
 *   POST ?action=remove_from_library  { user_id, novel_id }
 *   POST ?action=update_progress      { user_id, novel_id, chapter }
 */

// ─── Database Configuration ─────────────────────────────────────────────────
$DB_HOST = 'localhost';
$DB_USER = 'root';
$DB_PASS = '';
$DB_NAME = 'yomi_db';

// ─── CORS & Headers ─────────────────────────────────────────────────────────
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ─── Database Connection ─────────────────────────────────────────────────────
$conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $conn->connect_error]);
    exit;
}
$conn->set_charset('utf8mb4');

// ─── Helpers ─────────────────────────────────────────────────────────────────
function getPostData() {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    if (!$data) {
        $data = $_POST;
    }
    return $data;
}

function respond($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data);
    exit;
}

function respondError($message, $code = 400) {
    respond(['error' => $message], $code);
}

// ─── Router ──────────────────────────────────────────────────────────────────
$action = $_GET['action'] ?? '';

switch ($action) {
    // ═══════════════════════════════════════════════════════════════════════
    // AUTH
    // ═══════════════════════════════════════════════════════════════════════

    case 'register':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') respondError('POST required', 405);
        
        $data = getPostData();
        $email = trim($data['email'] ?? '');
        $password = $data['password'] ?? '';
        
        if (empty($email) || empty($password)) {
            respondError('Email and password are required');
        }
        
        // Check if email already exists
        $stmt = $conn->prepare('SELECT id FROM users WHERE email = ?');
        $stmt->bind_param('s', $email);
        $stmt->execute();
        if ($stmt->get_result()->num_rows > 0) {
            respondError('Email already registered');
        }
        $stmt->close();
        
        // Create user
        $hash = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $conn->prepare('INSERT INTO users (email, password_hash) VALUES (?, ?)');
        $stmt->bind_param('ss', $email, $hash);
        
        if ($stmt->execute()) {
            respond([
                'success' => true,
                'user_id' => $conn->insert_id,
                'email' => $email,
            ]);
        } else {
            respondError('Registration failed', 500);
        }
        break;

    case 'login':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') respondError('POST required', 405);
        
        $data = getPostData();
        $email = trim($data['email'] ?? '');
        $password = $data['password'] ?? '';
        
        if (empty($email) || empty($password)) {
            respondError('Email and password are required');
        }
        
        $stmt = $conn->prepare('SELECT id, email, password_hash FROM users WHERE email = ?');
        $stmt->bind_param('s', $email);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            respondError('Invalid email or password', 401);
        }
        
        $user = $result->fetch_assoc();
        $stmt->close();
        
        if (!password_verify($password, $user['password_hash'])) {
            respondError('Invalid email or password', 401);
        }
        
        respond([
            'success' => true,
            'user_id' => (int) $user['id'],
            'email' => $user['email'],
        ]);
        break;

    // ═══════════════════════════════════════════════════════════════════════
    // NOVELS
    // ═══════════════════════════════════════════════════════════════════════

    case 'get_novels':
        $result = $conn->query('SELECT * FROM novels ORDER BY created_at DESC');
        $novels = [];
        while ($row = $result->fetch_assoc()) {
            $novels[] = [
                'id' => (int) $row['id'],
                'title' => $row['title'],
                'author' => $row['author'],
                'synopsis' => $row['synopsis'],
                'cover_image' => $row['cover_image'],
                'total_chapters' => (int) $row['total_chapters'],
                'created_at' => $row['created_at'],
            ];
        }
        respond($novels);
        break;

    case 'get_novel':
        $id = (int) ($_GET['id'] ?? 0);
        if ($id <= 0) respondError('Novel ID is required');
        
        $stmt = $conn->prepare('SELECT * FROM novels WHERE id = ?');
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            respondError('Novel not found', 404);
        }
        
        $row = $result->fetch_assoc();
        respond([
            'id' => (int) $row['id'],
            'title' => $row['title'],
            'author' => $row['author'],
            'synopsis' => $row['synopsis'],
            'cover_image' => $row['cover_image'],
            'total_chapters' => (int) $row['total_chapters'],
            'created_at' => $row['created_at'],
        ]);
        break;

    case 'get_chapters':
        $novelId = (int) ($_GET['novel_id'] ?? 0);
        if ($novelId <= 0) respondError('Novel ID is required');
        
        $stmt = $conn->prepare('SELECT * FROM chapters WHERE novel_id = ? ORDER BY chapter_number ASC');
        $stmt->bind_param('i', $novelId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $chapters = [];
        while ($row = $result->fetch_assoc()) {
            $chapters[] = [
                'id' => (int) $row['id'],
                'novel_id' => (int) $row['novel_id'],
                'chapter_number' => (int) $row['chapter_number'],
                'title' => $row['title'],
                'content' => $row['content'],
            ];
        }
        respond($chapters);
        break;

    // ═══════════════════════════════════════════════════════════════════════
    // LIBRARY
    // ═══════════════════════════════════════════════════════════════════════

    case 'get_library':
        $userId = (int) ($_GET['user_id'] ?? 0);
        if ($userId <= 0) respondError('User ID is required');
        
        $stmt = $conn->prepare('SELECT * FROM user_library WHERE user_id = ? ORDER BY added_at DESC');
        $stmt->bind_param('i', $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $entries = [];
        while ($row = $result->fetch_assoc()) {
            $entries[] = [
                'novel_id' => (int) $row['novel_id'],
                'last_chapter_read' => (int) $row['last_chapter_read'],
                'added_at' => $row['added_at'],
            ];
        }
        respond($entries);
        break;

    case 'add_to_library':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') respondError('POST required', 405);
        
        $data = getPostData();
        $userId = (int) ($data['user_id'] ?? 0);
        $novelId = (int) ($data['novel_id'] ?? 0);
        
        if ($userId <= 0 || $novelId <= 0) {
            respondError('user_id and novel_id are required');
        }
        
        $stmt = $conn->prepare('INSERT IGNORE INTO user_library (user_id, novel_id, last_chapter_read) VALUES (?, ?, 1)');
        $stmt->bind_param('ii', $userId, $novelId);
        
        if ($stmt->execute()) {
            respond(['success' => true]);
        } else {
            respondError('Failed to add to library', 500);
        }
        break;

    case 'remove_from_library':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') respondError('POST required', 405);
        
        $data = getPostData();
        $userId = (int) ($data['user_id'] ?? 0);
        $novelId = (int) ($data['novel_id'] ?? 0);
        
        if ($userId <= 0 || $novelId <= 0) {
            respondError('user_id and novel_id are required');
        }
        
        $stmt = $conn->prepare('DELETE FROM user_library WHERE user_id = ? AND novel_id = ?');
        $stmt->bind_param('ii', $userId, $novelId);
        
        if ($stmt->execute()) {
            respond(['success' => true]);
        } else {
            respondError('Failed to remove from library', 500);
        }
        break;

    case 'update_progress':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') respondError('POST required', 405);
        
        $data = getPostData();
        $userId = (int) ($data['user_id'] ?? 0);
        $novelId = (int) ($data['novel_id'] ?? 0);
        $chapter = (int) ($data['chapter'] ?? 0);
        
        if ($userId <= 0 || $novelId <= 0 || $chapter <= 0) {
            respondError('user_id, novel_id, and chapter are required');
        }
        
        $stmt = $conn->prepare('UPDATE user_library SET last_chapter_read = ? WHERE user_id = ? AND novel_id = ?');
        $stmt->bind_param('iii', $chapter, $userId, $novelId);
        
        if ($stmt->execute()) {
            respond(['success' => true]);
        } else {
            respondError('Failed to update progress', 500);
        }
        break;

    // ═══════════════════════════════════════════════════════════════════════
    // DEFAULT
    // ═══════════════════════════════════════════════════════════════════════

    default:
        respond([
            'message' => 'Yomi API',
            'available_actions' => [
                'register', 'login',
                'get_novels', 'get_novel', 'get_chapters',
                'get_library', 'add_to_library', 'remove_from_library', 'update_progress',
            ],
        ]);
        break;
}

$conn->close();
