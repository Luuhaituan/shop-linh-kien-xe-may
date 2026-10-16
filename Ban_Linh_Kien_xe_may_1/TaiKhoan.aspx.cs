using System;
using System.Web.UI;

namespace Ban_Linh_Kien_xe_may_1
{
    public partial class TaiKhoan : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // B?o m?t: n?u ch?a ??ng nh?p thì chuy?n t?i trang ??ng nh?p
            if (Session["User"] == null)
            {
                Response.Redirect("Dang_nhap.aspx");
                return;
            }
        }
    }
}
