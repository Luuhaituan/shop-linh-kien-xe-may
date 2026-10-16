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
    /// <summary>Xem nhat ky hoat dong cua quan tri vien / nhan vien.</summary>
    public class NhatKyApi : IHttpHandler, IRequiresSessionState
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

            try
            {
                string keyword = (context.Request.QueryString["kw"] ?? "").Trim();
                var list = new List<object>();
                string connStr = NhatKyHelper.ChuoiKetNoi();

                string sql = @"SELECT TOP 500 Id, MaNguoiDung, TenDangNhap, HanhDong, DoiTuong, ChiTiet, DiaChiIP, ThoiGian
                               FROM NhatKyHoatDong " +
                               (string.IsNullOrEmpty(keyword) ? "" : "WHERE HanhDong LIKE @Kw OR TenDangNhap LIKE @Kw OR DoiTuong LIKE @Kw ") +
                               "ORDER BY ThoiGian DESC, Id DESC";

                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(keyword)) cmd.Parameters.AddWithValue("@Kw", "%" + keyword + "%");
                    conn.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            list.Add(new
                            {
                                id = Convert.ToInt32(dr["Id"]),
                                nguoiDung = dr["TenDangNhap"] == DBNull.Value ? "Hệ thống" : dr["TenDangNhap"].ToString(),
                                hanhDong = dr["HanhDong"].ToString(),
                                doiTuong = dr["DoiTuong"] == DBNull.Value ? "" : dr["DoiTuong"].ToString(),
                                chiTiet = dr["ChiTiet"] == DBNull.Value ? "" : dr["ChiTiet"].ToString(),
                                ip = dr["DiaChiIP"] == DBNull.Value ? "" : dr["DiaChiIP"].ToString(),
                                thoiGian = dr["ThoiGian"] == DBNull.Value ? "" : Convert.ToDateTime(dr["ThoiGian"]).ToString("dd/MM/yyyy HH:mm:ss")
                            });
                        }
                    }
                }

                context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = list }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi xử lý: " + ex.Message }));
            }
        }

        public bool IsReusable => false;
    }
}
