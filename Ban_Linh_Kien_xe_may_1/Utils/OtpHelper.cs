using System;
using System.Data.SqlClient;
using System.Security.Cryptography;

namespace Ban_Linh_Kien_xe_may_1.Utils
{
    public enum KetQuaOtp
    {
        HopLe = 0,
        KhongTonTai = 1,
        SaiMa = 2,
        QuaNhieuLanSai = 3
    }

    /// <summary>
    /// Quan ly ma xac thuc email (OTP) luu trong bang MaXacThucOTP.
    /// Dung ADO.NET de khong phai cap nhat EDMX.
    /// </summary>
    public static class OtpHelper
    {
        public const string MucDichDangKy = "Register";
        public const string MucDichDatLai = "ResetPassword";

        private const int SoLanSaiToiDa = 5;
        private const int HieuLucPhut = 5;

        /// <summary>Sinh ma OTP 6 chu so bang nguon ngau nhien bao mat.</summary>
        public static string TaoMaOtp()
        {
            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] bytes = new byte[4];
                rng.GetBytes(bytes);
                uint value = BitConverter.ToUInt32(bytes, 0) % 1000000u;
                return value.ToString("D6");
            }
        }

        /// <summary>Tao OTP moi, luu DB va gui ve email. Tra ve ma vua tao.</summary>
        public static string TaoVaGuiOtp(string email, string mucDich, string hoTen = null)
        {
            string ma = TaoMaOtp();
            LuuOtp(email, ma, mucDich);
            EmailHelper.Gui(email, "Mã xác thực VanDonMotor",
                EmailHelper.TaoNoiDungOtp(hoTen, ma, HieuLucPhut));
            return ma;
        }

        private static void LuuOtp(string email, string ma, string mucDich)
        {
            string connStr = NhatKyHelper.ChuoiKetNoi();
            if (string.IsNullOrEmpty(connStr))
                throw new InvalidOperationException("Khong tim thay chuoi ket noi QuanLyLinhKienDB.");

            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Vo hieu hoa cac OTP cu cua cung email + muc dich
                using (var cmd = new SqlCommand(
                    "UPDATE MaXacThucOTP SET DaSuDung = 1 WHERE Email = @Email AND MucDich = @MucDich AND DaSuDung = 0", conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@MucDich", mucDich);
                    cmd.ExecuteNonQuery();
                }

                using (var cmd = new SqlCommand(
                    @"INSERT INTO MaXacThucOTP (Email, MaOTP, MucDich, ThoiGianHetHan)
                      VALUES (@Email, @MaOTP, @MucDich, DATEADD(MINUTE, @Phut, GETDATE()))", conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@MaOTP", ma);
                    cmd.Parameters.AddWithValue("@MucDich", mucDich);
                    cmd.Parameters.AddWithValue("@Phut", HieuLucPhut);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public static KetQuaOtp XacThucOtp(string email, string mucDich, string maNhap)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(maNhap))
                return KetQuaOtp.KhongTonTai;
            maNhap = maNhap.Trim();

            string connStr = NhatKyHelper.ChuoiKetNoi();
            if (string.IsNullOrEmpty(connStr)) return KetQuaOtp.KhongTonTai;

            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();

                int id = 0, soLanThu = 0;
                DateTime hetHan = DateTime.MinValue;
                string maLuu = null;
                bool found = false;

                using (var cmd = new SqlCommand(
                    @"SELECT TOP 1 Id, MaOTP, SoLanThu, ThoiGianHetHan
                      FROM MaXacThucOTP
                      WHERE Email = @Email AND MucDich = @MucDich AND DaSuDung = 0
                      ORDER BY NgayTao DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@MucDich", mucDich);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            found = true;
                            id = Convert.ToInt32(r["Id"]);
                            maLuu = Convert.ToString(r["MaOTP"]);
                            soLanThu = Convert.ToInt32(r["SoLanThu"]);
                            hetHan = Convert.ToDateTime(r["ThoiGianHetHan"]);
                        }
                    }
                }

                if (!found) return KetQuaOtp.KhongTonTai;
                if (hetHan < DateTime.Now) return KetQuaOtp.KhongTonTai;
                if (soLanThu >= SoLanSaiToiDa) return KetQuaOtp.QuaNhieuLanSai;

                if (!string.Equals(maLuu, maNhap, StringComparison.Ordinal))
                {
                    using (var cmd = new SqlCommand(
                        "UPDATE MaXacThucOTP SET SoLanThu = SoLanThu + 1 WHERE Id = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        cmd.ExecuteNonQuery();
                    }
                    return KetQuaOtp.SaiMa;
                }

                using (var cmd = new SqlCommand(
                    "UPDATE MaXacThucOTP SET DaSuDung = 1 WHERE Id = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", id);
                    cmd.ExecuteNonQuery();
                }
                return KetQuaOtp.HopLe;
            }
        }

        public static string MoTaKetQua(KetQuaOtp kq)
        {
            switch (kq)
            {
                case KetQuaOtp.SaiMa:
                    return "Mã xác thực không đúng!";
                case KetQuaOtp.QuaNhieuLanSai:
                    return "Bạn đã nhập sai quá nhiều lần. Vui lòng gửi lại mã mới.";
                case KetQuaOtp.KhongTonTai:
                    return "Mã xác thực không tồn tại hoặc đã hết hạn. Vui lòng gửi lại mã.";
                default:
                    return "";
            }
        }
    }
}
