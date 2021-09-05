using UnityEngine;
using UnityEditor;
using System.Text;

namespace AssetsCheck
{
    public class MaterialChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game", };

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:material", checkDirs);
            string[] keyWords = { "ENABLE_UV_NOISE", "ENABLE_DECAL" };
            string[] propertyNames = { "_UVNoise", "_DecalTex"};
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                Material material = AssetDatabase.LoadAssetAtPath<Material>(path);
                if ((!material.IsKeywordEnabled("ENABLE_UV_NOISE") && material.HasProperty("_UVNoise") && null != material.GetTexture("_UVNoise"))
                    || (!material.IsKeywordEnabled("ENABLE_DECAL") && material.HasProperty("_DecalTex") && null != material.GetTexture("_DecalTex"))
                    || (!material.IsKeywordEnabled("ENABLE_GLOW") && material.HasProperty("_GlowTex") && null != material.GetTexture("_GlowTex"))
                    || (!material.IsKeywordEnabled("ENABLE_DISSLOVE") && material.HasProperty("_DissloveTex") && null != material.GetTexture("_DissloveTex"))
                    || (!material.IsKeywordEnabled("ENABLE_FLOW_ADD") && !material.IsKeywordEnabled("ENABLE_FLOW_MUL") && material.HasProperty("_FlowTex") && null != material.GetTexture("_FlowTex"))
                    || (!material.IsKeywordEnabled("ENABLE_NORMAL") && material.HasProperty("_NormalTex") && null != material.GetTexture("_NormalTex")))
                {
                    CheckItem checkItem = new CheckItem();
                    checkItem.asset = path;
                    this.outputList.Add(checkItem);
                }
            }
        }

        override protected void OnFix(string[] lines)
        {
            string[] guids = AssetDatabase.FindAssets("t:material", checkDirs);

            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                Material material = AssetDatabase.LoadAssetAtPath<Material>(path);

                if ((!material.IsKeywordEnabled("ENABLE_UV_NOISE") && material.HasProperty("_UVNoise")))
                {
                    material.SetTexture("_UVNoise", null);
                }

                if ((!material.IsKeywordEnabled("ENABLE_DECAL") && material.HasProperty("_DecalTex")))
                {
                    material.SetTexture("_DecalTex", null);
                }

                if ((!material.IsKeywordEnabled("ENABLE_GLOW") && material.HasProperty("_GlowTex")))
                {
                    material.SetTexture("_GlowTex", null);
                }

                if (!material.IsKeywordEnabled("ENABLE_DISSLOVE") && material.HasProperty("_DissloveTex") && null != material.GetTexture("_DissloveTex"))
                {
                    material.SetTexture("_DissloveTex", null);
                    material.DisableKeyword("ENABLE_DISSLOVE_VERTEX_COLOR");
                    material.DisableKeyword("ENABLE_DISSLOVE_OUTLINE");
                }

                if ((!material.IsKeywordEnabled("ENABLE_FLOW_ADD") && !material.IsKeywordEnabled("ENABLE_FLOW_MUL") && material.HasProperty("_FlowTex")))
                {
                    material.SetTexture("_FlowTex", null);
                    material.DisableKeyword("ENABLE_FLOW_SMOOTH");
                }

                if ((!material.IsKeywordEnabled("ENABLE_NORMAL") && material.HasProperty("_NormalTex")))
                {
                    material.SetTexture("_NormalTex", null);
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
