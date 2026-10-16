using System;
using System.Web;
using System.Web.SessionState;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class GioHangApi : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.ContentEncoding = System.Text.Encoding.UTF8;

            try
            {
                // 1. KIỂM TRA ĐĂNG NHẬP THEO CHUẨN CỦA BẠN (Session["User"])
                if (context.Session["User"] == null)
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "not_logged_in" }));
                    return;
                }

                // Lấy Object người dùng từ Session và ép kiểu về bảng NguoiDung
                var currentUser = (NguoiDung)context.Session["User"];
                int maNguoiDung = currentUser.MaNguoiDung; // Rút mã người dùng ra để dùng

                string action = context.Request["action"];

                using (QuanLyLinhKienXeMayEntities db = new QuanLyLinhKienXeMayEntities())
                {
                    // 2. TÌM HOẶC TẠO GIỎ HÀNG CHO NGƯỜI DÙNG
                    var gioHang = db.GioHangs.FirstOrDefault(g => g.MaNguoiDung == maNguoiDung);
                    if (gioHang == null)
                    {
                        gioHang = new GioHang { MaNguoiDung = maNguoiDung, NgayCapNhat = DateTime.Now };
                        db.GioHangs.Add(gioHang);
                        db.SaveChanges();
                    }

                    // 3. XỬ LÝ CÁC HÀNH ĐỘNG CỦA GIỎ HÀNG
                    if (action == "get")
                    {
                        // Load dữ liệu giỏ hàng
                        var listCart = db.ChiTietGioHangs.Where(c => c.MaGioHang == gioHang.MaGioHang).Select(c => new
                        {
                            id = c.MaLinhKien,
                            name = c.LinhKien.TenLinhKien,
                            price = c.LinhKien.GiaBan,
                            img = c.LinhKien.HinhAnh,
                            qty = c.SoLuong
                        }).ToList();

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = listCart }));
                    }
                    else if (action == "add")
                    {
                        // 1. Lấy ID sản phẩm
                        int maLinhKien = Convert.ToInt32(context.Request["id"]);

                        // 2. Hứng biến số lượng từ Javascript gửi lên (Mặc định là 1 nếu không truyền)
                        int soLuongThem = 1;
                        if (!string.IsNullOrEmpty(context.Request["qty"]))
                        {
                            int.TryParse(context.Request["qty"], out soLuongThem);
                        }

                        var chiTiet = db.ChiTietGioHangs.FirstOrDefault(c => c.MaGioHang == gioHang.MaGioHang && c.MaLinhKien == maLinhKien);

                        if (chiTiet != null)
                        {
                            // 3. Cộng dồn số lượng khách vừa chọn
                            chiTiet.SoLuong += soLuongThem;
                        }
                        else
                        {
                            // 4. Thêm mới sản phẩm vào giỏ với đúng số lượng khách chọn
                            db.ChiTietGioHangs.Add(new ChiTietGioHang { MaGioHang = gioHang.MaGioHang, MaLinhKien = maLinhKien, SoLuong = soLuongThem });
                        }

                        gioHang.NgayCapNhat = DateTime.Now; // Cập nhật thời gian giỏ hàng
                        db.SaveChanges();
                        context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                    }
                    else if (action == "remove")
                    {
                        // 1. Lấy ID sản phẩm cần xóa
                        int maLinhKien = Convert.ToInt32(context.Request["id"]);

                        // 2. Tìm sản phẩm đó trong giỏ hàng hiện tại
                        var chiTiet = db.ChiTietGioHangs.FirstOrDefault(c => c.MaGioHang == gioHang.MaGioHang && c.MaLinhKien == maLinhKien);

                        // 3. Nếu tìm thấy thì xóa nó khỏi cơ sở dữ liệu
                        if (chiTiet != null)
                        {
                            db.ChiTietGioHangs.Remove(chiTiet);
                            gioHang.NgayCapNhat = DateTime.Now; // Cập nhật lại giờ sửa giỏ hàng
                            db.SaveChanges();
                        }

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                    }
                    else if (action == "update")
                    {
                        int maLinhKien = Convert.ToInt32(context.Request["id"]);
                        int soLuongMoi = Convert.ToInt32(context.Request["qty"]);

                        var chiTiet = db.ChiTietGioHangs.FirstOrDefault(c => c.MaGioHang == gioHang.MaGioHang && c.MaLinhKien == maLinhKien);

                        if (chiTiet != null)
                        {
                            if (soLuongMoi > 0)
                            {
                                chiTiet.SoLuong = soLuongMoi; // Cập nhật số lượng mới
                            }
                            else
                            {
                                db.ChiTietGioHangs.Remove(chiTiet); // Nếu khách giảm số lượng về 0 thì xóa luôn
                            }

                            gioHang.NgayCapNhat = DateTime.Now;
                            db.SaveChanges();
                        }

                        context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = ex.Message }));
            }
        }

        public bool IsReusable => false;
    }
}