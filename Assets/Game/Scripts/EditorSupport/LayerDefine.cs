
namespace EditorSupport
{
    public static class LayerName
    {
        public const string Walkable = "Walkable";
        public const string UI3D = "UI3D";
    }

    public static class LayerDefine
    {
        public readonly static int Walkable = UnityEngine.LayerMask.NameToLayer(LayerName.Walkable);
        public readonly static int UI3D = UnityEngine.LayerMask.NameToLayer(LayerName.UI3D);
    }

    public static class LayerMask
    {
        public readonly static int Walkable = 1 << LayerDefine.Walkable;
        public readonly static int UI3D = 1 << LayerDefine.UI3D;
    }
}

