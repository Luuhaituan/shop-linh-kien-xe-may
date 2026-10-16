/* =========================================================
   OTP UPGRADE - Bang luu ma xac thuc email (OTP)
   Dung cho: Xac thuc email khi Dang ky + Dat lai mat khau
   Chay 1 lan. An toan khi chay lai (co IF NOT EXISTS).
   ========================================================= */

IF OBJECT_ID('dbo.MaXacThucOTP', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MaXacThucOTP (
        Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Email          VARCHAR(255)      NOT NULL,
        MaOTP          CHAR(6)           NOT NULL,
        MucDich        VARCHAR(20)       NOT NULL, -- Register | ResetPassword
        SoLanThu       INT               NOT NULL DEFAULT 0,
        DaSuDung       BIT               NOT NULL DEFAULT 0,
        ThoiGianHetHan DATETIME          NOT NULL,
        NgayTao        DATETIME          NOT NULL DEFAULT GETDATE()
    );
    CREATE INDEX IX_MaXacThucOTP_Email_MucDich
        ON dbo.MaXacThucOTP(Email, MucDich, DaSuDung);
END
GO
