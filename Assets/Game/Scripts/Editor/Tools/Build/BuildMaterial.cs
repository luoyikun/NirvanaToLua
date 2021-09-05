using UnityEngine;
using UnityEditor;
using System.IO;
using Nirvana.Editor;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System;
using System.Text.RegularExpressions;

namespace Build
{
    public class BuildMaterial
    {
        // 每种材质球下的材质球列表
        private static Dictionary<MaterialKey, List<Material>> materialKeyListMap = new Dictionary<MaterialKey, List<Material>>(MaterialKeyCompare.Default);
        private static Dictionary<string, long> shaderWriteTimeMap = new Dictionary<string, long>();

        private static string outputDir = "Assets/Game/Shaders/Materials";

        private static HashSet<string> modifyMaterialPaths = new HashSet<string>();
        private static HashSet<Shader> changedShaders = new HashSet<Shader>();
        private static void GetKeywordIdDic(Dictionary<string, int> dic, HashSet<int> idSet)
        {
            string path = Path.Combine(outputDir, "keyword_id.txt");
            if (!File.Exists(path))
            {
                return;
            }

            string[] lines = File.ReadAllLines(path);
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.Empty != lines[i])
                {
                    string[] ary = lines[i].Split(' ');
                    dic.Add(ary[0], Convert.ToInt32(ary[1]));
                    idSet.Add(Convert.ToInt32(ary[1]));
                }
            }
        }

        private static int GetIncKeywordId(HashSet<int> idSet)
        {
            for (int i = 1; i < 1000; i++)
            {
                if (!idSet.Contains(i))
                {
                    idSet.Add(i);
                    return i;
                }
            }

            return 0;
        }

        private static void SaveKeywordIdDic(Dictionary<string, int> dic)
        {
            string path = Path.Combine(outputDir, "keyword_id.txt");
            List<string> list = new List<string>();
            foreach (var item in dic)
            {
                list.Add(string.Format("{0} {1}", item.Key, item.Value));
            }

            File.WriteAllLines(path, list.ToArray());
        }

        private static void GetShaderRecord(Dictionary<string, long> recordDic)
        {
            string path = Path.Combine(outputDir, "shader_modified_record.txt");
            if (!File.Exists(path))
            {
                return;
            }

            string[] lines = File.ReadAllLines(path);
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.Empty != lines[i])
                {
                    string[] ary = lines[i].Split('#');
                    recordDic.Add(ary[0], long.Parse(ary[1]));
                }
            }
        }

        private static void SaveShaderRecord(Dictionary<string, long> recordDic)
        {
            string path = Path.Combine(outputDir, "shader_modified_record.txt");
            List<string> list = new List<string>();
            foreach (var item in recordDic)
            {
                list.Add(string.Format("{0}#{1}", item.Key, item.Value));
            }

            File.WriteAllLines(path, list.ToArray());
        }

        public static bool Build(out string[] modifyMaterialList)
        {
            using (var progress = new ProgressIndicator("Build AssetBundle Materials"))
            {
                modifyMaterialPaths.Clear();
                bool isSucc = Build(progress);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                modifyMaterialList = modifyMaterialPaths.ToArray();
                return isSucc;
            }
        }

        public static bool Build()
        {
            using (var progress = new ProgressIndicator("Build AssetBundle Materials"))
            {
                bool isSucc = Build(progress);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                return isSucc;
            }
        }

        private static HashSet<MaterialKey> FetchAllMaterials()
        {
            materialKeyListMap.Clear();

            var materialKeys = new HashSet<MaterialKey>(MaterialKeyCompare.Default);
            var assetPaths = AssetDatabase.GetAllAssetPaths();
            foreach (var assetPath in assetPaths)
            {
                if (!assetPath.EndsWith(".mat"))
                {
                    continue;
                }

                if (!IsValidMaterial(assetPath))
                {
                    continue;
                }

                var material = AssetDatabase.LoadMainAssetAtPath(assetPath) as Material;
                if (material != null && material.shader != null)
                {
                    var key = new MaterialKey(material.shader, material.shaderKeywords);
                    materialKeys.Add(key);

                    List<Material> materialList;
                    if (!materialKeyListMap.TryGetValue(key, out materialList))
                    {
                        materialList = new List<Material>();
                        materialKeyListMap.Add(key, materialList);
                    }

                    materialList.Add(material);
                }
            }

            return materialKeys;
        }

        private static bool Build(ProgressIndicator progress)
        {
            if (progress.Show("Find all material keys: "))
            {
                return true;
            }

            var materialKeys = FetchAllMaterials();

            var keyword_str_id_dic = new Dictionary<string, int>();
            var keyword_id_dic = new HashSet<int>();
            GetKeywordIdDic(keyword_str_id_dic, keyword_id_dic);

            changedShaders.Clear();
            shaderWriteTimeMap.Clear();
            GetShaderRecord(shaderWriteTimeMap);

            progress.SetTotal(materialKeys.Count);
            foreach (var key in materialKeys)
            {
                string keyWordStr = "";
                foreach (var keyword in key.Keywords)
                {
                    int keyword_id = 0;
                    if (!keyword_str_id_dic.TryGetValue(keyword, out keyword_id))
                    {
                        keyword_id = GetIncKeywordId(keyword_id_dic);
                        if (keyword_id <= 0)
                        {
                            Debug.LogErrorFormat("打包Shader失败, keyword_id is error");
                            return false;
                        }

                        keyword_str_id_dic.Add(keyword, keyword_id);
                    }

                    keyWordStr += string.IsNullOrEmpty(keyWordStr) ? keyword_id.ToString() : "_" + keyword_id;
                }

                progress.AddProgress();
                if (progress.Show("Build material: " + keyWordStr))
                {
                    return true;
                }

                if (!CreateShaderOrMaterial(key, keyWordStr))
                {
                    progress.Dispose();
                    Debug.LogErrorFormat("打包Shader失败!!!!!!!!!!!!!!!!!!!!!!!!!");
                    return false;
                }
            }

            CacheShaderBeChangeed();
            SaveKeywordIdDic(keyword_str_id_dic);
            SaveShaderRecord(shaderWriteTimeMap);
            return true;
        }

        // 获得原始shader的名字（在shader中的名字)
        private static string GetOrginalShaderName(string shaderName)
        {
            if (shaderName.IndexOf("AutoBuild/") < 0) return shaderName;

            string orignalShaderName = shaderName.Replace("AutoBuild/", "");
            orignalShaderName = orignalShaderName.Substring(0, orignalShaderName.IndexOf("__KW__"));
            return orignalShaderName;
        }

        // 获得原始shader的绝对路径
        private static string GetOrginalShaderAbsolutePath(string shaderName)
        {
            string orginalShaderName = GetOrginalShaderName(shaderName);
            Shader shader = Shader.Find(orginalShaderName);
            if (null == shader)
            {
                Debug.Log("打不到原始sahder: " + orginalShaderName);
                return "";
            }

            string assetPath = AssetDatabase.GetAssetPath(shader.GetInstanceID());
            string absolutePath = string.Format("{0}/../{1}", Application.dataPath, assetPath);
            return absolutePath;
        }

        // 获得新shader的名字（在shader中的名字)
        private static string GetNewShaderName(string shaderName, string keyWordStr)
        {
            string orignalShaderName = GetOrginalShaderName(shaderName);
            return string.Format("AutoBuild/{0}__KW__{1}", orignalShaderName, keyWordStr);
        }

        // 获得新shader文件的名字
        private static string GetNewShaderFileName(string shaderName, string keyWordStr)
        {
            string orginalShaderName = GetOrginalShaderName(shaderName);
            orginalShaderName = orginalShaderName.Replace("/", "_");
            return string.Format("AutoBuild_{0}__KW__{1}", orginalShaderName, keyWordStr);
        }

        // 检查shader代码是改动过，改过过则需要重新拷贝
        private static bool CheckShaderChanged(string shaderName)
        {
            string orginalShaderAssetFilePath = GetOrginalShaderAbsolutePath(shaderName);
            if (!File.Exists(orginalShaderAssetFilePath))
            {
                return true;
            }

            string orginalShaderName = GetOrginalShaderName(shaderName);
            long lastWriteOrginalShaderTime = GetTimeStamp(File.GetLastWriteTime(orginalShaderAssetFilePath));
            if (!shaderWriteTimeMap.ContainsKey(orginalShaderName) || lastWriteOrginalShaderTime != shaderWriteTimeMap[orginalShaderName])
            {
                return true;
            }

            return false;
        }

        private static void CacheShaderBeChangeed()
        {
            foreach (var shader in changedShaders)
            {
                CacheShaderBeChangeed(shader);
            }
        }

        // 缓存原始sahder修改时间（与下次做对比）
        private static void CacheShaderBeChangeed(Shader shader)
        {
            if (null == shader)
            {
                return;
            }

            string orginalShaderAssetFilePath = GetOrginalShaderAbsolutePath(shader.name);
            if (!File.Exists(orginalShaderAssetFilePath))
            {
                return;
            }

            string orginalShaderName = GetOrginalShaderName(shader.name);
            long lastWriteOrginalShaderTime = GetTimeStamp(File.GetLastWriteTime(orginalShaderAssetFilePath));
            if (!shaderWriteTimeMap.ContainsKey(orginalShaderName))
            {
                shaderWriteTimeMap.Add(orginalShaderName, lastWriteOrginalShaderTime);
            }
            else
            {
                shaderWriteTimeMap[orginalShaderName] = lastWriteOrginalShaderTime;
            }
        }

        private static bool CreateShaderOrMaterial(MaterialKey materialKey, string keyWordStr)
        {
            Shader shader = materialKey.Shader;

            // 根据原始名重新组建新的 Game_Standard => AutoBuild/Game/Standard_KW_2_3
            string newFileName = GetNewShaderFileName(shader.name, keyWordStr);
            string dirName = newFileName;
            string dirAbsolutePath = string.Format("{0}/../{1}/{2}", Application.dataPath, outputDir, dirName);

            string dirRelPath = Path.Combine(outputDir, dirName);
            if (!AssetDatabase.IsValidFolder(dirRelPath))
            {
                AssetDatabase.CreateFolder(outputDir, dirName);
            }

            string newShaderName = GetNewShaderName(shader.name, keyWordStr);
            string newShaderAssetPath = string.Format("{0}/{1}.shader", dirRelPath, newFileName);
            Shader newShader = AssetDatabase.LoadAssetAtPath<Shader>(newShaderAssetPath);
            bool shaderIsChaned = CheckShaderChanged(shader.name);

            if (null == newShader || shaderIsChaned)   /// 新shader不存在，或者原始的shader被改动过,则应该更新新的shader
            {
                string orginalShaderAbsolutePath = GetOrginalShaderAbsolutePath(shader.name);
                if (orginalShaderAbsolutePath.IndexOf("Error") >= 0)
                {
                    Debug.LogErrorFormat("Shader有错误, {0}，以下是有可能出错的材质球，请认真检查!!!!!!!!!!!!!!!!!!!!!!!!，", orginalShaderAbsolutePath);
                    OutputMaterialsKeyInfo(materialKey, null);
                    return false;
                }

                if (!File.Exists(orginalShaderAbsolutePath))
                {
                    Debug.LogFormat("用了Unity内置的材质球，建议处理！以下是有问题的材质球");
                    OutputMaterialsKeyInfo(materialKey, shader.name);
                    return true;
                }

                string shaderContent = File.ReadAllText(orginalShaderAbsolutePath);
                string orignalShaderName = GetOrginalShaderName(shader.name);

                // 修改shader内容
                shaderContent = shaderContent.Replace(orignalShaderName, newShaderName);
                string[] cgincList = { "ShaderAttributes.cginc",
                    "ShaderColor.cginc",
                    "ShaderFlow.cginc",
                    "ShaderLighting.cginc",
                    "ShaderNormal.cginc",
                    "ShaderMirror.cginc",
                    "ShaderReflection.cginc",
                    "ShaderRim.cginc",
                    "ShaderTexture.cginc",
                    "ShaderVerticalFog.cginc" };

                for (int i = 0; i < cgincList.Length; i++)
                {
                    shaderContent = shaderContent.Replace(cgincList[i], "../../" + cgincList[i]);
                }

                string newShaderAbsolutePath = string.Format("{0}/{1}.shader", dirAbsolutePath, newFileName);
                File.WriteAllText(newShaderAbsolutePath, shaderContent);
                AssetDatabase.ImportAsset(newShaderAssetPath);
                newShader = Shader.Find(newShaderName);
            }

            /// 材质球不存在，或者材质指定的shader不是新shader的名字则要更新材质球
            string materilAssetPath = string.Format("{0}/{1}.mat", dirRelPath, newFileName);
            Material material = AssetDatabase.LoadAssetAtPath<Material>(materilAssetPath);
            if (null != material && null != material.shader && material.shader.name != newShaderName)
            {
                ReplaceShader(material, newShader);
            }
            else if (null == material || null == material.shader)
            {
                material = new Material(newShader);
                material.shaderKeywords = materialKey.Keywords;
                AssetDatabaseUtil.ReplaceAsset(material, materilAssetPath);
            }

            // 存储shader这次的记录
            changedShaders.Add(shader);
            // 优化shader
            OptimizeMaterialShader(materialKey, newShader);

            return true;
        }

        private static long GetTimeStamp(DateTime time)
        {
            DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
            return (long)(time - startTime).TotalMilliseconds;
        }

        private static void OutputMaterialsKeyInfo(MaterialKey materialKey, string shaderName)
        {
            List<Material> materialList;
            if (materialKeyListMap.TryGetValue(materialKey, out materialList))
            {
                foreach (var mat in materialList)
                {
                    if (string.IsNullOrEmpty(shaderName) || null == mat.shader || mat.shader.name == shaderName)
                    {
                        Debug.Log(AssetDatabase.GetAssetPath(mat));
                    }
                }
            }
        }

        // 非常重要！
        private static void OptimizeMaterialShader(MaterialKey materialKey, Shader newShader)
        {
            List<Material> materialList;
            if (materialKeyListMap.TryGetValue(materialKey, out materialList))
            {
                foreach (var mat in materialList)
                {
                    ReplaceShader(mat, newShader);
                }
            }
        }

        //  不用 mat.shader = newShader;实属无奈，这个接口会导致material其他属性有可能被改, 非常奇怪。
        // 而这里的新shader和旧shader内容上是相同的！只是希望材质球对新建的shader产生依赖关系
        private static void ReplaceShader(Material material, Shader newShader)
        {
            string materialPath = AssetDatabase.GetAssetPath(material.GetInstanceID());
            Shader originalShader = material.shader;
            string originalMaterialPath = AssetDatabase.GetAssetPath(material);
            string originalGuid = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(originalShader));
            string newGuid = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(newShader));
            if (originalGuid == newGuid)
            {
                return;
            }

            if (string.IsNullOrEmpty(newGuid))
            {
                Debug.LogError("替换shader失败！");
                return;
            }

            string materialStr = File.ReadAllText(materialPath);
            materialStr = materialStr.Replace(originalGuid, newGuid);

            string absolutepath = string.Format("{0}/../{1}", Application.dataPath, materialPath);
            File.WriteAllText(absolutepath, materialStr);
            modifyMaterialPaths.Add(originalMaterialPath);
        }

        // 是否是有效的material
        public static bool IsValidMaterial(string asset)
        {
            if (asset.StartsWith(outputDir))
            {
                return false;
            }

            if (!asset.StartsWith("Assets/Game/"))
            {
                return false;
            }

            return true;
        }

        private class ShaderRecord
        {
            public string newShadeFileName;
            public string orginalShaderPath;
            public long lastWriteTime;
        }

        private class MaterialKey
        {
            public MaterialKey(Shader shader, string[] keywords)
            {
                this.Shader = shader;
                this.Keywords = keywords;
            }

            public Shader Shader { get; private set; }

            public string[] Keywords { get; private set; }
        }

        private class MaterialKeyCompare : IEqualityComparer<MaterialKey>
        {
            private static volatile MaterialKeyCompare defaultComparer;

            /// <summary>
            /// Gets a default instance of the <see cref="MaterialKeyCompare"/>.
            /// </summary>
            public static MaterialKeyCompare Default
            {
                get
                {
                    if (defaultComparer == null)
                    {
                        defaultComparer = new MaterialKeyCompare();
                    }

                    return defaultComparer;
                }
            }

            /// <inheritdoc />
            public bool Equals(MaterialKey x, MaterialKey y)
            {
                return x.Shader == y.Shader &&
                    x.Keywords.SequenceEqual(y.Keywords);
            }

            /// <inheritdoc />
            public int GetHashCode(MaterialKey obj)
            {
                int hashcode = obj.Shader.GetHashCode();
                foreach (var keyword in obj.Keywords)
                {
                    hashcode ^= keyword.GetHashCode();
                }

                return hashcode;
            }
        }
    }
}