// ── Hàm Xác thực Người dùng (Mockup thay thế auth.js) ────────
// Các hàm này giúp Navbar không bị lỗi khi gọi ở trang HTML.



// ── API Base URL ──────────────────────────────────────────────────────────────
// Khi chạy từ IIS/ASP.NET (trong thư mục giao_dien): dùng '../api'
// Khi chạy từ Python server (http.server): đổi thành '' và dùng dữ liệu fallback
const API = 'api';

// ── State ──
let products = [];
let cart = [];
let activeFilter = '';

// ── Init ──
document.addEventListener('DOMContentLoaded', async () => {
    // 1. Lấy dữ liệu sản phẩm
    await loadProductsFromDB();

    // 2. Tự động đọc tham số trên URL để bật bộ lọc (nếu có)
    const urlParams = new URLSearchParams(window.location.search);
    const catParam = urlParams.get('cat');
    if (catParam) {
        // Tìm nút tương ứng trong cột trái và bấm vào nó
        const filterBtn = document.querySelector(`.shop-sidebar .filter-btn[onclick*="'${catParam}'"]`);
        if (filterBtn) {
            filterBtn.click(); // Tự động click
        }
    }
});

// ── Load từ Database ──────────────────────────────────────────────────────────
async function loadProductsFromDB() {
    try {
        const res = await fetch(`${API}/LinhKienApi.ashx`);
        if (!res.ok) throw new Error('Lỗi mạng');

        const json = await res.json();
        if (json.success) {
            products = json.data;
            renderProducts(products);
        } else {
            console.error("Lỗi từ server:", json.message);
            document.getElementById('product-list').innerHTML = '<p style="color:red; text-align:center;">Lỗi tải dữ liệu từ máy chủ.</p>';
        }
    } catch (e) {
        console.error("Không kết nối được API:", e);
        // Hiển thị thông báo lỗi ra màn hình thay vì dùng dữ liệu giả
        document.getElementById('product-list').innerHTML = '<p style="text-align:center;">Hệ thống đang bảo trì. Vui lòng quay lại sau!</p>';
    }
}



