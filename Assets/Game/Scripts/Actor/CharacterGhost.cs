using UnityEngine;
using System.Collections.Generic;

public class CharacterGhost : MonoBehaviour
{
    class GhostInfo
    {
        public GhostInfo(GameObject gameObject, Material material, float time)
        {
            GameObject = gameObject;
            Material = material;
            ShowTime = time;
        }

        public GameObject GameObject;
        public Material Material;
        public float ShowTime;
    }

    SkinnedMeshRenderer skinnedMeshRenderer;
    Transform skinnedMeshTransform;

    private Dictionary<int, List<GhostInfo>> ghostListDict = new Dictionary<int, List<GhostInfo>>();
    private List<GhostInfo> curGhostList;

    private Transform cachedTransform;
    private Transform root;

    int maxGhostTypeNum = 2;

    int curShowMinGhostIdx = -1;
    int curGhostIdx = 0;
    int curMaxGhostNum = 5;
    int curMaxConcurrentGhostNum = 5;
    int curGhostType = -1;

    float ghostInterval = 0.2f;
    float ghostLastCreateTime = 0.0f;

    float hideGhostTime = 0.0f;
    int alphaNameId = -1;

    float speedFactor = 2.5f;

    Material material;

    public Material Material
    {
        get
        {
            return material;
        }

        set
        {
            if (material != value)
            {
                material = value;

                /*foreach (var key in ghostListDict.Keys)
                {
                    var ghostList = ghostListDict[key];
                    for (int i = 0; i < ghostList.Count; ++i)
                    {
                        var go = ghostList[i];
                        var meshRenderer = go.GetComponent<MeshRenderer>();

                        if (meshRenderer != null)
                        {
                            meshRenderer.sharedMaterial = material;
                        }
                    }
                }*/
            }
        }
    }

    public Transform Root
    {
        get
        {
            return root;
        }
        set
        {
            root = value;
        }
    }


    private void Start()
    {
        skinnedMeshRenderer = gameObject.GetComponentInChildren<SkinnedMeshRenderer>();
        skinnedMeshTransform = skinnedMeshRenderer.transform;

        cachedTransform = transform;

        alphaNameId = Shader.PropertyToID("_Alpha");
    }

    private void LateUpdate()
    {

        if (curGhostType == -1 || curGhostList == null)
        {
            return;
        }

        var time = Time.realtimeSinceStartup;

        if (time >= hideGhostTime)
        {
            curGhostType = -1;
            CloseCurGhostList();

            return;
        }

        // 是否还需要继续创建ghost
        if (curGhostIdx < curMaxGhostNum && time - ghostLastCreateTime >= ghostInterval)
        {
            ghostLastCreateTime = time;
            GameObject ghostGo;

            if (curGhostList.Count <= curGhostIdx)
            {
                ghostGo = new GameObject("ghost" + curGhostIdx);

                var transform = ghostGo.transform;
                if (root != null)
                {
                    transform.SetParent(root);
                }


                MeshFilter meshFilter = ghostGo.AddComponent<MeshFilter>();
                MeshRenderer meshRenderer = ghostGo.AddComponent<MeshRenderer>();

                meshRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                meshRenderer.receiveShadows = false;

                // mesh
                Mesh mesh = new Mesh(); ;
                mesh.Clear();

                var bounds = skinnedMeshRenderer.sharedMesh.bounds;
                skinnedMeshRenderer.BakeMesh(mesh);
                meshFilter.mesh = mesh;

                // Material
                var sharedMaterial = new Material(material);
                meshRenderer.sharedMaterial = sharedMaterial;

                transform.position = skinnedMeshTransform.position;
                transform.rotation = skinnedMeshTransform.rotation;

                curGhostList.Add(new GhostInfo(ghostGo, sharedMaterial, time));

            }
            else
            {
                var ghostInfo = curGhostList[curGhostIdx];
                ghostInfo.Material.SetFloat(alphaNameId, 1);
                ghostInfo.ShowTime = time;

                ghostGo = ghostInfo.GameObject;
                ghostGo.SetActive(true);

                var transform = ghostGo.transform;

                transform.position = skinnedMeshTransform.position;
                transform.rotation = skinnedMeshTransform.rotation;
            }

            curGhostIdx++;
        }

        for (int i = 0; i <= curGhostIdx - 1; ++i)
        {
            var ghostInfo = curGhostList[i];
            ghostInfo.Material.SetFloat(alphaNameId, Mathf.Clamp01(1 - (time - ghostInfo.ShowTime) * speedFactor));
        }

        /*if (curGhostIdx - curShowMinGhostIdx + 1 > curMaxConcurrentGhostNum)
        {
            curGhostList[curShowMinGhostIdx].GameObject.SetActive(false);
            curShowMinGhostIdx++;
        }*/
    }

