using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Nirvana;
using System.IO;

class UnzipAssetBundleView
{
    private GameObject view = null;
    private Text progressTxt = null;

    public void Open()
    {
        if (null != this.view || null == GameObject.Find("UILayer"))
        {
            return;
        }

        this.view = new GameObject();
        this.view.transform.SetParent(GameObject.Find("UILayer").transform, false);
        this.view.name = "UnzaipAssetView";
        RectTransform view_tf = this.view.AddComponent<RectTransform>();
        view_tf.anchorMin = Vector2.zero;
        view_tf.anchorMax = Vector2.one;
        view_tf.offsetMin = Vector2.zero;
        view_tf.offsetMax = Vector2.zero;

        // 背景
        string bg_path = Path.Combine(UnityEngine.Application.streamingAssetsPath, "AgentAssets/loading_bg.png");
        
        try
        {
            GameObject img_obj = new GameObject();
            img_obj.name = "background";
            img_obj.transform.SetParent(this.view.transform, false);

            RectTransform tf = img_obj.AddComponent<RectTransform>();
            tf.anchorMin = Vector2.zero;
            tf.anchorMax = Vector2.one;
            tf.offsetMin = Vector2.zero;
            tf.offsetMax = Vector2.zero;

            img_obj.AddComponent<RawImage>();
            LoadRawImageURL raw_img = img_obj.AddComponent<LoadRawImageURL>();
            raw_img.URL = bg_path;
        }
        catch (Exception)
        {
            Debug.LogError("unzip bg not found:" + bg_path);
        }

        // 进度
        GameObject txt_obj = new GameObject();
        txt_obj.name = "ProgressTxt";
        txt_obj.transform.SetParent(this.view.transform, false);
        RectTransform txt_tf = txt_obj.AddComponent<RectTransform>();
        txt_tf.anchorMin = new Vector2(0.5f, 0.05f);
        txt_tf.anchorMax = new Vector2(0.5f, 0.05f);
        txt_tf.sizeDelta = new Vector2(700, 100);

        this.progressTxt = txt_obj.AddComponent<Text>();
        this.progressTxt.fontSize = 24;
        this.progressTxt.alignment = TextAnchor.MiddleCenter;

        // 进度文本字体
        string ttf_path = Path.Combine(Application.streamingAssetsPath, "AgentAssets/zipttf");
        try
        {
            AssetBundle asset_bundle = AssetBundle.LoadFromFile(ttf_path);
            Font font = asset_bundle.LoadAsset<Font>("SIMHEI");
            this.progressTxt.font = font;
        }
        catch (Exception)
        {
            Debug.LogError("unzip font not found :" + ttf_path);
        }
    }

    public void SetProgress(int curNum, int maxNum)
    {
        if (null != this.progressTxt)
        {
            float precent = (float)curNum / maxNum;
            this.progressTxt.text = string.Format("首次解压资源，请稍等【{0}%】（不消耗流量）", Convert.ToInt32(precent * 100));
        }
    }

    public void Close()
    {
        if (null == this.view)
        {
            return;
        }

        GameObject.Destroy(this.view);
    }
}
