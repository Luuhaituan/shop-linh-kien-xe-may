using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    /// <summary>Quan ly Dong xe (UC06.19) va lien ket Dong xe - Linh kien (many-to-many TuongThichXe).</summary>
    public class QuanLyDongXeApi : IHttpHandler, IRequiresSessionState
    {
        private static string ConnStr()
        {
            return NhatKyHelper.ChuoiKetNoi();
        }

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
                    case "add": Add(context, user); break;
                    case "update": Update(context, user); break;
                    case "delete": Delete(context, user); break;
                    case "get_by_product": GetByProduct(context); break;
                    case "set_product": SetProduct(context, user); break;
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

        private void Get(HttpContext context)
        {
            var list = new List<object>();
            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var data = db.DongXes
                    .OrderBy(d => d.HangXe).ThenBy(d => d.TenXe)
                    .Select(d => new
                    {
                        id = d.MaXe,
                        hangXe = d.HangXe,
                        tenXe = d.TenXe,
                        doiXe = d.DoiXe,
                        count = d.LinhKiens.Count()
                    }).ToList();
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = data }));
            }
        }

        private void Add(HttpContext context, NguoiDung user)
        {
            string hangXe = (context.Request.Form["hangXe"] ?? "").Trim();
            string tenXe = (context.Request.Form["tenXe"] ?? "").Trim();
            int? doiXe = ParseNullableInt(context.Request.Form["doiXe"]);

            if (string.IsNullOrEmpty(hangXe) || string.IsNullOrEmpty(tenXe))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vui lòng nhập Hãng xe và Tên xe!" }));
                return;
            }

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                if (db.DongXes.Any(d => d.HangXe.ToLower() == hangXe.ToLower() && d.TenXe.ToLower() == tenXe.ToLower()))
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Dòng xe này đã tồn tại!" }));
                    return;
                }

                var xe = new DongXe { HangXe = hangXe, TenXe = tenXe, DoiXe = doiXe };
                db.DongXes.Add(xe);
                db.SaveChanges();

                NhatKyHelper.Ghi(context, "Thêm dòng xe", "DongXe#" + xe.MaXe, hangXe + " " + tenXe);
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Thêm dòng xe thành công!" }));
            }
        }

        private void Update(HttpContext context, NguoiDung user)
        {
            int id = ParseInt(context.Request.Form["id"]);
            string hangXe = (context.Request.Form["hangXe"] ?? "").Trim();
            string tenXe = (context.Request.Form["tenXe"] ?? "").Trim();
            int? doiXe = ParseNullableInt(context.Request.Form["doiXe"]);

            if (id <= 0 || string.IsNullOrEmpty(hangXe) || string.IsNullOrEmpty(tenXe))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Thông tin chưa hợp lệ!" }));
                return;
            }

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var xe = db.DongXes.FirstOrDefault(d => d.MaXe == id);
                if (xe == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Dòng xe không tồn tại!" }));
                    return;
                }

                if (db.DongXes.Any(d => d.MaXe != id && d.HangXe.ToLower() == hangXe.ToLower() && d.TenXe.ToLower() == tenXe.ToLower()))
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Dòng xe này đã trùng với dòng xe khác!" }));
                    return;
                }

                xe.HangXe = hangXe;
                xe.TenXe = tenXe;
                xe.DoiXe = doiXe;
                db.SaveChanges();

                NhatKyHelper.Ghi(context, "Sửa dòng xe", "DongXe#" + id, hangXe + " " + tenXe);
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Cập nhật dòng xe thành công!" }));
            }
        }

        private void Delete(HttpContext context, NguoiDung user)
        {
            int id = ParseInt(context.Request.QueryString["id"] ?? context.Request.Form["id"]);
            if (id <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã dòng xe không hợp lệ!" }));
                return;
            }

            using (var db = new QuanLyLinhKienXeMayEntities())
            {
                var xe = db.DongXes.FirstOrDefault(d => d.MaXe == id);
                if (xe == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Dòng xe không tồn tại!" }));
                    return;
                }

                int soLK = xe.LinhKiens.Count();
                if (soLK > 0)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không thể xóa! Có " + soLK + " linh kiện đang gắn với dòng xe này." }));
                    return;
                }

                db.DongXes.Remove(xe);
                db.SaveChanges();

                NhatKyHelper.Ghi(context, "Xóa dòng xe", "DongXe#" + id, xe.HangXe + " " + xe.TenXe);
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Xóa dòng xe thành công!" }));
            }
        }

        private void GetByProduct(HttpContext context)
        {
            int maLinhKien = ParseInt(context.Request.QueryString["maLinhKien"] ?? context.Request.QueryString["id"]);
            if (maLinhKien <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã linh kiện không hợp lệ!" }));
                return;
            }

            var ids = new List<int>();
            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand("SELECT MaXe FROM TuongThichXe WHERE MaLinhKien = @Ma", conn))
            {
                cmd.Parameters.AddWithValue("@Ma", maLinhKien);
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read()) ids.Add(Convert.ToInt32(dr["MaXe"]));
                }
            }

            context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = ids }));
        }

        private void SetProduct(HttpContext context, NguoiDung user)
        {
            int maLinhKien = ParseInt(context.Request.Form["maLinhKien"]);
            string idsRaw = context.Request.Form["maXe"] ?? "";

            if (maLinhKien <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã linh kiện không hợp lệ!" }));
                return;
            }

            var ids = idsRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                            .Select(s => ParseInt(s)).Where(i => i > 0).Distinct().ToList();

            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    using (var del = new SqlCommand("DELETE FROM TuongThichXe WHERE MaLinhKien = @Ma", conn, tx))
                    {
                        del.Parameters.AddWithValue("@Ma", maLinhKien);
                        del.ExecuteNonQuery();
                    }

                    foreach (var maXe in ids)
                    {
                        using (var ins = new SqlCommand("INSERT INTO TuongThichXe (MaLinhKien, MaXe) VALUES (@Ma, @Xe)", conn, tx))
                        {
                            ins.Parameters.AddWithValue("@Ma", maLinhKien);
                            ins.Parameters.AddWithValue("@Xe", maXe);
                            ins.ExecuteNonQuery();
                        }
                    }

                    tx.Commit();
                }
            }

            NhatKyHelper.Ghi(context, "Cập nhật dòng xe tương thích", "LinhKien#" + maLinhKien, "Số dòng xe: " + ids.Count);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Cập nhật dòng xe tương thích thành công!" }));
        }

        private static int ParseInt(string s)
        {
            int v;
            return int.TryParse(s, out v) ? v : 0;
        }

        private static int? ParseNullableInt(string s)
        {
            int v;
            if (int.TryParse(s, out v)) return v;
            return null;
        }

        public bool IsReusable => false;
    }
}