// ── Render Products 
// ── Render Products 
function renderProducts(data) {
    const grid = document.getElementById('productGrid');
    if (!grid) return;

    if (!data.length) {
        grid.innerHTML = '<div style="text-align:center;padding:60px;color:var(--text-muted);grid-column:1/-1"><div style="font-size:48px">🔍</div><p>Không tìm thấy sản phẩm phù hợp</p></div>';
        return;
    }

    let displayData = data;
    let showMoreHTML = '';

    // 1. KIỂM TRA XEM ĐANG Ở TRANG NÀO
    const isTrangSanPham = window.location.pathname.toLowerCase().includes('sanpham.aspx');

    // 2. CHỈ GIỚI HẠN 8 SẢN PHẨM NẾU ĐANG Ở TRANG CHỦ
    if (!isTrangSanPham && data.length > 8) {
        displayData = data.slice(0, 8);

        showMoreHTML = `
        <div style="grid-column: 1 / -1; text-align: center; margin-top: 30px; margin-bottom: 20px;">
            <a href="SanPham.aspx" style="display: inline-block; padding: 12px 30px; background-color: transparent; border: 1px solid #ee4d2d; color: #ee4d2d; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer; transition: 0.3s; text-decoration: none;" onmouseover="this.style.backgroundColor='#ee4d2d'; this.style.color='#fff';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#ee4d2d';">
                Xem tất cả sản phẩm →
            </a>
        </div>
        `;
    }

    // 3. VẼ GIAO DIỆN SẢN PHẨM (ĐOẠN ĐÃ SỬA LỖI VỆT MÀU RỖNG CHỮ)
    const productsHTML = displayData.map(p => {
        // Xử lý huy hiệu (Badge) an toàn, tránh vệt màu rỗng chữ
        let activeBadge = '';
        let badgeText = '';

        if (p.stock <= 0) {
            activeBadge = 'out';
            badgeText = 'Hết Hàng';
        } else if (p.isSale) {
            activeBadge = 'sale';
            badgeText = 'Giảm Giá';
        } else if (p.isHot) {
            activeBadge = 'hot';
            badgeText = 'Hot 🔥';
        } else if (p.badge && typeof p.badge === 'string' && p.badge.trim() !== '') {
            activeBadge = p.badge.toLowerCase();
            badgeText = p.badge;
        }

        // Chỉ sinh thẻ HTML nếu có chữ thật sự
        let badgeHTML = (activeBadge && badgeText.trim() !== '')
            ? `<span class="product-badge badge-${activeBadge}" ${activeBadge === 'out' ? 'style="background:#555; color:#fff;"' : ''}>${badgeText}</span>`
            : '';

        let oldPriceHTML = '';
        if (p.oldPrice && p.oldPrice > p.price) {
            oldPriceHTML = `<span class="price-old" style="text-decoration: line-through; color: #888; font-size: 13px; margin-left: 8px;">${formatVND(p.oldPrice)}</span>`;
        }

        // Tính toán số sao
        let diem = (p.rating !== null && p.rating !== undefined) ? p.rating : 0;
        let luotDG = (p.reviews !== null && p.reviews !== undefined) ? p.reviews : 0;

        let soSaoVang = Math.round(diem);
        let soSaoXam = 5 - soSaoVang;

        let htmlSao = '<span class="stars" style="color:#ffce3d; letter-spacing: 2px;">' + '★'.repeat(soSaoVang) + '</span>' +
            '<span class="stars" style="color:#555; letter-spacing: 2px;">' + '★'.repeat(soSaoXam) + '</span>';

        // Khóa nút nếu hết hàng
        let actionBtnHTML = (p.stock <= 0)
            ? `<button class="btn-cart" style="background: #444; color: #888; cursor: not-allowed; border: none;" disabled>🚫 Hết hàng</button>`
            : `<button class="btn-cart" onclick="addToCart(${p.id})">🛒 Thêm vào giỏ</button>`;

        return `
        <div class="product-card" id="prod-${p.id}" ${p.stock <= 0 ? 'style="opacity: 0.75;"' : ''}>
          ${badgeHTML}
          
          <div class="product-img-wrap">
            <a href="ChiTietSanPham.aspx?id=${p.id}" style="display: block;">
                <img src="${p.img}" alt="${p.name}" loading="lazy" onerror="this.src='images/anh_dai_dien.jpg'"/>
            </a>
            <div class="product-actions">
              ${actionBtnHTML}
            </div>
          </div>
          
          <div class="product-info">
            <div class="product-brand">${p.brand || ''}</div>
            
            <a href="ChiTietSanPham.aspx?id=${p.id}" style="text-decoration: none; color: inherit;">
                <div class="product-name">${p.name}</div>
            </a>

            <!-- KHU VỰC HIỂN THỊ ĐÁNH GIÁ SAO ĐỘNG -->
            <div class="product-rating" style="display: flex; align-items: center; gap: 5px;">
              ${htmlSao}
              <span class="rating-count" style="margin-left: 4px; font-size: 12px; color: #999;">${diem.toFixed(1)} (${luotDG})</span>
            </div>
            
            <div class="product-price">
              <span class="price-current">${formatVND(p.price)}</span>${oldPriceHTML}
            </div>
          </div>
        </div>
      `;
    }).join('');

    // 4. GẮN VÀO LƯỚI
    grid.innerHTML = productsHTML + showMoreHTML;
}
// ── Filter ──
let currentFilters = {
    brand: '',
    category: '',
    isDiscount: false
};

