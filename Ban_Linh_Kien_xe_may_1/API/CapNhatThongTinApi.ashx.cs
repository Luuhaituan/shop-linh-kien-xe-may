using System;
using System.Web;
using System.Web.SessionState;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class CapNhatThongTinApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            // Kiểm tra đăng nhập
            if (context.Session["User"] == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vui lòng đăng nhập!" }));
                return;
            }

            NguoiDung user = (NguoiDung)context.Session["User"];
            string sdt = context.Request.Form["sdt"];
            string diaChi = context.Request.Form["diaChi"];

            try
            {
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    // Tìm tài khoản trong database
                    var userInDb = db.NguoiDungs.FirstOrDefault(u => u.MaNguoiDung == user.MaNguoiDung);
                    if (userInDb != null)
                    {
                        userInDb.SoDienThoai = sdt;    // Lưu số điện thoại mới
                        userInDb.DiaChi = diaChi;      // Lưu địa chỉ mới

                        db.SaveChanges(); // Lệnh này giúp chốt việc lưu thẳng vào SQL Server

                        // Cập nhật lại Session để lần sau khách F5 lại trang vẫn thấy thông tin mới
                        context.Session["User"] = userInDb;

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                    }
                    else
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không tìm thấy người dùng!" }));
                    }
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