using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class ChiTietSPApi : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            // Lấy ID sản phẩm từ URL
            int maLinhKien;
            if (!int.TryParse(context.Request.QueryString["id"], out maLinhKien))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã sản phẩm không hợp lệ!" }));
                return;
            }

            try
            {
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    // Chỉ lấy các cột cơ bản nhất chắc chắn có trong SQL
                    var sanPham = db.LinhKiens
                        .Where(sp => sp.MaLinhKien == maLinhKien)
                        .Select(sp => new
                        {
                            MaLinhKien = sp.MaLinhKien,
                            TenLinhKien = sp.TenLinhKien,
                            GiaBan = sp.GiaBan,
                            HinhAnh = sp.HinhAnh,
                            MoTa = sp.MoTa,
                            SoLuongTon = sp.SoLuongTon,

                            DaBan = db.ChiTietDonHangs.Where(ct => ct.MaLinhKien == sp.MaLinhKien).Sum(ct => (int?)ct.SoLuong) ?? 0
                        }).FirstOrDefault();

                    if (sanPham != null)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = sanPham }));
                    }
                    else
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không tìm thấy sản phẩm!" }));
                    }
                }
            }
            catch (Exception ex)
            {
                // Nếu lỗi SQL sẽ báo thẳng ra để dễ sửa
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi SQL: " + ex.Message }));
            }
        }
        public bool IsReusable => false;
    }
}