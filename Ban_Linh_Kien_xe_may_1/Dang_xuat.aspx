<%@ Page Language="C#" AutoEventWireup="true" %>
<%
    Session.Clear(); // Xóa sạch dữ liệu đăng nhập
    Session.Abandon(); // Hủy Session
    Response.Redirect("index.aspx"); // Đẩy về lại trang chủ
%>