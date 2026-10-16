using System;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using System.Linq;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class CapNhatTaiKhoanApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            // BỌC TRY-CATCH CHO TOÀN BỘ PHẦN THÂN ĐỂ BẮT MỌI LỖI (Kể cả lỗi ép kiểu Session)
            try
            {
                if (context.Session["User"] == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "not_logged_in" }));
                    return;
                }

                // Dòng này rất hay gây lỗi 500 nếu Session đang lưu cấu trúc khác với NguoiDung
                var userSession = (NguoiDung)context.Session["User"];

                string hoTen = context.Request.Form["hoTen"];
                string email = context.Request.Form["email"];
                string sdt = context.Request.Form["sdt"];

                if (string.IsNullOrEmpty(hoTen) || string.IsNullOrEmpty(sdt))
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Thiếu thông tin" }));
                    return;
                }

                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    var user = db.NguoiDungs.FirstOrDefault(u => u.MaNguoiDung == userSession.MaNguoiDung);
                    if (user == null)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Người dùng không tồn tại" }));
                        return;
                    }

                    // Nếu email thay đổi, kiểm tra trùng
                    if (!string.IsNullOrEmpty(email) && email != user.Email)
                    {
                        if (db.NguoiDungs.Any(u => u.Email == email && u.MaNguoiDung != user.MaNguoiDung))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Email đã được sử dụng bởi tài khoản khác" }));
                            return;
                        }
                        user.Email = email;
                    }

                    user.HoTen = hoTen;
                    user.SoDienThoai = sdt;

                    db.SaveChanges();

                    // Cập nhật session
                    context.Session["User"] = user;

                    context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                }
            }
            catch (Exception ex)
            {   
                // Thay vì sập (lỗi 500), nó sẽ báo lỗi 200 và truyền nguyên nhân lỗi về cho SweetAlert
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi Backend: " + ex.Message }));
            }
        }

        public bool IsReusable => false;
    }
}