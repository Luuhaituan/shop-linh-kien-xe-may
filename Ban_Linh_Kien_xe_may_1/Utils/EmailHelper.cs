using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Text;

namespace Ban_Linh_Kien_xe_may_1.Utils
{
    /// <summary>
    /// Gui email qua SMTP. Cau hinh trong Web.config (appSettings):
    ///   SmtpHost, SmtpPort, SmtpUser, SmtpPassword, SmtpFrom, SmtpFromName, SmtpEnableSsl
    /// </summary>
    public static class EmailHelper
    {
        private static string Cfg(string key, string macDinh = null)
        {
            var v = ConfigurationManager.AppSettings[key];
            return string.IsNullOrWhiteSpace(v) ? macDinh : v.Trim();
        }

        public static bool DaCauHinh()
        {
            return !string.IsNullOrWhiteSpace(Cfg("SmtpHost"))
                && !string.IsNullOrWhiteSpace(Cfg("SmtpUser"))
                && !string.IsNullOrWhiteSpace(Cfg("SmtpPassword"));
        }

        public static void Gui(string denEmail, string tieuDe, string noiDungHtml)
        {
            if (string.IsNullOrWhiteSpace(denEmail))
                throw new ArgumentException("Email nguoi nhan khong hop le.", nameof(denEmail));

            if (!DaCauHinh())
                throw new InvalidOperationException(
                    "Chua cau hinh SMTP trong Web.config (SmtpHost/SmtpUser/SmtpPassword/SmtpFrom).");

            string host = Cfg("SmtpHost");
            int port;
            if (!int.TryParse(Cfg("SmtpPort", "587"), out port)) port = 587;
            string user = Cfg("SmtpUser");
            string pass = Cfg("SmtpPassword");
            string from = Cfg("SmtpFrom", user);
            string fromName = Cfg("SmtpFromName", "VanDonMotor");
            bool enableSsl = !string.Equals(Cfg("SmtpEnableSsl", "true"), "false",
                                            StringComparison.OrdinalIgnoreCase);

            using (var mail = new MailMessage())
            {
                mail.From = new MailAddress(from, fromName, Encoding.UTF8);
                mail.To.Add(denEmail);
                mail.Subject = tieuDe;
                mail.SubjectEncoding = Encoding.UTF8;
                mail.Body = noiDungHtml;
                mail.BodyEncoding = Encoding.UTF8;
                mail.IsBodyHtml = true;

                using (var client = new SmtpClient(host, port))
                {
                    client.EnableSsl = enableSsl;
                    client.UseDefaultCredentials = false;
                    client.Credentials = new NetworkCredential(user, pass);
                    client.DeliveryMethod = SmtpDeliveryMethod.Network;
                    client.Timeout = 15000;
                    client.Send(mail);
                }
            }
        }

        /// <summary>Mô tả ngắn gọn nguyên nhân lỗi gửi email để hiển thị cho người dùng.</summary>
        public static string MoTaLoiGui(Exception ex)
        {
            if (ex == null) return "Không gửi được email xác thực. Vui lòng thử lại sau.";

            bool loiSql = ex is System.Data.SqlClient.SqlException
                          || ex.InnerException is System.Data.SqlClient.SqlException;
            bool loiSmtp = ex is SmtpException || ex.InnerException is SmtpException;
            bool loiMang = ex is WebException || ex.InnerException is WebException;

            string thongBao;
            if (loiSql)
                thongBao = "Không lưu được mã xác thực vào database. Kiểm tra kết nối CSDL và bảng MaXacThucOTP (chạy file SQL/otp_upgrade.sql).";
            else if (!DaCauHinh())
                thongBao = "Hệ thống chưa cấu hình gửi email (SMTP). Vui lòng điền SmtpUser/SmtpPassword/SmtpFrom trong Web.config.";
            else if (loiSmtp)
                thongBao = "Máy chủ email từ chối. Kiểm tra SmtpUser (địa chỉ Gmail) và SmtpPassword (App Password 16 ký tự, KHÔNG phải mật khẩu Gmail).";
            else if (loiMang)
                thongBao = "Không kết nối được tới máy chủ email. Kiểm tra mạng hoặc cấu hình SmtpHost/SmtpPort.";
            else
                thongBao = "Không gửi được email xác thực. Vui lòng thử lại sau.";

            bool debug = false;
            try
            {
                debug = System.Web.HttpContext.Current != null
                        && System.Web.HttpContext.Current.IsDebuggingEnabled;
            }
            catch { }

            if (debug) thongBao += " [" + ex.GetType().Name + ": " + ex.Message + "]";
            return thongBao;
        }

        public static string TaoNoiDungOtp(string hoTen, string maOtp, int soPhut)
        {
            string ten = string.IsNullOrWhiteSpace(hoTen)
                ? "bạn"
                : System.Web.HttpUtility.HtmlEncode(hoTen);

            return $@"<div style='font-family:Segoe UI,Arial,sans-serif;max-width:520px;margin:auto;border:1px solid #e5e5e5;border-radius:10px;overflow:hidden'>
  <div style='background:#e85d04;color:#fff;padding:18px 24px;font-size:20px;font-weight:700'>VanDonMotor</div>
  <div style='padding:24px;color:#222;line-height:1.6'>
    <p>Xin chào <b>{ten}</b>,</p>
    <p>Mã xác thực (OTP) của bạn là:</p>
    <div style='text-align:center;margin:22px 0'>
      <span style='display:inline-block;letter-spacing:8px;font-size:32px;font-weight:800;color:#e85d04;background:#fff3e0;padding:12px 24px;border-radius:8px'>{maOtp}</span>
    </div>
    <p>Mã có hiệu lực trong <b>{soPhut} phút</b>. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>
    <p style='color:#888;font-size:13px'>Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email này.</p>
  </div>
</div>";
        }
    }
}
