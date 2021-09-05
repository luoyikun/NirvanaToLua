using ICSharpCode.SharpZipLib.Zip;
using Nirvana;
using System;
using System.IO;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using LuaInterface;

class UnzipAssetBundle
{
    private Dictionary<string, List<string>> zipDic = new Dictionary<string, List<string>>();
    private Queue<string> zipQueue = new Queue<string>();

    private string unzipDir;
    private LinkedListNode<Action> updateHandle;
    private Action unzipFinishCallback;
    private UnzipAssetBundleView view = new UnzipAssetBundleView();

    public void Start(Action finishCallback)
    {
        this.unzipFinishCallback = finishCallback;

        this.unzipDir = Path.Combine(Application.persistentDataPath, EncryptMgr.GetEncryptPath("BundleCache"));
        if (!Directory.Exists(this.unzipDir))
        {
            Directory.CreateDirectory(this.unzipDir);
        }

        // 已经解压过将不再解压
        if (File.Exists(Path.Combine(this.unzipDir, "unziped.txt")))
        {
            this.unzipFinishCallback();
            return;
        }

        if (!this.ReadZipList())
        {
            this.unzipFinishCallback();
            return;
        }

        this.CrateDirectorys();
        this.StartUnZipAllFile();
    }

    public void Dispose()
    {
        if (null != this.updateHandle)
        {
            Scheduler.RemoveFrameListener(this.updateHandle);
            this.updateHandle = null;
        }
    }

    private bool ReadZipList()
    {
        this.zipDic.Clear();

        var data = StreamingAssets.ReadAllText("zip_list.txt");
        var lines = data.Split('\n');
        foreach (var line in lines)
        {
            string[] ary = line.Split(' ');
            if (ary.Length != 2)
            {
                continue;
            }

            string zip_file = ary[0];
            string asset_bundle_file = ary[1].Replace("AssetBundle/", "");

            List<string> asset_bundle_list;
            if (!this.zipDic.TryGetValue(zip_file, out asset_bundle_list))
            {
                asset_bundle_list = new List<string>();
                this.zipDic.Add(zip_file, asset_bundle_list);
                this.zipQueue.Enqueue(zip_file);
            }
            asset_bundle_list.Add(asset_bundle_file);
        }

        return this.zipDic.Count > 0;
    }

    private void CrateDirectorys()
    {
        Debugger.Log(string.Format("[UnzipAssetBundle] Start CrateFolders: {0}", this.unzipDir));

        StringBuilder path_builder = new StringBuilder();

        foreach (var item in this.zipDic)
        {
            List<string> list = item.Value;
            foreach (var path in list)
            {
                string[] ary = path.Split('/');

                path_builder.Remove(0, path_builder.Length);
                path_builder.Append(this.unzipDir);
                for (int i = 0; i < ary.Length - 1; i++)
                {
                    path_builder.Append("/" + ary[i]);
                    if (!Directory.Exists(path_builder.ToString()))
                    {
                        Directory.CreateDirectory(path_builder.ToString());
                    }
                }
            }
        }
    }

    private void StartUnZipAllFile()
    {
        Debugger.Log("[UnzipAssetBundle] start unzip all file");
        this.view.Open();
        this.view.SetProgress(0, 100);

        this.updateHandle = Scheduler.AddFrameListener(()=>
        {
            for (int i = 0; i < 2; i++)
            {
                if (0 == this.zipQueue.Count)
                {
                    OnUnZipAllFileSucc();
                    return;
                }

                bool is_succ = false;
                string zip_file = this.zipQueue.Dequeue();
                this.UnzipFile(Path.Combine(Application.streamingAssetsPath, zip_file),
                                this.unzipDir,
                                "",
                                out is_succ);

                this.view.SetProgress(this.zipDic.Count - this.zipQueue.Count, this.zipDic.Count);
                if (!is_succ)
                {
                    this.OnUnZipFileFail(zip_file);
                }
            }
        });
    }

    private void OnUnZipFileFail(string zipFile)
    {
        Debugger.LogError(string.Format("[UnZipAllFile] unzip fail {0}", zipFile));
        if (null != this.updateHandle)
        {
            Scheduler.RemoveFrameListener(this.updateHandle);
            this.updateHandle = null;
        }
    }

    private void OnUnZipAllFileSucc()
    {
        Debugger.Log("[UnZipAllFile] unzip succ");
        File.WriteAllText(Path.Combine(this.unzipDir, "unziped.txt"), this.zipDic.Count.ToString());
        this.view.Close();

        if (null != this.updateHandle)
        {
            Scheduler.RemoveFrameListener(this.updateHandle);
            this.updateHandle = null;
        }

        if (null != this.unzipFinishCallback)
        {
            this.unzipFinishCallback();
        }
    }

    public void UnzipFile(string zipFile, string folder, string passWord, out bool isSucc)
    {
        ZipInputStream s = null;
        ZipEntry theEntry = null;

        string fileName;
        FileStream streamWriter = null;
        try
        {
            s = new ZipInputStream(File.OpenRead(zipFile));
            s.Password = passWord;
            while ((theEntry = s.GetNextEntry()) != null)
            {
                if (theEntry.Name != String.Empty)
                {
                    fileName = Path.Combine(folder, theEntry.Name.Replace("AssetBundle/", ""));
                    //Debugger.Log(String.Format("[UnZipAllFile] UnzipFile: {0}", fileName));
                    
                    streamWriter = File.Create(fileName);
                    int size = 2048;
                    byte[] data = new byte[2048];
                    while (true)
                    {
                        size = s.Read(data, 0, data.Length);
                        if (size > 0)
                        {
                            streamWriter.Write(data, 0, size);
                        }
                        else
                        {
                            break;
                        }
                    }
                }
            }

            isSucc = true;
        }
        catch(Exception ex)
        {
            Debug.LogError(ex.Message);
            isSucc = false;
        }
        finally
        {
            if (streamWriter != null)
            {
                streamWriter.Close();
                streamWriter = null;
            }
            if (theEntry != null)
            {
                theEntry = null;
            }
            if (s != null)
            {
                s.Close();
                s = null;
            }
            GC.Collect();
            GC.Collect(1);
        }
    }
}

