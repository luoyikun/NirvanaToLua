using UnityEngine;
using UnityEditor;

public static class ImporterUtils
{
    public static string IgnoreImportedLabel = "IgnoreImportRule";
    public static string ReadableLabel = "Readable";

    public static bool IsIgnoreImportRule(Object obj)
    {
        var labels = AssetDatabase.GetLabels(obj);
        foreach (var label in labels)
        {
            if (label == IgnoreImportedLabel)
            {
                return true;
            }
        }

        return false;
    }

    public static bool CheckLabel(string assetPath)
    {
        return CheckLabel(AssetDatabase.LoadMainAssetAtPath(assetPath));
    }

    public static bool CheckLabel(string assetPath, string lable)
    {
        return CheckLabel(AssetDatabase.LoadMainAssetAtPath(assetPath));
    }

    public static bool CheckLabel(Object obj, string lable = "")
    {
        lable = string.IsNullOrEmpty(lable) ? IgnoreImportedLabel : lable;

        var labels = AssetDatabase.GetLabels(obj);
        foreach (var label in labels)
        {
            if (label == lable)
            {
                return true;
            }
        }

        return false;
    }

    public static void SetLabel(string assetPath, string lable = "")
    {
        SetLabel(AssetDatabase.LoadMainAssetAtPath(assetPath), lable);
    }

    public static void SetLabel(Object obj, string lable = "")
    {
        if (obj == null)
        {
            return;
        }

        lable = string.IsNullOrEmpty(lable) ? IgnoreImportedLabel : lable;

        var labels = AssetDatabase.GetLabels(obj);
		var newLabels = new string[labels.Length + 1];
		bool hasLabel = false;
		
        for (int i = 0; i < labels.Length; ++i)
        {
			if (labels[i] == lable)
			{
				hasLabel = true;
				break;
			}
            newLabels[i] = labels[i];
        }
		
		if (!hasLabel)
		{
			newLabels[labels.Length] = lable;

			AssetDatabase.SetLabels(obj, newLabels);
			EditorUtility.SetDirty(obj);
		}
    }

    public static void ClearLabel(string path)
    {
        ClearLabel(AssetDatabase.LoadMainAssetAtPath(path));
    }

    public static void ClearLabel(Object obj)
    {
        AssetDatabase.SetLabels(obj, new string[] { });
        EditorUtility.SetDirty(obj);
    }
}