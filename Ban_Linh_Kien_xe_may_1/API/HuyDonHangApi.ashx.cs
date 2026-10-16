using System;
using System.Web;
using System.Web.SessionState;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class HuyDonHangApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            // 1. Kiểm tra đăng nhập
            if (context.Session["User"] == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "not_logged_in" }));
                return;
            }

            try
            {
                var currentUser = (NguoiDung)context.Session["User"];
                int maDonHang = Convert.ToInt32(context.Request["id"]);
                string action = context.Request["action"]; // Lấy biến action từ Javascript (huy hoặc hoanhang)

                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    // Lấy đơn hàng từ Database
                    var donHang = db.DonHangs.FirstOrDefault(d => d.MaDonHang == maDonHang && d.MaNguoiDung == currentUser.MaNguoiDung);

                    if (donHang == null)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không tìm thấy đơn hàng!" }));
                        return;
                    }

                    // ==========================================
                    // LUỒNG 1: XỬ LÝ TRẢ HÀNG / HOÀN TIỀN
                    // ==========================================
                    if (action == "hoanhang")
                    {
                        if (donHang.TrangThaiDon == "Hoàn thành" || donHang.TrangThaiDon.ToLower() == "hoàn thành")
                        {
                            // Kiểm tra quá 7 ngày không cho trả
                            if (donHang.NgayDat.HasValue)
                            {
                                TimeSpan thoiGianDaQua = DateTime.Now - donHang.NgayDat.Value;
                                if (thoiGianDaQua.TotalDays > 7)
                                {
                                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Đã quá thời hạn 7 ngày để yêu cầu trả hàng!" }));
                                    return;
                                }
                            }

                            string lyDo = context.Request["lydo"];

                            // Đổi trạng thái sang Trả hàng
                            donHang.TrangThaiDon = "Trả hàng/Hoàn tiền";
                            db.SaveChanges();
                            context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                        }
                        else
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Đơn hàng chưa hoàn thành, không thể trả hàng!" }));
                        }
                    }
                    // ==========================================
                    // LUỒNG 2: XỬ LÝ HỦY ĐƠN HÀNG (CHỜ XÁC NHẬN)
                    // ==========================================
                    else
                    {
                        if (donHang.TrangThaiDon == "Chờ xác nhận" || donHang.TrangThaiDon.ToLower() == "chờ xác nhận")
                        {
                            // Đổi trạng thái sang Đã hủy
                            donHang.TrangThaiDon = "Đã hủy";
                            db.SaveChanges();
                            context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                        }
                        else
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Đơn hàng đang ở trạng thái không thể hủy!" }));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi máy chủ: " + ex.Message }));
            }
        }

        public bool IsReusable => false;
    }
}