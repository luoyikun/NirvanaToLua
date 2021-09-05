using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEditor;
using UnityEngine.UI;
using System.Xml;
using System.Xml.Serialization;
using System.Xml.Xsl;
using System.Xml.Schema;
using System.IO;

public class SpriteManager : BaseEditorWindow
{
    private SerializableDictionary<string, SpriteObject> dic;
    private Sprite selectSprite;
    private SpriteObject selectData = SpriteObject.Null;
    private string guid;
    private string note;
    private int label_1;
    private int label_2;
    private int label_3;
    private bool isEditor = false;
    private string selectSpriteGuid;

    private string keyWord;
    private int searchLabel_1 = -1;
    private int searchLabel_2 = -1;
    private int searchLabel_3 = -1;
    private List<SpriteObject> list = new List<SpriteObject>();
    private List<GameObject> unregisteredObjectList = new List<GameObject>();
    private List<Sprite> unregisteredSpriteList = new List<Sprite>();
    private Vector2 scrollPos = Vector2.zero;
    private Vector2 unregisteredScrollPos = Vector2.zero;
    private UnityEngine.Object selectUnRegisteredObject;
    private int searchType = 0;

    private static string[] labels_1 = { "通用", "不通用" };
    private static string[] labels_2 = { "背景", "按钮or开关", "图标", "其它", "进度条", "文字", "标题or标签" };
    private static string[] labels_3 = { "普通", "镜像", "九宫格" };
    private static string path = "Assets/Game/UIs/sprite.xml";
    private int totalPage = 0;
    private int curPage = 0;
    private int everyPageCount = 20;
    private int inputPage = 0;
    private uint oldMD5;

    [MenuItem("自定义工具/图片管理")]
    private static void ShowWindow()
    {
        Rect wr = new Rect(0, 0, 500, 800);
        EditorWindow.GetWindowWithRect<SpriteManager>(wr, false, "图片管理");
    }

