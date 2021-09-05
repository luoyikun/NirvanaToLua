using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using Nirvana.Editor;

// 打包图集，输出文件到工程下的UIAltas下
public class AltasPacker : EditorWindow
{
    // 指定要检查的文件夹
    private string[] checkDirs = new string[1];

    private string fileName = "";

    private int maxWidth = 2048;
    private int maxHeight = 2048;

    [MenuItem("自定义工具/打包图集")]
    public static void ShowAltasPacker()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(AltasPacker));
        window.titleContent = new GUIContent("AltasPacker");
    }

    Object tmpFile;

    private void OnGUI()
    {
        if (GUILayout.Button("StartPackAll"))
        {
            checkDirs[0] = "Assets/Game/UIs/Views";
            this.StartPack();
        }

        EditorGUILayout.Space();
        tmpFile = EditorGUILayout.ObjectField("添加文件(View文件下):", tmpFile, typeof(Object), true) as Object;

        if (GUILayout.Button("StartPackByFile"))
        {
            if (tmpFile == null)
            {
                this.ShowNotification(new GUIContent("请选择正确的文件夹!"));
                return;
            }
            fileName = tmpFile.name;
            fileName = "Assets/Game/UIs/Views/" + fileName;
            checkDirs[0] = fileName;
            if (Directory.Exists(checkDirs[0]))
            { this.StartPack(); }
            else
            {
                this.ShowNotification(new GUIContent("请选择正确的文件夹!"));
            }
        }
    }

    private void StartPack()
    {
        Debug.Log("Start pack");
        // 因为下面要设置isreadable。会受到importrule的影响
        this.SetImportRuleCanProcess(false);

        Dictionary<string, List<string>> texturesDic = new Dictionary<string, List<string>>();
        this.GetPackTextureDic(texturesDic);
        this.ExcutePackTextures(texturesDic);

        // 重置导入规则
        this.SetImportRuleCanProcess(true);

        Debug.Log("pack complete");
    }

    private void SetImportRuleCanProcess(bool value)
    {
        var guids = AssetDatabase.FindAssets("t:AssetImportRule");
        for (int i = 0; i < guids.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[i]);
            AssetImportRule import_rule = AssetDatabase.LoadAssetAtPath<AssetImportRule>(path);
            if (null != import_rule)
            {
                import_rule.SetIsCanProcess(value);
            }
        }
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

    private void ExcutePackTextures(Dictionary<string, List<string>> dic)
    {
        foreach (var item in dic)
        {
            // 加载纹理并设置isReadable为true
            List<string> path_list = item.Value;
            List<Texture2D> texture_list = new List<Texture2D>();

            for (int i = 0; i < path_list.Count; i++)
            {
                TextureImporter importer = AssetImporter.GetAtPath(path_list[i]) as TextureImporter;
                Texture2D texture2d = AssetDatabase.LoadAssetAtPath<Texture2D>(path_list[i]);
                if (null == importer || null == texture2d)
                {
                    continue;
                }

                importer.isReadable = true;
                importer.SaveAndReimport();
                texture_list.Add(texture2d);
            }

            // 打包图集并保存
            try
            {
                if (texture_list.Count > 1) // 大于1才打图集
                {
                    // 打包图集
                    Texture2D altas = new Texture2D(maxWidth, maxHeight, TextureFormat.RGBA32, false);
                    altas.PackTextures(texture_list.ToArray(), 0);
                    this.SaveAltasTexture(item.Key, altas);
                }
            }
            catch (System.Exception)
            {
                throw;
            }

            // 重设isReadable为false
            for (int i = 0; i < path_list.Count; i++)
            {
                TextureImporter importer = AssetImporter.GetAtPath(path_list[i]) as TextureImporter;
                importer.isReadable = false;
                importer.SaveAndReimport();
            }
        }
    }

    private void SaveAltasTexture(string packtag, Texture2D altas)
    {
        string dir = Path.Combine(Application.dataPath, "../UIAltas");
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        string[] ary = packtag.Split('/');
        string name = ary[ary.Length - 1];

        var files = Directory.GetFiles(dir);
        foreach (var fileName in files)
        {
            string spriteName = fileName.Substring(fileName.LastIndexOf("_") + 1).TrimEnd(".png".ToCharArray());
            if (spriteName == name)
            {
                File.Delete(fileName);
            }
        }

        File.WriteAllBytes(Path.Combine(dir, string.Format("{0}x{1}_{2}.png", altas.width, altas.height, name)),
                                    altas.EncodeToPNG());
    }
}
