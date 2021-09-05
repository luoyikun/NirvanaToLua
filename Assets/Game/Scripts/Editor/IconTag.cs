using System.IO;
using UnityEditor;
using UnityEngine;

public static class IconTag
{
    [MenuItem("Nirvana/Mark Item Icon Tag")]
	private static void MarkIconTag()
    {
        var guids = AssetDatabase.FindAssets(
            "t:texture", 
            new string[] { "Assets/Game/UIs/Icons/Item" });
        foreach (var guid in guids)
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var importer = AssetImporter.GetAtPath(path) as TextureImporter;
            if (importer != null)
            {
                var name = Path.GetFileNameWithoutExtension(path);
                var tag = string.Format("icons/item/{0}", name);
                importer.spritePackingTag = tag;
                importer.SaveAndReimport();
            }
        }
	}
}
