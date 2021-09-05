using AssetsCheck;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using UnityEditor;
using UnityEngine;


public static class AutoCheckAll
{
    // 检查所有
    public static void CheckAll()
    {
        AssetsChecker.RefreshErrorStatistics();
        List<CheckerType> list = AssetsChecker.GetAutoCheckTypeList();
        foreach (var item in list)
        {
            BaseChecker checker = AssetsChecker.GetChecker(item);
            if (null != checker)
            {
                checker.SetFileName(System.Enum.GetName(typeof(CheckerType), item));
                checker.StartCheck();
                checker.Output();
                AssetsChecker.SaveCacheErrorCount(checker.GetFileName(), checker.ErrorCount, checker.GetErrorDesc());
            }
        }
    }
}

namespace AssetsCheck
{
    class ErrorItem
    {
        public int count;
        public string desc;
    }

    public static class AssetsChecker
    {
        private static Dictionary<CheckerType, BaseChecker> checkerDic = new Dictionary<CheckerType, BaseChecker>();
        private static Dictionary<string, ErrorItem> statisticsErrorDic = new Dictionary<string, ErrorItem>();

        // 更新错误统计
        public static void RefreshErrorStatistics()
        {
            if (!Directory.Exists(AssetsCheckConfig.OutputDir))
            {
                Directory.CreateDirectory(AssetsCheckConfig.OutputDir);
            }

            if (!Directory.Exists(AssetsCheckConfig.ExcludeDir))
            {
                Directory.CreateDirectory(AssetsCheckConfig.ExcludeDir);
            }

            statisticsErrorDic.Clear();

            string[] lines;
            ReadErrorStatisticsLines(out lines);
            for (int i = 0; i < lines.Length; i++)
            {
                string[] ary = lines[i].Split(' ');
                if (ary.Length >= 3 && !string.IsNullOrEmpty(ary[0]) && Convert.ToInt32(ary[1]) > 0)
                {
                    ErrorItem error_item = new ErrorItem();
                    error_item.count = Convert.ToInt32(ary[1]);
                    error_item.desc = ary[2];
                    statisticsErrorDic.Add(ary[0], error_item);
                }
            }
        }

        // 保存错误数量
        public static void SaveCacheErrorCount(string checkerName, int count, string desc)
        {
            ErrorItem error_item;
            if (!statisticsErrorDic.TryGetValue(checkerName, out error_item))
            {
                error_item = new ErrorItem();
                statisticsErrorDic.Add(checkerName, error_item);
            }

            error_item.count = count;
            error_item.desc = desc;

            WriteStatisticsError();
        }

        // 读取本地存储的错误统计
        public static void ReadErrorStatisticsLines(out string[] lines)
        {
            string path = Path.Combine(AssetsCheckConfig.OutputDir, "ErrorStatistics.txt");
            if (File.Exists(path))
            {
                lines = File.ReadAllLines(path);
            }
            else
            {
                lines = new string[] { };
            }
        }

        // 写在本地
        private static void WriteStatisticsError()
        {
            StringBuilder builder = new StringBuilder();
            foreach (var item in statisticsErrorDic)
            {
                if (!string.IsNullOrEmpty(item.Key) && item.Value.count > 0)
                {
                    builder.Append(string.Format("{0} {1} {2}\n", item.Key, item.Value.count, item.Value.desc));
                }
            }
            File.WriteAllText(Path.Combine(AssetsCheckConfig.OutputDir, "ErrorStatistics.txt"), builder.ToString());
        }

        // 获得每种检查缓存起来的错误数量
        public static int GetCacheErrorCount(string checkerName)
        {
            if (statisticsErrorDic.ContainsKey(checkerName))
            {
                return statisticsErrorDic[checkerName].count;
            }

            return 0;
        }

        // 根据类型获得检查器
        public static BaseChecker GetChecker(CheckerType type)
        {
            BaseChecker checker;
            if (!checkerDic.TryGetValue(type, out checker))
            {
                // UI相关
                if (CheckerType.UITexture == type) checker = new UITextureChecker();
                if (CheckerType.UIAtlas == type) checker = new UIAtlasChecker();
                if (CheckerType.UIBundleDepend == type) checker = new UIBundleDependCheck();
                if (CheckerType.UICommonImageRef == type) checker = new UICommonImageRefChecker();
                if (CheckerType.UIIconImageRef == type) checker = new UIIconmageRefChecker();
                if (CheckerType.UIRawImage == type) checker = new UIRawimageChecker();

                // 组件类
                // 特效
                if (CheckerType.ParticleSystemSetting == type) checker = new ParticleSystemSettingChecker();
                if (CheckerType.UIEffectAttach == type) checker = new UIEffectAttachChecker();
                if (CheckerType.EffectDependUIRes == type) checker = new EffectDependUIResChecker();

                // 材质球
                if (CheckerType.Material == type) checker = new MaterialChecker();
                if (CheckerType.LowMaterialChecker == type) checker = new LowMaterialChecker();
                
                // 角色相关
                if (CheckerType.ActorModel == type) checker = new ActorModelChecker();
                if (CheckerType.ActorReceivedShadow == type) checker = new ActorReceivedShadowChecker();
                if (CheckerType.ActorGameObjectAttach == type) checker = new ActorGameObjectAttachChecker();

                // 场景相关
                if (CheckerType.SceneEdit == type) checker = new SceneEditChecker();
                if (CheckerType.SceneMeshCollider == type) checker = new SceneMeshColliderChecker();
                if (CheckerType.SceneCastShadow == type) checker = new SceneCastShadowChecker();
                if (CheckerType.SceneBatchChecker == type) checker = new SceneBatchChecker();

                // 其他
                if (CheckerType.LuaConfigMemory == type) checker = new LuaConfigMemoryChecker();
                if (CheckerType.AssetBundleVariant == type) checker = new AssetBundleVariantChecker();
                if (CheckerType.AssetBundleLoopDepend == type) checker = new AssetBundleLoopDepend();
                if (CheckerType.GameObjectAttachMissing == type) checker = new GameObjectAttachMissingChecker();

                checkerDic.Add(type, checker);
            }

            return checker;
        }

        public static List<CheckerType> GetAutoCheckTypeList()
        {
            List<CheckerType> list = new List<CheckerType>();
            FieldInfo[] fields = typeof(CheckerType).GetFields();
            for (int i = 1; i < fields.Length; i++)
            {
                CheckerType checkerType = (CheckerType)fields[i].GetValue(null);
                list.Add(checkerType);
            }

            return list;
        }
    }
}
