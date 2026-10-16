using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class AdminQuanLyDonHangApi : IHttpHandler, System.Web.SessionState.IRequiresSessionState
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
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    string action = context.Request.QueryString["action"] ?? "";

                    // Chi dem nhanh so don dang cho xu ly (dung cho thong bao realtime)
                    if (action == "pending_count")
                    {
                        int soCho = db.DonHangs.Count(x => x.TrangThaiDon == "Chờ xác nhận");
                        int soDangGiao = db.DonHangs.Count(x => x.TrangThaiDon == "Đang giao" || x.TrangThaiDon == "Đang giao cho Shipper");
                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, choXacNhan = soCho, dangGiao = soDangGiao }));
                        return;
                    }

                    var listDB = db.DonHangs.OrderByDescending(x => x.NgayDat).ToList();

                    // Đã sửa lại đúng tên cột như bạn yêu cầu
                    var dsDonHang = listDB.Select(x => new
                    {
                        id = x.MaDonHang,
                        tenKhach = x.TenNguoiNhan,
                        ngay = x.NgayDat.HasValue ? x.NgayDat.Value.ToString("dd/MM/yyyy HH:mm") : "",
                        tongTien = x.TongTien,
                        sdt = x.SdtNhanHang,
                        diaChi = x.DiaChiGiaoHang,
                        ptThanhToan = x.PhuongThucThanhToan,
                        ttThanhToan = x.TrangThaiThanhToan,
                        maVanDon = x.MaVanDon,
                        ttDon = x.TrangThaiDon,
                        donViVanChuyen = x.DonViVanChuyen,
                        lyDoHuy = x.LyDoHuy,
                        giamGia = (decimal)(x.GiamGia ?? 0),
                        maGiamGia = x.MaGiamGiaCode
                    }).ToList();

                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = dsDonHang }));
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
