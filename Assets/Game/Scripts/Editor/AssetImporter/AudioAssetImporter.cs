using UnityEngine;
using UnityEditor;

public class AudioAssetImporter : AssetPostprocessor
{
    private static string MusicDir = "Assets/Game/Audios/Musics";
    private static readonly string CGvoiceDir = "Assets/Game/Audios/SFXs/CGvoice";
    private static readonly string NpcvoiceDir = "Assets/Game/Audios/SFXs/Npcvoice";
    private static readonly string ChuangjueDir = "Assets/Game/Audios/SFXs/chuangjue";

    private void OnPreprocessAudio()
    {
        AudioImporter importer = (AudioImporter)assetImporter;

        PorocessSamleSetting(importer);
        ProcessForceToMono(importer);
        ProcessLoadMode(importer);
    }

    private void PorocessSamleSetting(AudioImporter importer)
    {
        AudioImporterSampleSettings settings = importer.defaultSampleSettings;
        settings.compressionFormat = AudioCompressionFormat.Vorbis;
        if (settings.quality > 0.75f)
        {
            settings.quality = 0.75f;
        }

        // samplerate
        if (importer.assetPath.StartsWith(MusicDir)
            || importer.assetPath.StartsWith(CGvoiceDir)
            || importer.assetPath.StartsWith(ChuangjueDir)
            || importer.assetPath.StartsWith(NpcvoiceDir))
        {
            settings.loadType = AudioClipLoadType.Streaming;
            settings.sampleRateSetting = AudioSampleRateSetting.OptimizeSampleRate;
        }
        else
        {
            settings.loadType = AudioClipLoadType.DecompressOnLoad;
            settings.sampleRateSetting = AudioSampleRateSetting.OverrideSampleRate;
            settings.sampleRateOverride = 22050;
        }

        settings.compressionFormat = AudioCompressionFormat.Vorbis;
        importer.defaultSampleSettings = settings;
    }

    private void ProcessForceToMono(AudioImporter importer)
    {
        importer.forceToMono = true;
    }

    private void ProcessLoadMode(AudioImporter importer)
    {
        importer.loadInBackground = true;
    }
}