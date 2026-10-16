<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="Ban_Linh_Kien_xe_may_1.Admin" %>
<%
    // Chặn ngay trước khi render bất kỳ HTML nào của trang quản trị.
    // Admin.aspx.cs đã đặt sẵn StatusCode = 403 trước khi chạy tới đây.
    if (!CanAccessAdmin)
    {
        Response.Write(Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.HtmlKhongCoQuyen("trang Quản trị"));
        Response.End();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản Trị Hệ Thống | VanDonMotor</title>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        /* RESET & BỐ CỤC CHUNG */
        body { 
            background: #121212; color: #fff; margin: 0; 
            font-family: Arial, sans-serif; display: flex; height: 100vh; overflow: hidden; 
        }
        
        /* SIDEBAR BÊN TRÁI */
        .sidebar { 
            width: 250px; background: #1e1e1e; padding: 20px; 
            border-right: 1px solid #333; display: flex; flex-direction: column; 
        }
        .sidebar h2 { 
            color: #ee4d2d; margin-top: 0; font-size: 22px; 
            text-align: center; padding-bottom: 20px; border-bottom: 1px solid #333; 
        }
        .sidebar a { 
            color: #ddd; text-decoration: none; padding: 12px 15px; 
            margin-bottom: 10px; border-radius: 6px; transition: 0.3s; display: block; cursor: pointer;
        }
        .sidebar a:hover, .sidebar a.active { background: #ee4d2d; color: #fff; }
        
        /* KHU VỰC NỘI DUNG CHÍNH */
        .main-content { flex-grow: 1; padding: 30px; overflow-y: auto; }
        
        /* HEADER & NÚT THÊM */
        .admin-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .admin-header h2 { margin: 0; color: #fff; }
        .btn-add { background: #26aa99; color: #fff; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: bold; }
        .btn-add:hover { background: #1f8d7d; }

        /* BỘ LỌC & PHÂN TRANG */
        .admin-filter { padding: 9px 12px; background: #242424; border: 1px solid #444; color: #fff; border-radius: 6px; outline: none; cursor: pointer; font-size: 14px; }
        .admin-filter:hover, .admin-filter:focus { border-color: #ee4d2d; }
        .admin-filter option { background: #1e1e1e; color: #fff; }
        .pagination-bar { display: flex; justify-content: center; align-items: center; gap: 7px; margin-top: 18px; flex-wrap: wrap; }
        .pagination-bar button { background: #2a2a2a; color: #ddd; border: 1px solid #444; padding: 7px 13px; border-radius: 6px; cursor: pointer; font-weight: bold; transition: 0.2s; }
        .pagination-bar button:hover:not(:disabled) { background: #ee4d2d; border-color: #ee4d2d; color: #fff; }
        .pagination-bar button.active { background: #ee4d2d; border-color: #ee4d2d; color: #fff; }
        .pagination-bar button:disabled { opacity: 0.4; cursor: not-allowed; }
        .pagination-bar .page-info { color: #888; font-size: 13px; margin-left: 8px; }

        /* ===== KHU VỰC QUẢN LÝ KHÁCH HÀNG ===== */
        .cust-page-sub { margin: 5px 0 0; color: #888; font-size: 13px; }
        .cust-toolbar { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }
        .cust-search { position: relative; }
        .cust-search input { padding: 10px 15px 10px 40px; width: 270px; background: #242424; border: 1px solid #444; color: #fff; border-radius: 8px; outline: none; transition: 0.2s; }
        .cust-search input:focus { border-color: #ee4d2d; box-shadow: 0 0 0 3px rgba(238,77,45,0.15); }
        .cust-search .cust-search-ico { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); font-size: 14px; opacity: 0.55; pointer-events: none; }

        .cust-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin-bottom: 22px; }
        .cust-stat { display: flex; align-items: center; gap: 14px; background: linear-gradient(160deg, #26262b, #1e1e1e); border: 1px solid #333; border-radius: 12px; padding: 16px 18px; transition: 0.25s; }
        .cust-stat:hover { transform: translateY(-3px); border-color: #3f3f45; }
        .cust-stat-ico { width: 46px; height: 46px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .cust-stat-ico svg { width: 22px; height: 22px; }
        .cust-stat-ico.total { background: rgba(33,158,188,0.15); color: #219ebc; }
        .cust-stat-ico.active { background: rgba(38,170,153,0.15); color: #26aa99; }
        .cust-stat-ico.locked { background: rgba(239,35,60,0.15); color: #ef233c; }
        .cust-stat-ico.money { background: rgba(255,183,3,0.15); color: #ffb703; }
        .cust-stat-lbl { color: #999; font-size: 12px; text-transform: uppercase; letter-spacing: 0.6px; margin-bottom: 5px; }
        .cust-stat-val { color: #fff; font-size: 22px; font-weight: 800; line-height: 1; }

        .table-card { background: #1e1e1e; border: 1px solid #333; border-radius: 12px; overflow: hidden; }
        .table-card table { background: transparent; border-radius: 0; }
        .table-card th { background: #242428; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; }
        .table-card td { padding: 14px 15px; }
        .cust-row { transition: background 0.15s; }
        .cust-row:hover { background: #232326; }
        .cust-id { color: #777; font-weight: bold; }
        .cust-user { display: flex; align-items: center; gap: 11px; }
        .cust-avatar { width: 42px; height: 42px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px; color: #fff; flex-shrink: 0; box-shadow: 0 2px 6px rgba(0,0,0,0.35); }
        .cust-name { font-weight: bold; color: #fff; line-height: 1.3; }
        .cust-sub { font-size: 12px; color: #888; margin-top: 2px; }
        .cust-contact { display: flex; flex-direction: column; gap: 5px; }
        .cust-contact span { display: flex; align-items: center; gap: 7px; color: #bbb; font-size: 13px; }
        .cust-contact svg { width: 13px; height: 13px; opacity: 0.6; flex-shrink: 0; }
        .cust-money { color: #ffb703; font-weight: bold; text-align: center; }
        .cust-count { text-align: center; font-weight: bold; color: #219ebc; }

        .act-group { display: inline-flex; gap: 8px; justify-content: center; flex-wrap: wrap; }
        .btn-act { display: inline-flex; align-items: center; gap: 6px; padding: 7px 12px; border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-weight: 600; font-size: 13px; line-height: 1; transition: 0.18s; }
        .btn-act svg { width: 15px; height: 15px; flex-shrink: 0; }
        .btn-act:hover { transform: translateY(-1px); }
        .btn-act-view { background: rgba(59,130,246,0.12); color: #6ea8fe; border-color: rgba(59,130,246,0.35); }
        .btn-act-view:hover { background: #3b82f6; color: #fff; }
        .btn-act-order { background: rgba(142,68,173,0.14); color: #c084fc; border-color: rgba(142,68,173,0.4); }
        .btn-act-order:hover { background: #8e44ad; color: #fff; }
        .btn-act-lock { background: rgba(239,35,60,0.12); color: #ff6b7d; border-color: rgba(239,35,60,0.35); }
        .btn-act-lock:hover { background: #ef233c; color: #fff; }
        .btn-act-unlock { background: rgba(38,170,153,0.12); color: #4ad9c2; border-color: rgba(38,170,153,0.35); }
        .btn-act-unlock:hover { background: #26aa99; color: #fff; }

        @media (max-width: 1100px) { .cust-stats { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 640px) { .cust-stats { grid-template-columns: 1fr; } .cust-search input { width: 100%; } }
        
        /* BẢNG DỮ LIỆU */
        table { width: 100%; border-collapse: collapse; background: #1e1e1e; border-radius: 8px; overflow: hidden; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #333; }
        th { background: #2a2a2a; color: #ee4d2d; }
        td { color: #ccc; vertical-align: middle; }
        
        .prod-img { width: 60px; height: 60px; object-fit: cover; border-radius: 4px; background: #fff; padding: 2px;}
        
        /* NÚT THAO TÁC */
        .btn-action { color: #fff; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-weight: bold; margin-right: 5px; }
        .btn-edit { background: #ffb703; color: #000; }
        .btn-delete { background: #ef233c; }
        .btn-view { background: #3b82f6; }
        .btn-history { background: #8e44ad; color: #fff; }
        .btn-lock { background: #ef233c; color: #fff; }
        .btn-unlock { background: #26aa99; color: #fff; }
        
        /* CSS TRẠNG THÁI ĐƠN HÀNG & KHÁCH HÀNG */
        .status-badge { padding: 6px 10px; border-radius: 4px; font-size: 12px; font-weight: bold; display: inline-block; text-align: center; min-width: 80px;}
        .status-pending { background: #ffb703; color: #000; }
        .status-shipping { background: #219ebc; color: #fff; }
        .status-success { background: #26aa99; color: #fff; }
        .status-cancel { background: #ef233c; color: #fff; }
        .status-return { background: #8e44ad; color: #fff; }
        .status-active { background: #26aa99; color: #fff; }
        .status-locked { background: #ef233c; color: #fff; }
        
        /* CSS KHU VỰC THỐNG KÊ */
        .dashboard-cards { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; margin-bottom: 25px; }
        .stat-card { background: #2a2a2d; padding: 20px 15px; border-radius: 8px; text-align: center; border-bottom: 4px solid #4a4a4d; box-shadow: 0 4px 6px rgba(0,0,0,0.2); transition: 0.3s; }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-card h3 { color: #aaa; font-size: 13px; margin: 0 0 10px 0; text-transform: uppercase; letter-spacing: 1px; }
        .stat-card .num { color: #fff; font-size: 26px; font-weight: bold; margin: 0; }
        .stat-card.total { border-color: #219ebc; }
        .stat-card.success { border-color: #26aa99; }
        .stat-card.success .num { color: #26aa99; }
        .stat-card.cancel { border-color: #ef233c; }
        .stat-card.cancel .num { color: #ef233c; }
        .stat-card.return { border-color: #8e44ad; }
        .stat-card.return .num { color: #8e44ad; }
        .stat-card.revenue { border-color: #ffb703; background: #332b18; }
        .stat-card.revenue .num { color: #ffb703; }
        
        /* CSS ẨN/HIỆN TAB */
        .view-section { display: none; }
        .view-section.active { display: block; }

        /* BIỂU ĐỒ DOANH THU */
        .chart-area { display: flex; align-items: flex-end; gap: 6px; height: 220px; padding: 15px 10px 30px 10px; background: #1e1e1e; border-radius: 8px; border: 1px solid #333; position: relative; }
        .chart-col { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; height: 100%; position: relative; }
        .chart-col .bar { width: 65%; background: linear-gradient(#ee4d2d, #ffb703); border-radius: 4px 4px 0 0; min-height: 2px; transition: 0.3s; }
        .chart-col .bar:hover { filter: brightness(1.2); }
        .chart-col .lbl { position: absolute; bottom: -22px; font-size: 10px; color: #888; white-space: nowrap; }
        .chart-col .val { font-size: 10px; color: #ffb703; margin-bottom: 3px; }
        .thumb-sm { width: 46px; height: 46px; object-fit: cover; border-radius: 4px; border: 1px solid #444; margin: 2px; cursor: pointer; }
        .mini-tbl { width: 100%; border-collapse: collapse; }
        .mini-tbl td, .mini-tbl th { padding: 8px 10px; font-size: 13px; }
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px; }
        .panel { background: #1e1e1e; border: 1px solid #333; border-radius: 8px; padding: 15px; }
        .panel h3 { margin: 0 0 12px 0; color: #ee4d2d; font-size: 15px; }
        .swal-wide-html select, .swal-wide-html input[type=text], .swal-wide-html input[type=number], .swal-wide-html textarea {
            width: 100%; box-sizing: border-box; padding: 8px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px; font-family: inherit;
        }
        .swal-wide-html textarea { resize: vertical; min-height: 60px; }
        .swal-wide-html label { color: #555; font-weight: bold; display: block; margin-bottom: 5px; }
        .swal-wide-html .row { display: flex; gap: 12px; margin-bottom: 12px; }
        .swal-wide-html .row > div { flex: 1; }
        .xe-box { max-height: 130px; overflow-y: auto; border: 1px solid #ddd; border-radius: 6px; padding: 8px; background: #f8f9fa; }
        .xe-box label { font-weight: normal; display: flex; align-items: center; gap: 6px; margin-bottom: 4px; color: #333; }
        .gallery-current { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 8px; }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <div class="sidebar">
        <h2>VanDonMotor<br><span style="color:#fff; font-size:16px;"><%= Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.TenVaiTro(VaiTroHienTai) %></span></h2>
        <% if (CoTab("sanpham")) { %>
        <a id="nav-sanpham" class="<%= TabMacDinh == "sanpham" ? "active" : "" %>" onclick="switchTab('sanpham')">📦 Quản lý Sản Phẩm</a>
        <% } %>
        <% if (CoTab("danhmuc")) { %>
        <a id="nav-danhmuc" class="<%= TabMacDinh == "danhmuc" ? "active" : "" %>" onclick="switchTab('danhmuc')">📂 Quản lý Danh Mục</a>
        <% } %>
        <% if (CoTab("dongxe")) { %>
        <a id="nav-dongxe" class="<%= TabMacDinh == "dongxe" ? "active" : "" %>" onclick="switchTab('dongxe')">🏍️ Quản lý Dòng Xe</a>
        <% } %>
        <% if (CoTab("khachhang")) { %>
        <a id="nav-khachhang" class="<%= TabMacDinh == "khachhang" ? "active" : "" %>" onclick="switchTab('khachhang')">👥 Quản lý Khách Hàng</a>
        <% } %>
        <% if (CoTab("nguoidung")) { %>
        <a id="nav-nguoidung" class="<%= TabMacDinh == "nguoidung" ? "active" : "" %>" onclick="switchTab('nguoidung')">🛡️ Quản Lý Người Dùng</a>
        <% } %>
        <% if (CoTab("donhang")) { %>
        <a id="nav-donhang" class="<%= TabMacDinh == "donhang" ? "active" : "" %>" onclick="switchTab('donhang')"><span>🛒 Quản lý Đơn Hàng</span><span class="nav-badge" id="navOrderBadge">0</span></a>
        <% } %>
        <% if (CoTab("khuyenmai")) { %>
        <a id="nav-khuyenmai" class="<%= TabMacDinh == "khuyenmai" ? "active" : "" %>" onclick="switchTab('khuyenmai')">🏷️ Khuyến Mãi</a>
        <% } %>
        <% if (CoTab("kho")) { %>
        <a id="nav-kho" class="<%= TabMacDinh == "kho" ? "active" : "" %>" onclick="switchTab('kho')">📥 Quản lý Kho</a>
        <% } %>
        <% if (CoTab("danhgia")) { %>
        <a id="nav-danhgia" class="<%= TabMacDinh == "danhgia" ? "active" : "" %>" onclick="switchTab('danhgia')">⭐ Quản lý Đánh Giá</a>
        <% } %>
        <% if (CoTab("thongke")) { %>
        <a id="nav-thongke" class="<%= TabMacDinh == "thongke" ? "active" : "" %>" onclick="switchTab('thongke')">📊 Thống Kê</a>
        <% } %>
        <% if (CoTab("nhatky")) { %>
        <a id="nav-nhatky" class="<%= TabMacDinh == "nhatky" ? "active" : "" %>" onclick="switchTab('nhatky')">📜 Nhật Ký Hệ Thống</a>
        <% } %>
        <% if (CoTab("chat")) { %>
        <a id="nav-chat" class="<%= TabMacDinh == "chat" ? "active" : "" %>" onclick="switchTab('chat')"><span>💬 Trò Chuyện Khách Hàng</span><span class="nav-badge" id="navChatBadge">0</span></a>
        <% } %>
        
        <a href="index.aspx" style="margin-top: auto; background: #333; text-align: center;">⬅ Về trang cửa hàng</a>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        
        <!-- ================= KHU VỰC QUẢN LÝ SẢN PHẨM ================= -->
        <div id="view-sanpham" class="view-section<%= TabMacDinh == "sanpham" ? " active" : "" %>">
            <div class="admin-header">
                <h2>Danh sách Sản Phẩm</h2>
                <button class="btn-add" onclick="themMoi()">+ Thêm Sản Phẩm Mới</button>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>ID</th><th>Hình Ảnh</th><th>Tên Phụ Tùng</th><th>Danh Mục</th><th>Giá Bán</th><th>Tồn Kho</th><th>Hành Động</th>
                    </tr>
                </thead>
                <tbody id="adminProductTable">
                    <tr><td colspan="7" style="text-align: center; padding: 30px;">Đang tải dữ liệu từ CSDL...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC QUẢN LÝ DANH MỤC ================= -->
        <div id="view-danhmuc" class="view-section">
            <div class="admin-header">
                <h2>Danh Sách Danh Mục Phụ Tùng</h2>
                <button class="btn-add" onclick="themMoiDanhMuc()">+ Thêm Danh Mục Mới</button>
            </div>
            <table>
                <thead>
                    <tr>
                        <th style="width: 120px;">Mã DM</th>
                        <th>Tên Danh Mục</th>
                        <th style="width: 200px;">Số Lượng Linh Kiện</th>
                        <th style="width: 180px;">Hành Động</th>
                    </tr>
                </thead>
                <tbody id="categoryTableBody">
                    <tr><td colspan="4" style="text-align: center; padding: 30px;">Đang tải danh mục...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC QUẢN LÝ KHÁCH HÀNG ================= -->
        <div id="view-khachhang" class="view-section">
            <div class="admin-header" style="flex-wrap: wrap; gap: 12px; margin-bottom: 18px;">
                <div>
                    <h2 style="margin: 0;">Danh Sách Khách Hàng &amp; Thành Viên</h2>
                    <p class="cust-page-sub">Quản lý thông tin, lịch sử mua hàng và trạng thái tài khoản khách hàng.</p>
                </div>
                <div class="cust-toolbar">
                    <div class="cust-search">
                        <span class="cust-search-ico">🔍</span>
                        <input type="text" id="custSearchInput" placeholder="Tìm theo tên, SĐT, Email, Username..."
                               oninput="filterCustomers()">
                    </div>
                    <select id="custRoleFilter" class="admin-filter" onchange="filterCustomers()">
                        <option value="">Tất cả vai trò</option>
                        <option value="User">Khách hàng</option>
                        <option value="Admin">Quản trị viên</option>
                        <option value="NhanVienBanHang">NV bán hàng</option>
                        <option value="NhanVienKho">NV kho</option>
                        <option value="NhanVienHoTro">NV hỗ trợ</option>
                    </select>
                    <select id="custStatusFilter" class="admin-filter" onchange="filterCustomers()">
                        <option value="">Tất cả trạng thái</option>
                        <option value="1">Hoạt động</option>
                        <option value="0">Đang bị khóa</option>
                    </select>
                    <select id="custSort" class="admin-filter" onchange="filterCustomers()">
                        <option value="newest">Sắp xếp: Mới nhất</option>
                        <option value="spent_desc">Chi tiêu cao nhất</option>
                        <option value="orders_desc">Nhiều đơn nhất</option>
                        <option value="name_asc">Tên A → Z</option>
                    </select>
                </div>
            </div>

            <!-- THỐNG KÊ NHANH -->
            <div class="cust-stats" id="custStats">
                <div class="cust-stat">
                    <div class="cust-stat-ico total">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </div>
                    <div>
                        <div class="cust-stat-lbl">Tổng khách hàng</div>
                        <div class="cust-stat-val" id="csTotal">0</div>
                    </div>
                </div>
                <div class="cust-stat">
                    <div class="cust-stat-ico active">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                    <div>
                        <div class="cust-stat-lbl">Đang hoạt động</div>
                        <div class="cust-stat-val" id="csActive">0</div>
                    </div>
                </div>
                <div class="cust-stat">
                    <div class="cust-stat-ico locked">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    </div>
                    <div>
                        <div class="cust-stat-lbl">Đang bị khóa</div>
                        <div class="cust-stat-val" id="csLocked">0</div>
                    </div>
                </div>
                <div class="cust-stat">
                    <div class="cust-stat-ico money">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                    </div>
                    <div>
                        <div class="cust-stat-lbl">Tổng chi tiêu</div>
                        <div class="cust-stat-val" id="csMoney">0 ₫</div>
                    </div>
                </div>
            </div>

            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th style="width: 70px;">Mã KH</th>
                            <th>Khách hàng</th>
                            <th>Liên hệ</th>
                            <th style="text-align: center; width: 100px;">Số đơn</th>
                            <th style="text-align: center;">Tổng chi tiêu</th>
                            <th style="text-align: center; width: 130px;">Trạng thái</th>
                            <th style="width: 260px; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody id="userTableBody">
                        <tr><td colspan="7" style="text-align: center; padding: 30px;">Đang tải danh sách khách hàng...</td></tr>
                    </tbody>
                </table>
            </div>
            <div id="custPagination" class="pagination-bar"></div>
        </div>

        <!-- ================= KHU VỰC QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN ================= -->
        <div id="view-nguoidung" class="view-section">
            <div class="admin-header" style="flex-wrap: wrap; gap: 15px;">
                <h2>Quản Lý Người Dùng &amp; Phân Quyền</h2>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <input type="text" id="userSearchInput" placeholder="Tìm theo tên, username, email, SĐT..."
                           oninput="filterNguoiDung()"
                           style="padding: 9px 15px; width: 300px; background: #242424; border: 1px solid #444; color: #fff; border-radius: 6px; outline: none;">
                    <button class="btn-add" onclick="themNhanSu()">+ Thêm Nhân Sự</button>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th style="width: 70px;">Mã</th>
                        <th>Tên Đăng Nhập</th>
                        <th>Họ và Tên</th>
                        <th>Email / SĐT</th>
                        <th style="text-align:center;">Vai Trò</th>
                        <th style="text-align:center;">Trạng Thái</th>
                        <th style="width: 320px; text-align: center;">Hành Động</th>
                    </tr>
                </thead>
                <tbody id="nguoiDungTableBody">
                    <tr><td colspan="7" style="text-align: center; padding: 30px;">Đang tải danh sách người dùng...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC QUẢN LÝ ĐƠN HÀNG  ================= -->
        <div id="view-donhang" class="view-section">
            <div class="admin-header">
                <h2>Quản Lý Đơn Hàng</h2>
            </div>

            <!-- BẢNG THỐNG KÊ DOANH THU -->
            <div class="dashboard-cards" id="orderStats">
                <div class="stat-card total">
                    <h3>Tổng Đơn Đặt</h3>
                    <p class="num" id="stat-tong">0</p>
                </div>
                <div class="stat-card success">
                    <h3>Đã Giao</h3>
                    <p class="num" id="stat-giao">0</p>
                </div>
                <div class="stat-card cancel">
                    <h3>Đã Hủy</h3>
                    <p class="num" id="stat-huy">0</p>
                </div>
                <div class="stat-card return">
                    <h3>Hoàn Trả</h3>
                    <p class="num" id="stat-tra">0</p>
                </div>
                <div class="stat-card revenue">
                    <h3>Tổng Doanh Thu</h3>
                    <p class="num" id="stat-tien">0 ₫</p>
                </div>
            </div>

            <!-- THANH TÌM KIẾM VÀ BỘ LỌC ĐA NĂNG -->
            <div style="background: #1e1e1e; padding: 15px; border-radius: 8px; margin-bottom: 20px; display: flex; flex-wrap: wrap; gap: 12px; align-items: center; border: 1px solid #333;">
                <input type="text" id="orderSearchInput" placeholder="Tìm theo Mã đơn, Tên khách, SĐT, Mã vận đơn..." 
                       oninput="filterOrders()"
                       style="flex: 2; min-width: 250px; padding: 10px 15px; background: #242424; border: 1px solid #444; color: #fff; border-radius: 4px; outline: none;">
                
                <select id="filterStatus" onchange="filterOrders()" style="flex: 1; min-width: 150px; padding: 10px; background: #242424; border: 1px solid #444; color: #fff; border-radius: 4px; outline: none;">
                    <option value="">-- Tất cả trạng thái đơn --</option>
                    <option value="Chờ xác nhận">Chờ xác nhận</option>
                    <option value="Đã xác nhận">Đã xác nhận</option>
                    <option value="Đang chuẩn bị hàng">Đang chuẩn bị hàng</option>
                    <option value="Đang giao">Đang giao</option>
                    <option value="Đã giao">Đã giao</option>
                    <option value="Đã hủy">Đã hủy</option>
                    <option value="Hoàn trả">Hoàn trả / Trả hàng</option>
                </select>

                <select id="filterPayment" onchange="filterOrders()" style="flex: 1; min-width: 150px; padding: 10px; background: #242424; border: 1px solid #444; color: #fff; border-radius: 4px; outline: none;">
                    <option value="">-- Trạng thái thanh toán --</option>
                    <option value="Chưa thanh toán">Chưa thanh toán</option>
                    <option value="Đã thanh toán">Đã thanh toán</option>
                    <option value="Đã hoàn tiền">Đã hoàn tiền</option>
                </select>

                <button class="btn-action" onclick="resetOrderFilter()" style="background: #444; padding: 10px 18px; border-radius: 4px;">Đặt lại</button>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Mã Đơn</th>
                        <th>Khách Hàng (SĐT)</th>
                        <th>Địa Chỉ Giao Hàng</th>
                        <th>Ngày Đặt</th>
                        <th>Tổng Tiền</th>
                        <th>Thanh Toán</th>
                        <th>Trạng Thái Đơn</th>
                        <th style="width: 130px; text-align: center;">Hành Động</th>
                    </tr>
                </thead>
                <tbody id="orderTableBody">
                    <tr><td colspan="8" style="text-align: center; padding: 30px;">Đang tải dữ liệu...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC QUẢN LÝ DÒNG XE ================= -->
        <div id="view-dongxe" class="view-section">
            <div class="admin-header">
                <h2>Quản Lý Dòng Xe</h2>
                <button class="btn-add" onclick="themDongXe()">+ Thêm Dòng Xe</button>
            </div>
            <table>
                <thead>
                    <tr>
                        <th style="width: 80px;">Mã</th>
                        <th>Hãng Xe</th>
                        <th>Tên Dòng Xe</th>
                        <th>Đời Xe</th>
                        <th style="text-align:center;">Số Linh Kiện Tương Thích</th>
                        <th style="width: 180px; text-align:center;">Hành Động</th>
                    </tr>
                </thead>
                <tbody id="dongXeTableBody">
                    <tr><td colspan="6" style="text-align:center; padding:30px;">Đang tải...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC KHUYẾN MÃI ================= -->
        <div id="view-khuyenmai" class="view-section">
            <div class="admin-header">
                <h2>Quản Lý Mã Giảm Giá</h2>
                <button class="btn-add" onclick="themMaGiamGia()">+ Thêm Mã Giảm Giá</button>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Mã</th>
                        <th>Loại</th>
                        <th>Giá Trị</th>
                        <th>Đơn Tối Thiểu</th>
                        <th>Số Lượng</th>
                        <th>Hiệu Lực</th>
                        <th style="text-align:center;">Trạng Thái</th>
                        <th style="width: 180px; text-align:center;">Hành Động</th>
                    </tr>
                </thead>
                <tbody id="khuyenMaiTableBody">
                    <tr><td colspan="8" style="text-align:center; padding:30px;">Đang tải...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC QUẢN LÝ KHO ================= -->
        <div id="view-kho" class="view-section">
            <div class="admin-header" style="flex-wrap: wrap; gap: 12px;">
                <h2>Quản Lý Nhập / Xuất Kho</h2>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <select id="khoFilterLoai" onchange="loadPhieuKho()" style="padding: 9px 12px; background:#242424; border:1px solid #444; color:#fff; border-radius:6px;">
                        <option value="">-- Tất cả phiếu --</option>
                        <option value="Nhap">Nhập kho</option>
                        <option value="Xuat">Xuất kho</option>
                    </select>
                    <button class="btn-add" onclick="taoPhieuKho()">+ Tạo Phiếu Kho</button>
                </div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th style="width:80px;">Mã</th>
                        <th>Sản Phẩm</th>
                        <th>Loại</th>
                        <th>Số Lượng</th>
                        <th>Tồn Trước → Sau</th>
                        <th>Lý Do</th>
                        <th>Người Tạo</th>
                        <th>Thời Gian</th>
                    </tr>
                </thead>
                <tbody id="khoTableBody">
                    <tr><td colspan="8" style="text-align:center; padding:30px;">Đang tải...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC QUẢN LÝ ĐÁNH GIÁ ================= -->
        <div id="view-danhgia" class="view-section">
            <div class="admin-header" style="flex-wrap: wrap; gap: 12px;">
                <h2>Quản Lý Đánh Giá Sản Phẩm</h2>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <select id="dgFilterSP" onchange="loadDanhGiaAdmin()" style="padding: 9px 12px; background:#242424; border:1px solid #444; color:#fff; border-radius:6px; min-width:200px;">
                        <option value="">-- Tất cả sản phẩm --</option>
                    </select>
                    <select id="dgFilterTrangThai" onchange="renderDanhGiaAdmin()" style="padding: 9px 12px; background:#242424; border:1px solid #444; color:#fff; border-radius:6px;">
                        <option value="">-- Tất cả trạng thái --</option>
                        <option value="hien">Đang hiển thị</option>
                        <option value="an">Đã ẩn</option>
                    </select>
                </div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th style="width:80px;">Mã</th>
                        <th>Sản Phẩm</th>
                        <th>Khách Hàng</th>
                        <th style="text-align:center;">Số Sao</th>
                        <th>Nội Dung</th>
                        <th>Ngày</th>
                        <th style="width: 190px; text-align:center;">Hành Động</th>
                    </tr>
                </thead>
                <tbody id="danhGiaTableBody">
                    <tr><td colspan="7" style="text-align:center; padding:30px;">Đang tải...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC THỐNG KÊ ================= -->
        <div id="view-thongke" class="view-section">
            <div class="admin-header" style="flex-wrap: wrap; gap: 12px;">
                <h2>Thống Kê & Phân Tích</h2>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <label style="color:#aaa; font-size:13px;">Từ:</label>
                    <input type="date" id="tkFrom" style="padding: 8px; background:#242424; border:1px solid #444; color:#fff; border-radius:6px;">
                    <label style="color:#aaa; font-size:13px;">Đến:</label>
                    <input type="date" id="tkTo" style="padding: 8px; background:#242424; border:1px solid #444; color:#fff; border-radius:6px;">
                    <button class="btn-add" onclick="loadThongKeChiTiet()">Xem</button>
                </div>
            </div>
            <div class="dashboard-cards">
                <div class="stat-card total"><h3>Tổng Đơn</h3><p class="num" id="tk-tong">0</p></div>
                <div class="stat-card success"><h3>Đã Giao</h3><p class="num" id="tk-giao">0</p></div>
                <div class="stat-card cancel"><h3>Đã Hủy</h3><p class="num" id="tk-huy">0</p></div>
                <div class="stat-card return"><h3>Hoàn Trả</h3><p class="num" id="tk-tra">0</p></div>
                <div class="stat-card revenue"><h3>Doanh Thu</h3><p class="num" id="tk-tien">0 ₫</p></div>
            </div>

            <div class="panel">
                <h3 id="tk-chart-title">Doanh thu theo ngày</h3>
                <div class="chart-area" id="tkChart"></div>
            </div>

            <div class="grid-2">
                <div class="panel">
                    <h3>🔥 Top sản phẩm bán chạy</h3>
                    <table class="mini-tbl"><thead><tr><th>Sản phẩm</th><th style="text-align:center;">SL</th><th style="text-align:right;">Doanh thu</th></tr></thead><tbody id="tkTopSP"></tbody></table>
                </div>
                <div class="panel">
                    <h3>👑 Top khách hàng chi tiêu</h3>
                    <table class="mini-tbl"><thead><tr><th>Khách hàng</th><th style="text-align:center;">Số đơn</th><th style="text-align:right;">Chi tiêu</th></tr></thead><tbody id="tkTopKH"></tbody></table>
                </div>
            </div>
        </div>

        <!-- ================= KHU VỰC NHẬT KÝ HỆ THỐNG ================= -->
        <div id="view-nhatky" class="view-section">
            <div class="admin-header" style="flex-wrap: wrap; gap: 12px;">
                <h2>Nhật Ký Hoạt Động Hệ Thống</h2>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <input type="text" id="nkSearch" placeholder="Tìm theo hành động, đối tượng, người dùng..." oninput="loadNhatKy()"
                           style="padding:9px 12px; width:320px; background:#242424; border:1px solid #444; color:#fff; border-radius:6px; outline:none;">
                    <button class="btn-action" onclick="loadNhatKy()" style="background:#444; padding:9px 16px;">Tải lại</button>
                </div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th style="width:80px;">Mã</th>
                        <th style="width:160px;">Thời Gian</th>
                        <th>Người Thực Hiện</th>
                        <th>Hành Động</th>
                        <th>Đối Tượng</th>
                        <th>Chi Tiết</th>
                    </tr>
                </thead>
                <tbody id="nhatKyTableBody">
                    <tr><td colspan="6" style="text-align:center; padding:30px;">Đang tải...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- ================= KHU VỰC QUẢN LÝ CHAT DÀNH CHO ADMIN ================= -->
        <div id="view-chat" class="view-section<%= TabMacDinh == "chat" ? " active" : "" %>">
            <div class="admin-header">
                <h2>💬 Quản Lý Chat Hỗ Trợ Khách Hàng</h2>
                <div style="font-size: 14px; color: #888;">Tin nhắn được cập nhật tự động mỗi 4 giây</div>
            </div>
            <div class="chat-toolbar">
                <span class="chat-unread-note" id="adminUnreadNote"></span>
            </div>
            <style>
                .admin-chat-container { display: flex; height: 600px; background: #1e1e1e; border: 1px solid #333; border-radius: 8px; overflow: hidden; }
                .chat-session-list { width: 280px; border-right: 1px solid #333; background: #252525; overflow-y: auto; flex-shrink: 0; }
                .session-item { padding: 14px 16px; border-bottom: 1px solid #333; cursor: pointer; transition: 0.2s; }
                .session-item:hover { background: #333; }
                .session-item.active { background: #3a2a2a; border-left: 3px solid #ee4d2d; }
                .session-name { font-weight: bold; color: #fff; margin-bottom: 5px; display: flex; align-items: center; gap: 6px; }
                .session-preview { font-size: 12px; color: #aaa; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 4px; }
                .session-time { font-size: 11px; color: #777; }
                .chat-main-area { flex: 1; display: flex; flex-direction: column; background: #121212; }
                .chat-main-header { padding: 12px 20px; background: #2a2a2a; border-bottom: 1px solid #333; color: #fff; font-weight: bold; display: flex; align-items: center; gap: 8px; }
                .admin-messages-box { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; }
                .admin-chat-footer { padding: 15px; background: #1e1e1e; border-top: 1px solid #333; display: flex; gap: 10px; }
                .admin-chat-footer input { flex: 1; background: #2a2a2a; border: 1px solid #444; color: #fff; padding: 10px 14px; border-radius: 6px; outline: none; font-size: 14px; font-family: inherit; }
                .admin-chat-footer input:focus { border-color: #ee4d2d; }
                .admin-chat-footer button { background: #ee4d2d; color: #fff; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: bold; font-family: inherit; }
                .admin-chat-footer button:hover { background: #d73a1c; }
                .admin-chat-footer button:disabled { background: #555; cursor: not-allowed; }
                .empty-chat-state { text-align: center; color: #555; margin-top: 80px; font-size: 15px; }
                .session-item.unread { background: #33262a; }
                .session-item.unread .session-name { color: #fff; }
                .session-item.unread .session-preview { color: #ddd; font-weight: 600; }
                .badge-chua-doc { margin-left: auto; background: #ee4d2d; color: #fff; font-size: 11px;
                                 font-weight: 700; min-width: 20px; height: 20px; border-radius: 10px;
                                 display: inline-flex; align-items: center; justify-content: center;
                                 padding: 0 6px; flex-shrink: 0; }
                .nav-badge { background: #ee4d2d; color: #fff; font-size: 11px; font-weight: 700;
                              min-width: 19px; height: 19px; border-radius: 10px; display: none;
                              align-items: center; justify-content: center; padding: 0 6px;
                              margin-left: auto; flex-shrink: 0; }
                .nav-badge.show { display: inline-flex; }
                .chat-toolbar { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; }
                .chat-unread-note { font-size: 13px; color: #ee4d2d; font-weight: 600; }
            </style>
            
            <div class="admin-chat-container">
                <!-- Danh sách phiên chat bên trái -->
                <div class="chat-session-list" id="adminSessionList">
                    <div style="padding: 30px; text-align: center; color: #888;">Đang tải danh sách...</div>
                </div>

                <!-- Khung nội dung hội thoại bên phải -->
                <div class="chat-main-area">
                    <div class="chat-main-header" id="adminChatHeader">
                        <span>💬</span>
                        <span id="adminChatTitle">Hãy chọn một cuộc trò chuyện</span>
                    </div>
                    <div class="admin-messages-box" id="adminMessagesBox">
                        <div class="empty-chat-state">Vui lòng chọn khách hàng để xem và trả lời tin nhắn</div>
                    </div>
                    <div class="admin-chat-footer">
                        <input type="text" id="adminChatInput" placeholder="Nhập tin nhắn phản hồi..." onkeypress="if(event.key==='Enter') sendAdminMessage()" disabled />
                        <button id="adminSendBtn" onclick="sendAdminMessage()" disabled>Gửi</button>
                    </div>
                </div>
            </div>
        </div>

    <!-- JAVASCRIPT XỬ LÝ DỮ LIỆU -->
    <script>
        // Cờ phân quyền do server truyền xuống. Chỉ có tác dụng hiển thị;
        // quyền thật đã được chặn ở Admin.aspx.cs và trong từng API.
        const IS_QUAN_TRI_VIEN = <%= IsQuanTriVien ? "true" : "false" %>;
        const THONG_BAO_KHONG_CO_QUYEN = '<%= Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.ThongBaoKhongCoQuyen %>';

        // Danh sách tab vai trò hiện tại được phép (tính ở server theo PhanQuyen.CoQuyen).
        const TAB_CHO_PHEP = [<%= TabChoPhepJs %>];

        const TAT_CA_TAB = ['sanpham', 'danhmuc', 'dongxe', 'khachhang', 'nguoidung', 'donhang', 'khuyenmai', 'kho', 'danhgia', 'thongke', 'nhatky', 'chat'];

        let dsSanPhamAdmin = [];
        let dsDanhMucAdmin = [];
        let dsKhachHangAdmin = [];
        let custPage = 1;
        const CUST_PAGE_SIZE = 10;

        function baoKhongCoQuyen() {
            if (window.Swal) {
                Swal.fire({ icon: 'error', title: THONG_BAO_KHONG_CO_QUYEN,
                    text: 'Tài khoản nhân viên chỉ được sử dụng phần trò chuyện với khách hàng.' });
            } else {
                alert(THONG_BAO_KHONG_CO_QUYEN);
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            if (TAB_CHO_PHEP.indexOf('donhang') >= 0) {
                khoiDongThongBaoDonHang();
            }
            switchTab(TAB_CHO_PHEP.length ? TAB_CHO_PHEP[0] : 'chat');
        });

        // 1. LOGIC CHUYỂN TAB TỔNG HỢP
        function switchTab(tabName) {
            if (TAB_CHO_PHEP.indexOf(tabName) === -1) {
                baoKhongCoQuyen();
                return;
            }

            TAT_CA_TAB.forEach(function (t) {
                const nav = document.getElementById('nav-' + t);
                if (nav) nav.classList.remove('active');
            });

            const navTab = document.getElementById('nav-' + tabName);
            if (navTab) navTab.classList.add('active');

            TAT_CA_TAB.forEach(function (t) {
                const view = document.getElementById('view-' + t);
                if (view) view.classList.remove('active');
            });

            const viewTab = document.getElementById('view-' + tabName);
            if (viewTab) viewTab.classList.add('active');

            if (tabName === 'donhang') {
                loadOrders();
            } else if (tabName === 'danhmuc') {
                loadCategories();
            } else if (tabName === 'dongxe') {
                loadDongXe();
            } else if (tabName === 'khachhang') {
                loadCustomers();
            } else if (tabName === 'nguoidung') {
                loadNguoiDung();
            } else if (tabName === 'sanpham') {
                loadAdminProducts();
            } else if (tabName === 'khuyenmai') {
                loadKhuyenMai();
            } else if (tabName === 'kho') {
                loadPhieuKho();
            } else if (tabName === 'danhgia') {
                loadDanhGiaAdmin();
            } else if (tabName === 'thongke') {
                loadThongKeChiTiet();
            } else if (tabName === 'nhatky') {
                loadNhatKy();
            } else if (tabName === 'chat') {
                loadAdminSessions();
            }
        }

        // ==========================================
        // 2. CODE QUẢN LÝ KHÁCH HÀNG (FULL)
        // ==========================================
        async function loadCustomers() {
            const tbody = document.getElementById('userTableBody');
            try {
                const res = await fetch('/api/QuanLyKhachHangApi.ashx?action=get');
                const json = await res.json();

                if (json.success) {
                    dsKhachHangAdmin = json.data;
                    renderCustomerStats();
                    applyCustomerFilters(true);
                } else {
                    tbody.innerHTML = `<tr><td colspan="7" style="color:#ef233c; text-align:center;">${json.message}</td></tr>`;
                }
            } catch (e) {
                tbody.innerHTML = '<tr><td colspan="7" style="color:#ef233c; text-align:center;">Lỗi kết nối API Khách hàng!</td></tr>';
            }
        }

        function renderCustomerStats() {
            const list = dsKhachHangAdmin || [];
            const set = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };
            set('csTotal', list.length);
            set('csActive', list.filter(u => u.status === 1).length);
            set('csLocked', list.filter(u => u.status === 0).length);
            set('csMoney', list.reduce((s, u) => s + (u.totalSpent || 0), 0).toLocaleString('vi-VN') + ' ₫');
        }

        function tenVaiTroText(role) {
            if (role === 'Admin') return 'Quản trị viên (Admin)';
            if (role === 'NhanVienBanHang') return 'Nhân viên bán hàng';
            if (role === 'NhanVienKho') return 'Nhân viên kho';
            if (role === 'NhanVienHoTro' || role === 'NhanVien') return 'Nhân viên hỗ trợ';
            return 'Khách hàng';
        }

        function vaiTroNgan(role) {
            if (role === 'Admin') return '<span style="color:#ee4d2d; font-weight:bold;">(Admin)</span>';
            if (role === 'NhanVienBanHang') return '<span style="color:#219ebc; font-weight:bold;">(NV bán hàng)</span>';
            if (role === 'NhanVienKho') return '<span style="color:#8e44ad; font-weight:bold;">(NV kho)</span>';
            if (role === 'NhanVienHoTro' || role === 'NhanVien') return '<span style="color:#26aa99; font-weight:bold;">(NV hỗ trợ)</span>';
            return '';
        }

        function avatarChuDau(name, id) {
            const ch = ((name || '?').trim().charAt(0) || '?').toUpperCase();
            const mau = ['#ee4d2d', '#219ebc', '#8e44ad', '#26aa99', '#ffb703', '#3b82f6', '#e83e8c'];
            const c = mau[(id || 0) % mau.length];
            return `<div class="cust-avatar" style="background:${c};">${ch}</div>`;
        }

        const CUST_ICONS = {
            view: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>',
            order: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>',
            lock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>',
            unlock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg>',
            mail: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>',
            phone: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.36 1.9.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.34 1.85.57 2.81.7A2 2 0 0 1 22 16.92z"/></svg>'
        };

        function renderCustomerTable(data) {
            const tbody = document.getElementById('userTableBody');
            if (!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding: 25px; color:#888;">Không tìm thấy khách hàng phù hợp.</td></tr>';
                return;
            }

            tbody.innerHTML = data.map(u => {
                const isLocked = (u.status === 0);
                const statusBadge = isLocked
                    ? `<span class="status-badge status-locked">Đang bị khóa</span>`
                    : `<span class="status-badge status-active">Hoạt động</span>`;

                const uname = (u.username || '').replace(/'/g, "\\'");
                const btnLockAction = isLocked
                    ? `<button class="btn-act btn-act-unlock" onclick="toggleLockCustomer(${u.id}, '${uname}', 1)" title="Mở khóa tài khoản">${CUST_ICONS.unlock} Mở khóa</button>`
                    : `<button class="btn-act btn-act-lock" onclick="toggleLockCustomer(${u.id}, '${uname}', 0)" title="Khóa tài khoản">${CUST_ICONS.lock} Khóa</button>`;

                return `
                <tr class="cust-row" ${isLocked ? 'style="opacity: 0.65;"' : ''}>
                    <td><span class="cust-id">#${u.id}</span></td>
                    <td>
                        <div class="cust-user">
                            ${avatarChuDau(u.name || u.username, u.id)}
                            <div>
                                <div class="cust-name">${u.name || 'Chưa cập nhật'}</div>
                                <div class="cust-sub">@${u.username} ${vaiTroNgan(u.role)}</div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div class="cust-contact">
                            <span>${CUST_ICONS.mail}${u.email || '—'}</span>
                            <span>${CUST_ICONS.phone}${u.phone || '—'}</span>
                        </div>
                    </td>
                    <td class="cust-count">${u.orderCount}</td>
                    <td class="cust-money">${(u.totalSpent || 0).toLocaleString('vi-VN')} ₫</td>
                    <td style="text-align: center;">${statusBadge}</td>
                    <td>
                        <div class="act-group">
                            <button class="btn-act btn-act-view" onclick="viewCustomerDetail(${u.id})" title="Xem chi tiết">${CUST_ICONS.view} Chi tiết</button>
                            <button class="btn-act btn-act-order" onclick="viewCustomerOrders(${u.id})" title="Lịch sử đơn hàng">${CUST_ICONS.order} Đơn hàng</button>
                            ${(IS_QUAN_TRI_VIEN && u.role !== 'Admin') ? btnLockAction : ''}
                        </div>
                    </td>
                </tr>
                `;
            }).join('');
        }

        function custFilteredSorted() {
            const kw = (document.getElementById('custSearchInput').value || '').toLowerCase().trim();
            const roleF = document.getElementById('custRoleFilter').value;
            const statusF = document.getElementById('custStatusFilter').value;
            const sortF = document.getElementById('custSort').value;

            let list = dsKhachHangAdmin.filter(u => {
                const matchKw = !kw ||
                    (u.name && u.name.toLowerCase().includes(kw)) ||
                    (u.username && u.username.toLowerCase().includes(kw)) ||
                    (u.phone && u.phone.includes(kw)) ||
                    (u.email && u.email.toLowerCase().includes(kw));
                const matchRole = !roleF ||
                    (roleF === 'NhanVienHoTro'
                        ? (u.role === 'NhanVienHoTro' || u.role === 'NhanVien')
                        : u.role === roleF);
                const matchStatus = !statusF || String(u.status) === statusF;
                return matchKw && matchRole && matchStatus;
            });

            const ten = u => (u.name || u.username || '').toLowerCase();
            switch (sortF) {
                case 'spent_desc': list.sort((a, b) => (b.totalSpent || 0) - (a.totalSpent || 0)); break;
                case 'orders_desc': list.sort((a, b) => (b.orderCount || 0) - (a.orderCount || 0)); break;
                case 'name_asc': list.sort((a, b) => ten(a).localeCompare(ten(b))); break;
                default: list.sort((a, b) => b.id - a.id);
            }
            return list;
        }

        function applyCustomerFilters(resetPage) {
            if (resetPage) custPage = 1;
            const list = custFilteredSorted();
            const total = list.length;
            const totalPages = Math.max(1, Math.ceil(total / CUST_PAGE_SIZE));
            if (custPage > totalPages) custPage = totalPages;
            const start = (custPage - 1) * CUST_PAGE_SIZE;
            renderCustomerTable(list.slice(start, start + CUST_PAGE_SIZE));
            renderCustPagination(total, totalPages);
        }

        function filterCustomers() {
            applyCustomerFilters(true);
        }

        function custGoPage(p) {
            custPage = p;
            applyCustomerFilters(false);
        }

        function renderCustPagination(total, totalPages) {
            const el = document.getElementById('custPagination');
            if (!el) return;
            if (total === 0) { el.innerHTML = ''; return; }

            const from = (custPage - 1) * CUST_PAGE_SIZE + 1;
            const to = Math.min(custPage * CUST_PAGE_SIZE, total);

            const pages = [];
            for (let p = 1; p <= totalPages; p++) {
                if (p === 1 || p === totalPages || Math.abs(p - custPage) <= 2) pages.push(p);
                else if (pages[pages.length - 1] !== '...') pages.push('...');
            }

            let html = `<button ${custPage === 1 ? 'disabled' : ''} onclick="custGoPage(${custPage - 1})">&laquo; Trước</button>`;
            html += pages.map(p => p === '...'
                ? '<span style="color:#666; padding:0 4px;">…</span>'
                : `<button class="${p === custPage ? 'active' : ''}" onclick="custGoPage(${p})">${p}</button>`).join('');
            html += `<button ${custPage === totalPages ? 'disabled' : ''} onclick="custGoPage(${custPage + 1})">Sau &raquo;</button>`;
            html += `<span class="page-info">Hiển thị ${from}–${to} / ${total} người dùng</span>`;
            el.innerHTML = html;
        }

        function viewCustomerDetail(id) {
            const u = dsKhachHangAdmin.find(x => x.id === id);
            if (!u) return;

            Swal.fire({
                title: 'Thông Tin Khách Hàng #' + u.id,
                width: '500px',
                html: `
                    <div style="text-align: left; padding: 10px 15px; font-size: 14px; line-height: 1.8;">
                        <p><b>Tên đăng nhập:</b> <span style="color:#ee4d2d;">${u.username}</span></p>
                        <p><b>Họ và tên:</b> ${u.name || 'Chưa cập nhật'}</p>
                        <p><b>Email:</b> ${u.email || 'Chưa có'}</p>
                        <p><b>Số điện thoại:</b> ${u.phone || 'Chưa có'}</p>
                        <p><b>Vai trò hệ thống:</b> ${tenVaiTroText(u.role)}</p>
                        <p><b>Trạng thái:</b> ${u.status === 1 ? '<span style="color:#26aa99; font-weight:bold;">Đang hoạt động</span>' : '<span style="color:#ef233c; font-weight:bold;">Đang bị khóa</span>'}</p>
                        <hr style="border: 0; border-top: 1px solid #444; margin: 12px 0;">
                        <p><b>Tổng đơn đã đặt:</b> <span style="color:#219ebc; font-weight:bold;">${u.orderCount} đơn</span></p>
                        <p><b>Tổng tích lũy mua sắm:</b> <span style="color:#ffb703; font-weight:bold; font-size:16px;">${(u.totalSpent || 0).toLocaleString('vi-VN')} ₫</span></p>
                    </div>
                `,
                confirmButtonColor: '#3b82f6',
                confirmButtonText: 'Đóng'
            });
        }

        function toggleLockCustomer(id, username, isUnlocking) {
            const actionText = isUnlocking ? "MỞ KHÓA" : "KHÓA";
            const confirmColor = isUnlocking ? "#26aa99" : "#ef233c";

            Swal.fire({
                title: `Xác nhận ${actionText}?`,
                text: `Bạn có chắc muốn ${actionText.toLowerCase()} tài khoản "${username}" không?`,
                icon: isUnlocking ? 'question' : 'warning',
                showCancelButton: true,
                confirmButtonColor: confirmColor,
                cancelButtonColor: '#6c757d',
                confirmButtonText: `Đồng ý ${actionText}`,
                cancelButtonText: 'Hủy'
            }).then(async (res) => {
                if (res.isConfirmed) {
                    const form = new URLSearchParams();
                    form.append('action', 'toggle_status');
                    form.append('id', id);

                    try {
                        const r = await fetch('/api/QuanLyKhachHangApi.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: form.toString()
                        });
                        const json = await r.json();
                        if (json.success) {
                            Swal.fire({ icon: 'success', title: json.message, toast: true, position: 'top-end', timer: 2000, showConfirmButton: false });
                            loadCustomers();
                        } else {
                            Swal.fire('Lỗi', json.message, 'error');
                        }
                    } catch (e) {
                        Swal.fire('Lỗi kết nối', '', 'error');
                    }
                }
            });
        }

        async function viewCustomerOrders(id) {
            const u = dsKhachHangAdmin.find(x => x.id === id);
            const customerName = u ? (u.name || u.username) : ('#' + id);
            try {
                const res = await fetch(`/api/QuanLyKhachHangApi.ashx?action=order_history&id=${id}`);
                const json = await res.json();

                if (json.success) {
                    if (json.data.length === 0) {
                        Swal.fire('Lịch sử đơn hàng', `Khách hàng <b>${customerName}</b> chưa đặt đơn hàng nào.`, 'info');
                        return;
                    }

                    let tableRows = json.data.map(o => `
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 10px; font-weight:bold; color:#222;">#${o.id}</td>
                            <td style="padding: 10px; font-size: 13px; color:#333;">${o.date}</td>
                            <td style="padding: 10px; color:#ee4d2d; font-weight:bold;">${(o.total || 0).toLocaleString('vi-VN')} ₫</td>
                            <td style="padding: 10px; font-size: 13px; color:#333;">${o.payment || 'Tiền mặt'}</td>
                            <td style="padding: 10px;"><span style="background:#f1f1f1; color:#333; padding:3px 8px; border-radius:4px; font-size:12px;">${o.status || 'Chờ duyệt'}</span></td>
                        </tr>
                    `).join('');

                    Swal.fire({
                        title: `Lịch Sử Đơn Hàng: ${customerName}`,
                        width: '750px',
                        html: `
                            <table style="width: 100%; text-align: left; color: #333; border-collapse: collapse; margin-top: 10px;">
                                <thead>
                                    <tr style="border-bottom: 2px solid #999; color: #ee4d2d;">
                                        <th style="padding: 10px;">Mã Đơn</th>
                                        <th style="padding: 10px;">Ngày Đặt</th>
                                        <th style="padding: 10px;">Tổng Tiền</th>
                                        <th style="padding: 10px;">Phương Thức</th>
                                        <th style="padding: 10px;">Trạng Thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${tableRows}
                                </tbody>
                            </table>
                        `,
                        confirmButtonColor: '#3b82f6',
                        confirmButtonText: 'Đóng'
                    });
                } else {
                    Swal.fire('Lỗi', json.message, 'error');
                }
            } catch (e) {
                Swal.fire('Lỗi kết nối', 'Không thể tải lịch sử đơn hàng', 'error');
            }
        }

        // ==========================================
        // 2b. QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN (Admin)
        // ==========================================
        let dsNguoiDungAdmin = [];

        async function loadNguoiDung() {
            const tbody = document.getElementById('nguoiDungTableBody');
            try {
                const res = await fetch('/api/QuanLyKhachHangApi.ashx?action=get');
                const json = await res.json();
                if (json.success) {
                    dsNguoiDungAdmin = json.data;
                    renderNguoiDungTable(dsNguoiDungAdmin);
                } else {
                    tbody.innerHTML = `<tr><td colspan="7" style="color:#ef233c; text-align:center;">${json.message}</td></tr>`;
                }
            } catch (e) {
                tbody.innerHTML = '<tr><td colspan="7" style="color:#ef233c; text-align:center;">Lỗi kết nối API người dùng!</td></tr>';
            }
        }

        function nhanVaiTroBadge(role) {
            if (role === 'Admin') return '<span class="status-badge" style="background:#ee4d2d; color:#fff;">Quản trị viên</span>';
            if (role === 'NhanVienBanHang') return '<span class="status-badge" style="background:#219ebc; color:#fff;">NV bán hàng</span>';
            if (role === 'NhanVienKho') return '<span class="status-badge" style="background:#8e44ad; color:#fff;">NV kho</span>';
            if (role === 'NhanVienHoTro' || role === 'NhanVien') return '<span class="status-badge" style="background:#26aa99; color:#fff;">NV hỗ trợ</span>';
            return '<span class="status-badge" style="background:#444; color:#ddd;">Khách hàng</span>';
        }

        function renderNguoiDungTable(data) {
            const tbody = document.getElementById('nguoiDungTableBody');
            if (!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:25px; color:#888;">Không tìm thấy người dùng phù hợp.</td></tr>';
                return;
            }
            tbody.innerHTML = data.map(u => {
                const isLocked = (u.status === 0);
                const statusBadge = isLocked
                    ? `<span class="status-badge status-locked">Đang bị khóa</span>`
                    : `<span class="status-badge status-active">Hoạt động</span>`;
                const btnLock = isLocked
                    ? `<button class="btn-action btn-unlock" onclick="khoaNguoiDung(${u.id}, '${(u.username || '').replace(/'/g, "\\'")}', 1)">Mở khóa</button>`
                    : `<button class="btn-action btn-lock" onclick="khoaNguoiDung(${u.id}, '${(u.username || '').replace(/'/g, "\\'")}', 0)">Khóa</button>`;
                return `
                <tr ${isLocked ? 'style="opacity: 0.65; background: rgba(239, 35, 60, 0.05);"' : ''}>
                    <td style="font-weight: bold; color: #fff;">#${u.id}</td>
                    <td style="font-weight: bold; color: #fff;">${u.username}</td>
                    <td>${u.name || '<span style="color:#888;">Chưa cập nhật</span>'}</td>
                    <td style="font-size: 13px; color: #bbb;">${u.email || '—'}<div style="font-size: 12px; color: #888;">${u.phone || '—'}</div></td>
                    <td style="text-align: center;">${nhanVaiTroBadge(u.role)}</td>
                    <td style="text-align: center;">${statusBadge}</td>
                    <td style="text-align: center; white-space: nowrap;">
                        <button class="btn-action btn-edit" onclick="suaNguoiDung(${u.id})">Sửa</button>
                        <button class="btn-action btn-history" onclick="datLaiMatKhau(${u.id}, '${(u.username || '').replace(/'/g, "\\'")}')">Đặt lại MK</button>
                        ${u.role === 'Admin' ? '' : btnLock}
                    </td>
                </tr>`;
            }).join('');
        }

        function filterNguoiDung() {
            const kw = document.getElementById('userSearchInput').value.toLowerCase().trim();
            if (!kw) { renderNguoiDungTable(dsNguoiDungAdmin); return; }
            const filtered = dsNguoiDungAdmin.filter(u =>
                (u.name && u.name.toLowerCase().includes(kw)) ||
                (u.username && u.username.toLowerCase().includes(kw)) ||
                (u.email && u.email.toLowerCase().includes(kw)) ||
                (u.phone && u.phone.includes(kw))
            );
            renderNguoiDungTable(filtered);
        }

        function themNhanSu() {
            Swal.fire({
                title: 'Thêm Tài Khoản Nhân Sự',
                width: '560px',
                html: `
                    <div style="text-align:left; padding:5px;" class="swal-wide-html">
                        <div class="row">
                            <div><label>Tên đăng nhập (*):</label><input id="nd-username" type="text" placeholder="VD: nhanvien01"></div>
                        </div>
                        <div class="row">
                            <div><label>Mật khẩu (*):</label><input id="nd-password" type="text" placeholder="Tối thiểu 6 ký tự"></div>
                        </div>
                        <div class="row">
                            <div><label>Họ và tên (*):</label><input id="nd-hoten" type="text" placeholder="VD: Nguyễn Văn A"></div>
                        </div>
                        <div class="row">
                            <div><label>Email:</label><input id="nd-email" type="text" placeholder="email@example.com"></div>
                            <div><label>Số điện thoại:</label><input id="nd-sdt" type="text" placeholder="09xx..."></div>
                        </div>
                        <div class="row">
                            <div><label>Vai trò:</label>
                                <select id="nd-vaitro">
                                    <option value="NhanVienBanHang">Nhân viên bán hàng (Đơn hàng, Khách hàng)</option>
                                    <option value="NhanVienKho">Nhân viên kho (Quản lý kho)</option>
                                    <option value="NhanVienHoTro">Nhân viên hỗ trợ (Chat khách hàng)</option>
                                    <option value="Admin">Quản trị viên (toàn quyền)</option>
                                </select>
                            </div>
                        </div>
                    </div>`,
                showCancelButton: true,
                confirmButtonText: 'Thêm tài khoản',
                cancelButtonText: 'Hủy',
                confirmButtonColor: '#26aa99',
                preConfirm: () => {
                    const un = document.getElementById('nd-username').value.trim();
                    const pw = document.getElementById('nd-password').value;
                    const ht = document.getElementById('nd-hoten').value.trim();
                    if (!un || !pw || !ht) { Swal.showValidationMessage('Vui lòng nhập Tên đăng nhập, Mật khẩu và Họ tên!'); return false; }
                    if (pw.length < 6) { Swal.showValidationMessage('Mật khẩu phải từ 6 ký tự trở lên!'); return false; }
                    return true;
                }
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                const fd = new URLSearchParams();
                fd.append('action', 'add_staff');
                fd.append('username', document.getElementById('nd-username').value.trim());
                fd.append('password', document.getElementById('nd-password').value);
                fd.append('hoTen', document.getElementById('nd-hoten').value.trim());
                fd.append('email', document.getElementById('nd-email').value.trim());
                fd.append('sdt', document.getElementById('nd-sdt').value.trim());
                fd.append('vaiTro', document.getElementById('nd-vaitro').value);
                await guiFormNguoiDung(fd);
            });
        }

        async function suaNguoiDung(id) {
            let u;
            try {
                const res = await fetch('/api/QuanLyNguoiDungApi.ashx?action=detail&id=' + id);
                const json = await res.json();
                if (!json.success) { Swal.fire('Lỗi', json.message, 'error'); return; }
                u = json.data;
            } catch (e) { Swal.fire('Lỗi kết nối', 'Không tải được thông tin người dùng', 'error'); return; }

            const esc = s => (s == null ? '' : String(s).replace(/"/g, '&quot;'));
            Swal.fire({
                title: 'Sửa Người Dùng #' + id,
                width: '560px',
                html: `
                    <div style="text-align:left; padding:5px;" class="swal-wide-html">
                        <div class="row">
                            <div><label>Tên đăng nhập:</label><input id="nd-username" type="text" value="${esc(u.username)}" disabled></div>
                        </div>
                        <div class="row">
                            <div><label>Họ và tên (*):</label><input id="nd-hoten" type="text" value="${esc(u.name)}"></div>
                        </div>
                        <div class="row">
                            <div><label>Email:</label><input id="nd-email" type="text" value="${esc(u.email)}"></div>
                            <div><label>Số điện thoại:</label><input id="nd-sdt" type="text" value="${esc(u.phone)}"></div>
                        </div>
                        <div class="row">
                            <div><label>Địa chỉ:</label><input id="nd-diachi" type="text" value="${esc(u.address)}"></div>
                        </div>
                        <div class="row">
                            <div><label>Vai trò:</label>
                                <select id="nd-vaitro" ${u.role === 'Admin' ? 'disabled' : ''}>
                                    <option value="User" ${u.role === 'User' ? 'selected' : ''}>Khách hàng</option>
                                    <option value="NhanVienBanHang" ${u.role === 'NhanVienBanHang' ? 'selected' : ''}>Nhân viên bán hàng</option>
                                    <option value="NhanVienKho" ${u.role === 'NhanVienKho' ? 'selected' : ''}>Nhân viên kho</option>
                                    <option value="NhanVienHoTro" ${u.role === 'NhanVienHoTro' ? 'selected' : ''}>Nhân viên hỗ trợ</option>
                                    <option value="NhanVien" ${u.role === 'NhanVien' ? 'selected' : ''}>Nhân viên (chung - chỉ chat)</option>
                                    <option value="Admin" ${u.role === 'Admin' ? 'selected' : ''}>Quản trị viên</option>
                                </select>
                            </div>
                        </div>
                    </div>`,
                showCancelButton: true,
                confirmButtonText: 'Lưu thay đổi',
                cancelButtonText: 'Hủy',
                confirmButtonColor: '#ffb703',
                preConfirm: () => {
                    if (!document.getElementById('nd-hoten').value.trim()) { Swal.showValidationMessage('Vui lòng nhập họ tên!'); return false; }
                    return true;
                }
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                const fd = new URLSearchParams();
                fd.append('action', 'update');
                fd.append('id', id);
                fd.append('hoTen', document.getElementById('nd-hoten').value.trim());
                fd.append('email', document.getElementById('nd-email').value.trim());
                fd.append('sdt', document.getElementById('nd-sdt').value.trim());
                fd.append('diaChi', document.getElementById('nd-diachi').value.trim());
                fd.append('vaiTro', document.getElementById('nd-vaitro').value);
                await guiFormNguoiDung(fd);
            });
        }

        function datLaiMatKhau(id, username) {
            Swal.fire({
                title: 'Đặt Lại Mật Khẩu',
                input: 'text',
                inputLabel: 'Mật khẩu mới cho tài khoản: ' + username,
                inputPlaceholder: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                showCancelButton: true,
                confirmButtonText: 'Đặt lại',
                cancelButtonText: 'Hủy',
                confirmButtonColor: '#8e44ad',
                inputValidator: (val) => {
                    if (!val || val.length < 6) return 'Mật khẩu mới phải từ 6 ký tự trở lên!';
                }
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                const fd = new URLSearchParams();
                fd.append('action', 'reset_password');
                fd.append('id', id);
                fd.append('newPassword', r.value);
                await guiFormNguoiDung(fd);
            });
        }

        function khoaNguoiDung(id, username, isUnlocking) {
            const actionText = isUnlocking ? "MỞ KHÓA" : "KHÓA";
            Swal.fire({
                title: `Xác nhận ${actionText}?`,
                text: `Bạn có chắc muốn ${actionText.toLowerCase()} tài khoản "${username}" không?`,
                icon: isUnlocking ? 'question' : 'warning',
                showCancelButton: true,
                confirmButtonColor: isUnlocking ? '#26aa99' : '#ef233c',
                cancelButtonColor: '#6c757d',
                confirmButtonText: `Đồng ý ${actionText}`,
                cancelButtonText: 'Hủy'
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                const fd = new URLSearchParams();
                fd.append('action', 'toggle_status');
                fd.append('id', id);
                try {
                    const res = await fetch('/api/QuanLyKhachHangApi.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: fd.toString()
                    });
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); loadNguoiDung(); }
                    else Swal.fire('Lỗi', json.message, 'error');
                } catch (e) { Swal.fire('Lỗi kết nối', '', 'error'); }
            });
        }

        async function guiFormNguoiDung(fd) {
            try {
                const res = await fetch('/api/QuanLyNguoiDungApi.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: fd.toString()
                });
                const json = await res.json();
                if (json.success) { toastOK(json.message); loadNguoiDung(); }
                else Swal.fire('Thất bại', json.message, 'error');
            } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
        }

        // ==========================================
        // 3. QUẢN LÝ DANH MỤC (CRUD)
        // ==========================================
        async function loadCategories() {
            const tbody = document.getElementById('categoryTableBody');
            try {
                const res = await fetch('/api/QuanLyDanhMucApi.ashx?action=get');
                const json = await res.json();

                if (json.success) {
                    dsDanhMucAdmin = json.data;
                    if (json.data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="4" style="text-align:center;">Chưa có danh mục nào.</td></tr>';
                        return;
                    }

                    tbody.innerHTML = json.data.map(d => `
                        <tr>
                            <td style="font-weight: bold; color: #fff;">#${d.id}</td>
                            <td style="color: #fff; font-size: 15px; font-weight: 500;">${d.name}</td>
                            <td><span style="background: #2a2a2a; color: #219ebc; padding: 4px 10px; border-radius: 4px; font-weight: bold;">${d.count} linh kiện</span></td>
                            <td>
                                <button class="btn-action btn-edit" onclick="suaDanhMuc(${d.id}, '${d.name.replace(/'/g, "\\'")}')">Sửa</button>
                                <button class="btn-action btn-delete" onclick="xoaDanhMuc(${d.id}, '${d.name.replace(/'/g, "\\'")}', ${d.count})">Xóa</button>
                            </td>
                        </tr>
                    `).join('');
                } else {
                    tbody.innerHTML = `<tr><td colspan="4" style="color:red; text-align:center;">${json.message}</td></tr>`;
                }
            } catch (e) {
                tbody.innerHTML = '<tr><td colspan="4" style="color:red; text-align:center;">Lỗi kết nối API Danh mục!</td></tr>';
            }
        }

        function themMoiDanhMuc() {
            Swal.fire({
                title: 'Thêm Danh Mục Mới',
                input: 'text',
                inputLabel: 'Tên danh mục linh kiện:',
                inputPlaceholder: 'Ví dụ: Pô & Ống Xả, Lốp & Vỏ...',
                showCancelButton: true,
                confirmButtonText: 'Lưu Danh Mục',
                cancelButtonText: 'Hủy',
                confirmButtonColor: '#26aa99',
                inputValidator: (val) => {
                    if (!val || !val.trim()) return 'Vui lòng nhập tên danh mục!';
                }
            }).then(async (res) => {
                if (res.isConfirmed) {
                    const form = new URLSearchParams();
                    form.append('action', 'add');
                    form.append('name', res.value.trim());

                    try {
                        const r = await fetch('/api/QuanLyDanhMucApi.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: form.toString()
                        });
                        const json = await r.json();
                        if (json.success) {
                            Swal.fire({ icon: 'success', title: json.message, toast: true, position: 'top-end', timer: 2000, showConfirmButton: false });
                            loadCategories();
                        } else {
                            Swal.fire('Lỗi', json.message, 'error');
                        }
                    } catch (e) {
                        Swal.fire('Lỗi kết nối', 'Không thể kết nối máy chủ', 'error');
                    }
                }
            });
        }

        function suaDanhMuc(id, tenHienTai) {
            Swal.fire({
                title: 'Sửa Danh Mục #' + id,
                input: 'text',
                inputValue: tenHienTai,
                inputLabel: 'Tên danh mục mới:',
                showCancelButton: true,
                confirmButtonText: 'Cập nhật',
                cancelButtonText: 'Hủy',
                confirmButtonColor: '#ffb703',
                inputValidator: (val) => {
                    if (!val || !val.trim()) return 'Tên danh mục không được để trống!';
                }
            }).then(async (res) => {
                if (res.isConfirmed) {
                    const form = new URLSearchParams();
                    form.append('action', 'update');
                    form.append('id', id);
                    form.append('name', res.value.trim());

                    try {
                        const r = await fetch('/api/QuanLyDanhMucApi.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: form.toString()
                        });
                        const json = await r.json();
                        if (json.success) {
                            Swal.fire({ icon: 'success', title: json.message, toast: true, position: 'top-end', timer: 2000, showConfirmButton: false });
                            loadCategories();
                        } else {
                            Swal.fire('Lỗi', json.message, 'error');
                        }
                    } catch (e) {
                        Swal.fire('Lỗi kết nối', 'Không thể kết nối máy chủ', 'error');
                    }
                }
            });
        }

        function xoaDanhMuc(id, ten, count) {
            if (count > 0) {
                Swal.fire('Cảnh báo', `Danh mục "${ten}" đang có ${count} sản phẩm! Vui lòng xóa hoặc di chuyển các sản phẩm này sang danh mục khác trước khi xóa.`, 'warning');
                return;
            }

            Swal.fire({
                title: 'Xác nhận xóa?',
                text: `Bạn có chắc muốn xóa vĩnh viễn danh mục "${ten}"?`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef233c',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Xóa ngay',
                cancelButtonText: 'Hủy'
            }).then(async (res) => {
                if (res.isConfirmed) {
                    try {
                        const r = await fetch(`/api/QuanLyDanhMucApi.ashx?action=delete&id=${id}`);
                        const json = await r.json();
                        if (json.success) {
                            Swal.fire({ icon: 'success', title: json.message, toast: true, position: 'top-end', timer: 2000, showConfirmButton: false });
                            loadCategories();
                        } else {
                            Swal.fire('Lỗi', json.message, 'error');
                        }
                    } catch (e) {
                        Swal.fire('Lỗi kết nối', 'Không thể kết nối máy chủ', 'error');
                    }
                }
            });
        }

        // ==========================================
        // 4. CODE QUẢN LÝ SẢN PHẨM
        // ==========================================
        async function loadAdminProducts() {
            try {
                const res = await fetch('/api/LinhKienApi.ashx?admin=1');
                const json = await res.json();

                if (json.success) {
                    dsSanPhamAdmin = json.data;
                    const tbody = document.getElementById('adminProductTable');

                    if (json.data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;">Chưa có sản phẩm nào.</td></tr>';
                        return;
                    }

                    tbody.innerHTML = json.data.map(p => {
                        const hidden = p.isHidden;
                        return `
                        <tr ${hidden ? 'style="opacity:0.55;"' : ''}>
                            <td style="font-weight: bold;">#${p.id}</td>
                            <td><img src="${p.img || 'images/anh_dai_dien.jpg'}" class="prod-img" onerror="this.src='images/anh_dai_dien.jpg'"/></td>
                            <td style="color: #fff;">
                                ${p.name}
                                ${p.isHot ? '<span style="color:#ee4d2d; font-size:11px;">🔥</span>' : ''}
                                ${p.isSale ? '<span style="color:#ffb703; font-size:11px;">📉</span>' : ''}
                                ${hidden ? '<span style="background:#444; color:#ccc; font-size:11px; padding:2px 6px; border-radius:3px; margin-left:5px;">Đã ẩn</span>' : ''}
                                <div style="font-size:12px; color:#888;">${p.brand ? p.brand + ' • ' : ''}${(p.dongXe && p.dongXe.length) ? p.dongXe.length + ' dòng xe' : 'Chưa gán dòng xe'}</div>
                            </td>
                            <td><span style="background: #333; padding: 4px 8px; border-radius: 4px; font-size: 12px;">${p.category || 'Chưa phân loại'}</span></td>
                            <td style="color: #ee4d2d; font-weight: bold;">${parseInt(p.price).toLocaleString('vi-VN')} ₫</td>
                            <td>${p.stock || 0}</td>
                            <td style="white-space:nowrap;">
                                <button class="btn-action btn-edit" onclick="suaSanPham(${p.id})">Sửa</button>
                                ${hidden
                                    ? `<button class="btn-action" style="background:#26aa99;" onclick="toggleAnSanPham(${p.id}, true)">Hiện</button>
                                       <button class="btn-action btn-delete" onclick="xoaVinhVienSanPham(${p.id}, '${(p.name||'').replace(/'/g, "\\'")}')">Xóa</button>`
                                    : `<button class="btn-action" style="background:#6c757d;" onclick="toggleAnSanPham(${p.id}, false)">Ẩn</button>`}
                            </td>
                        </tr>
                    `;
                    }).join('');
                }
            } catch (e) {
                Swal.fire('Lỗi', 'Không thể tải dữ liệu', 'error');
            }
        }

        async function toggleAnSanPham(id, isHidden) {
            const verb = isHidden ? 'hiện lại' : 'ẩn';
            Swal.fire({
                title: 'Xác nhận',
                text: `Bạn muốn ${verb} sản phẩm này?`,
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#26aa99',
                confirmButtonText: 'Đồng ý',
                cancelButtonText: 'Hủy'
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                try {
                    const url = isHidden
                        ? `/api/XoaSanPhamApi.ashx?id=${id}&restore=1`
                        : `/api/XoaSanPhamApi.ashx?id=${id}`;
                    const res = await fetch(url, { method: 'POST' });
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); loadAdminProducts(); }
                    else Swal.fire('Lỗi', json.message, 'error');
                } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
            });
        }

        function xoaVinhVienSanPham(id, ten) {
            Swal.fire({
                title: 'Xóa vĩnh viễn!',
                html: `Xóa vĩnh viễn <b>${ten}</b> khỏi CSDL?<br><small style="color:#ef233c;">Thao tác này không thể hoàn tác và sẽ xóa cả đánh giá, chi tiết đơn hàng liên quan.</small>`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef233c',
                confirmButtonText: 'Xóa vĩnh viễn',
                cancelButtonText: 'Hủy'
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                try {
                    const res = await fetch(`/api/XoaSanPhamApi.ashx?id=${id}&hard=1`, { method: 'POST' });
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); loadAdminProducts(); }
                    else Swal.fire('Lỗi', json.message, 'error');
                } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
            });
        }

        function toastOK(msg) {
            Swal.fire({ icon: 'success', title: msg, toast: true, position: 'top-end', timer: 2000, showConfirmButton: false });
        }

        // Cache dòng xe dùng cho form sản phẩm
        let dsDongXeAdmin = [];
        let dangSuaId = null;

        async function taiDuLieuFormSanPham() {
            try {
                if (!dsDanhMucAdmin || dsDanhMucAdmin.length === 0) {
                    const r1 = await fetch('/api/QuanLyDanhMucApi.ashx?action=get');
                    const j1 = await r1.json();
                    if (j1.success) dsDanhMucAdmin = j1.data;
                }
            } catch (e) { console.error("Lỗi tải danh mục:", e); }
            try {
                if (!dsDongXeAdmin || dsDongXeAdmin.length === 0) {
                    const r2 = await fetch('/api/QuanLyDongXeApi.ashx?action=get');
                    const j2 = await r2.json();
                    if (j2.success) dsDongXeAdmin = j2.data;
                }
            } catch (e) { console.error("Lỗi tải dòng xe:", e); }
        }

        function optionsDanhMucHtml(selectedId) {
            if (!dsDanhMucAdmin || dsDanhMucAdmin.length === 0) return '<option value="">Chưa có danh mục nào</option>';
            return dsDanhMucAdmin.map(d =>
                `<option value="${d.id}" ${String(d.id) === String(selectedId) ? 'selected' : ''}>${d.name}</option>`).join('');
        }

        function dongXeCheckboxHtml(selectedNames) {
            if (!dsDongXeAdmin || dsDongXeAdmin.length === 0)
                return '<div style="color:#999;">Chưa có dòng xe nào. Hãy thêm ở tab "Dòng Xe".</div>';
            selectedNames = selectedNames || [];
            return dsDongXeAdmin.map(x => {
                const ten = ((x.hangXe || '') + ' ' + (x.tenXe || '') + ' ' + (x.doiXe || '')).replace(/\s+/g, ' ').trim();
                const checked = selectedNames.indexOf(ten) >= 0 ? 'checked' : '';
                return `<label><input type="checkbox" class="xe-chk" value="${x.id}" ${checked}> ${ten}</label>`;
            }).join('');
        }

        function layMaXeDaChon() {
            return Array.from(document.querySelectorAll('.xe-chk:checked')).map(c => c.value).join(',');
        }

        function buildProductFormHtml(p) {
            p = p || {};
            const isEdit = !!p.id;
            const gia = p.price != null ? p.price : '';
            const giaGoc = p.giaNiemYet != null ? p.giaNiemYet : gia;
            const esc = s => (s == null ? '' : String(s).replace(/"/g, '&quot;'));
            return `
                <div style="text-align:left; padding:5px;" class="swal-wide-html">
                    <div class="row">
                        <div>
                            <label>Tên phụ tùng (*):</label>
                            <input id="sp-ten" type="text" value="${esc(p.name)}" placeholder="Nhập tên sản phẩm...">
                        </div>
                    </div>
                    <div class="row">
                        <div>
                            <label>Danh mục chính (*):</label>
                            <select id="sp-danhmuc">${optionsDanhMucHtml(p.maDanhMuc)}</select>
                        </div>
                        <div>
                            <label>Danh mục phụ:</label>
                            <select id="sp-danhmucphu"><option value="">-- Không --</option>${optionsDanhMucHtml(p.maDanhMucPhu)}</select>
                        </div>
                    </div>
                    <div class="row">
                        <div>
                            <label>Giá gốc (VNĐ):</label>
                            <input id="sp-giagoc" type="number" value="${giaGoc}">
                        </div>
                        <div>
                            <label>Giá bán (*):</label>
                            <input id="sp-gia" type="number" value="${gia}">
                        </div>
                        <div>
                            <label>Tồn kho:</label>
                            <input id="sp-ton" type="number" value="${isEdit ? (p.stock || 0) : 10}">
                        </div>
                    </div>
                    <div class="row">
                        <div>
                            <label>Hãng xe:</label>
                            <input id="sp-hangxe" type="text" value="${esc(p.hangXe || p.brand)}" placeholder="VD: Honda, Yamaha...">
                        </div>
                        <div>
                            <label>Nhãn hiệu (badge):</label>
                            <input id="sp-nhanhieu" type="text" value="${esc(p.badge)}" placeholder="VD: Chính hãng, Loại 1...">
                        </div>
                    </div>
                    <div class="row">
                        <div>
                            <label>Mô tả sản phẩm:</label>
                            <textarea id="sp-mota" rows="3" placeholder="Mô tả chi tiết...">${esc(p.moTa)}</textarea>
                        </div>
                    </div>
                    <div class="row" style="background:#f8f9fa; padding:10px; border-radius:6px; border:1px solid #ddd;">
                        <label style="flex:1; font-weight:bold;"><input type="checkbox" id="sp-hot" ${p.isHot ? 'checked' : ''}> 🔥 HOT</label>
                        <label style="flex:1; font-weight:bold;"><input type="checkbox" id="sp-sale" ${p.isSale ? 'checked' : ''}> 📉 Giảm giá</label>
                        <label style="flex:1; font-weight:bold;"><input type="checkbox" id="sp-hien" ${(isEdit && p.isHidden) ? '' : 'checked'}> 👁️ Hiển thị</label>
                    </div>
                    <div style="margin:12px 0 5px;">
                        <label>Dòng xe tương thích:</label>
                        <div class="xe-box">${dongXeCheckboxHtml(p.dongXe)}</div>
                    </div>
                    ${isEdit ? `<div style="margin:12px 0 5px;"><label>Thư viện ảnh hiện có (bấm ảnh để đặt làm ảnh chính):</label><div id="sp-gallery" class="gallery-current"></div></div>` : ''}
                    <div style="margin:12px 0 5px;">
                        <label>${isEdit ? 'Tải lên ảnh mới (sẽ thành ảnh chính):' : 'Chọn ảnh từ máy tính:'}</label>
                        <input id="sp-anh" type="file" accept="image/*" style="font-size:13px;">
                    </div>
                </div>
            `;
        }

        async function loadGalleryVaoDialog(maLinhKien) {
            const box = document.getElementById('sp-gallery');
            if (!box) return;
            try {
                const res = await fetch('/api/QuanLyAnhApi.ashx?action=get&maLinhKien=' + maLinhKien);
                const json = await res.json();
                if (!json.success || !json.data.length) { box.innerHTML = '<span style="color:#999; font-size:12px;">Chưa có ảnh trong thư viện.</span>'; return; }
                box.innerHTML = json.data.map(a => `
                    <div style="position:relative; text-align:center;">
                        <img src="${a.url}" class="thumb-sm" title="${a.main ? 'Ảnh chính' : 'Đặt làm ảnh chính'}"
                             style="${a.main ? 'border:2px solid #26aa99;' : ''}" onclick="datAnhChinh(${a.id})">
                        <div><button type="button" onclick="xoaAnh(${a.id})" style="font-size:11px; color:#ef233c; background:none; border:none; cursor:pointer;">Xóa</button></div>
                    </div>`).join('');
            } catch (e) { box.innerHTML = '<span style="color:#ef233c; font-size:12px;">Lỗi tải ảnh.</span>'; }
        }

        async function datAnhChinh(maAnh) {
            if (!dangSuaId) return;
            const fd = new URLSearchParams();
            fd.append('action', 'set_main');
            fd.append('id', maAnh);
            try {
                await fetch('/api/QuanLyAnhApi.ashx', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: fd.toString() });
                loadGalleryVaoDialog(dangSuaId);
                loadAdminProducts();
            } catch (e) { console.error(e); }
        }

        async function xoaAnh(maAnh) {
            if (!dangSuaId) return;
            try {
                await fetch('/api/QuanLyAnhApi.ashx?action=delete&id=' + maAnh, { method: 'POST' });
                loadGalleryVaoDialog(dangSuaId);
                loadAdminProducts();
            } catch (e) { console.error(e); }
        }

        async function themMoi() {
            await taiDuLieuFormSanPham();

            Swal.fire({
                title: 'Thêm Phụ Tùng Mới',
                width: '720px',
                html: buildProductFormHtml(null),
                showCancelButton: true,
                confirmButtonText: 'Thêm vào CSDL',
                cancelButtonText: 'Hủy bỏ',
                confirmButtonColor: '#26aa99',
                preConfirm: () => {
                    const ten = document.getElementById('sp-ten').value.trim();
                    const gia = document.getElementById('sp-gia').value.trim();
                    const maDanhMuc = document.getElementById('sp-danhmuc').value;
                    if (!ten || !gia) { Swal.showValidationMessage('Vui lòng nhập Tên và Giá bán!'); return false; }
                    if (!maDanhMuc) { Swal.showValidationMessage('Vui lòng chọn danh mục cho sản phẩm!'); return false; }
                    return true;
                }
            }).then(async (result) => {
                if (!result.isConfirmed) return;
                const formData = new FormData();
                formData.append('ten', document.getElementById('sp-ten').value.trim());
                formData.append('maDanhMuc', document.getElementById('sp-danhmuc').value);
                formData.append('maDanhMucPhu', document.getElementById('sp-danhmucphu').value);
                formData.append('giaGoc', document.getElementById('sp-giagoc').value);
                formData.append('giaBan', document.getElementById('sp-gia').value);
                formData.append('tonKho', document.getElementById('sp-ton').value);
                formData.append('hangXe', document.getElementById('sp-hangxe').value);
                formData.append('nhanHieu', document.getElementById('sp-nhanhieu').value);
                formData.append('moTa', document.getElementById('sp-mota').value);
                formData.append('isHot', document.getElementById('sp-hot').checked);
                formData.append('isSale', document.getElementById('sp-sale').checked);
                formData.append('trangThai', document.getElementById('sp-hien').checked);
                formData.append('maXe', layMaXeDaChon());
                const fileInput = document.getElementById('sp-anh');
                if (fileInput && fileInput.files[0]) formData.append('fileAnh', fileInput.files[0]);

                try {
                    const res = await fetch('/api/ThemSanPhamApi.ashx', { method: 'POST', body: formData });
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); loadAdminProducts(); }
                    else { Swal.fire('Thất bại', json.message, 'error'); }
                } catch (e) { Swal.fire('Lỗi', 'Không kết nối được', 'error'); }
            });
        }

        async function suaSanPham(id) {
            const p = dsSanPhamAdmin.find(x => x.id === id);
            if (!p) return;

            await taiDuLieuFormSanPham();
            dangSuaId = id;

            Swal.fire({
                title: 'Sửa Sản Phẩm #' + id,
                width: '720px',
                html: buildProductFormHtml(p),
                didOpen: () => { loadGalleryVaoDialog(id); },
                showCancelButton: true,
                confirmButtonText: 'Lưu thay đổi',
                cancelButtonText: 'Hủy bỏ',
                confirmButtonColor: '#26aa99',
                preConfirm: () => {
                    if (!document.getElementById('sp-ten').value.trim()) {
                        Swal.showValidationMessage('Vui lòng nhập tên sản phẩm!');
                        return false;
                    }
                    return true;
                }
            }).then(async (result) => {
                if (!result.isConfirmed) return;

                const formData = new URLSearchParams();
                formData.append('id', id);
                formData.append('ten', document.getElementById('sp-ten').value.trim());
                formData.append('maDanhMuc', document.getElementById('sp-danhmuc').value);
                formData.append('maDanhMucPhu', document.getElementById('sp-danhmucphu').value);
                formData.append('giaGoc', document.getElementById('sp-giagoc').value);
                formData.append('giaBan', document.getElementById('sp-gia').value);
                formData.append('tonKho', document.getElementById('sp-ton').value);
                formData.append('hangXe', document.getElementById('sp-hangxe').value);
                formData.append('nhanHieu', document.getElementById('sp-nhanhieu').value);
                formData.append('moTa', document.getElementById('sp-mota').value);
                formData.append('isHot', document.getElementById('sp-hot').checked);
                formData.append('isSale', document.getElementById('sp-sale').checked);
                formData.append('trangThai', document.getElementById('sp-hien').checked);
                formData.append('syncXe', '1');
                formData.append('maXe', layMaXeDaChon());

                const fileInput = document.getElementById('sp-anh');
                const coAnhMoi = fileInput && fileInput.files[0];

                try {
                    let res;
                    if (coAnhMoi) {
                        const fd = new FormData();
                        formData.forEach((v, k) => fd.append(k, v));
                        fd.append('fileAnh', coAnhMoi);
                        res = await fetch('/api/SuaSanPhamApi.ashx', { method: 'POST', body: fd });
                    } else {
                        res = await fetch('/api/SuaSanPhamApi.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: formData.toString()
                        });
                    }
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); loadAdminProducts(); }
                    else { Swal.fire('Thất bại', json.message, 'error'); }
                } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
            });
        }

        // (Xóa sản phẩm nay dùng toggleAnSanPham / xoaVinhVienSanPham ở phần danh sách sản phẩm)

        // ==========================================
        // 5. CODE QUẢN LÝ ĐƠN HÀNG
        // ==========================================
        let dsDonHangAdmin = [];

        async function loadOrders() {
            const tbody = document.getElementById('orderTableBody');
            try {
                const res = await fetch('/api/AdminQuanLyDonHangApi.ashx');
                const json = await res.json();
                if (IS_QUAN_TRI_VIEN) loadThongKe();

                if (json.success) {
                    dsDonHangAdmin = json.data;
                    renderOrderTable(dsDonHangAdmin);
                } else {
                    tbody.innerHTML = `<tr><td colspan="8" style="color: #ef233c; text-align: center;">Lỗi máy chủ: ${json.message}</td></tr>`;
                }
            } catch (e) {
                tbody.innerHTML = `<tr><td colspan="8" style="color: #ef233c; text-align: center;">Lỗi kết nối API đơn hàng!</td></tr>`;
            }
        }

        function renderOrderTable(data) {
            const tbody = document.getElementById('orderTableBody');
            if (!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 25px; color:#888;">Không tìm thấy đơn hàng nào.</td></tr>';
                return;
            }

            tbody.innerHTML = data.map(o => {
                let classStatus = 'status-pending'; // Mặc định vàng cam cho Chờ xác nhận, Đã xác nhận, Đang chuẩn bị hàng
                if (o.ttDon === 'Đang giao cho Shipper' || o.ttDon === 'Đang giao') classStatus = 'status-shipping';
                if (o.ttDon === 'Đã giao thành công' || o.ttDon === 'Đã giao' || o.ttDon === 'Hoàn thành') classStatus = 'status-success';
                if (o.ttDon === 'Hủy đơn hàng' || o.ttDon === 'Đã hủy') classStatus = 'status-cancel';
                if (o.ttDon === 'Khách hoàn trả hàng' || o.ttDon === 'Hoàn trả') classStatus = 'status-return';

                let isPaid = (o.ttThanhToan && o.ttThanhToan.toLowerCase().includes('đã'));
                let ttThanhToanColor = isPaid ? '#26aa99' : '#ffb703';

                return `
                <tr>
                    <td style="font-weight: bold; color: #fff;">
                        #${o.id}
                        <div style="font-size: 11px; color: #219ebc; margin-top: 4px;">
                            ${o.maVanDon ? `MVD: <b>${o.maVanDon}</b>` : '<span style="color:#666;">Chưa có mã VC</span>'}
                        </div>
                    </td>
                    <td>
                        <div style="font-weight:bold; color:#fff;">${o.tenKhach || 'Khách vãng lai'}</div>
                        <div style="font-size: 12px; color: #aaa; margin-top:4px;">📞 ${o.sdt || '—'}</div>
                    </td>
                    <td style="font-size: 13px; max-width: 220px; line-height: 1.4;">${o.diaChi || ''}</td>
                    <td style="font-size: 13px;">${o.ngay}</td>
                    <td style="color: #ee4d2d; font-weight: bold; font-size: 15px;">
                        ${(o.tongTien || 0).toLocaleString('vi-VN')} ₫
                        ${o.giamGia ? `<div style="font-size:11px; color:#4ade80; font-weight:normal; margin-top:2px;">Đã giảm ${o.giamGia.toLocaleString('vi-VN')} ₫${o.maGiamGia ? ' (' + o.maGiamGia + ')' : ''}</div>` : ''}
                    </td>
                    <td style="font-size: 13px;">
                        <div>💳 ${o.ptThanhToan || 'Tiền mặt'}</div>
                        <div style="color: ${ttThanhToanColor}; font-weight: bold; font-size: 12px; margin-top:4px;">
                            ${o.ttThanhToan || 'Chưa thanh toán'}
                        </div>
                    </td>
                    <td><span class="status-badge ${classStatus}">${o.ttDon || 'Chờ duyệt'}</span></td>
                    <td style="text-align: center;">
                        <button class="btn-action btn-view" onclick="xemChiTiet('${o.id}')" style="margin-bottom: 5px; width: 100%;">Chi tiết</button><br>
                        <button class="btn-action btn-edit" onclick="capNhatTrangThai('${o.id}')" style="width: 100%;">Cập nhật</button>
                    </td>
                </tr>
                `;
            }).join('');
        }

        // Lọc đơn hàng tức thì (Client-side Search & Filter)
        function filterOrders() {
            const kw = document.getElementById('orderSearchInput').value.toLowerCase().trim();
            const status = document.getElementById('filterStatus').value;
            const payment = document.getElementById('filterPayment').value;

            let filtered = dsDonHangAdmin.filter(o => {
                const matchKw = !kw ||
                    o.id.toString().includes(kw) ||
                    (o.tenKhach && o.tenKhach.toLowerCase().includes(kw)) ||
                    (o.sdt && o.sdt.includes(kw)) ||
                    (o.maVanDon && o.maVanDon.toLowerCase().includes(kw));

                const matchStatus = !status || (o.ttDon === status);
                const matchPayment = !payment || (o.ttThanhToan === payment);

                return matchKw && matchStatus && matchPayment;
            });

            renderOrderTable(filtered);
        }

        function resetOrderFilter() {
            document.getElementById('orderSearchInput').value = '';
            document.getElementById('filterStatus').value = '';
            document.getElementById('filterPayment').value = '';
            renderOrderTable(dsDonHangAdmin);
        }

        // Hộp thoại Cập nhật thông minh (Tách riêng TT Đơn + TT Thanh toán + Vận đơn + Lý do hủy)
        function capNhatTrangThai(id) {
            const o = dsDonHangAdmin.find(x => x.id == id);
            if (!o) return;

            Swal.fire({
                title: `Cập Nhật Đơn Hàng #${id}`,
                width: '550px',
                html: `
                    <div style="text-align: left; padding: 10px; font-size: 14px;">
                        <div style="margin-bottom: 12px;">
                            <label style="color:#aaa; display:block; margin-bottom:5px; font-weight:bold;">Trạng thái đơn hàng:</label>
                            <select id="swal-order-status" class="swal2-input" style="width:100%; margin:0; box-sizing:border-box;" onchange="toggleCancelReason(this.value)">
                            <option value="Chờ xác nhận" ${o.ttDon === 'Chờ xác nhận' ? 'selected' : ''}>Chờ xác nhận</option>
                            <option value="Đã xác nhận" ${o.ttDon === 'Đã xác nhận' ? 'selected' : ''}>Đã xác nhận</option>
                            <option value="Đang chuẩn bị hàng" ${o.ttDon === 'Đang chuẩn bị hàng' ? 'selected' : ''}>Đang chuẩn bị hàng</option>
                            <option value="Đang giao cho Shipper" ${o.ttDon === 'Đang giao cho Shipper' ? 'selected' : ''}>Đang giao cho Shipper</option>
                            <option value="Đã giao thành công" ${o.ttDon === 'Đã giao thành công' ? 'selected' : ''}>Đã giao thành công</option>
                            <option value="Hủy đơn hàng" ${o.ttDon === 'Hủy đơn hàng' ? 'selected' : ''}>Hủy đơn hàng</option>
                            <option value="Khách hoàn trả hàng" ${o.ttDon === 'Khách hoàn trả hàng' ? 'selected' : ''}>Khách hoàn trả hàng</option>
                        </select>
                        </div>

                        <!-- Khung nhập lý do nếu chọn Hủy -->
                        <div id="cancelReasonBox" style="display: ${o.ttDon === 'Đã hủy' ? 'block' : 'none'}; margin-bottom: 12px; background: rgba(239,35,60,0.1); padding: 10px; border-radius: 4px; border: 1px solid #ef233c;">
                            <label style="color:#ef233c; display:block; margin-bottom:5px; font-weight:bold;">Lý do hủy (*):</label>
                            <select id="swal-cancel-reason" class="swal2-input" style="width:100%; margin:0; box-sizing:border-box;">
                                <option value="Khách hàng yêu cầu hủy">Khách hàng yêu cầu hủy</option>
                                <option value="Hết hàng trong kho">Hết hàng trong kho</option>
                                <option value="Không liên lạc được với khách">Không liên lạc được với khách</option>
                                <option value="Thông tin địa chỉ không chính xác">Thông tin địa chỉ không chính xác</option>
                                <option value="Khác">Lý do khác...</option>
                            </select>
                        </div>

                        <div style="margin-bottom: 12px;">
                            <label style="color:#aaa; display:block; margin-bottom:5px; font-weight:bold;">Trạng thái thanh toán:</label>
                            <select id="swal-payment-status" class="swal2-input" style="width:100%; margin:0; box-sizing:border-box;">
                                <option value="Chưa thanh toán" ${o.ttThanhToan === 'Chưa thanh toán' ? 'selected' : ''}>Chưa thanh toán</option>
                                <option value="Đã thanh toán" ${o.ttThanhToan === 'Đã thanh toán' ? 'selected' : ''}>Đã thanh toán</option>
                                <option value="Đã hoàn tiền" ${o.ttThanhToan === 'Đã hoàn tiền' ? 'selected' : ''}>Đã hoàn tiền</option>
                            </select>
                        </div>

                        <div style="display:flex; gap:10px; margin-bottom: 12px;">
                            <div style="flex:1;">
                                <label style="color:#aaa; display:block; margin-bottom:5px; font-weight:bold;">Đơn vị vận chuyển:</label>
                                <input type="text" id="swal-carrier" class="swal2-input" placeholder="GHN, ViettelPost, J&T..." value="${o.donViVanChuyen || ''}" style="width:100%; margin:0; box-sizing:border-box;">
                            </div>
                            <div style="flex:1;">
                                <label style="color:#aaa; display:block; margin-bottom:5px; font-weight:bold;">Mã vận đơn:</label>
                                <input type="text" id="swal-tracking" class="swal2-input" placeholder="Nhập mã vận đơn..." value="${o.maVanDon || ''}" style="width:100%; margin:0; box-sizing:border-box;">
                            </div>
                        </div>
                    </div>
                `,
                showCancelButton: true,
                confirmButtonText: 'Lưu Cập Nhật',
                cancelButtonText: 'Hủy',
                confirmButtonColor: '#ffb703',
                preConfirm: () => {
                    const st = document.getElementById('swal-order-status').value;
                    const reason = document.getElementById('swal-cancel-reason').value;
                    return {
                        trangThai: st,
                        trangThaiThanhToan: document.getElementById('swal-payment-status').value,
                        donViVanChuyen: document.getElementById('swal-carrier').value.trim(),
                        maVanDon: document.getElementById('swal-tracking').value.trim(),
                        lyDoHuy: (st === 'Đã hủy') ? reason : ''
                    };
                }
            }).then(async (result) => {
                if (result.isConfirmed) {
                    const data = result.value;
                    const form = new URLSearchParams();
                    form.append('id', id);
                    form.append('trangThai', data.trangThai);
                    form.append('trangThaiThanhToan', data.trangThaiThanhToan);
                    form.append('donViVanChuyen', data.donViVanChuyen);
                    form.append('maVanDon', data.maVanDon);
                    form.append('lyDoHuy', data.lyDoHuy);

                    try {
                        const res = await fetch('/api/CapNhatDonHangApi.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: form.toString()
                        });
                        const json = await res.json();
                        if (json.success) {
                            Swal.fire({ icon: 'success', title: json.message, toast: true, position: 'top-end', timer: 1800, showConfirmButton: false });
                            loadOrders();
                        } else {
                            Swal.fire('Thao tác không hợp lệ', json.message, 'warning');
                        }
                    } catch (e) {
                        Swal.fire('Lỗi kết nối', '', 'error');
                    }
                }
            });
        }

        function toggleCancelReason(val) {
            const box = document.getElementById('cancelReasonBox');
            if (box) {
                box.style.display = (val === 'Hủy đơn hàng' || val === 'Đã hủy') ? 'block' : 'none';
            }
        }

        // Hộp thoại Xem chi tiết dạng Hóa đơn hoàn chỉnh
        async function xemChiTiet(id) {
            const o = dsDonHangAdmin.find(x => x.id == id);
            try {
                const res = await fetch('/api/ChiTietDonHangApi.ashx?id=' + id);
                const json = await res.json();

                if (json.success) {
                    let itemsHtml = (json.data || []).map(item => `
                        <tr style="border-bottom: 1px solid #333;">
                            <td style="padding:10px; display:flex; align-items:center; gap:10px;">
                                <img src="${item.hinhAnh}" onerror="this.src='images/anh_dai_dien.jpg'" style="width:40px; height:40px; object-fit:cover; border-radius:4px; background:#fff;">
                                <span style="font-size:14px; font-weight:500;">${item.tenSP}</span>
                            </td>
                            <td style="padding:10px; text-align:center;">${item.soLuong}</td>
                            <td style="padding:10px; text-align:right; color:#ccc;">${item.donGia.toLocaleString('vi-VN')} ₫</td>
                            <td style="padding:10px; text-align:right; color:#26aa99; font-weight:bold;">${item.thanhTien.toLocaleString('vi-VN')} ₫</td>
                        </tr>
                    `).join('');

                    let modalHtml = `
                        <div style="text-align:left; color:#fff; font-size:13px; line-height:1.6;">
                            <!-- Header đơn -->
                            <div style="display:flex; justify-content:space-between; background:#252525; padding:12px; border-radius:6px; margin-bottom:15px;">
                                <div>
                                    <div style="font-size:15px; font-weight:bold; color:#ee4d2d;">MÃ ĐƠN: #${id}</div>
                                    <div style="color:#aaa;">Ngày đặt: ${o.ngay}</div>
                                </div>
                                <div style="text-align:right;">
                                    <div>ĐVVC: <b>${o.donViVanChuyen || 'Tiêu chuẩn'}</b></div>
                                    <div>Mã vận đơn: <b style="color:#219ebc;">${o.maVanDon || 'Chưa cấp'}</b></div>
                                </div>
                            </div>

                            <!-- Khách hàng -->
                            <div style="margin-bottom:15px; background:#222; padding:10px; border-radius:6px;">
                                <div><b>Người nhận:</b> ${o.tenKhach} (📞 ${o.sdt || 'Không có'})</div>
                                <div><b>Địa chỉ giao hàng:</b> ${o.diaChi || 'Nhận tại cửa hàng'}</div>
                                ${o.lyDoHuy ? `<div style="color:#ef233c; margin-top:5px;"><b>Lý do hủy đơn:</b> ${o.lyDoHuy}</div>` : ''}
                            </div>

                            <!-- Bảng sản phẩm -->
                            <table style="width:100%; border-collapse:collapse; margin-bottom:15px;">
                                <thead>
                                    <tr style="border-bottom:2px solid #444; color:#aaa; font-size:12px;">
                                        <th style="padding:8px; text-align:left;">Sản phẩm</th>
                                        <th style="padding:8px; text-align:center;">SL</th>
                                        <th style="padding:8px; text-align:right;">Đơn giá</th>
                                        <th style="padding:8px; text-align:right;">Thành tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${itemsHtml}
                                </tbody>
                            </table>

                            <!-- Tổng hóa đơn -->
                            <div style="border-top:1px dashed #555; padding-top:10px; text-align:right;">
                                ${o.giamGia ? `<div style="font-size:13px; color:#4ade80;">Giảm giá${o.maGiamGia ? ' (' + o.maGiamGia + ')' : ''}: -${o.giamGia.toLocaleString('vi-VN')} ₫</div>` : ''}
                                <div style="font-size:16px; margin-top:5px;">
                                    Tổng thanh toán: <span style="font-size:20px; font-weight:bold; color:#ee4d2d;">${(o.tongTien || 0).toLocaleString('vi-VN')} ₫</span>
                                </div>
                                <div style="color:#aaa; font-size:12px; margin-top:3px;">
                                    Phương thức: ${o.ptThanhToan || 'Tiền mặt'} (${o.ttThanhToan || 'Chưa thanh toán'})
                                </div>
                            </div>
                        </div>
                    `;

                    Swal.fire({
                        title: 'Chi Tiết Đơn Hàng',
                        html: modalHtml,
                        width: '700px',
                        background: '#1a1a1a',
                        confirmButtonText: 'Đóng',
                        confirmButtonColor: '#3b82f6'
                    });
                }
            } catch (e) {
                Swal.fire('Lỗi', 'Không kết nối được tới máy chủ', 'error');
            }
        }

        async function loadThongKe() {
            try {
                const res = await fetch('/api/ThongKeApi.ashx');
                const json = await res.json();
                if (json.success) {
                    document.getElementById('stat-tong').textContent = json.data.tongDon;
                    document.getElementById('stat-giao').textContent = json.data.daGiao;
                    document.getElementById('stat-huy').textContent = json.data.daHuy;
                    document.getElementById('stat-tra').textContent = json.data.hoanTra;
                    document.getElementById('stat-tien').textContent = json.data.doanhThu.toLocaleString('vi-VN') + ' ₫';
                }
            } catch (e) {
                console.log("Lỗi tải thống kê:", e);
            }
        }

        // ==========================================
        // 5b. QUẢN LÝ DÒNG XE
        // ==========================================
        let dsDongXeBang = [];

        async function loadDongXe() {
            const tbody = document.getElementById('dongXeTableBody');
            try {
                const res = await fetch('/api/QuanLyDongXeApi.ashx?action=get');
                const json = await res.json();
                if (!json.success) { tbody.innerHTML = `<tr><td colspan="6" style="color:#ef233c; text-align:center;">${json.message}</td></tr>`; return; }
                dsDongXeBang = json.data;
                dsDongXeAdmin = json.data;
                if (!json.data.length) { tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:25px; color:#888;">Chưa có dòng xe nào.</td></tr>'; return; }
                tbody.innerHTML = json.data.map(x => `
                    <tr>
                        <td style="font-weight:bold;">#${x.id}</td>
                        <td style="color:#fff;">${x.hangXe || ''}</td>
                        <td style="color:#fff;">${x.tenXe || ''}</td>
                        <td>${x.doiXe || '—'}</td>
                        <td style="text-align:center; color:#219ebc; font-weight:bold;">${x.count}</td>
                        <td style="text-align:center;">
                            <button class="btn-action btn-edit" onclick="suaDongXe(${x.id})">Sửa</button>
                            <button class="btn-action btn-delete" onclick="xoaDongXe(${x.id}, '${(x.hangXe + ' ' + x.tenXe).replace(/'/g, "\\'")}')">Xóa</button>
                        </td>
                    </tr>`).join('');
            } catch (e) { tbody.innerHTML = '<tr><td colspan="6" style="color:#ef233c; text-align:center;">Lỗi kết nối API dòng xe!</td></tr>'; }
        }

        function formDongXe(x) {
            x = x || {};
            const esc = s => (s == null ? '' : String(s).replace(/"/g, '&quot;'));
            return `
                <div style="text-align:left; padding:5px;" class="swal-wide-html">
                    <div class="row"><div><label>Hãng xe (*):</label><input id="dx-hang" type="text" value="${esc(x.hangXe)}" placeholder="VD: Honda"></div></div>
                    <div class="row"><div><label>Tên dòng xe (*):</label><input id="dx-ten" type="text" value="${esc(x.tenXe)}" placeholder="VD: Wave Alpha"></div></div>
                    <div class="row"><div><label>Đời xe (năm):</label><input id="dx-doi" type="number" value="${x.doiXe || ''}" placeholder="VD: 2023"></div></div>
                </div>`;
        }

        function themDongXe() {
            Swal.fire({
                title: 'Thêm Dòng Xe', width: '480px', html: formDongXe(null),
                showCancelButton: true, confirmButtonText: 'Thêm', cancelButtonText: 'Hủy', confirmButtonColor: '#26aa99',
                preConfirm: () => {
                    if (!document.getElementById('dx-hang').value.trim() || !document.getElementById('dx-ten').value.trim()) {
                        Swal.showValidationMessage('Vui lòng nhập Hãng xe và Tên xe!'); return false;
                    }
                    return true;
                }
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                const fd = new URLSearchParams();
                fd.append('action', 'add');
                fd.append('hangXe', document.getElementById('dx-hang').value.trim());
                fd.append('tenXe', document.getElementById('dx-ten').value.trim());
                fd.append('doiXe', document.getElementById('dx-doi').value);
                await guiFormDongXe(fd);
            });
        }

        function suaDongXe(id) {
            const x = dsDongXeBang.find(t => t.id === id);
            if (!x) return;
            Swal.fire({
                title: 'Sửa Dòng Xe #' + id, width: '480px', html: formDongXe(x),
                showCancelButton: true, confirmButtonText: 'Lưu', cancelButtonText: 'Hủy', confirmButtonColor: '#26aa99',
                preConfirm: () => {
                    if (!document.getElementById('dx-hang').value.trim() || !document.getElementById('dx-ten').value.trim()) {
                        Swal.showValidationMessage('Vui lòng nhập Hãng xe và Tên xe!'); return false;
                    }
                    return true;
                }
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                const fd = new URLSearchParams();
                fd.append('action', 'update');
                fd.append('id', id);
                fd.append('hangXe', document.getElementById('dx-hang').value.trim());
                fd.append('tenXe', document.getElementById('dx-ten').value.trim());
                fd.append('doiXe', document.getElementById('dx-doi').value);
                await guiFormDongXe(fd);
            });
        }

        async function guiFormDongXe(fd) {
            try {
                const res = await fetch('/api/QuanLyDongXeApi.ashx', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: fd.toString() });
                const json = await res.json();
                if (json.success) { toastOK(json.message); dsDongXeAdmin = []; loadDongXe(); }
                else Swal.fire('Thất bại', json.message, 'error');
            } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
        }

        function xoaDongXe(id, ten) {
            Swal.fire({
                title: 'Xóa dòng xe?', text: 'Bạn muốn xóa: ' + ten, icon: 'warning',
                showCancelButton: true, confirmButtonColor: '#ef233c', confirmButtonText: 'Xóa', cancelButtonText: 'Hủy'
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                try {
                    const res = await fetch('/api/QuanLyDongXeApi.ashx?action=delete&id=' + id, { method: 'POST' });
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); dsDongXeAdmin = []; loadDongXe(); }
                    else Swal.fire('Không thể xóa', json.message, 'error');
                } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
            });
        }

        // ==========================================
        // 5c. QUẢN LÝ KHUYẾN MÃI
        // ==========================================
        let dsKhuyenMai = [];

        async function loadKhuyenMai() {
            const tbody = document.getElementById('khuyenMaiTableBody');
            try {
                const res = await fetch('/api/QuanLyKhuyenMaiApi.ashx?action=get');
                const json = await res.json();
                if (!json.success) { tbody.innerHTML = `<tr><td colspan="8" style="color:#ef233c; text-align:center;">${json.message}</td></tr>`; return; }
                dsKhuyenMai = json.data;
                if (!json.data.length) { tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; padding:25px; color:#888;">Chưa có mã giảm giá nào.</td></tr>'; return; }
                tbody.innerHTML = json.data.map(m => {
                    const loai = m.loaiGiam === 'PhanTram' ? '%' : '₫';
                    const giaTri = m.loaiGiam === 'PhanTram' ? m.giaTri + '%' : Number(m.giaTri).toLocaleString('vi-VN') + ' ₫';
                    const conLai = m.soLuong == null ? '∞' : Math.max(0, m.soLuong - m.daDung);
                    return `
                    <tr>
                        <td style="font-weight:bold; color:#ffb703;">${m.code}<div style="font-size:12px;color:#888;">${m.name}</div></td>
                        <td>${m.loaiGiam === 'PhanTram' ? 'Phần trăm' : 'Số tiền'}</td>
                        <td style="color:#ee4d2d; font-weight:bold;">${giaTri}</td>
                        <td>${Number(m.donHangToiThieu || 0).toLocaleString('vi-VN')} ₫</td>
                        <td>${m.daDung}/${m.soLuong == null ? '∞' : m.soLuong} <span style="color:#888;">(còn ${conLai})</span></td>
                        <td style="font-size:12px;">${m.ngayBatDau || '—'} → ${m.ngayKetThuc || '—'}</td>
                        <td style="text-align:center;">${m.trangThai
                            ? '<span class="status-badge status-active">Đang bật</span>'
                            : '<span class="status-badge status-locked">Đã tắt</span>'}</td>
                        <td style="text-align:center;">
                            <button class="btn-action btn-edit" onclick="suaKhuyenMai(${m.id})">Sửa</button>
                            <button class="btn-action" style="background:#6c757d;" onclick="toggleKhuyenMai(${m.id})">${m.trangThai ? 'Tắt' : 'Bật'}</button>
                            <button class="btn-action btn-delete" onclick="xoaKhuyenMai(${m.id}, '${(m.code||'').replace(/'/g, "\\'")}')">Xóa</button>
                        </td>
                    </tr>`;
                }).join('');
            } catch (e) { tbody.innerHTML = '<tr><td colspan="8" style="color:#ef233c; text-align:center;">Lỗi kết nối API khuyến mãi!</td></tr>'; }
        }

        function formKhuyenMai(m) {
            m = m || {};
            const esc = s => (s == null ? '' : String(s).replace(/"/g, '&quot;'));
            const selPT = m.loaiGiam === 'PhanTram' ? 'selected' : '';
            const selTien = m.loaiGiam === 'SoTien' ? 'selected' : '';
            return `
                <div style="text-align:left; padding:5px;" class="swal-wide-html">
                    <div class="row">
                        <div><label>Mã code (*):</label><input id="km-code" type="text" value="${esc(m.code)}" placeholder="VD: GIAM20"></div>
                        <div><label>Tên khuyến mãi (*):</label><input id="km-name" type="text" value="${esc(m.name)}" placeholder="VD: Giảm 20%"></div>
                    </div>
                    <div class="row">
                        <div><label>Loại giảm:</label><select id="km-loai"><option value="PhanTram" ${selPT}>Phần trăm (%)</option><option value="SoTien" ${selTien}>Số tiền (₫)</option></select></div>
                        <div><label>Giá trị:</label><input id="km-giatri" type="number" value="${m.giaTri || ''}"></div>
                        <div><label>Giảm tối đa (₫):</label><input id="km-max" type="number" value="${m.giamToiDa || ''}"></div>
                    </div>
                    <div class="row">
                        <div><label>Đơn tối thiểu (₫):</label><input id="km-min" type="number" value="${m.donHangToiThieu || 0}"></div>
                        <div><label>Số lượng (để trống = ∞):</label><input id="km-sl" type="number" value="${m.soLuong == null ? '' : m.soLuong}"></div>
                    </div>
                    <div class="row">
                        <div><label>Ngày bắt đầu:</label><input id="km-bd" type="date" value="${m.ngayBatDau || ''}"></div>
                        <div><label>Ngày kết thúc:</label><input id="km-kt" type="date" value="${m.ngayKetThuc || ''}"></div>
                    </div>
                    <div class="row" style="background:#f8f9fa; padding:10px; border-radius:6px; border:1px solid #ddd;">
                        <label style="font-weight:bold;"><input type="checkbox" id="km-tt" ${(m.id && !m.trangThai) ? '' : 'checked'}> Kích hoạt</label>
                    </div>
                </div>`;
        }

        function docFormKhuyenMai(id) {
            const fd = new URLSearchParams();
            if (id) { fd.append('action', 'update'); fd.append('id', id); } else { fd.append('action', 'add'); }
            fd.append('code', document.getElementById('km-code').value.trim());
            fd.append('name', document.getElementById('km-name').value.trim());
            fd.append('loaiGiam', document.getElementById('km-loai').value);
            fd.append('giaTri', document.getElementById('km-giatri').value);
            fd.append('giamToiDa', document.getElementById('km-max').value);
            fd.append('donHangToiThieu', document.getElementById('km-min').value);
            fd.append('soLuong', document.getElementById('km-sl').value);
            fd.append('ngayBatDau', document.getElementById('km-bd').value);
            fd.append('ngayKetThuc', document.getElementById('km-kt').value);
            fd.append('trangThai', document.getElementById('km-tt').checked);
            return fd;
        }

        async function guiFormKhuyenMai(fd) {
            try {
                const res = await fetch('/api/QuanLyKhuyenMaiApi.ashx', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: fd.toString() });
                const json = await res.json();
                if (json.success) { toastOK(json.message); loadKhuyenMai(); }
                else Swal.fire('Thất bại', json.message, 'error');
            } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
        }

        function themMaGiamGia() {
            Swal.fire({
                title: 'Thêm Mã Giảm Giá', width: '620px', html: formKhuyenMai(null),
                showCancelButton: true, confirmButtonText: 'Thêm', cancelButtonText: 'Hủy', confirmButtonColor: '#26aa99',
                preConfirm: () => {
                    if (!document.getElementById('km-code').value.trim() || !document.getElementById('km-name').value.trim()) {
                        Swal.showValidationMessage('Vui lòng nhập Mã và Tên khuyến mãi!'); return false;
                    }
                    return true;
                }
            }).then(r => { if (r.isConfirmed) guiFormKhuyenMai(docFormKhuyenMai(null)); });
        }

        function suaKhuyenMai(id) {
            const m = dsKhuyenMai.find(t => t.id === id);
            if (!m) return;
            Swal.fire({
                title: 'Sửa Mã Giảm Giá #' + id, width: '620px', html: formKhuyenMai(m),
                showCancelButton: true, confirmButtonText: 'Lưu', cancelButtonText: 'Hủy', confirmButtonColor: '#26aa99',
                preConfirm: () => {
                    if (!document.getElementById('km-code').value.trim() || !document.getElementById('km-name').value.trim()) {
                        Swal.showValidationMessage('Vui lòng nhập Mã và Tên khuyến mãi!'); return false;
                    }
                    return true;
                }
            }).then(r => { if (r.isConfirmed) guiFormKhuyenMai(docFormKhuyenMai(id)); });
        }

        async function toggleKhuyenMai(id) {
            const fd = new URLSearchParams(); fd.append('action', 'toggle'); fd.append('id', id);
            await guiFormKhuyenMai(fd);
        }

        function xoaKhuyenMai(id, code) {
            Swal.fire({
                title: 'Xóa mã giảm giá?', text: 'Bạn muốn xóa mã: ' + code, icon: 'warning',
                showCancelButton: true, confirmButtonColor: '#ef233c', confirmButtonText: 'Xóa', cancelButtonText: 'Hủy'
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                try {
                    const res = await fetch('/api/QuanLyKhuyenMaiApi.ashx?action=delete&id=' + id, { method: 'POST' });
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); loadKhuyenMai(); }
                    else Swal.fire('Thất bại', json.message, 'error');
                } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
            });
        }

        // ==========================================
        // 5d. QUẢN LÝ KHO
        // ==========================================
        let dsSanPhamKho = [];

        async function loadPhieuKho() {
            const tbody = document.getElementById('khoTableBody');
            try {
                if (!dsSanPhamKho.length) {
                    const r0 = await fetch('/api/QuanLyKhoApi.ashx?action=get');
                    const j0 = await r0.json();
                    if (j0.success) dsSanPhamKho = j0.data;
                }
                const res = await fetch('/api/QuanLyKhoApi.ashx?action=history');
                const json = await res.json();
                if (!json.success) { tbody.innerHTML = `<tr><td colspan="8" style="color:#ef233c; text-align:center;">${json.message}</td></tr>`; return; }
                const loai = document.getElementById('khoFilterLoai').value;
                const data = loai ? json.data.filter(x => x.loaiPhieu === loai) : json.data;
                if (!data.length) { tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; padding:25px; color:#888;">Chưa có phiếu kho nào.</td></tr>'; return; }
                tbody.innerHTML = data.map(p => {
                    const badge = p.loaiPhieu === 'Nhap' ? 'status-success' : (p.loaiPhieu === 'Xuat' ? 'status-cancel' : 'status-shipping');
                    const ten = p.loaiPhieu === 'Nhap' ? 'Nhập' : (p.loaiPhieu === 'Xuat' ? 'Xuất' : 'Điều chỉnh');
                    return `
                    <tr>
                        <td style="font-weight:bold;">#${p.id}</td>
                        <td style="color:#fff;">${p.sanPham}</td>
                        <td><span class="status-badge ${badge}">${ten}</span></td>
                        <td style="font-weight:bold;">${p.soLuong}</td>
                        <td>${p.truoc} → <b style="color:#26aa99;">${p.sau}</b></td>
                        <td>${p.lyDo || '—'}<div style="font-size:12px;color:#888;">${p.ghiChu || ''}</div></td>
                        <td>${p.nguoiThucHien}</td>
                        <td style="font-size:12px;">${p.thoiGian}</td>
                    </tr>`;
                }).join('');
            } catch (e) { tbody.innerHTML = '<tr><td colspan="8" style="color:#ef233c; text-align:center;">Lỗi kết nối API kho!</td></tr>'; }
        }

        async function taoPhieuKho() {
            if (!dsSanPhamKho.length) {
                try {
                    const r0 = await fetch('/api/QuanLyKhoApi.ashx?action=get');
                    const j0 = await r0.json();
                    if (j0.success) dsSanPhamKho = j0.data;
                } catch (e) { }
            }
            if (!dsSanPhamKho.length) { Swal.fire('Thông báo', 'Chưa có sản phẩm nào để lập phiếu.', 'info'); return; }
            const options = dsSanPhamKho.map(x => `<option value="${x.id}">#${x.id} - ${x.name} (tồn: ${x.stock})</option>`).join('');
            Swal.fire({
                title: 'Tạo Phiếu Kho', width: '520px',
                html: `
                <div style="text-align:left; padding:5px;" class="swal-wide-html">
                    <div class="row"><div><label>Sản phẩm (*):</label><select id="pk-sp">${options}</select></div></div>
                    <div class="row">
                        <div><label>Loại phiếu:</label><select id="pk-loai"><option value="Nhap">Nhập kho (+)</option><option value="Xuat">Xuất kho (-)</option><option value="DieuChinh">Điều chỉnh (đặt lại)</option></select></div>
                        <div><label>Số lượng (*):</label><input id="pk-sl" type="number" value="1"></div>
                    </div>
                    <div class="row"><div><label>Lý do:</label><input id="pk-lydo" type="text" placeholder="VD: Nhập hàng nhà cung cấp"></div></div>
                    <div class="row"><div><label>Ghi chú:</label><input id="pk-ghichu" type="text" placeholder="Tùy chọn"></div></div>
                </div>`,
                showCancelButton: true, confirmButtonText: 'Lưu phiếu', cancelButtonText: 'Hủy', confirmButtonColor: '#26aa99',
                preConfirm: () => {
                    const sl = parseInt(document.getElementById('pk-sl').value, 10);
                    if (!sl || sl <= 0) { Swal.showValidationMessage('Số lượng phải lớn hơn 0!'); return false; }
                    return true;
                }
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                const fd = new URLSearchParams();
                fd.append('action', 'adjust');
                fd.append('maLinhKien', document.getElementById('pk-sp').value);
                fd.append('loaiPhieu', document.getElementById('pk-loai').value);
                fd.append('soLuong', document.getElementById('pk-sl').value);
                fd.append('lyDo', document.getElementById('pk-lydo').value);
                fd.append('ghiChu', document.getElementById('pk-ghichu').value);
                try {
                    const res = await fetch('/api/QuanLyKhoApi.ashx', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: fd.toString() });
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); dsSanPhamKho = []; loadPhieuKho(); }
                    else Swal.fire('Thất bại', json.message, 'error');
                } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
            });
        }

        // ==========================================
        // 5e. QUẢN LÝ ĐÁNH GIÁ
        // ==========================================
        let dsDanhGiaAdmin = [];

        async function loadDanhGiaAdmin() {
            const tbody = document.getElementById('danhGiaTableBody');
            try {
                const res = await fetch('/api/QuanLyDanhGiaApi.ashx?action=get');
                const json = await res.json();
                if (!json.success) { tbody.innerHTML = `<tr><td colspan="7" style="color:#ef233c; text-align:center;">${json.message}</td></tr>`; return; }
                dsDanhGiaAdmin = json.data;
                // Nạp combobox sản phẩm (nếu chưa)
                const sel = document.getElementById('dgFilterSP');
                if (sel.options.length <= 1) {
                    const mapSP = {};
                    json.data.forEach(d => { mapSP[d.maLinhKien] = d.sanPham; });
                    Object.keys(mapSP).forEach(k => {
                        const o = document.createElement('option'); o.value = k; o.textContent = '#' + k + ' - ' + mapSP[k]; sel.appendChild(o);
                    });
                }
                renderDanhGiaAdmin();
            } catch (e) { tbody.innerHTML = '<tr><td colspan="7" style="color:#ef233c; text-align:center;">Lỗi kết nối API đánh giá!</td></tr>'; }
        }

        function renderDanhGiaAdmin() {
            const tbody = document.getElementById('danhGiaTableBody');
            const sp = document.getElementById('dgFilterSP').value;
            const tt = document.getElementById('dgFilterTrangThai').value;
            let data = dsDanhGiaAdmin;
            if (sp) data = data.filter(d => String(d.maLinhKien) === String(sp));
            if (tt === 'an') data = data.filter(d => d.hidden);
            if (tt === 'hien') data = data.filter(d => !d.hidden);
            if (!data.length) { tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:25px; color:#888;">Không có đánh giá phù hợp.</td></tr>'; return; }
            tbody.innerHTML = data.map(d => `
                <tr ${d.hidden ? 'style="opacity:0.6;"' : ''}>
                    <td style="font-weight:bold;">#${d.id}</td>
                    <td>${d.sanPham || '—'}<div style="font-size:12px;color:#888;">#${d.maLinhKien}</div></td>
                    <td>${d.khachHang || '—'}<div style="font-size:12px;color:#888;">@${d.username || ''}</div></td>
                    <td style="text-align:center; color:#ffb703;">${'★'.repeat(d.soSao || 0)}</td>
                    <td style="max-width:280px;">${(d.noiDung || '').replace(/</g, '&lt;')}</td>
                    <td style="font-size:12px;">${d.ngay}</td>
                    <td style="text-align:center;">
                        ${d.hidden
                            ? `<button class="btn-action" style="background:#26aa99;" onclick="doiTrangThaiDanhGia(${d.id}, true)">Hiện</button>`
                            : `<button class="btn-action" style="background:#6c757d;" onclick="doiTrangThaiDanhGia(${d.id}, false)">Ẩn</button>`}
                        <button class="btn-action btn-delete" onclick="xoaDanhGia(${d.id})">Xóa</button>
                    </td>
                </tr>`).join('');
        }

        function doiTrangThaiDanhGia(id, isUnhide) {
            if (isUnhide) {
                guiDanhGia('unhide', id);
            } else {
                Swal.fire({
                    title: 'Ẩn đánh giá?', input: 'text', inputPlaceholder: 'Lý do ẩn (không bắt buộc)', icon: 'warning',
                    showCancelButton: true, confirmButtonText: 'Ẩn', cancelButtonText: 'Hủy', confirmButtonColor: '#ef233c'
                }).then(async (r) => {
                    if (!r.isConfirmed) return;
                    const fd = new URLSearchParams();
                    fd.append('action', 'hide'); fd.append('id', id); fd.append('lyDo', r.value || '');
                    await guiDanhGiaFd(fd);
                });
            }
        }

        async function guiDanhGia(action, id) {
            const fd = new URLSearchParams();
            fd.append('action', action); fd.append('id', id);
            await guiDanhGiaFd(fd);
        }

        async function guiDanhGiaFd(fd) {
            try {
                const res = await fetch('/api/QuanLyDanhGiaApi.ashx', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: fd.toString() });
                const json = await res.json();
                if (json.success) { toastOK(json.message); loadDanhGiaAdmin(); }
                else Swal.fire('Thất bại', json.message, 'error');
            } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
        }

        function xoaDanhGia(id) {
            Swal.fire({
                title: 'Xóa đánh giá?', text: 'Đánh giá sẽ bị xóa vĩnh viễn.', icon: 'warning',
                showCancelButton: true, confirmButtonColor: '#ef233c', confirmButtonText: 'Xóa', cancelButtonText: 'Hủy'
            }).then(async (r) => {
                if (!r.isConfirmed) return;
                try {
                    const res = await fetch('/api/QuanLyDanhGiaApi.ashx?action=delete&id=' + id, { method: 'POST' });
                    const json = await res.json();
                    if (json.success) { toastOK(json.message); loadDanhGiaAdmin(); }
                    else Swal.fire('Thất bại', json.message, 'error');
                } catch (e) { Swal.fire('Lỗi mạng', 'Không kết nối được', 'error'); }
            });
        }

        // ==========================================
        // 5f. THỐNG KÊ CHI TIẾT
        // ==========================================
        async function loadThongKeChiTiet() {
            const from = document.getElementById('tkFrom').value;
            const to = document.getElementById('tkTo').value;
            let qs = '';
            if (from) qs += (qs ? '&' : '?') + 'from=' + from;
            if (to) qs += (qs ? '&' : '?') + 'to=' + to;
            try {
                const res = await fetch('/api/ThongKeApi.ashx' + qs);
                const json = await res.json();
                if (!json.success) return;
                const d = json.data;
                document.getElementById('tk-tong').textContent = d.tongDon;
                document.getElementById('tk-giao').textContent = d.daGiao;
                document.getElementById('tk-huy').textContent = d.daHuy;
                document.getElementById('tk-tra').textContent = d.hoanTra;
                document.getElementById('tk-tien').textContent = Number(d.doanhThu).toLocaleString('vi-VN') + ' ₫';
                document.getElementById('tk-chart-title').textContent = 'Doanh thu theo ngày (' + d.tuNgay + ' → ' + d.denNgay + ')';
                renderTKChart(d.doanhThuTheoNgay);
                document.getElementById('tkTopSP').innerHTML = (d.topSanPham || []).map(x =>
                    `<tr><td>${x.ten}</td><td style="text-align:center;">${x.soLuong}</td><td style="text-align:right; color:#ffb703;">${Number(x.doanhThu).toLocaleString('vi-VN')} ₫</td></tr>`
                ).join('') || '<tr><td colspan="3" style="color:#888; text-align:center;">Chưa có dữ liệu</td></tr>';
                document.getElementById('tkTopKH').innerHTML = (d.topKhachHang || []).map(x =>
                    `<tr><td>${x.ten}</td><td style="text-align:center;">${x.soDon}</td><td style="text-align:right; color:#ffb703;">${Number(x.chiTieu).toLocaleString('vi-VN')} ₫</td></tr>`
                ).join('') || '<tr><td colspan="3" style="color:#888; text-align:center;">Chưa có dữ liệu</td></tr>';
            } catch (e) { console.log('Lỗi tải thống kê:', e); }
        }

        function renderTKChart(data) {
            const wrap = document.getElementById('tkChart');
            if (!data || !data.length) { wrap.innerHTML = '<div style="width:100%; text-align:center; color:#888; align-self:center;">Chưa có dữ liệu doanh thu trong khoảng này.</div>'; return; }
            const max = Math.max.apply(null, data.map(x => Number(x.tien) || 0)) || 1;
            wrap.innerHTML = data.map(x => {
                const h = Math.max(2, Math.round((Number(x.tien) || 0) / max * 170));
                return `<div class="chart-col" title="${x.ngay}: ${Number(x.tien).toLocaleString('vi-VN')} ₫">
                            <div class="val">${Number(x.tien) >= 1000000 ? (Math.round(Number(x.tien) / 1000)) + 'k' : ''}</div>
                            <div class="bar" style="height:${h}px;"></div>
                            <div class="lbl">${x.ngay}</div>
                        </div>`;
            }).join('');
        }

        // ==========================================
        // 5g. NHẬT KÝ HỆ THỐNG
        // ==========================================
        async function loadNhatKy() {
            const tbody = document.getElementById('nhatKyTableBody');
            const kw = document.getElementById('nkSearch').value.trim();
            try {
                const res = await fetch('/api/NhatKyApi.ashx' + (kw ? '?kw=' + encodeURIComponent(kw) : ''));
                const json = await res.json();
                if (!json.success) { tbody.innerHTML = `<tr><td colspan="6" style="color:#ef233c; text-align:center;">${json.message}</td></tr>`; return; }
                if (!json.data.length) { tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:25px; color:#888;">Không có bản ghi nhật ký nào.</td></tr>'; return; }
                tbody.innerHTML = json.data.map(n => `
                    <tr>
                        <td style="font-weight:bold;">#${n.id}</td>
                        <td style="font-size:12px;">${n.thoiGian}</td>
                        <td style="color:#fff;">${n.nguoiDung}<div style="font-size:11px;color:#888;">${n.ip || ''}</div></td>
                        <td style="color:#ffb703; font-weight:bold;">${n.hanhDong}</td>
                        <td>${n.doiTuong || '—'}</td>
                        <td style="color:#bbb;">${(n.chiTiet || '').replace(/</g, '&lt;')}</td>
                    </tr>`).join('');
            } catch (e) { tbody.innerHTML = '<tr><td colspan="6" style="color:#ef233c; text-align:center;">Lỗi kết nối API nhật ký!</td></tr>'; }
        }

        // ==========================================
        // 5h. THÔNG BÁO ĐƠN HÀNG MỚI
        // ==========================================
        let soChoXacNhanTruoc = -1;

        function khoiDongThongBaoDonHang() {
            kiemTraDonHangMoi();
            setInterval(kiemTraDonHangMoi, 15000);
        }

        async function kiemTraDonHangMoi() {
            try {
                const res = await fetch('/api/AdminQuanLyDonHangApi.ashx?action=pending_count');
                const json = await res.json();
                if (!json.success) return;

                const badge = document.getElementById('navOrderBadge');
                if (badge) {
                    if (json.choXacNhan > 0) { badge.textContent = json.choXacNhan > 99 ? '99+' : json.choXacNhan; badge.classList.add('show'); }
                    else { badge.classList.remove('show'); badge.textContent = '0'; }
                }

                if (soChoXacNhanTruoc >= 0 && json.choXacNhan > soChoXacNhanTruoc) {
                    Swal.fire({
                        icon: 'info', title: 'Đơn hàng mới!',
                        text: 'Có ' + json.choXacNhan + ' đơn đang chờ xác nhận.',
                        toast: true, position: 'top-end', timer: 5000, showConfirmButton: false
                    });
                }
                soChoXacNhanTruoc = json.choXacNhan;
            } catch (e) { /* im lặng khi mất kết nối tạm thời */ }
        }

        // ==========================================
        // 6. CODE QUẢN LÝ CHAT CHO ADMIN
        // ==========================================
        let activeAdminSession = null;
        let adminUserId = null;
        let adminChatInterval = null;

        async function loadAdminSessions() {
            try {
                const res = await fetch('/api/ChatApi.ashx?action=admin_get_sessions');
                const json = await res.json();
                if (json.success) {
                    renderAdminSessions(json.data);
                }
            } catch (e) { console.error(e); }
        }

        function capNhatBadgeTong(tong) {
            const badge = document.getElementById('navChatBadge');
            if (!badge) return;
            if (tong > 0) {
                badge.textContent = tong > 99 ? '99+' : tong;
                badge.classList.add('show');
            } else {
                badge.classList.remove('show');
                badge.textContent = '0';
            }
        }

        function renderAdminSessions(sessions) {
            const wrap = document.getElementById('adminSessionList');
            if (!sessions || sessions.length === 0) {
                wrap.innerHTML = '<div style="padding: 30px; text-align: center; color: #888;">Chưa có cuộc trò chuyện nào</div>';
                capNhatBadgeTong(0);
                return;
            }

            let tongChuaDoc = 0;
            let html = '';
            sessions.forEach(function(s) {
                const soChuaDoc = s.SoTinChuaDoc || 0;
                // Phiên đang mở không cần badge: người dùng đang nhìn nó.
                const hienBadge = soChuaDoc > 0 && activeAdminSession !== s.MaPhienChat;
                if (hienBadge) tongChuaDoc += soChuaDoc;
                const cls = (activeAdminSession === s.MaPhienChat ? 'active' : '') + (soChuaDoc > 0 ? ' unread' : '');
                html += '<div class="session-item ' + cls + '" data-ma-phien="' + s.MaPhienChat + '" data-ten-khach="' + escapeHtml(s.HoTen) + '">' +
                        '<div class="session-name"><span>👤</span> <span style="flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">' + escapeHtml(s.HoTen) + '</span>' +
                        (hienBadge ? '<span class="badge-chua-doc">' + soChuaDoc + '</span>' : '') + '</div>' +
                        '<div class="session-preview">' + escapeHtml(s.TinNhanCuoi) + '</div>' +
                        '<div class="session-time">' + escapeHtml(s.ThoiGianCuoi || '') + '</div></div>';
            });
            wrap.innerHTML = html;

            capNhatBadgeTong(tongChuaDoc);
            const note = document.getElementById('adminUnreadNote');
            if (note) {
                note.textContent = tongChuaDoc > 0
                    ? '🔔 ' + tongChuaDoc + ' tin nhắn đang chờ bạn trả lời'
                    : '✅ Đã xem hết tin nhắn mới';
            }

            // Cập nhật danh sách phiên mỗi 4 giây
            if (window.adminChatRefreshInterval) clearInterval(window.adminChatRefreshInterval);
            window.adminChatRefreshInterval = setInterval(loadAdminSessions, 4000);
        }

        document.getElementById('adminSessionList').addEventListener('click', function (e) {
            const item = e.target.closest('.session-item');
            if (!item) return;
            const maPhien = parseInt(item.getAttribute('data-ma-phien'), 10);
            if (isNaN(maPhien)) return;
            selectAdminSession(maPhien, item.getAttribute('data-ten-khach') || '');
        });

        async function selectAdminSession(maPhien, tenKhach) {
            activeAdminSession = maPhien;
            document.getElementById('adminChatTitle').innerText = 'Đang chat với: ' + tenKhach;
            document.getElementById('adminChatInput').disabled = false;
            document.getElementById('adminSendBtn').disabled = false;

            // Cập nhật UI active
            loadAdminSessions();
            await fetchAdminMessages();

            // Bật polling cho tin nhắn
            if (adminChatInterval) clearInterval(adminChatInterval);
            adminChatInterval = setInterval(fetchAdminMessages, 2500);
        }

        async function fetchAdminMessages() {
            if (!activeAdminSession) return;
            try {
                const res = await fetch('/api/ChatApi.ashx?action=get_messages&maPhienChat=' + activeAdminSession);
                const json = await res.json();
                if (json.success) {
                    adminUserId = json.currentUserId;
                    renderAdminMessages(json.data);
                }
            } catch (e) { console.error(e); }
        }

        function renderAdminMessages(messages) {
            const wrap = document.getElementById('adminMessagesBox');
            let html = '';
            if (!messages || messages.length === 0) {
                wrap.innerHTML = '<div class="empty-chat-state">Cuộc trò chuyện trống. Hãy gửi tin nhắn đầu tiên!</div>';
                return;
            }
            messages.forEach(function(m) {
                const isMine = m.MaNguoiGui === adminUserId;
                html += '<div class="msg-item ' + (isMine ? 'msg-mine' : 'msg-other') + '" style="max-width: 65%;">' +
                        '<div style="font-size: 11px; font-weight: bold; margin-bottom: 3px; opacity: 0.8;">' + escapeHtml(m.TenNguoiGui || 'Khách') + '</div>' +
                        '<div>' + escapeHtml(m.NoiDung) + '</div>' +
                        '<div class="msg-time">' + m.ThoiGianGui + '</div></div>';
            });
            wrap.innerHTML = html;
            wrap.scrollTop = wrap.scrollHeight;
        }

        async function sendAdminMessage() {
            const input = document.getElementById('adminChatInput');
            const text = input.value.trim();
            if (!text || !activeAdminSession) return;

            input.value = '';
            const formData = new FormData();
            formData.append('maPhienChat', activeAdminSession);
            formData.append('noiDung', text);

            try {
                await fetch('/api/ChatApi.ashx?action=send_message', { method: 'POST', body: formData });
                await fetchAdminMessages();
                await loadAdminSessions(); // Cập nhật lại danh sách
            } catch (e) { console.error(e); }
        }

        function escapeHtml(text) {
            if (!text) return '';
            return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
        }
    </script>
</body>
</html>