//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

/// <summary>
/// The utility tool for string.
/// </summary>
public static class StringUtil
{
    /// <summary>
    /// Gets the character count for a string.
    /// </summary>
    public static int GetCharacterCount(string text)
    {
        return text.Length;
    }

    /// <summary>
    /// Gets the substring of a text.
    /// </summary>
    public static string Substring(string text, int start, int length)
    {
        return text.Substring(start, length);
    }

    public static int LastIndexOf(string text, string value)
    {
        return text.LastIndexOf(value);
    }
}
