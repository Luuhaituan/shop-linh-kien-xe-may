<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <style>
        .cat-grid .cat-card:nth-child(n+9) {
        display: none !important;
        }
    /* Ép buộc hộp thoại SweetAlert2 luôn nằm trên cùng mọi lớp màng che */
    body.swal2-shown > [class^="swal2-container"],
    .swal2-container {
        z-index: 9999999 !important;
    }
    .hero-section {
        display: flex;
        align-items: center;
        justify-content: space-between;
        max-width: 1200px;
        margin: 0 auto;
        padding: 40px 20px;
        gap: 30px; 
        position: relative;
        z-index: 2; 
    }

    .hero-left {
        flex: 1;
        max-width: 50%;
    }

    .hero-right {
        flex: 1;
        max-width: 50%;
        overflow: hidden; 
        position: relative;
        padding: 20px 0;
        mask-image: linear-gradient(to right, transparent, black 5%, black 95%, transparent);
        -webkit-mask-image: linear-gradient(to right, transparent, black 5%, black 95%, transparent);
    }

    .hero-slider {
        display: flex;
        gap: 20px;
        width: max-content; 
        animation: slideLeftRight 12s linear infinite alternate; 
    }

    .hero-slider:hover {
        animation-play-state: paused;
    }

    .slide-card {
        background: #fff; /* Nền trắng giúp ảnh linh kiện xe nổi bật và sạch sẽ */
        border: 2px solid transparent;
        border-radius: 12px;
        padding: 0; 
        width: 260px; /* PHÓNG TO thẻ ra (cũ là 220px) */
        height: 260px; /* Ép thành hình vuông lớn */
        flex-shrink: 0;
        text-align: center;
        text-decoration: none;
        display: block;
        position: relative; /* Điểm tựa để làm lớp mờ và nổi chữ */
        overflow: hidden; /* Cắt đi phần ảnh bị tràn khi phóng to */
        transition: 0.4s ease;
    }

    .slide-card img {
        width: 100%;
        height: 100%;
        object-fit: contain; 
        padding: 20px; /* Cho ảnh lùi vào trong một chút */
        transition: transform 0.5s ease; /* Hiệu ứng zoom ảnh mượt mà */
    }

    /* Tạo lớp màn đen che mờ ảnh (Mặc định ẩn đi) */
    .slide-card::before {
        content: '';
        position: absolute;
        inset: 0; /* Phủ kín toàn bộ thẻ */
        background: rgba(0, 0, 0, 0.85); /* Nền đen mờ 85% */
        opacity: 0; /* Mặc định trong suốt (ẩn) */
        transition: 0.4s ease;
        z-index: 1;
    }

    /* CHỮ: Tên sản phẩm (Mặc định giấu đi và tụt xuống dưới) */
    .slide-card .slide-title {
        position: absolute;
        top: 40%;
        left: 15px;
        right: 15px;
        color: #fff;
        font-size: 18px;
        font-weight: bold;
        line-height: 1.4;
        opacity: 0; /* Ẩn đi */
        transform: translateY(20px); /* Tụt xuống dưới 20px */
        transition: 0.4s ease;
        z-index: 2; /* Nằm trên lớp màn đen */
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    /* CHỮ: Giá tiền (Mặc định giấu đi và tụt xuống dưới) */
    .slide-card .slide-price {
        position: absolute;
        top: 60%;
        left: 15px;
        right: 15px;
        color: #ee4d2d;
        font-weight: bold;
        font-size: 24px;
        opacity: 0; /* Ẩn đi */
        transform: translateY(20px);
        transition: 0.4s ease;
        transition-delay: 0.05s; /* Hiển thị trễ hơn tên 1 tí tạo hiệu ứng lướt */
        z-index: 2;
    }

    /* ==================================================
       HIỆU ỨNG KHI DI CHUỘT VÀO (HOVER)
    ================================================== */
    .slide-card:hover {
        border-color: #ee4d2d; /* Bo viền cam */
        box-shadow: 0 10px 25px rgba(238, 77, 45, 0.3); /* Đổ bóng tỏa ra ngoài */
    }

    .slide-card:hover img {
        transform: scale(1.15); /* Phóng to ảnh thêm 15% */
    }

    .slide-card:hover::before {
        opacity: 1; /* Hiện lớp màn đen lên */
    }

    .slide-card:hover .slide-title {
        opacity: 1; /* Khởi động độ nét */
        transform: translateY(-50%); /* Trượt chữ lên giữa */
    }

    .slide-card:hover .slide-price {
        opacity: 1; /* Khởi động độ nét */
        transform: translateY(-30%); /* Trượt giá lên trên */
    }

    /* Khung hình chuyển động của Animation */
    @keyframes slideLeftRight {
        0% { transform: translateX(0); }
        100% { transform: translateX(calc(-100% + 500px)); }
    }
</style>
   <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>VanDonMotor – Linh Kiện Xe Máy Chính Hãng</title>
  <meta name="description" content="Mua sắm linh kiện xe máy chính hãng, giá tốt nhất. Honda, Yamaha, Suzuki, SYM – bảo hành uy tín, giao hàng toàn quốc."/>
  <link rel="stylesheet" href="style.css"/>
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
      <a href="index.aspx" class="active">Trang Chủ</a>
      <a href="SanPham.aspx">Sản Phẩm</a>
      <a href="#danh-muc">Danh Mục</a>
      <a href="#khuyen-mai">Khuyến Mãi</a>
      <!--<a href="#lien-he">Liên Hệ</a>-->
    </div>

    <div class="nav-actions">
      
      <button class="icon-btn" title="Giỏ hàng" id="cartBtn" onclick="openCart()">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
        <span class="badge" id="cartBadge">0</span>
      </button>
      
      <!-- === ĐOẠN CODE C# KIỂM TRA ĐĂNG NHẬP === -->
      <% if (Session["User"] == null) { %>
          <!-- Khi CHƯA đăng nhập -->
          <a href="Dang_nhap.aspx" class="btn-login">Đăng Nhập</a>
          <a href="Dang_ky.aspx" class="btn-register" style="text-decoration:none;display:flex;align-items:center">Đăng Ký</a>
      <% } else { 
          // Lấy thông tin user từ Session
          var currentUser = Session["User"] as Ban_Linh_Kien_xe_may_1.Models.NguoiDung;
      %>
          <!-- Khi ĐÃ đăng nhập -->
          <div class="nav-user-menu" style="display:flex;">
            <div class="user-avatar-btn" onclick="toggleUserMenu(event)">
              <div class="user-avatar-ico">👤</div>
              <!-- In tên người dùng ra giao diện -->
              <span style="font-weight: 700;"><%= currentUser.HoTen %></span>
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="user-dropdown">
                <a href="TaiKhoan.aspx" class="dropdown-item">👤 Tài khoản của tôi</a>
                <a href="DonHang.aspx" class="dropdown-item">📦 Đơn hàng</a>
              
              <!-- Nếu là Admin thì hiện thêm nút Quản trị -->
              <% if (Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsStaff(currentUser.VaiTro)) { %>
                  <div class="dropdown-divider"></div>
                  <a href="Admin.aspx" class="dropdown-item">⚙️ Quản Trị Admin</a>
              <% } %>
              
              <div class="dropdown-divider"></div>
              <a href="Dang_xuat.aspx" class="dropdown-item danger">🚪 Đăng Xuất</a>
            </div>
          </div>
      <% } %>
      <!-- ======================================= -->
    </div>
  </div>
</nav>

<!-- HERO -->
<section class="hero">
  <div class="hero-bg"></div>
  <div class="hero-overlay"></div>
  
  <div class="hero-section">
      <!-- Cột Trái: Chữ và nút bấm -->
      <div class="hero-left">
        <div class="hero-badge">🔥 Ưu đãi tháng 10 – Giảm đến 40%</div>
        <h1>Linh Kiện Xe Máy<em>Chính Hãng, Giá Tốt</em></h1>
        <p>Hơn 10,000+ phụ tùng xe máy từ các thương hiệu uy tín. Bảo hành chính hãng, giao hàng nhanh toàn quốc trong 24h.</p>
        <div class="hero-btns">
          <button class="btn-hero-primary" onclick="document.getElementById('san-pham').scrollIntoView({behavior:'smooth'})">
            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
            Mua Ngay
          </button>
          <button class="btn-hero-outline" onclick="document.getElementById('danh-muc').scrollIntoView({behavior:'smooth'})">
            Xem Danh Mục →
          </button>
        </div>
        <div class="hero-stats">
          <div class="stat"><span class="stat-num">10+</span><span class="stat-label">Sản phẩm</span></div>
          <div class="stat"><span class="stat-num">0+</span><span class="stat-label">Khách hàng</span></div>
          <div class="stat"><span class="stat-num">0★</span><span class="stat-label">Đánh giá</span></div>
          <div class="stat"><span class="stat-num">12T</span><span class="stat-label">Bảo hành</span></div>
        </div>
      </div>

      <!-- Cột Phải: Các sản phẩm tự động chạy ngang -->
      <div class="hero-right">
          <div class="hero-slider">
              <!-- Nhớ sửa lại src ảnh cho đúng với dự án của bạn nhé -->
              <a href="ChiTietSanPham.aspx?id=2" class="slide-card">
                  <img src="images/bugi.jpg" alt="Bugi" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'200\\' height=\\'160\\'%3E%3Crect width=\\'200\\' height=\\'160\\' fill=\\'%23333\\'/%3E%3C/svg%3E'" />
                  <div class="slide-title">Bugi Iridium Honda</div>
                  <div class="slide-price">85.000 ₫</div>
              </a>
              
              <a href="ChiTietSanPham.aspx?id=4" class="slide-card">
                  <img src="images/bo_che_hoa_khi_wave.jpg" alt="Chế Hòa Khí" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'200\\' height=\\'160\\'%3E%3Crect width=\\'200\\' height=\\'160\\' fill=\\'%23333\\'/%3E%3C/svg%3E'" />
                  <div class="slide-title">Bộ Chế Hòa Khí Wave</div>
                  <div class="slide-price">420.000 ₫</div>
              </a>
              
              <a href="ChiTietSanPham.aspx?id=3" class="slide-card">
                  <img src="images/dia_phanh_truoc_ex.jpg" alt="Đĩa phanh" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'200\\' height=\\'160\\'%3E%3Crect width=\\'200\\' height=\\'160\\' fill=\\'%23333\\'/%3E%3C/svg%3E'" />
                  <div class="slide-title">Đĩa Phanh Exciter 150</div>
                  <div class="slide-price">285.000 ₫</div>
              </a>
              
              <a href="ChiTietSanPham.aspx?id=5" class="slide-card">
                  <img src="images/sen_cam_kep.jpg" alt="Sên xe" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'200\\' height=\\'160\\'%3E%3Crect width=\\'200\\' height=\\'160\\' fill=\\'%23333\\'/%3E%3C/svg%3E'" />
                  <div class="slide-title">Sên Cam Yamaha Nouvo</div>
                  <div class="slide-price">195.000 ₫</div>
              </a>
          </div>
      </div>
  </div>
</section>

<!-- BRANDS 
<div class="brands-bg">
  <div class="section-inner">
    <div class="brands-row">
      <span class="brand-item">Honda</span>
      <span class="brand-item">Yamaha</span>
      <span class="brand-item">Suzuki</span>
      <span class="brand-item">SYM</span>
      <span class="brand-item">Piaggio</span>
      <span class="brand-item">Kawasaki</span>
      <span class="brand-item">Kymco</span>
    </div>
  </div>
</div>

<!-- DANH MỤC -->
<section id="danh-muc">
  <div class="section-inner">
    <div class="section-header">
      <div>
        <h2 class="section-title">Danh Mục <span>Sản Phẩm</span></h2>
        <p class="section-subtitle">Tìm nhanh linh kiện theo loại xe và bộ phận</p>
      </div>
      <!--<a href="#" class="view-all">Tất cả danh mục →</a>-->
    </div>
    <div class="cat-grid">
      <!-- Khi bấm vào sẽ chuyển sang trang SanPham.aspx và tự động lọc -->
      <a href="SanPham.aspx?cat=Động cơ" class="cat-card"><span class="cat-icon">⚙️</span><div class="cat-name">Động Cơ</div><div class="cat-count">1,240 sản phẩm</div></a>
      <a href="SanPham.aspx?cat=Phanh" class="cat-card"><span class="cat-icon">🛑</span><div class="cat-name">Hệ Thống Phanh</div><div class="cat-count">856 sản phẩm</div></a>
      <a href="SanPham.aspx?cat=Điện" class="cat-card"><span class="cat-icon">⚡</span><div class="cat-name">Hệ Thống Điện</div><div class="cat-count">632 sản phẩm</div></a>
      <a href="SanPham.aspx?cat=Truyền động" class="cat-card"><span class="cat-icon">🔗</span><div class="cat-name">Truyền Động</div><div class="cat-count">478 sản phẩm</div></a>
      <a href="SanPham.aspx?cat=Lọc" class="cat-card"><span class="cat-icon">🔩</span><div class="cat-name">Bộ Lọc</div><div class="cat-count">320 sản phẩm</div></a>
      <a href="SanPham.aspx?cat=Đèn" class="cat-card"><span class="cat-icon">💡</span><div class="cat-name">Đèn Xe</div><div class="cat-count">510 sản phẩm</div></a>
      <a href="SanPham.aspx?cat=Xăm lốp" class="cat-card"><span class="cat-icon">🔄</span><div class="cat-name">Xăm Lốp</div><div class="cat-count">290 sản phẩm</div></a>
      <a href="SanPham.aspx?cat=Phụ kiện" class="cat-card"><span class="cat-icon">🛡️</span><div class="cat-name">Phụ Kiện</div><div class="cat-count">2,100 sản phẩm</div></a>
    </div>
  </div>
</section>

<!-- KHUYẾN MÃI BANNER -->
<section id="khuyen-mai" style="padding-top:0">
  <div class="section-inner">
    <div class="promo-grid">
      <div class="promo-card promo-card-1">
        <div class="promo-deco">🔥</div>
        <h3>Flash Sale Cuối Tuần</h3>
        <p>Giảm đến <strong style="color:#ff6b00;font-size:24px">40%</strong> linh kiện động cơ chính hãng</p>
        <a href="#san-pham" class="btn-promo">Xem ưu đãi →</a>
      </div>
      <div class="promo-card promo-card-2">
        <div class="promo-deco">📦</div>
        <h3>Miễn Phí Vận Chuyển</h3>
        <p>Đơn hàng từ <strong style="color:#6c8eff;font-size:24px">500k</strong> – Giao toàn quốc trong 24h</p>
        <a href="#san-pham" class="btn-promo">Mua ngay →</a>
      </div>
    </div>
  </div>
</section>

<!-- SẢN PHẨM NỔI BẬT -->
<section id="san-pham">
  <div class="section-inner">
    <div class="section-header">
      <div>
        <h2 class="section-title">Sản Phẩm <span>Nổi Bật</span></h2>
        <p class="section-subtitle">Linh kiện bán chạy nhất, được khách hàng tin dùng</p>
      </div>
      <a href="SanPham.aspx" class="view-all">Xem tất cả →</a>
    </div>

    

    <div class="product-grid" id="productGrid"></div>
  </div>
</section>

<!-- ĐÁNH GIÁ 
<section style="background:var(--bg-card);border-top:1px solid var(--border);border-bottom:1px solid var(--border)">
  <div class="section-inner">
    <div class="section-header">
      <div>
        <h2 class="section-title">Khách Hàng <span>Nói Gì?</span></h2>
        <p class="section-subtitle">Hơn 50,000+ đánh giá 5 sao từ khách hàng trên toàn quốc</p>
      </div>
    </div>
    <div class="testi-grid">
      <div class="testi-card">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-text">"Mua bugi Honda Air Blade về lắp vào, xe chạy ngon hơn hẳn. Hàng chính hãng, đóng gói cẩn thận, giao hàng nhanh trong ngày. Rất hài lòng!"</p>
        <div class="testi-author"><div class="testi-avatar">👨</div><div><div class="testi-name">Nguyễn Văn An</div><div class="testi-loc">Hà Nội</div></div></div>
      </div>
      <div class="testi-card">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-text">"Đĩa phanh Yamaha Exciter chất lượng tốt, giá hợp lý hơn ngoài thị trường. Shop tư vấn nhiệt tình, sẽ ủng hộ dài dài!"</p>
        <div class="testi-author"><div class="testi-avatar">👩</div><div><div class="testi-name">Trần Thị Bình</div><div class="testi-loc">TP. Hồ Chí Minh</div></div></div>
      </div>
      <div class="testi-card">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-text">"Lần đầu mua online linh kiện xe, lo lắng hàng giả nhưng MotoVanDon uy tín quá. Có tem bảo hành, code QR kiểm tra hàng thật. Thumbs up!"</p>
        <div class="testi-author"><div class="testi-avatar">🧑</div><div><div class="testi-name">Lê Minh Khoa</div><div class="testi-loc">Đà Nẵng</div></div></div>
      </div>
    </div>
  </div>
</section>

<!-- NEWSLETTER 
<% if (Session["User"] == null) { %>
<section>
  <div class="section-inner" style="padding:0">
    <div class="newsletter" id="lien-he">
      <h2>🔔 Đăng Ký Nhận Ưu Đãi</h2>
      <p>Nhận thông báo khuyến mãi độc quyền, sản phẩm mới và mẹo bảo dưỡng xe trước tiên!</p>
      <form class="newsletter-form" onsubmit="handleSubscribe(event)">
        <input type="email" id="emailInput" placeholder="Nhập email của bạn..." required/>
        <button type="submit" class="btn-subscribe">Đăng Ký Ngay</button>
      </form>
    </div>
  </div>
</section>
<% } %>

<!-- FOOTER -->
<footer>
  <div class="footer-inner">
    <div class="footer-grid">
      <div class="footer-brand">
        <div class="logo">
        <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />          <span style="font-size:20px;font-weight:900">VanDon<span style="color:#ff6b00">Motor</span></span>
        </div>
        <p class="footer-desc">Chuyên cung cấp linh kiện, phụ tùng xe máy chính hãng. Uy tín – Chất lượng – Giá tốt nhì thị trường.</p>
        <!--<div class="social-links">
          <a href="#" class="social-btn" title="Facebook">f</a>
          <a href="#" class="social-btn" title="Zalo">Z</a>
          <a href="#" class="social-btn" title="YouTube">▶</a>
          <a href="#" class="social-btn" title="TikTok">♪</a>
        </div> -->
      </div>
     <div class="footer-col">
        <!--<h4>Danh Mục</h4>
        <ul>
          <li><a href="#">Động cơ</a></li>
          <li><a href="#">Hệ thống phanh</a></li>
          <li><a href="#">Hệ thống điện</a></li>
          <li><a href="#">Truyền động</a></li>
          <li><a href="#">Đèn xe</a></li>
          <li><a href="#">Phụ kiện</a></li>
        </ul>   
      </div>
      <div class="footer-col"> -->
        <!--<h4>Hỗ Trợ</h4>
        <ul>
          <li><a href="#">Theo dõi đơn hàng</a></li>
          <li><a href="#">Chính sách đổi trả</a></li>
          <li><a href="#">Tra cứu bảo hành</a></li>
          <li><a href="#">Hướng dẫn mua hàng</a></li>
          <li><a href="#">FAQ</a></li>
        </ul>
      </div>-->
      <div class="footer-col">
        <h4>Liên Hệ</h4>
        <ul>
          <li><a href="#">📍 Thôn Hà Xá, Thái bình</a></li>
          <li><a href="tel:0824230160">📞 0824320160</a></li>
          <li><a href="#">✉️ haituanvd@gmail.com</a></li>
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

<!-- POPUP QUANG CAO UU DAI -->
<style>
    .promo-modal {
        position: fixed; inset: 0; z-index: 999999;
        display: none; align-items: center; justify-content: center; padding: 20px;
    }
    .promo-modal.show { display: flex; }
    .promo-modal-overlay {
        position: absolute; inset: 0; background: rgba(0, 0, 0, 0.78);
        backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px);
        animation: promoFade 0.3s ease;
    }
    .promo-modal-card {
        position: relative; width: 100%; max-width: 420px;
        background: linear-gradient(160deg, #1e1e22, #141416);
        border: 1px solid rgba(255, 107, 0, 0.35);
        border-radius: 16px; overflow: hidden;
        box-shadow: 0 25px 60px rgba(0, 0, 0, 0.65), 0 0 0 1px rgba(255, 107, 0, 0.08);
        animation: promoPop 0.4s cubic-bezier(.2, .9, .3, 1.2);
    }
    .promo-modal-card::before {
        content: ''; position: absolute; top: -60px; right: -60px;
        width: 200px; height: 200px; border-radius: 50%;
        background: radial-gradient(circle, rgba(255, 107, 0, 0.35), transparent 70%);
        pointer-events: none;
    }
    .promo-modal-close {
        position: absolute; top: 12px; right: 12px; z-index: 3;
        width: 32px; height: 32px; border-radius: 50%; border: none;
        background: rgba(255, 255, 255, 0.1); color: #fff; font-size: 15px;
        cursor: pointer; display: flex; align-items: center; justify-content: center;
        transition: 0.25s;
    }
    .promo-modal-close:hover { background: #ef4444; transform: rotate(90deg); }
    .promo-modal-badge {
        background: linear-gradient(90deg, #ff6b00, #ee4d2d); color: #fff;
        text-align: center; font-size: 12px; font-weight: 800; letter-spacing: 1.5px;
        padding: 8px 0;
    }
    .promo-modal-body { padding: 26px 26px 24px; text-align: center; position: relative; z-index: 2; }
    .promo-modal-sale {
        display: inline-flex; flex-direction: column; align-items: center; justify-content: center;
        width: 108px; height: 108px; border-radius: 50%;
        background: radial-gradient(circle at 35% 30%, #ff8a3d, #ee4d2d);
        box-shadow: 0 8px 26px rgba(238, 77, 45, 0.5);
        margin: -6px auto 16px; color: #fff; line-height: 1;
    }
    .promo-modal-sale-num { font-size: 34px; font-weight: 900; letter-spacing: -1px; }
    .promo-modal-sale-label { font-size: 10px; font-weight: 700; letter-spacing: 2px; opacity: 0.95; margin-top: 3px; }
    .promo-modal-title { color: #fff; font-size: 20px; margin: 0 0 8px; font-weight: 800; }
    .promo-modal-desc { color: var(--text-muted); font-size: 14px; line-height: 1.6; margin: 0 0 18px; }
    .promo-modal-code-label { display: block; color: var(--text-muted); font-size: 12px; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 1px; }
    .promo-modal-code-box {
        display: flex; align-items: stretch; gap: 0; justify-content: center;
        border: 1px dashed var(--primary); border-radius: 10px; overflow: hidden;
        background: rgba(255, 107, 0, 0.08); margin-bottom: 20px;
    }
    .promo-modal-code-box span {
        flex: 1; padding: 12px; color: var(--primary);
        font-size: 20px; font-weight: 900; letter-spacing: 3px;
        display: flex; align-items: center; justify-content: center;
    }
    .promo-modal-code-box button {
        border: none; background: var(--primary); color: #fff;
        padding: 0 18px; font-weight: 700; font-size: 13px; cursor: pointer;
        font-family: inherit; transition: 0.25s; white-space: nowrap;
    }
    .promo-modal-code-box button:hover { background: var(--primary-dark); }
    .promo-modal-code-box button.copied { background: #16a34a; }
    .promo-modal-cta {
        width: 100%; border: none; border-radius: 10px; cursor: pointer;
        background: linear-gradient(90deg, #ff6b00, #ee4d2d); color: #fff;
        font-size: 16px; font-weight: 800; padding: 14px; font-family: inherit;
        box-shadow: 0 8px 22px rgba(238, 77, 45, 0.4); transition: 0.25s;
    }
    .promo-modal-cta:hover { transform: translateY(-2px); box-shadow: 0 12px 28px rgba(238, 77, 45, 0.55); }
    .promo-modal-skip {
        display: block; margin: 12px auto 0; background: none; border: none;
        color: var(--text-muted); font-size: 13px; cursor: pointer; font-family: inherit;
        text-decoration: underline; text-underline-offset: 3px;
    }
    .promo-modal-skip:hover { color: var(--text); }
    @keyframes promoFade { from { opacity: 0; } to { opacity: 1; } }
    @keyframes promoPop {
        from { opacity: 0; transform: translateY(30px) scale(0.92); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }
    @media (max-width: 480px) {
        .promo-modal-sale { width: 92px; height: 92px; }
        .promo-modal-sale-num { font-size: 28px; }
        .promo-modal-body { padding: 20px 18px; }
    }
</style>

<div class="promo-modal" id="promoModal" aria-hidden="true">
    <div class="promo-modal-overlay" onclick="closePromoModal()"></div>
    <div class="promo-modal-card" role="dialog" aria-modal="true" aria-label="Ưu đãi đặc biệt">
        <button class="promo-modal-close" onclick="closePromoModal()" aria-label="Đóng quảng cáo">✕</button>
        <div class="promo-modal-badge">🔥 ƯU ĐÃI ĐỘC QUYỀN</div>
        <div class="promo-modal-body">
            <div class="promo-modal-sale">
                <span class="promo-modal-sale-num">40%</span>
                <span class="promo-modal-sale-label">GIẢM GIÁ</span>
            </div>
            <h3 class="promo-modal-title">Linh Kiện Xe Máy Chính Hãng</h3>
            <p class="promo-modal-desc">Ưu đãi tháng 10 – Giảm đến 40% toàn bộ phụ tùng động cơ. Nhập mã dưới đây khi thanh toán để nhận giảm giá!</p>
            <span class="promo-modal-code-label">Mã giảm giá</span>
            <div class="promo-modal-code-box">
                <span id="promoCodeText">VANDON40</span>
                <button type="button" id="promoCopyBtn" onclick="copyPromoCode()">Sao chép</button>
            </div>
            <button class="promo-modal-cta" onclick="promoGoShopping()">🛒 Mua Ngay</button>
            <button class="promo-modal-skip" onclick="closePromoModal()">Để sau</button>
        </div>
    </div>
</div>

<!-- POPUP QUANG CAO SAN PHAM DANG BAN -->
<style>
    .sale-ad { position: fixed; inset: 0; z-index: 999999; display: none; align-items: center; justify-content: center; padding: 20px; }
    .sale-ad.show { display: flex; }
    .sale-ad-overlay {
        position: absolute; inset: 0; background: rgba(0, 0, 0, 0.78);
        backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px);
        animation: promoFade 0.3s ease;
    }
    .sale-ad-card {
        position: relative; width: 100%; max-width: 560px;
        background: linear-gradient(160deg, #1e1e22, #141416);
        border: 1px solid rgba(255, 107, 0, 0.35);
        border-radius: 16px; overflow: hidden;
        box-shadow: 0 25px 60px rgba(0, 0, 0, 0.65);
        animation: promoPop 0.4s cubic-bezier(.2, .9, .3, 1.2);
    }
    .sale-ad-card::before {
        content: ''; position: absolute; top: -60px; right: -60px;
        width: 200px; height: 200px; border-radius: 50%;
        background: radial-gradient(circle, rgba(255, 107, 0, 0.35), transparent 70%);
        pointer-events: none;
    }
    .sale-ad-body { padding: 22px 22px 22px; position: relative; z-index: 2; }
    .sale-ad-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin: 16px 0 18px; }
    .sale-ad-item {
        display: flex; gap: 10px; align-items: center; text-decoration: none;
        background: #1a1a1a; border: 1px solid #2c2c2c; border-radius: 10px;
        padding: 8px; transition: 0.2s;
    }
    .sale-ad-item:hover { border-color: var(--primary); transform: translateY(-2px); }
    .sale-ad-item img { width: 58px; height: 58px; object-fit: cover; border-radius: 8px; background: #333; flex-shrink: 0; }
    .sale-ad-item-info { min-width: 0; }
    .sale-ad-item-name {
        color: #fff; font-size: 13px; font-weight: 600; line-height: 1.3;
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
    }
    .sale-ad-item-price { color: var(--primary); font-weight: 800; font-size: 14px; }
    .sale-ad-item-old { color: #888; text-decoration: line-through; font-size: 12px; margin-left: 6px; }
    .sale-ad-item-off {
        display: inline-block; background: linear-gradient(90deg, #ff6b00, #ee4d2d); color: #fff;
        font-size: 10px; font-weight: 800; padding: 1px 6px; border-radius: 6px; margin-top: 4px;
    }
    @media (max-width: 480px) {
        .sale-ad-grid { grid-template-columns: 1fr; }
        .sale-ad-body { padding: 18px 16px; }
    }
</style>

<div class="sale-ad" id="saleAdModal" aria-hidden="true">
    <div class="sale-ad-overlay" onclick="closeSaleAd()"></div>
    <div class="sale-ad-card" role="dialog" aria-modal="true" aria-label="Sản phẩm đang bán">
        <button class="promo-modal-close" onclick="closeSaleAd()" aria-label="Đóng quảng cáo">✕</button>
        <div class="promo-modal-badge">🔥 SẢN PHẨM ĐANG KHUYẾN MÃI</div>
        <div class="sale-ad-body">
            <h3 class="promo-modal-title" style="text-align:center;margin-top:14px;">Ưu đãi hot hôm nay</h3>
            <p class="promo-modal-desc" style="text-align:center;margin-bottom:0;">Số lượng có hạn – nhanh tay chốt đơn!</p>
            <div class="sale-ad-grid" id="saleAdGrid">
                <div style="grid-column: 1 / -1; text-align: center; color: #888; padding: 24px;">Đang tải sản phẩm...</div>
            </div>
            <button class="promo-modal-cta" onclick="saleAdGoShopping()">🛒 Xem tất cả sản phẩm</button>
            <button class="promo-modal-skip" onclick="closeSaleAd()">Để sau</button>
        </div>
    </div>
</div>

<script>
    (function () {
        var PROMO_KEY = 'vandon_promo_shown';
        var SALEAD_KEY = 'vandon_salead_shown';
        var PROMO_CODE = 'VANDON40';
        var DELAY = 900;

        function showPromo() {
            var modal = document.getElementById('promoModal');
            if (!modal) return;
            modal.classList.add('show');
            modal.setAttribute('aria-hidden', 'false');
            document.body.style.overflow = 'hidden';
        }

        window.closePromoModal = function () {
            var modal = document.getElementById('promoModal');
            if (!modal) return;
            modal.classList.remove('show');
            modal.setAttribute('aria-hidden', 'true');
            document.body.style.overflow = '';
            try { sessionStorage.setItem(PROMO_KEY, '1'); } catch (e) { }
        };

        window.copyPromoCode = function () {
            var btn = document.getElementById('promoCopyBtn');
            function done() {
                if (btn) {
                    btn.textContent = 'Đã sao chép ✓';
                    btn.classList.add('copied');
                    setTimeout(function () {
                        btn.textContent = 'Sao chép';
                        btn.classList.remove('copied');
                    }, 2000);
                }
                if (typeof showToast === 'function') showToast('📋 Đã sao chép mã: ' + PROMO_CODE, 'success');
            }
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(PROMO_CODE).then(done).catch(done);
            } else {
                var ta = document.createElement('textarea');
                ta.value = PROMO_CODE;
                document.body.appendChild(ta);
                ta.select();
                try { document.execCommand('copy'); } catch (e) { }
                document.body.removeChild(ta);
                done();
            }
        };

        window.promoGoShopping = function () {
            window.closePromoModal();
            var target = document.getElementById('san-pham');
            if (target) target.scrollIntoView({ behavior: 'smooth' });
        };

        // ----- POPUP UU DAI MA GIAM GIA -----
        // Hoi server: tai khoan da dung ma nay chua? Neu da dung thi khong hien uu dai nua.
        window.vandonShowPromoIfEligible = function () {
            var shown = false;
            try { shown = sessionStorage.getItem(PROMO_KEY) === '1'; } catch (e) { }
            if (shown) return;

            fetch('api/MaGiamGiaApi.ashx?action=promo&maCode=' + encodeURIComponent(PROMO_CODE), { credentials: 'same-origin' })
                .then(function (r) { return r.json(); })
                .then(function (json) {
                    if (json && json.show === false) return;
                    setTimeout(showPromo, DELAY);
                })
                .catch(function () {
                    setTimeout(showPromo, DELAY);
                });
        };

        // ----- POPUP QUANG CAO SAN PHAM DANG BAN -----
        function showSaleAd() {
            var modal = document.getElementById('saleAdModal');
            if (!modal) return;
            modal.classList.add('show');
            modal.setAttribute('aria-hidden', 'false');
            document.body.style.overflow = 'hidden';
        }

        window.closeSaleAd = function () {
            var modal = document.getElementById('saleAdModal');
            if (!modal) return;
            modal.classList.remove('show');
            modal.setAttribute('aria-hidden', 'true');
            document.body.style.overflow = '';
            try { sessionStorage.setItem(SALEAD_KEY, '1'); } catch (e) { }
            // Sau khi dong quang cao san pham, hien uu dai ma giam gia (neu con hieu luc)
            window.vandonShowPromoIfEligible();
        };

        window.saleAdGoShopping = function () {
            try { sessionStorage.setItem(SALEAD_KEY, '1'); } catch (e) { }
            window.location.href = 'SanPham.aspx';
        };

        // Lay danh sach san pham dang ban: uu tien san pham giam gia, roi den san pham hot
        function taiSanPhamQuangCao() {
            return fetch('api/LinhKienApi.ashx', { credentials: 'same-origin' })
                .then(function (r) { return r.json(); })
                .then(function (json) {
                    if (!json || !json.success) return [];
                    var all = (json.data || []).filter(function (p) { return p.stock > 0; });
                    var list = all.filter(function (p) { return p.isSale; });
                    if (list.length < 2) {
                        list = list.concat(all.filter(function (p) { return !p.isSale && p.isHot; }));
                    }
                    if (list.length === 0) list = all;
                    return list.slice(0, 4);
                })
                .catch(function () { return []; });
        }

        function renderSaleAd(list) {
            var grid = document.getElementById('saleAdGrid');
            if (!grid) return;
            grid.innerHTML = list.map(function (p) {
                var oldPrice = (p.oldPrice && p.oldPrice > p.price) ? p.oldPrice : 0;
                var oldHtml = oldPrice ? '<span class="sale-ad-item-old">' + formatVND(oldPrice) + '</span>' : '';
                var off = (oldPrice && p.price > 0) ? Math.round((1 - p.price / oldPrice) * 100) : 0;
                var offHtml = off > 0 ? '<span class="sale-ad-item-off">-' + off + '%</span>' : '';
                var img = p.img || 'images/anh_dai_dien.jpg';
                return '<a class="sale-ad-item" href="ChiTietSanPham.aspx?id=' + p.id + '">' +
                    '<img src="' + img + '" alt="" onerror="this.src=\'images/anh_dai_dien.jpg\'">' +
                    '<div class="sale-ad-item-info">' +
                        '<div class="sale-ad-item-name">' + p.name + '</div>' +
                        '<div><span class="sale-ad-item-price">' + formatVND(p.price) + '</span>' + oldHtml + '</div>' +
                        offHtml +
                    '</div></a>';
            }).join('');
        }

        document.addEventListener('keydown', function (e) {
            if (e.key !== 'Escape') return;
            var sa = document.getElementById('saleAdModal');
            if (sa && sa.classList.contains('show')) { window.closeSaleAd(); return; }
            var modal = document.getElementById('promoModal');
            if (modal && modal.classList.contains('show')) window.closePromoModal();
        });

        document.addEventListener('DOMContentLoaded', function () {
            var saleShown = false;
            try { saleShown = sessionStorage.getItem(SALEAD_KEY) === '1'; } catch (e) { }

            if (saleShown) {
                window.vandonShowPromoIfEligible();
                return;
            }

            taiSanPhamQuangCao().then(function (list) {
                if (list && list.length) {
                    renderSaleAd(list);
                    setTimeout(showSaleAd, DELAY);
                } else {
                    window.vandonShowPromoIfEligible();
                }
            });
        });
    })();
</script>

<!-- WIDGET CHAT BONG BONG - KHACH HANG -->
<style>
    .chat-widget-btn {
        position: fixed; bottom: 25px; left: 25px; z-index: 9999;
        background: #ee4d2d; color: #fff; border: none; border-radius: 50px;
        padding: 12px 20px; font-weight: bold; cursor: pointer;
        box-shadow: 0 4px 15px rgba(238, 77, 45, 0.4); display: flex; align-items: center; gap: 8px;
        font-family: inherit; font-size: 14px;
    }
    .chat-widget-btn:hover {
        background: #d73a1c;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(238, 77, 45, 0.5);
    }
    .chat-box-container {
        position: fixed; bottom: 85px; left: 25px; z-index: 9999;
        width: 350px; height: 450px; background: #1e1e1e; border: 1px solid #333;
        border-radius: 12px; display: none; flex-direction: column; box-shadow: 0 5px 25px rgba(0,0,0,0.5);
        font-family: 'Outfit', Arial, sans-serif; overflow: hidden;
    }
    .chat-box-container.open {
        display: flex;
        animation: slideUpChat 0.3s ease;
    }
    @keyframes slideUpChat {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .chat-header {
        background: #2a2a2a; padding: 12px 16px; border-bottom: 1px solid #333;
        display: flex; justify-content: space-between; align-items: center; color: #fff; font-weight: bold;
    }
    .chat-messages {
        flex: 1; padding: 15px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; background: #121212;
    }
    .msg-item { max-width: 80%; padding: 8px 12px; border-radius: 8px; font-size: 14px; line-height: 1.4; word-wrap: break-word; }
    .msg-mine { align-self: flex-end; background: #ee4d2d; color: #fff; border-bottom-right-radius: 2px; }
    .msg-other { align-self: flex-start; background: #2a2a2a; color: #eee; border: 1px solid #3d3d3d; border-bottom-left-radius: 2px; }
    .msg-time { font-size: 10px; opacity: 0.7; margin-top: 4px; text-align: right; }
    .chat-footer { padding: 10px; background: #1e1e1e; border-top: 1px solid #333; display: flex; gap: 8px; }
    .chat-footer input { flex: 1; background: #2a2a2a; border: 1px solid #444; color: #fff; padding: 8px 12px; border-radius: 6px; outline: none; font-size: 14px; font-family: inherit; }
    .chat-footer input:focus { border-color: #ee4d2d; }
    .chat-footer button { background: #ee4d2d; color: #fff; border: none; padding: 8px 15px; border-radius: 6px; cursor: pointer; font-weight: bold; font-family: inherit; }
    .chat-footer button:hover { background: #d73a1c; }
    .chat-close-btn { background: none; border: none; color: #aaa; font-size: 18px; cursor: pointer; padding: 4px; }
    .chat-close-btn:hover { color: #ef4444; }
    .chat-widget-badge {
        background: #fff; color: #ee4d2d; font-size: 12px; font-weight: 800;
        min-width: 20px; height: 20px; border-radius: 10px; padding: 0 6px;
        display: none; align-items: center; justify-content: center;
    }
    .chat-widget-badge.show { display: inline-flex; }
</style>

<button class="chat-widget-btn" onclick="toggleChatBox()">
    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
    Chat với Cửa Hàng
    <span class="chat-widget-badge" id="chatUnreadBadge">0</span>
</button>

<div class="chat-box-container" id="chatBox">
    <div class="chat-header">
        <span>💬 Hỗ Trợ Khách Hàng</span>
        <button class="chat-close-btn" onclick="toggleChatBox()">✕</button>
    </div>
    <div class="chat-messages" id="chatMessages">
        <div style="text-align:center; color:#888; font-size:13px; margin-top:20px;">Đang kết nối...</div>
    </div>
    <div class="chat-footer">
        <input type="text" id="chatInput" placeholder="Nhập tin nhắn..." onkeypress="if(event.key==='Enter') sendChatMessage()" />
        <button onclick="sendChatMessage()">Gửi</button>
    </div>
</div>

<script>
    let currentMaPhienChat = null;
    let myUserId = null;
    let chatInterval = null;
    let unreadInterval = null;

    function capNhatBadgeKhach(tong) {
        const badge = document.getElementById('chatUnreadBadge');
        if (!badge) return;
        if (tong > 0) {
            badge.textContent = tong > 99 ? '99+' : tong;
            badge.classList.add('show');
        } else {
            badge.classList.remove('show');
            badge.textContent = '0';
        }
    }

    // Chỉ đọc số tin chưa đọc, không đánh dấu đã đọc — dùng khi hộp thoại đang đóng.
    async function pollUnreadBadge() {
        try {
            const res = await fetch('api/ChatApi.ashx?action=get_unread');
            const data = await res.json();
            if (data.success) {
                if (data.maPhienChat) currentMaPhienChat = data.maPhienChat;
                capNhatBadgeKhach(data.tongChuaDoc || 0);
            } else if (data.message === "not_logged_in") {
                // Khách vãng lai: dừng poll cho tới khi đăng nhập và mở lại hộp thoại.
                if (unreadInterval) clearInterval(unreadInterval);
                unreadInterval = null;
            }
        } catch (e) { console.log('Lỗi tải badge:', e); }
    }

    async function toggleChatBox() {
        const box = document.getElementById('chatBox');
        if (box.classList.contains('open')) {
            box.classList.remove('open');
            clearInterval(chatInterval);
            // Hộp thoại đóng: chuyển sang chế độ chỉ báo badge.
            if (unreadInterval) clearInterval(unreadInterval);
            pollUnreadBadge();
            unreadInterval = setInterval(pollUnreadBadge, 5000);
        } else {
            box.classList.add('open');
            if (unreadInterval) clearInterval(unreadInterval);
            await initChatSession();
            // Đã mở hộp thoại nên không còn tin nào chưa đọc phía khách.
            capNhatBadgeKhach(0);
            chatInterval = setInterval(fetchChatMessages, 2500);
        }
    }

    async function initChatSession() {
        try {
            const res = await fetch('api/ChatApi.ashx?action=get_or_create_session');
            const data = await res.json();
            if (data.message === "not_logged_in") {
                document.getElementById('chatMessages').innerHTML = '<div style="color:#ee4d2d; text-align:center; padding:20px;">Vui lòng <a href="Dang_nhap.aspx" style="color:#fff;text-decoration:underline;">đăng nhập</a> để chat.</div>';
                return;
            }
            if (data.success) {
                currentMaPhienChat = data.maPhienChat;
                await fetchChatMessages();
            }
        } catch (e) { console.error(e); }
    }

    async function fetchChatMessages() {
        if (!currentMaPhienChat) return;
        try {
            const res = await fetch('api/ChatApi.ashx?action=get_messages&maPhienChat=' + currentMaPhienChat);
            const json = await res.json();
            if (json.success) {
                myUserId = json.currentUserId;
                renderChatMessages(json.data);
                // get_messages đã đánh dấu đã đọc cho phía khách, nên badge về 0.
                capNhatBadgeKhach(json.soTinChuaDoc || 0);
            }
        } catch (e) { console.error(e); }
    }

    function renderChatMessages(messages) {
        const wrap = document.getElementById('chatMessages');
        if (!messages || messages.length === 0) {
            wrap.innerHTML = '<div style="text-align:center; color:#666; font-size:13px;">Hãy gửi tin nhắn đầu tiên cho cửa hàng!</div>';
            return;
        }
        let html = '';
        messages.forEach(m => {
            const isMine = m.MaNguoiGui === myUserId;
            html += '<div class="msg-item ' + (isMine ? 'msg-mine' : 'msg-other') + '">' +
                    '<div>' + escapeHtml(m.NoiDung) + '</div>' +
                    '<div class="msg-time">' + m.ThoiGianGui + '</div></div>';
        });
        wrap.innerHTML = html;
        wrap.scrollTop = wrap.scrollHeight;
    }

    async function sendChatMessage() {
        const input = document.getElementById('chatInput');
        const text = input.value.trim();
        if (!text || !currentMaPhienChat) return;
        input.value = '';
        const formData = new FormData();
        formData.append('maPhienChat', currentMaPhienChat);
        formData.append('noiDung', text);
        try {
            await fetch('api/ChatApi.ashx?action=send_message', { method: 'POST', body: formData });
            await fetchChatMessages();
        } catch (e) { console.error(e); }
    }

    function escapeHtml(text) {
        if (!text) return '';
        return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
    }

    // Widget đóng khi tải trang: kiểm tra badge ngay và lặp mỗi 5 giây.
    pollUnreadBadge();
    unreadInterval = setInterval(pollUnreadBadge, 5000);
</script>

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

<!-- TOAST -->
<div class="toast-wrap" id="toastWrap"></div>

<script src="app.js"></script>
    <script>
    // Hàm bật/tắt menu khi click vào tên người dùng
    function toggleUserMenu(event) {
        event.stopPropagation(); // Ngăn không cho sự kiện click lan ra ngoài
        const dropdown = document.querySelector('.user-dropdown');
        if(dropdown) {
            dropdown.classList.toggle('active');
        }
    }

    // Đóng menu khi người dùng click ra bất kỳ chỗ nào khác trên trang web
    document.addEventListener('click', function(event) {
        const userMenu = document.querySelector('.nav-user-menu');
        const dropdown = document.querySelector('.user-dropdown');
        
        // Nếu click ra ngoài khu vực menu thì ẩn nó đi
        if (userMenu && dropdown && !userMenu.contains(event.target)) {
            dropdown.classList.remove('active');
        }
    });
    </script>
</body>
</html>