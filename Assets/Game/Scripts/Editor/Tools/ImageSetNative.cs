using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class ImageSetNative : BaseEditorWindow
{
    private List<GameObject> list = new List<GameObject>();
    private Vector2 scrollerPos = new Vector2();
    private Sprite oldImage;
    private Sprite newImage;
    private bool needChangeSprite = false;
    private bool advance = true;
    private int imageType = 0;
    private bool isMirror = false;
    private int mirrorMode = 0;
    private Vector2 imageSize = new Vector2();
    private bool changeSize = true;
    private Object selectObj;
    private enum ImageType
    {
        Simple, Sliced
    }
    private enum MirrorMode
    {
        Horizontal, Vertical, Quad
    }
    [MenuItem("自定义工具/替换图片")]

    private static void ShowWindow()
    {
        EditorWindow.GetWindow<ImageSetNative>(false, "替换图片");
    }

    private void OnGUI()
    {
        OldImage = EditorGUILayout.ObjectField("OldImage: ", OldImage, typeof(Sprite), true) as Sprite;
        NeedChangeSprite = EditorGUILayout.ToggleLeft("NeedChangeImage: ", NeedChangeSprite);
        if (NeedChangeSprite)
        {
            NewImage = EditorGUILayout.ObjectField("NewImage: ", NewImage, typeof(Sprite), true) as Sprite;
        }
        changeSize = EditorGUILayout.ToggleLeft("ChangeSize: ", changeSize);
        if (!changeSize)
            GUI.enabled = false;
        imageSize = EditorGUILayout.Vector2Field("ImageSize: ", imageSize);
        GUI.enabled = true;
        GUILayout.Space(10);
        advance = GUILayout.Toggle(advance, new GUIContent("Advance: "), EditorStyles.foldout);
        if (advance)
        {
            GUILayout.BeginVertical(EditorStyles.inspectorDefaultMargins);
            GUILayout.Space(10);
            imageType = EditorGUILayout.IntPopup("ImageType: ", imageType, new string[] { "Simple", "Sliced" },  new int[] { 0, 1 });
            if (imageType == (int)ImageType.Simple)
            {
                isMirror = EditorGUILayout.Toggle("IsMirror: ", isMirror);
                if (isMirror)
                {
                    GUILayout.BeginVertical(EditorStyles.inspectorDefaultMargins);
                    mirrorMode = EditorGUILayout.IntPopup("MirrorMode: ", mirrorMode, new string[] { "Horizontal", "Vertical", "Quad" }, new int[] { 0, 1, 2 });
                    GUILayout.EndVertical();
                }
            }
            GUILayout.EndVertical();
        }
        GUILayout.Space(10);
        if (GUILayout.Button("ChangeAll"))
        {
            if (CheckSetting())
                ChangeAll();
        }

        scrollerPos = EditorGUILayout.BeginScrollView(scrollerPos);
        for (int i = 0; i < list.Count; ++i)
        {
            var obj = list[i];
            if (null == obj)
            {
                list.Remove(obj);
                break;
            }
            var style = EditorStyles.textField;
            if (obj == this.selectObj)
                style = EditorStyles.whiteLabel;
            if (GUILayout.Button(obj.name, style))
            {
                this.selectObj = obj;
                PingObj(obj);
            }
        }
        EditorGUILayout.EndScrollView();
    }

    public void ChangeAll()
    {
        if (null != list)
            list.Clear();
        SearchAll();
        AssetDatabase.SaveAssets();
    }

    private bool CheckSetting()
    {
        if (null == oldImage)
        {
            this.ShowNotification(new GUIContent("OldImage为空"));
            return false;
        }
        if (needChangeSprite && null == newImage)
        {
            this.ShowNotification(new GUIContent("NewImage为空"));
            return false;
        }
        return true;
    }

    private void SearchAll()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs/Views" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.Check(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("替换中", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void Check(GameObject obj)
    {
        var images = obj.GetComponentsInChildren<Image>(true);
        for (int i = 0; i < images.Length; ++i)
        {
            var image = images[i];
            if (image.sprite == oldImage)
            {
                if (needChangeSprite)
                {
                    image.sprite = newImage;
                }

                var mirror = image.gameObject.GetComponent<Nirvana.UIImageMirror>();
                if (imageType == (int)ImageType.Sliced)
                {
                    if (null != mirror)
                    {
                        GameObject.DestroyImmediate(mirror, true);
                    }
                    image.type = Image.Type.Sliced;
                }
                else if (imageType == (int)ImageType.Simple)
                {
                    image.type = Image.Type.Simple;
                    if (isMirror)
                    {
                        if (null == mirror)
                        {
                            mirror = image.gameObject.AddComponent<Nirvana.UIImageMirror>();
                        }
                        mirror.enabled = true;
                        if (mirrorMode == (int)MirrorMode.Horizontal)
                        {
                            mirror.MirrorMode = Nirvana.UIImageMirror.MirrorModeType.Horizontal;
                        }
                        else if (mirrorMode == (int)MirrorMode.Vertical)
                        {
                            mirror.MirrorMode = Nirvana.UIImageMirror.MirrorModeType.Vertical;
                        }
                        else if (mirrorMode == (int)MirrorMode.Quad)
                        {
                            mirror.MirrorMode = Nirvana.UIImageMirror.MirrorModeType.Quad;
                        }
                    }
                    else
                    {
                        if (null != mirror)
                        {
                            GameObject.DestroyImmediate(mirror, true);
                        }
                    }
                }
                if (changeSize)
                    image.rectTransform.sizeDelta = imageSize;
                PrefabUtility.ResetToPrefabState(image.gameObject);
                PrefabUtility.SetPropertyModifications(image.gameObject, new PropertyModification[] { });
                list.Add(image.gameObject);
            }
        }
    }

    private void UpdateImageSize()
    {
        if (needChangeSprite)
        {
            if (null != newImage)
            {
                imageSize = new Vector2(newImage.rect.width, newImage.rect.height);
            }
        }
        else
        {
            if (null != oldImage)
            {
                imageSize = new Vector2(oldImage.rect.width, oldImage.rect.height);
            }
        }
    }

    private Sprite OldImage
    {
        set
        {
            if (oldImage != value)
            {
                oldImage = value;
                UpdateImageSize();
            }
        }
        get
        {
            return oldImage;
        }
    }

    private Sprite NewImage
    {
        set
        {
            if (newImage != value)
            {
                newImage = value;
                UpdateImageSize();
            }
        }
        get
        {
            return newImage;
        }
    }

    private bool NeedChangeSprite
    {
        get
        {
            return needChangeSprite;
        }
        set
        {
            if (needChangeSprite != value)
            {
                needChangeSprite = value;
                UpdateImageSize();
            }
        }
    }
}
