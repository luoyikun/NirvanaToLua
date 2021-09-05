//------------------------------------------------------------------------------
// This file is part of CrossGate project in Area6.
// Copyright © 2013-2015 Area6 Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using LuaInterface;
using Nirvana;
using System;

/// <summary>
/// The extension for <see cref="NetClient"/>
/// </summary>
public static class NetClientExtensions
{
    public delegate void ReceiveMessageDelegate(LuaByteBuffer message);
    private static bool isNeedEncryptMg;
    private static byte[] encryptKey;
    private static int ECNRYPT_KEY_LEN = 256;

    public static NetClient.ReceiveDelegate ListenMessage(
        this NetClient client, 
        ReceiveMessageDelegate receiveDelegate)
    {
        NetClient.ReceiveDelegate handle = delegate(byte[] bytes, uint len)
        {
            client.TryDecryptMsg(bytes, (int)len);
            var message = new LuaByteBuffer(bytes, (int)len);
            receiveDelegate(message);
        };

        client.ReceiveEvent += handle;
        return handle;
    }

    public static void UnlistenMessage(
        this NetClient client, 
        NetClient.ReceiveDelegate handle)
    {
        client.ReceiveEvent -= handle;
    }

    public static NetClient.DisconnectDelegate ListenDisconnect(
        this NetClient client, NetClient.DisconnectDelegate handler)
    {
        client.DisconnectEvent += handler;
        return handler;
    }

    public static void UnlistenDisconnect(
        this NetClient client, NetClient.DisconnectDelegate handle)
    {
        client.DisconnectEvent -= handle;
    }

    public static void SetIsNeedEncryptMsg(this NetClient client, bool _isNeedEncryptMg)
    {
        isNeedEncryptMg = _isNeedEncryptMg;
    }

    private static void TryDecryptMsg(this NetClient client, byte[] data, int dataLen)
    {
        if (isNeedEncryptMg && null != encryptKey && dataLen > 0)
        {
            DecryptMsg(client, data, dataLen);
        }
    }

    public static void TrySendEncryptKeyToServer(this NetClient client)
    {
        if (!isNeedEncryptMg)
        {
            return;
        }

        if (null == encryptKey)
        {
            encryptKey = new byte[ECNRYPT_KEY_LEN];
            Random ran = new Random();
            for (int i = 0; i < ECNRYPT_KEY_LEN; i++)
            {
                encryptKey[i] = Convert.ToByte(ran.Next(0, 255));
            }
        }

        byte[] msgData = new byte[4 + ECNRYPT_KEY_LEN];
        ushort msgType = 65535;
        byte[] typeByte = System.BitConverter.GetBytes(msgType);
        Buffer.BlockCopy(typeByte, 0, msgData, 0, typeByte.Length);
        Buffer.BlockCopy(encryptKey, 0, msgData, 4, ECNRYPT_KEY_LEN);

        client.SendMsg(msgData, null);
    }

    public static void ClearEncryptKey(this NetClient client)
    {
        encryptKey = null;
    }

    public static void TrySendEncryptMsg(this NetClient client, byte[] data, NetClient.SendDelegate sendDelegate = null)
    {
        if (isNeedEncryptMg && null != encryptKey)
        {
            EncryptMsg(client, data, data.Length);
            client.SendMsg(data, sendDelegate);
        }
        else
        {
            client.SendMsg(data, sendDelegate);
        }
    }

    public static void DecryptMsg(this NetClient client, byte[] data, int dataLen)
    {
        for (int i = 0; i < dataLen; i++)
        {
            data[i] ^= encryptKey[i % ECNRYPT_KEY_LEN];
        }
    }

    public static void EncryptMsg(this NetClient client, byte[] data, int dataLen)
    {
        for (int i = 0; i < dataLen; i++)
        {
            data[i] ^= encryptKey[i % ECNRYPT_KEY_LEN];
        }
    }
}
