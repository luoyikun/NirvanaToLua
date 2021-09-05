using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections.Generic;

public class ParticleSystemsSearcher : EditorWindow
{
    [MenuItem("自定义工具/资源搜索工具/特效搜索")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow(typeof(ParticleSystemsSearcher), false, "特效搜索");
    }

    private UnityEngine.Object cCheckFolder;

    private int m_nMinPartSysCount = 0;               // 粒子发射器
    private int m_nMinPartCount = 0;                  // 最大粒子数量
    private int m_nMinMateCount = 0;                  // 材质球数量
    private float m_fMinTextureMemoryCount = 0;       // 贴图内存
    private float m_fMinMeshMemoryCount = 0;          // 网格内存
    private float m_fMinTimeCount = 0;                // 

    private Vector2 m_v2ScrollPos;

    private List<GameObject> m_lsResultObject = new List<GameObject>();
    private List<int> m_lsHideTagCount = new List<int>();
    private List<int> m_lsPartSysCount = new List<int>();
    private List<int> m_lsPartsCount = new List<int>();
    private List<int> m_lsMateCount = new List<int>();
    private List<float> m_lsTextureMemoryCount = new List<float>();
    private List<float> m_lsMeshMemorysCount = new List<float>();
    private List<float> m_lsTimeCount = new List<float>();
    private List<bool> m_lsLoop = new List<bool>();

    //查找文件
    private string[] _GetFiles(string path, bool recursive = true)
    {
        List<string> withExtensions = new List<string>() { ".prefab" };

        var resultList = new List<string>();
        string[] files = Directory.GetFiles(path, "*.*", recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);

        foreach (var strPath in files)
        {
            if (withExtensions.Contains(Path.GetExtension(strPath).ToLower()))
            {
                resultList.Add(strPath.Replace('\\', '/'));
            }
        }

        return resultList.ToArray();
    }

    private int _GetHideTagCount(Transform cTrans)
    {
        int nHideTagCount = 0;

        /*for (int i = 0; i < cTrans.childCount; ++i)
        {
            Transform cChild = cTrans.GetChild(i);

            if (cChild.CompareTag("CanHide"))
                nHideTagCount += 1;
            else
                nHideTagCount += _GetHideTagCount(cChild);
        }*/

        return nHideTagCount;
    }

    // 粒子数量 粒子发射器量 
    private void _GetPartInfo(GameObject cObj, out int o_nPartSysCount, out int o_nPartCount)
    {
        ParticleSystem[] lsPartSys = cObj.GetComponentsInChildren<ParticleSystem>(true);

        o_nPartSysCount = lsPartSys.Length;

        o_nPartCount = 0;
        foreach (var ps in lsPartSys)
        {
            int nPartCount = 0;
            ParticleSystem.EmissionModule emiss = ps.emission;
            ParticleSystemRenderer renderer = (ParticleSystemRenderer)ps.GetComponent<Renderer>();

            // 就算不渲染也一样计算粒子数量
            if (!emiss.enabled /*|| (renderer.mesh== null)*/)
                continue;

            ParticleSystem.MinMaxCurve rate = emiss.rate;

            if (emiss.type == ParticleSystemEmissionType.Distance)      // 按距离计算的 直接按粒子发射的限制算
            {
                nPartCount = ps.maxParticles;
            }
            else if (emiss.type == ParticleSystemEmissionType.Time)      // 按时间计算的 动态计算
            {
                // 正常发射
                if (rate.constantMax != 0)
                {
                    nPartCount = (int)(rate.constantMax * (ps.startDelay + ps.startLifetime));
                }

                // 顶点发射
                if (emiss.burstCount > 0)
                {
                    ParticleSystem.Burst[] bursts = new ParticleSystem.Burst[emiss.burstCount];
                    emiss.GetBursts(bursts);

                    //暂时先做成简单叠加
                    for (int i = 0; i < bursts.Length; ++i)
                    {
                        nPartCount += bursts[i].maxCount;
                    }
                }

                if (nPartCount > ps.maxParticles)
                {
                    nPartCount = ps.maxParticles;
                }
            }

            o_nPartCount += nPartCount;
        }
    }

    // 材质数量
    private int _GetMateCount(GameObject cObj)
    {
        Dictionary<Material, bool> mapMate = new Dictionary<Material, bool>();

        Renderer[] lsRender = cObj.GetComponentsInChildren<Renderer>();
        foreach (var render in lsRender)
        {
            if (render.sharedMaterial != null)
                mapMate[render.sharedMaterial] = true;

            foreach (var mate in render.sharedMaterials)
            {
                if (mate != null)
                    mapMate[mate] = true;
            }
        }

        return mapMate.Keys.Count;
    }

