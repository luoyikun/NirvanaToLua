using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

public class TextureAssetImporter : AssetPostprocessor
{
    private static string GameDir = "Assets/Game/";
    private static string UiDir = "Assets/Game/UIs/";
    private static string EffectsDir = "Assets/Game/Effects";
    private static string Effects2Dir = "Assets/Game/Effects2";
    private static string ViewDir = "Assets/Game/UIs/Views/";
    private static string ImagesDir = "Assets/Game/UIs/Images/";
    private static string Images2Dir = "Assets/Game/UIs/Images2/";
    private static string MainUIImageDir = "Assets/Game/UIs/Views/MainUI";
    private static string IconsDir = "Assets/Game/UIs/Icons/";
    private static string FontDir = "Assets/Game/UIs/Fonts/";
    private static string RawImageDir = "Assets/Game/UIs/RawImages/";
    private static string ActorsDir = "Assets/Game/Actors/";
    private static string RoleDir = "Assets/Game/Actors/Role/";
    private static string NpcDir = "Assets/Game/Actors/NPC/";
    private static string MountDir = "Assets/Game/Actors/Mount/";
    private static string GoddessDir = "Assets/Game/Actors/Goddess/";
    private static string SceneEnviromentDir = "Assets/Game/Environments/";

    public static string ItemIconDir = "Assets/Game/UIs/Icons/Item/";
    public static string TitleIconDir = "Assets/Game/UIs/Icons/Title/";
    public static string SkillIconDir = "Assets/Game/UIs/Icons/Skill/";
    public static string BossIconDir = "Assets/Game/UIs/Icons/Boss/";
    public static string HeadFrameIconDir = "Assets/Game/UIs/Icons/HeadFrame/";
    public static string ActivityIconDir = "Assets/Game/UIs/Icons/Activity/";
    public static string ZhuanzhiIconDir = "Assets/Game/UIs/Icons/Zhuanzhi/";

    private static HashSet<string> tempIgnoreAssets = new HashSet<string>();

    private void OnPreprocessTexture()
    {
        TextureImporter textureImporter = (TextureImporter)assetImporter;
        if (HideFlags.NotEditable == textureImporter.hideFlags)
        {
            return;
        }

        if (tempIgnoreAssets.Contains(assetImporter.assetPath))
        {
            return;
        }

        if (ImporterUtils.CheckLabel(assetPath))
        {
            return;
        }

        ProcessTextureType(textureImporter);
        ProcessPackingTag(textureImporter);
        ProcessMipmap(textureImporter);
        ProcessReadable(textureImporter, assetPath);
        ProcessFilterMode(textureImporter);
        ProcessAdvancedAndWrapMode(textureImporter);
        ProcessScenePlatformSetting(textureImporter);
    }

    private void OnPostprocessTexture(Texture2D texture)
    {
        TextureImporter textureImporter = (TextureImporter)assetImporter;
        if (tempIgnoreAssets.Contains(assetImporter.assetPath))
        {
            return;
        }

        ProcessResizeTextureToMutiple4(textureImporter, texture);
    }

    private void ProcessTextureType(TextureImporter textureImporter)
    {
        if (textureImporter.assetPath.StartsWith(FontDir)
            || textureImporter.assetPath.StartsWith(ViewDir)
            || textureImporter.assetPath.StartsWith(IconsDir)
            || textureImporter.assetPath.StartsWith(Images2Dir)
            || textureImporter.assetPath.StartsWith(ImagesDir))
        {
            textureImporter.textureType = TextureImporterType.Sprite;
        }
        else if (textureImporter.assetPath.StartsWith(RawImageDir))
        {
            textureImporter.textureType = TextureImporterType.Default;
        }
    }

    private void ProcessPackingTag(TextureImporter textureImporter)
    {
        if (TextureImporterType.Sprite != textureImporter.textureType
                   || textureImporter.assetPath.Contains("/nopack/")
                   || textureImporter.assetPath.StartsWith(FontDir)
                    || textureImporter.assetPath.StartsWith(TitleIconDir)
                    || textureImporter.assetPath.StartsWith(SkillIconDir)
                    || textureImporter.assetPath.StartsWith(HeadFrameIconDir)
                    || textureImporter.assetPath.StartsWith(BossIconDir)
                    || textureImporter.assetPath.StartsWith(ActivityIconDir)
                    || textureImporter.assetPath.StartsWith(ItemIconDir)
                    || textureImporter.assetPath.StartsWith(ZhuanzhiIconDir))
        {
            textureImporter.spritePackingTag = string.Empty;
            return;
        }

        if (textureImporter.assetPath.StartsWith(MainUIImageDir))
        {
            textureImporter.spritePackingTag = "uis/views/main/images";
            return;
        }

        if (textureImporter.assetPath.StartsWith(Images2Dir))
        {
            textureImporter.spritePackingTag = "uis/images2";
            return;
        }

        if (textureImporter.assetPath.StartsWith(ImagesDir))
        {
            textureImporter.spritePackingTag = "uis/images";
            return;
        }

        string pack_tag = textureImporter.assetPath.Replace(GameDir, "").ToLower();
        pack_tag = pack_tag.Substring(0, pack_tag.LastIndexOf("/"));
        textureImporter.spritePackingTag = pack_tag;
    }

    private void ProcessMipmap(TextureImporter textureImporter)
    {
        if (textureImporter.assetPath.StartsWith(SceneEnviromentDir)
            || textureImporter.textureType == TextureImporterType.Lightmap
            || textureImporter.textureShape != TextureImporterShape.Texture2D)
        {
            textureImporter.mipmapEnabled = true;
            return;
        }

        textureImporter.mipmapEnabled = false;
    }

