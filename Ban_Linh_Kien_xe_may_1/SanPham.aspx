<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
    <title>Tất Cả Sản Phẩm | VanDonMotor</title>
    
    <link rel="icon" type="image/png" href="images/logo.png" />
    <link rel="stylesheet" href="style.css"/>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        /* Ép buộc hộp thoại SweetAlert2 luôn nằm trên cùng mọi lớp màng che */
        body.swal2-shown > [class^="swal2-container"],
        .swal2-container {
            z-index: 9999999 !important;
        }

        .shop-container {
            display: flex;
            gap: 30px;
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        /* Khung danh mục bên trái */
        .shop-sidebar {
            width: 250px;
            flex-shrink: 0;
            background: var(--bg-card);
            padding: 20px;
            border-radius: 12px;
            border: 1px solid var(--border);
            height: fit-content;
        }
        .shop-sidebar h3 {
            font-size: 18px;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--primary);
        }
        .shop-sidebar ul {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .shop-sidebar .filter-btn {
            width: 100%;
            text-align: left;
            background: transparent;
            padding: 10px 15px;
            font-size: 15px;
            border-radius: 6px;
            border: 1px solid transparent;
            color: #ddd;
            cursor: pointer;
            transition: 0.2s;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .shop-sidebar .filter-btn:hover {
            background: rgba(255, 255, 255, 0.05);
            color: #fff;
        }
        .shop-sidebar .filter-btn.active {
            background: var(--primary);
            color: #fff;
            font-weight: bold;
        }
        
        /* Khung sản phẩm bên phải */
        .shop-content {
            flex-grow: 1;
        }
        .shop-content h2 {
            font-size: 24px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<!-- NAVBAR -->
<nav class="navbar" id="navbar">
  <div class="nav-inner">
    <a href="index.aspx" class="logo">
      <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />
      <span class="brand">VanDon<span class="accent">Motor</span></span>
    </a>

    <div class="search-wrap">
      <input type="text" id="searchInput" placeholder="Tìm linh kiện, phụ tùng, hãng xe..."/>
      <button class="search-btn" onclick="handleSearch()">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
      </button>
    </div>

    <div class="nav-links">
      <a href="index.aspx">Trang Chủ</a>
      <a href="SanPham.aspx" class="active">Sản Phẩm</a>
      <a href="index.aspx#danh-muc">Danh Mục</a>
      <a href="index.aspx#khuyen-mai">Khuyến Mãi</a>
    </div>

    <div class="nav-actions">
      <button class="icon-btn" title="Giỏ hàng" id="cartBtn" onclick="openCart()">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
        <span class="badge" id="cartBadge">0</span>
      </button>
      
      <!-- KIỂM TRA ĐĂNG NHẬP -->
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

    <!-- NÚT QUAY LẠI -->
    <div class="btn-back-container">
        <button class="btn-back" onclick="window.history.back()">
            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 12H5"></path>
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 19l-7-7 7-7"></path>
            </svg>
            Quay lại
        </button>
    </div>

    <!-- KHU VỰC CHÍNH SHOP -->
    <div class="shop-container">
        
        <!-- Cột trái: Bộ lọc phân loại -->
        <aside class="shop-sidebar">
            <h3>Danh Mục & Phân Loại</h3>
            <ul id="sidebarFilterList">
                <li><button class="filter-btn active" id="btn-filter-all" onclick="toggleFilter(this, 'all', '')">Tất Cả Sản Phẩm</button></li>
                
                <!-- Lọc theo Hãng -->
                <li style="margin-top: 10px; font-weight: bold; color: var(--text-muted);">Theo Hãng</li>
                <li><button class="filter-btn" onclick="toggleFilter(this, 'brand', 'Honda')">Honda</button></li>
                <li><button class="filter-btn" onclick="toggleFilter(this, 'brand', 'Yamaha')">Yamaha</button></li>
                <li><button class="filter-btn" onclick="toggleFilter(this, 'brand', 'Suzuki')">Suzuki</button></li>
                <li><button class="filter-btn" onclick="toggleFilter(this, 'brand', 'SYM')">SYM</button></li>
                
                <!-- Lọc theo Bộ Phận: SẼ ĐƯỢC TỰ ĐỘNG SINH TỪ CSDL -->
                <li style="margin-top: 10px; font-weight: bold; color: var(--text-muted);">Theo Bộ Phận</li>
                <div id="dynamicCategoryList" style="display: flex; flex-direction: column; gap: 10px;">
                    <!-- JS sẽ nạp các danh mục ở đây -->
                </div>

                <!-- Lọc Giảm giá -->
                <li style="margin-top: 10px;"><button class="filter-btn" onclick="toggleFilter(this, 'isDiscount', true)" style="color: #ef4444; border-color: #ef4444;">🔥 Hàng Giảm Giá</button></li>
            </ul>
        </aside>

        <!-- Cột phải: Lưới hiển thị sản phẩm -->
        <main class="shop-content">
            <h2 id="shopTitle">Tất Cả Sản Phẩm</h2>
            <div class="product-grid" id="productGrid"></div>
        </main>
    </div>

<!-- FOOTER -->
<footer>
  <div class="footer-inner">
    <div class="footer-grid">
      <div class="footer-brand">
        <div class="logo">
          <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />
          <span style="font-size:20px;font-weight:900">VanDon<span style="color:#ff6b00">Motor</span></span>
        </div>
        <p class="footer-desc">Chuyên cung cấp linh kiện, phụ tùng xe máy chính hãng. Uy tín – Chất lượng – Giá tốt nhì thị trường.</p>
      </div>
      <div class="footer-col">
        <h4>Liên Hệ</h4>
        <ul>
          <li><a href="#">📍 Thôn Hà Xá, Thái bình</a></li>
          <li><a href="tel:0387281833">📞 3782 81833</a></li>
          <li><a href="#">✉️ info@VanDonMotor.vn</a></li>
          <li><a href="#">🕐 Thứ 2–Thứ 7: 8h–18h</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <span>© 2026 VanDonMotor. Bản quyền thuộc về VanDonMotor QUANGNINH.</span>
      <div class="payment-icons">
        <span class="pay-badge">MOMO</span>
        <span class="pay-badge">ZALOPAY</span>
        <span class="pay-badge">COD</span>
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
  <div class="cart-items" id="cartItems">
    <div style="text-align:center;padding:60px 20px;color:var(--text-muted)">
      <div style="font-size:48px;margin-bottom:16px">🛒</div>
      <p>Giỏ hàng đang trống</p>
    </div>
  </div>
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
    // Bật/tắt dropdown tài khoản
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

    // TẢI DANH MỤC TỰ ĐỘNG TỪ DATABASE CHO THANH BÊN
    async function loadShopCategories() {
        const catBox = document.getElementById('dynamicCategoryList');
        if (!catBox) return;

        try {
            const res = await fetch('/api/DanhMucApi.ashx');
            const json = await res.json();

            if (json.success && json.data) {
                // Lấy danh mục đang chọn từ URL nếu có (?cat=...)
                const urlParams = new URLSearchParams(window.location.search);
                const currentCat = urlParams.get('cat') || '';

                catBox.innerHTML = json.data.map(d => {
                    const isMatched = (currentCat.toLowerCase() === d.name.toLowerCase());
                    return `
                        <li>
                            <button class="filter-btn ${isMatched ? 'active' : ''}" onclick="toggleFilter(this, 'category', '${d.name}')">
                                <span>${d.name}</span>
                                <span style="font-size:12px; opacity:0.6;">(${d.count})</span>
                            </button>
                        </li>
                    `;
                }).join('');

                // Nếu URL có tham số lọc danh mục, cập nhật lại trạng thái active
                if (currentCat) {
                    const allBtn = document.getElementById('btn-filter-all');
                    if (allBtn) allBtn.classList.remove('active');
                }
            }
        } catch (e) {
            console.error("Không thể tải danh mục:", e);
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        loadShopCategories();
    });
</script>
</body>
</html>