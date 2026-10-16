using System;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using System.Collections.Generic;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class CapNhatDonHangApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            var user = context.Session["User"] as NguoiDung;
            if (user == null || !Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.CoQuyen(user.VaiTro, "donhang"))
            {
                context.Response.StatusCode = (user == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn không có quyền thực hiện thao tác này!" }));
                return;
            }

            try
            {
                int id = int.Parse(context.Request.Form["id"]);
                string trangThaiMoi = context.Request.Form["trangThai"];
                string ttThanhToanMoi = context.Request.Form["trangThaiThanhToan"];
                string donViVC = context.Request.Form["donViVanChuyen"];
                string maVanDon = context.Request.Form["maVanDon"];
                string lyDoHuy = context.Request.Form["lyDoHuy"];

                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    var don = db.DonHangs.FirstOrDefault(d => d.MaDonHang == id);
                    if (don == null)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Đơn hàng không tồn tại!" }));
                        return;
                    }

                    string trangThaiCu = don.TrangThaiDon;

                    // KIỂM TRA LUỒNG TRẠNG THÁI HỢP LỆ
                    if (!string.IsNullOrEmpty(trangThaiMoi) && trangThaiMoi != trangThaiCu)
                    {
                        if (!KiemTraLuongHopLe(trangThaiCu, trangThaiMoi, out string msgError))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = msgError }));
                            return;
                        }

                        // Nếu chuyển sang Đã giao -> Tự động chuyển thanh toán sang Đã thanh toán (nếu là COD)
                        if (trangThaiMoi == "Đã giao" && don.PhuongThucThanhToan == "COD")
                        {
                            don.TrangThaiThanhToan = "Đã thanh toán";
                        }

                        // Nếu hủy mà chưa có lý do
                        if (trangThaiMoi == "Đã hủy" && string.IsNullOrEmpty(lyDoHuy))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vui lòng chọn hoặc nhập lý do hủy đơn!" }));
                            return;
                        }

                        don.TrangThaiDon = trangThaiMoi;
                        if (!string.IsNullOrEmpty(lyDoHuy)) don.LyDoHuy = lyDoHuy;

                        // Ghi lại lịch sử (nếu có bảng LichSuDonHang)
                        try
                        {
                            db.Database.ExecuteSqlCommand(
                                "INSERT INTO LichSuDonHang (MaDonHang, TrangThaiCu, TrangThaiMoi, GhiChu, ThoiGian, NguoiThucHien) VALUES ({0}, {1}, {2}, {3}, GETDATE(), {4})",
                                id, trangThaiCu, trangThaiMoi, lyDoHuy ?? "", user.HoTen ?? user.TenDangNhap
                            );
                        }
                        catch { /* Bỏ qua nếu chưa update DB */ }
                    }

                    // Cập nhật trạng thái thanh toán riêng
                    if (!string.IsNullOrEmpty(ttThanhToanMoi))
                    {
                        don.TrangThaiThanhToan = ttThanhToanMoi;
                    }

                    // Cập nhật vận đơn
                    if (!string.IsNullOrEmpty(donViVC)) don.DonViVanChuyen = donViVC;
                    if (!string.IsNullOrEmpty(maVanDon)) don.MaVanDon = maVanDon;

                    db.SaveChanges();
                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Cập nhật đơn hàng thành công!" }));
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi xử lý: " + ex.Message }));
            }
        }

        // Định nghĩa ma trận luồng trạng thái
        private bool KiemTraLuongHopLe(string trangThaiCu, string trangThaiMoi, out string message)
        {
            message = "";
            if (trangThaiCu == "Đã hủy" || trangThaiCu == "Hủy bỏ")
            {
                message = "Đơn hàng đã hủy, không thể thay đổi trạng thái nữa!";
                return false;
            }
            if (trangThaiCu == "Đã giao" && (trangThaiMoi == "Chờ xác nhận" || trangThaiMoi == "Đang chuẩn bị hàng" || trangThaiMoi == "Đang giao"))
            {
                message = "Đơn hàng đã giao thành công, không thể chuyển ngược lại giai đoạn giao/chuẩn bị!";
                return false;
            }
            return true;
        }

        public bool IsReusable => false;
    }
}
