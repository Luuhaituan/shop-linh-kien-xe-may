using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    /// <summary>Quan ly danh gia san pham (UC06 extra): xem, an/hien, xoa.</summary>
    public class QuanLyDanhGiaApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var user = context.Session["User"] as NguoiDung;
            if (user == null || !PhanQuyen.IsAdmin(user.VaiTro))
            {
                context.Response.StatusCode = (user == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn không có quyền truy cập!" }));
                return;
            }

            string action = context.Request.QueryString["action"] ?? context.Request.Form["action"] ?? "get";

            try
            {
                switch (action)
                {
                    case "get": Get(context); break;
                    case "hide": Hide(context, user); break;
                    case "unhide": Unhide(context, user); break;
                    case "delete": Delete(context, user); break;
                    default:
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Unknown action" }));
                        break;
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi xử lý: " + ex.Message }));
            }
        }

        private static HashSet<int> LayDanhSachAn()
        {
            var set = new HashSet<int>();
            string connStr = NhatKyHelper.ChuoiKetNoi();
            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand("SELECT MaDanhGia FROM DanhGiaAn", conn))
            {
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read()) set.Add(Convert.ToInt32(dr["MaDanhGia"]));
                }
            }
            return set;
        }

        private void Get(HttpContext context)
        {
            var hidden = LayDanhSachAn();

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var raw = (from d in db.DanhGias
                           join u in db.NguoiDungs on d.MaNguoiDung equals u.MaNguoiDung
                           orderby d.NgayDanhGia descending
                           select new
                           {
                               d.MaDanhGia,
                               d.MaLinhKien,
                               TenSP = d.LinhKien.TenLinhKien,
                               TenKH = u.HoTen,
                               TenDangNhap = u.TenDangNhap,
                               d.SoSao,
                               d.NoiDung,
                               d.NgayDanhGia
                           }).ToList();

                var data = raw.Select(d => new
                {
                    id = d.MaDanhGia,
                    maLinhKien = d.MaLinhKien,
                    sanPham = d.TenSP,
                    khachHang = d.TenKH,
                    username = d.TenDangNhap,
                    soSao = d.SoSao,
                    noiDung = d.NoiDung,
                    ngay = d.NgayDanhGia.HasValue ? d.NgayDanhGia.Value.ToString("dd/MM/yyyy HH:mm") : "",
                    hidden = hidden.Contains(d.MaDanhGia)
                }).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = data }));
            }
        }

        private void Hide(HttpContext context, NguoiDung user)
        {
            int id = ParseInt(context.Request.Form["id"]);
            string lyDo = context.Request.Form["lyDo"] ?? "";
            if (id <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã đánh giá không hợp lệ!" }));
                return;
            }

            string connStr = NhatKyHelper.ChuoiKetNoi();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("IF NOT EXISTS (SELECT 1 FROM DanhGiaAn WHERE MaDanhGia = @Ma) INSERT INTO DanhGiaAn (MaDanhGia, LyDo) VALUES (@Ma, @LyDo)", conn))
                {
                    cmd.Parameters.AddWithValue("@Ma", id);
                    cmd.Parameters.AddWithValue("@LyDo", (object)lyDo ?? DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }

            NhatKyHelper.Ghi(context, "Ẩn đánh giá", "DanhGia#" + id, lyDo);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã ẩn đánh giá!" }));
        }

        private void Unhide(HttpContext context, NguoiDung user)
        {
            int id = ParseInt(context.Request.Form["id"]);
            if (id <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã đánh giá không hợp lệ!" }));
                return;
            }

            string connStr = NhatKyHelper.ChuoiKetNoi();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("DELETE FROM DanhGiaAn WHERE MaDanhGia = @Ma", conn))
                {
                    cmd.Parameters.AddWithValue("@Ma", id);
                    cmd.ExecuteNonQuery();
                }
            }

            NhatKyHelper.Ghi(context, "Hiện đánh giá", "DanhGia#" + id, null);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã hiện lại đánh giá!" }));
        }

        private void Delete(HttpContext context, NguoiDung user)
        {
            int id = ParseInt(context.Request.QueryString["id"] ?? context.Request.Form["id"]);
            if (id <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã đánh giá không hợp lệ!" }));
                return;
            }

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var dg = db.DanhGias.FirstOrDefault(x => x.MaDanhGia == id);
                if (dg == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Đánh giá không tồn tại!" }));
                    return;
                }
                db.DanhGias.Remove(dg);
                db.SaveChanges();
            }

            string connStr = NhatKyHelper.ChuoiKetNoi();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("DELETE FROM DanhGiaAn WHERE MaDanhGia = @Ma", conn))
                {
                    cmd.Parameters.AddWithValue("@Ma", id);
                    cmd.ExecuteNonQuery();
                }
            }

            NhatKyHelper.Ghi(context, "Xóa đánh giá", "DanhGia#" + id, null);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã xóa đánh giá!" }));
        }

        private static int ParseInt(string s)
        {
            int v;
            return int.TryParse(s, out v) ? v : 0;
        }

        public bool IsReusable => false;
    }
}
