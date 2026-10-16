using System;
using System.Web;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.Utils
{
    /// <summary>
    /// Phân quyền theo 3 mức: Admin > NhanVien > User
    ///   - Admin:   toàn quyền (quản lý sản phẩm, danh mục, khách hàng, tài khoản, doanh thu, chat)
    ///   - NhanVien: chỉ được phần trò chuyện với khách hàng
    ///   - User:    chỉ dùng mặt cửa hàng
    /// </summary>
    public static class PhanQuyen
    {
        public const string Admin = "Admin";
        public const string NhanVien = "NhanVien";              // Nhân viên hỗ trợ (giữ để tương thích)
        public const string NhanVienBanHang = "NhanVienBanHang"; // Nhân viên bán hàng
        public const string NhanVienKho = "NhanVienKho";         // Nhân viên kho
        public const string NhanVienHoTro = "NhanVienHoTro";     // Nhân viên hỗ trợ (chat)
        public const string User = "User";

        public const string ThongBaoKhongCoQuyen = "Bạn không có quyền truy cập";

        /// <summary>Danh sách tab khu vực quản trị, theo đúng thứ tự hiển thị trên sidebar.</summary>
        public static readonly string[] TatCaTab = new[]
        {
            "sanpham", "danhmuc", "dongxe", "khachhang", "nguoidung", "donhang",
            "khuyenmai", "kho", "danhgia", "thongke", "nhatky", "chat"
        };

        public static bool IsAdmin(string vaiTro)
        {
            return string.Equals(vaiTro, Admin, StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsNhanVien(string vaiTro)
        {
            return string.Equals(vaiTro, NhanVien, StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsNhanVienBanHang(string vaiTro)
        {
            return string.Equals(vaiTro, NhanVienBanHang, StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsNhanVienKho(string vaiTro)
        {
            return string.Equals(vaiTro, NhanVienKho, StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsNhanVienHoTro(string vaiTro)
        {
            return string.Equals(vaiTro, NhanVienHoTro, StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsUser(string vaiTro)
        {
            return string.Equals(vaiTro, User, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>Có phải tài khoản nhân sự (được vào khu vực quản trị): Admin hoặc bất kỳ loại nhân viên.</summary>
        public static bool IsStaff(string vaiTro)
        {
            return IsAdmin(vaiTro) || IsNhanVien(vaiTro) || IsNhanVienBanHang(vaiTro)
                   || IsNhanVienKho(vaiTro) || IsNhanVienHoTro(vaiTro);
        }

        /// <summary>Vai trò hợp lệ để gán cho tài khoản (kể cả User).</summary>
        public static bool LaVaiTroHopLe(string vaiTro)
        {
            return IsStaff(vaiTro) || IsUser(vaiTro);
        }

        /// <summary>
        /// Vai trò được gán cho tài khoản nhân sự do Admin tạo (không gồm User).
        /// </summary>
        public static bool LaVaiTroNhanSu(string vaiTro)
        {
            return IsStaff(vaiTro);
        }

        /// <summary>Tên hiển thị tiếng Việt của vai trò.</summary>
        public static string TenVaiTro(string vaiTro)
        {
            if (IsAdmin(vaiTro)) return "Quản trị viên";
            if (IsNhanVienBanHang(vaiTro)) return "Nhân viên bán hàng";
            if (IsNhanVienKho(vaiTro)) return "Nhân viên kho";
            if (IsNhanVienHoTro(vaiTro) || IsNhanVien(vaiTro)) return "Nhân viên hỗ trợ";
            return "Khách hàng";
        }

        /// <summary>
        /// Kiểm tra quyền truy cập một tab/chức năng quản trị theo mã tab
        /// (sanpham, danhmuc, dongxe, khachhang, nguoidung, donhang, khuyenmai,
        ///  kho, danhgia, thongke, nhatky, chat).
        /// Admin có mọi quyền; các vai trò nhân viên chỉ có một số tab nhất định.
        /// </summary>
        public static bool CoQuyen(string vaiTro, string tab)
        {
            if (IsAdmin(vaiTro)) return true;

            string v = (vaiTro ?? "").Trim();
            switch ((tab ?? "").Trim().ToLowerInvariant())
            {
                case "khachhang":
                case "donhang":
                    return IsNhanVienBanHang(v);
                case "kho":
                    return IsNhanVienKho(v);
                case "chat":
                    return IsNhanVienHoTro(v) || IsNhanVien(v);
                default:
                    return false;
            }
        }

        public static NguoiDung GetNguoiDung(HttpContext context)
        {
            return context.Session["User"] as NguoiDung;
        }

        public static bool IsStaffSession(HttpContext context)
        {
            var user = GetNguoiDung(context);
            return user != null && IsStaff(user.VaiTro);
        }

        public static bool IsAdminSession(HttpContext context)
        {
            var user = GetNguoiDung(context);
            return user != null && IsAdmin(user.VaiTro);
        }

        /// <summary>
        /// Trả về true nếu request được phép đi tiếp.
        /// Nếu không, đã ghi thông báo từ chối vào response và trả về false.
        /// </summary>
        public static bool RequireStaff(HttpContext context, System.Web.Script.Serialization.JavaScriptSerializer js)
        {
            if (IsStaffSession(context)) return true;
            Reject(context, js);
            return false;
        }

        public static bool RequireAdmin(HttpContext context, System.Web.Script.Serialization.JavaScriptSerializer js)
        {
            if (IsAdminSession(context)) return true;
            Reject(context, js);
            return false;
        }

        private static void Reject(HttpContext context, System.Web.Script.Serialization.JavaScriptSerializer js)
        {
            var user = GetNguoiDung(context);
            string msg = user == null ? "not_logged_in" : "forbidden";
            context.Response.Write(js.Serialize(new { success = false, message = msg }));
            context.Response.StatusCode = user == null ? 401 : 403;
        }

        /// <summary>HTML trang thông báo không có quyền, dùng khi gõ tay URL vào trang quản trị.</summary>
        public static string HtmlKhongCoQuyen(string tenTinhNang)
        {
            string t = HttpUtility.HtmlEncode(tenTinhNang ?? "Trang quản trị");
            string tb = HttpUtility.HtmlEncode(ThongBaoKhongCoQuyen);

            // Thuoc tinh HTML dung nhay don de khong phai escape trong chuoi verbatim.
            return @"<!DOCTYPE html>
<html lang='vi'>
<head>
<meta charset='utf-8'>
<meta name='viewport' content='width=device-width, initial-scale=1'>
<title>" + tb + @"</title>
<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>
<style>
  body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;
       background:#141414;color:#fff;font-family:'Segoe UI',Arial,sans-serif;}
  .box{background:#1e1e1e;border:1px solid #333;border-radius:12px;padding:40px 48px;
       max-width:460px;text-align:center;}
  h1{font-size:22px;margin:16px 0 8px;color:#ee4d2d;}
  p{color:#aaa;margin:0 0 24px;line-height:1.6;}
  a{display:inline-block;background:#e85d04;color:#fff;text-decoration:none;
    padding:11px 26px;border-radius:6px;font-weight:600;}
</style>
</head>
<body>
  <div class='box'>
    <div style='font-size:52px;'>&#128683;</div>
    <h1>" + tb + @"</h1>
    <p>Tài khoản của bạn không được phép mở " + t + @".</p>
    <a href='index.aspx'>Về trang chủ</a>
  </div>
  <script>
    Swal.fire({ icon: 'error', title: '" + tb + @"',
      text: 'Vui lòng liên hệ quản trị viên nếu bạn cần quyền truy cập.' });
  </script>
</body>
</html>";
        }
    }
}