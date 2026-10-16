using System;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class QuanLyDanhMucApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                // Kiểm tra quyền Admin
                var user = context.Session["User"] as NguoiDung;
                if (user == null || !Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsAdmin(user.VaiTro))
                {
                    context.Response.StatusCode = (user == null) ? 401 : 403;
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không có quyền truy cập!" }));
                    return;
                }

                string action = context.Request.QueryString["action"] ?? context.Request.Form["action"] ?? "get";

                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    // 1. LẤY DANH SÁCH DANH MỤC + ĐẾM SỐ SẢN PHẨM LIÊN KẾT
                    if (action == "get")
                    {
                        var list = db.DanhMucs.Select(d => new
                        {
                            id = d.MaDanhMuc,
                            name = d.TenDanhMuc,
                            count = db.LinhKiens.Count(l => l.MaDanhMuc == d.MaDanhMuc)
                        })
                            .ToList();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = list }));
                        return;
                    }

                    // 2. THÊM DANH MỤC MỚI
                    if (action == "add")
                    {
                        string name = context.Request.Form["name"]?.Trim();
                        if (string.IsNullOrEmpty(name))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vui lòng nhập tên danh mục!" }));
                            return;
                        }

                        if (db.DanhMucs.Any(d => d.TenDanhMuc.ToLower() == name.ToLower()))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Tên danh mục này đã tồn tại!" }));
                            return;
                        }

                        var dm = new DanhMuc { TenDanhMuc = name };
                        db.DanhMucs.Add(dm);
                        db.SaveChanges();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Thêm danh mục thành công!" }));
                        return;
                    }

                    // 3. SỬA DANH MỤC
                    if (action == "update")
                    {
                        int id = int.Parse(context.Request.Form["id"]);
                        string name = context.Request.Form["name"]?.Trim();

                        if (string.IsNullOrEmpty(name))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Tên danh mục không được để trống!" }));
                            return;
                        }

                        var dm = db.DanhMucs.FirstOrDefault(d => d.MaDanhMuc == id);
                        if (dm == null)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Danh mục không tồn tại!" }));
                            return;
                        }

                        if (db.DanhMucs.Any(d => d.TenDanhMuc.ToLower() == name.ToLower() && d.MaDanhMuc != id))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Tên danh mục này đã trùng với danh mục khác!" }));
                            return;
                        }

                        dm.TenDanhMuc = name;
                        db.SaveChanges();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Cập nhật danh mục thành công!" }));
                        return;
                    }

                    // 4. XÓA DANH MỤC (BẢO VỆ DỮ LIỆU)
                    if (action == "delete")
                    {
                        int id = int.Parse(context.Request.QueryString["id"] ?? context.Request.Form["id"]);

                        // Kiểm tra nếu còn sản phẩm trực thuộc danh mục thì ngăn không cho xóa
                        bool hasProducts = db.LinhKiens.Any(l => l.MaDanhMuc == id);
                        if (hasProducts)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new
                            {
                                success = false,
                                message = "Không thể xóa! Danh mục này đang chứa sản phẩm, hãy chuyển hoặc xóa sản phẩm trước."
                            }));
                            return;
                        }

                        var dm = db.DanhMucs.FirstOrDefault(d => d.MaDanhMuc == id);
                        if (dm == null)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Danh mục không tồn tại!" }));
                            return;
                        }

                        db.DanhMucs.Remove(dm);
                        db.SaveChanges();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Xóa danh mục thành công!" }));
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi xử lý: " + ex.Message }));
            }
        }

        public bool IsReusable => false;
    }
}