// Hàm xử lý khi bấm nút lọc
function toggleFilter(btn, type, value) {
    // 1. Quản lý class 'active' trên giao diện (để hiện màu cam)
    const parentList = btn.closest('ul');

    // Nếu bấm vào nút "Tất Cả Sản Phẩm"
    if (type === 'all') {
        currentFilters = { brand: '', category: '', isDiscount: false };
        document.querySelectorAll('.shop-sidebar .filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        applyMultiFilter();
        return;
    }

    // Tắt nút "Tất Cả" nếu đang bật
    const allBtn = document.querySelector('.shop-sidebar .filter-btn[onclick*="all"]');
    if (allBtn) allBtn.classList.remove('active');

    // Nếu người dùng bấm lại vào nút đang chọn (để hủy chọn)
    if (btn.classList.contains('active')) {
        btn.classList.remove('active');
        currentFilters[type] = type === 'isDiscount' ? false : '';
    } else {
        // Hủy các nút khác cùng loại (vd: Chọn Honda thì tắt Yamaha)
        if (type !== 'isDiscount') {
            const siblings = parentList.querySelectorAll(`.filter-btn[onclick*="'${type}'"]`);
            siblings.forEach(b => b.classList.remove('active'));
        }

        btn.classList.add('active');
        currentFilters[type] = type === 'isDiscount' ? true : value;
    }
    applyMultiFilter();
}
function applyMultiFilter() {
    let filtered = products;

    if (currentFilters.brand !== '') {
        filtered = filtered.filter(p => p.brand === currentFilters.brand);
    }

    if (currentFilters.category !== '') {
        // ĐÃ SỬA: Thay dấu === thành hàm .includes() để tìm từ khóa Đa danh mục
        filtered = filtered.filter(p =>
            p.category && p.category.includes(currentFilters.category)
        );
    }

    if (currentFilters.isDiscount) {
        filtered = filtered.filter(p => p.oldPrice != null);
    }

    // Đổi tiêu đề cột phải cho ngầu
    updateShopTitle();

    // Render kết quả
    renderProducts(filtered);
}

function updateShopTitle() {
    const titleEl = document.querySelector('.shop-content h2');
    if (!titleEl) return;

    let parts = [];
    if (currentFilters.brand) parts.push(`Hãng ${currentFilters.brand}`);
    if (currentFilters.category) parts.push(`${currentFilters.category}`);
    if (currentFilters.isDiscount) parts.push(`Giảm giá`);

    titleEl.textContent = parts.length > 0
        ? `Sản Phẩm: ${parts.join(' - ')}`
        : 'Tất Cả Sản Phẩm';
}

// ── Cart ──
async function addToCart(id, qty = 1) {
    try {
        // 1. Gửi lệnh lên C# để lưu vào SQL Server
        const res = await fetch(`api/GioHangApi.ashx?action=add&id=${id}&qty=${qty}`, { method: 'POST' });
        const json = await res.json();

        // 2. Xử lý kết quả trả về từ C#
        if (json.success) {
            // Lấy tên sản phẩm để hiện thông báo cho đẹp giống code cũ của bạn
            const p = products.find(x => x.id == id);
            if (p) {
                showToast(`✅ Đã thêm "${p.name.substring(0, 30)}..." vào giỏ hàng`, 'success');
            } else {
                showToast('✅ Đã thêm sản phẩm vào giỏ hàng', 'success');
            }

            // Đồng bộ lại giỏ hàng từ SQL về giao diện ngay lập tức
            loadCartFromDB();
        }
        else if (json.message === "not_logged_in") {
            // Nếu C# phát hiện chưa đăng nhập
            showToast('⚠️ Vui lòng đăng nhập để mua hàng!', 'error');

            // Đợi 1.5 giây để khách đọc xong thông báo rồi mới chuyển trang
            setTimeout(() => {
                window.location.href = 'Dang_nhap.aspx';
            }, 1500);
        }
        else {
            showToast("❌ Có lỗi xảy ra: " + json.message, 'error');
        }
    } catch (error) {
        console.error("Lỗi khi kết nối hệ thống:", error);
        showToast("❌ Không thể kết nối tới máy chủ!", 'error');
    }
}

async function loadCartFromDB() {
    try {
        const res = await fetch(`${API}/GioHangApi.ashx?action=get`);
        const json = await res.json();

        if (json.success) {
            // Gán danh sách sản phẩm từ SQL vào biến cart của giao diện
            cart = json.data;

            // 👇 BẠN THÊM HÀM VẼ GIAO DIỆN CỦA BẠN VÀO ĐÂY ĐỂ NÓ HIỆN RA LÊN WEB:
            if (typeof updateCartUI === 'function') {
                updateCartUI(); // Hoặc thay bằng tên hàm vẽ giỏ hàng thực tế của bạn
            }
        }
    } catch (error) {
        console.error("Lỗi khi tải giỏ hàng:", error);
    }
}

// Chạy hàm này ngay khi trang web vừa tải xong
document.addEventListener("DOMContentLoaded", () => {
    loadCartFromDB();
});

function updateCartUI() {
    const total = cart.reduce((s, i) => s + i.qty, 0);
    const cartBadge = document.getElementById('cartBadge');
    const cartCount = document.getElementById('cartCount');

    if (cartBadge) cartBadge.textContent = total;
    if (cartCount) cartCount.textContent = total;

    const totalPrice = cart.reduce((s, i) => s + i.price * i.qty, 0);
    const cartTotal = document.getElementById('cartTotal');
    if (cartTotal) cartTotal.textContent = formatVND(totalPrice);

    renderCartItems();
}

function renderCartItems() {
    const wrap = document.getElementById('cartItems');
    if (!wrap) return;
    if (!cart.length) {
        wrap.innerHTML = '<div style="text-align:center;padding:60px 20px;color:var(--text-muted)"><div style="font-size:48px;margin-bottom:16px">🛒</div><p>Giỏ hàng đang trống</p></div>';
        return;
    }
    wrap.innerHTML = cart.map(item => `
    <div class="cart-item">
      <div class="cart-item-img"><img src="${item.img}" alt="${item.name}" onerror="this.style.display='none'"/></div>
      <div class="cart-item-info">
        <div class="cart-item-brand">${item.brand || ''}</div>
        <div class="cart-item-name">${item.name}</div>
        <div class="cart-item-price">${formatVND(item.price)}</div>
        <div class="qty-control">
          <button class="qty-btn" onclick="changeQty(${item.id},-1)">−</button>
          <span class="qty-num">${item.qty}</span>
          <button class="qty-btn" onclick="changeQty(${item.id},1)">+</button>
          <button class="qty-btn" onclick="removeFromCart(${item.id})" style="margin-left:8px;color:#ef4444;font-size:14px">🗑</button>
        </div>
      </div>
    </div>
  `).join('');
}

async function changeQty(id, step) {
    // 1. Tìm sản phẩm trong giỏ hàng để lấy số lượng hiện tại
    const item = cart.find(x => x.id == id);
    if (!item) return;

    // 2. Tính ra số lượng mới (Số lượng cũ + 1 hoặc - 1)
    const newQty = item.qty + step;

    // In ra kiểm tra xem tính đúng chưa
    console.log(`Đã bấm! ID: ${id} | Đang có: ${item.qty} | Sẽ đổi thành: ${newQty}`);

    // 3. Nếu số lượng mới tụt xuống 0 hoặc âm, gọi hàm Xóa
    if (newQty <= 0) {
        removeFromCart(id);
        return;
    }

    try {
        // 4. Gửi tổng số lượng mới nhất lên máy chủ C#
        const res = await fetch(`${API}/GioHangApi.ashx?action=update&id=${id}&qty=${newQty}`);
        const json = await res.json();

        if (json.success) {
            // Tải lại giỏ hàng từ SQL để nó tự động vẽ lại số lượng
            loadCartFromDB();
        } else {
            if (typeof showToast === 'function') {
                showToast("❌ Lỗi cập nhật: " + json.message, "error");
            }
        }
    } catch (error) {
        console.error("Lỗi kết nối:", error);
    }
}

async function removeFromCart(id) {
    // 1. Tìm tên sản phẩm trong giỏ hàng
    const p = cart.find(x => x.id == id);
    const tenSp = p ? p.name : "sản phẩm này";

    // 2. Hiển thị hộp thoại xác nhận siêu đẹp của SweetAlert2
    Swal.fire({
        title: 'Xóa sản phẩm?',
        text: `Bạn có chắc muốn bỏ "${tenSp}" ra khỏi giỏ hàng không?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ff5722', // Nút đồng ý màu cam xuyệt tông web
        cancelButtonColor: '#6c757d',  // Nút hủy màu xám
        confirmButtonText: 'Vâng, xóa nó!',
        cancelButtonText: 'Hủy',
        background: '#1a1a1a',         // Nền tối màu
        color: '#ffffff'               // Chữ màu trắng
    }).then(async (result) => {
        // 3. Nếu người dùng bấm nút "Vâng, xóa nó!"
        if (result.isConfirmed) {
            try {
                const res = await fetch(`${API}/GioHangApi.ashx?action=remove&id=${id}`);
                const json = await res.json();

                if (json.success) {
                    if (typeof showToast === 'function') {
                        showToast(`🗑️ Đã xóa "${tenSp}"!`, "success");
                    }

                    // Tải lại giỏ hàng từ SQL
                    loadCartFromDB();
                } else {
                    if (typeof showToast === 'function') {
                        showToast("❌ Lỗi khi xóa: " + json.message, "error");
                    }
                }
            } catch (error) {
                console.error("Lỗi kết nối khi xóa:", error);
                if (typeof showToast === 'function') {
                    showToast("❌ Không thể kết nối tới máy chủ!", "error");
                }
            }
        }
    });
}
//danh Muc
async function loadCategoriesFromDB() {
    try {
        const res = await fetch(`${API}/DanhMucApi.ashx`);
        const json = await res.json();

        if (json.success) {
            // Nhắm thẳng vào class cat-grid của bạn
            const catGrid = document.querySelector('.cat-grid');

            if (catGrid) {
                let html = '';

                // 1. Tạo "Từ điển" để tự động gắn Icon cho từng loại danh mục
                const iconMap = {
                    'Động cơ': '⚙️',
                    'Phanh': '🛑',
                    'Điện': '⚡',
                    'Truyền động': '🔗',
                    'Lọc': '🔩',
                    'Đèn': '💡',
                    'Xăm lốp': '🔄',
                    'Phụ kiện': '🛡️'
                };

                // 2. Lặp qua danh sách lấy từ SQL và vẽ giao diện
                json.data.forEach(item => {
                    // Nếu tên danh mục có trong từ điển thì lấy icon đó, không thì dùng icon mặc định 🏍️
                    const icon = iconMap[item.name] || '🏍️';

                    html += `
                    <a href="SanPham.aspx?cat=${encodeURIComponent(item.name)}" class="cat-card">
                        <span class="cat-icon">${icon}</span>
                        <div class="cat-name">${item.name}</div>
                        <div class="cat-count">Xem chi tiết →</div> 
                    </a>`;
                });

                // 3. Đổ HTML mới vào thay thế HTML cũ
                catGrid.innerHTML = html;
            }
        }
    } catch (error) {
        console.error("Lỗi khi tải danh mục:", error);
    }
}

// Chạy hàm này khi web vừa load lên (bạn có thể nhét vào chung với chỗ gọi loadProductsFromDB)
document.addEventListener("DOMContentLoaded", () => {
    loadCategoriesFromDB();
});

function openCart() {
    document.getElementById('cartOverlay').classList.add('open');
    document.getElementById('cartSidebar').classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closeCart() {
    document.getElementById('cartOverlay').classList.remove('open');
    document.getElementById('cartSidebar').classList.remove('open');
    document.body.style.overflow = '';
}

/*async function checkout() {
    try {
        // Có thể thêm hiệu ứng loading ở đây nếu muốn

        // Gọi API Đặt hàng
        const res = await fetch(`${API}/DatHangApi.ashx`);
        const json = await res.json();

        if (json.success) {
            // Thông báo thành công
            showToast(`🎉 Đặt hàng thành công! Mã đơn của bạn là: ${json.maDonHang}`, 'success');

            // Xóa rỗng giỏ hàng trên giao diện bằng cách tải lại từ SQL
            loadCartFromDB();

            // Đợi 2 giây cho khách đọc thông báo rồi đá về trang chủ
            setTimeout(() => {
                window.location.href = "index.aspx";
            }, 2000);

        } else if (json.message === "not_logged_in") {
            showToast('⚠️ Vui lòng đăng nhập để thanh toán!', 'error');
            setTimeout(() => {
                window.location.href = 'Dang_nhap.aspx';
            }, 1500);
        } else {
            // Nếu giỏ hàng trống hoặc có lỗi khác
            showToast("❌ Không thể đặt hàng: " + json.message, 'error');
        }
    } catch (error) {
        console.error("Lỗi kết nối:", error);
        showToast("❌ Không thể kết nối tới hệ thống!", 'error');
    }
}*/
function checkout() {
    // Nếu giỏ hàng trống thì báo lỗi
    if (cart.length === 0) {
        if (typeof showToast === 'function') {
            showToast('⚠️ Giỏ hàng của bạn đang trống!', 'error');
        }
        return;
    }
    // Lệnh chuyển trang sang Form Thanh Toán
    window.location.href = 'ThanhToan.aspx';
}

// ── Search ──
function handleSearch() {
    const searchInput = document.getElementById('searchInput');
    if (!searchInput) return;

    const q = searchInput.value.toLowerCase().trim();
    if (!q) { renderProducts(products); return; }

    const filtered = products.filter(p =>
        p.name.toLowerCase().includes(q) ||
        (p.brand || '').toLowerCase().includes(q) ||
        (p.category || '').toLowerCase().includes(q)
    );

    // ĐÃ SỬA: Chỉ cuộn trang nếu tìm thấy thẻ có id="san-pham"
    const khungSanPham = document.getElementById('san-pham');
    if (khungSanPham) {
        khungSanPham.scrollIntoView({ behavior: 'smooth' });
    }

    renderProducts(filtered);
}

const searchInputEl = document.getElementById('searchInput');
if (searchInputEl) {
    searchInputEl.addEventListener('keydown', e => { if (e.key === 'Enter') handleSearch(); });
}

// ── Newsletter ──
function handleSubscribe(e) {
    e.preventDefault();
    const emailInput = document.getElementById('emailInput');
    showToast(`📧 Đăng ký thành công với ${emailInput.value}!`, 'success');
    emailInput.value = '';
}

// ── Toast ──
function showToast(msg, type = 'success') {
    const wrap = document.getElementById('toastWrap');
    if (!wrap) return;

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `<span class="toast-icon">${type === 'success' ? '✅' : '❌'}</span><span>${msg}</span>`;
    wrap.appendChild(toast);
    requestAnimationFrame(() => toast.classList.add('show'));
    setTimeout(() => { toast.classList.remove('show'); setTimeout(() => toast.remove(), 400); }, 3200);
}

// ── Helpers ──
function formatVND(n) {
    return n ? parseInt(n).toLocaleString('vi-VN') + ' ₫' : '';
}


window.addEventListener('scroll', () => {
    // 1. Chỉ tìm các link bắt đầu bằng dấu # (nghĩa là đang ở trang chủ)
    const scrollLinks = document.querySelectorAll('.nav-links a[href^="#"]');
    if (scrollLinks.length === 0) return; // Nếu ở trang SanPham.aspx thì không chạy đoạn này

    // 2. Tính toán vị trí cuộn (cộng thêm 150px để bù trừ độ cao của thanh menu)
    const scrollPos = window.scrollY + 150;
    let activeId = null;

    // 3. Quét xem vị trí hiện tại đang khớp với section nào
    scrollLinks.forEach(link => {
        const section = document.querySelector(link.getAttribute('href'));
        if (section && section.offsetTop <= scrollPos) {
            activeId = link.getAttribute('href');
        }
    });

    // 4. Tắt màu cam của tất cả các nút (ngoại trừ nút Sản Phẩm)
    document.querySelectorAll('.nav-links a').forEach(link => {
        if (link.getAttribute('href') !== 'SanPham.aspx') {
            link.classList.remove('active');
        }
    });

    // 5. Bật màu cam cho mục tương ứng
    if (activeId) {
        // Đang ở trong 1 section (Danh mục, Khuyến mãi...)
        const activeLink = document.querySelector(`.nav-links a[href="${activeId}"]`);
        if (activeLink) activeLink.classList.add('active');
    } else {
        // Nếu cuộn lên trên cùng thì bật lại màu cam cho Trang Chủ
        const homeLink = document.querySelector('.nav-links a[href="index.aspx"]');
        if (homeLink) homeLink.classList.add('active');
    }
});

window.addEventListener("pageshow", function (event) {
    // Nếu event.persisted = true nghĩa là trang đang được gọi lên từ bộ nhớ đệm do ấn nút Back
    if (event.persisted) {
        window.location.reload(); // Ép F5 tải lại mới hoàn toàn
    }
});