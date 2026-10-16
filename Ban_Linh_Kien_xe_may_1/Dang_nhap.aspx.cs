using System;
using System.Linq;
using System.Net;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1
{
    public partial class Dang_nhap : System.Web.UI.Page
    {
        // Khởi tạo Entity Framework Model
        QuanLyLinhKienXeMayEntities db = new QuanLyLinhKienXeMayEntities();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Ẩn thông báo lỗi mỗi khi load lại trang
            pnlAlertError.Visible = false;
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // 1. === ĐOẠN CODE KIỂM TRA CAPTCHA ===
            string recaptchaResponse = Request.Form["g-recaptcha-response"];

            if (string.IsNullOrEmpty(recaptchaResponse) || !VerifyReCaptcha(recaptchaResponse))
            {
                lblAlertMsg.Text = "Vui lòng xác nhận bạn không phải robot!";
                pnlAlertError.Visible = true;
                pnlAlertError.CssClass = "auth-alert error show";
                return;
            }
            // ===============================================

            // 2. Lấy thông tin tài khoản mật khẩu
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text; // Plain input password

            // 3. Tìm user theo username hoặc email
            var user = db.NguoiDungs.FirstOrDefault(u => u.TenDangNhap == username || u.Email == username);

            if (user != null)
            {
                bool verified = false;

                // 4. Kiểm tra mật khẩu với helper
                if (PasswordHelper.VerifyPassword(user.MatKhau, password))
                {
                    verified = true;

                    // Nếu mật khẩu đang lưu plaintext (legacy), migrate lên hash
                    if (!PasswordHelper.IsHashed(user.MatKhau))
                    {
                        user.MatKhau = PasswordHelper.HashPassword(password);
                        db.SaveChanges();
                    }
                }

                if (verified)
                {
                    // 👉 5. BƯỚC MỚI: CHẶN TÀI KHOẢN NẾU ĐANG BỊ KHÓA
                    if (user.TrangThai == false)
                    {
                        lblAlertMsg.Text = "Tài khoản của bạn đã bị khóa bởi Quản trị viên!";
                        pnlAlertError.Visible = true;
                        pnlAlertError.CssClass = "auth-alert error show";
                        return; // Dừng lại ngay, không cấp Session và không chuyển trang
                    }

                    // Lưu session và phân quyền
                    Session["User"] = user;

                    if (Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsStaff(user.VaiTro))
                    {
                        Response.Redirect("Admin.aspx");
                    }
                    else
                    {
                        Response.Redirect("index.aspx");
                    }

                    return;
                }
            }

            // Nếu tới đây nghĩa là không thành công
            lblAlertMsg.Text = "Tên đăng nhập hoặc mật khẩu không đúng!";
            pnlAlertError.Visible = true;
            pnlAlertError.CssClass = "auth-alert error show";
        }

        private bool VerifyReCaptcha(string response)
        {
            string secretKey = "6LfMcn4tAAAAACB9ufsWNtwmWS86XscdJr43CU-q";
            string url = $"https://www.google.com/recaptcha/api/siteverify?secret={secretKey}&response={response}";

            try
            {
                using (WebClient webClient = new WebClient())
                {
                    string jsonResponse = webClient.DownloadString(url);
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