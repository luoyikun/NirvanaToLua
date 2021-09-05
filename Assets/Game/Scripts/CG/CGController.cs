using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;
using Nirvana;

public sealed class CGController : MonoBehaviour
{
    private PlayableDirector director;
    private Action endCallback;
    private List<GameObject> newActorList = new List<GameObject>();
    private bool lasIsPlaying = false;

    [SerializeField]
    [Tooltip("The skip btn")]
    [AssetType(typeof(Button))]
    private Button skinBtn = null;

    [SerializeField]
    [Tooltip("需要挂在主角身上的特效")]
    private AttachTransform[] roleEffcts;

    // 在unity编辑器下改动track的mute会保存在本地导致svn经常有变化。在cg结束时恢复到旧值
    private Dictionary<string, bool> oldTrackMuteDic = new Dictionary<string, bool>();

    private void Awake()
    {
        this.director = this.GetComponentInChildren<PlayableDirector>();

        if (null != this.skinBtn)
        {
            this.skinBtn.onClick.AddListener(this.Skip);
        }
    }

    private void Update ()
    {
        if (this.lasIsPlaying && PlayState.Playing != this.director.state)
        {
            this.lasIsPlaying = false;
            this.OnPlayEnd();
        }

        if (!this.lasIsPlaying && PlayState.Playing == this.director.state)
        {
            this.lasIsPlaying = true;
        }
    }

    public bool AddActor(GameObject new_actor, string track_name)
    {
        if (null == new_actor)
        {
            return false;
        }

        PlayableAsset asset = this.director.playableAsset;
        if (null == asset)
        {
            return false;
        }

        var is_succ = false;
        if (null == new_actor.GetComponent<Animator>())
        {
            new_actor.AddComponent<Animator>();
        }

        foreach (PlayableBinding pb in asset.outputs)
        {
            if (track_name == pb.streamName)
            {
                AnimationTrack track = pb.sourceObject as AnimationTrack;

                GameObject old_actor = this.director.GetGenericBinding(track) as GameObject;
                if (null != old_actor)
                {
                    // cg里添加的脚本组件
                    AttachTransform old_attach = old_actor.GetComponent<AttachTransform>();
                    if (null != old_attach && null == new_actor.GetComponent<AttachTransform>())
                    {
                        AttachTransform new_attach = new_actor.AddComponent<AttachTransform>();
                        new_attach.target = old_attach.target;
                        new_attach.offset = old_attach.offset;
                        new_attach.rotation = old_attach.rotation;
                    }

                    old_actor.SetActive(false);
                    new_actor.SetActive(true);
                }

                this.director.SetGenericBinding(track, new_actor);
                this.ChangeAttachTranform(new_actor.transform);
                is_succ = true;
                break;
            }
        }

        if (is_succ)
        {
            this.newActorList.Add(new_actor);
        }

        return is_succ;
    }

    public void SetTrackMute(string track_name, bool is_mute)
    {
        List<TrackAsset> track_list = new List<TrackAsset>();
        this.GetTrackAssetList(track_name, track_list);

        foreach (var track in track_list)
        {
#if UNITY_EDITOR
            if (!this.oldTrackMuteDic.ContainsKey(track.name))
            {
                this.oldTrackMuteDic.Add(track.name, track.muted);
            }
#endif
            track.muted = is_mute;
        }
    }

    private void GetTrackAssetList(string track_name, List<TrackAsset> track_list)
    {
        if (null == this.director || null == track_list)
        {
            return;
        }

        PlayableAsset playable_asset = this.director.playableAsset;
        if (null == playable_asset)
        {
            return;
        }

        foreach (PlayableBinding pb in playable_asset.outputs)
        {
            RecursionGetTrackAsset(pb.sourceObject as TrackAsset, track_name, track_list);
        }
    }

    private void RecursionGetTrackAsset(TrackAsset track_asset, string track_name, List<TrackAsset> track_list)
    {
        if (null == track_asset)
        {
            return;
        }

        if (track_asset.name == track_name)
        {
            track_list.Add(track_asset);
        }

        IEnumerable<TrackAsset> track_asset_list = track_asset.GetChildTracks();
        foreach (TrackAsset child_track in track_asset_list)
        {
            this.RecursionGetTrackAsset(child_track, track_name, track_list);
        }
    }

    public void SetPlayEndCallback(Action end_callback = null)
    {
        this.endCallback = end_callback;
    }

    public void Play()
    {
        if (null == this.director)
        {
            return;
        }

        this.director.Play();
    }

    public void Stop()
    {
        if (null == this.director)
        {
            return;
        }

        this.director.Stop();
        this.Clear();
        this.endCallback = null;
    }

    public void Skip()
    {
        if (null == this.director || PlayState.Playing != this.director.state)
        {
            return;
        }

        this.director.Stop();
        this.OnPlayEnd();
    }

    private void OnPlayEnd()
    {
        this.Clear();
        if (null != this.endCallback)
        {
            this.endCallback();
            this.endCallback = null;
        }
    }

    private void Clear()
    {
        foreach (GameObject actor in this.newActorList)
        {
            if (null == actor)
            {
                continue;
            }

            actor.SetActive(true);
            AttachTransform attach_transform = actor.GetComponent<AttachTransform>();
            if (null != attach_transform)
            {
                Destroy(attach_transform);
            }

        }

        this.newActorList.Clear();

#if UNITY_EDITOR
        foreach (KeyValuePair<string, bool> track_mute in this.oldTrackMuteDic)
        {
            List<TrackAsset> track_list = new List<TrackAsset>();
            this.GetTrackAssetList(track_mute.Key, track_list);
            foreach (var track_asset in track_list)
            {
                track_asset.muted = track_mute.Value;
            }
        }

        this.oldTrackMuteDic.Clear();
#endif
    }

    private void ChangeAttachTranform(Transform actor)
    {
        foreach (var attach in this.roleEffcts)
        {
            if (null != attach && null != attach.target)
            {
                var newTrans = actor.Find(attach.target.name);
                if (null != newTrans)
                {
                    attach.target = newTrans;
                }
            }
        }       
    }
}
