using System;
using System.Web;
using System.Web.SessionState;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models; // Sửa lại đúng namespace Models của bạn

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class DanhGiaApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            string action = context.Request["action"];

            try
            {
                using (var db = new QuanLyLinhKienXeMayEntities())
                {
                    // 1. TẢI DANH SÁCH ĐÁNH GIÁ
                    if (action == "get")
                    {
                        int maLinhKien = int.Parse(context.Request["id"]);

                        // Danh sách đánh giá bị Admin ẩn
                        var danhGiaAn = LayDanhGiaAn();

                        // Bước 1: Kéo dữ liệu thô từ SQL lên RAM trước (Chưa vội format ngày tháng)
                        var danhGiasRaw = (from d in db.DanhGias
                                           join u in db.NguoiDungs on d.MaNguoiDung equals u.MaNguoiDung
                                           where d.MaLinhKien == maLinhKien
                                           orderby d.NgayDanhGia descending
                                           select new
                                           {
                                               MaDanhGia = d.MaDanhGia,
                                               HoTen = u.HoTen,
                                               SoSao = d.SoSao,
                                               NoiDung = d.NoiDung,
                                               NgayDanhGiaRaw = d.NgayDanhGia // Giữ nguyên kiểu DateTime gốc
                                           }).ToList();

                        // Bước 2: Dùng C# trên RAM để format ngày tháng cho đẹp rồi gửi ra Web
                        var danhGias = danhGiasRaw
                            .Where(d => !danhGiaAn.Contains(d.MaDanhGia))
                            .Select(d => new
                            {
                                HoTen = d.HoTen,
                                SoSao = d.SoSao,
                                NoiDung = d.NoiDung,
                                NgayTao = d.NgayDanhGiaRaw.HasValue ? d.NgayDanhGiaRaw.Value.ToString("dd/MM/yyyy HH:mm") : ""
                            }).ToList();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = danhGias }));
                    }

                    // 2. GỬI ĐÁNH GIÁ MỚI
                    else if (action == "add")
                    {
                        if (context.Session["User"] == null)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn cần đăng nhập để đánh giá!" }));
                            return;
                        }

                        NguoiDung user = (NguoiDung)context.Session["User"];
                        int maLinhKien = int.Parse(context.Request.Form["maLinhKien"]);
                        int soSao = int.Parse(context.Request.Form["soSao"]);
                        string noiDung = context.Request.Form["noiDung"];

                        // KIỂM TRA ĐIỀU KIỆN: Đã mua hàng mới được đánh giá
                        bool daMuaHang = db.ChiTietDonHangs.Any(ct =>
                                ct.MaLinhKien == maLinhKien &&
                                ct.DonHang.MaNguoiDung == user.MaNguoiDung);

                        if (!daMuaHang)
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Bạn phải mua sản phẩm này mới được đánh giá!" }));
                            return;
                        }

                        // Lưu xuống Database
                        DanhGia dgMoi = new DanhGia
                        {
                            MaLinhKien = maLinhKien,
                            MaNguoiDung = user.MaNguoiDung,
                            SoSao = soSao,
                            NoiDung = noiDung,
                            NgayDanhGia = DateTime.Now // Dùng đúng tên cột của bạn
                        };

                        db.DanhGias.Add(dgMoi);
                        db.SaveChanges();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = ex.Message }));
            }
        }

        private static System.Collections.Generic.HashSet<int> LayDanhGiaAn()
        {
            var set = new System.Collections.Generic.HashSet<int>();
            try
            {
                string connStr = Ban_Linh_Kien_xe_may_1.Utils.NhatKyHelper.ChuoiKetNoi();
                using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT MaDanhGia FROM DanhGiaAn", conn))
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

        public bool IsReusable => false;
    }
}