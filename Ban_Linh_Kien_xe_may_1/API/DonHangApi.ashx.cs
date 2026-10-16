using System;
using System.Web;
using System.Web.SessionState;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class DonHangApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            if (context.Session["User"] == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "not_logged_in" }));
                return;
            }

            NguoiDung user = (NguoiDung)context.Session["User"];

            string action = context.Request.QueryString["action"];

            try
            {
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    if (!string.IsNullOrEmpty(action) && action == "whoami")
                    {
                        var u = db.NguoiDungs.FirstOrDefault(d => d.MaNguoiDung == user.MaNguoiDung);
                        if (u == null)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "not_found" }));
                            return;
                        }

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = new { u.HoTen, u.Email, u.SoDienThoai } }));
                        return;
                    }

                    // Lấy tất cả đơn hàng của User này, sắp xếp đơn mới nhất lên đầu
                    var danhSachDon = db.DonHangs
                        .Where(d => d.MaNguoiDung == user.MaNguoiDung)
                        .OrderByDescending(d => d.NgayDat)
                        .Select(d => new
                        {
                            MaDonHang = d.MaDonHang,
                            NgayDat = d.NgayDat,
                            TrangThai = d.TrangThaiDon, // Ví dụ: Chờ xác nhận, Đang giao...
                            TongTien = d.TongTien,
                            GiamGia = d.GiamGia,
                            MaGiamGia = d.MaGiamGiaCode,
                            maVanDon = d.MaVanDon,
                            // Lấy luôn chi tiết các sản phẩm nằm trong đơn hàng này
                            ChiTiet = d.ChiTietDonHangs.Select(c => new
                            {
                                TenSP = c.LinhKien.TenLinhKien,
                                HinhAnh = c.LinhKien.HinhAnh,
                                SoLuong = c.SoLuong,
                                DonGia = c.DonGia
                            }).ToList()
                        }).ToList();

                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = danhSachDon }));
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = ex.Message }));
            }
        }
        public bool IsReusable => false;
    }
}