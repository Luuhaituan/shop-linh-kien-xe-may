using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace Ban_Linh_Kien_xe_may_1.API
{
    public class ChatApi : IHttpHandler, IRequiresSessionState
    {
        /*private string GetConnectionString()
        {
            try
            {
                if (ConfigurationManager.ConnectionStrings["QuanLyLinhKienDB"] != null &&
                    !string.IsNullOrEmpty(ConfigurationManager.ConnectionStrings["QuanLyLinhKienDB"].ConnectionString))
                {
                    return ConfigurationManager.ConnectionStrings["QuanLyLinhKienDB"].ConnectionString;
                }
            }
            catch { }
            return @"Data Source=.\SQLEXPRESS;Initial Catalog=BanLinhKienXeMay;Integrated Security=True";
        }*/

        private string GetConnectionString()
        {
            var conn = ConfigurationManager.ConnectionStrings["QuanLyLinhKienDB"];
            if (conn != null && !string.IsNullOrEmpty(conn.ConnectionString))
            {
                return conn.ConnectionString;
            }

            throw new Exception("Không tìm thấy chuỗi kết nối 'QuanLyLinhKienDB' trong file Web.config.");
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";
            context.Response.AppendHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            JavaScriptSerializer js = new JavaScriptSerializer();

            try
            {
                // Kiểm tra Session đăng nhập
                dynamic user = context.Session["User"];
                if (user == null)
                {
                    context.Response.StatusCode = 401;
                    context.Response.Write(js.Serialize(new { success = false, message = "not_logged_in" }));
                    return;
                }

                int userId = 0;
                string vaiTro = "KhachHang";

                try
                {
                    var propMaND = user.GetType().GetProperty("MaNguoiDung");
                    if (propMaND != null)
                    {
                        object val = propMaND.GetValue(user, null);
                        if (val != null) userId = Convert.ToInt32(val);
                    }

                    var propVaiTro = user.GetType().GetProperty("VaiTro");
                    if (propVaiTro != null)
                    {
                        object val = propVaiTro.GetValue(user, null);
                        if (val != null) vaiTro = val.ToString();
                    }
                }
                catch { }

                string action = context.Request.QueryString["action"] ?? "";
                string connStr = GetConnectionString();

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    if (action == "get_or_create_session")
                    {
                        int maPhien = GetOrCreateSession(conn, userId);
                        context.Response.Write(js.Serialize(new { success = true, maPhienChat = maPhien }));
                    }
                    else if (action == "get_messages")
                    {
                        int maPhien = 0;
                        if (int.TryParse(context.Request.QueryString["maPhienChat"], out maPhien))
                        {
                            if (!CanAccessSession(conn, maPhien, userId, vaiTro))
                            {
                                context.Response.StatusCode = 403;
                                context.Response.Write(js.Serialize(new { success = false, message = "forbidden" }));
                                return;
                            }
                            // Đếm trước khi đánh dấu đã đọc, để giao diện còn hiện được con số vừa mới đọc.
                            int chuaDoc = CountChuaDoc(conn, maPhien, vaiTro);
                            var listMsgs = GetMessages(conn, maPhien);
                            MarkDaDoc(conn, maPhien, vaiTro);
                            context.Response.Write(js.Serialize(new { success = true, data = listMsgs, currentUserId = userId, soTinChuaDoc = chuaDoc }));
                        }
                        else
                        {
                            context.Response.Write(js.Serialize(new { success = false, message = "Invalid maPhienChat" }));
                        }
                    }
                    else if (action == "send_message")
                    {
                        int maPhien = 0;
                        string noiDung = context.Request.Form["noiDung"] ?? "";

                        if (int.TryParse(context.Request.Form["maPhienChat"], out maPhien) && !string.IsNullOrWhiteSpace(noiDung))
                        {
                            if (!CanAccessSession(conn, maPhien, userId, vaiTro))
                            {
                                context.Response.StatusCode = 403;
                                context.Response.Write(js.Serialize(new { success = false, message = "forbidden" }));
                                return;
                            }
                            SendMessage(conn, maPhien, userId, noiDung, IsStaff(vaiTro));
                            context.Response.Write(js.Serialize(new { success = true }));
                        }
                        else
                        {
                            context.Response.Write(js.Serialize(new { success = false, message = "Nội dung trống" }));
                        }
                    }
                    else if (action == "get_unread")
                    {
                        // Chỉ đọc số lượng, KHÔNG đánh dấu đã đọc — dùng cho badge khi hộp thoại đang đóng.
                        if (IsStaff(vaiTro))
                        {
                            var list = AdminGetSessions(conn);
                            int tong = 0;
                            foreach (dynamic s in list)
                            {
                                tong += (int)s.SoTinChuaDoc;
                            }
                            context.Response.Write(js.Serialize(new { success = true, tongChuaDoc = tong, data = list }));
                        }
                        else
                        {
                            int maPhien = GetOrCreateSession(conn, userId);
                            int tong = CountChuaDoc(conn, maPhien, vaiTro);
                            context.Response.Write(js.Serialize(new { success = true, tongChuaDoc = tong, maPhienChat = maPhien }));
                        }
                    }
                    else if (action == "admin_get_sessions")
                    {
                        if (!IsStaff(vaiTro))
                        {
                            context.Response.StatusCode = 403;
                                context.Response.Write(js.Serialize(new { success = false, message = "forbidden" }));
                            return;
                        }
                        var sessions = AdminGetSessions(conn);
                        context.Response.Write(js.Serialize(new { success = true, data = sessions }));
                    }
                    else if (action == "delete_session")
                    {
                        // Cho phep Admin/NhanVien dong va xoa han mot phien chat
                        if (!IsStaff(vaiTro))
                        {
                            context.Response.StatusCode = 403;
                            context.Response.Write(js.Serialize(new { success = false, message = "forbidden" }));
                            return;
                        }

                        int maPhien = 0;
                        if (int.TryParse(context.Request.Form["maPhienChat"] ?? context.Request.QueryString["maPhienChat"], out maPhien) && maPhien > 0)
                        {
                            DeleteSession(conn, maPhien);
                            context.Response.Write(js.Serialize(new { success = true, message = "Đã xóa phiên trò chuyện!" }));
                        }
                        else
                        {
                            context.Response.Write(js.Serialize(new { success = false, message = "Mã phiên không hợp lệ!" }));
                        }
                    }
                    else
                    {
                        context.Response.Write(js.Serialize(new { success = false, message = "Unknown action" }));
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(js.Serialize(new { success = false, message = ex.Message }));
            }
        }

        private bool IsAdmin(string vaiTro)
        {
            return Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsAdmin(vaiTro);
        }

        private bool IsStaff(string vaiTro)
        {
            return Ban_Linh_Kien_xe_may_1.Utils.PhanQuyen.IsStaff(vaiTro);
        }

        private bool CanAccessSession(SqlConnection conn, int maPhien, int userId, string vaiTro)
        {
            if (maPhien <= 0) return false;
            // Admin và NhanVien đều được xem/trả lời mọi phiên chat
            if (IsStaff(vaiTro)) return true;

            string sql = "SELECT COUNT(1) FROM PhienChat WHERE MaPhienChat = @MaPhien AND MaNguoiDung = @MaNguoiDung";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@MaPhien", maPhien);
                cmd.Parameters.AddWithValue("@MaNguoiDung", userId);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        /// <summary>Tên cột trạng thái đã đọc tương ứng với phía đang đọc.</summary>
        private string CotDaDoc(string vaiTro)
        {
            return IsStaff(vaiTro) ? "DaDocNhanVien" : "DaDocKhach";
        }

        /// <summary>Số tin nhắn trong phiên mà phía <paramref name="vaiTro"/> chưa đọc.</summary>
        private int CountChuaDoc(SqlConnection conn, int maPhien, string vaiTro)
        {
            string cot = CotDaDoc(vaiTro);
            string sql = "SELECT COUNT(1) FROM TinNhan WHERE MaPhienChat = @MaPhien AND " + cot + " = 0";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@MaPhien", maPhien);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        /// <summary>Đánh dấu đã đọc cho phía gọi. Không đụng tới trạng thái của phía còn lại.</summary>
        private void MarkDaDoc(SqlConnection conn, int maPhien, string vaiTro)
        {
            string cot = CotDaDoc(vaiTro);
            string sql = "UPDATE TinNhan SET " + cot + " = 1 WHERE MaPhienChat = @MaPhien AND " + cot + " = 0";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@MaPhien", maPhien);
                cmd.ExecuteNonQuery();
            }
        }

        private int GetOrCreateSession(SqlConnection conn, int userId)
        {
            string checkSql = "SELECT TOP 1 MaPhienChat FROM PhienChat WHERE MaNguoiDung = @MaNguoiDung ORDER BY ThoiGianBatDau DESC";
            using (SqlCommand cmd = new SqlCommand(checkSql, conn))
            {
                cmd.Parameters.AddWithValue("@MaNguoiDung", userId);
                object res = cmd.ExecuteScalar();
                if (res != null) return Convert.ToInt32(res);
            }

            string insertSql = "INSERT INTO PhienChat (MaNguoiDung, ThoiGianBatDau) OUTPUT INSERTED.MaPhienChat VALUES (@MaNguoiDung, GETDATE())";
            using (SqlCommand cmd = new SqlCommand(insertSql, conn))
            {
                cmd.Parameters.AddWithValue("@MaNguoiDung", userId);
                return (int)cmd.ExecuteScalar();
            }
        }

        private List<object> GetMessages(SqlConnection conn, int maPhien)
        {
            List<object> list = new List<object>();
            string sql = @"SELECT t.MaTinNhan, t.MaPhienChat, t.MaNguoiGui, t.NoiDung, t.ThoiGianGui, ISNULL(n.HoTen, N'Khách') AS HoTen 
                           FROM TinNhan t 
                           LEFT JOIN NguoiDung n ON t.MaNguoiGui = n.MaNguoiDung 
                           WHERE t.MaPhienChat = @MaPhien 
                           ORDER BY t.ThoiGianGui ASC";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@MaPhien", maPhien);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        list.Add(new
                        {
                            MaTinNhan = dr["MaTinNhan"],
                            MaPhienChat = dr["MaPhienChat"],
                            MaNguoiGui = dr["MaNguoiGui"],
                            TenNguoiGui = dr["HoTen"].ToString(),
                            NoiDung = dr["NoiDung"].ToString(),
                            ThoiGianGui = Convert.ToDateTime(dr["ThoiGianGui"]).ToString("HH:mm dd/MM")
                        });
                    }
                }
            }
            return list;
        }

        private void SendMessage(SqlConnection conn, int maPhien, int maNguoiGui, string noiDung, bool nguoiGuiLaNhanVien)
        {
            // Người gửi luôn đã đọc tin của mình; phía còn lại thì chưa đọc.
            string sql = @"INSERT INTO TinNhan (MaPhienChat, MaNguoiGui, NoiDung, ThoiGianGui, DaDoc, DaDocKhach, DaDocNhanVien)
                           VALUES (@MaPhien, @MaNguoiGui, @NoiDung, GETDATE(), 1, @DaDocKhach, @DaDocNhanVien)";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@MaPhien", maPhien);
                cmd.Parameters.AddWithValue("@MaNguoiGui", maNguoiGui);
                cmd.Parameters.AddWithValue("@NoiDung", noiDung);
                cmd.Parameters.AddWithValue("@DaDocKhach", nguoiGuiLaNhanVien ? (object)0 : 1);
                cmd.Parameters.AddWithValue("@DaDocNhanVien", nguoiGuiLaNhanVien ? 1 : (object)0);
                cmd.ExecuteNonQuery();
            }
        }

        private List<object> AdminGetSessions(SqlConnection conn)
        {
            List<object> list = new List<object>();
            string sql = @"
                SELECT 
                    p.MaPhienChat, 
                    p.MaNguoiDung, 
                    p.ThoiGianBatDau,
                    ISNULL(n.HoTen, N'Khách hàng') AS HoTen,
                    ISNULL(m.NoiDung, N'Chưa có tin nhắn') AS TinNhanCuoi,
                    m.ThoiGianGui AS ThoiGianCuoi,
                    ISNULL(u.SoChuaDoc, 0) AS SoTinChuaDoc
                FROM PhienChat p
                LEFT JOIN NguoiDung n ON p.MaNguoiDung = n.MaNguoiDung
                OUTER APPLY (
                    SELECT TOP 1 NoiDung, ThoiGianGui 
                    FROM TinNhan 
                    WHERE MaPhienChat = p.MaPhienChat 
                    ORDER BY ThoiGianGui DESC
                ) m
                OUTER APPLY (
                    SELECT COUNT(1) AS SoChuaDoc
                    FROM TinNhan t2
                    WHERE t2.MaPhienChat = p.MaPhienChat AND t2.DaDocNhanVien = 0
                ) u
                ORDER BY SoTinChuaDoc DESC, m.ThoiGianGui DESC, p.ThoiGianBatDau DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string tgCuoi = "";
                        if (dr["ThoiGianCuoi"] != DBNull.Value)
                        {
                            tgCuoi = Convert.ToDateTime(dr["ThoiGianCuoi"]).ToString("HH:mm dd/MM");
                        }

                        list.Add(new
                        {
                            MaPhienChat = Convert.ToInt32(dr["MaPhienChat"]),
                            MaNguoiDung = Convert.ToInt32(dr["MaNguoiDung"]),
                            HoTen = dr["HoTen"].ToString(),
                            TinNhanCuoi = dr["TinNhanCuoi"].ToString(),
                            ThoiGianCuoi = tgCuoi,
                            SoTinChuaDoc = Convert.ToInt32(dr["SoTinChuaDoc"])
                        });
                    }
                }
            }
            return list;
        }

        private void DeleteSession(SqlConnection conn, int maPhien)
        {
            using (var cmd = new SqlCommand("DELETE FROM TinNhan WHERE MaPhienChat = @MaPhien", conn))
            {
                cmd.Parameters.AddWithValue("@MaPhien", maPhien);
                cmd.ExecuteNonQuery();
            }
            using (var cmd = new SqlCommand("DELETE FROM PhienChat WHERE MaPhienChat = @MaPhien", conn))
            {
                cmd.Parameters.AddWithValue("@MaPhien", maPhien);
                cmd.ExecuteNonQuery();
            }
        }

        public bool IsReusable => false;
    }
}