using System;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class QuanLyKhachHangApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            var currentUser = context.Session["User"] as NguoiDung;
            if (currentUser == null || !Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.CoQuyen(currentUser.VaiTro, "khachhang"))
            {
                context.Response.StatusCode = (currentUser == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn không có quyền truy cập!" }));
                return;
            }

            string action = context.Request.QueryString["action"] ?? context.Request.Form["action"] ?? "get";

            try
            {
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    // 1. LẤY DANH SÁCH KHÁCH HÀNG
                    if (action == "get")
                    {
                        var users = db.NguoiDungs.Select(u => new
                        {
                            id = u.MaNguoiDung,
                            username = u.TenDangNhap,
                            name = u.HoTen,
                            email = u.Email,
                            phone = u.SoDienThoai,
                            role = u.VaiTro,
                            // u.TrangThai kiểu bool?: true/null là 1 (hoạt động), false là 0 (khóa)
                            status = (u.TrangThai == false) ? 0 : 1,
                            orderCount = db.DonHangs.Count(d => d.MaNguoiDung == u.MaNguoiDung),
                            // Nếu tên cột trạng thái đơn hàng của bạn là TinhTrang, hãy đổi TrangThaiDonHang thành TinhTrang
                            totalSpent = db.DonHangs
                                           .Where(d => d.MaNguoiDung == u.MaNguoiDung && (d.TrangThaiDon == "Đã giao" || d.TrangThaiDon == "Đã giao thành công" || d.TrangThaiDon == "Hoàn thành"))
                                           .Select(d => (decimal?)d.TongTien)
                                           .Sum() ?? 0
                        }).OrderByDescending(u => u.id).ToList();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = users }));
                        return;
                    }

                    // 2. KHÓA HOẶC MỞ KHÓA TÀI KHOẢN (ĐẢO BOOLEAN)
                    if (action == "toggle_status")
                    {
                        if (!Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.CoQuyen(currentUser.VaiTro, "nguoidung"))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Chỉ quản trị viên mới được khóa/mở tài khoản!" }));
                            return;
                        }

                        int id = int.Parse(context.Request.Form["id"]);
                        if (id == currentUser.MaNguoiDung)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không thể tự khóa tài khoản của chính mình!" }));
                            return;
                        }

                        var targetUser = db.NguoiDungs.FirstOrDefault(u => u.MaNguoiDung == id);
                        if (targetUser == null)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Tài khoản không tồn tại!" }));
                            return;
                        }

                        // Tài khoản Quản trị viên không thể bị khóa
                        if (targetUser.VaiTro == Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.Admin)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không thể khóa tài khoản Quản trị viên!" }));
                            return;
                        }

                        // Đảo trạng thái true/false
                        bool isActive = (targetUser.TrangThai != false);
                        targetUser.TrangThai = !isActive;
                        db.SaveChanges();

                        string msg = (targetUser.TrangThai == false) ? "Đã khóa tài khoản thành công!" : "Đã mở khóa tài khoản thành công!";
                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = msg }));
                        return;
                    }

                    // 3. XEM LỊCH SỬ MUA HÀNG
                    if (action == "order_history")
                    {
                        int id = int.Parse(context.Request.QueryString["id"]);
                        // Lấy dữ liệu thô trước (EF không dịch được DateTime.ToString("...") sang SQL),
                        // sau đó mới format ngày trên RAM.
                        var raw = db.DonHangs
                                       .Where(d => d.MaNguoiDung == id)
                                       .OrderByDescending(d => d.NgayDat)
                                       .Select(d => new
                                       {
                                           id = d.MaDonHang,
                                           ngayDat = d.NgayDat,
                                           total = d.TongTien,
                                           status = d.TrangThaiDon, // Đổi thành d.TinhTrang nếu cột trong CSDL tên là TinhTrang
                                           payment = d.PhuongThucThanhToan
                                       }).ToList();

                        var orders = raw.Select(d => new
                        {
                            id = d.id,
                            date = d.ngayDat.HasValue ? d.ngayDat.Value.ToString("dd/MM/yyyy HH:mm") : "",
                            total = d.total,
                            status = d.status,
                            payment = d.payment
                        }).ToList();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = orders }));
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi xử lý: " + ex.Message }));
            }
        }

        public bool IsReusable => false;
    }
}
