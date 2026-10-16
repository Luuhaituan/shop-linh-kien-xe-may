using System;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Web.UI;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1
{
    public partial class Dang_ky : System.Web.UI.Page
    {
        // Khai báo Database
        QuanLyLinhKienXeMayEntities db = new QuanLyLinhKienXeMayEntities();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Ẩn các thông báo mỗi lần load lại trang
            pnlAlertError.CssClass = "auth-alert error";
            pnlAlertSuccess.CssClass = "auth-alert success";
        }

        // ============ BƯỚC 1: Nhập thông tin -> gửi OTP ============
        protected void btnReg_Click(object sender, EventArgs e)
        {
            // 1. Kiểm tra người dùng đã tick Captcha chưa 
            string recaptchaResponse = Request.Form["g-recaptcha-response"];
            if (string.IsNullOrEmpty(recaptchaResponse) || !VerifyReCaptcha(recaptchaResponse))
            {
                ShowError("Vui lòng xác nhận bạn không phải robot!");
                return;
            }

            // 2. Lấy dữ liệu từ form
            string hoTenVal = hoTen.Text.Trim();
            string userName = tenDN.Text.Trim();
            string userEmail = email.Text.Trim();
            string userPhone = sdt.Text.Trim();
            string pwVal = pw.Text;
            string pw2Val = pw2.Text;

            // 3. Kiểm tra dữ liệu (server-side, không tin tưởng JS)
            if (string.IsNullOrEmpty(hoTenVal))
            {
                ShowError("Vui lòng nhập họ tên!");
                return;
            }
            if (string.IsNullOrEmpty(userName) || !Regex.IsMatch(userName, "^[a-z0-9_]+$"))
            {
                ShowError("Tên đăng nhập chỉ chứa chữ thường, số và dấu _");
                return;
            }
            if (string.IsNullOrEmpty(userEmail) || !Regex.IsMatch(userEmail, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                ShowError("Vui lòng nhập email hợp lệ!");
                return;
            }
            if (string.IsNullOrEmpty(pwVal) || pwVal.Length < 6)
            {
                ShowError("Mật khẩu tối thiểu 6 ký tự!");
                return;
            }
            if (pwVal != pw2Val)
            {
                ShowError("Mật khẩu xác nhận không khớp!");
                return;
            }
            if (string.IsNullOrEmpty(Request.Form["terms"]))
            {
                ShowError("Vui lòng đồng ý với điều khoản dịch vụ!");
                return;
            }

            // 4. Kiểm tra trùng lặp trong Database
            if (db.NguoiDungs.Any(u => u.TenDangNhap == userName))
            {
                ShowError("Tên đăng nhập này đã được sử dụng!");
                return;
            }
            if (db.NguoiDungs.Any(u => u.Email == userEmail))
            {
                ShowError("Email này đã được đăng ký cho tài khoản khác!");
                return;
            }
            if (!string.IsNullOrEmpty(userPhone) && db.NguoiDungs.Any(u => u.SoDienThoai == userPhone))
            {
                ShowError("Số điện thoại này đã được sử dụng!");
                return;
            }

            // 5. Sinh OTP và gửi email xác thực
            try
            {
                OtpHelper.TaoVaGuiOtp(userEmail, OtpHelper.MucDichDangKy, hoTenVal);
            }
            catch (Exception ex)
            {
                ShowError(EmailHelper.MoTaLoiGui(ex));
                return;
            }

            // 6. Lưu tạm thông tin đăng ký vào Session (chưa tạo tài khoản)
            Session["Reg_HoTen"] = hoTenVal;
            Session["Reg_TenDangNhap"] = userName;
            Session["Reg_Email"] = userEmail;
            Session["Reg_SDT"] = userPhone;
            Session["Reg_MatKhauHash"] = PasswordHelper.HashPassword(pwVal);

            HienThiBuocOtp(userEmail);
        }

        // ============ BƯỚC 2: Xác thực OTP -> tạo tài khoản ============
        protected void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            string userEmail = Session["Reg_Email"] as string;
            if (string.IsNullOrEmpty(userEmail))
            {
                ShowError("Phiên đăng ký đã hết hạn. Vui lòng đăng ký lại.");
                VeLaiBuocNhap();
                return;
            }

            var ketQua = OtpHelper.XacThucOtp(userEmail, OtpHelper.MucDichDangKy, txtOtp.Text);
            if (ketQua != KetQuaOtp.HopLe)
            {
                ShowError(OtpHelper.MoTaKetQua(ketQua));
                HienThiBuocOtp(userEmail);
                return;
            }

            string userName = Session["Reg_TenDangNhap"] as string;

            // Kiểm tra lại trùng lặp (phòng khi có người đăng ký trùng trong lúc chờ OTP)
            if (db.NguoiDungs.Any(u => u.TenDangNhap == userName))
            {
                ShowError("Tên đăng nhập này đã được sử dụng!");
                XoaPhienDangKy();
                VeLaiBuocNhap();
                return;
            }
            if (db.NguoiDungs.Any(u => u.Email == userEmail))
            {
                ShowError("Email này đã được đăng ký cho tài khoản khác!");
                XoaPhienDangKy();
                VeLaiBuocNhap();
                return;
            }

            // Tạo tài khoản với mật khẩu đã hash, trạng thái hoạt động, ngày đăng ký
            NguoiDung newUser = new NguoiDung();
            newUser.HoTen = Session["Reg_HoTen"] as string;
            newUser.TenDangNhap = userName;
            newUser.Email = userEmail;
            newUser.SoDienThoai = Session["Reg_SDT"] as string;
            newUser.MatKhau = Session["Reg_MatKhauHash"] as string;
            newUser.VaiTro = "User";
            newUser.TrangThai = true;
            newUser.NgayDangKy = DateTime.Now;

            try
            {
                db.NguoiDungs.Add(newUser);
                db.SaveChanges();
            }
            catch
            {
                ShowError("Đăng ký thất bại do lỗi hệ thống. Vui lòng thử lại.");
                HienThiBuocOtp(userEmail);
                return;
            }

            XoaPhienDangKy();
            NhatKyHelper.Ghi(Context, "Đăng ký tài khoản", "NguoiDung", "Tài khoản mới: " + userName);

            // Báo thành công và chuyển hướng
            pnlRegister.Visible = false;
            pnlOtp.Visible = false;
            lblAlertOkMsg.Text = "Đăng ký thành công! Vui lòng đăng nhập.";
            pnlAlertSuccess.CssClass = "auth-alert success show";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "redirect",
                "setTimeout(function(){ window.location.href = 'Dang_nhap.aspx'; }, 2500);", true);
        }

        protected void btnResendOtp_Click(object sender, EventArgs e)
        {
            string userEmail = Session["Reg_Email"] as string;
            string hoTenVal = Session["Reg_HoTen"] as string;
            if (string.IsNullOrEmpty(userEmail))
            {
                ShowError("Phiên đăng ký đã hết hạn. Vui lòng đăng ký lại.");
                VeLaiBuocNhap();
                return;
            }

            try
            {
                OtpHelper.TaoVaGuiOtp(userEmail, OtpHelper.MucDichDangKy, hoTenVal);
            }
            catch (Exception ex)
            {
                ShowError(EmailHelper.MoTaLoiGui(ex));
                HienThiBuocOtp(userEmail);
                return;
            }

            HienThiBuocOtp(userEmail);
            lblAlertOkMsg.Text = "Đã gửi lại mã xác thực tới email của bạn.";
            pnlAlertSuccess.CssClass = "auth-alert success show";
        }

        protected void btnBackRegister_Click(object sender, EventArgs e)
        {
            XoaPhienDangKy();
            VeLaiBuocNhap();
        }

        // ============ Helpers ============
        private void HienThiBuocOtp(string userEmail)
        {
            lblOtpEmail.Text = userEmail;
            txtOtp.Text = "";
            pnlRegister.Visible = false;
            pnlOtp.Visible = true;
        }

        private void VeLaiBuocNhap()
        {
            pnlOtp.Visible = false;
            pnlRegister.Visible = true;
        }

        private void XoaPhienDangKy()
        {
            Session.Remove("Reg_HoTen");
            Session.Remove("Reg_TenDangNhap");
            Session.Remove("Reg_Email");
            Session.Remove("Reg_SDT");
            Session.Remove("Reg_MatKhauHash");
        }

        private void ShowError(string msg)
        {
            lblAlertMsg.Text = msg;
            pnlAlertError.CssClass = "auth-alert error show";
        }

        private bool VerifyReCaptcha(string response)
        {
            // BẠN NHỚ DÁN SECRET KEY TỪ GOOGLE VÀO ĐÂY NHÉ
            string secretKey = "6LfMcn4tAAAAACB9ufsWNtwmWS86XscdJr43CU-q";
            string url = $"https://www.google.com/recaptcha/api/siteverify?secret={secretKey}&response={response}";

            try
            {
                using (WebClient webClient = new WebClient())
                {
                    string jsonResponse = webClient.DownloadString(url);
                    // Kiểm tra xem Google trả về có chữ "success": true hay không
                    return jsonResponse.Contains("\"success\": true");
                }
            }
            catch
            {
                return false;
            }
        }
    }
}
