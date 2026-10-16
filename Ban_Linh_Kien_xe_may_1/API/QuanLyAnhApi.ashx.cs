using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    /// <summary>Quan ly hinh anh san pham (UC06.7): nhieu anh + chon anh chinh.</summary>
    public class QuanLyAnhApi : IHttpHandler, IRequiresSessionState
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
                    case "upload": Upload(context, user); break;
                    case "delete": Delete(context, user); break;
                    case "set_main": SetMain(context, user); break;
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
            int maLinhKien = ParseInt(context.Request.QueryString["maLinhKien"] ?? context.Request.QueryString["id"]);
            if (maLinhKien <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã linh kiện không hợp lệ!" }));
                return;
            }

            var list = new List<object>();
            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand("SELECT MaAnh, DuongDanAnh, LaAnhChinh, ThuTu FROM AnhSanPham WHERE MaLinhKien = @Ma ORDER BY LaAnhChinh DESC, ThuTu ASC, MaAnh ASC", conn))
            {
                cmd.Parameters.AddWithValue("@Ma", maLinhKien);
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        list.Add(new
                        {
                            id = Convert.ToInt32(dr["MaAnh"]),
                            url = dr["DuongDanAnh"].ToString(),
                            main = Convert.ToBoolean(dr["LaAnhChinh"]),
                            order = Convert.ToInt32(dr["ThuTu"])
                        });
                    }
                }
            }

            context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = list }));
        }

        private void Upload(HttpContext context, NguoiDung user)
        {
            int maLinhKien = ParseInt(context.Request.Form["maLinhKien"]);
            if (maLinhKien <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã linh kiện không hợp lệ!" }));
                return;
            }

            if (context.Request.Files.Count == 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Chưa chọn ảnh!" }));
                return;
            }

            HttpPostedFile file = context.Request.Files["fileAnh"];
            if (file == null || file.ContentLength <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "File ảnh rỗng!" }));
                return;
            }

            string fileName = Path.GetFileName(file.FileName);
            string uniqueFileName = DateTime.Now.ToString("yyyyMMdd_HHmmss_") + fileName;
            string folderPath = context.Server.MapPath("~/images/");
            if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);
            string savePath = Path.Combine(folderPath, uniqueFileName);
            file.SaveAs(savePath);
            string duongDan = "images/" + uniqueFileName;

            string connStr = ConnStr();
            int soAnhHienCo = 0;
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var countCmd = new SqlCommand("SELECT COUNT(1) FROM AnhSanPham WHERE MaLinhKien = @Ma", conn))
                {
                    countCmd.Parameters.AddWithValue("@Ma", maLinhKien);
                    soAnhHienCo = Convert.ToInt32(countCmd.ExecuteScalar());
                }

                bool laAnhChinh = (soAnhHienCo == 0);
                using (var ins = new SqlCommand("INSERT INTO AnhSanPham (MaLinhKien, DuongDanAnh, LaAnhChinh, ThuTu) VALUES (@Ma, @Url, @Main, @ThuTu)", conn))
                {
                    ins.Parameters.AddWithValue("@Ma", maLinhKien);
                    ins.Parameters.AddWithValue("@Url", duongDan);
                    ins.Parameters.AddWithValue("@Main", laAnhChinh);
                    ins.Parameters.AddWithValue("@ThuTu", soAnhHienCo);
                    ins.ExecuteNonQuery();
                }

                if (laAnhChinh)
                {
                    using (var upd = new SqlCommand("UPDATE LinhKien SET HinhAnh = @Url WHERE MaLinhKien = @Ma", conn))
                    {
                        upd.Parameters.AddWithValue("@Url", duongDan);
                        upd.Parameters.AddWithValue("@Ma", maLinhKien);
                        upd.ExecuteNonQuery();
                    }
                }
            }

            NhatKyHelper.Ghi(context, "Thêm ảnh sản phẩm", "LinhKien#" + maLinhKien, duongDan);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Tải ảnh lên thành công!" }));
        }

        private void Delete(HttpContext context, NguoiDung user)
        {
            int maAnh = ParseInt(context.Request.QueryString["id"] ?? context.Request.Form["id"]);
            if (maAnh <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã ảnh không hợp lệ!" }));
                return;
            }

            string connStr = ConnStr();
            string duongDan = null;
            int maLinhKien = 0;
            bool laAnhChinh = false;

            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var sel = new SqlCommand("SELECT MaLinhKien, DuongDanAnh, LaAnhChinh FROM AnhSanPham WHERE MaAnh = @Ma", conn))
                {
                    sel.Parameters.AddWithValue("@Ma", maAnh);
                    using (var dr = sel.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            maLinhKien = Convert.ToInt32(dr["MaLinhKien"]);
                            duongDan = dr["DuongDanAnh"].ToString();
                            laAnhChinh = Convert.ToBoolean(dr["LaAnhChinh"]);
                        }
                    }
                }

                if (duongDan == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Ảnh không tồn tại!" }));
                    return;
                }

                using (var del = new SqlCommand("DELETE FROM AnhSanPham WHERE MaAnh = @Ma", conn))
                {
                    del.Parameters.AddWithValue("@Ma", maAnh);
                    del.ExecuteNonQuery();
                }

                // Neu xoa anh chinh -> chon anh con lai lam anh chinh
                if (laAnhChinh)
                {
                    int? anhKeTiep = null;
                    using (var next = new SqlCommand("SELECT TOP 1 MaAnh FROM AnhSanPham WHERE MaLinhKien = @Ma ORDER BY ThuTu ASC, MaAnh ASC", conn))
                    {
                        next.Parameters.AddWithValue("@Ma", maLinhKien);
                        object r = next.ExecuteScalar();
                        if (r != null) anhKeTiep = Convert.ToInt32(r);
                    }

                    if (anhKeTiep.HasValue)
                    {
                        SetMainInternal(conn, anhKeTiep.Value, maLinhKien);
                    }
                }
            }

            // Xoa file vat ly (khong quan trong neu loi)
            try
            {
                if (!string.IsNullOrEmpty(duongDan))
                {
                    string full = context.Server.MapPath("~/" + duongDan.TrimStart('/'));
                    if (File.Exists(full)) File.Delete(full);
                }
            }
            catch { }

            NhatKyHelper.Ghi(context, "Xóa ảnh sản phẩm", "LinhKien#" + maLinhKien, duongDan);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã xóa ảnh!" }));
        }

        private void SetMain(HttpContext context, NguoiDung user)
        {
            int maAnh = ParseInt(context.Request.Form["id"] ?? context.Request.QueryString["id"]);
            if (maAnh <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã ảnh không hợp lệ!" }));
                return;
            }

            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                int maLinhKien = 0;
                using (var sel = new SqlCommand("SELECT MaLinhKien FROM AnhSanPham WHERE MaAnh = @Ma", conn))
                {
                    sel.Parameters.AddWithValue("@Ma", maAnh);
                    object r = sel.ExecuteScalar();
                    if (r == null)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Ảnh không tồn tại!" }));
                        return;
                    }
                    maLinhKien = Convert.ToInt32(r);
                }

                SetMainInternal(conn, maAnh, maLinhKien);
            }

            NhatKyHelper.Ghi(context, "Đặt ảnh chính", "Anh#" + maAnh, null);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã đặt làm ảnh chính!" }));
        }

        private static void SetMainInternal(SqlConnection conn, int maAnh, int maLinhKien)
        {
            using (var reset = new SqlCommand("UPDATE AnhSanPham SET LaAnhChinh = 0 WHERE MaLinhKien = @Ma", conn))
            {
                reset.Parameters.AddWithValue("@Ma", maLinhKien);
                reset.ExecuteNonQuery();
            }

            string url = null;
            using (var set = new SqlCommand("UPDATE AnhSanPham SET LaAnhChinh = 1 WHERE MaAnh = @Ma; SELECT DuongDanAnh FROM AnhSanPham WHERE MaAnh = @Ma", conn))
            {
                set.Parameters.AddWithValue("@Ma", maAnh);
                object r = set.ExecuteScalar();
                if (r != null) url = r.ToString();
            }

            if (!string.IsNullOrEmpty(url))
            {
                using (var upd = new SqlCommand("UPDATE LinhKien SET HinhAnh = @Url WHERE MaLinhKien = @Ma", conn))
                {
                    upd.Parameters.AddWithValue("@Url", url);
                    upd.Parameters.AddWithValue("@Ma", maLinhKien);
                    upd.ExecuteNonQuery();
                }
            }
        }

        private static int ParseInt(string s)
        {
            int v;
            return int.TryParse(s, out v) ? v : 0;
        }

        public bool IsReusable => false;
    }
}
