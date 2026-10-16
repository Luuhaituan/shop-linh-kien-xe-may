<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dieu_khoan.aspx.cs" Inherits="Ban_Linh_Kien_xe_may_1.Dieu_khoan" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điều Khoản Dịch Vụ | VanDonMotor</title>
    
    <!-- Tái sử dụng file auth.css để lấy màu nền gốc -->
    <link rel="stylesheet" href="auth.css"/> 
    
    <style>
        /* Tùy chỉnh riêng cho phần khung chứa văn bản */
        .terms-page-bg {
            min-height: 100vh;
            background: var(--bg);
            padding: 40px 20px;
        }
        .terms-container {
            max-width: 850px;
            margin: 0 auto;
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            color: #d1d5db; /* Màu xám sáng cho dễ đọc */
            line-height: 1.7;
            font-size: 15px;
        }
        .terms-container h1 {
            color: var(--primary);
            text-align: center;
            font-size: 24px;
            margin-bottom: 20px;
            text-transform: uppercase;
        }
        .terms-container h4 {
            color: #ffffff;
            font-size: 18px;
            margin-top: 30px;
            margin-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            padding-bottom: 8px;
        }
        .terms-container ul {
            padding-left: 20px;
            margin-bottom: 15px;
        }
        .terms-container li {
            margin-bottom: 8px;
        }
        .terms-container strong {
            color: var(--text); /* Màu trắng nổi bật */
        }
        .back-btn {
            display: inline-block;
            margin-bottom: 20px;
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
        }
        .back-btn:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="terms-page-bg">
            <div class="terms-container">
                
                <a href="Dang_ky.aspx" class="back-btn">&larr; Quay lại trang đăng ký</a>
                
                <h1>ĐIỀU KHOẢN DỊCH VỤ VanDonMotor</h1>
                
                <p>Chào mừng bạn đến với hệ thống mua sắm trực tuyến VanDonMotor. Việc bạn truy cập, đăng ký tài khoản và sử dụng các dịch vụ trên website đồng nghĩa với việc bạn đã đồng ý với các Điều khoản dịch vụ dưới đây.</p>

                <h4>Điều 1: Tài khoản người dùng</h4>
                <ul>
                    <li><strong>Thông tin đăng ký:</strong> Người dùng cần cung cấp thông tin cá nhân (Họ tên, Số điện thoại, Email, Địa chỉ) chính xác để hệ thống lưu trữ và xử lý đơn hàng.</li>
                    <li><strong>Bảo mật:</strong> Bạn tự chịu trách nhiệm bảo mật thông tin đăng nhập. Mọi giao dịch phát sinh từ tài khoản của bạn sẽ được mặc định là do chính bạn thực hiện.</li>
                </ul>

                <h4>Điều 2: Thông tin sản phẩm và Giá cả</h4>
                <ul>
                    <li><strong>Mô tả sản phẩm:</strong> Chúng tôi nỗ lực cung cấp hình ảnh và thông số kỹ thuật của linh kiện, phụ tùng xe máy chính xác nhất có thể. Tuy nhiên, màu sắc thực tế có thể chênh lệch đôi chút do thiết bị hiển thị.</li>
                    <li><strong>Giá bán:</strong> Giá sản phẩm niêm yết chưa bao gồm phí vận chuyển. Giá có thể được điều chỉnh tùy theo từng thời điểm mà không cần thông báo trước, tuy nhiên giá của đơn hàng đã xác nhận sẽ không thay đổi.</li>
                </ul>

                <h4>Điều 3: Xử lý Đơn hàng và Thanh toán</h4>
                <ul>
                    <li><strong>Xác nhận đơn hàng:</strong> Sau khi bạn đặt hàng thành công trên website, nhân viên hoặc hệ thống của VanDonMotor sẽ tiến hành xác nhận trước khi giao.</li>
                    <li><strong>Từ chối đơn hàng:</strong> Chúng tôi có quyền từ chối xử lý đơn trong trường hợp sản phẩm hết hàng hoặc phát hiện lỗi hệ thống hiển thị sai giá trị sản phẩm.</li>
                    <li><strong>Thanh toán:</strong> Chấp nhận thanh toán khi nhận hàng (COD) hoặc chuyển khoản ngân hàng theo hướng dẫn trên website.</li>
                </ul>

                <h4>Điều 4: Vận chuyển và Đổi trả</h4>
                <ul>
                    <li><strong>Giao hàng:</strong> Thời gian và chi phí giao hàng phụ thuộc vào địa chỉ nhận hàng và khối lượng linh kiện.</li>
                    <li><strong>Kiểm hàng:</strong> Khách hàng được quyền kiểm tra ngoại quan linh kiện khi nhận, nhưng không được phép lắp ráp thử lên xe trước khi thanh toán.</li>
                    <li><strong>Đổi trả:</strong> Hỗ trợ đổi trả trong vòng 7 ngày nếu sản phẩm bị giao sai mã, hỏng hóc do quá trình vận chuyển, hoặc lỗi kỹ thuật từ nhà sản xuất (sản phẩm phải chưa qua sử dụng).</li>
                </ul>

                <h4>Điều 5: Các hành vi bị nghiêm cấm</h4>
                <p>Để đảm bảo hệ thống hoạt động ổn định, người dùng không được phép thực hiện các hành vi sau:</p>
                <ul>
                    <li>Tạo đơn hàng giả mạo (bom hàng) gây ảnh hưởng đến hệ thống vận hành.</li>
                    <li>Sử dụng phần mềm tự động, can thiệp vào cơ sở dữ liệu hoặc phát tán mã độc lên website.</li>
                    <li>Sử dụng thông tin sản phẩm của VanDonMotor để lừa đảo hoặc vi phạm pháp luật.</li>
                </ul>

                <h4>Điều 6: Giới hạn trách nhiệm</h4>
                <p>VanDonMotor chỉ cung cấp linh kiện và phụ tùng. Chúng tôi <strong>không chịu trách nhiệm</strong> cho bất kỳ hỏng hóc, sự cố kỹ thuật hay thiệt hại nào phát sinh do việc khách hàng tự lắp đặt linh kiện sai quy cách, sai dòng xe, hoặc tự ý độ chế làm thay đổi kết cấu an toàn của phương tiện.</p>
            </div>
        </div>
    </form>
</body>
</html>