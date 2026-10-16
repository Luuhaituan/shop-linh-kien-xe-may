using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.Utils
{
    /// <summary>
    /// Ghi nhat ky hoat dong cua Admin/NhanVien vao bang NhatKyHoatDong.
    /// Moi loi deu duoc bo qua de khong lam gian doan nghiep vu chinh.
    /// </summary>
    public static class NhatKyHelper
    {
        private static string LayChuoiKetNoi()
        {
            try
            {
                var cs = ConfigurationManager.ConnectionStrings["QuanLyLinhKienDB"];
                if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString))
                    return cs.ConnectionString;
            }
            catch { }
            return null;
        }

        public static void Ghi(HttpContext context, string hanhDong, string doiTuong, string chiTiet)
        {
            try
            {
                string connStr = LayChuoiKetNoi();
                if (string.IsNullOrEmpty(connStr)) return;

                var user = context != null ? context.Session["User"] as NguoiDung : null;

                string sql = @"INSERT INTO NhatKyHoatDong (MaNguoiDung, TenDangNhap, HanhDong, DoiTuong, ChiTiet, DiaChiIP)
                               VALUES (@MaNguoiDung, @TenDangNhap, @HanhDong, @DoiTuong, @ChiTiet, @DiaChiIP)";

                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@MaNguoiDung", (object)(user != null ? (int?)user.MaNguoiDung : null) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@TenDangNhap", (object)(user != null ? user.TenDangNhap : null) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@HanhDong", (object)hanhDong ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@DoiTuong", (object)doiTuong ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ChiTiet", (object)chiTiet ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@DiaChiIP", (object)(context != null && context.Request != null ? context.Request.UserHostAddress : null) ?? DBNull.Value);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch
            {
                // Bo qua loi nhat ky
            }
        }

        /// <summary>Lay chuoi ket noi ADO.NET dung chung (bang QuanLyLinhKienDB).</summary>
        public static string ChuoiKetNoi()
        {
            return LayChuoiKetNoi();
        }
    }
}