    // 获取贴图内存
    private float _GetTextureMemoryCount(GameObject cObj)
    {
        float fTextureMemoryCount = 0;

        Dictionary<Material, bool> mapMate = new Dictionary<Material, bool>();

        Renderer[] lsRender = cObj.GetComponentsInChildren<Renderer>();
        foreach (var render in lsRender)
        {
            if (render.sharedMaterial != null)
                mapMate[render.sharedMaterial] = true;

            foreach (var mate in render.sharedMaterials)
            {
                if (mate != null)
                    mapMate[mate] = true;
            }
        }

        // 搜集贴图
        Dictionary<Texture, bool> mapTexture = new Dictionary<Texture, bool>();

        foreach (Material mate in mapMate.Keys)
        {
            if (mate.mainTexture != null)
            {
                mapTexture[mate.mainTexture] = true;
            }
        }

        foreach (Texture texture in mapTexture.Keys)
        {
            fTextureMemoryCount += UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(texture) / 2;
        }

        return fTextureMemoryCount / 1000;
    }

    // 获取网格内存
    private float _GetMeshMemoryCount(GameObject cObj)
    {
        float fMeshMemoryCount = 0;

        Dictionary<Mesh, bool> mapMesh = new Dictionary<Mesh, bool>();

        SkinnedMeshRenderer[] lsSkinMesh = cObj.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var skinMesh in lsSkinMesh)
        {
            if (skinMesh.sharedMesh != null)
            {
                mapMesh[skinMesh.sharedMesh] = true;
            }
        }

        MeshFilter[] lsMeshFilter = cObj.GetComponentsInChildren<MeshFilter>();
        foreach (var meshFilter in lsMeshFilter)
        {
            if (meshFilter.sharedMesh != null)
            {
                mapMesh[meshFilter.sharedMesh] = true;
            }
        }

        foreach (Mesh cMesh in mapMesh.Keys)
        {
            fMeshMemoryCount += UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(cMesh);
        }

