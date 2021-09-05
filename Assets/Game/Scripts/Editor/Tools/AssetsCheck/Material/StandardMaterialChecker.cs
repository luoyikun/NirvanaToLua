using UnityEngine;
using UnityEditor;
using System.Text;

namespace AssetsCheck
{
    public class StandardMaterialChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game",};

        override protected void OnCheck()
        {
            // 先构建引用关系

            AssetRefrence.Build("t:prefab", new string[] { "Assets/Game" });
            AssetRefrence.Build("t:scene", new string[] { "Assets/Game" });

            CheckAllModels();
            CheckAllMaterial();
        }

        private void CheckAllModels()
        {
            string[] guids = AssetDatabase.FindAssets("t:model", checkDirs);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                GameObject model = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                CheckModel(model, path);
            }
        }

        private void CheckModel(GameObject model, string path)
        {
            Renderer[] renders = model.GetComponentsInChildren<Renderer>();
            foreach (var render in renders)
            {
                Material[] materials = render.sharedMaterials;
                for (int i = 0; i < materials.Length; i++)
                {
                    if (null != materials[i] && !IsValidMaterial(materials[i]))
                    {
                        CheckItem item = new CheckItem();
                        item.asset = path;
                        item.shaderName = materials[i].shader.name;
                        this.outputList.Add(item);
                    }
                }
            }
        }

        private void CheckAllMaterial()
        {
            var assetPaths = AssetDatabase.GetAllAssetPaths();
            foreach (var path in assetPaths)
            {
                if (!AssetRefrence.IsBeRefed(path))
                {
                    continue;
                }

                Material material = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (null != material && !IsValidMaterial(material))
                {
                    CheckItem item = new CheckItem();
                    item.asset = path;
                    item.shaderName = material.shader.name;
                    this.outputList.Add(item);
                }
            }
        }

        override protected void OnFix(string[] lines)
        {
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.IsNullOrEmpty(lines[i]))
                {
                    continue;
                }

                string separator = "    ";
                string path = lines[i].Split(separator.ToCharArray())[0];
                AssetImporter importer = AssetImporter.GetAtPath(path);
                if (null != importer)
                {
                    importer.SaveAndReimport();  // 在导入规则那会自动处理掉
                }
            }
        }

        private bool IsValidMaterial(Material material)
        {
            if (!material.shader.name.StartsWith("Game/"))
            {
                return false;
            }

            return true;
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
