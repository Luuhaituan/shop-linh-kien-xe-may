using System;
using System.Web;
using System.Web.SessionState;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class DatHangApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            if (context.Session["User"] == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn cần đăng nhập để thanh toán!" }));
                return;
            }

            NguoiDung user = (NguoiDung)context.Session["User"];

            // Nhận dữ liệu từ form HTML gửi lên
            string ten = context.Request.Form["ten"];
            string sdt = context.Request.Form["sdt"];
            string diaChi = context.Request.Form["diaChi"];
            string ptThanhToan = context.Request.Form["ptThanhToan"];
            string maCode = (context.Request.Form["maCode"] ?? "").Trim().ToUpper();

            try
            {
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    var gioHang = db.GioHangs.FirstOrDefault(g => g.MaNguoiDung == user.MaNguoiDung);
                    if (gioHang == null || !gioHang.ChiTietGioHangs.Any())
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Giỏ hàng trống!" }));
                        return;
                    }

                    var chiTietGH = gioHang.ChiTietGioHangs.ToList();
                    decimal tongTien = (decimal)chiTietGH.Sum(c => c.SoLuong * c.LinhKien.GiaBan);

                    // === 1b. ÁP DỤNG MÃ GIẢM GIÁ (nếu có) ===
                    decimal tienGiam = 0m;
                    if (!string.IsNullOrEmpty(maCode))
                    {
                        var kqGiam = MaGiamGiaHelper.KiemTra(maCode, tongTien, user.MaNguoiDung);
                        if (!kqGiam.HopLe)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = kqGiam.ThongBao }));
                            return;
                        }
                        tienGiam = kqGiam.TienGiam;
                    }
                    decimal tongThanhToan = tongTien - tienGiam;
                    if (tongThanhToan < 0) tongThanhToan = 0;

                    // === 1. CẬP NHẬT THÔNG TIN NGƯỜI DÙNG ===
                    var userInDb = db.NguoiDungs.FirstOrDefault(u => u.MaNguoiDung == user.MaNguoiDung);
                    if (userInDb != null)
                    {
                        userInDb.HoTen = ten;
                        userInDb.SoDienThoai = sdt;
                        userInDb.DiaChi = diaChi;

                        // Lưu đè thông tin mới vào Session để giao diện tự cập nhật
                        context.Session["User"] = userInDb;
                    }
                    // =========================================

                    // === 2. TẠO MÃ VẬN ĐƠN THEO THỜI GIAN ===
                    // VD260921145106 (Ví dụ: Năm 26, Tháng 09, Ngày 21, 14h51m06s)
                    string trackingCode = "VD" + DateTime.Now.ToString("yyMMddHHmmss");
                    // =========================================

                    // 3. Khởi tạo đơn hàng với các trường thông tin chuẩn xác
                    Models.DonHang donHangMoi = new Models.DonHang
                    {
                        MaNguoiDung = user.MaNguoiDung,
                        NgayDat = DateTime.Now,
                        TongTien = tongThanhToan,
                        GiamGia = tienGiam > 0 ? (decimal?)tienGiam : null,
                        MaGiamGiaCode = tienGiam > 0 ? maCode : null,
                        TenNguoiNhan = ten,
                        SdtNhanHang = sdt,
                        DiaChiGiaoHang = diaChi,
                        PhuongThucThanhToan = ptThanhToan,
                        TrangThaiThanhToan = "Chưa thanh toán",
                        TrangThaiDon = "Chờ xác nhận",

                        // LƯU Ý QUAN TRỌNG: 
                        // Nếu trong SQL của bạn chưa có cột "MaVanDon" thì bạn phải vào SQL Server tạo thêm, 
                        // rồi "Update Model from Database" trong file .edmx nhé!
                        // Nếu tên cột của bạn khác (ví dụ: MaTheoDoi, TrackingNumber...), hãy sửa lại cho đúng.
                        MaVanDon = trackingCode
                    };

                    db.DonHangs.Add(donHangMoi);
                    db.SaveChanges(); // Lấy MaDonHang

                    // 4. Chuyển vào Chi tiết
                    foreach (var item in chiTietGH)
                    {
                        db.ChiTietDonHangs.Add(new ChiTietDonHang
                        {
                            MaDonHang = donHangMoi.MaDonHang,
                            MaLinhKien = item.MaLinhKien,
                            SoLuong = item.SoLuong,
                            DonGia = item.LinhKien.GiaBan
                        });

                        // BỔ SUNG THÊM LOGIC TRỪ TỒN KHO:
                        // (Khách mua 1 cái thì kho phải giảm đi 1 cái)
                        var linhKien = db.LinhKiens.FirstOrDefault(lk => lk.MaLinhKien == item.MaLinhKien);
                        if (linhKien != null)
                        {
                            linhKien.SoLuongTon = linhKien.SoLuongTon - item.SoLuong;
                        }
                    }

                    // 5. Xóa Giỏ hàng   
                    db.ChiTietGioHangs.RemoveRange(chiTietGH);

                    // 6. Lưu toàn bộ thay đổi (Chi tiết đơn, Tồn kho, Xóa giỏ hàng)
                    db.SaveChanges();

                    // Tăng số lượt đã dùng của mã giảm giá
                    if (tienGiam > 0) MaGiamGiaHelper.TangSoLanDung(maCode);

                    // TRẢ VỀ CẢ MÃ ĐƠN (ID) VÀ MÃ VẬN ĐƠN (Chữ) CHO GIAO DIỆN
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        maDonHang = donHangMoi.MaDonHang,
                        maVanDon = trackingCode, // Trả về để trang web báo "Mã vận đơn của bạn là: VD..."
                        tongTien = tongTien,          // Tổng tiền hàng trước giảm giá
                        tienGiam = tienGiam,          // Số tiền được giảm
                        tongThanhToan = tongThanhToan // Số tiền thực tế phải trả
                    }));
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