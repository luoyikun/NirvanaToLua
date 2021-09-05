using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using Nirvana.Editor;
using System;

// 打包图集，输出文件到工程下的UIAltas下
public class AtlasPackerWindow : EditorWindow
{
    // 指定要检查的文件夹
    private string[] checkDirs = new string[1];

    private string fileName = "";
    
    private UnityEngine.Object targetFile;

    [MenuItem("自定义工具/资源检查/打包图集")]
    public static void ShowAltasPacker()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(AtlasPackerWindow));
        window.titleContent = new GUIContent("AltasPacker");
    }

    private void OnGUI()
    {
        if (GUILayout.Button("StartPackAll"))
        {
            checkDirs = new string[] { "Assets/Game/UIs/Views/ActivityView/Images",
                                        "Assets/Game/UIs/Views/AdvanceView/Images"};
            AtlasPacker packer = new AtlasPacker();
            packer.StartPack(checkDirs);
        }

        EditorGUILayout.Space();
        targetFile = EditorGUILayout.ObjectField("添加文件:", targetFile, typeof(UnityEngine.Object), true) as UnityEngine.Object;

        if (GUILayout.Button("StartPackByFile"))
        {
            if (null == targetFile)
            {
                this.ShowNotification(new GUIContent("请选择正确的文件夹!"));
                return;
            }

            checkDirs[0] = AssetDatabase.GetAssetPath(targetFile);
            if (Directory.Exists(checkDirs[0]))
            {
                this.ShowNotification(new GUIContent("请选择正确的文件夹!"));
            }

            AtlasPacker packer = new AtlasPacker();
            packer.StartPack(checkDirs);
        }
    }
}

public struct AltasPackRecordItem
{
    public string packTag;
    public int totalSize;
    public int altasWidth;
    public int altasHeight;
}

public class AtlasPacker
{
    public struct PackItem
    {
        public string packTag;
        public List<string> assets;
    }


    private int maxWidth = 2048;
    private int maxHeight = 2048;
    private string[] checkDirs = new string[1];
    private Dictionary<string, AltasPackRecordItem> recordDic = new Dictionary<string, AltasPackRecordItem>();

    public void ReadRecods(Dictionary<string, AltasPackRecordItem> recordDic)
    {
        string path = Path.Combine(Application.dataPath, "../AssetsCheck/UIAltas/record.txt");
        if (!File.Exists(path))
        {
            return;
        }

        string[] lines = File.ReadAllLines(path);
        for (int i = 0; i < lines.Length; i++)
        {
            string[] ary = lines[i].Split(' ');
            AltasPackRecordItem item = new AltasPackRecordItem();
            item.packTag = ary[0];
            item.totalSize = Convert.ToInt32(ary[1]);
            item.altasWidth = Convert.ToInt32(ary[2]);
            item.altasHeight = Convert.ToInt32(ary[3]);
            recordDic.Add(item.packTag, item);
        }
    }

    private void WriteRecords()
    {
        string path = Path.Combine(Application.dataPath, "../AssetsCheck/UIAltas/record.txt");
        List<string> list = new List<string>();
        foreach (var item in recordDic)
        {
            list.Add(string.Format("{0} {1} {2} {3}", item.Value.packTag, item.Value.totalSize, item.Value.altasWidth, item.Value.altasHeight));
        }

        File.WriteAllLines(path, list.ToArray());
    }


    public void StartPack(string[] checkDirs)
    {
        recordDic.Clear();
        ReadRecods(recordDic);

        this.checkDirs = checkDirs;
        Debug.Log("Start pack");

        Dictionary<string, List<string>> texturesDic = new Dictionary<string, List<string>>();
        this.GetPackTextureDic(texturesDic);
        this.FilterPackTextures(texturesDic);
        this.ExcutePackTextures(texturesDic);
        this.WriteRecords();

        Debug.Log("pack complete");
    }

