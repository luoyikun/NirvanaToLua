namespace Game
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public sealed class AttachSkinObject : MonoBehaviour
    {
        private List<Bone> boneList;
        // Use this for initialization
        private void Awake()
        {
            if (null == this.boneList)
            {
                this.boneList = new List<Bone>();
                var skinnedMesh = this.GetComponentsInChildren<SkinnedMeshRenderer>();
                foreach (var mesh in skinnedMesh)
                {
                    this.boneList.Add(new Bone(mesh, mesh.bones, mesh.rootBone));
                }
            }
        }

        public void ResetBone()
        {
            foreach (var bone in this.boneList)
            {
                var mesh = bone.mesh;
                mesh.bones = bone.bones;
                mesh.rootBone = bone.rootBone;
            }
        }

        private struct Bone
        {
            public SkinnedMeshRenderer mesh;
            public Transform[] bones;
            public Transform rootBone;
            public Bone(SkinnedMeshRenderer mesh, Transform[] transforms, Transform rootBone)
            {
                this.mesh = mesh;
                this.rootBone = rootBone;
                this.bones = new Transform[transforms.Length];
                for (int i = 0; i < transforms.Length; ++i)
                {
                    this.bones[i] = transforms[i];
                }
            }
        }
    }
}
