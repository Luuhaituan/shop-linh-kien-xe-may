using System;
using System.IO;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    // Model dữ liệu nhận từ SePay (chuyển sang kiểu nullable để tránh lỗi ép kiểu)
    public class SePayWebhookPayload
    {
        public long? id { get; set; }
        public string gateway { get; set; }
        public string transactionDate { get; set; }
        public string accountNumber { get; set; }
        public string content { get; set; }        // Nội dung CK
        public string transferType { get; set; }   // "in" hoặc "out"
        public decimal? transferAmount { get; set; } // Số tiền
    }

    public class SePayWebhook : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            // 1. Chỉ nhận POST
            if (context.Request.HttpMethod != "POST")
            {
                context.Response.StatusCode = 200;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Method Not Allowed" }));
                return;
            }

            try
            {
                // 2. Đọc chuỗi JSON
                string jsonBody;
                using (var reader = new StreamReader(context.Request.InputStream))
                {
                    jsonBody = reader.ReadToEnd();
                }

                if (string.IsNullOrWhiteSpace(jsonBody))
                {
                    context.Response.StatusCode = 200;
                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Empty body" }));
                    return;
                }

                var data = JsonConvert.DeserializeObject<SePayWebhookPayload>(jsonBody);

                if (data == null)
                {
                    context.Response.StatusCode = 200;
                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Null data" }));
                    return;
                }

                // 3. Nếu là giao dịch test hoặc không phải tiền vào -> Trả về 200 luôn để SePay báo thành công
                if (data.transferType != "in" || string.IsNullOrEmpty(data.content))
                {
                    context.Response.StatusCode = 200;
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Webhook nhận thành công (Bỏ qua vì không phải tiền vào hoặc nội dung trống)"
                    }));
                    return;
                }

                decimal soTienChuyen = data.transferAmount ?? 0;
                string noiDungCK = data.content.Trim();

                // 4. Tìm đơn hàng trong SQL Server
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    // Lấy các đơn chưa thanh toán có mã vận đơn
                    var pendingOrders = db.DonHangs
                                          .Where(d => d.TrangThaiThanhToan == "Chưa thanh toán" && d.MaVanDon != null && d.MaVanDon != "")
                                          .ToList();

                    // Tìm đơn có mã vận đơn nằm trong nội dung chuyển khoản
                    var donHang = pendingOrders.FirstOrDefault(d =>
                        noiDungCK.IndexOf(d.MaVanDon, StringComparison.OrdinalIgnoreCase) >= 0
                    );

                    if (donHang != null)
                    {
                        // Kiểm tra số tiền
                        if (soTienChuyen >= donHang.TongTien)
                        {
                            donHang.TrangThaiThanhToan = "Đã thanh toán";
                            donHang.TrangThaiDon = "Đã xác nhận";
                            db.SaveChanges();

                            context.Response.StatusCode = 200;
                            context.Response.Write(JsonConvert.SerializeObject(new
                            {
                                success = true,
                                message = "Cập nhật đơn hàng thành công!",
                                maVanDon = donHang.MaVanDon
                            }));
                            return;
                        }
                    }

                    // Kể cả không khớp đơn hàng (ví dụ khi SePay gửi test mã ảo), vẫn trả về HTTP 200 để SePay không báo lỗi 500
                    context.Response.StatusCode = 200;
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Nhận webhook thành công nhưng không tìm thấy đơn hàng trùng khớp!"
                    }));
                }
            }
            catch (Exception ex)
            {
                // Trả về 200 kèm nội dung lỗi để dễ debug và không làm SePay đỏ màn hình
                context.Response.StatusCode = 200;
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    error = ex.Message,
                    inner = ex.InnerException != null ? ex.InnerException.Message : ""
                }));
            }
        }

        public bool IsReusable => false;
    }
}