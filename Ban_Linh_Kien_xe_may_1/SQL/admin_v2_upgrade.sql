/* =========================================================
   ADMIN V2 UPGRADE - Bo sung cac bang cho cac chuc nang quan tri
   Chay 1 lan. An toan khi chay lai (co IF NOT EXISTS).
   ========================================================= */

/* 1. Ma giam gia / Khuyen mai */
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

/* 2. Thu vien anh san pham (nhieu anh / 1 san pham) */
IF OBJECT_ID('dbo.AnhSanPham', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AnhSanPham (
        MaAnh       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MaLinhKien  INT              NOT NULL,
        DuongDanAnh VARCHAR(255)     NOT NULL,
        LaAnhChinh  BIT              NOT NULL DEFAULT 0,
        ThuTu       INT              NOT NULL DEFAULT 0,
        NgayTao     DATETIME         NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_AnhSanPham_LinhKien FOREIGN KEY (MaLinhKien)
            REFERENCES dbo.LinhKien(MaLinhKien) ON DELETE CASCADE
    );
END
GO

/* 3. Nhat ky hoat dong (audit log) */
IF OBJECT_ID('dbo.NhatKyHoatDong', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.NhatKyHoatDong (
        Id           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MaNguoiDung  INT              NULL,
        TenDangNhap  VARCHAR(50)      NULL,
        HanhDong     NVARCHAR(100)    NOT NULL,
        DoiTuong     NVARCHAR(100)    NULL,
        ChiTiet      NVARCHAR(1000)   NULL,
        DiaChiIP     VARCHAR(50)      NULL,
        ThoiGian     DATETIME         NOT NULL DEFAULT GETDATE()
    );
END
GO

/* 4. Phieu kho (nhap / xuat / dieu chinh ton kho) */
IF OBJECT_ID('dbo.PhieuKho', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PhieuKho (
        MaPhieu      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MaLinhKien   INT              NOT NULL,
        LoaiPhieu    VARCHAR(10)      NOT NULL, -- Nhap | Xuat | DieuChinh
        SoLuong      INT              NOT NULL,
        SoLuongTruoc INT              NOT NULL DEFAULT 0,
        SoLuongSau   INT              NOT NULL DEFAULT 0,
        LyDo         NVARCHAR(255)    NULL,
        GhiChu       NVARCHAR(500)    NULL,
        MaNguoiDung  INT              NULL,
        ThoiGian     DATETIME         NOT NULL DEFAULT GETDATE()
    );
END
GO

/* 5. Danh sach danh gia bi an (Admin an danh gia xau) */
IF OBJECT_ID('dbo.DanhGiaAn', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DanhGiaAn (
        MaDanhGia INT          NOT NULL PRIMARY KEY,
        LyDo      NVARCHAR(255) NULL,
        ThoiGian  DATETIME     NOT NULL DEFAULT GETDATE()
    );
END
GO
