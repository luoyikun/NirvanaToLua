using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneOptimizeMgr
{ 
    public static void StaticBatch()
    {
        GameObject staticBatchRoot = GameObject.FindGameObjectWithTag("StaticBatching");
        if (null == staticBatchRoot)
        {
            Debug.LogError("没有找到StaticBatching标记，将影响静态合批");
            return;
        }

        GameObject lightObj = GameObject.Find("Hero light");
        int cullingMask = 0;
        if (null != lightObj)
        {
            Light light = lightObj.GetComponent<Light>();
            if (null != light)
            {
                cullingMask = light.cullingMask;
            }
            else
            {
                Debug.LogError("没有找到Hero light灯光，将影响静态合批效率!");
            }
        }

        Dictionary<string, List<GameObject>> combineDic = new Dictionary<string, List<GameObject>>();
        combineDic.Add("receiveShadows", new List<GameObject>());
        combineDic.Add("lightEffective", new List<GameObject>());
        combineDic.Add("default", new List<GameObject>());

        MeshRenderer[] meshRenderers = staticBatchRoot.GetComponentsInChildren<MeshRenderer>(true);
        for (int i = 0; i < meshRenderers.Length; i++)
        {
            MeshRenderer meshRenderer = meshRenderers[i];
            GameObject go = meshRenderers[i].gameObject;
            if ((1 << go.gameObject.layer & cullingMask) != 0) // 受灯光影响
            {
                if (meshRenderer.receiveShadows) // 接收阴影
                {
                    combineDic["receiveShadows"].Add(go);
                }
                else
                {
                    combineDic["lightEffective"].Add(go);
                }
            }
            else
            {
                combineDic["default"].Add(go);
            }
        }

        foreach (var combine in combineDic)
        {
            UnityEngine.StaticBatchingUtility.Combine(combine.Value.ToArray(), staticBatchRoot);
        }
    }
}
