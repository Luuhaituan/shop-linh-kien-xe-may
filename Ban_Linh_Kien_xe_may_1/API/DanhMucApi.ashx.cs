using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;
using Ban_Linh_Kien_xe_may_1.Models;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class DanhMucApi : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.ContentEncoding = System.Text.Encoding.UTF8;

            try
            {
                using (QuanLyLinhKienXeMayEntities db = new QuanLyLinhKienXeMayEntities())
                {
                    // Lấy tất cả danh mục từ bảng DanhMuc
                    var listDanhMuc = db.DanhMucs.Select(d => new
                    {
                        id = d.MaDanhMuc,
                        name = d.TenDanhMuc,
                        count = db.LinhKiens.Count(l => l.MaDanhMuc == d.MaDanhMuc)
                    }).ToList();

                    context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = listDanhMuc }));
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