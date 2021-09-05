//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

[ExecuteInEditMode]
public class UIPrefabPanel : MonoBehaviour
{
    [SerializeField]
    private GameObject panel;

#if UNITY_EDITOR
    private GameObject instance;

    /// <summary>
    /// Refresh the panel.
    /// </summary>
    public void Refresh()
    {
        var prefabType = PrefabUtility.GetPrefabType(this);
        if (prefabType == PrefabType.Prefab)
        {
            return;
        }

        if (this.instance != null)
        {
            this.transform.SetParent(null, false);
            if (Application.isPlaying)
            {
                GameObject.Destroy(this.instance);
            }
            else
            {
                GameObject.DestroyImmediate(this.instance);
            }

            this.instance = null;
        }

        if (this.transform.parent == null && this.panel != null)
        {
            this.instance = GameObject.Instantiate(this.panel);
            this.instance.hideFlags = HideFlags.DontSave;
            this.transform.SetParent(this.instance.transform, false);
            EditorApplication.delayCall += () =>
                EditorGUIUtility.PingObject(this);
        }
    }

    private void OnEnable()
    {
        if (GameRoot.Instance != null)
        {
            return;
        }

        this.Refresh();
    }

    private void OnDestroy()
    {
        if (this.instance != null)
        {
            var instance = this.instance;
            this.instance = null;
            EditorApplication.delayCall += () =>
            {
                if (Application.isPlaying)
                {
                    GameObject.Destroy(instance);
                }
                else
                {
                    GameObject.DestroyImmediate(instance);
                }
            };
        };
    }
#endif
}
