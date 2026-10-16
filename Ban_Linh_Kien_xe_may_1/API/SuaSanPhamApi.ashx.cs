using System;
using System.IO;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class SuaSanPhamApi : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            // Bảo mật: Chặn người lạ
            var user = context.Session["User"] as Ban_Linh_Kien_xe_may_1.Models.NguoiDung;
            if (user == null || !Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsAdmin(user.VaiTro))
            {
                context.Response.StatusCode = (user == null) ? 401 : 403;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Từ chối truy cập!" }));
                return;
            }

            try
            {
                int id = Convert.ToInt32(context.Request["id"]);
                string tenMoi = context.Request["ten"];

                string strGiaGoc = context.Request["giaGoc"];
                string strGiaBan = context.Request["giaBan"];

                decimal giaBanMoi = string.IsNullOrEmpty(strGiaBan) ? 0 : Convert.ToDecimal(strGiaBan);
                decimal giaGocMoi = string.IsNullOrEmpty(strGiaGoc) ? giaBanMoi : Convert.ToDecimal(strGiaGoc);

                int tonKhoMoi = 0;
                int.TryParse(context.Request["tonKho"], out tonKhoMoi);

                bool isHotMoi = context.Request["isHot"] == "true";
                bool isSaleMoi = context.Request["isSale"] == "true";

                string moTa = context.Request["moTa"];
                string hangXe = context.Request["hangXe"];
                string nhanHieu = context.Request["nhanHieu"];
                int? maDanhMucPhu = ParseNullableInt(context.Request["maDanhMucPhu"]);
                int? maDanhMuc = ParseNullableInt(context.Request["maDanhMuc"]);

                int tonKhoTruoc = 0;

                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    var sp = db.LinhKiens.FirstOrDefault(x => x.MaLinhKien == id);
                    if (sp == null)
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Không tìm thấy sản phẩm!" }));
                        return;
                    }

                    tonKhoTruoc = sp.SoLuongTon ?? 0;

                    sp.TenLinhKien = tenMoi;
                    sp.GiaBan = giaBanMoi;
                    sp.GiaNiemYet = giaGocMoi;
                    sp.SoLuongTon = tonKhoMoi;
                    sp.SanPhamHot = isHotMoi;
                    sp.SanPhamGiamGia = isSaleMoi;
                    sp.MoTa = string.IsNullOrEmpty(moTa) ? null : moTa;
                    sp.HangXe = string.IsNullOrEmpty(hangXe) ? null : hangXe;
                    sp.NhanHieu = string.IsNullOrEmpty(nhanHieu) ? null : nhanHieu;

                    if (context.Request.Form["maDanhMucPhu"] != null) sp.MaDanhMucPhu = maDanhMucPhu;
                    if (maDanhMuc.HasValue && maDanhMuc.Value > 0) sp.MaDanhMuc = maDanhMuc.Value;

                    // Trạng thái ẩn/hiện chỉ đổi khi form có gửi
                    string ttRaw = context.Request.Form["trangThai"];
                    if (ttRaw != null) sp.TrangThai = (ttRaw != "false");

                    // Cập nhật ảnh chính nếu có upload ảnh mới
                    if (context.Request.Files.Count > 0)
                    {
                        HttpPostedFile fileAnh = context.Request.Files["fileAnh"];
                        if (fileAnh != null && fileAnh.ContentLength > 0)
                        {
                            string fileName = Path.GetFileName(fileAnh.FileName);
                            string uniqueFileName = DateTime.Now.ToString("yyyyMMdd_HHmmss_") + fileName;
                            string folderPath = context.Server.MapPath("~/images/");
                            if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);
                            fileAnh.SaveAs(Path.Combine(folderPath, uniqueFileName));
                            string duongDan = "images/" + uniqueFileName;
                            sp.HinhAnh = duongDan;
                            LuuAnhVaoThuVien(id, duongDan);
                        }
                    }

                    db.SaveChanges();
                }

                // Ghi phiếu kho nếu tồn kho thay đổi
                if (tonKhoMoi != tonKhoTruoc)
                {
                    int chenhLech = tonKhoMoi - tonKhoTruoc;
                    GhiPhieuKho(context, user, id, chenhLech > 0 ? "Nhap" : "Xuat", Math.Abs(chenhLech), tonKhoTruoc, tonKhoMoi,
                                "Cập nhật tồn kho khi sửa sản phẩm", "");
                }

                // Đồng bộ dòng xe tương thích nếu có cờ syncXe
                if (context.Request.Form["syncXe"] == "1")
                {
                    DongBoDongXe(id, context.Request.Form["maXe"] ?? "");
                }

                NhatKyHelper.Ghi(context, "Sửa sản phẩm", "LinhKien#" + id, tenMoi);
                context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Cập nhật thành công!" }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Lỗi nhập liệu: " + ex.Message }));
            }
        }

        private static void LuuAnhVaoThuVien(int maLinhKien, string duongDan)
        {
            try
            {
                string connStr = NhatKyHelper.ChuoiKetNoi();
                using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                {
                    conn.Open();
                    using (var reset = new System.Data.SqlClient.SqlCommand("UPDATE AnhSanPham SET LaAnhChinh = 0 WHERE MaLinhKien = @Ma", conn))
                    {
                        reset.Parameters.AddWithValue("@Ma", maLinhKien);
                        reset.ExecuteNonQuery();
                    }
                    using (var cmd = new System.Data.SqlClient.SqlCommand("INSERT INTO AnhSanPham (MaLinhKien, DuongDanAnh, LaAnhChinh, ThuTu) VALUES (@Ma, @Url, 1, 0)", conn))
                    {
                        cmd.Parameters.AddWithValue("@Ma", maLinhKien);
                        cmd.Parameters.AddWithValue("@Url", duongDan);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
        }

        private static void DongBoDongXe(int maLinhKien, string maXeRaw)
        {
            try
            {
                string connStr = NhatKyHelper.ChuoiKetNoi();
                using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                {
                    conn.Open();
                    using (var del = new System.Data.SqlClient.SqlCommand("DELETE FROM TuongThichXe WHERE MaLinhKien = @Ma", conn))
                    {
                        del.Parameters.AddWithValue("@Ma", maLinhKien);
                        del.ExecuteNonQuery();
                    }
                    foreach (var s in maXeRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
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

        private static int? ParseNullableInt(string s)
        {
            int v;
            if (int.TryParse(s, out v)) return v;
            return null;
        }

        public bool IsReusable => false;
    }
}