    private void OnEnable()
    {
        if (!File.Exists(path))
        {
            using (FileStream fileStream = new FileStream(path, FileMode.Create))
            {
                this.dic = new SerializableDictionary<string, SpriteObject>();
                XmlSerializer xmlFormatter = new XmlSerializer(typeof(SerializableDictionary<string, SpriteObject>));
                xmlFormatter.Serialize(fileStream, this.dic);
            }
        }
        else
        {
            using (FileStream fileStream = new FileStream(path, FileMode.Open))
            {
                XmlSerializer xmlFormatter = new XmlSerializer(typeof(SerializableDictionary<string, SpriteObject>));
                this.dic = (SerializableDictionary<string, SpriteObject>)xmlFormatter.Deserialize(fileStream);
            }
            this.oldMD5 = MD5.GetMD5FromFile(path);
        }
    }
    private void OnGUI()
    {
        this.SelectSprite = EditorGUILayout.ObjectField("Select Sprite: ", this.SelectSprite, typeof(Sprite), true, GUILayout.Height(150f)) as Sprite;
        if (null != SelectSprite)
        {
            this.isEditor = EditorGUILayout.ToggleLeft("Editor: ", this.isEditor);
            if (this.isEditor)
            {
                note = EditorGUILayout.TextField(note);
                this.label_1 = EditorGUILayout.IntPopup("标签1: ", this.label_1, labels_1, new int[] { 0, 1 });
                this.label_2 = EditorGUILayout.IntPopup("标签2: ", this.label_2, labels_2, new int[] { 0, 1, 2, 3, 4, 5, 6 });
                this.label_3 = EditorGUILayout.IntPopup("标签3: ", this.label_3, labels_3, new int[] { 0, 1, 2 });
                if (GUILayout.Button("Save"))
                {
                    this.Save(this.guid, this.note, this.label_1, this.label_2, this.label_3);
                    this.isEditor = false;
                    this.selectData = this.GetValue(this.guid);
                }
            }
            else
            {
                if (!this.selectData.isNull())
                {
                    EditorGUILayout.LabelField("说明: " + this.selectData.note);
                    EditorGUILayout.LabelField("标签1: " + labels_1[this.selectData.label_1]);
                    EditorGUILayout.LabelField("标签2: " + labels_2[this.selectData.label_2]);
                    EditorGUILayout.LabelField("标签3: " + labels_3[this.selectData.label_3]);
                }
                else
                {
                    EditorGUILayout.LabelField("说明: " );
                    EditorGUILayout.LabelField("标签1: ");
                    EditorGUILayout.LabelField("标签2: ");
                    EditorGUILayout.LabelField("标签3: ");
                }
            }
        }
        else
        {
            EditorGUILayout.LabelField("说明: ");
            EditorGUILayout.LabelField("标签1: ");
            EditorGUILayout.LabelField("标签2: ");
            EditorGUILayout.LabelField("标签3: ");
        }
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("搜索框");
        EditorGUILayout.BeginVertical(EditorStyles.textArea);
        this.keyWord = EditorGUILayout.TextField("KeyWord: ", this.keyWord);
        this.searchLabel_1 = EditorGUILayout.IntPopup("标签1: ", this.searchLabel_1, new string[] { "全部", "通用", "不通用" }, new int[] { -1, 0, 1 });
        this.searchLabel_2 = EditorGUILayout.IntPopup("标签2: ", this.searchLabel_2, new string[] { "全部", "背景", "按钮or开关", "图标", "其它", "进度条", "文字", "标题or标签" }, new int[] { -1, 0, 1, 2, 3, 4, 5, 6 });
        this.searchLabel_3 = EditorGUILayout.IntPopup("标签3: ", this.searchLabel_3, new string[] { "全部", "普通", "镜像", "九宫格" }, new int[] { -1, 0, 1, 2 });
        if (GUILayout.Button("Search"))
        {
            this.scrollPos = Vector2.zero;
            this.Find(this.keyWord, this.searchLabel_1, this.searchLabel_2, this.searchLabel_3);
        }
        if (this.list.Count > 0)
        {
            if (GUILayout.Button("Clean"))
            {
                this.list.Clear();
            }
            this.scrollPos = EditorGUILayout.BeginScrollView(this.scrollPos);
            foreach (var obj in this.list)
            {
                var style = EditorStyles.textField;
                if (obj.guid == this.selectSpriteGuid)
                    style = EditorStyles.whiteLabel;
                if (GUILayout.Button(obj.note, style))
                {
                    var path = AssetDatabase.GUIDToAssetPath(obj.guid);
                    this.SelectSprite = AssetDatabase.LoadAssetAtPath(path, typeof(Sprite)) as Sprite;
                    EditorGUIUtility.PingObject(this.selectSprite);
                    if (null == this.selectSprite)
                    {
                        this.ShowNotification(new GUIContent("Sprite丢失！！！"));
                    }
                }
            }
            EditorGUILayout.EndScrollView();
        }
        EditorGUILayout.EndVertical();
        if (GUILayout.Button("CleanEmptySprite"))
        {
            this.CleanMissingSprite();
        }
        EditorGUILayout.Space();
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("未注册图片搜索");
        this.searchType = EditorGUILayout.IntPopup("搜索类型", this.searchType, new string[] { "Sprite", "Object" }, new int[] { 0, 1 });
        EditorGUILayout.EndHorizontal();
        if (GUILayout.Button("SearchUnregisteredSprite"))
        {
            this.unregisteredObjectList.Clear();
            this.unregisteredSpriteList.Clear();
            this.unregisteredScrollPos = Vector2.zero;
            if (this.searchType == 0)
            {
                this.SearchUnregisteredSprite();
                this.totalPage = this.unregisteredSpriteList.Count / this.everyPageCount;
            }
            else
            {
                this.SearchUnregisteredObject();
                this.totalPage = this.unregisteredObjectList.Count / this.everyPageCount;
            }
            this.curPage = 0;
            this.inputPage = 0;
        }
        if (this.unregisteredObjectList.Count > 0)
        {
            EditorGUILayout.BeginVertical(EditorStyles.textArea);
            EditorGUILayout.LabelField("TotalCount: " + this.unregisteredObjectList.Count + "\tTotalPage: " + this.totalPage);
            if (GUILayout.Button("Clean"))
            {
                this.unregisteredObjectList.Clear();
            }

            this.UpdatePage();
            this.unregisteredScrollPos = EditorGUILayout.BeginScrollView(this.unregisteredScrollPos);
            for (int i = this.curPage * this.everyPageCount; i < Mathf.Min(this.unregisteredObjectList.Count, (this.curPage + 1) * this.everyPageCount); ++i)
            {
                var obj = this.unregisteredObjectList[i];
                if (null == obj)
                {
                    this.unregisteredObjectList.Remove(obj);
                    break;
                }
                var style = EditorStyles.textField;                    
                if (obj == this.selectUnRegisteredObject)
                    style = EditorStyles.whiteLabel;
                if (GUILayout.Button(obj.name, style))
                {
                    this.selectUnRegisteredObject = obj;
                    PingObj(obj);
                }
            }
            EditorGUILayout.EndScrollView();
            EditorGUILayout.EndVertical();
        }
        else if (this.unregisteredSpriteList.Count > 0)
        {
            EditorGUILayout.BeginVertical(EditorStyles.textArea);
            EditorGUILayout.LabelField("TotalCount: " + this.unregisteredSpriteList.Count + "\tTotalPage: " + this.totalPage);
            if (GUILayout.Button("Clean"))
            {
                this.unregisteredSpriteList.Clear();
            }

            this.UpdatePage();
            this.unregisteredScrollPos = EditorGUILayout.BeginScrollView(this.unregisteredScrollPos);
            for (int i = this.curPage * this.everyPageCount; i < Mathf.Min(this.unregisteredSpriteList.Count, (this.curPage + 1) * this.everyPageCount); ++i)
            {
                var sprite = this.unregisteredSpriteList[i];
                if (null == sprite)
                {
                    this.unregisteredSpriteList.Remove(sprite);
                    break;
                }
                var style = EditorStyles.textField;
                if (sprite == this.selectSprite)
                    style = EditorStyles.whiteLabel;
                if (GUILayout.Button(sprite.name, style))
                {
                    this.SelectSprite = sprite;
                    EditorGUIUtility.PingObject(this.selectSprite);
                }
            }
            EditorGUILayout.EndScrollView();
            EditorGUILayout.EndVertical();
        }
    }

