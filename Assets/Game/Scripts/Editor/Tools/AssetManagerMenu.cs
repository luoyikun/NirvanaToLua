
namespace Game
{
    using UnityEngine;
    using UnityEditor;

    public static class AssetManagerMenu
    {
        private const string MenuRoot = "自定义工具/AssetManager/";
        private const string SimulateAssetBundlesModeKey = "SimulateAssetBundlesMode";

        private static int simulateAssetBundle = -1;
        private static int SimulateAssetBundle
        {
            get
            {
                if (simulateAssetBundle == -1)
                {
                    simulateAssetBundle = EditorPrefs.GetInt(SimulateAssetBundlesModeKey, 1);
                }

                return simulateAssetBundle;
            }

            set
            {
                simulateAssetBundle = value;
                EditorPrefs.SetInt(SimulateAssetBundlesModeKey, value);
            }
        }

        [MenuItem(MenuRoot + "No Simulate AssetBundles", false, 0)]
        public static void NoSimulateAssetBundleFunc()
        {
            SimulateAssetBundle = 0;
        }

        [MenuItem(MenuRoot + "No Simulate AssetBundles", true, 0)]
        private static bool NoSimulateAssetBundlesValidate()
        {
            Menu.SetChecked(
                MenuRoot + "No Simulate AssetBundles",
                SimulateAssetBundle == 0);
            return true;
        }

        [MenuItem(MenuRoot + "Simulate AssetBundles", false, 1)]
        public static void SimulateAssetBundleFunc()
        {
            SimulateAssetBundle = 1;
        }

        [MenuItem(MenuRoot + "Simulate AssetBundles", true, 1)]
        private static bool SimulateAssetBundlesValidate()
        {
            Menu.SetChecked(
                MenuRoot + "Simulate AssetBundles",
                SimulateAssetBundle == 1);
            return true;
        }
    }
}
