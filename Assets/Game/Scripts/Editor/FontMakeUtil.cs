using Nirvana.Editor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class FontMakeUtil
{
    private static string fontDir = "Assets/Game/UIs/Fonts";

    [MenuItem("自定义工具/技术专用/生成字体")]
    public static void Build()
    {
        string[] guids = AssetDatabase.FindAssets("t:fontmaker", new string[] { fontDir });

        List<Texture2D> textureList = new List<Texture2D>();
        List<FontMaker> fontMakerList = new List<FontMaker>();
        List<string> dirList = new List<string>();
        for (int i = 0; i < guids.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[i]);
            FontMaker fontMaker = AssetDatabase.LoadAssetAtPath<FontMaker>(path);
            if (!FetchAllTexture(fontMaker, textureList))
            {
                return;
            }
            dirList.Add(Path.GetDirectoryName(path));
            fontMakerList.Add(fontMaker);
        }

        Rect[] rects;
        Material material;
        CreateMaterial(textureList, out rects, out material);

        int rectIndex = 0;
        for (int i = 0; i < fontMakerList.Count; i++)
        {
            string fontPath = string.Format("{0}/{1}.fontsettings", dirList[i], fontMakerList[i].atlasName);
            CreateTTF(fontPath, fontMakerList[i], material, rects, ref rectIndex);
        }
    }

    private static bool FetchAllTexture(FontMaker fontMaker, List<Texture2D> textureList)
    {
        foreach (var font in fontMaker.fonts)
        {
            foreach (var glyph in font.Glyphs)
            {
                if (glyph.Image == null)
                {
                    Debug.LogErrorFormat("The font {0} with graph: {1} is missing texture.", font.FontName, glyph.Code);
                    return false;
                }

                var imagePath = AssetDatabase.GetAssetPath(glyph.Image);
                ImporterUtils.SetLabel(imagePath, ImporterUtils.ReadableLabel);
                textureList.Add(glyph.Image);
            }
        }

        return true;
    }

    private static void CreateMaterial(List<Texture2D> textureList, out Rect[] rects, out Material material)
    {
        // Build the atlas.
        var atlas = new Texture2D(0, 0, TextureFormat.ARGB32, false);
        atlas.name = "Font Atlas";
        rects = atlas.PackTextures(textureList.ToArray(), 2, 2048, false);

        // Save the atlas to PNG.

        var atlasPath = Path.Combine(fontDir, "FontAtlas.png");
        var matPath = Path.Combine(fontDir, "FontAtlas.mat");

        var bytes = atlas.EncodeToPNG();
        var fileStream = File.OpenWrite(atlasPath);
        fileStream.Write(bytes, 0, bytes.Length);
        fileStream.Close();
        AssetDatabase.Refresh();

        var atlasTex = AssetDatabase.LoadAssetAtPath<Texture>(atlasPath);

        // Create the font material
        material = AssetDatabase.LoadAssetAtPath<Material>(matPath);
        if (material == null)
        {
            var shader = Shader.Find("Transparent/Diffuse");
            material = new Material(shader);
            AssetDatabase.CreateAsset(material, matPath);
        }

        material.mainTexture = atlasTex;
        EditorUtility.SetDirty(material);
        AssetDatabase.SaveAssets();

        // Force to refresh the asset database.
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    private static void CreateTTF(string fontPath, FontMaker fontMaker, Material material, Rect[] rects, ref int rectIndex)
    {
        foreach (var font in fontMaker.fonts)
        {
            var glyphs = font.Glyphs;
            if (glyphs.Length == 0)
            {
                continue;
            }

            var customFont = AssetDatabase.LoadAssetAtPath<Font>(fontPath);
            if (customFont == null)
            {
                customFont = new Font();
                AssetDatabase.CreateAsset(customFont, fontPath);
            }

            var maxHeight = 0.0f;
            var characterInfo = new CharacterInfo[glyphs.Length];
            for (int i = 0; i < glyphs.Length; ++i)
            {
                var glyph = glyphs[i];
                var image = glyph.Image;
                var rect = rects[rectIndex ++];

                if (maxHeight < image.height)
                {
                    maxHeight = image.height;
                }

                var info = new CharacterInfo();
                info.index = glyph.Code;

                var uvx = rect.x;
                var uvy = rect.y;
                var uvw = rect.width;
                var uvh = rect.height;

                info.uvBottomLeft = new Vector2(uvx, uvy);
                info.uvBottomRight = new Vector2(uvx + uvw, uvy);
                info.uvTopLeft = new Vector2(uvx, uvy + uvh);
                info.uvTopRight = new Vector2(uvx + uvw, uvy + uvh);

                info.minX = 0;
                info.minY = -image.height;
                info.maxX = image.width;
                info.maxY = 0;

                info.advance = image.width;
                characterInfo[i] = info;
            }

            customFont.characterInfo = characterInfo;
            customFont.material = material;

            var serObj = new SerializedObject(customFont);
            serObj.Update();
            var lineSpacing = serObj.FindProperty("m_LineSpacing");
            lineSpacing.floatValue = maxHeight;
            serObj.ApplyModifiedPropertiesWithoutUndo();

            EditorUtility.SetDirty(customFont);
        }
    }
}
