<%@ Page Language="C#" AutoEventWireup="true" %>
<%-- Khai bao __o cap top truoc cac khop if/else de tranh loi CS0103 --%>
<%=""%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thanh Toán Đơn Hàng | VanDonMotor</title>
    <link rel="stylesheet" href="style.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        /* Các style dành riêng cho phần Checkout */
        .checkout-wrapper { max-width: 1200px; margin: 40px auto; padding: 0 15px; }
        
        .box { background: var(--bg-card, #1e1e1e); border-radius: 4px; margin-bottom: 15px; border: 1px solid var(--border, #333); overflow: hidden; }
        
        .stripe-border { height: 3px; width: 100%; background-position-x: -30px; background-size: 116px 3px; background-image: repeating-linear-gradient(45deg,#6fa6d6,#6fa6d6 33px,transparent 0,transparent 41px,#f18d9b 0,#f18d9b 74px,transparent 0,transparent 82px); }
        
        .address-section { padding: 28px 30px 24px; }
        .address-header { display: flex; align-items: center; color: var(--primary, #ee4d2d); font-size: 18px; margin-bottom: 20px; }
        .address-header svg { width: 16px; height: 16px; fill: currentColor; margin-right: 8px; }
        .address-inputs { display: flex; gap: 15px; align-items: center; }
        .address-inputs input { background: transparent; border: 1px solid var(--border, #333); color: white; padding: 8px 12px; border-radius: 4px; outline: none; }
        .address-inputs input:focus { border-color: var(--primary, #ee4d2d); }
        .inp-name { width: 150px; font-weight: bold; }
        .inp-phone { width: 120px; font-weight: bold; }
        .inp-address { flex-grow: 1; }
        
        .product-section { padding: 20px 30px; }
        .grid-header { display: grid; grid-template-columns: 4fr 1fr 1fr 1fr; padding-bottom: 15px; color: var(--text-muted, #9e9e9e); font-size: 14px; }
        .grid-header .col-center { text-align: center; }
        .grid-header .col-right { text-align: right; }
        
        .product-item { display: grid; grid-template-columns: 4fr 1fr 1fr 1fr; align-items: center; padding: 15px 0; border-top: 1px solid var(--border, #333); }
        .prod-info-wrap { display: flex; align-items: center; gap: 15px; }
        .prod-img { width: 40px; height: 40px; object-fit: cover; border: 1px solid var(--border, #333); }
        .prod-name { font-size: 14px; }
        .prod-price { text-align: center; font-size: 14px; }
        .prod-qty { text-align: center; font-size: 14px; }
        .prod-total { text-align: right; font-size: 14px; color: var(--primary, #ee4d2d); }

        .options-row { display: flex; justify-content: flex-end; padding: 20px 30px; border-top: 1px dashed var(--border, #333); background: #1a1a1a; }
        .shipping-info { display: flex; align-items: center; gap: 20px; font-size: 14px; }
        
        .summary-section { padding: 20px 30px; display: flex; flex-direction: column; align-items: flex-end; border-top: 1px solid var(--border, #333); background: #1a1a1a; }
        .summary-row { display: flex; justify-content: flex-end; align-items: center; width: 400px; margin-bottom: 15px; font-size: 14px; color: var(--text-muted, #9e9e9e); }
        .summary-row .val { color: var(--text, #fff); font-size: 16px; margin-left: 20px; min-width: 120px; text-align: right; }
        .summary-row.final { font-size: 16px; color: var(--text, #fff); align-items: flex-end; }
        .summary-row.final .val { color: var(--primary, #ee4d2d); font-size: 28px; }
        
        .btn-place-order { background: var(--primary, #ee4d2d); color: #fff; border: none; padding: 13px 36px; font-size: 16px; cursor: pointer; border-radius: 4px; font-weight: bold; min-width: 210px; }
        .btn-place-order:hover { background: #d74427; }
    </style>
</head>
<body>

    <!-- ĐƯA THANH NAVBAR CHUẨN VÀO ĐÂY -->
    <nav class="navbar" id="navbar">
      <div class="nav-inner">
        <a href="index.aspx" class="logo">
          <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />
          <span class="brand">VanDon<span class="accent">Motor</span></span>
        </a>

        <div class="search-wrap">
          <input type="text" id="searchInput" placeholder="Tìm linh kiện, phụ tùng, hãng xe..."/>
          <button class="search-btn" onclick="window.location.href='SanPham.aspx?q=' + document.getElementById('searchInput').value">
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
          </button>
        </div>

        <div class="nav-links">
          <a href="index.aspx">Trang Chủ</a>
          <a href="SanPham.aspx">Sản Phẩm</a>
          <a href="index.aspx#danh-muc">Danh Mục</a>
          <a href="index.aspx#khuyen-mai">Khuyến Mãi</a>
        </div>

        <div class="nav-actions">
          <button class="icon-btn" title="Giỏ hàng" id="cartBtn" onclick="window.location.href='index.aspx'">
            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
          </button>
          
          <!-- Kiểm tra đăng nhập để vẽ Menu User -->
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
                  <a href="#" class="dropdown-item">👤 Tài khoản của tôi</a>
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
          <% } %>
        
    </nav>

    <%-- NỘI DUNG THANH TOÁN --%>
    <div class="btn-back-container">
        <button class="btn-back" onclick="window.history.back()">
            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 12H5"></path>
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 19l-7-7 7-7"></path>
            </svg>
            Quay lại
        </button>
    </div>
    <div class="checkout-wrapper">
        <h2 style="color: var(--primary); margin-bottom: 20px; border-left: 3px solid var(--primary); padding-left: 10px;">Thanh Toán</h2>
        
        <!-- Khu vực Địa Chỉ -->
        <div class="box">
            <div class="stripe-border"></div>
            <div class="address-section">
                <div class="address-header">
                    <svg viewBox="0 0 12 16"><path d="M6 3.2c1.506 0 2.727 1.195 2.727 2.667 0 1.473-1.22 2.666-2.727 2.666S3.273 7.34 3.273 5.867C3.273 4.395 4.493 3.2 6 3.2zM0 6c0-3.315 2.686-6 6-6s6 2.685 6 6c0 2.498-1.964 5.742-6 9.933C1.613 11.743 0 8.498 0 6z" fill-rule="evenodd"></path></svg>
                    Địa Chỉ Nhận Hàng
                </div>
                
                <div class="address-inputs">
                    <% 
                        var user = Session["User"] as Ban_Linh_Kien_xe_may_1.Models.NguoiDung; 
                        if (user == null) { Response.Redirect("Dang_nhap.aspx"); }
                        string hoTen = user.HoTen ?? "";
                        string sdt = user.SoDienThoai ?? ""; 
                        string diaChi = user.DiaChi ?? ""; 
                    %>
                    <input type="text" id="txtTen" class="inp-name" value="<%= hoTen %>" readonly style="color: #888; cursor: not-allowed;" title="Tên không thể thay đổi tại đây" />
                    <input type="text" id="txtSDT" class="inp-phone" value="<%= sdt %>" placeholder="Số điện thoại..." required />
                    <input type="text" id="txtDiaChi" class="inp-address" value="<%= diaChi %>" placeholder="Đường, Phường/Xã, Quận/Huyện, Tỉnh/Thành phố..." required />
                    <button id="btnLuuThongTin" onclick="luuThongTin(event)" style="background: transparent; border: 1px solid var(--primary); color: var(--primary); font-size: 12px; padding: 6px 16px; border-radius: 4px; cursor: pointer; font-weight: bold;">Lưu</button>
                </div>
            </div>
        </div>

        <!-- Khu vực Danh sách Sản phẩm -->
        <div class="box product-section">
            <div class="grid-header">
                <div>Sản phẩm</div>
                <div class="col-center">Đơn giá</div>
                <div class="col-center">Số lượng</div>
                <div class="col-right">Thành tiền</div>
            </div>
            
            <div id="checkoutItems">
                <div style="text-align:center; padding: 40px; color: #888;">Đang tải dữ liệu giỏ hàng...</div>
            </div>
        </div>

        <!-- Tùy chọn Giao hàng & Tổng kết -->
        <div class="box">
            <div class="options-row">
                <div class="shipping-info">
                    <span>Phương thức thanh toán:</span>
                    <!-- Thẻ select đã được thêm onchange để gọi hàm hiện QR -->
                    <select id="cbThanhToan" onchange="hienThiQRCode()" style="background:#121212; color:white; border:1px solid #333; padding:6px; border-radius:3px; outline:none;">
                        <option value="COD">Thanh toán khi nhận hàng (COD)</option>
                        <option value="Chuyển khoản">Chuyển khoản ngân hàng</option>
                    </select>
                </div>
            </div>
            
                       <!-- Cập nhật Khung QR Code thành lời nhắc -->
            <div id="khungQRCode" style="display: none; background: #2a2a2a; border-top: 1px dashed #444; padding: 15px 30px; text-align: left;">
                <p style="color: #ee4d2d; font-style: italic; margin: 0;">
                    * Vui lòng ấn <b>"Đặt Hàng"</b>, hệ thống sẽ tự động tạo mã QR với đúng số tiền và mã đơn hàng. Bạn sẽ quét mã ở bước tiếp theo!
                </p>
            </div>
            
            <!-- Khu vực Tổng tiền và nút Đặt Hàng -->
            <div class="summary-section">

                <!-- Nhập mã giảm giá -->
                <div style="width: 400px; max-width: 100%; margin-bottom: 15px;">
                    <div style="display:flex; gap:8px;">
                        <input type="text" id="txtMaGiamGia" placeholder="Mã giảm giá (vd: VANDON40)" maxlength="50"
                               style="flex-grow:1; background:#121212; color:#fff; border:1px solid #333; padding:8px 12px; border-radius:4px; outline:none; text-transform:uppercase;" />
                        <button type="button" id="btnApDungMa" onclick="apDungMaGiamGia()"
                                style="background: var(--primary,#ee4d2d); color:#fff; border:none; padding:8px 18px; border-radius:4px; cursor:pointer; font-weight:bold; white-space:nowrap;">Áp dụng</button>
                    </div>
                    <div id="thongBaoMa" style="font-size:12px; margin-top:6px; display:none;"></div>
                </div>

                <div class="summary-row">
                    <span>Tổng tiền hàng</span>
                    <span class="val" id="lblTongTienHang">0 ₫</span>
                </div>
                <div class="summary-row" id="rowGiamGia" style="display:none;">
                    <span>Giảm giá</span>
                    <span class="val" style="color:#4ade80;">-<span id="lblTienGiam">0 ₫</span></span>
                </div>
                <div class="summary-row">
                    <span>Phí vận chuyển</span>
                    <span class="val">0 ₫</span>
                </div>
                <div class="summary-row final">
                    <span>Tổng thanh toán:</span>
                    <span class="val" id="lblTongThanhToan">0 ₫</span>
                </div>
                <div style="margin-top: 20px; display: flex; width: 100%; justify-content: flex-end; align-items: center;">
                    <button class="btn-place-order" onclick="xacNhanDatHang()">Đặt Hàng</button>
                </div>
            </div>
        </div>

    <!-- JS XỬ LÝ GIAO DIỆN VÀ API -->
    <script>
        const API = 'api';
        let checkoutCart = [];
        let totalAmount = 0;
        let maDaApDung = '';
        let tienGiam = 0;

        function formatVND(n) { return n ? parseInt(n).toLocaleString('vi-VN') + ' ₫' : '0 ₫'; }

        // Tổng thanh toán = tổng tiền hàng - giảm giá
        function capNhatTongThanhToan() {
            const final = Math.max(0, totalAmount - tienGiam);
            document.getElementById('lblTongThanhToan').textContent = formatVND(final);
            return final;
        }

        // Bật/tắt menu tài khoản
        function toggleUserMenu(event) {
            event.stopPropagation();
            const dropdown = document.querySelector('.user-dropdown');
            if (dropdown) dropdown.classList.toggle('active');
        }

        document.addEventListener('click', function (event) {
            const userMenu = document.querySelector('.nav-user-menu');
            const dropdown = document.querySelector('.user-dropdown');
            if (userMenu && dropdown && !userMenu.contains(event.target)) {
                dropdown.classList.remove('active');
            }
        });

        // Tải giỏ hàng khi load trang
        document.addEventListener("DOMContentLoaded", async () => {
            await loadCheckoutCart();
        });

        async function loadCheckoutCart() {
            try {
                const res = await fetch(`${API}/GioHangApi.ashx?action=get`);
                const json = await res.json();

                if (json.success) {
                    checkoutCart = json.data;
                    renderCheckoutItems();
                } else {
                    document.getElementById('checkoutItems').innerHTML = '<div style="text-align:center; padding:20px;">' + json.message + '</div>';
                }
            } catch (error) {
                console.error("Lỗi:", error);
            }
        }

        function renderCheckoutItems() {
            const wrap = document.getElementById('checkoutItems');
            if (!checkoutCart || checkoutCart.length === 0) {
                wrap.innerHTML = '<div style="text-align:center; padding: 40px;">Giỏ hàng trống.</div>';
                document.querySelector('.btn-place-order').style.display = 'none';
                return;
            }

            let html = '';
            let total = 0;

            checkoutCart.forEach(item => {
                const subTotal = item.price * item.qty;
                total += subTotal;
                html += `
                <div class="product-item">
                    <div class="prod-info-wrap">
                        <img src="${item.img}" class="prod-img" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'40\\' height=\\'40\\'%3E%3Crect width=\\'40\\' height=\\'40\\' fill=\\'%23333\\'/%3E%3C/svg%3E'"/>
                        <div class="prod-name">${item.name}</div>
                    </div>
                    <div class="prod-price">${formatVND(item.price)}</div>
                    <div class="prod-qty">${item.qty}</div>
                    <div class="prod-total">${formatVND(subTotal)}</div>
                </div>
                `;
            });

            wrap.innerHTML = html;
            totalAmount = total;
            document.getElementById('lblTongTienHang').textContent = formatVND(total);
            capNhatTongThanhToan();
        }

        // Áp dụng mã giảm giá
        async function apDungMaGiamGia() {
            const code = document.getElementById('txtMaGiamGia').value.trim();
            const box = document.getElementById('thongBaoMa');
            if (!code) {
                Swal.fire('Thông báo', 'Vui lòng nhập mã giảm giá!', 'warning');
                return;
            }

            const btn = document.getElementById('btnApDungMa');
            btn.disabled = true;
            const original = btn.textContent;
            btn.textContent = 'Đang kiểm tra...';

            try {
                const formData = new URLSearchParams();
                formData.append('maCode', code);

                const res = await fetch(`${API}/MaGiamGiaApi.ashx?action=check`, { method: 'POST', body: formData });
                const json = await res.json();

                box.style.display = 'block';

                if (json.success && json.valid) {
                    maDaApDung = json.maCode;
                    tienGiam = json.tienGiam;
                    document.getElementById('rowGiamGia').style.display = 'flex';
                    document.getElementById('lblTienGiam').textContent = formatVND(json.tienGiam);
                    document.getElementById('txtMaGiamGia').value = json.maCode;
                    capNhatTongThanhToan();

                    const moTa = (json.loaiGiam === 'PhanTram') ? (json.giaTri + '%') : formatVND(json.giaTri);
                    box.style.color = '#4ade80';
                    box.innerHTML = `✔ Đã áp dụng mã <b>${json.maCode}</b> (giảm ${moTa}). <a href="#" onclick="boMaGiamGia();return false;" style="color:#ffb703;">Bỏ mã</a>`;
                } else {
                    maDaApDung = '';
                    tienGiam = 0;
                    document.getElementById('rowGiamGia').style.display = 'none';
                    capNhatTongThanhToan();
                    box.style.color = '#ef233c';
                    box.textContent = '✖ ' + (json.message || 'Mã giảm giá không hợp lệ.');
                }
            } catch (error) {
                Swal.fire('Lỗi mạng', 'Không thể kết nối đến máy chủ!', 'error');
            } finally {
                btn.disabled = false;
                btn.textContent = original;
            }
        }

        // Bỏ mã đang áp dụng
        function boMaGiamGia() {
            maDaApDung = '';
            tienGiam = 0;
            document.getElementById('txtMaGiamGia').value = '';
            document.getElementById('rowGiamGia').style.display = 'none';
            document.getElementById('thongBaoMa').style.display = 'none';
            capNhatTongThanhToan();
        }

        // Lưu thông tin người dùng
        async function luuThongTin(e) {
            e.preventDefault();
            const sdt = document.getElementById('txtSDT').value.trim();
            const diaChi = document.getElementById('txtDiaChi').value.trim();

            if (!sdt || !diaChi) {
                Swal.fire('Cảnh báo', 'Vui lòng điền đủ Số điện thoại và Địa chỉ!', 'warning');
                return;
            }

            const formData = new URLSearchParams();
            formData.append('sdt', sdt);
            formData.append('diaChi', diaChi);

            try {
                const res = await fetch(`${API}/CapNhatThongTinApi.ashx`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                });
                const json = await res.json();
                if (json.success) {
                    Swal.fire({ title: 'Thành công!', text: 'Thông tin nhận hàng đã được lưu.', icon: 'success', toast: true, position: 'top-end', showConfirmButton: false, timer: 2000 });
                } else {
                    Swal.fire('Lỗi', json.message, 'error');
                }
            } catch (error) {
                Swal.fire('Lỗi mạng', 'Không thể kết nối đến máy chủ!', 'error');
            }
        }

        // Đặt hàng
        async function xacNhanDatHang() {
            const ten = document.getElementById('txtTen').value.trim();
            const sdt = document.getElementById('txtSDT').value.trim();
            const diaChi = document.getElementById('txtDiaChi').value.trim();
            const ptThanhToan = document.getElementById('cbThanhToan').value;

            if (!ten || !sdt || !diaChi) {
                Swal.fire('Thiếu thông tin', 'Vui lòng điền đầy đủ thông tin giao hàng!', 'warning');
                return;
            }

            const formData = new URLSearchParams();
            formData.append('ten', ten);
            formData.append('sdt', sdt);
            formData.append('diaChi', diaChi);
            formData.append('ptThanhToan', ptThanhToan);
            formData.append('maCode', maDaApDung);

            try {
                const res = await fetch('/api/DatHangApi.ashx', {
                    method: 'POST',
                    body: formData
                });
                const json = await res.json();

                if (json.success) {
                    const tienPhaiTra = (typeof json.tongThanhToan === 'number') ? json.tongThanhToan : Math.max(0, totalAmount - tienGiam);

                    // NẾU KHÁCH CHỌN CHUYỂN KHOẢN -> HIỆN POPUP MÃ QR SEPAY
                    if (ptThanhToan === "Chuyển khoản") {

                        // --- CẤU HÌNH SEPAY CỦA BẠN TẠI ĐÂY ---
                        const soTaiKhoanMB = "0946868002005"; // <-- Điền số tài khoản MB Bank của bạn vào đây
                        const tenChuTK = "LUU HAI TUAN";
                        const maDon = json.maVanDon;

                        // Dùng link VietQR chuẩn có Logo MB Bank chính hãng, khóa đúng số tiền và mã đơn
                        const qrUrl = `https://img.vietqr.io/image/MB-${soTaiKhoanMB}-compact2.jpg?amount=${tienPhaiTra}&addInfo=${maDon}&accountName=${encodeURIComponent(tenChuTK)}`;

                        Swal.fire({
                            title: 'Quét mã để thanh toán',
                            html: `
                        <div style="font-size: 15px; margin-bottom: 15px;">
                            Mã đơn: <b style="color: #ee4d2d;">${maDon}</b><br>
                            Số tiền: <b style="color: #ee4d2d; font-size: 18px;">${formatVND(tienPhaiTra)}</b>
                        </div>
                        <img src="${qrUrl}" alt="Mã QR Thanh toán" style="width: 250px; height: 250px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.2);">
                        <p style="margin-top: 15px; font-size: 13px; color: #888;">
                            Sử dụng App ngân hàng để quét mã.<br>Hệ thống sẽ tự động xác nhận đơn hàng sau khi nhận được tiền!
                        </p>
                    `,
                            icon: 'info',
                            confirmButtonText: 'Tôi đã chuyển khoản xong',
                            confirmButtonColor: '#ee4d2d',
                            allowOutsideClick: false
                        }).then(() => {
                            window.location.href = 'index.aspx'; // Điều hướng về trang chủ hoặc trang lịch sử đơn hàng
                        });

                    } else {
                        // NẾU KHÁCH CHỌN COD -> HIỆN POPUP BÌNH THƯỜNG
                        const dongGiam = (json.tienGiam > 0) ? `<br>Đã giảm giá: <b style="color:#4ade80;">-${formatVND(json.tienGiam)}</b>` : '';
                        Swal.fire({
                            title: '🎉 Đặt hàng thành công!',
                            html: `Cảm ơn bạn đã mua sắm.<br>Mã vận đơn của bạn là: <b style="color: #ee4d2d; font-size: 18px;">${json.maVanDon}</b>${dongGiam}<br>Vui lòng chờ nhận hàng và thanh toán!`,
                            icon: 'success',
                            confirmButtonColor: '#ee4d2d'
                        }).then(() => {
                            window.location.href = 'index.aspx';
                        });
                    }
                } else {
                    Swal.fire('❌ Lỗi', json.message, 'error');
                }
            } catch (e) {
                console.error(e);
                Swal.fire('Lỗi mạng', 'Không thể kết nối đến máy chủ!', 'error');
            }
        }
        // Hàm kiểm tra và hiển thị QR Code
        function hienThiQRCode() {
            const phuongThuc = document.getElementById("cbThanhToan").value;
            const khungQR = document.getElementById("khungQRCode");

            if (phuongThuc === "Chuyển khoản") {
                khungQR.style.display = "block";
                khungQR.animate([
                    { opacity: 0, transform: 'translateY(-10px)' },
                    { opacity: 1, transform: 'translateY(0)' }
                ], { duration: 300, fill: 'forwards' });
            } else {
                khungQR.style.display = "none";
            }
        }
    </script>
</body>
</html>