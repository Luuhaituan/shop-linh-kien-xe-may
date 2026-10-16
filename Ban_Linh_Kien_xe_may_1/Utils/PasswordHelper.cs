using System;
using System.Security.Cryptography;
using System.Text;

namespace Ban_Linh_Kien_xe_may_1.Utils
{
    public static class PasswordHelper
    {
        // Format: PBKDF2$iterations$salt(base64)$hash(base64)
        public static string HashPassword(string password, int iterations = 10000)
        {
            if (password == null) throw new ArgumentNullException(nameof(password));

            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] salt = new byte[16];
                rng.GetBytes(salt);

                using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations))
                {
                    byte[] hash = pbkdf2.GetBytes(32);
                    return $"PBKDF2${iterations}${Convert.ToBase64String(salt)}${Convert.ToBase64String(hash)}";
                }
            }
        }

        public static bool VerifyPassword(string stored, string password)
        {
            if (stored == null) return false;
            if (password == null) return false;

            if (stored.StartsWith("PBKDF2$"))
            {
                try
                {
                    var parts = stored.Split('$');
                    if (parts.Length != 4) return false;
                    int iterations = int.Parse(parts[1]);
                    byte[] salt = Convert.FromBase64String(parts[2]);
                    byte[] storedHash = Convert.FromBase64String(parts[3]);

                    using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations))
                    {
                        byte[] testHash = pbkdf2.GetBytes(storedHash.Length);
                        return AreEqual(storedHash, testHash);
                    }
                }
                catch
                {
                    return false;
                }
            }
            else
            {
                // Legacy plaintext: compare directly
                return stored == password;
            }
        }

        public static bool IsHashed(string stored)
        {
            return !string.IsNullOrEmpty(stored) && stored.StartsWith("PBKDF2$");
        }

        // Constant-time comparison to prevent timing attacks
        private static bool AreEqual(byte[] a, byte[] b)
        {
            if (a.Length != b.Length) return false;
            int diff = 0;
            for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
            return diff == 0;
        }
    }
}