    private void OnDestroy()
    {
        DestroyGhost();
    }

    private void DestroyGhost()
    {
        // 这里用下foreach，频率很低，影响不大
        foreach (var key in ghostListDict.Keys)
        {
            var ghostList = ghostListDict[key];
            for (int i = 0; i < ghostList.Count; ++i)
            {
                var go = ghostList[i].GameObject;

                if (go != null)
                {
                    MeshFilter filter = go.GetComponent<MeshFilter>();

                    // 这里应该是多余的, 不过需要确定下
                    Destroy(filter.mesh);
                    Destroy(go);
                }

            }
        }

        ghostListDict.Clear();
    }

    public void SetMaxGhostTypeNum(int num)
    {
        maxGhostTypeNum = num;
    }

    public void SetSkinnedMeshRenderer(SkinnedMeshRenderer renderer)
    {
        skinnedMeshRenderer = renderer;
        skinnedMeshTransform = renderer.transform;

        DestroyGhost();
    }

    public void SetSpeedFactor(float factor)
    {
        speedFactor = factor;
    }

    // type: 残影类型，0、1、2... 
    // maxGhostNum：最多可以有maxGhostNum个残影
    // maxConcurrentGhostNum: 最多可以用maxConcurrentGhostNum个残影同时显示出来
    // timeInterval: 两个残影之间的时间间隔

    // Note：CharacterGhost会缓存住创建出来的残影mesh，所以type种类越少越好（例如冲锋用0， 跳跃用1，暂时不要加其他的了）
    // 可以通过SetMaxGhostTypeNum设置最多的残影类型，防止程序员滥用, maxGhostNum也是越少越好

    public void ShowGhost(int type, int maxGhostNum, int maxConcurrentGhostNum, float timeInterval)
    {
        if (type > maxGhostTypeNum)
        {
            Debug.LogErrorFormat("error ghost type, max:{0} type:{1}", maxGhostTypeNum, type);
            return;
        }

        CloseCurGhostList();

        List<GhostInfo> ghostList;
        if (!ghostListDict.TryGetValue(type, out ghostList))
        {
            ghostList = new List<GhostInfo>();
            ghostListDict.Add(type, ghostList);
        }

        curGhostIdx = 0;
        curGhostType = type;
        curGhostList = ghostList;
        curMaxGhostNum = maxGhostNum;
        curMaxConcurrentGhostNum = maxConcurrentGhostNum;
        curShowMinGhostIdx = 0;

        ghostLastCreateTime = 0;
        ghostInterval = timeInterval;

        hideGhostTime = timeInterval * (maxGhostNum + 1) + Time.realtimeSinceStartup;
    }

    public void Stop(float time)
    {
        if (curGhostType == -1 || curGhostList == null)
        {
            return;
        }

        float hideTime = Time.realtimeSinceStartup + time;
        if (hideTime < hideGhostTime)
        {
            hideGhostTime = hideTime;
        }
    }

    public static CharacterGhost Bind(GameObject go)
    {
        var characterGhost = go.GetComponent<CharacterGhost>() ?? go.AddComponent<CharacterGhost>();
        return characterGhost;
    }

	public void CloseCurGhostList()
    {
        if (curGhostList == null)
        {
            return;
        }

        for (int i = 0; i < curGhostList.Count; ++i)
        {
            curGhostList[i].GameObject.SetActive(false);
        }

        curGhostList = null;
    }
}
