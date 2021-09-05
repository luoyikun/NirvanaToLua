#if UNITY_EDITOR
using UnityEngine;
using System.Collections.Generic;

namespace EModules
{
    class DescriptionHelper : MonoBehaviour, IHashProperty
    {

        [HideInInspector][SerializeField]List<GameObject> Hash1 = new List<GameObject>();
        [HideInInspector][SerializeField]List<string> Hash2 = new List<string>();
        [HideInInspector][SerializeField]List<Int32List> Hash3 = new List<Int32List>();
        [HideInInspector][SerializeField]List<Int32List> Hash4 = new List<Int32List>();
        [HideInInspector][SerializeField]List<GameObject> Hash5 = new List<GameObject>();
        [HideInInspector][SerializeField]List<SingleList> Hash6 = new List<SingleList>();
        [HideInInspector][SerializeField]List<GameObject> Hash7 = new List<GameObject>();
        [HideInInspector][SerializeField]List<SingleList> Hash8 = new List<SingleList>();
        [HideInInspector][SerializeField]List<GameObject> Hash9 = new List<GameObject>();
        [HideInInspector][SerializeField]List<SingleList> Hash10 = new List<SingleList>();
        [HideInInspector][SerializeField]private bool _enableRegistrator;

        public List<GameObject> GetHash1() { return Hash1; }
        public void SetHash1(List<GameObject> hash) { Hash1 = hash; }

        public List<string> GetHash2() { return Hash2; }
        public void SetHash2(List<string> hash) { Hash2 = hash; }

        public List<Int32List> GetHash3() { return Hash3; }
        public void SetHash3(List<Int32List> hash) { Hash3 = hash; }

        public List<Int32List> GetHash4() { return Hash4; }
        public void SetHash4(List<Int32List> hash) { Hash4 = hash; }

        public List<GameObject> GetHash5() { return Hash5 ?? (Hash5 = new List<GameObject>()); }
        public void SetHash5(List<GameObject> hash) { Hash5 = hash; }

        public List<SingleList> GetHash6() { return Hash6 ?? (Hash6 = new List<SingleList>()); }
        public void SetHash6(List<SingleList> hash) { Hash6 = hash; }

        public List<GameObject> GetHash7() { return Hash7 ?? (Hash7 = new List<GameObject>()); }
        public void SetHash7(List<GameObject> hash) { Hash7 = hash; }

        public List<SingleList> GetHash8() { return Hash8 ?? (Hash8 = new List<SingleList>()); }
        public void SetHash8(List<SingleList> hash) { Hash8 = hash; }

        public List<GameObject> GetHash9() { return Hash9 ?? (Hash9 = new List<GameObject>()); }
        public void SetHash9(List<GameObject> hash) { Hash9 = hash; }

        public List<SingleList> GetHash10() { return Hash10 ?? (Hash10 = new List<SingleList>()); }
        public void SetHash10(List<SingleList> hash) { Hash10 = hash; }

        public bool EnableRegistrator {
            get { return _enableRegistrator; }
            set { _enableRegistrator = value; }
        }

        public Component component {
            get { return this; }
        }
    }
}

#endif