        return fMeshMemoryCount / 1000;
    }

    // 获取播放时间
    /*private void _GetTimeCount(GameObject cObj, out float fTimeCount, out bool bLoop)
    {
        EffectStatus status = EffectStatus.Bind(cObj, out fTimeCount);
        status.InitData();

        fTimeCount = status.TotalLength;
        bLoop = status.IsStatusLoop;

        DestroyImmediate(cObj.GetComponent<EffectStatus>(), true);
    }*/

    //
    private void _CollectParticleSystem()
    {
        m_lsResultObject.Clear();
        m_lsHideTagCount.Clear();
        m_lsPartSysCount.Clear();
        m_lsPartsCount.Clear();
        m_lsMateCount.Clear();
        m_lsTextureMemoryCount.Clear();
        m_lsMeshMemorysCount.Clear();
        m_lsTimeCount.Clear();
        m_lsTimeCount.Clear();

        string strCheckFolderPath = AssetDatabase.GetAssetPath(cCheckFolder);
        string[] lsFiles = _GetFiles(strCheckFolderPath);

        foreach (string strPrefabFile in lsFiles)
        {
            GameObject cObj = (GameObject)AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(strPrefabFile);

            int nHideTagCount = _GetHideTagCount(cObj.transform);

            int nPartSysCount;
            int nPartCount;

            _GetPartInfo(cObj, out nPartSysCount, out nPartCount);

            int nMateCount = _GetMateCount(cObj);
            float fTextureMemoryCount = _GetTextureMemoryCount(cObj);
            float fMeshMemoryCount = _GetMeshMemoryCount(cObj);

            // float fTimeCount;
            bool bLoop;

            // _GetTimeCount(cObj, out fTimeCount, out bLoop);

            if (nPartCount < m_nMinPartCount)
                continue;

            if (nPartSysCount < m_nMinPartSysCount)
                continue;

            if (nMateCount < m_nMinMateCount)
                continue;

            if (fTextureMemoryCount < m_fMinTextureMemoryCount)
                continue;

            if (fMeshMemoryCount < m_fMinMeshMemoryCount)
                continue;

            /*if (fTimeCount < m_fMinTimeCount)
                continue;*/

            m_lsResultObject.Add(cObj);
            m_lsHideTagCount.Add(nHideTagCount);
            m_lsPartSysCount.Add(nPartSysCount);
            m_lsPartsCount.Add(nPartCount);
            m_lsMateCount.Add(nMateCount);
            m_lsTextureMemoryCount.Add(fTextureMemoryCount);
            m_lsMeshMemorysCount.Add(fMeshMemoryCount);
            // m_lsTimeCount.Add(fTimeCount);
            // m_lsLoop.Add(bLoop);
        }
    }

    void OnGUI()
    {
        GUILayout.BeginVertical();

        if (cCheckFolder == null)
        {
            cCheckFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Resources/Effects/prefab");
        }

        cCheckFolder = EditorGUILayout.ObjectField("拖入搜索目录", cCheckFolder, typeof(UnityEngine.Object), false);

        m_nMinPartCount = EditorGUILayout.IntField("粒子数", m_nMinPartCount, GUILayout.Width(200));
        m_nMinPartSysCount = EditorGUILayout.IntField("粒子发射器", m_nMinPartSysCount, GUILayout.Width(200));
        m_nMinMateCount = EditorGUILayout.IntField("材质球数", m_nMinMateCount, GUILayout.Width(200));
        m_fMinTextureMemoryCount = EditorGUILayout.FloatField("贴图内存", m_fMinTextureMemoryCount, GUILayout.Width(200));
        m_fMinMeshMemoryCount = EditorGUILayout.FloatField("网格内存", m_fMinMeshMemoryCount, GUILayout.Width(200));
        m_fMinTimeCount = EditorGUILayout.FloatField("时间", m_fMinTimeCount, GUILayout.Width(200));

        if (GUILayout.Button("搜索特效", GUILayout.Width(100)))
        {
            _CollectParticleSystem();
        }

        if (m_lsResultObject.Count > 0)
        {
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("序号", GUILayout.Width(30));
            EditorGUILayout.LabelField("特效对象", GUILayout.Width(300));
            EditorGUILayout.LabelField("", GUILayout.Width(10));
            EditorGUILayout.LabelField("可隐藏点", GUILayout.Width(50));
            EditorGUILayout.LabelField("发射器", GUILayout.Width(50));
            EditorGUILayout.LabelField("粒子数", GUILayout.Width(50));
            EditorGUILayout.LabelField("材质球数", GUILayout.Width(50));
            EditorGUILayout.LabelField("贴图内存(kb)", GUILayout.Width(100));
            EditorGUILayout.LabelField("网格内存(kb)", GUILayout.Width(100));
            EditorGUILayout.LabelField("播放时间", GUILayout.Width(60));
            EditorGUILayout.LabelField("循环特效", GUILayout.Width(50));


            GUILayout.EndHorizontal();

            m_v2ScrollPos = EditorGUILayout.BeginScrollView(m_v2ScrollPos, GUILayout.Width(950), GUILayout.Height(600));

            for (var nIdx = 0; nIdx < m_lsResultObject.Count; ++nIdx)
            {
                GUILayout.BeginHorizontal();

                var obj = m_lsResultObject[nIdx];
                EditorGUILayout.LabelField((nIdx + 1).ToString(), GUILayout.Width(30));
                EditorGUILayout.ObjectField(obj, typeof(GameObject), false, GUILayout.Width(300));
                EditorGUILayout.LabelField("", GUILayout.Width(10));

                if (m_lsHideTagCount[nIdx] > 0)
                    EditorGUILayout.LabelField(m_lsHideTagCount[nIdx].ToString(), GUILayout.Width(50));
                else
                    EditorGUILayout.LabelField("", GUILayout.Width(50));

                EditorGUILayout.LabelField(m_lsPartSysCount[nIdx].ToString(), GUILayout.Width(50));
                EditorGUILayout.LabelField(m_lsPartsCount[nIdx].ToString(), GUILayout.Width(50));
                EditorGUILayout.LabelField(m_lsMateCount[nIdx].ToString(), GUILayout.Width(50));
                EditorGUILayout.LabelField(m_lsTextureMemoryCount[nIdx].ToString(), GUILayout.Width(100));
                EditorGUILayout.LabelField(m_lsMeshMemorysCount[nIdx].ToString(), GUILayout.Width(100));
                // EditorGUILayout.LabelField(m_lsTimeCount[nIdx].ToString(), GUILayout.Width(60));

                /*if (m_lsLoop[nIdx])
                    EditorGUILayout.LabelField("√", GUILayout.Width(80));
                else
                    EditorGUILayout.LabelField("", GUILayout.Width(80));*/

                GUILayout.EndHorizontal();

                EditorGUILayout.Space();
            }

            EditorGUILayout.EndScrollView();

            EditorGUILayout.LabelField("共计" + m_lsResultObject.Count + "个");
        }

        GUILayout.EndVertical();
    }
}