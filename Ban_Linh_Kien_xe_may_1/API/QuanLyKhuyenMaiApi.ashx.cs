using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    /// <summary>Quan ly ma giam gia / khuyen mai cua Admin.</summary>
    public class QuanLyKhuyenMaiApi : IHttpHandler, IRequiresSessionState
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
                    case "toggle": Toggle(context, user); break;
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
            string connStr = ConnStr();
            string sql = @"SELECT MaGiamGia, MaCode, TenKhuyenMai, LoaiGiam, GiaTri, GiamToiDa, DonHangToiThieu,
                                  SoLuong, DaDung, NgayBatDau, NgayKetThuc, TrangThai, NgayTao
                           FROM MaGiamGia ORDER BY NgayTao DESC";
            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        list.Add(new
                        {
                            id = Convert.ToInt32(dr["MaGiamGia"]),
                            code = dr["MaCode"].ToString(),
                            name = dr["TenKhuyenMai"].ToString(),
                            loaiGiam = dr["LoaiGiam"].ToString(),
                            giaTri = dr["GiaTri"] == DBNull.Value ? 0m : Convert.ToDecimal(dr["GiaTri"]),
                            giamToiDa = dr["GiamToiDa"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(dr["GiamToiDa"]),
                            donHangToiThieu = dr["DonHangToiThieu"] == DBNull.Value ? 0m : Convert.ToDecimal(dr["DonHangToiThieu"]),
                            soLuong = dr["SoLuong"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["SoLuong"]),
                            daDung = Convert.ToInt32(dr["DaDung"]),
                            ngayBatDau = dr["NgayBatDau"] == DBNull.Value ? "" : Convert.ToDateTime(dr["NgayBatDau"]).ToString("yyyy-MM-dd"),
                            ngayKetThuc = dr["NgayKetThuc"] == DBNull.Value ? "" : Convert.ToDateTime(dr["NgayKetThuc"]).ToString("yyyy-MM-dd"),
                            trangThai = Convert.ToBoolean(dr["TrangThai"]),
                            ngayTao = dr["NgayTao"] == DBNull.Value ? "" : Convert.ToDateTime(dr["NgayTao"]).ToString("dd/MM/yyyy HH:mm")
                        });
                    }
                }
            }

            context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = list }));
        }

        private void Add(HttpContext context, NguoiDung user)
        {
            var f = context.Request.Form;
            string code = (f["code"] ?? "").Trim().ToUpper();
            string name = (f["name"] ?? "").Trim();
            string loaiGiam = (f["loaiGiam"] ?? "PhanTram").Trim();

            if (string.IsNullOrEmpty(code) || string.IsNullOrEmpty(name))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Vui lòng nhập Mã và Tên khuyến mãi!" }));
                return;
            }

            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var check = new SqlCommand("SELECT COUNT(1) FROM MaGiamGia WHERE MaCode = @Code", conn))
                {
                    check.Parameters.AddWithValue("@Code", code);
                    if (Convert.ToInt32(check.ExecuteScalar()) > 0)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã khuyến mãi đã tồn tại!" }));
                        return;
                    }
                }

                string sql = @"INSERT INTO MaGiamGia (MaCode, TenKhuyenMai, LoaiGiam, GiaTri, GiamToiDa, DonHangToiThieu, SoLuong, NgayBatDau, NgayKetThuc, TrangThai)
                               VALUES (@Code, @Name, @Loai, @GiaTri, @Max, @Min, @SL, @BD, @KT, @TT)";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    Gans(cmd, code, name, loaiGiam, f);
                    cmd.ExecuteNonQuery();
                }
            }

            NhatKyHelper.Ghi(context, "Thêm khuyến mãi", "MaGiamGia:" + code, name);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Thêm mã khuyến mãi thành công!" }));
        }

        private void Update(HttpContext context, NguoiDung user)
        {
            var f = context.Request.Form;
            int id = ParseInt(f["id"]);
            string code = (f["code"] ?? "").Trim().ToUpper();
            string name = (f["name"] ?? "").Trim();
            string loaiGiam = (f["loaiGiam"] ?? "PhanTram").Trim();

            if (id <= 0 || string.IsNullOrEmpty(code) || string.IsNullOrEmpty(name))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Thông tin chưa hợp lệ!" }));
                return;
            }

            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var check = new SqlCommand("SELECT COUNT(1) FROM MaGiamGia WHERE MaCode = @Code AND MaGiamGia <> @Id", conn))
                {
                    check.Parameters.AddWithValue("@Code", code);
                    check.Parameters.AddWithValue("@Id", id);
                    if (Convert.ToInt32(check.ExecuteScalar()) > 0)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã khuyến mãi đã trùng với mã khác!" }));
                        return;
                    }
                }

                string sql = @"UPDATE MaGiamGia SET MaCode=@Code, TenKhuyenMai=@Name, LoaiGiam=@Loai, GiaTri=@GiaTri,
                                      GiamToiDa=@Max, DonHangToiThieu=@Min, SoLuong=@SL, NgayBatDau=@BD, NgayKetThuc=@KT, TrangThai=@TT
                               WHERE MaGiamGia=@Id";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    Gans(cmd, code, name, loaiGiam, f);
                    cmd.Parameters.AddWithValue("@Id", id);
                    cmd.ExecuteNonQuery();
                }
            }

            NhatKyHelper.Ghi(context, "Sửa khuyến mãi", "MaGiamGia#" + id, code + " - " + name);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Cập nhật mã khuyến mãi thành công!" }));
        }

        private void Delete(HttpContext context, NguoiDung user)
        {
            int id = ParseInt(context.Request.QueryString["id"] ?? context.Request.Form["id"]);
            if (id <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã không hợp lệ!" }));
                return;
            }

            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("DELETE FROM MaGiamGia WHERE MaGiamGia = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", id);
                    cmd.ExecuteNonQuery();
                }
            }

            NhatKyHelper.Ghi(context, "Xóa khuyến mãi", "MaGiamGia#" + id, null);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Xóa mã khuyến mãi thành công!" }));
        }

        private void Toggle(HttpContext context, NguoiDung user)
        {
            int id = ParseInt(context.Request.Form["id"]);
            if (id <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Mã không hợp lệ!" }));
                return;
            }

            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE MaGiamGia SET TrangThai = CASE WHEN TrangThai = 1 THEN 0 ELSE 1 END WHERE MaGiamGia = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", id);
                    cmd.ExecuteNonQuery();
                }
            }

            NhatKyHelper.Ghi(context, "Đổi trạng thái khuyến mãi", "MaGiamGia#" + id, null);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Đã đổi trạng thái khuyến mãi!" }));
        }

        private static void Gans(SqlCommand cmd, string code, string name, string loaiGiam, System.Collections.Specialized.NameValueCollection f)
        {
            cmd.Parameters.AddWithValue("@Code", code);
            cmd.Parameters.AddWithValue("@Name", name);
            cmd.Parameters.AddWithValue("@Loai", loaiGiam);
            cmd.Parameters.AddWithValue("@GiaTri", ParseDecimal(f["giaTri"]));
            cmd.Parameters.AddWithValue("@Max", (object)ParseNullableDecimal(f["giamToiDa"]) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Min", ParseDecimal(f["donHangToiThieu"]));
            cmd.Parameters.AddWithValue("@SL", (object)ParseNullableInt(f["soLuong"]) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@BD", (object)ParseDate(f["ngayBatDau"]) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@KT", (object)ParseDate(f["ngayKetThuc"]) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@TT", (f["trangThai"] == "false") ? false : true);
        }

        private static int ParseInt(string s) { int v; return int.TryParse(s, out v) ? v : 0; }
        private static int? ParseNullableInt(string s) { int v; return int.TryParse(s, out v) ? v : (int?)null; }
        private static decimal ParseDecimal(string s) { decimal v; return decimal.TryParse(s, out v) ? v : 0m; }
        private static decimal? ParseNullableDecimal(string s) { decimal v; return decimal.TryParse(s, out v) ? v : (decimal?)null; }
        private static DateTime? ParseDate(string s) { DateTime v; return DateTime.TryParse(s, out v) ? v : (DateTime?)null; }

        public bool IsReusable => false;
    }
}
