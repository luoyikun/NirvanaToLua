using UnityEngine;
using UnityEditor;
using System.Text;
using System.Collections.Generic;
using Game;
using Nirvana;
using UnityEngine.Rendering;

namespace AssetsCheck
{
    public class LowMaterialChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = {
            //"Assets/Game/Actors/NPC",
          // "Assets/Game/Actors/Monster",
         //  "Assets/Game/Actors/Role",
         //  "Assets/Game/Actors/Wing",
//            "Assets/Game/Actors/Mount",
//            "Assets/Game/Actors/Weapon",
       // "Assets/Game/Actors/Arm",
   //     "Assets/Game/Actors/Arm",
         "Assets/Game/Actors/Monster",
        };

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:material", checkDirs);
        
        }

        override protected void OnFix(string[] lines)
        {
//             string[] guids = AssetDatabase.FindAssets("t:material", checkDirs);
//             for (int i = 0; i < guids.Length; i++)
//             {
//                 string path = AssetDatabase.GUIDToAssetPath(guids[i]);
//                 if (path.IndexOf("_low") >= 0)
//                 {
//                     continue;
//                 }
//             }

            this.AddActorRender();
        }

        private Material GetLowMaterial(Material material)
        {
            if (null == material)
            {
                return null;
            }

            string path = AssetDatabase.GetAssetPath(material.GetInstanceID());

            string lowPath = path.Replace(".mat", "_low.mat");
            Material lowMaterial = AssetDatabase.LoadAssetAtPath<Material>(lowPath);
            if (null == lowMaterial)
            {
                AssetDatabase.CopyAsset(path, path.Replace(".mat", "_low.mat"));
                lowMaterial = AssetDatabase.LoadAssetAtPath<Material>(lowPath);

                lowMaterial.SetTexture("_UVNoise", null);
                lowMaterial.SetTexture("_DecalTex", null);
                lowMaterial.SetTexture("_NormalTex", null);
                lowMaterial.SetTexture("_FlowTex", null);
                lowMaterial.SetTexture("_DissloveTex", null);
                lowMaterial.shader = Shader.Find("Actor/Unlit");
            }

            foreach (var item in lowMaterial.shaderKeywords)
            {
                lowMaterial.DisableKeyword(item);
            }

            return lowMaterial;
        }

        private void AddActorRender()
        {
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                GameObject gameObj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (null == gameObj.GetComponent<ActorAttachment>()
                    && null == gameObj.GetComponent<AttachObject>()
                     && null == gameObj.GetComponent<AttachSkinObject>()
                     && null == gameObj.GetComponent<AnimatorOptimizer>()
                        && null == gameObj.GetComponent<Animator>())
                {
                    continue;
                }

                Renderer[] renders = gameObj.GetComponentsInChildren<Renderer>();
                if (renders.Length <= 0)
                {
                    continue;
                }

                if (gameObj.GetComponentsInChildren<ParticleSystem>(true).Length > 0)
                {
                    Debug.LogErrorFormat("AddActorRender warning-1:" + path);
                    continue;
                }

                List<ActorRender.RenderItem> list = new List<ActorRender.RenderItem>();
                for (int m = 0; m < renders.Length; m++)
                {
                    if (renders[m].sharedMaterials.Length != 1)
                    {
                        
                        // 第1个材质球是standard, 每2个材质球是particle只有这种情况下在 ActorRender中使用.material才是正确
                        if (renders[m].sharedMaterials.Length == 2
                            && null != renders[m].sharedMaterials[0] && null != renders[m].sharedMaterials[1]
                            && renders[m].sharedMaterials[0].shader.name.IndexOf("Game/Standard") > 0
                             && renders[m].sharedMaterials[1].shader.name.IndexOf("Game/Particle") > 0)
                        {
                            // donothng
                        }
                        else
                        {
                            Debug.LogErrorFormat("AddActorRender warning0:" + path);
                            continue;
                        }
                    }

                    if (null == renders[m].sharedMaterials[0])
                    {
                        Debug.LogErrorFormat("AddActorRender warning1:" + path);
                        continue;
                    }

                    // 判是否是GameStand的Opaqueue才处理
                    if (!(renders[m].sharedMaterials[0].shader.name.IndexOf("Game/Standard") > 0
                        && renders[m].sharedMaterials[0].GetInt("_SrcBlend") == (int)BlendMode.One
                        && renders[m].sharedMaterials[0].GetInt("_DstBlend") == (int)BlendMode.Zero))
                    {
                        Debug.LogErrorFormat("AddActorRender warning2:" + path);
                        continue;
                    }

                    ActorRender.RenderItem renderItem = new ActorRender.RenderItem();
                    renderItem.renderer = renders[m];
                    renderItem.HighMaterial = renders[m].sharedMaterials[0];
                    renderItem.lowMaterial = GetLowMaterial(renderItem.HighMaterial);

                    list.Add(renderItem);
                }

                if (list.Count > 0)
                {
                    ActorRender actorRender = gameObj.GetComponent<ActorRender>();
                    if (null == actorRender)
                    {
                        actorRender = gameObj.AddComponent<ActorRender>();

                    }
                    actorRender.SetRenderList(list);
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public string shaderName;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0}   {1}", asset, shaderName));
                return builder;
            }
        }
    }
}
