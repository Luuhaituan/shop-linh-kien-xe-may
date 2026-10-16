using System;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    /// <summary>Quan ly nguoi dung (UC06.14-16): xem, sua, doi vai tro, reset mat khau, them nhan vien.</summary>
    public class QuanLyNguoiDungApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var currentUser = context.Session["User"] as NguoiDung;
            if (currentUser == null || !PhanQuyen.IsAdmin(currentUser.VaiTro))
            {
                context.Response.StatusCode = (currentUser == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn không có quyền truy cập!" }));
                return;
            }

            string action = context.Request.QueryString["action"] ?? context.Request.Form["action"] ?? "get";

            try
            {
                switch (action)
                {
                    case "detail": Detail(context); break;
                    case "update": Update(context, currentUser); break;
                    case "reset_password": ResetPassword(context, currentUser); break;
                    case "add_staff": AddStaff(context, currentUser); break;
                    default:
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Unknown action" }));
                        break;
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi xử lý: " + ex.Message }));
            }
        }

        private void Detail(HttpContext context)
        {
            int id = ParseInt(context.Request.QueryString["id"]);
            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var u = db.NguoiDungs.Where(x => x.MaNguoiDung == id).Select(x => new
                {
                    id = x.MaNguoiDung,
                    username = x.TenDangNhap,
                    name = x.HoTen,
                    email = x.Email,
                    phone = x.SoDienThoai,
                    address = x.DiaChi,
                    role = x.VaiTro,
                    status = (x.TrangThai == false) ? 0 : 1,
                    orderCount = db.DonHangs.Count(d => d.MaNguoiDung == x.MaNguoiDung)
                }).FirstOrDefault();

                if (u == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Tài khoản không tồn tại!" }));
                    return;
                }

                context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = u }));
            }
        }

        private void Update(HttpContext context, NguoiDung currentUser)
        {
            int id = ParseInt(context.Request.Form["id"]);
            string hoTen = (context.Request.Form["hoTen"] ?? "").Trim();
            string email = (context.Request.Form["email"] ?? "").Trim();
            string sdt = (context.Request.Form["sdt"] ?? "").Trim();
            string diaChi = (context.Request.Form["diaChi"] ?? "").Trim();
            string vaiTro = (context.Request.Form["vaiTro"] ?? "").Trim();

            if (id <= 0 || string.IsNullOrEmpty(hoTen))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vui lòng nhập họ tên!" }));
                return;
            }

            if (!string.IsNullOrEmpty(vaiTro) && !PhanQuyen.LaVaiTroHopLe(vaiTro))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vai trò không hợp lệ!" }));
                return;
            }

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var u = db.NguoiDungs.FirstOrDefault(x => x.MaNguoiDung == id);
                if (u == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Tài khoản không tồn tại!" }));
                    return;
                }

                if (id == currentUser.MaNguoiDung && !string.IsNullOrEmpty(vaiTro) && vaiTro != PhanQuyen.Admin)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không thể tự hạ quyền của chính mình!" }));
                    return;
                }

                // Tài khoản Quản trị viên không thể bị hạ quyền (tương đương xóa quyền Admin)
                if (u.VaiTro == PhanQuyen.Admin && !string.IsNullOrEmpty(vaiTro) && vaiTro != PhanQuyen.Admin)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không thể thay đổi vai trò của tài khoản Quản trị viên!" }));
                    return;
                }

                if (!string.IsNullOrEmpty(email) && email != u.Email)
                {
                    if (db.NguoiDungs.Any(x => x.Email == email && x.MaNguoiDung != id))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Email đã được dùng bởi tài khoản khác!" }));
                        return;
                    }
                }

                u.HoTen = hoTen;
                u.Email = string.IsNullOrEmpty(email) ? null : email;
                u.SoDienThoai = string.IsNullOrEmpty(sdt) ? null : sdt;
                u.DiaChi = string.IsNullOrEmpty(diaChi) ? null : diaChi;
                if (!string.IsNullOrEmpty(vaiTro)) u.VaiTro = vaiTro;
                db.SaveChanges();

                NhatKyHelper.Ghi(context, "Cập nhật người dùng", "NguoiDung#" + id, hoTen + " | vai trò: " + u.VaiTro);
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Cập nhật người dùng thành công!" }));
            }
        }

        private void ResetPassword(HttpContext context, NguoiDung currentUser)
        {
            int id = ParseInt(context.Request.Form["id"]);
            string newPass = context.Request.Form["newPassword"];

            if (id <= 0 || string.IsNullOrEmpty(newPass) || newPass.Length < 6)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mật khẩu mới phải từ 6 ký tự trở lên!" }));
                return;
            }

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var u = db.NguoiDungs.FirstOrDefault(x => x.MaNguoiDung == id);
                if (u == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Tài khoản không tồn tại!" }));
                    return;
                }

                u.MatKhau = PasswordHelper.HashPassword(newPass);
                db.SaveChanges();

                NhatKyHelper.Ghi(context, "Đặt lại mật khẩu", "NguoiDung#" + id, u.TenDangNhap);
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đặt lại mật khẩu thành công!" }));
            }
        }

        private void AddStaff(HttpContext context, NguoiDung currentUser)
        {
            string username = (context.Request.Form["username"] ?? "").Trim();
            string password = context.Request.Form["password"];
            string hoTen = (context.Request.Form["hoTen"] ?? "").Trim();
            string email = (context.Request.Form["email"] ?? "").Trim();
            string sdt = (context.Request.Form["sdt"] ?? "").Trim();
            string vaiTro = (context.Request.Form["vaiTro"] ?? "").Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password) || string.IsNullOrEmpty(hoTen))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vui lòng nhập Tên đăng nhập, Mật khẩu và Họ tên!" }));
                return;
            }
            if (password.Length < 6)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mật khẩu phải từ 6 ký tự trở lên!" }));
                return;
            }
            if (!PhanQuyen.LaVaiTroNhanSu(vaiTro))
            {
                vaiTro = PhanQuyen.NhanVienHoTro;
            }

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                if (db.NguoiDungs.Any(x => x.TenDangNhap == username))
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Tên đăng nhập đã tồn tại!" }));
                    return;
                }
                if (!string.IsNullOrEmpty(email) && db.NguoiDungs.Any(x => x.Email == email))
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Email đã được sử dụng!" }));
                    return;
                }

                var u = new NguoiDung
                {
                    TenDangNhap = username,
                    MatKhau = PasswordHelper.HashPassword(password),
                    HoTen = hoTen,
                    Email = string.IsNullOrEmpty(email) ? null : email,
                    SoDienThoai = string.IsNullOrEmpty(sdt) ? null : sdt,
                    VaiTro = vaiTro,
                    NgayDangKy = DateTime.Now,
                    TrangThai = true
                };

                db.NguoiDungs.Add(u);
                db.SaveChanges();

                NhatKyHelper.Ghi(context, "Thêm tài khoản nhân sự", "NguoiDung#" + u.MaNguoiDung, username + " | vai trò: " + vaiTro);
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Thêm tài khoản thành công!" }));
            }
        }

        private static int ParseInt(string s)
        {
            int v;
            return int.TryParse(s, out v) ? v : 0;
        }

        public bool IsReusable => false;
    }
}
