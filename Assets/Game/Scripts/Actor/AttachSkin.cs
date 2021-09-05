//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

namespace Game
{
    using System.Collections.Generic;
    using UnityEngine;
    using Nirvana;

    /// <summary>
    /// The description of AttachSkin.
    /// </summary>
    public sealed class AttachSkin : MonoBehaviour
    {
        [SerializeField]
        private Transform rootBone;
        [SerializeField]
        private GameObject attachPrefab;
        [SerializeField]
        private Transform headBone;
        [SerializeField]
        private bool isCG = false;
        [SerializeField]
        private Transform attachRootBone;

        private Dictionary<string, Transform> boneDict;
        private GameObject weapon;
        private GameObject attachObj;

        private void Awake()
        {
            if (null == this.rootBone)
            {
                this.rootBone = this.transform;
            }
            this.ResetBoneDict();
        }

        private void OnEnable()
        {
            if (this.isCG)
            {
                if (null == this.weapon)
                {
                    this.weapon = GameObject.Instantiate(this.attachPrefab);
                }
                this.AttachMesh(this.weapon);
            }
        }

        private void OnDisable()
        {
            if (null != this.weapon)
            {
                GameObject.Destroy(this.weapon);
                this.weapon = null;
            }
        }

        private void OnDestroy()
        {
            if (null != this.weapon)
            {
                GameObject.Destroy(this.weapon);
                this.weapon = null;
            }
        }
        private void ResetBoneDict()
        {
            // Build the bone dictionary.
            if (null == this.boneDict)
            {
                this.boneDict = new Dictionary<string, Transform>();
            }
            else
            {
                this.boneDict.Clear();
            }

            this.BuildBoneDict(this.rootBone);
        }

        public void AttachMesh(GameObject attachObj)
        {
            this.attachObj = attachObj;
            this.AttachObj(attachObj);
        }

        public void ClearMeshes(GameObject attachObj)
        {
            var attachSkinObj = attachObj.GetComponent<AttachSkinObject>();
            if (null != attachSkinObj)
            {
                attachSkinObj.ResetBone();
            }
        }

        private void AttachObj(GameObject attach)
        {
            var meshes = attach.GetComponentsInChildren<SkinnedMeshRenderer>();
            foreach (var mesh in meshes)
            {
                this.Attach(mesh);
            }

            var gameObjectAttachs = attach.GetComponentsInChildren<GameObjectAttach>();
            foreach (var gameObjectAttach in gameObjectAttachs)
            {
                Transform newbone = null;
                if (!this.boneDict.TryGetValue(gameObjectAttach.transform.parent.name, out newbone))
                {
                    Debug.LogError("Error bone name: " + gameObjectAttach.transform.parent.name);
                    return;
                }
                var attachTransform = gameObjectAttach.GetOrAddComponent<AttachTransform>();
                attachTransform.target = newbone;
            }
        }

        private void BuildBoneDict(Transform bone)
        {
            if (this.boneDict.ContainsKey(bone.name))
            {
                Debug.LogError("Error bone name: " + bone.name);
                return;
            }

            this.boneDict.Add(bone.name, bone);
            for (int i = 0; i < bone.childCount; ++i)
            {
                this.BuildBoneDict(bone.GetChild(i));
            }
        }

        private void Attach(SkinnedMeshRenderer skinnedMesh)
        {
            // Replace the bones.
            var bones = skinnedMesh.bones;
            var bindbones = new Transform[bones.Length];
            for (int i = 0; i < bones.Length; ++i)
            {
                var bone = bones[i];
                if (bone == null)
                {
                    Debug.LogWarning("The skinned mesh missing a bone at index: " + i);
                    continue;
                }

                Transform newbone = null;
                if (!this.boneDict.TryGetValue(bone.name, out newbone))
                {
                    Debug.LogWarning("Can not find the bone: " + bone.name);
                }

                bindbones[i] = newbone;
            }

            skinnedMesh.bones = bindbones;
            if(this.isCG && null != this.attachRootBone)
            {
                skinnedMesh.rootBone = this.attachRootBone;
            }
            else if(null != this.headBone)
            {
                skinnedMesh.rootBone = this.headBone;
            }
            else
            {
                skinnedMesh.rootBone = this.rootBone;
            }
        }

        public void SetRootBone(Transform rootBone)
        {
            if (null != this.attachObj)
            {
                var meshes = this.attachObj.GetComponentsInChildren<SkinnedMeshRenderer>();
                foreach (var mesh in meshes)
                {
                    mesh.rootBone = rootBone;
                }
            }
        }

        public void ResetRootBone()
        {
            if (null != this.attachObj)
            {
                var meshes = this.attachObj.GetComponentsInChildren<SkinnedMeshRenderer>();
                foreach (var mesh in meshes)
                {
                    mesh.rootBone = this.rootBone;
                }
            }
        }

        public GameObject AttachPrefab
        {
            get { return this.attachPrefab; }
        }

        public Transform AttachRootBone
        {
            get { return this.attachRootBone; }
        }
    }
}
