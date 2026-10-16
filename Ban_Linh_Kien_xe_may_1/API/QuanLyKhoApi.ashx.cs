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
    /// <summary>Quan ly ton kho (UC06.8): xem ton, canh bao sap het, nhap/xuat/dieu chinh, lich su kho.</summary>
    public class QuanLyKhoApi : IHttpHandler, IRequiresSessionState
    {
        private static string ConnStr()
        {
            return NhatKyHelper.ChuoiKetNoi();
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var user = context.Session["User"] as NguoiDung;
            if (user == null || !PhanQuyen.CoQuyen(user.VaiTro, "kho"))
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
                    case "history": History(context); break;
                    case "adjust": Adjust(context, user); break;
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
            string sql = @"SELECT lk.MaLinhKien, lk.TenLinhKien, lk.SoLuongTon, lk.GiaBan,
                                  ISNULL(dm.TenDanhMuc, N'') AS TenDanhMuc,
                                  ISNULL(lk.HinhAnh, '') AS HinhAnh
                           FROM LinhKien lk
                           LEFT JOIN DanhMuc dm ON lk.MaDanhMuc = dm.MaDanhMuc
                           ORDER BY lk.SoLuongTon ASC, lk.MaLinhKien ASC";
            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        int ton = dr["SoLuongTon"] == DBNull.Value ? 0 : Convert.ToInt32(dr["SoLuongTon"]);
                        list.Add(new
                        {
                            id = Convert.ToInt32(dr["MaLinhKien"]),
                            name = dr["TenLinhKien"].ToString(),
                            stock = ton,
                            price = dr["GiaBan"] == DBNull.Value ? 0m : Convert.ToDecimal(dr["GiaBan"]),
                            category = dr["TenDanhMuc"].ToString(),
                            img = dr["HinhAnh"].ToString()
                        });
                    }
                }
            }

            context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = list }));
        }

        private void History(HttpContext context)
        {
            int maLinhKien = ParseInt(context.Request.QueryString["maLinhKien"]);
            var list = new List<object>();
            string connStr = ConnStr();

            string sql = @"SELECT pk.MaPhieu, pk.MaLinhKien, lk.TenLinhKien, pk.LoaiPhieu, pk.SoLuong,
                                  pk.SoLuongTruoc, pk.SoLuongSau, pk.LyDo, pk.GhiChu, pk.ThoiGian,
                                  ISNULL(nd.HoTen, N'Hệ thống') AS NguoiThucHien
                           FROM PhieuKho pk
                           LEFT JOIN LinhKien lk ON pk.MaLinhKien = lk.MaLinhKien
                           LEFT JOIN NguoiDung nd ON pk.MaNguoiDung = nd.MaNguoiDung "
                           + (maLinhKien > 0 ? "WHERE pk.MaLinhKien = @Ma " : "")
                           + "ORDER BY pk.ThoiGian DESC, pk.MaPhieu DESC";
            if (maLinhKien <= 0) sql = sql.Replace("@Ma", "0");

            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (maLinhKien > 0) cmd.Parameters.AddWithValue("@Ma", maLinhKien);
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        list.Add(new
                        {
                            id = Convert.ToInt32(dr["MaPhieu"]),
                            maLinhKien = Convert.ToInt32(dr["MaLinhKien"]),
                            sanPham = dr["TenLinhKien"] == DBNull.Value ? "" : dr["TenLinhKien"].ToString(),
                            loaiPhieu = dr["LoaiPhieu"].ToString(),
                            soLuong = Convert.ToInt32(dr["SoLuong"]),
                            truoc = Convert.ToInt32(dr["SoLuongTruoc"]),
                            sau = Convert.ToInt32(dr["SoLuongSau"]),
                            lyDo = dr["LyDo"] == DBNull.Value ? "" : dr["LyDo"].ToString(),
                            ghiChu = dr["GhiChu"] == DBNull.Value ? "" : dr["GhiChu"].ToString(),
                            thoiGian = dr["ThoiGian"] == DBNull.Value ? "" : Convert.ToDateTime(dr["ThoiGian"]).ToString("dd/MM/yyyy HH:mm"),
                            nguoiThucHien = dr["NguoiThucHien"].ToString()
                        });
                    }
                }
            }

            context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = list }));
        }

        private void Adjust(HttpContext context, NguoiDung user)
        {
            var f = context.Request.Form;
            int maLinhKien = ParseInt(f["maLinhKien"]);
            string loaiPhieu = (f["loaiPhieu"] ?? "Nhap").Trim();
            int soLuong = ParseInt(f["soLuong"]);
            string lyDo = (f["lyDo"] ?? "").Trim();
            string ghiChu = (f["ghiChu"] ?? "").Trim();

            if (maLinhKien <= 0 || soLuong <= 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Sản phẩm hoặc số lượng chưa hợp lệ!" }));
                return;
            }
            if (loaiPhieu != "Nhap" && loaiPhieu != "Xuat" && loaiPhieu != "DieuChinh")
            {
                loaiPhieu = "Nhap";
            }

            string connStr = ConnStr();
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                int tonTruoc = 0;
                using (var sel = new SqlCommand("SELECT SoLuongTon FROM LinhKien WHERE MaLinhKien = @Ma", conn))
                {
                    sel.Parameters.AddWithValue("@Ma", maLinhKien);
                    object r = sel.ExecuteScalar();
                    if (r == null || r == DBNull.Value)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Sản phẩm không tồn tại!" }));
                        return;
                    }
                    tonTruoc = Convert.ToInt32(r);
                }

                int tonSau;
                if (loaiPhieu == "Nhap") tonSau = tonTruoc + soLuong;
                else if (loaiPhieu == "Xuat") tonSau = tonTruoc - soLuong;
                else tonSau = soLuong; // DieuChinh: dat dung so luong nhap vao

                if (tonSau < 0)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Số lượng xuất vượt quá tồn kho hiện tại (" + tonTruoc + ")!" }));
                    return;
                }

                using (var tx = conn.BeginTransaction())
                {
                    using (var upd = new SqlCommand("UPDATE LinhKien SET SoLuongTon = @Sau WHERE MaLinhKien = @Ma", conn, tx))
                    {
                        upd.Parameters.AddWithValue("@Sau", tonSau);
                        upd.Parameters.AddWithValue("@Ma", maLinhKien);
                        upd.ExecuteNonQuery();
                    }

                    using (var ins = new SqlCommand(@"INSERT INTO PhieuKho (MaLinhKien, LoaiPhieu, SoLuong, SoLuongTruoc, SoLuongSau, LyDo, GhiChu, MaNguoiDung)
                                                      VALUES (@Ma, @Loai, @SL, @Truoc, @Sau, @LyDo, @GhiChu, @ND)", conn, tx))
                    {
                        ins.Parameters.AddWithValue("@Ma", maLinhKien);
                        ins.Parameters.AddWithValue("@Loai", loaiPhieu);
                        ins.Parameters.AddWithValue("@SL", soLuong);
                        ins.Parameters.AddWithValue("@Truoc", tonTruoc);
                        ins.Parameters.AddWithValue("@Sau", tonSau);
                        ins.Parameters.AddWithValue("@LyDo", (object)lyDo ?? DBNull.Value);
                        ins.Parameters.AddWithValue("@GhiChu", (object)ghiChu ?? DBNull.Value);
                        ins.Parameters.AddWithValue("@ND", user.MaNguoiDung);
                        ins.ExecuteNonQuery();
                    }

                    tx.Commit();
                }
            }

            NhatKyHelper.Ghi(context, "Điều chỉnh kho", "LinhKien#" + maLinhKien, loaiPhieu + " " + soLuong);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Cập nhật kho thành công!" }));
        }

        private static int ParseInt(string s) { int v; return int.TryParse(s, out v) ? v : 0; }

        public bool IsReusable => false;
    }
}
