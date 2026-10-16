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
    public class LinhKienApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            try
            {
                var user = context.Session["User"] as NguoiDung;
                bool isAdmin = (user != null && PhanQuyen.IsAdmin(user.VaiTro));
                bool adminMode = isAdmin && (context.Request.QueryString["admin"] == "1");

                using (QuanLyLinhKienXeMayEntities db = new QuanLyLinhKienXeMayEntities())
                {
                    // 1. Từ điển danh mục
                    var tuDienDanhMuc = db.DanhMucs.ToDictionary(d => d.MaDanhMuc, d => d.TenDanhMuc);

                    // 2. Đánh giá đã bị ẩn (Admin ẩn)
                    var danhGiaAn = LayDanhGiaAn();

                    // 3. Toàn bộ đánh giá để tự tính điểm (loại trừ đánh giá bị ẩn)
                    var tatCaDanhGia = db.DanhGias
                        .Select(d => new { d.MaDanhGia, d.MaLinhKien, d.SoSao })
                        .ToList()
                        .Where(d => !danhGiaAn.Contains(d.MaDanhGia))
                        .ToList();

                    // 4. Dòng xe tương thích: MaLinhKien -> list tên dòng xe
                    var dongXeTheoSP = LayDongXeTheoSanPham();

                    // 5. Thư viện ảnh: MaLinhKien -> list url
                    var anhTheoSP = LayAnhTheoSanPham();

                    // 6. Sản phẩm
                    IQueryable<LinhKien> q = db.LinhKiens;
                    if (!adminMode) q = q.Where(x => x.TrangThai == true);

                    var listDB = q.ToList();

                    var listSanPham = listDB.Select(x =>
                    {
                        string tenPhu = "";
                        int maPhu = x.MaDanhMucPhu ?? 0;
                        if (maPhu > 0 && tuDienDanhMuc.ContainsKey(maPhu)) tenPhu = tuDienDanhMuc[maPhu];

                        string tenChinh = "";
                        if (tuDienDanhMuc.ContainsKey(x.MaDanhMuc)) tenChinh = tuDienDanhMuc[x.MaDanhMuc];

                        var ratings = tatCaDanhGia.Where(d => d.MaLinhKien == x.MaLinhKien).ToList();
                        int soDanhGia = ratings.Count;
                        double diemTB = soDanhGia > 0 ? ratings.Average(d => (double)(d.SoSao ?? 0)) : 0;

                        List<string> imgs;
                        if (!anhTheoSP.TryGetValue(x.MaLinhKien, out imgs)) imgs = new List<string>();
                        if (imgs.Count == 0 && !string.IsNullOrEmpty(x.HinhAnh)) imgs.Add(x.HinhAnh);

                        List<string> xe;
                        if (!dongXeTheoSP.TryGetValue(x.MaLinhKien, out xe)) xe = new List<string>();

                        return new
                        {
                            id = x.MaLinhKien,
                            name = x.TenLinhKien,
                            brand = x.HangXe,
                            category = (tenChinh + " " + tenPhu).Trim(),
                            tenDanhMuc = tenChinh,
                            maDanhMuc = x.MaDanhMuc,
                            maDanhMucPhu = x.MaDanhMucPhu,

                            price = x.GiaBan,
                            oldPrice = x.GiaNiemYet,
                            badge = x.NhanHieu,
                            moTa = x.MoTa,
                            hangXe = x.HangXe,

                            rating = diemTB,
                            reviews = soDanhGia,

                            img = x.HinhAnh,
                            images = imgs,
                            stock = x.SoLuongTon,
                            isHidden = !x.TrangThai,
                            trangThai = x.TrangThai,

                            giaNiemYet = x.GiaNiemYet,
                            isHot = x.SanPhamHot,
                            isSale = x.SanPhamGiamGia,
                            dongXe = xe,

                            SoDanhGia = soDanhGia,
                            DiemTrungBinh = diemTB
                        };
                    }).ToList();

                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = listSanPham }));
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = ex.Message }));
            }
        }

        private static HashSet<int> LayDanhGiaAn()
        {
            var set = new HashSet<int>();
            try
            {
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
            }
            catch { }
            return set;
        }

        private static Dictionary<int, List<string>> LayDongXeTheoSanPham()
        {
            var dict = new Dictionary<int, List<string>>();
            try
            {
                string connStr = NhatKyHelper.ChuoiKetNoi();
                string sql = @"SELECT tt.MaLinhKien, dx.HangXe, dx.TenXe, dx.DoiXe
                               FROM TuongThichXe tt
                               JOIN DongXe dx ON tt.MaXe = dx.MaXe";
                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int maLK = Convert.ToInt32(dr["MaLinhKien"]);
                            string ten = dr["HangXe"] + " " + dr["TenXe"] + (dr["DoiXe"] == DBNull.Value ? "" : " " + dr["DoiXe"]);
                            if (!dict.ContainsKey(maLK)) dict[maLK] = new List<string>();
                            dict[maLK].Add(ten.Trim());
                        }
                    }
                }
            }
            catch { }
            return dict;
        }

        private static Dictionary<int, List<string>> LayAnhTheoSanPham()
        {
            var dict = new Dictionary<int, List<string>>();
            try
            {
                string connStr = NhatKyHelper.ChuoiKetNoi();
                string sql = "SELECT MaLinhKien, DuongDanAnh FROM AnhSanPham ORDER BY LaAnhChinh DESC, ThuTu ASC, MaAnh ASC";
                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int maLK = Convert.ToInt32(dr["MaLinhKien"]);
                            if (!dict.ContainsKey(maLK)) dict[maLK] = new List<string>();
                            dict[maLK].Add(dr["DuongDanAnh"].ToString());
                        }
                    }
                }
            }
            catch { }
            return dict;
        }

        public bool IsReusable => false;
    }
}
