using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;

namespace AssetsCheck
{
    public enum CheckerType
    {
        // UI相关
        UITexture = 0,                                  // UI纹理
        UIAtlas,                                        // UI图集
        UITextureOpacity,                               // UI纹理不透明度
        UIBytes,                                        // UIBytes文件
        UIBundleDepend,                                 // UI的Bundle依赖
        UICommonImageRef,                               // UI的commonImage引用
        UIIconImageRef,                                 // UI图标类引用
        UIRawImage,                                     // UIRawimage

        // 组件类
        InvalidComponent,                               // 无效组件
        UI3DDisplay,                                    // UI上显示模型的脚本
        LoadRawImage,                                   // 加载插画类

        // 特效
        UIEffectTexture,                                // UI特效纹理
        ParticleSystemSetting,                          // 粒子系统设置
        UIEffectAttach,                                 // UI特效有没使用GameobjectAttach
        UnActiveEffectChecker,                          // 没有激活的特效
        UIEffectErrorBundleNameChecker,                 // UI特效错误bundlename检查
        EffectDependUIRes,                              // 特效依赖于ui资源                      

        // 材质球
        StandMaterial,                                  // 标准材质球
        Material,                                           // 材质球参数
        LowMaterialChecker,                      // 低配材质球

        // 角色相关
        ActorModel,                                     // 角色模型
        ActorReceivedShadow,                            // 角色接收阴影
        ActorGameObjectAttach,                          // 角色上使用特效时有没有用GameobjectAttach

        // 场景相关
        SceneEdit,                                      // 场景编辑
        SceneModel,                                     // 场景相关模型
        SceneMeshCollider,                              // 网格碰撞器
        SceneCastShadow,                                // 投射阴影
        SceneBatchChecker,                              // 场景批次检查

        // 其他
        UnUsedAsset,                                    // 没用被使用的资源
        UnUsedMaterial,                                 // 没有用的材质
        LuaConfigMemory,                                // Lua配置占用内存
        AssetBundleVariant,                             // AssetBundle别名
        AssetBundleLoopDepend,                          // AssetBundle循环依赖
        GameObjectAttachMissing                 // GameobjectAttach中记录的guid与assetbundleName不符合
    }

    class AssetsCheckConfig
    {
        // 排除列表文件夹
        public static string ExcludeDir = Path.Combine(Application.dataPath, "../AssetsCheck/Exclude");
        // 输出文件夹
        public static string OutputDir = Path.Combine(Application.dataPath, "../AssetsCheck");
    }
}
