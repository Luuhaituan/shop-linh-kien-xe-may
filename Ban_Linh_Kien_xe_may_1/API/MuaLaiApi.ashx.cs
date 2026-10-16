using System;
using System.Web;
using System.Web.SessionState;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class MuaLaiApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            if (context.Session["User"] == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vui lòng đăng nhập!" }));
                return;
            }

            int maDonHang;
            if (!int.TryParse(context.Request.QueryString["id"], out maDonHang))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã đơn hàng không hợp lệ!" }));
                return;
            }

            NguoiDung user = (NguoiDung)context.Session["User"];

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var donHangCu = db.DonHangs.FirstOrDefault(d => d.MaDonHang == maDonHang && d.MaNguoiDung == user.MaNguoiDung);

                if (donHangCu != null)
                {
                    // Lấy giỏ hàng hiện tại (Nếu chưa có thì tạo mới)
                    var gioHang = db.GioHangs.FirstOrDefault(g => g.MaNguoiDung == user.MaNguoiDung);
                    if (gioHang == null)
                    {
                        gioHang = new GioHang { MaNguoiDung = user.MaNguoiDung, NgayCapNhat = DateTime.Now };
                        db.GioHangs.Add(gioHang);
                        db.SaveChanges(); // Để sinh ra MaGioHang
                    }

                    // Lặp qua các chi tiết đơn hàng cũ để ném vào giỏ
                    foreach (var chiTietCu in donHangCu.ChiTietDonHangs)
                    {
                        var chiTietGio = db.ChiTietGioHangs.FirstOrDefault(c => c.MaGioHang == gioHang.MaGioHang && c.MaLinhKien == chiTietCu.MaLinhKien);

                        if (chiTietGio != null)
                        {
                            chiTietGio.SoLuong += chiTietCu.SoLuong; // Cộng dồn nếu trong giỏ đã có
                        }
                        else
                        {
                            db.ChiTietGioHangs.Add(new ChiTietGioHang
                            {
                                MaGioHang = gioHang.MaGioHang,
                                MaLinhKien = chiTietCu.MaLinhKien,
                                SoLuong = chiTietCu.SoLuong
                            });
                        }
                    }
                    db.SaveChanges();
                    context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                }
                else
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không tìm thấy đơn hàng gốc!" }));
                }
            }
        }
        public bool IsReusable => false;
    }
}