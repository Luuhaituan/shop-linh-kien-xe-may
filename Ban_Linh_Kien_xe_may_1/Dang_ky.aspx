<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dang_ky.aspx.cs" Inherits="Ban_Linh_Kien_xe_may_1.Dang_ky" ResponseEncoding="UTF-8" ContentType="text/html; charset=utf-8" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
    <title>Đăng Ký | VanDonMotor</title>
    <link rel="stylesheet" href="auth.css"/>
    <!-- thư viện reCAPTCHA của Google -->
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <style>
        .auth-card { max-width: 500px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        @media(max-width:480px){ .form-row { grid-template-columns: 1fr; } }
    </style>
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

            <h1 class="auth-title">Tạo Tài Khoản</h1>
            <p class="auth-subtitle">Đăng ký để mua sắm và nhận ưu đãi độc quyền</p>

            <form id="form1" runat="server">
                
                <!-- Alert thông báo từ C# hoặc JS -->
                <asp:Panel ID="pnlAlertError" runat="server" CssClass="auth-alert error" ClientIDMode="Static">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <asp:Label ID="lblAlertMsg" runat="server" ClientIDMode="Static"></asp:Label>
                </asp:Panel>
                
                <asp:Panel ID="pnlAlertSuccess" runat="server" CssClass="auth-alert success" ClientIDMode="Static">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                    <asp:Label ID="lblAlertOkMsg" runat="server" ClientIDMode="Static"></asp:Label>
                </asp:Panel>

                <!-- ============ BƯỚC 1: NHẬP THÔNG TIN ============ -->
                <asp:Panel ID="pnlRegister" runat="server">
                    <!-- Họ tên + SĐT -->
                    <div class="form-row">
                        <div class="form-group">
                            <label class="auth-label">Họ và Tên <span style="color:#ef4444">*</span></label>
                            <div class="auth-input-wrap">
                                <span class="input-ico"><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" width="18" height="18"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
                                <asp:TextBox ID="hoTen" runat="server" CssClass="auth-input" placeholder="Nguyễn Văn A" ClientIDMode="Static"></asp:TextBox>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="auth-label">Số Điện Thoại</label>
                            <div class="auth-input-wrap">
                                <span class="input-ico"><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" width="18" height="18"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13.28 19.79 19.79 0 0 1 1.61 4.7 2 2 0 0 1 3.6 2.5h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 9.91a16 16 0 0 0 6.08 6.08l.91-.91a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg></span>
                                <asp:TextBox ID="sdt" runat="server" CssClass="auth-input" TextMode="Phone" placeholder="0901 234 567" ClientIDMode="Static"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <!-- Tên đăng nhập -->
                    <div class="form-group">
                        <label class="auth-label">Tên Đăng Nhập <span style="color:#ef4444">*</span></label>
                        <div class="auth-input-wrap">
                            <span class="input-ico"><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" width="18" height="18"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4M4.22 19.78l2.83-2.83M16.95 7.05l2.83-2.83"/></svg></span>
                            <asp:TextBox ID="tenDN" runat="server" CssClass="auth-input" placeholder="vd: nguyen_van_a" ClientIDMode="Static"></asp:TextBox>
                        </div>
                        <div style="font-size:11px;color:var(--muted);margin-top:4px">Chỉ chứa chữ thường, số và dấu gạch dưới</div>
                    </div>

                    <!-- Email -->
                    <div class="form-group">
                        <label class="auth-label">Email <span style="color:#ef4444">*</span></label>
                        <div class="auth-input-wrap">
                            <span class="input-ico"><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg></span>
                            <asp:TextBox ID="email" runat="server" CssClass="auth-input" TextMode="Email" placeholder="example@email.com" ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>

                    <!-- Mật khẩu -->
                    <div class="form-group">
                        <label class="auth-label">Mật Khẩu <span style="color:#ef4444">*</span></label>
                        <div class="auth-input-wrap">
                            <span class="input-ico"><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" width="18" height="18"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
                            <asp:TextBox ID="pw" runat="server" CssClass="auth-input" TextMode="Password" placeholder="Tối thiểu 6 ký tự" oninput="checkStrength(this.value)" ClientIDMode="Static"></asp:TextBox>
                            <button type="button" class="eye-btn" onclick="togglePw('pw')">
                                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                        <div class="pw-strength" id="pwStrength" style="display:none">
                            <div class="pw-bars"><div class="pw-bar" id="bar1"></div><div class="pw-bar" id="bar2"></div><div class="pw-bar" id="bar3"></div><div class="pw-bar" id="bar4"></div></div>
                            <div class="pw-label" id="pwLabel"></div>
                        </div>
                    </div>

                    <!-- Nhập lại mật khẩu -->
                    <div class="form-group">
                        <label class="auth-label">Xác Nhận Mật Khẩu <span style="color:#ef4444">*</span></label>
                        <div class="auth-input-wrap">
                            <span class="input-ico"><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" width="18" height="18"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
                            <asp:TextBox ID="pw2" runat="server" CssClass="auth-input" TextMode="Password" placeholder="Nhập lại mật khẩu" ClientIDMode="Static"></asp:TextBox>
                            <button type="button" class="eye-btn" onclick="togglePw('pw2')">
                                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                    </div>

                    <!-- Điều khoản -->
                    <div style="display:flex;align-items:flex-start;gap:10px;margin-bottom:20px;font-size:13px;color:var(--muted)">
                       <input type="checkbox" id="terms" name="terms" value="1" style="accent-color:var(--primary);margin-top:2px;width:16px;height:16px;flex-shrink:0" />
                       <label for="terms">Tôi đồng ý với <a href="Dieu_khoan.aspx" target="_blank" style="color:var(--primary)">Điều khoản dịch vụ</a> của VanDonMotor</label>
                    </div>

                    <div style="margin-bottom: 20px; display: flex; justify-content: center;">
                        <div class="g-recaptcha" data-sitekey="6LfMcn4tAAAAAHm1itcIbo9Kt3dcqA4iW6vTU_jW" data-theme="dark"></div>
                    </div>

                    <!-- Nút Đăng Ký (Gọi C#) -->
                    <asp:LinkButton ID="btnReg" runat="server" CssClass="btn-auth" OnClientClick="return validateForm();" OnClick="btnReg_Click" ClientIDMode="Static">
                        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                        Tạo Tài Khoản
                    </asp:LinkButton>
                </asp:Panel>

                <!-- ============ BƯỚC 2: XÁC THỰC EMAIL (OTP) ============ -->
                <asp:Panel ID="pnlOtp" runat="server" Visible="false">
                    <p class="auth-subtitle" style="margin-bottom:16px">
                        Mã xác thực đã được gửi tới <b><asp:Label ID="lblOtpEmail" runat="server"></asp:Label></b>.
                        Vui lòng nhập mã gồm 6 chữ số để hoàn tất đăng ký.
                    </p>

                    <div class="form-group">
                        <label class="auth-label">Mã Xác Thực (OTP)</label>
                        <div class="auth-input-wrap">
                            <span class="input-ico"><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" width="18" height="18"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
                            <asp:TextBox ID="txtOtp" runat="server" CssClass="auth-input" MaxLength="6" inputmode="numeric" autocomplete="one-time-code" placeholder="Nhập 6 chữ số" ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>

                    <asp:LinkButton ID="btnVerifyOtp" runat="server" CssClass="btn-auth" OnClick="btnVerifyOtp_Click" ClientIDMode="Static">
                        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                        Xác Nhận
                    </asp:LinkButton>

                    <div style="text-align:center;margin-top:14px;font-size:13px">
                        <asp:LinkButton ID="btnResendOtp" runat="server" CausesValidation="false" OnClick="btnResendOtp_Click" style="color:var(--primary)">Gửi lại mã</asp:LinkButton>
                        &nbsp;·&nbsp;
                        <asp:LinkButton ID="btnBackRegister" runat="server" CausesValidation="false" OnClick="btnBackRegister_Click" style="color:var(--primary)">Nhập lại thông tin</asp:LinkButton>
                    </div>
                </asp:Panel>
            </form>

            <div class="auth-footer" style="margin-top:20px">
                Đã có tài khoản? <a href="Dang_nhap.aspx">Đăng nhập</a>
            </div>
        </div>
    </div>

    <!-- Script Javascript -->
    <script src="auth.js"></script>
    <script>
        // Kiểm tra hợp lệ trước khi gửi form về Server C#
        function validateForm() {
            const valHoTen = document.getElementById('hoTen').value.trim();
            const valTenDN = document.getElementById('tenDN').value.trim();
            const valEmail = document.getElementById('email').value.trim();
            const valPw = document.getElementById('pw').value;
            const valPw2 = document.getElementById('pw2').value;
            const isTermsChecked = document.getElementById('terms').checked;

            if (!valHoTen) { showErr('Vui lòng nhập họ tên!'); return false; }
            if (!valTenDN || !/^[a-z0-9_]+$/.test(valTenDN)) { showErr('Tên đăng nhập chỉ chứa chữ thường, số và dấu _'); return false; }
            if (!valEmail || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(valEmail)) { showErr('Vui lòng nhập email hợp lệ!'); return false; }
            if (valPw.length < 6) { showErr('Mật khẩu tối thiểu 6 ký tự!'); return false; }
            if (valPw !== valPw2) { showErr('Mật khẩu xác nhận không khớp!'); return false; }
            if (!isTermsChecked) { showErr('Vui lòng đồng ý với điều khoản!'); return false; }

            // Thêm hiệu ứng loading cho nút bấm
            const btn = document.getElementById('btnReg');
            if (btn) btn.classList.add('loading');
            return true; // Cho phép form gửi về C#
        }

        // Đánh giá độ mạnh mật khẩu
        function checkStrength(pwVal) {
            const el = document.getElementById('pwStrength');
            if (!pwVal) { el.style.display = 'none'; return; }
            el.style.display = 'block';

            const bars = [1, 2, 3, 4].map(i => document.getElementById('bar' + i));
            const label = document.getElementById('pwLabel');
            let score = 0;

            if (pwVal.length >= 6) score++;
            if (pwVal.length >= 10) score++;
            if (/[A-Z]/.test(pwVal) && /[0-9]/.test(pwVal)) score++;
            if (/[^A-Za-z0-9]/.test(pwVal)) score++;

            const cls = score <= 1 ? 'weak' : score <= 2 ? 'medium' : 'strong';
            bars.forEach((b, i) => { b.className = 'pw-bar' + (i < score ? ' ' + cls : ''); });

            label.textContent = ['', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'][score] || '';
            label.style.color = score <= 1 ? 'var(--danger)' : score <= 2 ? 'var(--primary)' : 'var(--success)';
        }

        // Hiện lỗi ở phía Client
        function showErr(msg) {
            document.getElementById('pnlAlertSuccess').classList.remove('show');
            document.getElementById('lblAlertMsg').textContent = msg;
            document.getElementById('pnlAlertError').classList.add('show');
            setTimeout(() => document.getElementById('pnlAlertError').classList.remove('show'), 4000);
        }

        // Bật tắt mật khẩu
        function togglePw(id) {
            const inp = document.getElementById(id);
            const isHide = inp.type === 'password';
            inp.type = isHide ? 'text' : 'password';
        }
    </script>

</body>
</html>