    private void ProcessReadable(TextureImporter textureImporter, string assetPath)
    {

        textureImporter.isReadable = assetPath.StartsWith(FontDir);
    }

    private void ProcessFilterMode(TextureImporter textureImporter)
    {
        if (TextureImporterType.Sprite == textureImporter.textureType)
        {
            textureImporter.filterMode = FilterMode.Bilinear;
        }
    }

    private void ProcessAdvancedAndWrapMode(TextureImporter textureImporter)
    {
        if (textureImporter.assetPath.StartsWith(RawImageDir))
        {
            textureImporter.alphaIsTransparency = false;
            textureImporter.npotScale = TextureImporterNPOTScale.None;
            textureImporter.wrapMode = TextureWrapMode.Clamp;
        }
    }

    private void ProcessScenePlatformSetting(TextureImporter textureImporter)
    {
        if (textureImporter.assetPath.StartsWith(FontDir))
        {
            return;
        }

        if (textureImporter.assetPath.StartsWith(EffectsDir) || textureImporter.assetPath.StartsWith(Effects2Dir))
        {
            TextureImporterPlatformSettings settings = textureImporter.GetPlatformTextureSettings("iPhone");
            settings.overridden = true;
            if (textureImporter.DoesSourceTextureHaveAlpha())
            {
                settings.format = TextureImporterFormat.PVRTC_RGBA4;
            }
            else
            {
                settings.format = TextureImporterFormat.PVRTC_RGB4;
            }
            textureImporter.SetPlatformTextureSettings(settings);

            settings = textureImporter.GetPlatformTextureSettings("Android");
            settings.overridden = true;
            settings.compressionQuality = 80;
            if (string.IsNullOrEmpty(textureImporter.spritePackingTag) && !textureImporter.DoesSourceTextureHaveAlpha())
            {
                settings.format = TextureImporterFormat.ETC_RGB4Crunched;
            }
            else
            {
                settings.format = TextureImporterFormat.ETC2_RGBA8Crunched;
            }
            textureImporter.SetPlatformTextureSettings(settings);
        }
        else
        {
            //ui的ios格式用astc
            TextureImporterPlatformSettings settings;
            if (textureImporter.assetPath.StartsWith(UiDir))
            {
                settings = textureImporter.GetPlatformTextureSettings("iPhone");
                settings.overridden = true;
                if (textureImporter.DoesSourceTextureHaveAlpha())
                {
                    settings.format = TextureImporterFormat.ASTC_RGBA_6x6;
                }
                else
                {
                    settings.format = TextureImporterFormat.ASTC_RGB_6x6;
                }
                textureImporter.SetPlatformTextureSettings(settings);
            }
            else if (textureImporter.textureType == TextureImporterType.Lightmap)
            {
                settings = textureImporter.GetPlatformTextureSettings("iPhone");
                settings.overridden = true;
                if (textureImporter.DoesSourceTextureHaveAlpha())
                {
                    settings.format = TextureImporterFormat.ASTC_RGBA_4x4;
                }
                textureImporter.SetPlatformTextureSettings(settings);
            }
            else
            {
                settings = textureImporter.GetPlatformTextureSettings("iPhone");
                settings.overridden = true;
                if (textureImporter.DoesSourceTextureHaveAlpha())
                {
                    settings.format = TextureImporterFormat.PVRTC_RGBA4;
                }
                else
                {
                    settings.format = TextureImporterFormat.PVRTC_RGB4;
                }
                textureImporter.SetPlatformTextureSettings(settings);
            }

            //android
            settings = textureImporter.GetPlatformTextureSettings("Android");
            settings.overridden = true;
            if (string.IsNullOrEmpty(textureImporter.spritePackingTag) && !textureImporter.DoesSourceTextureHaveAlpha())
            {
                settings.format = TextureImporterFormat.ETC2_RGB4;
            }
            else
            {
                settings.format = TextureImporterFormat.ETC2_RGBA8;
            }
            textureImporter.SetPlatformTextureSettings(settings);
        }
    }

    private static void ProcessResizeTextureToMutiple4(TextureImporter textureImporter, Texture2D texture)
    {
        if (!string.IsNullOrEmpty(textureImporter.spritePackingTag)
            || textureImporter.assetPath.StartsWith(FontDir))
        {
            return;
        }

        int newWidth = texture.width;
        if (texture.width % 4 != 0)
        {
            newWidth = 4 - texture.width % 4 + texture.width;
        }

        int newHeight = texture.height;
        if (texture.height % 4 != 0)
        {
            newHeight = 4 - texture.height % 4 + texture.height;
        }

        if (newWidth != texture.width || newHeight != texture.height)
        {
            tempIgnoreAssets.Add(textureImporter.assetPath);
            textureImporter.isReadable = true;
            textureImporter.SaveAndReimport();

            var newTexture = new Texture2D(newWidth, newHeight);

            for (int x = 0; x < newTexture.width; ++x)
            {
                for (int y = 0; y < newTexture.height; ++y)
                {
                    newTexture.SetPixel(x, y, new Color(0, 0, 0, 0));
                }
            }

            newTexture.SetPixels32(newWidth != texture.width ? 1 : 0, newHeight != texture.height ? 1 : 0, texture.width, texture.height, texture.GetPixels32());
            var bytes = newTexture.EncodeToPNG();
            File.WriteAllBytes(textureImporter.assetPath, bytes);

            textureImporter.isReadable = false;
            textureImporter.SaveAndReimport();
            tempIgnoreAssets.Remove(textureImporter.assetPath);
        }
    }
}