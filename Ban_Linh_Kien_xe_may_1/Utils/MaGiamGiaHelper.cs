using System;
using System.Data.SqlClient;

namespace Ban_Linh_Kien_xe_may_1.Utils
{
    /// <summary>Ket qua kiem tra/ap dung mot ma giam gia.</summary>
    public class KetQuaMaGiamGia
    {
        public bool HopLe { get; set; }
        public string MaCode { get; set; }
        public string TenKhuyenMai { get; set; }
        public string LoaiGiam { get; set; }
        public decimal GiaTri { get; set; }
        public decimal TienGiam { get; set; }
        public string ThongBao { get; set; }
    }

    /// <summary>
    /// Doc/kiem tra va cap nhat ma giam gia (bang MaGiamGia) qua ADO.NET.
    /// Khong phu thuoc EDMX de tranh phai "Update Model from Database".
    /// </summary>
    public static class MaGiamGiaHelper
    {
        /// <summary>
        /// Kiem tra ma co hop le voi don hang hay khong va tinh so tien duoc giam.
        /// Neu truyen maNguoiDung thi kiem tra them: moi tai khoan chi duoc dung ma nay 1 lan.
        /// </summary>
        public static KetQuaMaGiamGia KiemTra(string maCode, decimal tongTienHang, int? maNguoiDung = null)
        {
            var kq = new KetQuaMaGiamGia { HopLe = false };
            maCode = (maCode ?? "").Trim().ToUpper();

            if (string.IsNullOrEmpty(maCode))
            {
                kq.ThongBao = "Vui lòng nhập mã giảm giá.";
                return kq;
            }

            string connStr = NhatKyHelper.ChuoiKetNoi();
            if (string.IsNullOrEmpty(connStr))
            {
                kq.ThongBao = "Không kết nối được cơ sở dữ liệu.";
                return kq;
            }

            const string sql = @"SELECT TOP 1 MaGiamGia, MaCode, TenKhuyenMai, LoaiGiam, GiaTri, GiamToiDa,
                                        DonHangToiThieu, SoLuong, DaDung, NgayBatDau, NgayKetThuc, TrangThai
                                 FROM MaGiamGia WHERE MaCode = @Code";

            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Code", maCode);
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read())
                    {
                        kq.ThongBao = "Mã giảm giá không tồn tại.";
                        return kq;
                    }

                    bool trangThai = dr["TrangThai"] != DBNull.Value && Convert.ToBoolean(dr["TrangThai"]);
                    string ten = dr["TenKhuyenMai"] == DBNull.Value ? "" : dr["TenKhuyenMai"].ToString();
                    string loai = dr["LoaiGiam"] == DBNull.Value ? "PhanTram" : dr["LoaiGiam"].ToString();
                    decimal giaTri = dr["GiaTri"] == DBNull.Value ? 0m : Convert.ToDecimal(dr["GiaTri"]);
                    decimal? giamToiDa = dr["GiamToiDa"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(dr["GiamToiDa"]);
                    decimal donToiThieu = dr["DonHangToiThieu"] == DBNull.Value ? 0m : Convert.ToDecimal(dr["DonHangToiThieu"]);
                    int? soLuong = dr["SoLuong"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["SoLuong"]);
                    int daDung = dr["DaDung"] == DBNull.Value ? 0 : Convert.ToInt32(dr["DaDung"]);
                    DateTime? bd = dr["NgayBatDau"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["NgayBatDau"]);
                    DateTime? kt = dr["NgayKetThuc"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["NgayKetThuc"]);

                    kq.MaCode = maCode;
                    kq.TenKhuyenMai = ten;
                    kq.LoaiGiam = loai;
                    kq.GiaTri = giaTri;

                    if (maNguoiDung.HasValue && DaSuDungBoiNguoiDung(maCode, maNguoiDung.Value))
                    {
                        kq.ThongBao = "Tài khoản của bạn đã sử dụng mã giảm giá này rồi.";
                        return kq;
                    }

                    if (!trangThai) { kq.ThongBao = "Mã giảm giá đã bị khóa."; return kq; }
                    if (bd.HasValue && DateTime.Now < bd.Value) { kq.ThongBao = "Mã giảm giá chưa đến thời gian sử dụng."; return kq; }
                    if (kt.HasValue && DateTime.Now > kt.Value) { kq.ThongBao = "Mã giảm giá đã hết hạn."; return kq; }
                    if (soLuong.HasValue && daDung >= soLuong.Value) { kq.ThongBao = "Mã giảm giá đã hết lượt sử dụng."; return kq; }
                    if (tongTienHang < donToiThieu)
                    {
                        kq.ThongBao = "Đơn hàng tối thiểu " + donToiThieu.ToString("#,##0") + " ₫ để dùng mã này.";
                        return kq;
                    }

                    decimal tienGiam;
                    if (string.Equals(loai, "PhanTram", StringComparison.OrdinalIgnoreCase))
                    {
                        tienGiam = tongTienHang * giaTri / 100m;
                        if (giamToiDa.HasValue && giamToiDa.Value > 0 && tienGiam > giamToiDa.Value)
                            tienGiam = giamToiDa.Value;
                    }
                    else
                    {
                        tienGiam = giaTri;
                    }

                    if (tienGiam > tongTienHang) tienGiam = tongTienHang;
                    tienGiam = Math.Round(tienGiam, 0, MidpointRounding.AwayFromZero);

                    if (tienGiam <= 0)
                    {
                        kq.ThongBao = "Mã giảm giá không áp dụng được cho đơn hàng này.";
                        return kq;
                    }

                    kq.HopLe = true;
                    kq.TienGiam = tienGiam;
                    kq.ThongBao = "Áp dụng mã thành công.";
                    return kq;
                }
            }
        }

        /// <summary>
        /// Kiem tra tai khoan da tung su dung ma nay trong mot don hang chua bi huy hay chua.
        /// </summary>
        public static bool DaSuDungBoiNguoiDung(string maCode, int maNguoiDung)
        {
            maCode = (maCode ?? "").Trim().ToUpper();
            if (string.IsNullOrEmpty(maCode) || maNguoiDung <= 0) return false;

            string connStr = NhatKyHelper.ChuoiKetNoi();
            if (string.IsNullOrEmpty(connStr)) return false;

            const string sql = @"SELECT COUNT(1) FROM DonHang
                                 WHERE MaNguoiDung = @User AND MaGiamGiaCode = @Code
                                   AND (TrangThaiDon IS NULL OR (TrangThaiDon <> N'Hủy đơn hàng' AND TrangThaiDon <> N'Đã hủy'))";
            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@User", maNguoiDung);
                cmd.Parameters.AddWithValue("@Code", maCode);
                conn.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        /// <summary>Tang so lan su dung cua ma len 1 (goi sau khi tao don thanh cong).</summary>
        public static void TangSoLanDung(string maCode)
        {
            try
            {
                maCode = (maCode ?? "").Trim().ToUpper();
                if (string.IsNullOrEmpty(maCode)) return;

                string connStr = NhatKyHelper.ChuoiKetNoi();
                if (string.IsNullOrEmpty(connStr)) return;

                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand("UPDATE MaGiamGia SET DaDung = DaDung + 1 WHERE MaCode = @Code", conn))
                {
                    cmd.Parameters.AddWithValue("@Code", maCode);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch
            {
                // Khong de loi cap nhat luot dung lam hong viec dat hang
            }
        }
    }
}
