using ICSharpCode.SharpZipLib.Checksums;
using ICSharpCode.SharpZipLib.Zip;
using System;
using System.IO;
using System.Text;
using UnityEngine;

public static class ZipUtils
{
    /// <summary>
    /// ZIP:压缩单个文件
    /// </summary>
    /// <param name="fileToZip">需要压缩的文件（绝对路径）</param>
    /// <param name="zipedPath">压缩后的文件路径（绝对路径）</param>
    /// <param name="zipedFileName">压缩后的文件名称（文件名，默认 同源文件同名）</param>
    /// <param name="action">压缩完成后的回调函数</param>
    /// <param name="compressionLevel">压缩等级（0 无 - 9 最高，默认 5）</param>
    /// <param name="blockSize">缓存大小（每次写入文件大小，默认 2048）</param>
    /// <param name="isEncrypt">是否加密（默认 不加密）</param>
    public static void ZipFile(string fileToZip, string zipedPath, string zipedFileName = "", Action action = null, int compressionLevel = 5, int blockSize = 2048, bool isEncrypt = false)
	{
        ZipConstants.DefaultCodePage = Encoding.UTF8.CodePage;  // 防止中文名乱码 
        fileToZip = fileToZip.Replace("\\", "/");
        zipedPath = zipedPath.Replace("\\", "/");
        //如果文件没有找到，则报错
        if (!File.Exists(fileToZip))
		{
			throw new FileNotFoundException("指定要压缩的文件: " + fileToZip + " 不存在!");
		}
		//文件名称（默认同源文件名称相同）
		string ZipFileName = string.IsNullOrEmpty(zipedFileName) ? zipedPath + "/" + new FileInfo(fileToZip).Name.Substring(0, new FileInfo(fileToZip).Name.LastIndexOf('.')) + ".zip" : zipedPath + "/" + zipedFileName + ".zip";
		using (FileStream ZipFile = File.Create(ZipFileName))
		{
			using (ZipOutputStream ZipStream = new ZipOutputStream(ZipFile))
			{
				using (FileStream StreamToZip = new FileStream(fileToZip, FileMode.Open, FileAccess.Read))
				{
                    string fileName = fileToZip.Substring(fileToZip.LastIndexOf("/") + 1);
                    ZipEntry ZipEntry = new ZipEntry(fileName);
					if (isEncrypt)
					{
						//压缩文件加密
						ZipStream.Password = "cc";
					}
					ZipStream.PutNextEntry(ZipEntry);
					//设置压缩级别
					ZipStream.SetLevel(compressionLevel);
					//缓存大小
					byte[] buffer = new byte[blockSize];
					int sizeRead = 0;
					try
					{
						do
						{
							sizeRead = StreamToZip.Read(buffer, 0, buffer.Length);
							ZipStream.Write(buffer, 0, sizeRead);
						}
						while (sizeRead > 0);
					}
					catch (Exception ex)
					{
						throw ex;
					}
					StreamToZip.Close();
                }
				ZipStream.Finish();
				ZipStream.Close();
			}
			ZipFile.Close();
            if (action != null) { action(); }
        }
    }

