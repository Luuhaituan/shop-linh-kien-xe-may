<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dang_nhap.aspx.cs" Inherits="Ban_Linh_Kien_xe_may_1.Dang_nhap" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
    <title>Đăng Nhập | VanDonMotor</title>
    <meta name="description" content="Đăng nhập vào VanDonMotor – Cửa hàng linh kiện xe máy chính hãng"/>
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <!-- ĐÂY LÀ ĐOẠN LIÊN KẾT TỚI FILE CSS -->
    <link rel="stylesheet" href="auth.css"/>
</head>
<body>
    <div class="gears">
        <span class="gear">⚙</span>
        <span class="gear">⚙</span>
        <span class="gear">⚙</span>
    </div>

    <div class="auth-bg">
        <div class="auth-card">
            <!-- Logo -->
            <a href="index.aspx" class="auth-logo">
                <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="40" height="40" style="border-radius: 50%; object-fit: cover;" />          

                <span class="auth-logo-text">VanDon<span>Motor</span></span>
            </a>

            <h1 class="auth-title">Chào mừng trở lại!</h1>
            <p class="auth-subtitle">Đăng nhập để mua sắm và quản lý đơn hàng</p>

            <!-- Form chạy trên Server -->
            <form id="form1" runat="server">
                
                <!-- Alert thông báo lỗi từ C# -->
                <asp:Panel ID="pnlAlertError" runat="server" CssClass="auth-alert error" Visible="false">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <asp:Label ID="lblAlertMsg" runat="server" Text="Tên đăng nhập hoặc mật khẩu không đúng"></asp:Label>
                </asp:Panel>

                <!-- Input Tên đăng nhập -->
                <div class="form-group">
                    <label class="auth-label" for="txtUsername">Tên đăng nhập</label>
                    <div class="auth-input-wrap">
                        <span class="input-ico">
                            <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" width="18" height="18"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </span>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="auth-input" placeholder="Nhập tên đăng nhập..." required="true" autocomplete="username" ClientIDMode="Static"></asp:TextBox>
                    </div>
                </div>

                <!-- Input Mật khẩu -->
                <div class="form-group">
                    <label class="auth-label" for="txtPassword">Mật khẩu</label>
                    <div class="auth-input-wrap">
                        <span class="input-ico">
                            <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" width="18" height="18"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </span>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="auth-input" TextMode="Password" placeholder="Nhập mật khẩu..." required="true" autocomplete="current-password" ClientIDMode="Static"></asp:TextBox>
                        
                        <!-- Nút Show/Hide Mật khẩu -->
                        <button type="button" class="eye-btn" onclick="togglePw('txtPassword',this)" title="Hiện/Ẩn mật khẩu">
                            <svg id="eyeIcon" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                </div>

                <div style="display:flex;justify-content:flex-end;margin-bottom:20px">
                    <a href="Quen_mat_khau.aspx" style="color:var(--primary);font-size:13px;text-decoration:none">Quên mật khẩu?</a>
                </div>

                <div style="margin-bottom: 20px; display: flex; justify-content: center;">
                    <div class="g-recaptcha" data-sitekey="6LfMcn4tAAAAAHm1itcIbo9Kt3dcqA4iW6vTU_jW" data-theme="dark"></div>
                </div>

                <!-- Nút Submit gọi hàm C# -->
                <asp:LinkButton ID="btnLogin" runat="server" CssClass="btn-auth" OnClientClick="return validateLogin();" OnClick="btnLogin_Click" ClientIDMode="Static">
                    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                    Đăng Nhập
                </asp:LinkButton>
            </form>

            <div class="auth-divider">hoặc</div>

            <div class="auth-footer">
                Chưa có tài khoản? <a href="Dang_ky.aspx">Đăng ký ngay</a>
            </div>
            <div class="auth-footer" style="margin-top:10px">
                <a href="index.aspx">← Quay lại trang chủ</a>
            </div>
        </div>
    </div>

    <!-- ĐÂY LÀ ĐOẠN LIÊN KẾT TỚI FILE JS -->
    <script src="auth.js"></script>

    <script>
        function validateLogin() {
            // Kiểm tra reCAPTCHA
            const recaptchaResponse = grecaptcha.getResponse();
            if (recaptchaResponse.length === 0) {
                alert('Vui lòng xác nhận bạn không phải là robot!');
                return false; // Chặn lại, không cho form gửi về server C#
            }

            // Nếu đã tick, có thể thêm hiệu ứng loading cho nút bấm (tùy chọn)
            const btn = document.getElementById('btnLogin');
            if (btn) btn.classList.add('loading');

            return true; // Cho phép form chạy tiếp lệnh C#
        }
    </script>
    
</body>
</html>