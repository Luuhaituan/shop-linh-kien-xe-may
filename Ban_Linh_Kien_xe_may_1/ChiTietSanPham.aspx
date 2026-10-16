<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi Tiết Sản Phẩm | VanDonMotor</title>
    <link rel="stylesheet" href="style.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background: #121212; color: #fff; margin: 0; font-family: Arial, sans-serif; }
        .main-container { max-width: 1200px; margin: 20px auto; padding: 0 15px; }
        
        /* Box bao bọc toàn bộ chi tiết */
        .product-box { background: #1e1e1e; border-radius: 4px; display: flex; padding: 15px; margin-bottom: 20px; box-shadow: 0 1px 2px rgba(0,0,0,0.2); }
        
        /* === CỘT TRÁI (HÌNH ẢNH & CHIA SẺ) === */
        .col-left { width: 450px; flex-shrink: 0; padding-right: 30px; }
        .img-main-wrap { width: 100%; height: 450px; background: #000; display: flex; align-items: center; justify-content: center; margin-bottom: 15px; }
        .img-main { max-width: 100%; max-height: 100%; object-fit: contain; }
        
        /* Slider ảnh nhỏ */
        .img-thumbnails { display: flex; gap: 10px; position: relative; margin-bottom: 20px; }
        .thumb-item { width: 82px; height: 82px; border: 2px solid transparent; cursor: pointer; opacity: 0.7; }
        .thumb-item:hover, .thumb-item.active { border-color: #ee4d2d; opacity: 1; }
        .thumb-item img { width: 100%; height: 100%; object-fit: cover; }
        .thumb-nav { position: absolute; top: 50%; transform: translateY(-50%); background: rgba(0,0,0,0.5); color: white; border: none; padding: 10px 5px; cursor: pointer; z-index: 2; }
        .thumb-prev { left: 0; } .thumb-next { right: 0; }
        
        /* Chia sẻ & Yêu thích */
        .share-wrap { display: flex; justify-content: center; align-items: center; gap: 20px; font-size: 14px; color: #bbb; }
        .social-icons { display: flex; gap: 5px; align-items: center; }
        .social-icons span { display: inline-block; width: 20px; height: 20px; border-radius: 50%; color: white; text-align: center; line-height: 20px; font-size: 12px; font-weight: bold; cursor: pointer; }
        .ic-fb { background: #3b5998; } .ic-mess { background: #0084ff; } .ic-pin { background: #cb2027; } .ic-tw { background: #00aced; }
        .like-btn { display: flex; align-items: center; gap: 5px; cursor: pointer; }
        .like-btn svg { width: 18px; height: 18px; fill: #ff424f; }

        /* === CỘT PHẢI (THÔNG TIN & ĐẶT HÀNG) === */
        .col-right { flex-grow: 1; display: flex; flex-direction: column; }
        .prod-title { font-size: 20px; font-weight: 500; margin: 0 0 10px 0; line-height: 1.5; }
        
        /* Đánh giá & Đã bán */
        .meta-stats { display: flex; gap: 15px; font-size: 14px; color: #777; margin-bottom: 15px; align-items: center; }
        .meta-stats span { border-right: 1px solid #444; padding-right: 15px; }
        .meta-stats span:last-child { border-right: none; margin-left: auto; cursor: pointer; }
        
        /* Box Giá */
        .price-box { background: #242424; padding: 15px 20px; margin-bottom: 25px; display: flex; align-items: baseline; gap: 15px; }
        .old-price { color: #929292; text-decoration: line-through; font-size: 16px; }
        .current-price { color: #ee4d2d; font-size: 32px; font-weight: 500; }
        
        /* Các hàng thông tin (Vận chuyển, Phân loại, Số lượng) */
        .info-row { display: flex; margin-bottom: 25px; align-items: flex-start; }
        .info-label { width: 110px; color: #888; font-size: 14px; padding-top: 5px; flex-shrink: 0; }
        .info-content { flex-grow: 1; font-size: 14px; color: #fff; }
        
        /* Vận chuyển */
        .shipping-info { display: flex; flex-direction: column; gap: 8px; }
        .ship-highlight { color: #26aa99; display: flex; align-items: center; gap: 5px; }
        
        /* Nút Phân loại */
        .variant-list { display: flex; gap: 10px; flex-wrap: wrap; }
        .variant-btn { background: #1e1e1e; border: 1px solid #444; padding: 6px 12px; color: #fff; cursor: pointer; display: flex; align-items: center; gap: 8px; border-radius: 2px; }
        .variant-btn:hover { border-color: #ee4d2d; color: #ee4d2d; }
        .variant-btn.active { border-color: #ee4d2d; color: #ee4d2d; }
        
        /* Số lượng */
        .qty-wrap { display: flex; align-items: center; gap: 15px; }
        .qty-control { display: flex; border: 1px solid #444; border-radius: 2px; }
        .qty-btn { background: transparent; color: #fff; border: none; width: 32px; height: 32px; cursor: pointer; font-size: 16px; display: flex; justify-content: center; align-items: center; }
        .qty-input { width: 50px; text-align: center; background: transparent; border: none; color: #fff; border-left: 1px solid #444; border-right: 1px solid #444; outline: none; }
        .stock-txt { color: #888; }
        
        /* Action Buttons */
        .action-btns { display: flex; gap: 15px; margin-top: 20px; }
        .btn-add { background: rgba(238, 77, 45, 0.1); color: #ee4d2d; border: 1px solid #ee4d2d; padding: 0 20px; height: 48px; font-size: 15px; cursor: pointer; border-radius: 2px; display: flex; align-items: center; gap: 8px; }
        .btn-add:hover { background: rgba(238, 77, 45, 0.2); }
        .btn-buy { background: #ee4d2d; color: #fff; border: none; padding: 0 40px; height: 48px; font-size: 15px; cursor: pointer; border-radius: 2px; }
        .btn-buy:hover { background: #d73a1c; }

        /* Box Mô tả */
        .desc-box { background: #1e1e1e; padding: 25px; border-radius: 4px; box-shadow: 0 1px 2px rgba(0,0,0,0.2); margin-bottom: 40px; }
        .desc-header { background: #242424; padding: 15px; margin: -25px -25px 20px -25px; font-size: 18px; font-weight: normal; color: #fff; border-bottom: 1px solid #333;}
        .desc-content { color: #ccc; line-height: 1.8; white-space: pre-wrap; font-size: 14px; }

        /* === Box Đánh Giá === */
        .review-box { margin-bottom: 40px; }
        .review-header { display: flex; align-items: center; gap: 15px; margin-bottom: 20px; }
        .review-header h2 { font-size: 18px; color: #fff; margin: 0; font-weight: normal; }
        
        /* Star Rating Form */
        .review-form { background: #242424; padding: 20px; border-radius: 4px; margin-bottom: 20px; border: 1px solid #333; }
        .star-rating { display: inline-flex; flex-direction: row-reverse; gap: 5px; font-size: 24px; cursor: pointer; color: #444; }
        .star-rating input { display: none; }
        .star-rating label { cursor: pointer; transition: color 0.2s; }
        .star-rating label:hover, .star-rating label:hover ~ label, .star-rating input:checked ~ label { color: #ffce3d; }
        
        .review-input { width: 100%; box-sizing: border-box; background: #1e1e1e; border: 1px solid #444; color: #fff; padding: 12px; border-radius: 4px; margin-top: 15px; min-height: 80px; resize: vertical; outline: none; font-family: inherit; }
        .review-input:focus { border-color: #ee4d2d; }
        .btn-submit-review { background: #ee4d2d; color: #fff; border: none; padding: 10px 25px; cursor: pointer; border-radius: 2px; margin-top: 10px; font-size: 14px; }
        .btn-submit-review:hover { background: #d73a1c; }

        /* Review List */
        .review-item { border-bottom: 1px solid #333; padding: 15px 0; display: flex; gap: 15px; }
        .review-item:last-child { border-bottom: none; }
        .reviewer-avatar { width: 40px; height: 40px; border-radius: 50%; background: #444; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #fff; flex-shrink: 0; }
        .review-content { flex-grow: 1; }
        .reviewer-name { font-size: 14px; color: #fff; margin-bottom: 5px; font-weight: 500; }
        .review-stars { color: #ffce3d; font-size: 12px; margin-bottom: 8px; }
        .review-text { font-size: 14px; color: #ccc; line-height: 1.5; }
        .review-time { font-size: 12px; color: #777; margin-top: 5px; }
    </style>
</head>
<body>

    <!-- NAVBAR CHUẨN (Từ app.js) -->
    <nav class="navbar" id="navbar">
      <div class="nav-inner">
        <a href="index.aspx" class="logo">
          <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />
          <span class="brand">VanDon<span class="accent">Motor</span></span>
        </a>

        <div class="search-wrap">
          <input type="text" id="mainSearchInput" placeholder="Tìm linh kiện, phụ tùng, hãng xe..."/>
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
          <% } %>
        </div>
      </div>

    </nav>

    <!-- NỘI DUNG CHI TIẾT SẢN PHẨM -->
    <div class="btn-back-container">
        <button class="btn-back" onclick="window.history.back()">
            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 12H5"></path>
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 19l-7-7 7-7"></path>
            </svg>
            Quay lại
        </button>
    </div>
    <div class="main-container" id="spContent">
        <div style="text-align:center; padding:100px; color:#888; font-size: 20px;">Đang tải thông tin sản phẩm...</div>
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

    <!-- CART SIDEBAR & TOAST -->
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
    <div class="toast-wrap" id="toastWrap"></div>

    <!-- Script chung -->
    <script src="app.js"></script> 
    
    <script>
        let currentSP = null;

        function formatTien(n) { return n ? parseInt(n).toLocaleString('vi-VN') + ' ₫' : '0 ₫'; }

        // Dropdown menu
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
            const urlParams = new URLSearchParams(window.location.search);
            const id = urlParams.get('id');

            if (!id) {
                document.getElementById('spContent').innerHTML = "<div style='color:red; text-align:center;'>Không tìm thấy mã sản phẩm!</div>";
                return;
            }

            try {
                const res = await fetch(`api/ChiTietSPApi.ashx?id=${id}`);
                const json = await res.json();

                if (json.success) {
                    currentSP = json.data;
                    renderSanPham(currentSP);
                } else {
                    document.getElementById('spContent').innerHTML = `<div style='color:red; text-align:center; padding: 50px;'>${json.message}</div>`;
                }
            } catch (error) {
                document.getElementById('spContent').innerHTML = "<div style='color:red; text-align:center; padding: 50px;'>Lỗi kết nối máy chủ!</div>";
            }
        });

        function renderSanPham(sp) {
            const wrap = document.getElementById('spContent');
            const giaCu = sp.GiaBan * 1.25; // Hiển thị giá cũ làm màu

            // Vẽ UI giống y hệt Shopee Dark Mode
            wrap.innerHTML = `
                <div class="product-box">
                    <!-- CỘT TRÁI -->
                    <div class="col-left">
                        <div class="img-main-wrap">
                            <img src="${sp.HinhAnh}" class="img-main" id="mainImage" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'450\\' height=\\'450\\'%3E%3Crect width=\\'450\\' height=\\'450\\' fill=\\'%23333\\'/%3E%3C/svg%3E'"/>
                        </div>
                        
                        <!-- Vì CSDL của bạn chỉ có 1 ảnh, nên mình lặp lại ảnh đó để tạo giao diện Slider giống ảnh mẫu -->
                        <div class="img-thumbnails">
                            <button class="thumb-nav thumb-prev">‹</button>
                            <div class="thumb-item active"><img src="${sp.HinhAnh}"></div>
                            <div class="thumb-item"><img src="${sp.HinhAnh}"></div>
                            <div class="thumb-item"><img src="${sp.HinhAnh}"></div>
                            <div class="thumb-item"><img src="${sp.HinhAnh}"></div>
                            <div class="thumb-item"><img src="${sp.HinhAnh}"></div>
                            <button class="thumb-nav thumb-next">›</button>
                        </div>

                        <div class="share-wrap">
                            
                            
                        </div>
                    </div>

                    <!-- CỘT PHẢI -->
                    <div class="col-right">
                        <h1 class="prod-title">${sp.TenLinhKien}</h1>
                        
                        <div class="meta-stats">
                            <span id="soDanhGia">0 Đánh Giá</span>
                            <span>Đã Bán ${sp.DaBan != null ? sp.DaBan : 0}</span> <!-- Đã sửa -->
                            <span style="color:#999;">Tố cáo</span>
                        </div>

                        <div class="price-box">
                            <div class="old-price">${formatTien(giaCu)}</div>
                            <div class="current-price">${formatTien(sp.GiaBan)}</div>
                        </div>

                        <div class="info-row">
                            <div class="info-label">Vận Chuyển</div>
                            <div class="info-content shipping-info">
                                <div class="ship-highlight">
                                    <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M0 3.5A1.5 1.5 0 0 1 1.5 2h9A1.5 1.5 0 0 1 12 3.5V5h1.02a1.5 1.5 0 0 1 1.17.563l1.481 1.85a1.5 1.5 0 0 1 .329.938V10.5a1.5 1.5 0 0 1-1.5 1.5H14a2 2 0 1 1-4 0H5a2 2 0 1 1-3.998-.085A1.5 1.5 0 0 1 0 10.5v-7zm1.294 7.456A1.999 1.999 0 0 1 4.732 11h5.536a2.01 2.01 0 0 1 .732-.732V3.5a.5.5 0 0 0-.5-.5h-9a.5.5 0 0 0-.5.5v7a.5.5 0 0 0 .294.456zM12 10a2 2 0 0 1 1.732 1h.768a.5.5 0 0 0 .5-.5V8.35a.5.5 0 0 0-.11-.312l-1.48-1.85A.5.5 0 0 0 13.02 6H12v4zm-9 1a1 1 0 1 0 0 2 1 1 0 0 0 0-2zm9 0a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/></svg>
                                    Miễn phí vận chuyển
                                </div>
                                <div style="color: #bbb; padding-left: 20px;">Phí ship 0₫</div>
                            </div>
                        </div>

                        <div class="info-row">
                            <div class="info-label">Chọn</div>
                            <div class="info-content">
                                <div class="variant-list">
                                    <button class="variant-btn active">Mặc định</button>
                                </div>
                            </div>
                        </div>

                        <!-- 👉 LOGIC MỚI: Ẩn thanh tăng/giảm số lượng và Khóa nút nếu Hết Hàng -->
                        ${sp.SoLuongTon <= 0
                    ? `
                        <div class="info-row" style="align-items: center;">
                            <div class="info-content">
                                <div class="stock-txt" style="color: #ef233c; font-weight: bold; font-size: 16px;">
                                    ❌ Sản phẩm này hiện đang hết hàng
                                </div>
                            </div>
                        </div>
                        <div class="action-btns">
                            <button class="btn-buy" style="background: #444; color: #888; cursor: not-allowed; width: 100%;" disabled>
                                SẢN PHẨM ĐÃ HẾT HÀNG
                            </button>
                        </div>
                        `
                    : `
                        <div class="info-row" style="align-items: center;">
                            <div class="info-label">Số Lượng</div>
                            <div class="info-content qty-wrap">
                                <div class="qty-control">
                                    <button class="qty-btn" onclick="changeQty(-1)">-</button>
                                    <input type="text" id="txtQty" class="qty-input" value="1" onblur="checkQty(this, ${sp.SoLuongTon})">
                                    <button class="qty-btn" onclick="changeQty(1)">+</button>
                                </div>
                                <div class="stock-txt">${sp.SoLuongTon} sản phẩm có sẵn</div>
                            </div>
                        </div>

                        <div class="action-btns">
                            <button class="btn-add" onclick="addSPToCart(${sp.MaLinhKien})">
                                <svg width="20" height="20" fill="currentColor" viewBox="0 0 256 256"><path d="M222.14,58.87A8,8,0,0,0,216,56H54.68L49.79,29.14A16,16,0,0,0,34.05,16H16a8,8,0,0,0,0,16h18L59.56,172.29a24,24,0,0,0,5.33,11.27,28,28,0,1,0,44.4,8.44h45.42a28,28,0,1,0,42.95-12.91L212,74A8,8,0,0,0,222.14,58.87ZM88,216a12,12,0,1,1,12-12A12,12,0,0,1,88,216Zm96,0a12,12,0,1,1,12-12A12,12,0,0,1,184,216Zm12.63-54.85A8,8,0,0,0,192,152H76.41l-14.53-80H203Z"></path></svg>
                                Thêm Vào Giỏ Hàng
                            </button>
                            <button class="btn-buy" onclick="buyNow(${sp.MaLinhKien})">Mua Ngay</button>
                        </div>
                        `}
                    </div>
                </div>

                <!-- Box Mô tả -->
                <div class="desc-box">
                    <div class="desc-header">CHI TIẾT SẢN PHẨM</div>
                    <div class="desc-content">${sp.MoTa || 'Đang cập nhật mô tả chi tiết...'}</div>
                </div>

                <!-- Box Đánh giá -->
                <div class="desc-box review-box">
                    <div class="desc-header">ĐÁNH GIÁ SẢN PHẨM</div>

                    <div class="review-form">
                        <div style="font-size: 14px; margin-bottom: 5px; color: #ccc;">Bạn đánh giá sao về sản phẩm này?</div>
                        <div class="star-rating">
                            <input type="radio" id="star5" name="rating" value="5"><label for="star5">★</label>
                            <input type="radio" id="star4" name="rating" value="4"><label for="star4">★</label>
                            <input type="radio" id="star3" name="rating" value="3"><label for="star3">★</label>
                            <input type="radio" id="star2" name="rating" value="2"><label for="star2">★</label>
                            <input type="radio" id="star1" name="rating" value="1"><label for="star1">★</label>
                        </div>
                        <textarea id="txtReview" class="review-input" placeholder="Hãy chia sẻ nhận xét của bạn về chất lượng phụ tùng, dịch vụ..."></textarea>
                        <button class="btn-submit-review" onclick="submitReview(${sp.MaLinhKien})">Gửi Đánh Giá</button>
                    </div>

                    <div id="reviewList" style="margin-top: 20px;">
                        <div style="text-align: center; color: #888; padding: 20px;">Đang tải đánh giá...</div>
                    </div>
                </div>
            `;
            loadReviews(sp.MaLinhKien);
        }

        // Tăng giảm số lượng
        function changeQty(delta) {
            const inp = document.getElementById('txtQty');
            let val = parseInt(inp.value);
            if (isNaN(val)) val = 1;
            val += delta;
            if (val < 1) val = 1;
            if (val > currentSP.SoLuongTon) val = currentSP.SoLuongTon;
            inp.value = val;
        }

        function checkQty(inp, max) {
            let val = parseInt(inp.value);
            if (isNaN(val) || val < 1) inp.value = 1;
            if (val > max) inp.value = max;
        }

        // Mua hàng (dùng API từ app.js)
        function addSPToCart(id) {
            const qty = parseInt(document.getElementById('txtQty').value) || 1;
            if (typeof addToCart === 'function') {
                addToCart(id, qty); // Truyền thêm biến qty (số lượng) vào hàm
                setTimeout(openCart, 500);
            }
        }

        async function buyNow(id) {
            const qty = parseInt(document.getElementById('txtQty').value) || 1;

            try {
                const res = await fetch(`api/GioHangApi.ashx?action=add&id=${id}&qty=${qty}`, { method: 'POST' });
                const json = await res.json();

                if (json.success) {
                    window.location.href = 'ThanhToan.aspx';
                }
                // Xử lý khi chưa đăng nhập
                else if (json.message === "not_logged_in") {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Chưa đăng nhập',
                        text: 'Vui lòng đăng nhập để tiến hành mua hàng!',
                        timer: 1500, // Hiện 1.5 giây rồi tự chuyển trang
                        showConfirmButton: false
                    }).then(() => {
                        window.location.href = 'Dang_nhap.aspx';
                    });
                }
                else {
                    Swal.fire('Lỗi', json.message, 'error');
                }
            } catch (error) {
                console.error("Lỗi kết nối:", error);
                Swal.fire('Lỗi', 'Không thể kết nối máy chủ', 'error');
            }
        }

        async function loadReviews(maLinhKien) {
            const listWrap = document.getElementById('reviewList');
            try {
                const res = await fetch(`api/DanhGiaApi.ashx?action=get&id=${maLinhKien}`);
                const json = await res.json();

                if (json.success && json.data.length > 0) {
                    // 1. Cập nhật số đếm lên UI
                    let soDanhGiaElem = document.getElementById('soDanhGia');
                    if (soDanhGiaElem) soDanhGiaElem.innerHTML = `<span style="color: #ee4d2d;">${json.data.length}</span> Đánh Giá`;

                    // 2. Vẽ danh sách bình luận
                    listWrap.innerHTML = json.data.map(r => {
                        let tenUser = r.HoTen ? r.HoTen : "Khách Hàng";
                        let chuCaiDau = tenUser.charAt(0).toUpperCase();

                        return `
                <div class="review-item">
                    <div class="reviewer-avatar">${chuCaiDau}</div>
                    <div class="review-content">
                        <div class="reviewer-name">${tenUser}</div>
                        <div class="review-stars">${'★'.repeat(r.SoSao)}${'☆'.repeat(5 - r.SoSao)}</div>
                        <div class="review-text">${r.NoiDung}</div>
                        <div class="review-time">${r.NgayTao}</div>
                    </div>
                </div>
                `;
                    }).join('');
                } else {
                    // 3. Nếu không có bình luận nào
                    let soDanhGiaElem = document.getElementById('soDanhGia');
                    if (soDanhGiaElem) soDanhGiaElem.innerText = 'Chưa Có Đánh Giá';

                    listWrap.innerHTML = '<div style="color:#777; text-align:center; padding:20px;">Chưa có đánh giá nào cho sản phẩm này. Hãy là người đầu tiên đánh giá!</div>';
                }
            } catch (e) {
                console.error(e);
                listWrap.innerHTML = '<div style="color:#ef233c; text-align:center;">Lỗi kết nối khi tải đánh giá.</div>';
            }
        }

        async function submitReview(maLinhKien) {
            const ratingInput = document.querySelector('input[name="rating"]:checked');
            const noiDung = document.getElementById('txtReview').value.trim();

            if (!ratingInput) {
                Swal.fire('Thiếu thông tin', 'Vui lòng chọn số sao đánh giá!', 'warning');
                return;
            }
            if (noiDung === '') {
                Swal.fire('Thiếu thông tin', 'Vui lòng nhập nội dung đánh giá!', 'warning');
                return;
            }

            const soSao = ratingInput.value;

            try {
                // Gửi dữ liệu lên API
                const res = await fetch('api/DanhGiaApi.ashx?action=add', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `maLinhKien=${maLinhKien}&soSao=${soSao}&noiDung=${encodeURIComponent(noiDung)}`
                });

                const json = await res.json();

                if (json.success) {
                    Swal.fire('Thành công', 'Cảm ơn bạn đã đánh giá sản phẩm!', 'success');
                    document.getElementById('txtReview').value = '';
                    document.querySelector('input[name="rating"]:checked').checked = false;
                    loadReviews(maLinhKien); // Tải lại danh sách
                } else {
                    Swal.fire('Không thể đánh giá', json.message, 'error');
                }
            } catch (e) {
                console.error(e);
                Swal.fire('Lỗi', 'Có lỗi kết nối, vui lòng thử lại sau.', 'error');
            }
        }
    </script>
</body>
</html>