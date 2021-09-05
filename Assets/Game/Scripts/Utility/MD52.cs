//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System.Security.Cryptography;
using System.Text;

/// <summary>
/// The utility tool for MD5.
/// </summary>
public static class MD52
{
    /// <summary>
    /// Gets the md5 value from string.
    /// </summary>
    public static string GetMD5(string data)
    {
        var md5 = new MD5CryptoServiceProvider();
        var fromData = Encoding.UTF8.GetBytes(data);
        var targetData = md5.ComputeHash(fromData);

        var builder = new StringBuilder();
        for (int i = 0; i < targetData.Length; ++i)
        {
            builder.Append(targetData[i].ToString("x2"));
        }

        return builder.ToString();
    }
}
