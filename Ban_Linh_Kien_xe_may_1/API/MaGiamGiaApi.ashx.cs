using System;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    /// <summary>
    /// API cho khach hang kiem tra ma giam gia o trang thanh toan.
    /// Tong tien don duoc tinh lai o server (theo gio hang hien tai) de tranh sua gia tu client.
    /// </summary>
    public class MaGiamGiaApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var user = context.Session["User"] as NguoiDung;

            try
            {
                string action = context.Request.QueryString["action"] ?? context.Request.Form["action"] ?? "check";

                // Trang chu hoi co nen hien popup uu dai hay khong.
                // Khach vang lai: hien. Tai khoan da dung ma: khong hien.
                if (action == "promo")
                {
                    string promoCode = context.Request.QueryString["maCode"] ?? context.Request.Form["maCode"] ?? "";
                    bool show = true;
                    if (user != null && MaGiamGiaHelper.DaSuDungBoiNguoiDung(promoCode, user.MaNguoiDung))
                        show = false;

                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, show = show }));
                    return;
                }

                if (user == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn cần đăng nhập để dùng mã giảm giá!" }));
                    return;
                }

                if (action != "check")
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Unknown action" }));
                    return;
                }

                decimal tongTienHang = TinhTongTienGioHang(user.MaNguoiDung);
                if (tongTienHang <= 0)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, valid = false, message = "Giỏ hàng của bạn đang trống." }));
                    return;
                }

                string maCode = context.Request.Form["maCode"] ?? context.Request.QueryString["maCode"];
                var kq = MaGiamGiaHelper.KiemTra(maCode, tongTienHang, user.MaNguoiDung);

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    valid = kq.HopLe,
                    maCode = kq.MaCode,
                    ten = kq.TenKhuyenMai,
                    loaiGiam = kq.LoaiGiam,
                    giaTri = kq.GiaTri,
                    tienGiam = kq.TienGiam,
                    tongTienHang = tongTienHang,
                    tongThanhToan = tongTienHang - kq.TienGiam,
                    message = kq.ThongBao
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi xử lý: " + ex.Message }));
            }
        }

        private static decimal TinhTongTienGioHang(int maNguoiDung)
        {
            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var gioHang = db.GioHangs.FirstOrDefault(g => g.MaNguoiDung == maNguoiDung);
                if (gioHang == null || !gioHang.ChiTietGioHangs.Any()) return 0m;
                return (decimal)gioHang.ChiTietGioHangs.Sum(c => c.SoLuong * c.LinhKien.GiaBan);
            }
        }

        public bool IsReusable => false;
    }
}
