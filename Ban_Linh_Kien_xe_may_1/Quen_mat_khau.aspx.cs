using System;
using System.Linq;
using System.Web.UI;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1
{
    public partial class Quen_mat_khau : System.Web.UI.Page
    {
        // Gọi kết nối Database
        QuanLyLinhKienXeMayEntities db = new QuanLyLinhKienXeMayEntities();

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        // ============ BƯỚC 1: Xác minh danh tính -> gửi OTP ============
        protected void btnVerify_Click(object sender, EventArgs e)
        {
            AnThongBao();

            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(email))
            {
                HienThiLoi("Vui lòng nhập đầy đủ tên đăng nhập và email!");
                return;
            }

            // 1. Tìm người dùng có Tên đăng nhập và Email khớp nhau
            var user = db.NguoiDungs.FirstOrDefault(u => u.TenDangNhap == username && u.Email == email);

            if (user == null)
            {
                HienThiLoi("Tên đăng nhập hoặc Email không chính xác!");
                return;
            }

            // 2. Sinh OTP và gửi email
            try
            {
                OtpHelper.TaoVaGuiOtp(user.Email, OtpHelper.MucDichDatLai, user.HoTen);
            }
            catch (Exception ex)
            {
                HienThiLoi(EmailHelper.MoTaLoiGui(ex));
                return;
            }

            Session["Reset_MaNguoiDung"] = user.MaNguoiDung;
            Session["Reset_Email"] = user.Email;
            Session["Reset_HoTen"] = user.HoTen;

            HienThiBuocOtp(user.Email);
        }

        // ============ BƯỚC 2: Xác thực OTP -> đổi mật khẩu ============
        protected void btnReset_Click(object sender, EventArgs e)
        {
            AnThongBao();

            string email = Session["Reset_Email"] as string;
            object maNd = Session["Reset_MaNguoiDung"];

            if (string.IsNullOrEmpty(email) || maNd == null)
            {
                HienThiLoi("Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại.");
                VeLaiBuoc1();
                return;
            }

            string newPassword = txtNewPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            // Kiểm tra mật khẩu mới (server-side)
            if (string.IsNullOrEmpty(newPassword) || newPassword.Length < 6)
            {
                HienThiLoi("Mật khẩu mới phải có tối thiểu 6 ký tự!");
                HienThiBuocOtp(email);
                return;
            }
            if (newPassword != confirmPassword)
            {
                HienThiLoi("Mật khẩu xác nhận không khớp!");
                HienThiBuocOtp(email);
                return;
            }

            // Xác thực OTP
            var ketQua = OtpHelper.XacThucOtp(email, OtpHelper.MucDichDatLai, txtOtp.Text);
            if (ketQua != KetQuaOtp.HopLe)
            {
                HienThiLoi(OtpHelper.MoTaKetQua(ketQua));
                HienThiBuocOtp(email);
                return;
            }

            // Cập nhật mật khẩu mới (ĐÃ HASH - sửa lỗ hổng lưu plaintext)
            int maNguoiDung = Convert.ToInt32(maNd);
            var user = db.NguoiDungs.FirstOrDefault(u => u.MaNguoiDung == maNguoiDung);
            if (user == null)
            {
                HienThiLoi("Không tìm thấy tài khoản. Vui lòng thực hiện lại.");
                XoaPhienReset();
                VeLaiBuoc1();
                return;
            }

            user.MatKhau = PasswordHelper.HashPassword(newPassword);
            try
            {
                db.SaveChanges();
            }
            catch
            {
                HienThiLoi("Đặt lại mật khẩu thất bại do lỗi hệ thống. Vui lòng thử lại.");
                HienThiBuocOtp(email);
                return;
            }

            XoaPhienReset();
            NhatKyHelper.Ghi(Context, "Đặt lại mật khẩu", "NguoiDung", "Tài khoản: " + user.TenDangNhap);

            // Thành công
            pnlStep1.Visible = false;
            pnlStep2.Visible = false;
            lblAlertSuccess.Text = "Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.";
            pnlAlertSuccess.Visible = true;
            pnlAlertSuccess.CssClass = "auth-alert success show";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "redirect",
                "setTimeout(function(){ window.location.href = 'Dang_nhap.aspx'; }, 2500);", true);
        }

        protected void btnResendOtp_Click(object sender, EventArgs e)
        {
            AnThongBao();

            string email = Session["Reset_Email"] as string;
            string hoTen = Session["Reset_HoTen"] as string;
            if (string.IsNullOrEmpty(email))
            {
                HienThiLoi("Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại.");
                VeLaiBuoc1();
                return;
            }

            try
            {
                OtpHelper.TaoVaGuiOtp(email, OtpHelper.MucDichDatLai, hoTen);
            }
            catch (Exception ex)
            {
                HienThiLoi(EmailHelper.MoTaLoiGui(ex));
                HienThiBuocOtp(email);
                return;
            }

            HienThiBuocOtp(email);
            lblAlertSuccess.Text = "Đã gửi lại mã xác thực tới email của bạn.";
            pnlAlertSuccess.Visible = true;
            pnlAlertSuccess.CssClass = "auth-alert success show";
        }

        protected void btnBackStep1_Click(object sender, EventArgs e)
        {
            AnThongBao();
            XoaPhienReset();
            VeLaiBuoc1();
        }

        // ============ Helpers ============
        private void HienThiBuocOtp(string email)
        {
            lblOtpEmail.Text = email;
            txtOtp.Text = "";
            pnlStep1.Visible = false;
            pnlStep2.Visible = true;
        }

        private void VeLaiBuoc1()
        {
            pnlStep2.Visible = false;
            pnlStep1.Visible = true;
        }

        private void XoaPhienReset()
        {
            Session.Remove("Reset_MaNguoiDung");
            Session.Remove("Reset_Email");
            Session.Remove("Reset_HoTen");
        }

        private void AnThongBao()
        {
            pnlAlertError.Visible = false;
            pnlAlertError.CssClass = "auth-alert error";
            pnlAlertSuccess.Visible = false;
            pnlAlertSuccess.CssClass = "auth-alert success";
        }

        private void HienThiLoi(string msg)
        {
            lblAlertError.Text = msg;
            pnlAlertError.Visible = true;
            pnlAlertError.CssClass = "auth-alert error show";
        }
    }
}