    private void GetPackTextureDic(Dictionary<string, List<string>> dic)
    {
        string[] guides = AssetDatabase.FindAssets("t:texture2d", checkDirs);
        foreach (var guid in guides)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
            if (string.IsNullOrEmpty(importer.spritePackingTag))
            {
                continue;
            }

            List<string> list;
            if (!dic.TryGetValue(importer.spritePackingTag, out list))
            {
                list = new List<string>();
                dic.Add(importer.spritePackingTag, list);
            }

            list.Add(path);
        }
    }

    private void FilterPackTextures(Dictionary<string, List<string>> dic)
    {
        List<string> filters = new List<string>();

        foreach (var kv in dic)
        {
            if (kv.Key.StartsWith("uis/images"))
            {
                filters.Add(kv.Key);
                continue;
            }

            if (recordDic.ContainsKey(kv.Key))
            {
                int total_size = 0;
                List<string> texture_list = kv.Value;
                for (int i = 0; i < texture_list.Count; i++)
                {
                    Texture2D texture2d = AssetDatabase.LoadAssetAtPath<Texture2D>(texture_list[i]);
                    if (null != texture2d)
                    {
                        total_size += (texture2d.width * texture2d.height);
                    }
                }

                if (total_size == recordDic[kv.Key].totalSize)
                {
                    filters.Add(kv.Key);
                }
            }
        }

        foreach (var item in filters)
        {
            dic.Remove(item);
        }
    }

    private void ExcutePackTextures(Dictionary<string, List<string>> dic)
    {
        Queue<PackItem> pack_queue = new Queue<PackItem>();
        foreach (var item in dic)
        {
            PackItem pack_item = new PackItem();
            pack_item.packTag = item.Key;
            pack_item.assets = item.Value;
            pack_queue.Enqueue(pack_item);
        }

        StepPackTextures(pack_queue);
    }

    private void StepPackTextures(Queue<PackItem> packQueue)
    {
        if (packQueue.Count <= 0)
        {
            Debug.Log("Pack Complete");
            return;
        }

        PackItem pack_item = packQueue.Dequeue();
        List<string> path_list = pack_item.assets;
        List<Texture2D> texture_list = new List<Texture2D>();

        AltasPackRecordItem record_item = new AltasPackRecordItem();
        record_item.packTag = pack_item.packTag;

        for (int i = 0; i < path_list.Count; i++)
        {
            TextureImporter importer = AssetImporter.GetAtPath(path_list[i]) as TextureImporter;
            Texture2D texture2d = AssetDatabase.LoadAssetAtPath<Texture2D>(path_list[i]);
            if (null == importer || null == texture2d)
            {
                continue;
            }

            importer.hideFlags = HideFlags.NotEditable;
            importer.isReadable = true;
            importer.textureCompression = TextureImporterCompression.Uncompressed;
            importer.SaveAndReimport();
            texture_list.Add(texture2d);

            record_item.totalSize += texture2d.width * texture2d.height;
        }

        try
        {
            // 打包图集并保存
            if (texture_list.Count > 1) // 大于1才打图集
            {
                Debug.Log("pack: " + pack_item.packTag);
                Texture2D altas = new Texture2D(maxWidth, maxHeight, TextureFormat.RGBA32, false);
                altas.PackTextures(texture_list.ToArray(), 0, 2048);
                this.SaveAltasTexture(pack_item.packTag, altas);

                record_item.altasWidth = altas.width;
                record_item.altasHeight = altas.height;
                
                if (recordDic.ContainsKey(record_item.packTag))
                {
                    recordDic.Remove(record_item.packTag);
                }
                recordDic.Add(record_item.packTag, record_item);
            }
        }
        catch (System.Exception)
        {
            Debug.Log("pack fail: " + pack_item.packTag);
            throw;
        }
        finally
        {
            for (int i = 0; i < path_list.Count; i++)
            {
                TextureImporter importer = AssetImporter.GetAtPath(path_list[i]) as TextureImporter;
                importer.isReadable = false;                 // 重设isReadable为false
                importer.hideFlags = HideFlags.None;
                importer.textureCompression = TextureImporterCompression.Compressed;
                importer.SaveAndReimport();
            }

            StepPackTextures(packQueue);
        }
    }

    private void SaveAltasTexture(string packtag, Texture2D altas)
    {
        string dir = Path.Combine(Application.dataPath, "../AssetsCheck/UIAltas");
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        string name = packtag.Replace("/", "_");

        var files = Directory.GetFiles(dir);
        foreach (var file in files)
        {
            FileInfo file_info = new FileInfo(file);

            string file_name = file_info.Name;
            file_name = file_name.Substring(file_name.IndexOf("_") + 1).TrimEnd(".png".ToCharArray());
            if (file_name == name)
            {
                File.Delete(file);
            }
        }

        byte[] bytes = altas.EncodeToPNG();
        File.WriteAllBytes(Path.Combine(dir, string.Format("{0}x{1}_{2}.png", altas.width, altas.height, name)), bytes);
    }
}
