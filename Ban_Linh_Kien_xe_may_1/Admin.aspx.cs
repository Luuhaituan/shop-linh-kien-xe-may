using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Ban_Linh_Kien_xe_may_1.Models;
using Ban_Linh_Kien_xe_may_1.Utils;

namespace Ban_Linh_Kien_xe_may_1
{
    public partial class Admin : System.Web.UI.Page
    {
        /// <summary>Admin mới được mở toàn bộ khu vực quản trị; NhanVien chỉ mở tab Chat.</summary>
        public bool CanAccessAdmin { get; private set; }

        /// <summary>true = Admin, false = nhân viên (chỉ được một số tab).</summary>
        public bool IsQuanTriVien { get; private set; }

        /// <summary>Vai trò của tài khoản đang đăng nhập (Admin/NhanVienKho/...).</summary>
        public string VaiTroHienTai { get; private set; }

        /// <summary>Các tab mà vai trò hiện tại được phép truy cập (đúng thứ tự sidebar).</summary>
        public System.Collections.Generic.List<string> TabChoPhep { get; private set; }

        /// <summary>Tab mặc định mở đầu tiên.</summary>
        public string TabMacDinh { get; private set; }

        /// <summary>Chuỗi JS dạng 'sanpham','kho' để truyền xuống client.</summary>
        public string TabChoPhepJs { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            var user = Session["User"] as NguoiDung;

            if (user == null)
            {
                Response.Redirect("Dang_nhap.aspx", true);
                return;
            }

            CanAccessAdmin = PhanQuyen.IsStaff(user.VaiTro);

            if (!CanAccessAdmin)
            {
                // Chi dat header/status o day; noi dung HTML do khoi <% %> trong .aspx lo.
                // Toan bo giao dien quan tri da duoc boc trong <% if (CanAccessAdmin) { %>.
                Response.StatusCode = 403;
                Response.TrySkipIisCustomErrors = true;
                Response.ContentType = "text/html; charset=utf-8";
                return;
            }

            IsQuanTriVien = PhanQuyen.IsAdmin(user.VaiTro);
            VaiTroHienTai = user.VaiTro;

            TabChoPhep = new System.Collections.Generic.List<string>();
            foreach (var t in PhanQuyen.TatCaTab)
            {
                if (PhanQuyen.CoQuyen(user.VaiTro, t)) TabChoPhep.Add(t);
            }
            TabMacDinh = TabChoPhep.Count > 0 ? TabChoPhep[0] : "";
            TabChoPhepJs = TabChoPhep.Count > 0
                ? "'" + string.Join("','", TabChoPhep) + "'"
                : "";
        }

        /// <summary>Vai trò hiện tại có quyền với tab không (dùng để render sidebar).</summary>
        public bool CoTab(string tab)
        {
            return TabChoPhep != null && TabChoPhep.Contains(tab);
        }
    }
}