    private void UpdatePage()
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("上一页"))
        {
            this.curPage = Mathf.Max(this.curPage - 1, 0);
            this.inputPage = this.curPage;
        }
        if (GUILayout.Button("下一页"))
        {
            this.curPage = Mathf.Min(this.curPage + 1, this.totalPage);
            this.inputPage = this.curPage;
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        this.inputPage = EditorGUILayout.IntSlider(this.inputPage, 0, this.totalPage);
        if (GUILayout.Button("跳转"))
        {
            this.curPage = this.inputPage;
        }
        EditorGUILayout.EndHorizontal();
    }

    private void UpdateSelect()
    {
        if (null != this.selectSprite)
        {
            this.guid = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(this.selectSprite));
            this.selectData = this.GetValue(this.guid);
            if (!this.selectData.isNull())
            {
                this.note = this.selectData.note;
                this.label_1 = this.selectData.label_1;
                this.label_2 = this.selectData.label_2;
                this.label_3 = this.selectData.label_3;
            }
            else
            {
                this.note = "";
                this.label_1 = 0;
                this.label_2 = 0;
                this.label_3 = 0;
            }
        }
    }
    private Sprite SelectSprite
    {
        set
        {
            if (this.selectSprite != value)
            {
                this.selectSprite = value;
                if (null != this.selectSprite)
                    this.selectSpriteGuid = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(this.selectSprite.GetInstanceID()));
                else
                    this.selectSpriteGuid = string.Empty;

                this.UpdateSelect();
            }
        }
        get { return this.selectSprite; }
    }

    private SpriteObject GetValue(string guid)
    {
        this.CheckMD5();
        SpriteObject so;
        if (dic.TryGetValue(guid, out so))
        {
            return so;
        }
        return SpriteObject.Null;
    }

    private void Find(string keyword, int label_1 = -1, int label_2 = -1, int label_3 = -1)
    {
        this.CheckMD5();
        this.list.Clear();
        foreach (var so in dic)
        {
            if ((label_1 == -1 || so.Value.label_1 == label_1) && (label_2 == -1 || so.Value.label_2 == label_2) && (label_3 == -1 || so.Value.label_3 == label_3))
            {
                if (null == keyword || string.Empty == keyWord || so.Value.note.Contains(keyword))
                {
                    this.list.Add(so.Value);
                }
            }
        }
    }

    private void Save(string guid, string note, int label_1, int label_2, int label_3)
    {
        this.CheckMD5();
        if (this.dic.ContainsKey(guid))
        {
            SpriteObject newSpriteObject = new SpriteObject(guid, note, label_1, label_2, label_3);
            this.dic[guid] = newSpriteObject;
        }
        else
        {
            var spriteObject = new SpriteObject(guid, note, label_1, label_2, label_3);
            this.dic.Add(guid, spriteObject);
        }
        using (FileStream fileStream = new FileStream(path, FileMode.Create))
        {
            XmlSerializer xmlFormatter = new XmlSerializer(typeof(SerializableDictionary<string, SpriteObject>));
            xmlFormatter.Serialize(fileStream, this.dic);
        }
        this.oldMD5 = MD5.GetMD5FromFile(path);
    }

    private void CleanMissingSprite()
    {
        this.CheckMD5();
        var list = new List<string>();
        foreach (var so in dic)
        {
            var path = AssetDatabase.GUIDToAssetPath(so.Value.guid);
            var obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path);
            if (null == obj)
            {
                list.Add(so.Value.guid);
            }
        }
        foreach (var guid in list)
        {
            this.dic.Remove(guid);
        }
        using (FileStream fileStream = new FileStream(path, FileMode.Create))
        {
            XmlSerializer xmlFormatter = new XmlSerializer(typeof(SerializableDictionary<string, SpriteObject>));
            xmlFormatter.Serialize(fileStream, this.dic);
        }
        if (this.list.Count > 0)
            this.Find(this.keyWord, this.searchLabel_1, this.searchLabel_2, this.searchLabel_3);
        this.ShowNotification(new GUIContent("成功清理" + list.Count + "个丢失的Sprite"));
    }

    private void SearchUnregisteredObject()
    {
        this.CheckMD5();
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Game/UIs" });
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
            var gameobject = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            var images = gameobject.GetComponentsInChildren<Image>(true);
            foreach (var image in images)
            {
                if (null != image.sprite)
                {
                    var spritePath = AssetDatabase.GetAssetPath(image.sprite.texture.GetInstanceID());
                    var spriteGuid = AssetDatabase.AssetPathToGUID(spritePath);
                    if (!this.dic.ContainsKey(spriteGuid))
                    {
                        this.unregisteredObjectList.Add(image.gameObject);
                    }
                }
            }
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("查找中", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void SearchUnregisteredSprite()
    {
        this.CheckMD5();
        string[] guids = AssetDatabase.FindAssets("t:Sprite", new string[] { "Assets/Game/UIs" });
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            if (this.dic.ContainsKey(guid))
                continue;
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var sprite = AssetDatabase.LoadAssetAtPath(path, typeof(Sprite)) as Sprite;
            this.unregisteredSpriteList.Add(sprite);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("查找中", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void CheckMD5()
    {
        var newMD5 = MD5.GetMD5FromFile(path);
        if (this.oldMD5 != newMD5)
        {
            using (FileStream fileStream = new FileStream(path, FileMode.Open))
            {
                XmlSerializer xmlFormatter = new XmlSerializer(typeof(SerializableDictionary<string, SpriteObject>));
                this.dic = (SerializableDictionary<string, SpriteObject>)xmlFormatter.Deserialize(fileStream);
            }
            this.oldMD5 = newMD5;
            this.UpdateSelect();
        }
    }

    public enum Label_1
    {
        Public, Private,
    }

    public enum Label_2
    {
        BackGroud, Button_Toggle, Icon, Others, Progress, Text, Title_Label,
    }

    public enum Label_3
    {
        Simple, Mirror, Sliced,
    }

    public struct SpriteObject
    {
        public string guid;
        public string note;
        public int label_1;
        public int label_2;
        public int label_3;
        private static SpriteObject nullObject = new SpriteObject();

        public SpriteObject(string guid, string note, int label_1, int label_2, int label_3)
        {
            this.guid = guid;
            this.note = note;
            this.label_1 = label_1;
            this.label_2 = label_2;
            this.label_3 = label_3;
        }
        public static SpriteObject Null
        {
            get { return nullObject; }
        }

        public bool isNull()
        {
            return (null == this.guid || this.guid == string.Empty);
        }
    }

    [Serializable]
    public class SerializableDictionary<TKey, TValue> : Dictionary<TKey, TValue>, IXmlSerializable
    {
        public SerializableDictionary() { }
        public void WriteXml(XmlWriter write)       // Serializer  
        {
            XmlSerializer KeySerializer = new XmlSerializer(typeof(TKey));
            XmlSerializer ValueSerializer = new XmlSerializer(typeof(TValue));

            foreach (KeyValuePair<TKey, TValue> kv in this)
            {
                write.WriteStartElement("SerializableDictionary");
                write.WriteStartElement("key");
                KeySerializer.Serialize(write, kv.Key);
                write.WriteEndElement();
                write.WriteStartElement("value");
                ValueSerializer.Serialize(write, kv.Value);
                write.WriteEndElement();
                write.WriteEndElement();
            }
        }
        public void ReadXml(XmlReader reader)
        {
            reader.Read();
            XmlSerializer KeySerializer = new XmlSerializer(typeof(TKey));
            XmlSerializer ValueSerializer = new XmlSerializer(typeof(TValue));

            while (reader.NodeType != XmlNodeType.EndElement)
            {
                reader.ReadStartElement("SerializableDictionary");
                reader.ReadStartElement("key");
                TKey tk = (TKey)KeySerializer.Deserialize(reader);
                reader.ReadEndElement();
                reader.ReadStartElement("value");
                TValue vl = (TValue)ValueSerializer.Deserialize(reader);
                reader.ReadEndElement();
                reader.ReadEndElement();
                this.Add(tk, vl);
                reader.MoveToContent();
            }
            reader.ReadEndElement();
        }
        public XmlSchema GetSchema()
        {
            return null;
        }
    }
}
