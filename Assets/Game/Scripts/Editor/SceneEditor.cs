
using UnityEngine;
using UnityEditor;
using UnityObject = UnityEngine.Object;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;

public class SceneMerge : EditorWindow
{
    private UnityObject dirObject;

    [MenuItem("Tools/UI Tools/Scene Editor", false, 110)]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(SceneMerge), false, "Scene Editor");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
        window.minSize = new Vector2(300, 300);
    }

    private void OnGUI()
    {
        dirObject = EditorGUILayout.ObjectField("目录：", dirObject, typeof(UnityObject), false);

        GUILayout.Space(10);

        if (GUILayout.Button("Merge Main & Detail"))
        {
            if (dirObject == null)
            {
                return;
            }

            var allFilePaths = GetNeedMergeFilePath();

            int count = 0;
            foreach (var filePath in allFilePaths)
            {
                var progress = count / (float)allFilePaths.Count;

                var main_scene_path = GetScenePathWithEndTag(filePath, "_Main.unity");
                var detail_scene_path = GetScenePathWithEndTag(filePath, "_Detail.unity");

                if (File.Exists(main_scene_path) && File.Exists(detail_scene_path))
                {
                    var main_scene = EditorSceneManager.OpenScene(main_scene_path, OpenSceneMode.Additive);
                    var detail_scene = EditorSceneManager.OpenScene(detail_scene_path, OpenSceneMode.Additive);

                    if (main_scene.IsValid() && detail_scene.IsValid())
                    {
                        var objs = detail_scene.GetRootGameObjects();
                        foreach (var obj in objs)
                        {
                            SceneManager.MoveGameObjectToScene(obj, main_scene);
                        }
                    }

                    EditorSceneManager.SaveScene(main_scene);

                    EditorSceneManager.CloseScene(main_scene, true);
                    EditorSceneManager.CloseScene(detail_scene, true);

                    File.Delete(detail_scene_path);

                    var detail_scene_meta_path = GetScenePathWithEndTag(filePath, "_Detail.unity.meta");
                    if (File.Exists(detail_scene_meta_path))
                    {
                        File.Delete(detail_scene_meta_path);
                    }

                    EditorUtility.DisplayProgressBar("合并地图", string.Format("{0}/{1}", count, allFilePaths.Count), progress);

                    count++;
                }
            }

            EditorUtility.ClearProgressBar();
        }

        if (GUILayout.Button("Delete Main Camera"))
        {
            if (dirObject == null)
            {
                return;
            }

            var allFilePaths = GetNeedMergeFilePath();

            int count = 0;
            foreach (var filePath in allFilePaths)
            {
                var progress = count / (float)allFilePaths.Count;

                var main_scene_path = GetScenePathWithEndTag(filePath, "_Main.unity");

                if (File.Exists(main_scene_path))
                {
                    var main_scene = EditorSceneManager.OpenScene(main_scene_path, OpenSceneMode.Additive);

                    if (main_scene.IsValid())
                    {
                        var objs = main_scene.GetRootGameObjects();
                        foreach (var obj in objs)
                        {
                            //这里找到那个CameraFollow然后删除
                             var camera_follow = obj.GetComponentInChildren<CameraFollow>();
                            GameObject.Destroy(camera_follow.gameObject);
                        }
                    }

                    EditorSceneManager.SaveScene(main_scene);

                    EditorSceneManager.CloseScene(main_scene, true);

                    EditorUtility.DisplayProgressBar("删除 MainCamera", string.Format("{0}/{1}", count, allFilePaths.Count), progress);

                    count++;
                }
            }

            EditorUtility.ClearProgressBar();
        }

        if (GUILayout.Button("Set SceneGrid Size"))
        {
            if (dirObject == null)
            {
                return;
            }

            HashSet<string> needChangeFileList = new HashSet<string>();

            var allFilePaths = GetNeedMergeFilePath();
            foreach (var filePath in allFilePaths)
            {
                DirectoryInfo direction = new DirectoryInfo(filePath);
                FileInfo[] files = direction.GetFiles("*.unity", SearchOption.TopDirectoryOnly);

                for (int i = 0; i < files.Length; i++)
                {
                    if ((files[i].Name.Contains("_Logic") || files[i].Name.Contains("_logic")))
                    {
                        var change_scene_path = string.Format("{0}/{1}", filePath, files[i].Name);
                        if (!File.Exists(change_scene_path)) continue;

                        needChangeFileList.Add(change_scene_path);
                    }
                }
            }

            int count = 0;
            foreach (var change_scene_path in needChangeFileList)
            {
                var main_scene = EditorSceneManager.OpenScene(change_scene_path, OpenSceneMode.Additive);
                if (main_scene.IsValid())
                {
                    var objs = main_scene.GetRootGameObjects();
                    foreach (var obj in objs)
                    {
                        SceneGridView scene_grid_view = obj.GetComponentInChildren<SceneGridView>();
                        if (scene_grid_view)
                        {
                            Vector2 old_cell_size = scene_grid_view.CellSize;
                            if (old_cell_size.x == 0.5f && old_cell_size.y == 0.5f)
                            {
                                scene_grid_view.Initialize();
                                scene_grid_view.Resize(0, 0, -scene_grid_view.Row / 2, -scene_grid_view.Column / 2);
                            }
                            scene_grid_view.CellSize = new Vector2(1.0f, 1.0f);
                        }
                    }
                }

                EditorSceneManager.SaveScene(main_scene);
                EditorSceneManager.CloseScene(main_scene, true);

                count++;
                var progress = count / (float)needChangeFileList.Count;
                EditorUtility.DisplayProgressBar("Set SceneGrid Size", string.Format("{0}/{1}", count, needChangeFileList.Count), progress);
            }

            EditorUtility.ClearProgressBar();
        }

        GUILayout.Space(20);
    }

    private string GetScenePathWithEndTag(string path, string end)
    {
        string name = "";

        if (Directory.Exists(path))
        {
            DirectoryInfo direction = new DirectoryInfo(path);
            FileInfo[] files = direction.GetFiles("*", SearchOption.TopDirectoryOnly);

            for (int i = 0; i < files.Length; i++)
            {
                if (files[i].Name.EndsWith(end))
                {
                    name = files[i].Name;
                    break;
                }
            }
        }

        return string.Format("{0}/{1}", path, name);
    }

    private HashSet<string> GetNeedMergeFilePath()
    {
        var path = AssetDatabase.GetAssetPath(dirObject);

        HashSet<string> needMergeFileList = new HashSet<string>();

        var scenes = AssetDatabase.GetSubFolders(path);
        foreach (var scene in scenes)
        {
            needMergeFileList.Add(scene);
        }

        return needMergeFileList;
    }
}
