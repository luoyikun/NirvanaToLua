using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using Nirvana;
using System.Reflection;

public class FontTextureReBuild : Singleton<FontTextureReBuild>
{
    private MethodInfo rebuildForFontFun = null;

    private bool isOpen = false;
    private bool isCanRefresh = false;

    private float nextRefreshTime = 0;
    private HashSet<Font> dirtyFontSet = new HashSet<Font>();

    public FontTextureReBuild()
    {
        System.Type fontUpdateTrackerType = typeof(FontUpdateTracker);
        rebuildForFontFun = fontUpdateTrackerType.GetMethod("RebuildForFont", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);

        Font.textureRebuilt += delegate (Font font)
        {
            if (!this.isOpen || null == font)
            {
                return;
            }

            if (!dirtyFontSet.Contains(font))
            {
                dirtyFontSet.Add(font);
            }

            nextRefreshTime = Time.time + 1;
        };
    }

    public void OnGameStop()
    {
        dirtyFontSet.Clear();
    }

    // 提供功能关开启接口，以快速关闭该功能
    public void SetIsOpen(bool isOpen)
    {
        this.isOpen = isOpen;
    }

    public void SetCanRefresh(bool isCanRefresh)
    {
        this.isCanRefresh = isCanRefresh;
    }

    public void Update()
    {
        if (!this.isOpen)
        {
            return;
        }

        if (!this.isCanRefresh)
        {
            return;
        }

        if (dirtyFontSet.Count > 0 && Time.time >= nextRefreshTime)
        {
            try
            {
                foreach (var font in dirtyFontSet)
                {
                    rebuildForFontFun.Invoke(null, new object[] { font });
                }
            }
            catch (System.Exception)
            {
                throw;
            }
            finally
            {
                dirtyFontSet.Clear();
            }
        }
    }
}