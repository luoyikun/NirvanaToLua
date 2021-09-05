using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class EncryptStream : FileStream
{
    private byte[] encryptKey;
    public EncryptStream(string path, FileMode mode, FileAccess access, FileShare share, int bufferSize, bool useAsync) : base(path, mode, access, share, bufferSize, useAsync)
    {

    }
    public EncryptStream(string path, FileMode mode) : base(path, mode)
    {

    }

    public void SetEncryptKey(byte[] encryptKey)
    {
        this.encryptKey = encryptKey;
    }

    public override int Read(byte[] array, int offset, int count)
    {
        var index = base.Read(array, offset, count);
        for (int i = 0; i < array.Length; i++)
        {
            array[i] ^= encryptKey[i % encryptKey.Length];
        }
        return index;
    }

    public override void Write(byte[] array, int offset, int count)
    {
        for (int i = 0; i < array.Length; i++)
        {
            array[i] ^= encryptKey[i % encryptKey.Length];
        }
        base.Write(array, offset, count);
    }
}
