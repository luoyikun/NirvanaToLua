using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;
using EditorSupport;
using UnityEditor.SceneManagement;

[CustomEditor(typeof(CameraFollow))]
public class CameraFollow2Editor : Editor
{
	private string[] _toolbarChoices = new string[] { "目标", "移动", "缩放" };
	private int _toolbarSelection = 0;

	private bool _init = false;

	private CameraFollow _self;

	public override void OnInspectorGUI()
	{
		DrawDefaultInspector();

		_self = (CameraFollow)target;

		if (!_init) {
			_init = true;
		}

		bool allowSceneObjects = !EditorUtility.IsPersistent(_self);

		_toolbarSelection = GUILayout.Toolbar(_toolbarSelection, _toolbarChoices);

		if(_toolbarSelection == 0)
		{

			_self.target = (Transform)EditorGUILayout.ObjectField("目标", _self.target, typeof(Transform), allowSceneObjects);
			_self.TargetOffset = EditorGUILayout.Vector3Field("目标偏移", _self.TargetOffset);
		}
		else if(_toolbarSelection == 1)
		{
			if (_self.IsChangeAngle) 
			{
				_self.ChangeAngle(EditorGUILayout.Vector2Field ("初始旋转", _self.OriginAngle));
			} 
			else
			{
				_self.OriginAngle = EditorGUILayout.Vector2Field("初始旋转", _self.OriginAngle);
			}

            _self.AllowRotation = EditorGUILayout.Toggle("是否可以旋转", _self.AllowRotation);
            _self.AllowXRotation = EditorGUILayout.Toggle("是否可以绕X轴旋转", _self.AllowXRotation);
            _self.AllowYRotation = EditorGUILayout.Toggle("是否可以绕Y轴旋转", _self.AllowYRotation);
			_self.IsChangeAngle = EditorGUILayout.Toggle("是否可以旋转角度", _self.IsChangeAngle);

			if(_self.AllowRotation && (_self.AllowXRotation || _self.AllowYRotation))
			{
				EditorGUI.indentLevel++;

				EditorGUILayout.LabelField("旋转角度限制 [x轴Min: " + _self.MinPitchAngle + " | x轴Max: " + _self.MaxPitchAngle + "]");
				EditorGUILayout.MinMaxSlider(ref _self.MinPitchAngle, ref _self.MaxPitchAngle, -85, 85);

                GUILayout.Space(5);

                /*EditorGUILayout.LabelField("旋转角度限制 [y轴Min: " + _self.MinYawAngle + " | y轴Max: " + _self.MaxYawAngle + "]");
				EditorGUILayout.MinMaxSlider(ref _self.MinYawAngle, ref _self.MaxYawAngle, -10, 10);*/

                _self.MinYawAngle = EditorGUILayout.Slider("y轴旋转最小角度", _self.MinYawAngle, -50, 0);
                _self.MaxYawAngle = EditorGUILayout.Slider("y轴旋转最大角度", _self.MaxYawAngle, 0, 50);

				_self.MinPitchAngle = Mathf.Round(_self.MinPitchAngle);
				_self.MaxPitchAngle = Mathf.Round(_self.MaxPitchAngle);

				_self.RotationSmoothing = EditorGUILayout.FloatField("Sensitivity", _self.RotationSmoothing);


				EditorGUI.indentLevel--;
			}
		}
		else if(_toolbarSelection == 2)
		{
			#region Zoom Settings

			_self.AllowZoom = EditorGUILayout.Toggle("是否可以缩放", _self.AllowZoom);

			if(_self.AllowZoom)
			{
				EditorGUI.indentLevel++;

				_self.ZoomSmoothing = EditorGUILayout.FloatField("缩放平滑度", _self.ZoomSmoothing);

				EditorGUI.indentLevel--;
			}

			_self.Distance = EditorGUILayout.FloatField("距离", _self.Distance);
			EditorGUI.indentLevel++;
			EditorGUILayout.LabelField("[Min: " + _self.MinDistance + " | Max: " + _self.MaxDistance + "]");
			EditorGUILayout.MinMaxSlider(ref _self.MinDistance, ref _self.MaxDistance, 1, 200);
			EditorGUI.indentLevel--;

			_self.MinDistance = Mathf.Round(_self.MinDistance);
			_self.MaxDistance = Mathf.Round(_self.MaxDistance);

			#endregion
		}

		if(GUI.changed)
		{
			EditorUtility.SetDirty(_self);

            _self.ClampRotationAndDistance();
            _self.SyncFieldOfView();
            _self.SyncRotation();

            if (!Application.isPlaying)
            {
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
            }
		}
	}
}
