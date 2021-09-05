//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

namespace Game
{
    using UnityEditor;
    using UnityEngine;

    /// <summary>
    /// The profiler window for the lua.
    /// </summary>
    public sealed class LuaProfilerWindow : EditorWindow
    {
        private Vector2 scrollPosition;
        private bool showSummary;

        [MenuItem("自定义工具/性能分析/Lua性能分析")]
        public static void ProfileLua()
        {
            EditorWindow.GetWindow<LuaProfilerWindow>(false, "Lua Profiler");
        }

        private void OnGUI()
        {
            // The profile start/stop control. 
            if (LuaProfiler.IsValid)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("Profiling:");
                if (LuaProfiler.Profiling)
                {
                    if (GUILayout.Button("Stop"))
                    {
                        LuaProfiler.Stop();
                    }
                }
                else
                {
                    if (GUILayout.Button("Start"))
                    {
                        LuaProfiler.Start();
                    }
                }

                EditorGUILayout.EndHorizontal();
            }
            else
            {
                EditorGUILayout.HelpBox(
                    "The lua state is not launched.",
                    MessageType.Info);
            }

            // The statistic list.
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("Summary:");
            if (GUILayout.Button("Clean"))
            {
                LuaProfiler.Clean();
            }

            if (GUILayout.Button("Save"))
            {
                var path = EditorUtility.SaveFilePanel(
                    "Save Profile", 
                    Application.dataPath, 
                    "LuaProfile", 
                    "csv");
                if (!string.IsNullOrEmpty(path))
                {
                    LuaProfiler.Save(path);
                }
            }

            EditorGUILayout.EndHorizontal();

            this.showSummary = EditorGUILayout.Toggle(
                "Show Detail", this.showSummary);
            if (this.showSummary)
            {
                this.DrawSummary();
            }
        }

        private void DrawSummary()
        {
            // Draw the header.
            GUILayout.BeginHorizontal();
            GUILayout.Label("Name", GUILayout.MinWidth(275));
            GUILayout.Label("Count", GUILayout.Width(100));
            GUILayout.Label("Total(ms)", GUILayout.Width(100));
            GUILayout.Label("AvgTime(ms)", GUILayout.Width(100));
            GUILayout.Label("MaxTime(ms)", GUILayout.Width(100));
            GUILayout.EndHorizontal();

            // Draw the data.
            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
            var summary = LuaProfiler.SummaryStats;
            foreach (var kv in summary)
            {
                var name = kv.Key;
                var stats = kv.Value;
                GUILayout.BeginHorizontal();
                GUILayout.Label(
                    name, GUILayout.MinWidth(275));
                GUILayout.Label(
                    stats.Count.ToString(),
                    GUILayout.Width(100));
                GUILayout.Label(
                    (stats.Total * 1000).ToString("f2"),
                    GUILayout.Width(100));
                GUILayout.Label(
                    (stats.AvgTime * 1000).ToString("f2"),
                    GUILayout.Width(100));
                GUILayout.Label(
                    (stats.MaxTime * 1000).ToString("f2"),
                    GUILayout.Width(100));
                GUILayout.EndHorizontal();
            }

            EditorGUILayout.EndScrollView();
        }

        private void Update()
        {
            if (LuaProfiler.IsValid && 
                LuaProfiler.Profiling && 
                this.showSummary)
            {
                this.Repaint();
            }
        }
    }
}
