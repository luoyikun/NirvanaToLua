//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

/// <summary>
/// The utility tool for MD5.
/// </summary>
public static class MD5
{
    /// <summary>
    /// Gets the md5 value from string.
    /// </summary>
    public static uint GetMD5FromString(string data)
    {
        var md5 = new MD5CryptoServiceProvider();
        var md5Bytes = md5.ComputeHash(
            Encoding.Default.GetBytes(data));

        var value = (uint)((md5Bytes[0] & 0xFF) |
            ((md5Bytes[1] & 0xFF) << 8) |
            ((md5Bytes[2] & 0xFF) << 16) |
            ((md5Bytes[3] & 0xFF) << 24));
        return value;
    }

    /// <summary>
    /// Get the md5 value from file.
    /// </summary>
    public static uint GetMD5FromFile(string filePath)
    {
        try
        {
            var file = new FileStream(filePath, FileMode.Open);
            var md5 = new MD5CryptoServiceProvider();
            var md5Bytes = md5.ComputeHash(file);
            file.Close();

            var value = (uint)((md5Bytes[0] & 0xFF) | 
                ((md5Bytes[1] & 0xFF) << 8) | 
                ((md5Bytes[2] & 0xFF) << 16) | 
                ((md5Bytes[3] & 0xFF) << 24));
            return value;
        }
        catch (Exception ex)
        {
            throw new Exception("GetMD5FromFile fail:" + ex.Message);
        }
    }
}
