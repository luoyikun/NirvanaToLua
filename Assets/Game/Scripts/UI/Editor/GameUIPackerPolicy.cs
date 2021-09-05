//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.Sprites;
using UnityEngine;

/// <summary>
/// Define the game UI packer policy.
/// </summary>
public sealed class GameUIPackerPolicy : IPackerPolicy
{
    public bool AllowSequentialPacking
    {
        get
        {
            return false;
        }
    }

    private string TagPrefix { get { return "[TIGHT]"; } }

    /// <inheritdoc/>
    public int GetVersion()
    {
        return 1;
    }

    /// <inheritdoc/>
    public void OnGroupAtlases(
        BuildTarget target, PackerJob job, int[] textureImporterInstanceIDs)
    {
        var entries = new List<Entry>();

        Dictionary<string, PackGroup> packGroupDic = new Dictionary<string, PackGroup>();
       foreach (int instanceID in textureImporterInstanceIDs)
        {
            var ti = EditorUtility.InstanceIDToObject(instanceID) as TextureImporter;
            BuildPackGroup(packGroupDic, ti);
        }

       foreach (int instanceID in textureImporterInstanceIDs)
        {
            var ti = EditorUtility.InstanceIDToObject(instanceID) as TextureImporter;

            TextureFormat desiredFormat;
            ColorSpace colorSpace;
            int compressionQuality;
            ti.ReadTextureImportInstructions(target, out desiredFormat, out colorSpace, out compressionQuality);

			// Force to use alpha.
			if (desiredFormat == TextureFormat.ETC_RGB4 ||
			   desiredFormat == TextureFormat.ETC2_RGB)
			{
				desiredFormat = TextureFormat.ETC2_RGBA8;
            }

            if (desiredFormat == TextureFormat.PVRTC_RGB2)
            {
                desiredFormat = TextureFormat.PVRTC_RGBA2;
            }

            if (desiredFormat == TextureFormat.PVRTC_RGB4)
            {
                desiredFormat = TextureFormat.PVRTC_RGBA4;
            }

            if (desiredFormat == TextureFormat.RGB24)
            {
                desiredFormat = TextureFormat.RGBA32;
            }

            var tis = new TextureImporterSettings();
            ti.ReadTextureSettings(tis);

            PackGroup packGroup;
            int maxSize = 2048;
            if (packGroupDic.TryGetValue(ti.spritePackingTag, out packGroup))
            {
                maxSize = packGroup.GetMaxPackSize();
            }

            BuildEntries(entries, ti, desiredFormat, colorSpace, compressionQuality, tis.spriteMeshType, maxSize);
        }

        // First split sprites into groups based on atlas name
        var atlasGroups =
            from e in entries
            group e by e.atlasName;
        foreach (var atlasGroup in atlasGroups)
        {
            int page = 0;
            // Then split those groups into smaller groups based on texture settings
            var settingsGroups =
                from t in atlasGroup
                group t by t.settings;
            foreach (var settingsGroup in settingsGroups)
            {
                var atlasName = atlasGroup.Key;
                if (settingsGroups.Count() > 1)
                {
                    atlasName += string.Format(" (Group {0})", page);
                }

                job.AddAtlas(atlasName, settingsGroup.Key);
                foreach (var entry in settingsGroup)
                {
                    job.AssignToAtlas(
                        atlasName,
                        entry.sprite,
                        entry.packingMode,
                        SpritePackingRotation.None);
                }

                ++page;
            }
        }
    }

    private void BuildPackGroup(Dictionary<string, PackGroup> packGroupDic, TextureImporter ti)
    {
        if (string.IsNullOrEmpty(ti.spritePackingTag))
        {
            return;
        }

        PackGroup group;
        if (!packGroupDic.TryGetValue(ti.spritePackingTag, out group))
        {
            group = new PackGroup();
            packGroupDic.Add(ti.spritePackingTag, group);
        }

        var sprites = AssetDatabase.LoadAllAssetRepresentationsAtPath(ti.assetPath);
        foreach (var obj in sprites)
        {
            var sprite = obj as Sprite;
            if (sprite == null)
            {
                continue;
            }

            group.totalSize += Convert.ToInt32((sprite.rect.width * sprite.rect.height));
            if (sprite.rect.width >= 1024 || sprite.rect.height >= 1024)
            {
                group.isForce2048 = true;
            }
        }
    }

    private void BuildEntries(List<Entry> entries, TextureImporter ti, TextureFormat desiredFormat, ColorSpace colorSpace, int compressionQuality, SpriteMeshType meshType, int maxSize)
    {
        var sprites = AssetDatabase.LoadAllAssetRepresentationsAtPath(ti.assetPath);
        foreach (var obj in sprites)
        {
            var sprite = obj as Sprite;
            if (sprite == null)
            {
                continue;
            }

            var entry = new Entry();
            entry.sprite = sprite;
            entry.settings.format = desiredFormat;
            entry.settings.colorSpace = colorSpace;
            entry.settings.compressionQuality = compressionQuality;
            entry.settings.filterMode = Enum.IsDefined(typeof(FilterMode), ti.filterMode) ? ti.filterMode : FilterMode.Bilinear;
            entry.settings.maxWidth = maxSize;
            entry.settings.maxHeight = maxSize;
            entry.settings.paddingPower = 2;
            entry.atlasName = this.ParseAtlasName(ti.spritePackingTag);
            entry.packingMode = this.GetPackingMode(ti.spritePackingTag, meshType);

            entries.Add(entry);
        }

        Resources.UnloadAsset(ti);
    }

    private bool IsTagPrefixed(string packingTag)
    {
        packingTag = packingTag.Trim();
        if (packingTag.Length < TagPrefix.Length)
        {
            return false;
        }

        return (packingTag.Substring(0, TagPrefix.Length) == TagPrefix);
    }

    private string ParseAtlasName(string packingTag)
    {
        string name = packingTag.Trim();
        if (IsTagPrefixed(name))
        {
            name = name.Substring(TagPrefix.Length).Trim();
        }

        return (name.Length == 0) ? "(unnamed)" : name;
    }

    private SpritePackingMode GetPackingMode(
        string packingTag, SpriteMeshType meshType)
    {
        if (meshType == SpriteMeshType.Tight &&
            this.IsTagPrefixed(packingTag))
        {
            return SpritePackingMode.Tight;
        }

        return SpritePackingMode.Rectangle;
    }

    private class Entry
    {
        public Sprite sprite;
        public AtlasSettings settings;
        public string atlasName;
        public SpritePackingMode packingMode;
    }

    private class PackGroup
    {
        public string packName;
        public int totalSize;
        public bool isForce2048;

        public int GetMaxPackSize()
        {
            if (isForce2048)
            {
                return 2048;
            }

            else if (totalSize >= 1024 * 1024 * 2)
            {
                return 2048;
            }
            else
            {
                return 1024;
            }
        }
    }
}

