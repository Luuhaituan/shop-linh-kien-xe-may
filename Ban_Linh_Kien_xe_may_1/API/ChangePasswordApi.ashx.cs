using System;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using System.Linq;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class ChangePasswordApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            if (context.Session["User"] == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "not_logged_in" }));
                return;
            }

            var user = (NguoiDung)context.Session["User"];
            string current = context.Request.Form["current"]; // m?t kh?u hi?n t?i
            string @new = context.Request.Form["new"]; // m?t kh?u m?i

            if (string.IsNullOrEmpty(current) || string.IsNullOrEmpty(@new))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Thi?u d? li?u" }));
                return;
            }

            try
            {
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    var u = db.NguoiDungs.FirstOrDefault(x => x.MaNguoiDung == user.MaNguoiDung);
                    if (u == null)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Ng??i dùng không t?n t?i" }));
                        return;
                    }

                    // Ki?m tra m?t kh?u hi?n t?i
                    if (!PasswordHelper.VerifyPassword(u.MatKhau, current))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "M?t kh?u hi?n t?i không ?úng" }));
                        return;
                    }

                    // C?p nh?t m?t kh?u m?i (hash)
                    u.MatKhau = PasswordHelper.HashPassword(@new);
                    db.SaveChanges();

                    // C?p nh?t session ?? ??ng b?
                    context.Session["User"] = u;

                    context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
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
