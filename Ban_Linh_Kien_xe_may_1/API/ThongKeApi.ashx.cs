using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    /// <summary>
    /// Thong ke quan tri:
    ///   - Mac dinh: so lieu tong quan + doanh thu theo ngay + top san pham/khach hang.
    ///   - Query: ?from=yyyy-MM-dd&to=yyyy-MM-dd de gioi han khoang thoi gian.
    /// </summary>
    public class ThongKeApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var user = context.Session["User"] as NguoiDung;
            if (user == null || !PhanQuyen.IsAdmin(user.VaiTro))
            {
                context.Response.StatusCode = (user == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Từ chối truy cập!" }));
                return;
            }

            try
            {
                DateTime den = DateTime.Now.Date;
                DateTime tu = den.AddDays(-29);
                DateTime tmp;
                if (DateTime.TryParse(context.Request.QueryString["from"], out tmp)) tu = tmp.Date;
                if (DateTime.TryParse(context.Request.QueryString["to"], out tmp)) den = tmp.Date;
                DateTime denCuoi = den.AddDays(1); // bao gom ca ngay 'to'

                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    var orders = db.DonHangs.ToList();

                    int tongDon = orders.Count;
                    int daGiao = orders.Count(x => x.TrangThaiDon == "Đã giao" || x.TrangThaiDon == "Đã giao thành công" || x.TrangThaiDon == "Hoàn thành");
                    int daHuy = orders.Count(x => x.TrangThaiDon == "Đã hủy" || x.TrangThaiDon == "Hủy bỏ" || x.TrangThaiDon == "Hủy đơn hàng");
                    int hoanTra = orders.Count(x => x.TrangThaiDon == "Hoàn trả" || x.TrangThaiDon == "Trả hàng/Hoàn tiền" || x.TrangThaiDon == "Khách hoàn trả hàng");
                    int choXacNhan = orders.Count(x => x.TrangThaiDon == "Chờ xác nhận");
                    int dangGiao = orders.Count(x => x.TrangThaiDon == "Đang giao" || x.TrangThaiDon == "Đang giao cho Shipper");
                    int dangXuLy = orders.Count(x => x.TrangThaiDon == "Đã xác nhận" || x.TrangThaiDon == "Đang chuẩn bị hàng");

                    decimal doanhThu = orders
                        .Where(x => x.TrangThaiDon == "Đã giao" || x.TrangThaiDon == "Đã giao thành công" || x.TrangThaiDon == "Hoàn thành")
                        .Sum(x => (decimal?)x.TongTien) ?? 0;

                    // Doanh thu theo ngay trong khoang
                    var trongKhoang = orders.Where(o => o.NgayDat.HasValue && o.NgayDat.Value >= tu && o.NgayDat.Value < denCuoi).ToList();

                    var doanhThuTheoNgay = trongKhoang
                        .Where(o => o.TrangThaiDon == "Đã giao" || o.TrangThaiDon == "Đã giao thành công" || o.TrangThaiDon == "Hoàn thành")
                        .GroupBy(o => o.NgayDat.Value.Date)
                        .Select(g => new { ngay = g.Key.ToString("dd/MM"), tien = g.Sum(x => x.TongTien), don = g.Count() })
                        .OrderBy(x => x.ngay)
                        .ToList();

                    // Top san pham ban chay trong khoang
                    var maDonTrongKhoang = trongKhoang.Select(o => o.MaDonHang).ToList();
                    var tenSanPham = db.LinhKiens.ToDictionary(l => l.MaLinhKien, l => l.TenLinhKien);
                    var topSanPham = db.ChiTietDonHangs
                        .Where(ct => maDonTrongKhoang.Contains(ct.MaDonHang))
                        .ToList()
                        .GroupBy(ct => ct.MaLinhKien)
                        .Select(g => new
                        {
                            maLinhKien = g.Key,
                            ten = tenSanPham.ContainsKey(g.Key) ? tenSanPham[g.Key] : ("#" + g.Key),
                            soLuong = g.Sum(x => x.SoLuong),
                            doanhThu = g.Sum(x => x.SoLuong * x.DonGia)
                        })
                        .OrderByDescending(x => x.soLuong)
                        .Take(10)
                        .ToList();

                    // Top khach hang trong khoang
                    var tenKhach = db.NguoiDungs.ToDictionary(u => u.MaNguoiDung, u => u.HoTen);
                    var topKhachHang = trongKhoang
                        .GroupBy(o => o.MaNguoiDung)
                        .Select(g => new
                        {
                            maNguoiDung = g.Key,
                            ten = tenKhach.ContainsKey(g.Key) ? tenKhach[g.Key] : ("KH#" + g.Key),
                            soDon = g.Count(),
                            chiTieu = g.Where(o => o.TrangThaiDon == "Đã giao" || o.TrangThaiDon == "Đã giao thành công" || o.TrangThaiDon == "Hoàn thành").Sum(o => (decimal?)o.TongTien) ?? 0
                        })
                        .OrderByDescending(x => x.chiTieu)
                        .Take(10)
                        .ToList();

                    var kq = new
                    {
                        success = true,
                        data = new
                        {
                            tongDon,
                            daGiao,
                            daHuy,
                            hoanTra,
                            choXacNhan,
                            dangGiao,
                            dangXuLy,
                            doanhThu,
                            tuNgay = tu.ToString("dd/MM/yyyy"),
                            denNgay = den.ToString("dd/MM/yyyy"),
                            doanhThuTheoNgay,
                            topSanPham,
                            topKhachHang
                        }
                    };

                    context.Response.Write(JsonConvert.SerializeObject(kq));
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
