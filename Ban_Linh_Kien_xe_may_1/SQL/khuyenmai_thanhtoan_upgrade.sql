/* =========================================================
   KHUYEN MAI / THANH TOAN UPGRADE
   Bo sung phan ap dung ma giam gia khi thanh toan.
   Chay 1 lan. An toan khi chay lai (co IF NOT EXISTS).
   ========================================================= */

/* 1. Dam bao bang MaGiamGia da ton tai (neu chua chay admin_v2_upgrade.sql) */
IF OBJECT_ID('dbo.MaGiamGia', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MaGiamGia (
        MaGiamGia        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MaCode           VARCHAR(50)      NOT NULL,
        TenKhuyenMai     NVARCHAR(200)    NOT NULL,
        LoaiGiam         VARCHAR(20)      NOT NULL DEFAULT 'PhanTram', -- PhanTram | SoTien
        GiaTri           DECIMAL(18,0)    NOT NULL DEFAULT 0,
        GiamToiDa        DECIMAL(18,0)    NULL,
        DonHangToiThieu  DECIMAL(18,0)    NULL DEFAULT 0,
        SoLuong          INT              NULL,                       -- NULL = khong gioi han
        DaDung           INT              NOT NULL DEFAULT 0,
        NgayBatDau       DATETIME         NULL,
        NgayKetThuc      DATETIME         NULL,
        TrangThai        BIT              NOT NULL DEFAULT 1,
        NgayTao          DATETIME         NOT NULL DEFAULT GETDATE()
    );
    CREATE UNIQUE INDEX UX_MaGiamGia_MaCode ON dbo.MaGiamGia(MaCode);
END
GO

/* 2. Them cot MaGiamGiaCode vao DonHang de luu ma da ap dung cho don */
IF COL_LENGTH('dbo.DonHang', 'MaGiamGiaCode') IS NULL
BEGIN
    ALTER TABLE dbo.DonHang ADD MaGiamGiaCode VARCHAR(50) NULL;
END
GO

/* 3. Them vai ma giam gia mau de test (neu chua co) */
IF NOT EXISTS (SELECT 1 FROM dbo.MaGiamGia WHERE MaCode = 'VANDON40')
    INSERT INTO dbo.MaGiamGia (MaCode, TenKhuyenMai, LoaiGiam, GiaTri, GiamToiDa, DonHangToiThieu, SoLuong, TrangThai)
    VALUES ('VANDON40', N'VanDonMotor - Giam 40%', 'PhanTram', 40, NULL, 0, NULL, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.MaGiamGia WHERE MaCode = 'GIAM50K')
    INSERT INTO dbo.MaGiamGia (MaCode, TenKhuyenMai, LoaiGiam, GiaTri, GiamToiDa, DonHangToiThieu, SoLuong, TrangThai)
    VALUES ('GIAM50K', N'Giam 50.000d cho don tu 300.000d', 'SoTien', 50000, NULL, 300000, NULL, 1);
GO
