using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public partial class CheckResources
{
    void TextureWindow(int toolbarID)
    {
        KeyWorldModuleWindow(CheckSpriteInFolder);
        EditorGUILayout.HelpBox("遍历目录下的所有预制体的Image组件，查询Sprite名字是否包含关键词，保存在存储目录中", MessageType.Info);
    }

    private void CheckSpriteInFolder(DirectoryInfo dir)
    {
        var files = dir.GetFiles("*.prefab");
        if (files.Length > 0)
        {
            foreach (var file in files)
            {
                StringBuilder sb = new StringBuilder();
                sb.AppendLine(file.FullName);
                sb.AppendLine();
                if (CheckSpriteInFile(file, sb, sign))
                {
                    string[] catalogue = search_Dir_Path.Split('/');
                    int index = file.FullName.IndexOf(catalogue[catalogue.Length - 1]);
                    string validPath = file.FullName.Substring(index);
                    string allPath = record_Dir_Path + "/" + validPath;
                    string dirPath = allPath.Replace(file.Name, string.Empty);
                    if (!Directory.Exists(dirPath))
                    {
                        Directory.CreateDirectory(dirPath);
                    }
                    string recordPath = dirPath + file.Name.Replace("prefab", "txt");
                    File.WriteAllText(recordPath, sb.ToString());
                }
            }
        }

        var dirs = dir.GetDirectories();
        if (dirs.Length > 0)
        {
            foreach (var element in dirs)
            {
                CheckSpriteInFolder(element);
            }
        }
    }

    private bool CheckSpriteInFile(FileInfo file, StringBuilder sb, List<string> sign)
    {
        string fullPath = file.FullName.Replace("\\", "/");
        int index = fullPath.IndexOf("Assets/");
        string loadPath = fullPath.Substring(index);
        var go = AssetDatabase.LoadAssetAtPath<GameObject>(loadPath);
        if (go == null)
        {
            return false;
        }
        bool isExist = false;
        var images = go.GetComponentsInChildren<Image>(true);
        foreach (var image in images)
        {
            foreach (var keyword in sign)
            {
                string name = image.sprite ? image.sprite.name : string.Empty;
                if (name.Contains(keyword))
                {
                    string catalogue = GetNameByHierarchy(image.gameObject, "/");
                    sb.AppendLine(keyword + " --- " + catalogue);
                    isExist = true;
                }
            }
        }
        return isExist;

    }
}
