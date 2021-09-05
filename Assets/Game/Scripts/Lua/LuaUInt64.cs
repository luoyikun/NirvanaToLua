using System;
using UnityEngine;

public class LuaUInt64
{
    public static byte[] Make(UInt32 high, UInt32 low)
    {
        UInt64 uint64_value = high;
        uint64_value = ((uint64_value << 32) | low);
        return BitConverter.GetBytes(uint64_value);
    }

    public static byte[] FromString(string str)
    {
        UInt64 v;
        UInt64.TryParse(str, out v);
        return BitConverter.GetBytes(v);
    }

    public static byte[] And(byte[] left, byte[] right)
    {
        ulong uint64_value_l = BitConverter.ToUInt64(left, 0);
        ulong uint64_value_r = BitConverter.ToUInt64(right, 0);

        return BitConverter.GetBytes(uint64_value_l & uint64_value_r);
    }

    public static byte[] Or(byte[] left, byte[] right)
    {
        ulong uint64_value_l = BitConverter.ToUInt64(left, 0);
        ulong uint64_value_r = BitConverter.ToUInt64(right, 0);

        return BitConverter.GetBytes(uint64_value_l | uint64_value_r);
    }

    public static byte[] Xor(byte[] left, byte[] right)
    {
        ulong uint64_value_l = BitConverter.ToUInt64(left, 0);
        ulong uint64_value_r = BitConverter.ToUInt64(right, 0);

        return BitConverter.GetBytes(uint64_value_l ^ uint64_value_r);
    }

    public static byte[] FromDouble(double v)
    {
        return BitConverter.GetBytes((ulong)v);
    }

    public static double ToDouble(byte[] v)
    {
        return (double)BitConverter.ToUInt64(v, 0);
    }

    public static string ToString(byte[] v)
    {
        ulong uint64_value = BitConverter.ToUInt64(v, 0);
        return uint64_value.ToString();
    }

    public static byte[] UInt64ToBytes(UInt64 v)
    {
        return BitConverter.GetBytes(v);
    }

    public static UInt64 BytesToUInt64(byte[] v)
    {
        return BitConverter.ToUInt64(v, 0);
    }

    public static double LongLongToLuaNumber(UInt32 high, UInt32 low)
    {
        return (double)BitConverter.ToInt64(LuaUInt64.Make(high, low), 0);
    }
}