    /// <summary>
    /// ZIP：压缩文件夹
    /// </summary>
    /// <param name="directoryToZip">需要压缩的文件夹（绝对路径）</param>
    /// <param name="zipedPath">压缩后的文件路径（绝对路径）</param>
    /// <param name="zipedFileName">压缩后的文件名称（文件名，默认 同源文件夹同名）</param>
    /// <param name="action">压缩后的回调函数</param>
    /// <param name="isEncrypt">是否加密（默认 不加密）</param>
    public static void ZipDirectory(string directoryToZip, string zipedPath, string zipedFileName = "", Action action = null, bool isEncrypt = false)
	{
        ZipConstants.DefaultCodePage = Encoding.UTF8.CodePage;  // 防止中文名乱码 
        //如果目录不存在，则报错
        if (!Directory.Exists(directoryToZip))
		{
			throw new FileNotFoundException("指定的目录: " + directoryToZip + " 不存在!");
		}

		//文件名称（默认同源文件名称相同）
		string ZipFileName = string.IsNullOrEmpty(zipedFileName) ? zipedPath + "/" + new DirectoryInfo(directoryToZip).Name + ".zip" : zipedPath + "/" + zipedFileName + ".zip";
		using (FileStream zipFile = File.Create(ZipFileName))
		{
			using (ZipOutputStream s = new ZipOutputStream(zipFile))
			{
				if (isEncrypt)
				{
					//压缩文件加密
					s.Password = "cc";
				}
				ZipSetp(directoryToZip, s, "");
            }
		}
        if (action != null) { action(); }
    }
    /// <summary>
    /// 递归遍历目录
    /// </summary>
    private static void ZipSetp(string strDirectory, ZipOutputStream s, string parentPath)
	{
		if (strDirectory[strDirectory.Length - 1] != Path.DirectorySeparatorChar)
		{
			strDirectory += Path.DirectorySeparatorChar;
		}
		Crc32 crc = new Crc32();
		string[] filenames = Directory.GetFileSystemEntries(strDirectory);
		foreach (string file in filenames)// 遍历所有的文件和目录
		{
			if (Directory.Exists(file))// 先当作目录处理如果存在这个目录就递归Copy该目录下面的文件
			{
				string pPath = parentPath;
				pPath += file.Substring(file.LastIndexOf("/") + 1);
				pPath += "/";
                ZipSetp(file, s, pPath);
			}
			else // 否则直接压缩文件
			{
				//打开压缩文件
				using (FileStream fs = File.OpenRead(file))
				{
					byte[] buffer = new byte[fs.Length];
					fs.Read(buffer, 0, buffer.Length);

					string fileName = parentPath + file.Substring(file.LastIndexOf("/") + 1);
					ZipEntry entry = new ZipEntry(fileName);

					entry.DateTime = DateTime.Now;
					entry.Size = fs.Length;

					fs.Close();

					crc.Reset();
					crc.Update(buffer);

					entry.Crc = crc.Value;
					s.PutNextEntry(entry);

					s.Write(buffer, 0, buffer.Length);
				}
			}
		}
	}

    /// <summary>
    /// ZIP:解压一个zip文件
    /// </summary>
    /// <param name="zipFile">需要解压的Zip文件（绝对路径,不支持中文路径）</param>
    /// <param name="targetDirectory">解压到的目录(绝对路径,不支持中文路径)</param>
    /// <param name="action">解压后的回调函数</param>
    /// <param name="password">解压密码</param>
    /// <param name="overWrite">是否覆盖已存在的文件</param>
    public static void UnZip(string zipFile, string targetDirectory, Action action = null, string password = "", bool overWrite = true)
	{
        ZipConstants.DefaultCodePage = Encoding.UTF8.CodePage;  // 防止中文名乱码 
        zipFile = zipFile.Replace("\\", "/");
        targetDirectory = targetDirectory.Replace("\\", "/");
        //如果解压到的目录不存在，则报错
        if (!Directory.Exists(targetDirectory))
		{
			throw new FileNotFoundException("指定的目录: " + targetDirectory + " 不存在!");
		}
		//目录结尾
		if (!targetDirectory.EndsWith("/"))
		{
            targetDirectory = targetDirectory + "/"; 
		}
		using (ZipInputStream zipfiles = new ZipInputStream(File.OpenRead(zipFile)))
		{
            if (password != "")
            {
                //解压密码
                zipfiles.Password = password;
            }
            ZipEntry theEntry;
			while ((theEntry = zipfiles.GetNextEntry()) != null)
			{
				string directoryName = "";
				string pathToZip = "";
				pathToZip = theEntry.Name;
				if (pathToZip != "")
					directoryName = Path.GetDirectoryName(pathToZip) + "/";

				string fileName = Path.GetFileName(pathToZip);
				Directory.CreateDirectory(targetDirectory + directoryName);
				if (fileName != "")
				{
					if ((File.Exists(targetDirectory + directoryName + fileName) && overWrite) || (!File.Exists(targetDirectory + directoryName + fileName)))
					{
						using (FileStream streamWriter = File.Create(targetDirectory + directoryName + fileName))
						{
							int size = 2048;
							byte[] data = new byte[2048];
							while (true)
							{
								size = zipfiles.Read(data, 0, data.Length);
								if (size > 0)
									streamWriter.Write(data, 0, size);
								else
									break;
							}
							streamWriter.Close();
                        }
					}
				}
			}
			zipfiles.Close();
            if (action != null) { action(); }
        }
    }

}