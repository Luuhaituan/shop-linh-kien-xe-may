// ==========================================
// FILE: auth.js
// Xử lý các hiệu ứng giao diện cho trang Đăng nhập / Đăng ký
// ==========================================

// 1. Hàm bật/tắt hiển thị mật khẩu (Hiển thị icon con mắt)
function togglePw(id, btn) {
    const inp = document.getElementById(id);
    if (!inp) return; // Nếu không tìm thấy ô input thì bỏ qua

    const isHide = inp.type === 'password';
    inp.type = isHide ? 'text' : 'password';

    // Thay đổi icon SVG (Mở mắt / Nhắm mắt)
    btn.innerHTML = isHide
        ? `<svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/></svg>`
        : `<svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>`;
} // <-- LƯU Ý: Phải đóng ngoặc hàm togglePw ở đây!


// ==========================================
// 2. CÁC HÀM XỬ LÝ MODAL (ĐIỀU KHOẢN DỊCH VỤ)
// ==========================================

// Mở Modal
function openModal(id) {
    document.getElementById(id).classList.add('show');
}

// Đóng Modal
function closeModal(id) {
    document.getElementById(id).classList.remove('show');
}

// Tự động đóng Modal khi click ra khoảng trống bên ngoài
window.onclick = function (event) {
    const modal = document.getElementById('termsModal');
    if (event.target === modal) {
        modal.classList.remove('show');
    }
}


// ==========================================
// 3. TỰ ĐỘNG ẨN THÔNG BÁO LỖI SAU 4 GIÂY
// ==========================================
document.addEventListener("DOMContentLoaded", function () {
    const alerts = document.querySelectorAll('.auth-alert');

    alerts.forEach(alert => {
        // Nếu thông báo đang được hiển thị (C# trả về lỗi)
        if (window.getComputedStyle(alert).display !== 'none') {
            setTimeout(() => {
                // Tạo hiệu ứng mờ dần rồi ẩn hẳn đi cho mượt
                alert.style.transition = 'opacity 0.5s ease';
                alert.style.opacity = '0';

                setTimeout(() => {
                    alert.style.display = 'none';
                    alert.style.opacity = '1'; // Reset lại trạng thái cho lần sau
                }, 500);
            }, 4000); // 4000ms = 4 giây
        }
    });
});