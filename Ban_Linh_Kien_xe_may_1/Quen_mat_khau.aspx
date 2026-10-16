<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Quen_mat_khau.aspx.cs" Inherits="Ban_Linh_Kien_xe_may_1.Quen_mat_khau" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
    <title>Quên Mật Khẩu | VanDonMotor</title>
    <link rel="stylesheet" href="auth.css"/>
</head>
<body>
    <div class="auth-bg">
        <div class="auth-card">
            <!-- Logo -->
            <a href="index.aspx" class="auth-logo">
                <img src="images/anh_dai_dien.jpg" alt="Logo VanDonMotor" width="45" height="45" style="border-radius: 50%; object-fit: cover;" />
                <span class="auth-logo-text">VanDon<span>Motor</span></span>
            </a>

            <h1 class="auth-title">Khôi Phục Mật Khẩu</h1>
            <p class="auth-subtitle">Nhập thông tin xác thực để đặt lại mật khẩu mới</p>

            <form id="form1" runat="server">
                <!-- Thông báo Lỗi -->
                <asp:Panel ID="pnlAlertError" runat="server" CssClass="auth-alert error" Visible="false">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <asp:Label ID="lblAlertError" runat="server" Text=""></asp:Label>
                </asp:Panel>

                <!-- Thông báo Thành công -->
                <asp:Panel ID="pnlAlertSuccess" runat="server" CssClass="auth-alert success" Visible="false" style="background-color: #d4edda; color: #155724; border-color: #c3e6cb;">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    <asp:Label ID="lblAlertSuccess" runat="server" Text=""></asp:Label>
                </asp:Panel>

                <!-- ============ BƯỚC 1: XÁC MINH DANH TÍNH ============ -->
                <asp:Panel ID="pnlStep1" runat="server">
                    <div class="form-group">
                        <label class="auth-label">Tên đăng nhập</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="auth-input" placeholder="Nhập tên đăng nhập của bạn" required="true"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label class="auth-label">Email đã đăng ký</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="auth-input" TextMode="Email" placeholder="Nhập email của bạn" required="true"></asp:TextBox>
                    </div>

                    <asp:LinkButton ID="btnVerify" runat="server" CssClass="btn-auth" OnClick="btnVerify_Click">
                        Xác Minh
                    </asp:LinkButton>
                </asp:Panel>

                <!-- ============ BƯỚC 2: NHẬP OTP + MẬT KHẨU MỚI ============ -->
                <asp:Panel ID="pnlStep2" runat="server" Visible="false">
                    <p class="auth-subtitle" style="margin-bottom:16px">
                        Mã xác thực đã được gửi tới <b><asp:Label ID="lblOtpEmail" runat="server"></asp:Label></b>.
                        Nhập mã và mật khẩu mới để hoàn tất.
                    </p>

                    <div class="form-group">
                        <label class="auth-label">Mã xác thực (OTP)</label>
                        <asp:TextBox ID="txtOtp" runat="server" CssClass="auth-input" MaxLength="6" inputmode="numeric" autocomplete="one-time-code" placeholder="Nhập 6 chữ số"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label class="auth-label">Mật khẩu mới</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="auth-input" TextMode="Password" placeholder="Tối thiểu 6 ký tự"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label class="auth-label">Xác nhận mật khẩu mới</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="auth-input" TextMode="Password" placeholder="Nhập lại mật khẩu mới"></asp:TextBox>
                    </div>

                    <asp:LinkButton ID="btnReset" runat="server" CssClass="btn-auth" OnClick="btnReset_Click">
                        Lưu Mật Khẩu Mới
                    </asp:LinkButton>

                    <div style="text-align:center;margin-top:14px;font-size:13px">
                        <asp:LinkButton ID="btnResendOtp" runat="server" CausesValidation="false" OnClick="btnResendOtp_Click" style="color:var(--primary)">Gửi lại mã</asp:LinkButton>
                        &nbsp;·&nbsp;
                        <asp:LinkButton ID="btnBackStep1" runat="server" CausesValidation="false" OnClick="btnBackStep1_Click" style="color:var(--primary)">Nhập lại thông tin</asp:LinkButton>
                    </div>
                </asp:Panel>
            </form>

            <div class="auth-footer" style="margin-top:20px">
                Nhớ ra mật khẩu rồi? <a href="Dang_nhap.aspx">Đăng nhập ngay</a>
            </div>
        </div>
    </div>
</body>
</html>
