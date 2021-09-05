using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace AssetsCheck
{
    public class AssetsAutoCheck : EditorWindow
    {
        private Dictionary<CheckerType, bool> checkerDic = new Dictionary<CheckerType, bool>();
        private bool isAllSelectFlag = false;

        [MenuItem("自定义工具/资源检查/批量检查窗口", false, 110)]
        public static void AutoCheck()
        {
            EditorWindow window = EditorWindow.GetWindow(typeof(AssetsAutoCheck));
            window.titleContent = new GUIContent("AssetsAutoCheck");
        }

        private void OnGUI()
        {
            if (GUILayout.Button(!isAllSelectFlag ? "全选" : "取消全选"))
            {
                this.AllSelect(isAllSelectFlag);
            }

            if (GUILayout.Button("批量修复"))
            {
                this.StartFix();
            }

            if (GUILayout.Button("批量检查"))
            {
                this.StartCheck();
            }

            checkerDic.Clear();

            List<CheckerType> list = AssetsChecker.GetAutoCheckTypeList();
            for (int i = 0; i < list.Count; i++)
            {
                this.DrawLogActToggle(list[i]);
            }
        }

        private void DrawLogActToggle(CheckerType checkerType)
        {
            BaseChecker checker = AssetsChecker.GetChecker(checkerType);
            if (null == checker)
            {
                return;
            }

            string name = System.Enum.GetName(typeof(CheckerType), checkerType);
            checker.SetFileName(name);
            string toggle_label = string.Format("{0} （{1}）", name, checker.GetErrorDesc());

            UnityEngine.PlayerPrefs.GetInt("check" + checkerType);
            bool is_act = EditorGUILayout.ToggleLeft(toggle_label, 1 == UnityEngine.PlayerPrefs.GetInt("check" + checkerType));
            UnityEngine.PlayerPrefs.SetInt("check" + checkerType, is_act ? 1 : 0);

            checkerDic.Add(checkerType, is_act);
        }

        private void AllSelect(bool isAllSelectFlag)
        {
            this.isAllSelectFlag = !isAllSelectFlag;

            List<CheckerType> list = new List<CheckerType>();
            foreach (var kv in checkerDic)
            {
                list.Add(kv.Key);
            }

            checkerDic.Clear();
            foreach (var item in list)
            {
                UnityEngine.PlayerPrefs.SetInt("check" + item, this.isAllSelectFlag ? 1 : 0);
                checkerDic.Add(item, this.isAllSelectFlag);
            }
        }

        private void StartCheck()
        {
            AssetsChecker.RefreshErrorStatistics();

            foreach (var kv in checkerDic)
            {
                if (!kv.Value)
                {
                    continue;
                }

                BaseChecker checker = AssetsChecker.GetChecker(kv.Key);
                if (null == checker)
                {
                    continue;
                }

                checker.StartCheck();
                checker.Output();
                AssetsChecker.SaveCacheErrorCount(checker.GetFileName(), checker.ErrorCount, checker.GetErrorDesc());
            }
        }

        private void StartFix()
        {
            foreach (var kv in checkerDic)
            {
                if (!kv.Value)
                {
                    continue;
                }

                BaseChecker checker = AssetsChecker.GetChecker(kv.Key);
                if (null == checker)
                {
                    continue;
                }

                checker.StartFix();
            }
        }
    }
}