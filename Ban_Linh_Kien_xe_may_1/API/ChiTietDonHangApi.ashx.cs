using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class ChiTietDonHangApi : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            var user = context.Session["User"] as Ban_Linh_Kien_xe_may_1.Models.NguoiDung;
            if (user == null || !Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.CoQuyen(user.VaiTro, "donhang"))
            {
                context.Response.StatusCode = (user == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Từ chối truy cập!" }));
                return;
            }

            try
            {
                int id = Convert.ToInt32(context.Request["id"]);
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    // Lấy các sản phẩm thuộc về Mã Đơn Hàng này
                    var chiTiet = db.ChiTietDonHangs.Where(x => x.MaDonHang == id).Select(x => new
                    {
                        tenSP = x.LinhKien.TenLinhKien,
                        hinhAnh = x.LinhKien.HinhAnh,
                        soLuong = x.SoLuong,
                        donGia = x.DonGia,
                        thanhTien = x.SoLuong * x.DonGia
                    }).ToList();

                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = chiTiet }));
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
