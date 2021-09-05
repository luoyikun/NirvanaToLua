using UnityEngine;
using UnityEditor;

class GenericAssetImporter : AssetPostprocessor
{
    static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
    {
        foreach (var importedAsset in importedAssets)
        {
            AssetBundleMarkRule.MarkAssetBundle(importedAsset);
        }

        foreach (var movedAsset in movedAssets)
        {
            AssetBundleMarkRule.MarkAssetBundle(movedAsset);
        }
    }
}
