using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.UI;

public class ShowFPS : MonoBehaviour
{
	public float fpsMeasuringDelta = 1f;
	private static bool swich = false;
	private float timePassed;
	private int m_FrameCount = 0;
	private float m_FPS = 0.0f;
	private Rect rect1 = new Rect((Screen.width / 2) - 300, 0, 100, 100);
	private Rect rect2 = new Rect((Screen.width / 2) - 170, 0, 100, 100);
	private Rect rect3 = new Rect((Screen.width / 2) + 20, 0, 100, 100);
	GUIStyle lua;
	GUIStyle memory;
	GUIStyle bb;
	public Text text;
	string s;
	string format = "fps:{0} 内存:{1} lua:{2} dc:{3}";
    //string format = "lua:{0} dc:{1}";

    private void Start()
	{
		timePassed = 0.0f;
        swich = Debug.isDebugBuild;
    }

	private void Update()
	{
        if (swich)
		{
			m_FrameCount = m_FrameCount + 1;
			timePassed = timePassed + Time.deltaTime;

			if (timePassed > fpsMeasuringDelta)
			{
				m_FPS = (int)Math.Floor((m_FrameCount / timePassed));
				timePassed = 0.0f;
				m_FrameCount = 0;
                var totalmemory = Profiler.GetTotalAllocatedMemoryLong() / 1000000;
                var totalReserver = Profiler.GetTotalReservedMemoryLong() / 1000000;
                var luamemory = (int)(GameRoot.Instance.Collectgarbage("count") / 1000);
#if UNITY_EDITOR
				var drawcall = UnityEditor.UnityStats.batches;
#else
				var drawcall = "无法获取";
#endif
                s = string.Format(format, m_FPS, totalmemory + totalReserver, luamemory, drawcall);
                //s = string.Format(format, luamemory, drawcall);
                text.text = s;
			}
		}
		else
		{
			return;
		}
	}

	private void OnGUI()
	{
		
	}

	public static void SetSwich(bool on)
	{
        swich = on;
	}
}

