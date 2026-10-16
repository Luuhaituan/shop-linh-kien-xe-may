<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đơn Hàng Của Tôi | VanDonMotor</title>
    <link rel="stylesheet" href="style.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        .order-wrapper { max-width: 1000px; margin: 20px auto 60px; padding: 0; min-height: 60vh; font-family: Arial, sans-serif; }
        
        /* 1. Thanh Tabs phân loại */
        .tabs-container { display: flex; background: var(--bg-card, #1e1e1e); position: sticky; top: 0; z-index: 10; box-shadow: 0 1px 1px 0 rgba(0,0,0,.05); margin-bottom: 12px; }
        .tab-item { flex: 1; text-align: center; padding: 16px 0; cursor: pointer; color: #fff; font-size: 16px; border-bottom: 2px solid transparent; transition: 0.2s; user-select: none; }
        .tab-item:hover { color: var(--primary, #ee4d2d); }
        .tab-item.active { color: var(--primary, #ee4d2d); border-bottom-color: var(--primary, #ee4d2d); font-weight: bold; }

        /* 2. Thanh tìm kiếm */
        .search-bar { background: var(--bg-card, #1e1e1e); padding: 12px 16px; margin-bottom: 12px; display: flex; align-items: center; border-radius: 2px; }
        .search-bar svg { width: 20px; height: 20px; fill: #888; margin-right: 12px; }
        .search-bar input { flex: 1; background: transparent; border: none; color: white; outline: none; font-size: 14px; }

        /* 3. Card Đơn Hàng */
        .order-card { background: var(--bg-card, #1e1e1e); margin-bottom: 12px; border-radius: 2px; }
        
        /* Header của Card */
        .order-header { padding: 12px 24px; display: flex; justify-content: space-between; border-bottom: 1px solid #2e2e2e; align-items: center; }
        .order-header-left { display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: bold; }
        .badge-mall { background: #d0011b; color: #fff; padding: 2px 6px; font-size: 12px; border-radius: 2px; }
        .btn-chat { background: #ee4d2d; color: #fff; border: none; padding: 2px 8px; font-size: 12px; border-radius: 2px; display: flex; align-items: center; gap: 4px; cursor: pointer; }
        
        .order-header-right { display: flex; align-items: center; gap: 10px; font-size: 14px; }
        .delivery-status { color: #26aa99; display: flex; align-items: center; gap: 5px; }
        .delivery-status svg { width: 16px; height: 16px; fill: currentColor; }
        .status-text { color: #ee4d2d; text-transform: uppercase; padding-left: 10px; border-left: 1px solid #444; font-weight: bold; }

        /* Body của Card (Danh sách sản phẩm) */
        .order-item { display: flex; padding: 16px 24px; border-bottom: 1px solid #2e2e2e; }
        .item-img { width: 80px; height: 80px; border: 1px solid #333; object-fit: cover; border-radius: 4px; }
        .item-info { flex: 1; padding: 0 16px; }
        .item-name { font-size: 16px; line-height: 22px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; margin-bottom: 5px; }
        .item-variant { color: #9e9e9e; font-size: 14px; margin-bottom: 5px; }
        .item-qty { font-size: 14px; color: #ccc; }
        .item-price-wrap { text-align: right; }
        .item-price { color: #ee4d2d; font-size: 15px; font-weight: bold; }

        /* Footer của Card */
        .order-summary { background: #2a251d; padding: 24px; text-align: right; }
        .total-text { font-size: 14px; color: #fff; display: flex; justify-content: flex-end; align-items: center; margin-bottom: 16px; }
        .total-price { font-size: 24px; color: #ee4d2d; margin-left: 10px; font-weight: bold; }
        
        .order-actions { display: flex; justify-content: flex-end; gap: 10px; }
        .btn-action { padding: 8px 20px; font-size: 14px; cursor: pointer; border-radius: 2px; border: 1px solid transparent; font-weight: 500; }
        .btn-primary { background: #ee4d2d; color: #fff; }
        .btn-primary:hover { background: #d73a1c; }
        .btn-secondary { background: #242424; color: #fff; border-color: #444; }
        .btn-secondary:hover { background: #333; }

        .swal2-select {
            color: #000 !important;
            background-color: #fff !important;
        }
        .swal2-select option {
            color: #000 !important; 
            background-color: #fff !important;
        }
    </style>
</head>
<body>

    <!-- NAVBAR CHUẨN -->
    <nav class="navbar" id="navbar">
      <div class="nav-inner">
        <a href="index.aspx" class="logo">
          <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />
          <span class="brand">VanDon<span class="accent">Motor</span></span>
        </a>

        <div class="search-wrap">
          <input type="text" id="mainSearchInput" placeholder="Tìm linh kiện, phụ tùng, hãng xe..."/>
          <button class="search-btn" onclick="window.location.href='SanPham.aspx?q=' + encodeURIComponent(document.getElementById('mainSearchInput').value)">
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
          </button>
        </div>

        <div class="nav-links">
          <a href="index.aspx">Trang Chủ</a>
          <a href="SanPham.aspx">Sản Phẩm</a>
          <a href="index.aspx#danh-muc">Danh Mục</a>
        </div>

        <div class="nav-actions">
          <button class="icon-btn" title="Giỏ hàng" id="cartBtn" onclick="openCart()">
            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
            <span class="badge" id="cartBadge">0</span>
          </button>
          
          <% if (Session["User"] == null) { %>
              <a href="Dang_nhap.aspx" class="btn-login">Đăng Nhập</a>
              <a href="Dang_ky.aspx" class="btn-register" style="text-decoration:none;display:flex;align-items:center">Đăng Ký</a>
          <% } else { 
              var currentUser = Session["User"] as Ban_Linh_Kien_xe_may_1.Models.NguoiDung;
          %>
              <div class="nav-user-menu" style="display:flex;">
                <div class="user-avatar-btn" onclick="toggleUserMenu(event)">
                  <div class="user-avatar-ico">👤</div>
                  <span style="font-weight: 700;"><%= currentUser.HoTen %></span>
                  <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                </div>
                <div class="user-dropdown">
                  <a href="TaiKhoan.aspx" class="dropdown-item">👤 Tài khoản của tôi</a>
                  <a href="DonHang.aspx" class="dropdown-item">📦 Đơn hàng</a>
                  <% if (Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsStaff(currentUser.VaiTro)) { %>
                      <div class="dropdown-divider"></div>
                      <a href="Admin.aspx" class="dropdown-item">⚙️ Quản Trị Admin</a>
                  <% } %>
                  <div class="dropdown-divider"></div>
                  <a href="Dang_xuat.aspx" class="dropdown-item danger">🚪 Đăng Xuất</a>
                </div>
              </div>
          <% } %>
        </div>
      </div>
    </nav>

    <!-- NỘI DUNG ĐƠN HÀNG (SHOPEE UI) -->
    <div class="order-wrapper">

        <div style="max-width: 1000px; margin: 20px auto 0; padding: 0 20px;">
            <button class="btn-back" onclick="window.history.back()">
                <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 12H5"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 19l-7-7 7-7"></path>
                </svg>
                Quay lại
            </button>
        </div>
        
        <!-- Tabs Phân Loại: Đã đồng bộ key gọi hàm -->
        <div class="tabs-container">
            <div class="tab-item active" onclick="filterOrders('all', this)">Tất cả</div>
            <div class="tab-item" onclick="filterOrders('Chờ xác nhận', this)">Chờ xác nhận</div>
            <div class="tab-item" onclick="filterOrders('Đang giao', this)">Đang giao</div>
            <div class="tab-item" onclick="filterOrders('Hoàn thành', this)">Hoàn thành</div>
            <div class="tab-item" onclick="filterOrders('Đã hủy', this)">Đã hủy</div>
            <div class="tab-item" onclick="filterOrders('Trả hàng/Hoàn tiền', this)">Trả hàng/Hoàn tiền</div>
        </div>

        <!-- Thanh Tìm Kiếm Đơn Hàng -->
        <div class="search-bar">
            <svg viewBox="0 0 19 19"><g fill-rule="evenodd" stroke="none" stroke-width="1"><g transform="translate(-1016 -32)"><g><g transform="translate(405 21)"><g transform="translate(611 11)"><path d="m8 16c4.418278 0 8-3.581722 8-8s-3.581722-8-8-8-8 3.581722-8 8 3.581722 8 8 8zm0-2c-3.3137085 0-6-2.6862915-6-6s2.6862915-6 6-6 6 2.6862915 6 6-2.6862915 6-6 6z"></path><path d="m12.2972351 13.7114222 4.9799555 4.919354c.3929077.3881263 1.0260608.3842503 1.4141871-.0086574.3881263-.3929076.3842503-1.0260607-.0086574-1.414187l-4.9799554-4.919354c-.3929077-.3881263-1.0260608-.3842503-1.4141871.0086573-.3881263.3929077-.3842503 1.0260608.0086573 1.4141871z"></path></g></g></g></g></g></svg>
            <input type="text" id="orderSearchInput" placeholder="Bạn có thể tìm kiếm theo ID đơn hàng hoặc Tên Sản phẩm" onkeyup="searchOrders()" />
        </div>
        
        <!-- Khung chứa danh sách đơn hàng -->
        <div id="orderList">
            <div style="text-align:center; padding: 80px; color:#888;">Đang tải dữ liệu...</div>
        </div>

    </div>

    <!-- FOOTER CHUẨN -->
    <footer>
      <div class="footer-inner">
        <div class="footer-grid">
          <div class="footer-brand">
            <div class="logo">
             <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />
             <span style="font-size:20px;font-weight:900">VanDon<span style="color:var(--primary)">Motor</span></span>
            </div>
            <p class="footer-desc">Chuyên cung cấp linh kiện, phụ tùng xe máy chính hãng. Uy tín – Chất lượng – Giá tốt thị trường.</p>
          </div>
        </div>
      </div>
    </footer>

    <!-- CART SIDEBAR -->
    <div class="cart-overlay" id="cartOverlay" onclick="closeCart()"></div>
    <div class="cart-sidebar" id="cartSidebar">
      <div class="cart-header">
        <h3>🛒 Giỏ Hàng (<span id="cartCount">0</span>)</h3>
        <button class="cart-close" onclick="closeCart()">✕</button>
      </div>
      <div class="cart-items" id="cartItems"></div>
      <div class="cart-footer">
        <div class="cart-total">
          <span class="cart-total-label">Tổng cộng:</span>
          <span class="cart-total-price" id="cartTotal">0 ₫</span>
        </div>
        <button class="btn-checkout" onclick="checkout()">Tiến hành thanh toán</button>
      </div>
    </div>

    <div class="toast-wrap" id="toastWrap"></div>

    <script src="app.js"></script>
    <script>
        let allOrders = [];

        function formatTien(n) { return n ? parseInt(n).toLocaleString('vi-VN') + ' ₫' : '0 ₫'; }

        function toggleUserMenu(event) {
            event.stopPropagation();
            const dropdown = document.querySelector('.user-dropdown');
            if (dropdown) { dropdown.classList.toggle('active'); }
        }
        document.addEventListener('click', function (event) {
            const userMenu = document.querySelector('.nav-user-menu');
            const dropdown = document.querySelector('.user-dropdown');
            if (userMenu && dropdown && !userMenu.contains(event.target)) {
                dropdown.classList.remove('active');
            }
        });

        document.addEventListener("DOMContentLoaded", async () => {
            await loadOrders();
        });

        async function loadOrders() {
            try {
                const API_URL = typeof API !== 'undefined' ? API : 'api';
                const res = await fetch(`${API_URL}/DonHangApi.ashx`);
                const json = await res.json();

                if (json.message === "not_logged_in") {
                    window.location.href = 'Dang_nhap.aspx';
                    return;
                }

                if (json.success) {
                    allOrders = json.data || [];
                    renderOrders(allOrders);
                } else {
                    document.getElementById('orderList').innerHTML = `<div style="color:red; text-align:center; padding:40px;">Lỗi: ${json.message}</div>`;
                }
            } catch (error) {
                console.error("Lỗi:", error);
                document.getElementById('orderList').innerHTML = '<div style="text-align:center; padding:40px;">Không thể tải dữ liệu. Vui lòng thử lại!</div>';
            }
        }

        function renderOrders(ordersArray) {
            const wrap = document.getElementById('orderList');

            if (!ordersArray || ordersArray.length === 0) {
                wrap.innerHTML = `
                    <div style="text-align:center; padding: 100px 20px; background:var(--bg-card); border-radius:4px;">
                        <div style="font-size: 60px; margin-bottom: 20px;">📄</div>
                        <div style="font-size: 16px; color:#888; margin-bottom: 20px;">Chưa có đơn hàng trong mục này</div>
                        <button class="btn-action btn-primary" onclick="window.location.href='SanPham.aspx'">Tiếp tục mua sắm</button>
                    </div>`;
                return;
            }

            let html = '';
            ordersArray.forEach(don => {
                const ttHienThi = don.TrangThai || don.ttDon || 'Chờ xác nhận';
                const ttLower = ttHienThi.toLowerCase().trim();

                let actionButtons = '';
                // 1. Nhóm Chờ duyệt: Chờ xác nhận, Đã xác nhận, Đang chuẩn bị hàng
                if (ttLower === 'chờ xác nhận') {
                    actionButtons = `<button class="btn-action btn-secondary" onclick="huyDonHang(${don.MaDonHang})">Hủy đơn hàng</button>`;
                } else if (ttLower === 'đã xác nhận' || ttLower === 'đang chuẩn bị hàng') {
                    actionButtons = `<button class="btn-action btn-secondary" style="opacity: 0.6; cursor: not-allowed;" title="Shop đang chuẩn bị hàng, không thể tự hủy" disabled>Đang chuẩn bị</button>`;
                }
                // 2. Nhóm Đang giao
                else if (ttLower.includes('đang giao')) {
                    actionButtons = `<button class="btn-action btn-secondary" style="opacity: 0.6; cursor: not-allowed;" disabled>Đang giao hàng</button>`;
                }
                // 3. Nhóm Đã giao / Hoàn thành: Có quyền Trả hàng/Hoàn tiền và Mua Lại
                else if (ttLower.includes('đã giao') || ttLower.includes('hoàn thành')) {
                    actionButtons = `
                        <button class="btn-action btn-secondary" onclick="hoanHang(${don.MaDonHang})" style="margin-right: 10px; border-color: #ee4d2d; color: #ee4d2d;">Trả hàng/Hoàn tiền</button>
                        <button class="btn-action btn-primary" onclick="muaLai(${don.MaDonHang})">Mua Lại</button>
                    `;
                }
                // 4. Nhóm Đã hủy hoặc Hoàn trả
                else {
                    actionButtons = `<button class="btn-action btn-primary" onclick="muaLai(${don.MaDonHang})">Mua Lại</button>`;
                }

                html += `
                <div class="order-card">
                    <div class="order-header">
                        <div class="order-header-left">
                            <span class="badge-mall">Mall</span> VanDonMotor Store
                            <button class="btn-chat">💬 Chat</button>
                        </div>
                        <div class="order-header-right">
                            <div class="delivery-status" style="color: #888;">
                                <svg viewBox="0 0 16 16" style="margin-right: 4px; fill: #888;"><path d="M11.666 4.305 7.42 10.638 4.298 7.553a.5.5 0 0 0-.702.712l3.493 3.447a.5.5 0 0 0 .736-.037l4.582-6.848a.5.5 0 1 0-.83-.522z"></path></svg>
                                Ngày đặt: ${formatDate(don.NgayDat)} 
                                <span style="margin: 0 10px; color: #444;">|</span> 
                                <span style="color: #26aa99;">Mã Vận Đơn: ${don.maVanDon ? don.maVanDon : '#' + don.MaDonHang}</span>
                            </div>
                            <div class="status-text">${ttHienThi}</div>
                        </div>
                    </div>
                `;

                (don.ChiTiet || []).forEach(sp => {
                    html += `
                    <div class="order-item">
                        <img src="${sp.HinhAnh}" class="item-img" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'80\\' height=\\'80\\'%3E%3Crect width=\\'80\\' height=\\'80\\' fill=\\'%23333\\'/%3E%3C/svg%3E'"/>
                        <div class="item-info">
                            <div class="item-name">${sp.TenSP}</div>
                            <div class="item-variant">Phân loại hàng: Mặc định</div>
                            <div class="item-qty">x${sp.SoLuong}</div>
                        </div>
                        <div class="item-price-wrap">
                            <div class="item-price">${formatTien(sp.DonGia)}</div>
                        </div>
                    </div>
                    `;
                });

                html += `
                    <div class="order-summary">
                        <div class="total-text">
                            ${don.GiamGia ? `<div style="font-size:13px;color:#4ade80;margin-bottom:6px;">Giảm giá${don.MaGiamGia ? ' (' + don.MaGiamGia + ')' : ''}: -${formatTien(don.GiamGia)}</div>` : ''}
                            Thành tiền: <span class="total-price">${formatTien(don.TongTien)}</span>
                        </div>
                        <div class="order-actions">
                            ${actionButtons}
                        </div>
                    </div>
                </div>
                `;
            });

            wrap.innerHTML = html;
        }

        // HÀM LỌC GOM NHÓM CHÍNH XÁC THEO 7 TRẠNG THÁI CỦA ADMIN
        function filterOrders(tabKey, element) {
            const tabs = document.querySelectorAll('.tab-item');
            tabs.forEach(t => t.classList.remove('active'));
            if (element) element.classList.add('active');

            if (tabKey === 'all') {
                renderOrders(allOrders);
                return;
            }

            const filtered = allOrders.filter(don => {
                const st = (don.TrangThai || don.ttDon || '').toLowerCase().trim();

                switch (tabKey) {
                    case 'Chờ xác nhận':
                        return st === 'chờ xác nhận' || st === 'đã xác nhận' || st === 'đang chuẩn bị hàng';

                    case 'Đang giao':
                        return st.includes('đang giao');

                    case 'Hoàn thành':
                        return st.includes('đã giao') || st.includes('hoàn thành');

                    case 'Đã hủy':
                        return st.includes('hủy');

                    case 'Trả hàng/Hoàn tiền':
                        return st.includes('trả hàng') || st.includes('hoàn tiền') || st.includes('hoàn trả');

                    default:
                        return st.includes(tabKey.toLowerCase());
                }
            });

            document.getElementById('orderSearchInput').value = '';
            renderOrders(filtered);
        }

        function searchOrders() {
            const query = document.getElementById('orderSearchInput').value.toLowerCase().trim();
            document.querySelectorAll('.tab-item').forEach(t => t.classList.remove('active'));

            if (!query) {
                const firstTab = document.querySelector('.tab-item');
                if (firstTab) firstTab.classList.add('active');
                renderOrders(allOrders);
                return;
            }

            const filtered = allOrders.filter(don => {
                if (don.MaDonHang && don.MaDonHang.toString().includes(query)) return true;
                if (don.maVanDon && don.maVanDon.toLowerCase().includes(query)) return true;

                let matchName = false;
                (don.ChiTiet || []).forEach(sp => {
                    if (sp.TenSP && sp.TenSP.toLowerCase().includes(query)) { matchName = true; }
                });
                return matchName;
            });

            renderOrders(filtered);
        }

        async function hoanHang(maDonHang) {
            Swal.fire({
                title: 'Yêu cầu Trả hàng/Hoàn tiền',
                text: "Vui lòng chọn lý do hoàn trả:",
                input: 'select',
                inputOptions: {
                    'Lỗi kỹ thuật': 'Sản phẩm bị lỗi kỹ thuật/hỏng hóc',
                    'Giao sai hàng': 'Shop giao sai sản phẩm/phân loại',
                    'Thiếu hàng': 'Đơn hàng bị giao thiếu',
                    'Khác': 'Lý do khác (Bể vỡ, hết hạn...)'
                },
                inputPlaceholder: '--- Chọn lý do ---',
                showCancelButton: true,
                confirmButtonColor: '#ee4d2d',
                cancelButtonColor: '#333',
                confirmButtonText: 'Gửi yêu cầu',
                cancelButtonText: 'Đóng',
                background: '#1a1a1a', color: '#fff',
                inputValidator: (value) => {
                    return new Promise((resolve) => {
                        if (value) { resolve(); }
                        else { resolve('Bạn cần chọn một lý do để tiếp tục!'); }
                    });
                }
            }).then(async (result) => {
                if (result.isConfirmed) {
                    const lyDo = result.value;

                    try {
                        const API_URL = typeof API !== 'undefined' ? API : 'api';
                        const res = await fetch(`${API_URL}/HuyDonHangApi.ashx?action=hoanhang&id=${maDonHang}&lydo=${encodeURIComponent(lyDo)}`, { method: 'POST' });
                        const json = await res.json();

                        if (json.success) {
                            Swal.fire({ title: 'Thành công!', text: `Yêu cầu trả hàng (Lý do: ${lyDo}) đang được xử lý.`, icon: 'success', background: '#1a1a1a', color: '#fff' });
                            loadOrders();
                        } else {
                            Swal.fire({ title: 'Lỗi', text: json.message, icon: 'error', background: '#1a1a1a', color: '#fff' });
                        }
                    } catch (err) {
                        Swal.fire({ title: 'Lỗi', text: 'Không thể kết nối máy chủ!', icon: 'error', background: '#1a1a1a', color: '#fff' });
                    }
                }
            });
        }

        async function huyDonHang(maDonHang) {
            Swal.fire({
                title: 'Hủy đơn hàng?',
                text: "Bạn có chắc chắn muốn hủy đơn hàng này không?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ee4d2d',
                cancelButtonColor: '#444',
                confirmButtonText: 'Đồng ý hủy',
                cancelButtonText: 'Không',
                background: '#1a1a1a', color: '#fff'
            }).then(async (result) => {
                if (result.isConfirmed) {
                    try {
                        const API_URL = typeof API !== 'undefined' ? API : 'api';
                        const res = await fetch(`${API_URL}/HuyDonHangApi.ashx?id=${maDonHang}`, { method: 'POST' });
                        const json = await res.json();

                        if (json.success) {
                            Swal.fire({ title: 'Thành công!', text: 'Đơn hàng đã được hủy.', icon: 'success', background: '#1a1a1a', color: '#fff' });
                            loadOrders();
                        } else {
                            Swal.fire({ title: 'Lỗi', text: json.message, icon: 'error', background: '#1a1a1a', color: '#fff' });
                        }
                    } catch (error) {
                        Swal.fire({ title: 'Lỗi mạng', text: 'Không kết nối được với máy chủ', icon: 'error', background: '#1a1a1a', color: '#fff' });
                    }
                }
            });
        }

        async function muaLai(maDonHang) {
            try {
                const API_URL = typeof API !== 'undefined' ? API : 'api';
                const res = await fetch(`${API_URL}/MuaLaiApi.ashx?id=${maDonHang}`, { method: 'POST' });
                const json = await res.json();

                if (json.success) {
                    window.location.href = 'ThanhToan.aspx';
                } else {
                    Swal.fire({ title: 'Lỗi', text: json.message, icon: 'error', background: '#1a1a1a', color: '#fff' });
                }
            } catch (error) {
                Swal.fire({ title: 'Lỗi mạng', text: 'Không kết nối được với máy chủ', icon: 'error', background: '#1a1a1a', color: '#fff' });
            }
        }

        function formatDate(dateString) {
            if (!dateString) return "";
            let date = new Date(dateString);
            if (dateString.indexOf('/Date(') > -1) {
                date = new Date(parseInt(dateString.replace('/Date(', '').replace(')/', '')));
            }
            return date.toLocaleDateString('vi-VN') + ' ' + date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
        }
    </script>
</body>
</html>