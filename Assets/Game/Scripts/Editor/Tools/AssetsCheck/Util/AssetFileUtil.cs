using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace AssetsCheck
{
    class AssetFileUtil
    {
        public static void GetAllFileInDir(string path, List<string> fileLlist, string extension)
        {
            DirectoryInfo dir = new DirectoryInfo(path);
            FileInfo[] files = dir.GetFiles();
            DirectoryInfo[] dirs = dir.GetDirectories();
            foreach (FileInfo f in files)
            {
                if (f.Extension == extension)
                {
                    fileLlist.Add(f.FullName);//添加文件路径到列表中  
                }
            }

            foreach (DirectoryInfo d in dirs)
            {
                GetAllFileInDir(d.FullName, fileLlist, extension);
            }
        }
    }
}
