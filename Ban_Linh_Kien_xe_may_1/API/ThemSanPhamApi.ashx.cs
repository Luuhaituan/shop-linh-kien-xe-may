using System;
using System.IO;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class ThemSanPhamApi : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var user = context.Session["User"] as Ban_Linh_Kien_xe_may_1.Models.NguoiDung;
            if (user == null || !Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsAdmin(user.VaiTro))
            {
                context.Response.StatusCode = (user == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Từ chối truy cập!" }));
                return;
            }

            try
            {
                // 1. Nhận dữ liệu text từ FormData
                string ten = context.Request.Form["ten"];
                decimal giaGoc = Convert.ToDecimal(context.Request.Form["giaGoc"]);
                decimal giaBan = Convert.ToDecimal(context.Request.Form["giaBan"]);
                int tonKho = Convert.ToInt32(context.Request.Form["tonKho"]);
                int maDanhMuc = Convert.ToInt32(context.Request.Form["maDanhMuc"]);
                bool isHot = context.Request.Form["isHot"] == "true";
                bool isSale = context.Request.Form["isSale"] == "true";

                string moTa = context.Request.Form["moTa"];
                string hangXe = context.Request.Form["hangXe"];
                string nhanHieu = context.Request.Form["nhanHieu"];
                int? maDanhMucPhu = ParseNullableInt(context.Request.Form["maDanhMucPhu"]);
                bool trangThai = context.Request.Form["trangThai"] != "false";

                string duongDanAnh = "images/anh_dai_dien.jpg"; // Ảnh mặc định

                // 2. Xử lý File Ảnh tải lên (Nếu có)
                if (context.Request.Files.Count > 0)
                {
                    HttpPostedFile fileAnh = context.Request.Files["fileAnh"];
                    if (fileAnh != null && fileAnh.ContentLength > 0)
                    {
                        string fileName = Path.GetFileName(fileAnh.FileName);
                        string uniqueFileName = DateTime.Now.ToString("yyyyMMdd_HHmmss_") + fileName;
                        string folderPath = context.Server.MapPath("~/images/");
                        if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);
                        string savePath = Path.Combine(folderPath, uniqueFileName);

                        fileAnh.SaveAs(savePath);
                        duongDanAnh = "images/" + uniqueFileName;
                    }
                }

                int maLinhKienMoi = 0;

                // 3. Lưu vào Database
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    var spMoi = new LinhKien
                    {
                        TenLinhKien = ten,
                        GiaNiemYet = giaGoc,
                        GiaBan = giaBan,
                        SoLuongTon = tonKho,
                        MaDanhMuc = maDanhMuc,
                        MaDanhMucPhu = maDanhMucPhu,
                        HangXe = string.IsNullOrEmpty(hangXe) ? null : hangXe,
                        NhanHieu = string.IsNullOrEmpty(nhanHieu) ? null : nhanHieu,
                        MoTa = string.IsNullOrEmpty(moTa) ? null : moTa,
                        HinhAnh = duongDanAnh,
                        TrangThai = trangThai,
                        SanPhamHot = isHot,
                        SanPhamGiamGia = isSale
                    };

                    db.LinhKiens.Add(spMoi);
                    db.SaveChanges();
                    maLinhKienMoi = spMoi.MaLinhKien;
                }

                // 3b. Ghi ảnh vào thư viện ảnh + đặt làm ảnh chính
                LuuAnhVaoThuVien(maLinhKienMoi, duongDanAnh);

                // 3c. Ghi phiếu kho nhập ban đầu
                if (tonKho > 0)
                {
                    GhiPhieuKho(context, user, maLinhKienMoi, "Nhap", tonKho, 0, tonKho, "Tồn kho khởi tạo khi thêm sản phẩm", "");
                }

                // 3d. Gán dòng xe tương thích
                string maXeRaw = context.Request.Form["maXe"];
                if (!string.IsNullOrEmpty(maXeRaw))
                {
                    GanDongXe(maLinhKienMoi, maXeRaw);
                }

                NhatKyHelper.Ghi(context, "Thêm sản phẩm", "LinhKien#" + maLinhKienMoi, ten);
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Thêm sản phẩm thành công!" }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi dữ liệu: " + ex.Message }));
            }
        }

        private static void LuuAnhVaoThuVien(int maLinhKien, string duongDan)
        {
            if (string.IsNullOrEmpty(duongDan)) return;
            try
            {
                string connStr = NhatKyHelper.ChuoiKetNoi();
                using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                using (var cmd = new System.Data.SqlClient.SqlCommand("INSERT INTO AnhSanPham (MaLinhKien, DuongDanAnh, LaAnhChinh, ThuTu) VALUES (@Ma, @Url, 1, 0)", conn))
                {
                    cmd.Parameters.AddWithValue("@Ma", maLinhKien);
                    cmd.Parameters.AddWithValue("@Url", duongDan);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private static void GhiPhieuKho(HttpContext context, NguoiDung user, int maLinhKien, string loai, int sl, int truoc, int sau, string lyDo, string ghiChu)
        {
            try
            {
                string connStr = NhatKyHelper.ChuoiKetNoi();
                using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                using (var cmd = new System.Data.SqlClient.SqlCommand(@"INSERT INTO PhieuKho (MaLinhKien, LoaiPhieu, SoLuong, SoLuongTruoc, SoLuongSau, LyDo, GhiChu, MaNguoiDung)
                                                                         VALUES (@Ma, @Loai, @SL, @Truoc, @Sau, @LyDo, @GhiChu, @ND)", conn))
                {
                    cmd.Parameters.AddWithValue("@Ma", maLinhKien);
                    cmd.Parameters.AddWithValue("@Loai", loai);
                    cmd.Parameters.AddWithValue("@SL", sl);
                    cmd.Parameters.AddWithValue("@Truoc", truoc);
                    cmd.Parameters.AddWithValue("@Sau", sau);
                    cmd.Parameters.AddWithValue("@LyDo", (object)lyDo ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@GhiChu", (object)ghiChu ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ND", user.MaNguoiDung);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private static void GanDongXe(int maLinhKien, string maXeRaw)
        {
            try
            {
                var ids = maXeRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                string connStr = NhatKyHelper.ChuoiKetNoi();
                using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                {
                    conn.Open();
                    foreach (var s in ids)
                    {
                        int maXe;
                        if (!int.TryParse(s, out maXe)) continue;
                        using (var cmd = new System.Data.SqlClient.SqlCommand("INSERT INTO TuongThichXe (MaLinhKien, MaXe) VALUES (@Ma, @Xe)", conn))
                        {
                            cmd.Parameters.AddWithValue("@Ma", maLinhKien);
                            cmd.Parameters.AddWithValue("@Xe", maXe);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch { }
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
