<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TaiKhoan.aspx.cs" Inherits="Ban_Linh_Kien_xe_may_1.TaiKhoan" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8" />
    <title>Tài khoản của tôi | VanDonMotor</title>
    <!-- Kéo style.css chuẩn của web thay vì auth.css để đồng bộ Navbar/Footer -->
    <link rel="stylesheet" href="style.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background: #121212; color: #fff; margin: 0; font-family: Arial, sans-serif; }
        
        /* Layout riêng cho trang Tài khoản */
        .account-wrapper { max-width: 800px; margin: 20px auto 60px; padding: 0 15px; }
        
        .box { background: #1e1e1e; border: 1px solid #333; border-radius: 4px; padding: 30px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.2); }
        .box-header { font-size: 18px; color: #ee4d2d; margin-top: 0; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 1px solid #333; text-transform: uppercase; font-weight: 500; display: flex; align-items: center; gap: 8px;}
        
        /* Style form Label - Input */
        .form-group { display: flex; align-items: center; margin-bottom: 20px; }
        .form-label { width: 180px; color: #aaa; text-align: right; padding-right: 20px; font-size: 14px; }
        .form-control { flex: 1; max-width: 400px; background: #242424; border: 1px solid #444; color: #fff; padding: 10px 15px; border-radius: 4px; outline: none; transition: 0.3s; font-size: 14px; }
        .form-control:focus { border-color: #ee4d2d; background: #1e1e1e; }
        .form-control:disabled { opacity: 0.6; cursor: not-allowed; }
        
        .action-row { display: flex; justify-content: flex-start; padding-left: 200px; margin-top: 30px; gap: 15px;}
        
        .btn-save { background: #ee4d2d; color: #fff; border: none; padding: 10px 30px; font-size: 14px; cursor: pointer; border-radius: 4px; transition: 0.3s; font-weight: bold; }
        .btn-save:hover { background: #d74427; }
        .btn-cancel { background: transparent; color: #aaa; border: 1px solid #555; padding: 10px 20px; font-size: 14px; cursor: pointer; border-radius: 4px; transition: 0.3s; }
        .btn-cancel:hover { background: #333; color: #fff; }
    </style>
</head>
<body>

    <!-- BẢO VỆ TRANG: Nếu chưa đăng nhập thì đá văng luôn từ C# -->
    <% 
        var currentUser = Session["User"] as Ban_Linh_Kien_xe_may_1.Models.NguoiDung;
        if (currentUser == null) { Response.Redirect("Dang_nhap.aspx"); }
    %>

    <!-- NAVBAR CHUẨN -->
    <nav class="navbar" id="navbar">
      <div class="nav-inner">
        <a href="index.aspx" class="logo">
          <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />
          <span class="brand">VanDon<span class="accent">Motor</span></span>
        </a>

        <div class="search-wrap">
          <input type="text" id="mainSearchInput" placeholder="Tìm linh kiện, phụ tùng..."/>
          <button class="search-btn" onclick="window.location.href='SanPham.aspx?q=' + document.getElementById('mainSearchInput').value">
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
          
          <div class="nav-user-menu" style="display:flex;">
            <div class="user-avatar-btn" onclick="toggleUserMenu(event)">
              <div class="user-avatar-ico">👤</div>
              <span style="font-weight: 700;"><%= currentUser.HoTen %></span>
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="user-dropdown">
              <a href="TaiKhoan.aspx" class="dropdown-item active">👤 Tài khoản của tôi</a>
              <a href="DonHang.aspx" class="dropdown-item">📦 Đơn hàng</a>
              <% if (Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsStaff(currentUser.VaiTro)) { %>
                  <div class="dropdown-divider"></div>
                  <a href="Admin.aspx" class="dropdown-item">⚙️ Quản Trị Admin</a>
              <% } %>
              <div class="dropdown-divider"></div>
              <a href="Dang_xuat.aspx" class="dropdown-item danger">🚪 Đăng Xuất</a>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <!-- NÚT QUAY LẠI CÓ ÉP TẢI LẠI TRANG -->
    <div class="btn-back-container">
        <button class="btn-back" onclick="if(document.referrer) { window.location.href = document.referrer; } else { window.location.href = 'index.aspx'; }">
            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 12H5"></path>
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 19l-7-7 7-7"></path>
            </svg>
            Quay lại
        </button>
    </div>

    <!-- KHU VỰC NỘI DUNG TÀI KHOẢN -->
    <div class="account-wrapper">
        
        <!-- Box Hồ Sơ -->
        <div class="box">
            <h2 class="box-header">
                <svg width="24" height="24" fill="currentColor" viewBox="0 0 16 16"><path d="M3 14s-1 0-1-1 1-4 6-4 6 3 6 4-1 1-1 1H3zm5-6a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/></svg>
                Hồ Sơ Của Tôi
            </h2>
            <form id="frmProfile" onsubmit="return false;">
                <div class="form-group">
                    <label class="form-label">Tên đăng nhập</label>
                    <input type="text" class="form-control" value="<%= currentUser.TenDangNhap %>" disabled title="Tên đăng nhập không thể thay đổi"/>
                </div>
                <div class="form-group">
                    <label class="form-label">Họ và tên</label>
                    <input type="text" id="txtHoTen" class="form-control" placeholder="Nhập họ và tên..." />
                </div>
                <div class="form-group">
                    <label class="form-label">Số điện thoại</label>
                    <input type="text" id="txtSDT" class="form-control" placeholder="Nhập số điện thoại..." />
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" id="txtEmail" class="form-control" placeholder="Nhập địa chỉ email..." />
                </div>
                <div class="action-row">
                    <button class="btn-save" onclick="saveProfile()">Lưu Thay Đổi</button>
                </div>
            </form>
        </div>

        <!-- Box Đổi Mật Khẩu -->
        <div class="box">
            <h2 class="box-header">
                <svg width="24" height="24" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2zm3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2zM5 8h6a1 1 0 0 1 1 1v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/></svg>
                Đổi Mật Khẩu
            </h2>
            <form id="frmPass" onsubmit="return false;">
                <div class="form-group">
                    <label class="form-label">Mật khẩu hiện tại</label>
                    <input type="password" id="txtCurrent" class="form-control" placeholder="Nhập mật khẩu hiện tại" />
                </div>
                <div class="form-group">
                    <label class="form-label">Mật khẩu mới</label>
                    <input type="password" id="txtNew" class="form-control" placeholder="Nhập mật khẩu mới" />
                </div>
                <div class="form-group">
                    <label class="form-label">Xác nhận mật khẩu mới</label>
                    <input type="password" id="txtConfirm" class="form-control" placeholder="Nhập lại mật khẩu mới" />
                </div>
                <div class="action-row">
                    <button class="btn-save" onclick="changePassword()">Cập Nhật Mật Khẩu</button>
                    <button class="btn-cancel" onclick="document.getElementById('frmPass').reset()">Hủy bỏ</button>
                </div>
            </form>
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

    <!-- CART SIDEBAR ĐỂ KHÔNG LỖI JS KHI ẤN NÚT GIỎ HÀNG TRÊN NAVBAR -->
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
        <button class="btn-checkout" onclick="window.location.href='ThanhToan.aspx'">Tiến hành thanh toán</button>
      </div>
    </div>

    <!-- SCRIPTS -->
    <script src="app.js"></script>
    <script>
        //const API = 'api';

        // Xử lý Menu dropdown góc phải
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

        // Tải dữ liệu hồ sơ
        async function loadProfile() {
            try {
                const res = await fetch(`${API}/DonHangApi.ashx?action=whoami`);
                const json = await res.json();
                if (json.success) {
                    document.getElementById('txtHoTen').value = json.data.HoTen || '';
                    document.getElementById('txtSDT').value = json.data.SoDienThoai || '';
                    document.getElementById('txtEmail').value = json.data.Email || '';
                } else {
                    if (json.message === 'not_logged_in') window.location.href = 'Dang_nhap.aspx';
                }
            } catch (e) { console.error(e); }
        }

        // Lưu hồ sơ
        async function saveProfile() {
            const hoTen = document.getElementById('txtHoTen').value.trim();
            const sdt = document.getElementById('txtSDT').value.trim();
            const email = document.getElementById('txtEmail').value.trim();

            const form = new URLSearchParams();
            form.append('hoTen', hoTen);
            form.append('sdt', sdt);
            form.append('email', email);

            try {
                // Thêm headers: Content-Type vào đây
                const res = await fetch(`api/CapNhatTaiKhoanApi.ashx`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: form.toString()
                });

                const json = await res.json();
                if (json.success) {
                    Swal.fire({ icon: 'success', title: 'Cập nhật hồ sơ thành công!', toast: true, position: 'top-end', showConfirmButton: false, timer: 2000 });
                    const nameSpan = document.querySelector('.nav-user-menu span');
                    if (nameSpan) nameSpan.innerText = hoTen;
                } else {
                    Swal.fire('Lỗi', json.message || 'Không thể lưu', 'error');
                }
            } catch (e) {
                console.error("Lỗi:", e);
                Swal.fire('Lỗi', 'Không thể kết nối hoặc máy chủ phản hồi lỗi', 'error');
            }
        }

        // Đổi mật khẩu
        async function changePassword() {
            const current = document.getElementById('txtCurrent').value;
            const nw = document.getElementById('txtNew').value;
            const conf = document.getElementById('txtConfirm').value;

            if (!current || !nw) { Swal.fire('Lỗi', 'Vui lòng nhập đầy đủ thông tin mật khẩu!', 'warning'); return; }
            if (nw !== conf) { Swal.fire('Lỗi', 'Mật khẩu xác nhận không khớp!', 'warning'); return; }

            const form = new URLSearchParams();
            form.append('current', current);
            form.append('new', nw);

            try {
                const res = await fetch(`${API}/ChangePasswordApi.ashx`, { method: 'POST', body: form });
                const json = await res.json();
                if (json.success) {
                    Swal.fire({ icon: 'success', title: 'Đã đổi mật khẩu thành công', toast: true, position: 'top-end', showConfirmButton: false, timer: 2000 });
                    document.getElementById('frmPass').reset(); // Xóa trắng form mật khẩu sau khi đổi xong
                } else {
                    Swal.fire('Thất bại', json.message || 'Mật khẩu hiện tại không đúng', 'error');
                }
            } catch (e) { Swal.fire('Lỗi', 'Không thể kết nối đến máy chủ', 'error'); }
        }

        document.addEventListener('DOMContentLoaded', loadProfile);
    </script>
</body>
</html>