using System;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class XoaSanPhamApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var user = context.Session["User"] as NguoiDung;
            if (user == null || !PhanQuyen.IsAdmin(user.VaiTro))
            {
                context.Response.StatusCode = (user == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn không có quyền thực hiện thao tác này!" }));
                return;
            }

            string idStr = context.Request.QueryString["id"] ?? context.Request.Form["id"];
            if (string.IsNullOrEmpty(idStr) || !int.TryParse(idStr, out int id))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã sản phẩm không hợp lệ!" }));
                return;
            }

            // hard=1 -> xóa vĩnh viễn; restore=1 -> hiện lại sản phẩm đã ẩn; mặc định -> xóa mềm
            bool xoaVinhVien = context.Request.QueryString["hard"] == "1" || context.Request.Form["hard"] == "1";
            bool hienLai = context.Request.QueryString["restore"] == "1" || context.Request.Form["restore"] == "1";

            try
            {
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    var sp = db.LinhKiens.FirstOrDefault(x => x.MaLinhKien == id);
                    if (sp == null)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Sản phẩm không tồn tại hoặc đã bị xóa!" }));
                        return;
                    }

                    if (hienLai)
                    {
                        sp.TrangThai = true;
                        db.SaveChanges();
                        NhatKyHelper.Ghi(context, "Hiện lại sản phẩm", "LinhKien#" + id, sp.TenLinhKien);
                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã hiển thị lại sản phẩm!" }));
                        return;
                    }

                    if (!xoaVinhVien)
                    {
                        // XÓA MỀM: giữ lại dữ liệu lịch sử, chỉ ẩn khỏi người dùng
                        sp.TrangThai = false;
                        db.SaveChanges();

                        NhatKyHelper.Ghi(context, "Ẩn sản phẩm (xóa mềm)", "LinhKien#" + id, sp.TenLinhKien);
                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã ẩn sản phẩm khỏi cửa hàng thành công!" }));
                        return;
                    }

                    // XÓA VĨNH VIỄN: chỉ nên dùng khi chắc chắn
                    var danhGias = db.DanhGias.Where(dg => dg.MaLinhKien == id).ToList();
                    if (danhGias.Any()) db.DanhGias.RemoveRange(danhGias);

                    var chiTiets = db.ChiTietDonHangs.Where(ct => ct.MaLinhKien == id).ToList();
                    if (chiTiets.Any()) db.ChiTietDonHangs.RemoveRange(chiTiets);

                    var gioHangs = db.ChiTietGioHangs.Where(ct => ct.MaLinhKien == id).ToList();
                    if (gioHangs.Any()) db.ChiTietGioHangs.RemoveRange(gioHangs);

                    var dongXeLienKet = sp.DongXes.ToList();
                    foreach (var xe in dongXeLienKet) sp.DongXes.Remove(xe);

                    db.LinhKiens.Remove(sp);
                    db.SaveChanges();

                    NhatKyHelper.Ghi(context, "Xóa vĩnh viễn sản phẩm", "LinhKien#" + id, null);
                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã xóa vĩnh viễn sản phẩm!" }));
                }
            }
            catch (Exception ex)
            {
                string msg = ex.InnerException?.InnerException?.Message ?? ex.InnerException?.Message ?? ex.Message;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi xóa: " + msg }));
            }
        }

        public bool IsReusable => false;
    }
}
