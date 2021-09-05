ResPath = ResPath or {}

ResPath.CurrencyToIconId = {
	["diamond"] = 65534,		--钻石
	["bind_diamond"] = 65533,	--绑钻
	["exp"] = 90050,			--经验
	["chengjiu"] = 90001,		--成就
	["shengwang"] = 90002,		--魔晶
	["honor"] = 90003,			--声望
	["gongxun"] = 90004,		--功勋
	["weiwang"] = 90005,		--威望
	["score"] = 90006,			--寻宝积分
	["hunli"] = 90010,			--魂力
	["rune_suipian"] = 90012,	--符文碎片
	["magic_crystal"] = 90013,	--符文水晶
	["huoyue"] = 90014,         --活跃度
	["hunyu"] = 90015,       --竞技场魂玉
	["rune_jinghua"] = 90210,	--符文精华
	["xiannv_jinghua"] = 90028,	--仙女圣器精华
	["HunJing"] = 90797,--魂晶
	["DouqiFragment"] = 90798,	--斗气碎片
	--下面的还没有道具id
	["yuanli"] = 65534,
	["xianhun"] = 65534,
	["gongxian"] = 65534,
	["nvwashi"] = 65534,
	["guild_gongxian"] = 90009,  -- 公会贡献
	["kuafu_jifen"] = 90017,	 -- 跨服积分
	["lingjing"] = 90011,		 -- 仙宠灵晶
	--找回
	["mo_jing"] = 90002,		--魔晶
	["cross_honor"] = 90004,	--荣耀
	["yihuo_score"] = 90021,	--异火积分
}

function ResPath.GetLoginRes(res_name)
	return "uis/views/login/images_atlas", res_name
end

-- Icon  sex:1男 0女
function ResPath.GetRoleHeadBig(prof, sex)
	prof = prof % 10
	sex = sex or 1
	return "uis/icons/bigportrait_atlas", prof .. sex
end

-- 角色小头像 1男 0女
function ResPath.GetRoleHeadSmall(prof, sex)
	prof = prof % 10
	sex = sex or 1
	return "uis/icons/portrait_atlas", prof .. sex
end

function ResPath.GetRoleIconBig(res_id)
	return "uis/icons/portrait_atlas", res_id
end

--引导资源
function ResPath.GetGuideRes(res_id)
	return "uis/guideres_atlas", tostring(res_id)
end

function ResPath.GetGuideviewRes(res_id)
	return "uis/views/guideview/images/nopack_atlas", tostring(res_id)
end

function ResPath.GetSexRes(sex)
	local asset = sex == 0 and "Icon_Fmale" or "Icon_Male"
	return "uis/images_atlas", asset
end

function ResPath.GetMarrySexRes(sex)
	local asset = sex == 0 and "icon_sex_0" or "icon_sex_1"
	return "uis/images_atlas", asset
end

function ResPath.GetMiscPreloadRes(res_id)
	return "uis/views/miscpreload_prefab", tostring(res_id)
end

-----------------------表情目录--------------------------
--表情资源路径(小)
function ResPath.GetResFaceSmall(res_id)
	return "uis/views/mainui_prefab", tostring(res_id)
end

--表情资源路径(大)
function ResPath.GetResFaceBig(res_id)
	return "uis/views/chatview_prefab", tostring(res_id)
end

--大表情资源路径
function ResPath.GetResBigFace(res_id)
	return "uis/icons/bigface_prefab", tostring(res_id)
end

--大表情资源路径
function ResPath.GetResBigFaceByIndex(index,res_id)
	return "uis/icons/bigface/face_" ..(100 + index) .. "_prefab", tostring(res_id)
end

--普通动态标签资源路径
function ResPath.GetResNormalFace(res_id)
	return "uis/icons/normalface_prefab", tostring(res_id)
end

--普通动态标签资源路径ByIndex
function ResPath.GetResNormalFaceByIndex(index, res_id)
	return "uis/icons/normalface/" .. index .. "_prefab", tostring(res_id)
end

--特殊表情资源路径
function ResPath.GetResSpecialFace(res_id)
	return "uis/icons/special_atla", tostring(res_id)
end

-- 获取进阶装备格子图标
-- function ResPath.GetAdvanceEquipIcon(res_id)
-- 	return "uis/views/advanceview/images_atlas", res_id
-- end

function ResPath.GetDpsIcon()
	return "uis/views/floatingtext/images_atlas", "boss_dps"
end

function ResPath.GetFloatingIcon(res_id)
	return "uis/views/floatingtext/images_atlas", tostring(res_id)
end

function ResPath.GetNpcVoiceRes(res_id)
	return "audios/sfxs/npcvoice/" .. res_id, tostring(res_id)
end

function ResPath.GetNpcTalkVoiceRes(res_id, subsection, prof)
	if not res_id or not subsection then
		return nil, nil
	end
	local name = res_id .."_".. subsection .."_0"
	if prof then
		name = res_id .."_".. subsection .."_".. prof
	end
	return "audios/sfxs/npctalk/" .. res_id, tostring(name)
end

function ResPath.GetVoiceRes(res_id)
	return "audios/sfxs/voice/" .. res_id, tostring(res_id)
end

function ResPath.GetBGMResPath(res_id)
	return "audios/musics/bgm" .. res_id, "BGM" .. res_id
end

function ResPath.GetClashterritory(res_id)
	return "uis/views/clashterritory/images_atlas", tostring(res_id)
end

-- 获取经验、阶段副本背景图
function ResPath.GetFubenRawImage(small, big)
	return "uis/rawimages/background" .. small, "Background" .. big .. ".png"
end

-- 获取守护副本背景图
function ResPath.GetFubenDefenseRawImage(level)
	return "uis/rawimages/defense_bg_" .. level, "defense_bg_" .. level .. ".png"
end

function ResPath.GetFuBenSaoDangBg(res_id)
	return "uis/rawimages/saodang_bg_" .. res_id, "saodang_bg_" .. res_id .. ".png"
end

-- 获取副本传世佩剑Icon
function ResPath.GetTowerMojieIcon(id)
	return "uis/icons/towerpeijian_atlas", "peijian_icon_" .. id
end

-- 获取副本传世佩剑Icon(大图)
function ResPath.GetTowerPeiJianIcon(id)
	return "uis/rawimages/peijian_icon_" .. id, "peijian_icon_" .. id .. ".png"
end

-- 获取转职名字Icon
function ResPath.GetTransferNameIcon(id)
	return "uis/icons/zhuanzhi_atlas", "pic_" .. id
end

function ResPath.GetFilePath2(role_id)
	return string.format("%s/rawimg/%s",
		UnityEngine.Application.persistentDataPath, role_id)
end

function ResPath.GetFuBenViewImage(image)
	return "uis/views/fubenview/images_atlas", image
end

-- 获取副本传世佩剑名字横着的
function ResPath.GetTowerMojieName(id)
	return "uis/views/fubenview/images_atlas", "peijian_name_" .. id
end

-- 获取副本传世佩剑名字前缀横着的
function ResPath.GetTowerMojieNameIcon(id)
	return "uis/views/fubenview/images_atlas", "peijian_name_icon_" .. id
end

-- 获取副本传世佩剑名字竖着的
function ResPath.GetTowerMojieNameVertical(id)
	return "uis/views/fubenview/images_atlas", "vertical_peijian_name_" .. id
end

-- 获取副本传世佩剑名字前缀竖着的
function ResPath.GetTowerMojieNameIconVertical(id)
	return "uis/views/fubenview/images_atlas", "vertical_peijian_name_icon_" .. id
end

function ResPath.GetTowerMojieLittleNameVertical(id)
	return "uis/views/fubenview/images_atlas", "little_vertical_peijian_name_" .. id
end

function ResPath.GetTowerMojieLittleNameIconVertical(id)
	return "uis/views/fubenview/images_atlas", "little_vertical_peijian_name_icon_" .. id
end

-- 获取爬塔排行榜图标
function ResPath.GetTowerRankIcon(index)
	return "uis/views/fubenview/images_atlas", "rank_" .. index
end

-- 获取经验、阶段副本背景图
function ResPath.GetStoryFubenRawImage(res_id)
	return "uis/rawimages/storyimage" .. res_id, "storyimage" .. res_id .. ".png"
end

function ResPath.GetRawImage(res_name, is_jpg)
	local lower_res_name = string.lower(res_name)
	return "uis/rawimages/" .. lower_res_name, res_name .. (is_jpg and ".jpg" or ".png")
end

-- 情缘圣地背景图
function ResPath.GetShengDiRawImage(res_id)
	return "uis/rawimages/shengdi_bg_" .. res_id, "shengdi_bg_" .. res_id .. ".jpg"
end

-- 婚宴背景图
function ResPath.GetHunyanRawImage(res_id)
	return "uis/rawimages/marry_hunyan_" .. res_id, "marry_hunyan_" .. res_id .. ".jpg"
end

function ResPath.GetChatRes(res_id)
	return "uis/views/chatview/images_atlas", tostring(res_id)
end

function ResPath.GetTuPoIcon(res_id)
	return "uis/views/arena/images_atlas", "icon_tupo_" .. res_id
end

function ResPath.GetHaloSpirit(index)
	return "uis/views/marriageview/images_atlas", (26296 + index) .. ""
end

function ResPath.GetMarryImage(res_id)
	return "uis/views/marriageview/images_atlas", res_id
end

function ResPath.GetMarryTxtImage(res_id)
	return "uis/views/marriageview/images/text_atlas", res_id
end

function ResPath.GetMarryRawImage(res_id)
	--return "uis/views/marriageview/images_atlas", res_id .. ".png"
	return "uis/rawimages/" .. res_id, res_id .. ".png"
end

function ResPath.GetMedalSuitIcon(index)
	return "uis/views/baoju/images_atlas", "Suit" .. index
end

function ResPath.GetStrengthenStarIcon(index)
	return "uis/images_atlas", "star" .. index
end

function ResPath.GetForgeStrengthenStarIcon(index)
	return "uis/views/forgeview/images_atlas", "star" .. index
end

function ResPath.GetForgeJueXingIcon(index)
	return "uis/views/forgeview/images_atlas", "skill_" .. index
end

function ResPath.GetJueXingIcon(index)
	return "uis/views/tips/equiptips/images_atlas", "skill_" .. index
end


function ResPath.GetSpiritImage(res_id)
	return "uis/views/spiritview/images_atlas", res_id
end

function ResPath.GetWangZheZhiJie(res_name)
	return "uis/views/wangzhezhijie/images_atlas", res_name
end

function ResPath.GetZhiZunLingPai(res_name)
	return "uis/views/zhizunlingpai/images_atlas", res_name
end

--得到标签底
function ResPath.GetQualityTagBg(color_name)
	return "uis/views/spiritview/images_atlas","tag_"..color_name
end

function ResPath.GetStrengthenMoonIcon(index)
	return "uis/images_atlas", "moon" .. index
end

--通用物品标签底
function ResPath.GetItemQualityTagBg(color_name)
	return "uis/images_atlas", "bg_corner_tag_" .. color_name
end

function ResPath.GetItemQualityCcCircleTagBg(color_name)
	return "uis/images_atlas", "bg_circle_corner_tag_" .. color_name
end

function ResPath.GetBuffSmallIcon(client_type)
	return "uis/images_atlas", "buff_" .. client_type
end

--获取开服活动
function ResPath.GetOpenGameActivityRes(res_name)
	return "uis/views/kaifuactivity/images_atlas", res_name
end

function ResPath.GetGiftLimitBuyRes(res_name)
	return "uis/views/giftlimitbuy/images_atlas", res_name
end

function ResPath.GetWeekendTitle(res_id)
	return "uis/views/weekendhappy/images_atlas", "Title_txt" .. res_id
end

--获取开服活动
function ResPath.GetOpenGameActivityNoPackRes(res_name)
	return "uis/views/kaifuactivity/images/nopack_atlas", res_name
end

function ResPath.GetGuajiTaIcon()
	return "uis/views/guajitaview/images_atlas", "Icon_Rune_Tower_Top"
end

function ResPath.GetXingZuoYiJiIcon()
	return "uis/views/shengeview/images_atlas", "Icon_XingZuo_YiJi"
end


function ResPath.GetSymbolImage(res_name)
	return "uis/views/symbol/images_atlas", res_name
end

--获取活动底图
function ResPath.GetActivityBg(act_id)
	return "uis/rawimages/activitybg_" .. act_id, "ActivityBg_" .. act_id .. ".jpg"
end

-- --零元礼包
-- function ResPath.GetZeroGiftBg(req)
-- 	req = req == 0 and "" or req
-- 	return "uis/rawimages/zero_gift_word_atlas" .. req, "zero_gift_word" .. req .. ".jpg"
-- end

function ResPath.GetGetChatLableIcon(color_name)
	return "uis/images_atlas", "label_08_" .. color_name
end


function ResPath.GetBossHp(index)
	return "uis/images_atlas", "progress_14_" .. index
end

function ResPath.GetHelperIcon(res)
	return "uis/icons/helper_atlas", "Helper_" .. res
end

function ResPath.GetHelpIcon(res)
	return "uis/icons/helper_atlas", res
end

function ResPath.GetActiveDegreeIcon(icon_name)
	return "uis/views/baoju/images_atlas", icon_name
end

--获取进阶奖励图标
function ResPath.GetJinJieBg(id)
	return "uis/views/tips/jinjiereward/images_atlas", "Image_" .. id
end

function ResPath.GetMedalIcon(medal_id)
	return "uis/views/baoju/images_atlas", "Medal_Icon" .. medal_id
end

function ResPath.GetAchieveIcon(client_type)
	return "uis/views/baoju/images_atlas", "AchieveItem_Icon" .. client_type
end

function ResPath.GetRoleEffects(role_id)
	if role_id == nil or role_id == 0 then
		return nil, nil
	end
	local name = tostring(role_id) .. "_buff"
	return "effects/prefab/role/" .. math.floor(role_id / 1000) .. "/" .. string.lower(name) .."_prefab", name
end

function ResPath.GetImmortalTitle(index)
	return "uis/views/immortalcardview/nopack_atlas", "text_desc" .. index
end

function ResPath.GetRoleJumpEff(prof)
	if prof == nil or prof < 1 or prof > 4 then
		return nil, nil
	end
	local name = ""
	if prof == 1 then
		name = "Effects_nanjiancaitai"
	elseif prof == 2 then
		name = "Effects_nanqingcaitai"
	elseif prof == 3 then
		name = "Effects_nvshuangjiancaitai"
	elseif prof == 4 then
		name = "Effects_nvpaocaitai"
	end
	return "effects/prefab/misc/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetFourJumpMount(prof)
	if prof == nil or prof < 1 or prof > 4 then
		return nil, nil
	end
	local name = ""
	if prof == 1 then
		name = "laoying"
	elseif prof == 2 then
		name = "xianhe"
	elseif prof == 3 then
		name = "fenghuang"
	elseif prof == 4 then
		name = "zhihe"
	end
	return "effects/prefab/mount/" .. string.lower(name) .. "/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetTongyongEffect(name)
	return "effects/prefab/tongyong/" .. string.lower(name) .. "_prefab", name
end

-- 获取技能图标(全称)
function ResPath.GetSkillIcon(res_str)
	return "uis/icons/skill_atlas", res_str
end

function ResPath.GetTimeLimitTitleResPath(res_id)
	return "uis/views/tips/timelimittitletips/images_atlas", tostring(res_id)
end

-- 技能图标
function ResPath.GetRoleSkillIcon(res_id)
	return "uis/icons/skill_atlas", "Skill_" .. res_id
end

-- 怪物小头像
function ResPath.GetBossIcon(res_id)
	return "uis/icons/boss_atlas", "Boss_" .. res_id
end

-- 怪物大头像
function ResPath.GetBossRawIcon(res_id)
	return "uis/rawimages/boss_item_" .. res_id, "boss_item_" .. res_id .. ".png"
end

-- NPC 小头像
function ResPath.GetNpcHeadSmall(res_id)
	return "uis/icons/npc_atlas", "Npc_Icon_" .. res_id
end

-- NPC 对话头像
function ResPath.GetNpcHeadBig(res_id)
	return "uis/icons/npc_atlas", "Npc_" .. res_id
end

-- 表情图片
function ResPath.GetEmoji(res_id)
	return "uis/icons/emoji_atlas", tostring(res_id)
end

-- 兑换货币
function ResPath.GetExchangeIcon(res_id)
	return "uis/icons/coin_atlas", "Coin_" .. res_id
end

function ResPath.GetExchangeNewIcon(res)
	return "uis/icons/coin_atlas", "Coin_" .. res
end

function ResPath.GetGoldHuntModelHeadImg(name)
	return "uis/views/goldhuntview/images_atlas", name
end

function ResPath.GetBossTypeTag(res_id)
	return "uis/views/bossview/images_atlas", "tag_boss_type_" .. res_id
end

-- --获得匠心月饼类型
-- function ResPath.GetMoonCakeTypeImage(str_type, item_id)
-- 	return "uis/views/festivalactivity/image/".. str_type .."image_atlas", "moon_image" .. item_id
-- end

-- --获得匠心月饼名字
-- function ResPath.GetMoonCakeTypeName(str_type, item_id)
-- 	return "uis/views/festivalactivity/image/".. str_type .."image_atlas", "moon_name_" .. item_id
-- end

--获得匠心月饼类型
function ResPath.GetMoonCakeTypeImage(item_id)
	return "uis/views/kaifuactivity/images_atlas", "moon_image" .. item_id
end
--获得匠心月饼名字
function ResPath.GetMoonCakeTypeName(item_id)
	return "uis/views/kaifuactivity/images_atlas", "moon_name_" .. item_id
end

-- 累计充值箱子图标
function ResPath.GetLeiJiRechargeBoxIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "open_box" .. res
end

-- 累计充值Item大图标
function ResPath.GetLeiJiRechargeShowIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "show_item_" .. res
end

-- 累计充值奖励图片
function ResPath.GetLeiJiRechargeIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "recharge_text" .. res
end

-- 根据职业获取累计充值奖励图片
function ResPath.GetLeiJiNewRechargeIcon(res)
	return "uis/views/leijirechargeview/images_atlas", "recharge_text_" .. res
end

-- 累积充值奖励展示图片
function ResPath.GetLeiJiRechargeImage(res)
	return "uis/views/leijirechargeview/images_atlas", "leiji_recharge" .. res
end

-- 对应的罗马数字图片
function ResPath.GetRomeNumImage(res)
	return "uis/views/shengeview/images_atlas", "rome_num_" .. res
end

-- 神武圣衣
function ResPath.GetShenQiImage(res)
	return "uis/views/shenqi/images_atlas", res
end

function ResPath.GetTianShuImage(res)
	return "uis/views/tianshuview/image/nopack_atlas", "tianshu_text_" .. res
end

function ResPath.GetProgress(name)
	return "uis/progress", name
end

function ResPath.GetXingXiangIcon(res_id)
	return "uis/icons/xingmai_atlas","XingZuo_4020" .. (res_id + 25)
end

-- 货币信息
function ResPath.GetCurrencyID(currency_name)
	return ResPath.CurrencyToIconId[currency_name]
end

function ResPath.GetCurrencyIcon(currency_name)
	return ResPath.GetItemIcon(ResPath.CurrencyToIconId[currency_name])
end

-- 货币信息--旧的
-- function ResPath.GetCurrencyIcon(res_id)
-- 	return "uis/icons/currency", "Currency_"..tostring(res_id)
-- end

function ResPath.GetItemIcon(res_id)
	local bundle_id = math.floor(res_id / 1000)

	-- 这些物品id段是策划一直会加的物品，因此细分到100
	if bundle_id == 27
		or bundle_id == 26
		or bundle_id == 23
		or bundle_id == 22 then

		bundle_id = math.floor(res_id / 100)
		return "uis/icons/item/" .. bundle_id .. "00".."_atlas", "Item_" .. res_id

	else
		return "uis/icons/item/" .. bundle_id .. "000".."_atlas", "Item_" .. res_id
	end
end

function ResPath.GetLuoShuIcon(res_id)
	return "uis/views/player/images/luoshucard_atlas", "img_card_bg_" .. res_id
end

function ResPath.GetQualityIcon(id)
	return "uis/images_atlas", QUALITY_ICON[id]
end

function ResPath.GetLuoShuQuality(id)
	return "uis/views/player/images/nopack_atlas", "luoshu_quality_" .. id
end

function ResPath.GetLuoNameQuality(id)
	return "uis/views/player/images_atlas", "bg_name_" .. id
end

function ResPath.GetZhuanZhiIcon(name)
	return "uis/views/player/zhuanzhi_atlas", name
end

function ResPath.GetZhuanZhiSkill(skill)
	return "uis/icons/zhuanzhi_atlas", "zhuanzhi_" .. skill
end

function ResPath.GetQualityBgIcon(res_id)
	return "uis/views/tips/equiptips/images_atlas", "QualityBG_0" .. res_id
	-- return "uis/images_atlas", "QualityBG_0" .. res_id
end

--通用提示框背景图
function ResPath.GetQualityRawBgIcon(res_id)
	return "uis/rawimages/qualitytipbg_0"..res_id, "QualityTipBG_0" .. res_id .. ".png"
end

function ResPath.GetQualityRawTitleBg(res_id)
	return "uis/rawimages/tips_line_0"..res_id, "tips_line_0" .. res_id .. ".png"
end

--通用提示框龙头
function ResPath.GetTipsLongTouIcon(res_id)
	return "uis/rawimages/longtou_0"..res_id, "LongTou_0" .. res_id .. ".png"
end

--通用提示框龙尾
function ResPath.GetTipsLongWeiIcon(res_id)
	return "uis/rawimages/longwei_0"..res_id, "LongWei_0" .. res_id .. ".png"
end

--通用提示框框边
function ResPath.GetQualityKuangBgIcon(res_id)
	return "uis/images_atlas", "kuang_0" .. res_id
end

--通用提示框Line
function ResPath.GetQualityLineBgIcon(res_id)
	return "uis/images_atlas", "tips_line_0" .. res_id
end

function ResPath.GetQualityTopBg(res_id)
	return "uis/images_atlas", "tips_top_0" .. res_id
end

function ResPath.GetQualityBgIcon1(res_id)
	return "uis/views/tips/equiptips/images_atlas", "QualityBG_" .. res_id
	-- return "uis/images_atlas", "QualityBG_" .. res_id
end

function ResPath.GetQualityLineBgIcon(res_id)
	return "uis/views/tips/equiptips/images_atlas", "QualityLine_0" .. res_id
	-- return "uis/images_atlas", "QualityLine_0" .. res_id
end

-- 送花信息
function ResPath.GetFlowerItemIcon(res_id)
	return ResPath.GetItemIcon(res_id)
end

--获取坐骑阶数品质背景
function ResPath.GetMountGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetWingGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetFootGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetHaloGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetFaBaoGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end
function ResPath.GetWuQiGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end
function ResPath.GetShengongGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetShenyiGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetSpiritFazhenGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetSpiritHaloGradeQualityBG(id)
	return "uis/images_atlas", MOUNT_QUALITY_ICON[id]
end

function ResPath.GetFirsChargeSprite(table_index,select_index)
	local res_table = {
		{"shouchong_gift_1", "shouchong_gift_2", "shouchong_gift_3"},
		{"shouchong_gift_1_1", "shouchong_gift_2", "shouchong_gift_3"}
	}
	return "uis/views/firstchargeview/images_atlas", res_table[table_index][select_index]
end

function ResPath.GetSecondChargeViewTitle(index)
	return "uis/views/firstchargeview/images_atlas", "shouchong_title_" .. index
end

function ResPath.GetSecondChargeViewMainUITitle(index)
	return "uis/views/mainui/images_atlas", "ChargeText_" .. index
end

function ResPath.GetSecondChargeViewMainUILevel(index)
	return "uis/views/mainui/images_atlas", "ChargeLevel_" .. index
end

--获取坐骑幻化形象图标
function ResPath.GetMountImage(id)
	return "uis/icons/huanhua_atlas", "Mount_" .. id
end

--获取羽翼幻化形象图标
function ResPath.GetWingImage(id)
	return "uis/icons/huanhua_atlas", "Wing_" .. id
end

--获取神弓幻化形象图标
function ResPath.GetShengongImage(id)
	return "uis/icons/huanhua_atlas", "Shengong_" .. id
end

--获取神翼幻化形象图标
function ResPath.GetShenyiImage(id)
	return "uis/icons/huanhua_atlas", "Image_" .. id
end

--光环技能
function ResPath.GetAdvanceHaloSkillIcon(res_id)
	return "uis/icons/skill_atlas", "HaloSkill_" .. res_id
end

--法宝技能
function ResPath.GetFaBaoSkillIcon(res_id)
	return "uis/icons/skill_atlas", "FaBaoSkill_" .. res_id
end

--时装技能
function ResPath.GetFashionSkillIcon(res_id)
	return "uis/icons/skill_atlas", "FashionSkill_" .. res_id
end

-- 女神光环技能图标
function ResPath.GetHaloSkillIcon(res_id)
	return "uis/icons/skill_atlas", "GoddessHaloSkill_" .. res_id
end

function ResPath.GetShenShouSkillIcon(res_id)
	return "uis/views/shenshouview/images_atlas", "Skill_SS_" .. res_id
end

-- 女神法阵图标
function ResPath.GetFaZhenSkillIcon(res_id)
	return "uis/icons/skill_atlas", "GoddessFaZhenSkill_" .. res_id
end

--神兵技能图标
function ResPath.GetShenBingSkillIcon(res_id)
	return "uis/icons/skill_atlas", "ShenbingSkill_" .. res_id
end

-- 坐骑技能图标
function ResPath.GetMountSkillIcon(res_id)
	return "uis/icons/skill_atlas", "MountSkill_" .. res_id
end

-- 战骑技能图标
function ResPath.GetFightMountSkillIcon(res_id)
	return "uis/icons/skill_atlas", "FightMountSkill_" .. res_id
end

-- 宝具技能图标
function ResPath.GetBaoJuSkillIcon(res_id)
	return "uis/icons/skill_atlas", "BaoJuSkill_" .. res_id
end

-- 公会技能图标
function ResPath.GetGuildSkillIcon(res_id)
	return "uis/icons/skill_atlas", "GuildSkill_" .. res_id
end

-- 获取仙盟技能模型
function ResPath.GetSkillSwordModel(res_id)
	return "actors/xianmengjineng/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

-- 披风技能图标
function ResPath.GetCloakSkillIcon(res_id)
	return "uis/icons/skill_atlas", "PiFengSkill_" .. res_id
end

--灵刃技能图标
function ResPath.GetLingRenSkillIcon(res_id)
	return "uis/icons/skill_atlas", "LingrenSkill_" .. res_id
end

function ResPath.GetImgFuLingTypeIcon(type)
	return "uis/views/imagefuling/images_atlas", "fuling_type_icon" .. type
end

function ResPath.ImgFuLingTypeRawImage(fl_type)
	return "uis/rawimages/fuling_bg_type" .. fl_type, "fuling_bg_type" .. fl_type .. ".png"
end

function ResPath.ImgFuLingSkillIcon(fl_type)
	return "uis/icons/skill_atlas", "FuLingSkill_" .. fl_type
end

-- 每日首充
function ResPath.GetDailyChargeContentViewIcon(res_id)
	return "uis/views/dailychargeview/images/nopack_atlas", "desc" .. res_id
end

--获取仙女图标
function ResPath.GetGoddessIcon(res_id)
	return "uis/icons/goddess_atlas", "Goddess_" .. res_id
end

--获取仙女文字
function ResPath.GetGoddessText(res)
	return "uis/views/goddess/images_atlas", "text_" .. res
end

--获取仙女背景
function ResPath.GetGoddessBg(res)
	return "uis/views/goddess/images_atlas", "bg_" .. res
end

function ResPath.GetLittlePetBg(res)
	return "uis/views/littlepetview/images_atlas", "bg_" .. res
end

--得到排名图标
function ResPath.GetRankIcon(rank)
	return "uis/images_atlas", "icon_rank_" .. rank
end

--神话图标
function ResPath.GetMythImg(res_name)
	return "uis/views/myth/images_atlas",res_name
end

--得到新的排名图标
function ResPath.GetNewRankIcon(rank)
	return "uis/images_atlas", "rank_" .. rank
end

function ResPath.GetConsumerRankIcon(rank)
	return "uis/views/kuafuconsumerank/images_atlas", "rank_" .. rank
end

--得到排名背景
function ResPath.GetRankBgIcon(rank)
	return "uis/views/hefuactivity/images_atlas", "rankbg_" .. rank
end

--排行榜对应text
function ResPath.GetRankText(str)
	return "uis/views/rank/images_atlas", "rank_" .. str .. "_text"
end

function ResPath.GetRankImg(str)
	return "uis/views/rank/images_atlas", str
end

function ResPath.GetBiaoBaiRankImg(str)
	return "uis/views/biaobaiqiangview/images_atlas", str
end

--得到跨服1v1段位图标
function ResPath.Get1v1RankIcon(rank)
	return "uis/views/kuafu1v1/images_atlas", "Rank_0" .. rank
end

--得到跨服1v1职业头像
function ResPath.Get1v1Head(rank)
	return "uis/views/kuafu1v1/images/nopack_atlas", rank
end

-- 钻石，绑钻图标
function ResPath.GetDiamonIcon(res_id)
	return "uis/images_atlas", "icon_gold_" .. res_id
end

function ResPath.GetGoldIcon( res_id )
	return "uis/images_atlas","icon_gold_"..res_id
end

function ResPath.GetWingQualityBgIcon(res_id)
	return "uis/icons/quality_atlas", "Wing_Quality0" .. res_id
end

function ResPath.GetWingNameImg(res_id)
	return "uis/icons/wingname_atlas", "WingName_" .. res_id
end

function ResPath.GetWingSkillIcon(res_id)
	return "uis/icons/skill_atlas", "WingSkill_" .. res_id
end

function ResPath.GetFootSkillIcon(res_id)
	return "uis/icons/skill_atlas", "FootSkill_" .. res_id
end

-- 灵珠技能图标
function ResPath.GetLingZhuSkillIcon(res_id)
	return "uis/icons/skill_atlas", "LingZhuSkill_" .. res_id
end

-- 仙宝技能图标
function ResPath.GetXianBaoSkillIcon(res_id)
	return "uis/icons/skill_atlas", "XianBaoSkill_" .. res_id
end

-- 灵童技能图标
function ResPath.GetLingTongSkillIcon(res_id)
	return "uis/icons/skill_atlas", "LongTongSkill_" .. res_id
end

-- 灵弓技能图标
function ResPath.GetLingGongSkillIcon(res_id)
	return "uis/icons/skill_atlas", "LingGongSkill_" .. res_id
end

-- 灵骑技能图标
function ResPath.GetLingQiSkillIcon(res_id)
	return "uis/icons/skill_atlas", "LingQiSkill_" .. res_id
end

-- 头饰技能图标
function ResPath.GetTouShiSkillIcon(res_id)
	return "uis/icons/skill_atlas", "TouShiSkill_" .. res_id
end

-- 面饰技能图标
function ResPath.GetMaskSkillIcon(res_id)
	return "uis/icons/skill_atlas", "MaskSkill_" .. res_id
end

-- 腰饰技能图标
function ResPath.GetYaoShiSkillIcon(res_id)
	return "uis/icons/skill_atlas", "YaoShiSkill_" .. res_id
end

-- 麒麟臂技能图标
function ResPath.GetQiLinBiSkillIcon(res_id)
	return "uis/icons/skill_atlas", "QiLinBiSkill_" .. res_id
end

function ResPath.GetStarIcon(res_id)
	return "uis/images_atlas", "Star0" .. res_id
end

--魂玉图标
function ResPath.GetHunyuIcon(res_id)
	return "uis/icons/baoju_atlas", "hunyu_" .. res_id
end

function ResPath.GetNewStarIcon(res_id)
	res_id = tonumber(res_id)
	local multiple = math.floor(res_id/5)
	if multiple > 0 and res_id == 5*multiple then
		res_id = 5
	else
		res_id = res_id - 5*multiple
	end
	return "uis/images_atlas", "icon_star_" .. res_id
end

function ResPath.GetSystemIcon(res_id)
	return "uis/views/mainui/images_atlas", "Icon_System_" .. res_id
end

function ResPath.GetEffectBoss(res_id)
	--return "effects/prefabs_boss/misc_prefab", tostring(res_id)
	return "effects/prefab/boss/"..res_id.."_prefab",tostring(res_id)
end

function ResPath.GetMiscEffect(name)
	return "effects/prefab/misc/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetZhiBaoUpgradeEffect(res_id)
	local name = "uieffect_xianlin_"..tostring(res_id).."_dc"
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetTreasureEffect(res_id)
	local name = "item_"..tostring(res_id)
	local name1 = "Item_"..tostring(res_id)
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab", name1
end

function ResPath.GetMedalEffect(res_id)
	local name = "uieffect_badge_"..tostring(res_id).."_dc"
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetWangZheZhiJieEffect(res_id)
	local name = "UI_img_pic" .. res_id
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab",  name
end

function ResPath.GetLingPaiEffect(res_id)
	local name = "UI_pai_img_pic" .. res_id
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab",  name
end

function ResPath.GetStartEffect(res_id)
	return "effects/prefab/ui/" .. string.lower(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetEffect(res_id)
	return "effects/prefab/misc/" .. string.lower(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetHuLuEff(eff_id)
	return "actors/other/1000_prefab", "1000_attack_0" .. eff_id
end

function ResPath.GetTitleEffect(name)
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetBuffEffect(res_id)
	local name = tostring(res_id)
	return "effects/prefab/buff/".. string.lower(name) .."_prefab", name
end

function ResPath.GetHunYinEffect(res_id)
	return "effects/prefab/ui_x/" .. string.lower(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetMijiEffect(res_id)
	return "effects/prefab/ui_x/" .. string.lower(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetMijiEffect(res_id)
	return "effects/prefab/ui_x/" .. string.lower(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetUiEffect(name)
	return "effects/prefab/ui/" .. string.lower(name) .. "_prefab", tostring(name)
end

function ResPath.GetUiXEffect(name)
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab", tostring(name)
end

function ResPath.GetItemIconEffect(name)
	return "effects/prefab/ui/ui_jinglinminghun/" .. string.lower(name) .. "_prefab", tostring(name)
end

-- 获取格子特效
function ResPath.GetItemEffect()
	return "effects/prefab/ui_x/ui_wp_prefab", "UI_wp"
end

function ResPath.GetItemRewardEffect()
	return "effects/prefab/misc/effect_biankuang01_prefab", "Effect_biankuang01"
end

-- 获取运营活动格子特效
function ResPath.GetItemActivityEffect()
	return "effects/prefab/ui_x/ui_wp_prefab", "UI_wp"
end

function ResPath.GetForgeItemName(res_id)
	return "uis/views/forgeview/images_atlas", "name_" .. res_id
end

function ResPath.GetShenGeImg(res_id)
	return "uis/views/shengeview/images_atlas", tostring(res_id)
end

function ResPath.GetHunQiImg(res_id)
	return "uis/views/hunqiview/images_atlas", tostring(res_id)
end

function ResPath.GetYiHuoImg(index)
	return "uis/views/hunqiview/images_atlas", "yi_huo_" .. index
end

function ResPath.GetShengXiaoIcon(res_id)
	return "uis/views/shengxiaoview/images_atlas", "shengxiao_gold_" .. res_id
end

function ResPath.GetShengXiaoBigIcon(res_id)
	return "uis/views/shengxiaoview/images/nopack_atlas", "big_shengxiao_" .. res_id
end

function ResPath.GetShengXiaoStarSoul(res_id)
	return "uis/rawimages/bg_shengxiao_" .. res_id, "bg_shengxiao_" .. res_id .. ".png"
end

function ResPath.GetShengXiaoSkillIcon(res_id)
	return "uis/views/shengxiaoview/images_atlas", "shengxiao_skill_0" .. res_id
end

function ResPath.GetPieceIcon(res_id)
	return "uis/views/shengxiaoview/images_atlas", "piece_" .. res_id
end

function ResPath.GetXingHunIcon(res_id)
	return "uis/views/shengxiaoview/images_atlas", "xinghun_" .. res_id
end

function ResPath.GetShengXiaoWiget(res_id)
	return "uis/views/shengxiaoview_prefab", res_id
end

function ResPath.GetPetScoreIcon(res_id)
	return "uis/views/exchangeview/images_atlas", res_id
end

function ResPath.GetTianXiangWiget(res_id)
	return "uis/views/shenyinview_prefab", res_id
end

function ResPath.GetArenaRankbg(res_id)
	return "uis/views/arena/images/nopack_atlas", "rank_bg_" .. res_id
end

function ResPath.GetKFArenaRankbg(res_id)
	return "uis/views/kfarenaview/images/nopack_atlas", "rank_bg_" .. res_id
end

function ResPath.GetKFArenaDes(res_id)
	return "uis/views/kfarenaview/images_atlas", "enemy_dec_" .. res_id
end


function ResPath.GetTianXiangPieceIcon(res_id)
	return "uis/views/shenyinview/images_atlas", "piece_" .. res_id
end

function ResPath.GetUITipsEffect(res_id)
	local name = "ui_tips_kuantexiao_0" .. res_id
	return "effects/prefab/misc/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetSelectObjEffect(res_id)
	local name = "xuan_0" .. res_id
	return "effects/prefab/misc/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetSelectObjEffect2(res_id)
	local name = "XZ_" .. res_id
	return "effects/prefab/misc/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetTaskNpcEffect(index)
	local name = "task_effect_" .. index
	return "effects/prefab/misc/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetUiMingJianEffect(name)
	return "effects/prefab/ui/mingjian/" .. string.lower(name) .. "_prefab", tostring(name)
end

function ResPath.GetForgeEquipBgEffect(color)
	if color == 1 then
		color = "l"
	elseif color == 2 then
		color = "b"
	elseif color == 3 then
		color = "z"
	elseif color == 4 then
		color = "y"
	elseif color == 5 then
		color = "r"
	end
	local name = "UI_ZBqianghua_" .. color
	return "effects/prefab/ui/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetZhenfaEffect(asset)
	return "effects/prefab/misc/" .. string.lower(asset) .. "_prefab", tostring(asset)
end

function ResPath.GetForgeEquipGlowEffect(color)
	if color == 1 then
		color = "l"
	elseif color == 2 then
		color = "b"
	elseif color == 3 then
		color = "z"
	elseif color == 4 then
		color = "y"
	elseif color == 5 then
		color = "r"
	end
	local name = "UI_ZBqianghua_" .. color .. "_glow"
	return "effects/prefab/ui/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetImages(res_str)
	return "uis/images_atlas", res_str
end

function ResPath.GetImages2(res_str)
	return "uis/images2_atlas", res_str
end

function ResPath.GetZheKou(res_id)
	return "uis/views/exchangeview/images_atlas", "shop_zhekou_" .. res_id
end

function ResPath.GetscoietyView(res_str)
	return "uis/views/scoietyview/images_atlas", res_str
end

function ResPath.GetErnieImage(res_id)
	return "uis/views/ernieview/images_atlas", "Icon_" .. res_id
end
function ResPath.GetKuaFuLiuJieImages(res_id)
	return  "uis/views/kuafuliujie/images_atlas", "icon_line_" .. res_id
end

function ResPath.GetBaojiDayImage(res_id)
	return "uis/views/kaifuactivity/images_atlas", "baojiri_" .. res_id
end

function ResPath.GetAuraImage(res_id)
	return "uis/views/aurasearchview/images_atlas", "aura_"..res_id
end

function ResPath.GetVipIcon(res_str)
	return "uis/views/vipview/images_atlas", res_str
end

function ResPath.GetDoubleGoldIcon(res_str)
	return "uis/views/serveractivity/doublegold/images_atlas", res_str
end

function ResPath.GetVipItemIcon(res_str)
	return "uis/views/vipview/images_atlas", res_str
end

function ResPath.GetMainUI(name)
	return "uis/views/mainui/images_atlas", name
end

function ResPath.GetMainIcon(name)
	return "uis/views/mainui/images_atlas", name
end

function ResPath.GetPlayerImage(name)
	return "uis/views/player/images_atlas", name
end

function ResPath.GetPlayerPanel(name)
	return "uis/views/playerpanel/images_atlas", name
end

function ResPath.GetFriendPanelIcon(res_id)
	return "uis/views/friendpanel/images_atlas", tostring(res_id)
end

function ResPath.GetJuBaoPenIcon(res_id)
	return "uis/views/jubaopen/images_atlas", tostring(res_id) .. ".png"
end

function ResPath.GetExpenseNiceGiftIcon(res_id)
	return "uis/views/serveractivity/expensenicegift/images_atlas", tostring(res_id) .. ".png"
end

--魂器宝箱
function ResPath.GetHunqiBoxIcon(res_id)
	return "uis/views/hunqiview/images_atlas", "Box_0" .. res_id
end

function ResPath.GetTreasureItemIcon(name)
	return "uis/views/treasureview/images_atlas", name
end

-- 公会宝箱图片
function ResPath.GetGuildBoxIcon(res_id, state)
	if state then
		return "uis/views/guildview/images/nopack_atlas", "box_open_" .. res_id
	else
		return "uis/views/guildview/images_atlas", "Box_0" .. res_id
	end
end

-- 公会炼丹图片
function ResPath.GetGuildJianLuIcon(res_id, state)
	if state then
		return "uis/views/guildview/images/nopack_atlas", "guild_open_luzi" .. res_id
	else
		return "uis/views/guildview/images/nopack_atlas", "guild_luzi" .. res_id
	end
end

--生肖转转乐宝箱图片
function ResPath.GetShengXiaoBoxIcon(res_id, state)
	if state then
		return "uis/views/shengxiaoview/images/nopack_atlas", "box_open_" .. res_id
	else
		return "uis/views/shengxiaoview/images_atlas", "Box_0" .. res_id
	end
end

function ResPath.GetGuildFightLine(res_id)
	return "uis/views/guildfight/images_atlas", "icon_line_" .. res_id
end

function ResPath.GetKuaFuLiujieLine(res_id)
	return "uis/views/kuafuliujie/images_atlas", "icon_line_" .. res_id
end

function ResPath.GetGuildFightProgress(res_id)
	return "uis/views/guildfight/images_atlas", "progress_" .. res_id
end

function ResPath.GetBossRewardsBoxIcon(res_id, state)
	if state then
		return "uis/views/bossview/images/nopack_atlas", "box_open_" .. res_id
	else
		return "uis/views/bossview/images_atlas", "Box_0" .. res_id
	end
end

function ResPath.GetTujianBgIcon(res_id)
	return "uis/views/bossview/images_atlas", "tujian_bg_" .. res_id
end

-- 副本宝箱图片
function ResPath.GetFuBenBoxIcon(res_id, state)
	if state then
		return "uis/views/fubenview/images/nopack_atlas", "box_open_" .. res_id
	else
		return "uis/views/fubenview/images_atlas", "Box_0" .. res_id
	end
end

function ResPath.GetFuBenTypeBg(res_id)
	return "uis/views/fubenview/images_atlas", "team_fuben_" .. res_id
end

function ResPath.GetBossNoPackImage(res_id)
	return "uis/views/bossview/images/nopack_atlas", res_id
end

function ResPath.GetGuildImg(name)
	return "uis/views/guildview/images_atlas", name
end

-- 获取公会徽章默认图片
function ResPath.GetGuildBadgeIcon()
	return "uis/views/guildview/images_atlas", "guild_badge"
end

function ResPath.GetGuildBadgeIconInTips()
	return "uis/views/tips/portraittips/images_atlas", "guild_badge"
end
function ResPath.GetChatGuildBadgeIcon()
	return "uis/views/chatview/images_atlas", "view_badge"
end

function ResPath.GetGoldHuntModelImg(name)
	return "uis/views/goldhuntview/images_atlas", name
end

function ResPath.GetNpcPic(res_id)
	return "uis/icons/npc_atlas", "Npc_" .. res_id
end

function ResPath.GetSpiritSoulEffect(name)
	return "effects/prefab/misc/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetWelfareRes(res_id)
	return "uis/views/welfare/images_atlas", tostring(res_id)
end

-- 精灵阵法组合评分图标
function ResPath.GetSpiritScoreIcon(res_id)
	return "uis/views/spiritview/images_atlas", "Score" .. res_id
end

-- 精灵阵法组合评分图标
function ResPath.GetSpiritIcon(name)
	return "uis/views/spiritview/images_atlas", name
end

function ResPath.GetRightBubbleIcon(res_id)
	return "uis/chatres/bubbleres/bubble"..res_id.."_atlas", "bubble_" .. res_id .. "_right"
end

function ResPath.CrossFBIcon(res_id)
	return "uis/rawimages/kuafufuben_" .. res_id, "kuafufuben_" .. res_id .. ".jpg"
end

function ResPath.GetActivtyIcon(res_id)
	return "uis/images", "Icon_Activity_" .. res_id
end

function ResPath.GetHightBaoJuIcon(res_id)
	return "uis/rawimages/xianlin_" .. res_id, "xianlin_" .. res_id .. ".png"
end

function ResPath.GetGuildActivtyBg(res_id)
	return "uis/rawimages/guild_activity_bg_" .. res_id, "guild_activity_bg_" .. res_id .. ".png"
end

function ResPath.GetTerritoryBg(res_id)
	return "uis/rawimages/background0" .. res_id, "Background0" .. res_id .. ".jpg"
end

function ResPath.GetTitleIcon(res_id)
	if res_id == nil then
		return nil, nil
	end

	local bundle_id = math.floor(res_id/1000)
	return "uis/icons/title/"..bundle_id.."000".."_atlas", "Title_" .. res_id
end

function ResPath.GetTitleHightIcon(res_id)
	if res_id == nil then
		return nil, nil
	end

	local bundle_id = math.floor(res_id/1000)
	return "uis/icons/title/"..bundle_id.."000".."_atlas", "Title_" .. res_id .. "_H"
end

function ResPath.GetArenaRankBigTitle(res_id)
	if res_id == nil then
		return nil, nil
	end
	return "uis/views/arena/images/nopack_atlas", "title_" .. res_id
end

function ResPath.GetKFArenaRankBigTitle(res_id)
	if res_id == nil then
		return nil, nil
	end
	return "uis/views/kfarenaview/images/nopack_atlas", "title_" .. res_id
end

function ResPath.GetSkillGoalsIcon(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "uis/icons/skill_atlas", "Goals_" .. res_id
end

function ResPath.GetShenShouImg(res_id)
	return "uis/views/shenshouview/images_atlas", res_id
end

function ResPath.GetGroupPurchaseImg(res_id)
	return "uis/views/grouppurchaseview/images_atlas", res_id
end
---------------------------------------------------------
-- model
---------------------------------------------------------
function ResPath.GetShengqiModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/shengqi/" .. res_id .. "_prefab", tostring(res_id)
end
function ResPath.GetLongqiModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/longqi/" .. res_id .. "_prefab", tostring(res_id)
end
function ResPath.GetRoleModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/role/" .. math.floor(res_id).."_prefab", tostring(res_id)
end

function ResPath.GetBaojuModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/baoju/" .. math.floor(res_id).."_prefab", tostring(res_id)
end
function ResPath.GetRoleModelobe(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/role/" .. tostring((res_id-1)/100).."_prefab", tostring(res_id)
end
function ResPath.GetMonsterModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/monster/" .. math.floor(res_id / 1000).."_prefab", tostring(res_id)
end

function ResPath.GetShangguBOXModel(res_id)
	return "actors/gather/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetTriggerModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/trigger/" .. math.floor(res_id / 1000), tostring(res_id)
end

function ResPath.GetFallItemModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/fallitem/" .. math.floor(res_id / 1000).."_prefab", tostring(res_id)
end

function ResPath.GetDoorModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/npc/" .. math.floor(res_id / 1000).."_prefab", tostring(res_id)
end

function ResPath.GetGatherModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/gather/" .. math.floor(res_id / 1000).."_prefab", tostring(res_id)
end

-- function ResPath.GetNpcModel(res_id)
-- 	if res_id == nil or res_id == 0 or res_id == "" then
-- 		return nil, nil
-- 	end
-- 	return "actors/npc/" .. math.floor(res_id / 1000).."_prefab", tostring(res_id)
-- end

function ResPath.GetNpcModel(res_id, is_scene_obj)
	--print_error("暂时调用战旗模型的素材，当法宝有自己的模型后，才更改")
	if res_id == nil or res_id == 0 or res_id == "" then
		return nil, nil
	end
	return "actors/npc/" .. math.floor(res_id / 1000).."_prefab", is_scene_obj and tostring(res_id) .. "_S" or tostring(res_id)
end

function ResPath.GetWeaponModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/weapon/" .. math.floor(res_id / 100).."_prefab", tostring(res_id)
end

function ResPath.GetShenBingModel(res_id, prof)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	if res_id >= 10 then
		res_id = "9" .. prof .. "01" .."0".. res_id
	else
		res_id = "9" .. prof .. "01" .."00".. res_id
	end

	return "actors/weapon/" .. math.floor(res_id).."_prefab", tostring(res_id)
end

function ResPath.GetMingjiangModel(res_name)
	return string.format("actors/mingjiang/%s_prefab", res_name), res_name
end

function ResPath.GetWingModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

	return "actors/wing/" .. math.floor(res_id / 1000).."_prefab", tostring(res_id)
end

function ResPath.GetFootModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	local name = "Foot_" .. res_id
	return "effects/prefab/footprint/".. string.lower(name) .."_prefab", name
end

function ResPath.GetPifengModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

	return "actors/pifeng/" .. math.floor(res_id / 1000).."_prefab", tostring(res_id)
end

function ResPath.GetMountModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/mount/" .. math.floor(tonumber(res_id) / 1000).."_prefab", tostring(res_id)
end

function ResPath.GetGoddessModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/goddess/" .. res_id.."_prefab", tostring(res_id)
end

function ResPath.GetGoddessNotLModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/goddess/" .. res_id.."_prefab", tostring(res_id) .. "_S"
end

function ResPath.GetHunQiModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/hunqi/" .. res_id.."_prefab", tostring(res_id)
end

function ResPath.GetBoxModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/hunqi/17008", tostring(res_id)
end

function ResPath.GetHaloModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	local asset = "Halo_"
	if res_id >= 10 then
		asset = asset .. res_id
	else
		asset = asset .. "0" .. res_id
	end

	local name = asset
	return "effects/prefab/halo/" .. string.lower(name)  .. "_prefab", name
end

function ResPath.GetFaBaoModel(res_id, is_scene_obj)
	--print_error("暂时调用战旗模型的素材，当法宝有自己的模型后，才更改")
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	res_id = tostring(res_id)
	return "actors/baoju/" .. res_id.."_prefab", is_scene_obj and res_id .. "_S" or res_id
end

function ResPath.GetFamousGeneral(res_name)
	return "uis/views/bianshen/images_atlas", res_name
end

function ResPath.GetFamousGeneralBtnIcon(seq)
	return "uis/icons/bianshenicon_atlas", "btn_bianshen_icon_" .. seq .. ".png"
end

function ResPath.GetFashionShizhuangModel(res_id)
	return "actors/role/"..tostring(res_id).."_prefab", tostring(res_id)
end

function ResPath.GetFashionModel(res_id, sex, prof)
	if res_id == nil or res_id == 0 and prof == nil or prof == 0 and sex == nil then
		return nil, nil
	end
	if res_id >= 10 then
		res_id = "1" .. sex .. "0" .. prof .. "0" .. res_id
	else
		res_id = "1" .. sex .. "0" .. prof .. "00" .. res_id
	end
	
	return "actors/role/"..tostring(res_id).."_prefab", tostring(res_id)

end

function ResPath.GetStarEffect(res_id)
	local asset = "star_" .. res_id
	return "effects/prefab/misc/" .. string.lower(asset) .. "_prefab", asset
end

function ResPath.GetTitleModel(res_id)
	if res_id == nil then
		return nil, nil
	end
	return "effects/prefab/title/title_" .. string.lower(res_id) .. "_prefab", "Title_" .. res_id
end

function ResPath.GetStoryFbDoorModel()
	return "effects/prefab/misc/csm_prefab", "csm"
end

function ResPath.GetSpiritModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/spirit/" .. math.floor(tonumber(res_id) / 1000).."_prefab", tostring(res_id)
end

function ResPath.GetImpGuardModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil 
	end 
	return "actors/xiaogui/" .. math.floor(tonumber(res_id) / 1000).."_prefab", tostring(res_id)
end

function ResPath.GetHuoBanModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/huoban/" .. res_id.."_prefab", res_id .. "001"
end

function ResPath.GetGoddessFaZhenModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	local id = tostring(res_id)
	if res_id < 10 then
		id = "0" .. tostring(res_id)
	end
	local name = "huobanfz_" .. id
	return "effects/prefab/huobanfazhen/".. string.lower(name) .."_prefab", name
end

-- 获取化神元素球
function ResPath.GetHuashenBallModle()
	return "uis/views/advanceview/images_atlas", "BallModles"
end

-- 获取战斗坐骑
function ResPath.GetFightMountModel(res_id)
	return "actors/fightmount/"..tostring(math.floor(res_id / 1000)).."_prefab", tostring(res_id)
end

function ResPath.GetGoddessHaloModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	local id = tostring(res_id)
	if res_id < 10 then
		id = "0" .. tostring(res_id)
	end
	local name = "HuobanHalo_" .. id
	return "effects/prefab/huobanhalo/".. string.lower(name) .."_prefab", "HuobanHalo_" .. id
end

function ResPath.GetUiJingLingMingHunResid(res_id)
	local name = tostring(res_id)
	return "effects/prefab/ui/ui_jinglinminghun/".. string.lower(name) .."_prefab", name
end

function ResPath.GetHighBaoJuModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/baoju/" .. res_id.."_prefab", res_id .. "_L"
end

function ResPath.GetMedalModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

	return "actors/medal/" .. res_id.."_prefab", tostring(res_id)
end

function ResPath.GetForgeEquipModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/forge/" .. res_id.."_prefab", tostring(res_id)
end

function ResPath.GetQiZhiModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/qizhi/" .. res_id.."_prefab", tostring(res_id)
end

function ResPath.GetPetModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/pet/" .. res_id, res_id .. "001"
end

function ResPath.GetA2ChatLableIcon(color_name)
	return "uis/images_atlas", "chat_type_" .. color_name
end

function ResPath.GetBaseAttrIcon(attr_type)
	local asset, name = "", ""
	if attr_type == Language.Common.AttrNameNoUnderline.hp or attr_type == "maxhp" or attr_type == "max_hp" or attr_type == 33 then
		asset = "uis/images_atlas"
		name = "icon_info_hp"
	elseif attr_type == Language.Common.AttrNameNoUnderline.maxhp then
		asset = "uis/images_atlas"
		name = "icon_info_hp"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_maxhp then
		asset = "uis/images_atlas"
		name = "icon_info_hp"
	elseif attr_type == Language.Common.AttrNameNoUnderline.gongji or attr_type == 35 or attr_type == "gong_ji" then
		asset = "uis/images_atlas"
		name = "icon_info_gj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.attack then
		asset = "uis/images_atlas"
		name = "icon_info_gj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_gongji or attr_type == "gongji" then
		asset = "uis/images_atlas"
		name = "icon_info_gj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.fangyu or attr_type == "fangyu" or attr_type == "fang_yu" or attr_type == 36 then
		asset = "uis/images_atlas"
		name = "icon_info_fy"
	elseif attr_type == Language.Common.AttrNameNoUnderline.mingzhong or attr_type == "mingzhong" or attr_type == "ming_zhong" or attr_type == 37 then
		asset = "uis/images_atlas"
		name = "icon_info_mz"
	elseif attr_type == Language.Common.AttrNameNoUnderline.shanbi or attr_type == "shanbi" or attr_type == "shan_bi" or attr_type == 38 then
		asset = "uis/images_atlas"
		name = "icon_info_sb"
	elseif attr_type == Language.Common.AttrNameNoUnderline.baoji or attr_type == "baoji" or attr_type == "bao_ji" or attr_type == 39 then
		asset = "uis/images_atlas"
		name = "icon_info_bj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_baoji then
		asset = "uis/images_atlas"
		name = "icon_info_bj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_jingzhun then
		asset = "uis/images_atlas"
		name = "icon_info_bj"
	elseif attr_type == Language.Common.AttrNameNoUnderline.jianren or attr_type == "jianren" or attr_type == "jian_ren" or attr_type == 40 then
		asset = "uis/images_atlas"
		name = "icon_info_kb"
	elseif attr_type == Language.Common.AttrNameNoUnderline.movespeed or attr_type == "movespeed" then
		asset = "uis/images_atlas"
		name = "icon_info_sudu"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_pofang then
		asset = "uis/images_atlas"
		name = "icon_info_shjc"
	elseif attr_type == Language.Common.AttrNameNoUnderline.per_mianshang then
		asset = "uis/images"
		name = "icon_info_shjm"
	elseif attr_type == Language.Common.AttrNameNoUnderline.constant_zengshang or attr_type == "constant_zengshang" then
		asset = "uis/images_atlas"
		name = "icon_info_shjc"
	elseif attr_type == Language.Common.AttrNameNoUnderline.constant_mianshang or attr_type == "constant_mianshang" then
		asset = "uis/images_atlas"
		name = "icon_info_shjm"
	elseif attr_type == "lucky" then
		asset = "uis/images_atlas"
		name = "icon_info_luck"
	elseif attr_type == "exp" then
		asset = "uis/images_atlas"
		name = "icon_info_exp"
	end
	return asset, name
end

function ResPath.GetRuneIconResPath(attr_name)
	local asset, bundle = "", ""
	if attr_name == Language.Rune.AttrNameIndex.gongji then
		asset = "uis/images_atlas"
		bundle = "icon_info_gj"
	elseif attr_name == Language.Rune.AttrNameIndex.hp then
		asset = "uis/images_atlas"
		bundle = "icon_info_hp"
	elseif attr_name == Language.Rune.AttrNameIndex.baoji then
		asset = "uis/images_atlas"
		bundle = "icon_info_bj"
	elseif attr_name == Language.Rune.AttrNameIndex.shanbi then
		asset = "uis/images_atlas"
		bundle = "icon_info_sb"
	elseif attr_name == Language.Rune.AttrNameIndex.exp then
		asset = "uis/images_atlas"
		bundle = "icon_info_hp"
	elseif attr_name == Language.Rune.AttrNameIndex.mingzhong then
		asset = "uis/images_atlas"
		bundle = "icon_info_mz"
	elseif attr_name == Language.Rune.AttrNameIndex.kangbao then
		asset = "uis/images_atlas"
		bundle = "icon_info_kb"
	elseif attr_name == Language.Rune.AttrNameIndex.fangyu then
		asset = "uis/images_atlas"
		bundle = "icon_info_fy"
	elseif attr_name == Language.Rune.AttrNameIndex.weapon_gongji then
		asset = "uis/images_atlas"
		bundle = "icon_info_gj"
	elseif attr_name == Language.Rune.AttrNameIndex.weapon_hp then
		asset = "uis/images_atlas"
		bundle = "icon_info_hp"
	elseif attr_name == Language.Rune.AttrNameIndex.armor_shanbi then
		asset = "uis/images_atlas"
		bundle = "icon_info_sb"
	elseif attr_name == Language.Rune.AttrNameIndex.armor_fangyu then
		asset = "uis/images_atlas"
		bundle = "icon_info_fy"
	elseif attr_name == Language.Rune.AttrNameIndex.armor_kangbao then
		asset = "uis/images_atlas"
		bundle = "icon_info_kb"
	end
	return asset, bundle
end

--获取多种模型Asset
function ResPath.GetModelAsset(model_type, res_id)
	local asset, name = nil, nil
	if model_type == "ring" then
		asset, name = ResPath.GetForgeEquipModel("000" .. res_id)
	elseif model_type == "goddess" then
		asset, name = ResPath.GetGoddessModel(res_id)
	elseif model_type == "spirit" then
		asset, name = ResPath.GetSpiritModel(res_id)
	elseif model_type == "huoban" then
		asset, name = ResPath.GetHuoBanModel(res_id)
	elseif model_type == "wing" then
		asset, name = ResPath.GetWingModel(res_id)
	end
	return asset, name
end

function ResPath.GetZhiBaoHuanHuaHead(res_id)
	return "uis/views/baoju/images_atlas", "zhibao_head_" .. res_id
end

function ResPath.GetBoss(res_name)
	return "uis/rawimages/"..res_name, res_name .. ".png"
end

function ResPath.GetBossImages(res_name)
	return "uis/views/bossview/images_atlas", res_name
end

function ResPath.GetGoalDesImg(sys_type, goal_type)
	if sys_type == nil or goal_type == nil then
		return
	end
	return "uis/views/tips/timelimittitletips/images/nopack_atlas", "Img_des_" .. sys_type .. goal_type
end

function ResPath.GetBigGoalImg(sys_type)
	if sys_type == nil then
		return
	end
	return "uis/views/tips/timelimittitletips/images/nopack_atlas", "Img_biggoal_show" .. sys_type

end

function ResPath.GetSevenDayGift(res_name)
	return "uis/views/7logingift/images_atlas", res_name
end
function ResPath.GetYewaiGuajiMap(res_name)
	return "uis/views/yewaiguaji/images_atlas", "map"..res_name
end

function ResPath.GetWeaponShowModel(res_id, asset)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/weapon/" .. (asset or res_id).."_prefab", tostring(res_id)
end

function ResPath.GetTianShenIconByTaoZhuangType(taozhuang_type)
	return "uis/images_atlas", "tz_" .. taozhuang_type
end

function ResPath.GetVipLevelIcon(vip_level)
	return "uis/icons/vip_atlas", "vip_level_" .. vip_level
end

function ResPath.GetCompetitionActivity(res_name)
	return "uis/views/competitionactivityview/images_atlas", res_name
end

function ResPath.GetActivityview(res_name)
	return "uis/views/activityview/images_atlas", res_name
end

function ResPath.Getcompletechapterview(res_name)
	return "uis/views/tips/completechapterview/images/nopack_atlas", res_name
end

function ResPath.GetRuneRes(res_id)
	return "uis/views/rune/images_atlas", tostring(res_id)
end

function ResPath.GetRuneTreasureCount(res_id)
	return "uis/views/rune/images_atlas", "img_" .. tostring(res_id)
end

function ResPath.GetWidgets(res_name)
	return "uis/views/commonwidgets_prefab", res_name
end

function ResPath.GetRandomActRes(res_name)
	return "uis/views/randomact/images_atlas", res_name
end

function ResPath.GetRandomActLuckyChessRes(res_name)
	return "uis/views/randomact/luckychess/images_atlas", res_name
end

function ResPath.GetRestDoubleChongZhiRes(res_name)
	return "uis/views/mainui/images_atlas", res_name
end

function ResPath.GetJumpIcon(act_sep)
	if act_sep == 1 then
		return "uis/views/mainui/images_atlas", "Icon_Activity_5"
	elseif
		act_sep == 2 then
		return "uis/views/mainui/images_atlas", "Icon_Activity_21"
	elseif
		act_sep == 3 then
		return "uis/views/mainui/images_atlas", "Icon_Activity_6"
	elseif
		act_sep == 4 then
		return "uis/views/mainui/images_atlas", "Icon_Activity_19"
	elseif
		act_sep == 5 then
		return "uis/views/mainui/images_atlas", "Icon_System_Target"
	else
		return nil, nil
	end
end

function ResPath.GetWeaponEffect(res_id)
	return "effects/prefabs_weapon/misc_prefab", math.floor(res_id / 100000) .."_04"
end

function ResPath.GetWaBaoPic(scene_id)
	if scene_id == 103 then
		return "uis/rawimages/wabao_bg1", "wabao_bg1.png"
	elseif scene_id == 104 then
		return "uis/rawimages/wabao_bg2", "wabao_bg2.png"
	elseif scene_id == 105 then
		return "uis/rawimages/wabao_bg3", "wabao_bg3.png"
	end
	return nil, nil
end

function ResPath.GetHunQiSkillRes(res_id)
	return "uis/icons/skill_atlas", "HunQiSkill_" .. res_id
end

function ResPath.GetFishModelRes(res_id)
	return "uis/icons/fish/"..string.lower(tostring(res_id)).."_prefab", tostring(res_id)
end

function  ResPath.GetIconLock(res_id)
	return "uis/views/mainui/images_atlas","icon_lock_" ..res_id
end

function ResPath.GetGoddessRes(res_str)
	return "uis/views/goddess/images_atlas", res_str
end

function ResPath.GetMiningRes(res_str)
	return "uis/views/mining/images_atlas", res_str
end

function ResPath.GetXingLingRes(res_id)
	local name = "big_xingling_" .. res_id
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetAuraSearchRes(res_str)
	return "uis/views/aurasearchview_prefab", res_str
end

function ResPath.GetZhangkongStarRes(res_id)
	if res_id < 10 then
		return "uis/views/shengeview/images_atlas", "Star0" .. res_id
	elseif res_id == 10 then
		return "uis/views/shengeview/images_atlas", "Star" .. res_id
	end
end

function ResPath.GetXingLingEffect(color)
	if color == 1 then
		color = "lvse"
	elseif color == 2 then
		color = "lanse"
	elseif color == 3 then
		color = "zise"
	elseif color == 4 then
		color = "huangse"
	elseif color == 5 then
		color = "hongse"
	end

	local name = "UI_xingling_" .. color
	return "effects/prefab/ui_x/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetGoPawnImg(res_str)
	return "uis/views/gopawnview/images_atlas", res_str
end

function ResPath.GetBiPingImg(res_str)
	return "uis/views/tips/bipingtips", res_str
end

function ResPath.GetMapImg(res_id)
	return "uis/views/mapfind/images/nopack_atlas", "icon_map_"..res_id
end

function ResPath.GetLevelIcon(index)
	return "uis/views/fubenview/images_atlas", "fb_weapon" .. index
end

function ResPath.GetTowerSkillIcon(index)
	return "uis/icons/skill_atlas", "tower_skill_" .. index
end

function ResPath.GetTowerSkillTypeIcon(index)
	return "uis/views/fubenview/images_atlas", "bg_skill_type_" .. index
end

function ResPath.GetDefenseIcon(index)
	return "uis/views/fubenview/images_atlas", "defense_fb_tower_" .. index
end

function ResPath.GetHaloEffect(res_id)
	local name = "FQGH_0" .. res_id
	return "effects/prefab/halo_01/".. string.lower(name) .."_prefab", name
end

function ResPath.GetKuafuGuildBattle(res_id)
	return "uis/views/escortview/images_atlas", res_id
end

function ResPath.GetShenYinIcon(res_id)
	return "uis/icons/item/23900_atlas", "Item_2390" .. res_id 
end

function ResPath.GetShenYin(res_id)
	return "uis/views/shenyinview/images_atlas", res_id
end
function ResPath.GetGongXunRes(res_id)
	return "uis/views/baoju/images_atlas", res_id
end

function ResPath.GetJingJieLevelIcon(level)
	return "uis/icons/baoju_atlas", "longxing_" .. level
end

function ResPath.GetXingXiangCardBg(index)
	return "uis/views/xingxiangview/images_atlas", "xuanzhong_" .. index
end

function ResPath.GetXingXiangTitle(index)
	return "uis/views/xingxiangview/images_atlas", "name_" .. index
end

function ResPath.GetCardBGResPath(type)
	return "uis/views/immortalcardview/images/nopack_atlas", "card_type_" .. type
end

function ResPath.GetCardRewardResPath(type)
	return "uis/views/immortalcardview/images/nopack_atlas", "reward_type_" .. type
end

function ResPath.GetCardBtnResPath(type)
	return "uis/views/immortalcardview/images_atlas", "btn_card_type_" .. type
end

function ResPath.GetCardPayResPath(type)
	return "uis/views/immortalcardview/images_atlas", "card_pay_" .. type
end

function ResPath.GetRewardBgResPath(type)
	return "uis/views/immortalcardview/images_atlas", "immortal_circle_" .. type
end

function ResPath.GetCardForeverPayResPath()
	return "uis/views/immortalcardview/images_atlas", "forever_paid"
end

function ResPath.GetCardHadForeverPayResPath()
	return "uis/views/immortalcardview/images_atlas", "had_forever_paid"
end

function ResPath.GetCardShowImage(type)
	return "uis/views/immortalcardview/images/nopack_atlas", "card_show_" .. type
end

function ResPath.GetCardWayImage(type)
	return "uis/views/immortalcardview/images/nopack_atlas", "get_way_" .. type
end

function ResPath.GetCardTitleImage(type)
	return "uis/views/immortalcardview/images/nopack_atlas", "card_title_" .. type
end

function ResPath.GetOneYuanBtnImage(type)
	return "uis/views/oneyuanbuyview/images_atlas", "icon_btn_" .. type
end

function ResPath.GetAdvaneTargetTypeImage(type)
	return "uis/views/advanceview/images_atlas", "jinjie_" .. type
end

function ResPath.GetShenCiLevelImage(res_id)
	return "uis/views/advanceview/images_atlas", "shenci_level_" .. res_id
end

function ResPath.GetGoddesTargetTypeImage(type)
	return "uis/views/goddess/images_atlas", "jinjie_" .. type
end

function ResPath.GetAppearanceTargetTypeImage(type)
	return "uis/views/appearance/images_atlas", "jinjie_" .. type
end

function ResPath.GetMingJiangRes(res_name)
	return string.format("actors/mingjiang/%s_prefab", res_name), res_name
end

function ResPath.GetMingJiangNameImage(res_name)
	return "uis/views/bianshen/images_atlas", "mingjiang_" .. res_name
end

function ResPath.GetAdvanceImage(img_name)
	return "uis/views/advanceview/images_atlas", img_name
end

function ResPath.GetInnateSkillImage(skill_type, skill_index)
	if skill_type == 1 then
		return "uis/icons/talent/gongji_atlas", "Gongji_" .. skill_index
	elseif skill_type == 2 then
		return "uis/icons/talent/fangyu_atlas", "Fangyu_" .. skill_index
	elseif skill_type == 3 then
		return "uis/icons/talent/tongyong_atlas", "Tongyong_" .. skill_index
	elseif skill_type == 4 then
		return "uis/icons/talent/jingtong_atlas", "Jingtong_" .. skill_index
	end
end

function ResPath.GetMedalLevelImage(level)
	return "uis/views/advanceview/images/nopack_atlas", "medal_skill_" .. level
end

function ResPath.GetAppearMedalLevelImage(level)
	return "uis/views/appearance/images/nopack_atlas", "medal_skill_" .. level
end

-- 宝宝头像
function  ResPath.GetBabyIcon(res_id)
	return "uis/views/marriageview/baobao/image_atlas",res_id
end

function ResPath.GetHeFuCityRes(res_id)
	return "uis/views/hefucitycombatview/images_atlas", res_id
end

function ResPath.GetFishingRes(res_name)
	return "uis/views/fishing/images_atlas", res_name
end

function ResPath.GetNFRewardIcon(res_id)
	return "uis/views/kuafutuanzhan/images_atlas", "reward_" .. res_id
end


--头饰
function ResPath.GetTouShiModel(res_id)
	return "actors/headband/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

--腰饰
function ResPath.GetWaistModel(res_id)
	return "actors/belt/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

--麒麟臂
function ResPath.GetQilinBiModel(res_id, sex)
	if sex == 1 then
		return "actors/arm/man/" .. math.floor(res_id / 1000) .. "_prefab", res_id
	else
		return "actors/arm/woman/" .. math.floor(res_id / 1000) .. "_prefab", res_id
	end
end

--守护小鬼
function ResPath.GetShouHuXiaoGuiModel(res_id)
	return "actors/xiaogui/" .. math.floor(res_id / 1000) .."_prefab", res_id
end

--面饰
function ResPath.GetMaskModel(res_id)
	return "actors/mask/" .. res_id .. "_prefab", res_id
end

-- 灵珠模型
function ResPath.GetLingZhuModel(res_id, is_high)
	local param = "_CJ"
	if is_high then
		param = "_UI"
	end

	local name = "Lingzhu_" .. res_id .. param
	return "effects/prefab/lingzhu/".. string.lower(name) .."_prefab", name
end

-- 仙宝模型
function ResPath.GetXianBaoModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

	return "actors/lingbao/" .. res_id .. "_prefab", tostring(res_id)
end

-- 灵宠模型/灵童模型
function ResPath.GetLingChongModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end

	-- if IS_AUDIT_VERSION then
	-- 	local new_res_id = LingChongData.Instance:GetAuditRandomResId(res_id)
	-- 	if new_res_id > 0 then
	-- 		res_id = new_res_id
	-- 	end
	-- end
	return "actors/lingchong/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetLingChongModelEffect(res_id)
	return "actors/lingchong/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

-- 灵弓模型
function ResPath.GetLingGongModel(res_id, state)
	if state then
		-- 低模
		local new_res_id = math.floor(res_id / 10) .. 1
		return "actors/linggong/" .. math.floor(res_id / 1000) .. "_prefab", tostring(new_res_id)
	else
		return "actors/linggong/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
	end
end

-- 灵骑模型
function ResPath.GetLingQiModel(res_id)
	if IS_AUDIT_VERSION then
		local new_res_id = LingQiData.Instance:GetAuditRandomResId(res_id)
		if new_res_id > 0 then
			res_id = new_res_id
		end
	end

	return "actors/mount/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

-- 尾焰模型
function ResPath.GetWeiYanModel(res_id)
	local name = tostring(res_id)
	return "effects/prefab/actor/mount/".. string.lower(name) .."_prefab", name
end

-- 手环模型
function ResPath.GetShouHuanModel(res_id)
	local name = tostring(res_id)
	return "effects/prefab/shouhuan/".. string.lower(name) .."_prefab", name
end

-- 尾巴模型
function ResPath.GetTailModel(res_id)
	return "actors/weiba/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

-- 飞宠模型
function ResPath.GetFlyPetModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	
	return "actors/flypet/" .. math.floor(res_id / 1000) .. "_prefab", res_id
end

--获取小宠物
function ResPath.GetLittlePetModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
	return "actors/pet/" .. math.floor(res_id / 1000) .. "_prefab", tostring(res_id)
end

function ResPath.GetKf3V3(name)
	return "uis/views/kuafu3v3/images_atlas", name
end

function ResPath.GetKf3V3FinishImg(name)
	return "uis/rawimages/" .. name, name .. ".png"
end

function ResPath.GetHeadFrameIcon(res_id)
	if res_id == nil or res_id == -1 then
		return nil, nil
	end
	return "uis/icons/headframe_atlas", "head_frame_" .. res_id
end

-- 跨服1v1赛季奖励
function ResPath.GetKF1v1RankIcon(type)
	local bundle = "uis/views/kuafu3v3/images/nopack_atlas"
	if type == 1 then
		return bundle, "rank_red"
	elseif type == 2 then
		return bundle, "rank_yellow"
	elseif type == 3 then
		return bundle, "rank_zise"
	else
		return bundle, "rank_blue"
	end
end

function ResPath.GetScratchTicketRes(res_name)
	return "uis/views/scratchticket/images_atlas", res_name
end

-- 根据活动类型和id获取活动插画
function ResPath.GetActivityRawimage(act_type, act_id)
	if nil == act_type or nil == act_id then
		return
	end
	local bundle = "uis/rawimages/activity_" .. act_type .. "_" .. act_id
	local asset = "activity_" .. act_type .. "_" .. act_id .. ".png"
	return bundle, asset
end

function ResPath.GetShengXiaoJianYing(id)
	if nil == id then
		return
	end
	local bundle = "uis/views/shengxiaoview/images/nopack_atlas"
	local asset = "bg_" .. id .. ".png"
	return bundle, asset
end

function ResPath.GetGoldHuntQualityPic(id)
	if nil == id then
		return
	end
	local bundle = "uis/views/goldhuntview/images/nopack_atlas"
	local asset = "pop_" .. id
	return bundle, asset
end

function ResPath.GetExtremeChallngeIndex(index)
	return "uis/views/festivalactivity/images_atlas", "task_" .. index
end
function ResPath.GetHeadModel(res_id)
	if res_id == nil or res_id == 0 then
		return nil, nil
	end
    return string.format("actors/head/%s_prefab", math.floor(res_id / 1000)), tostring(res_id)
end
function ResPath.GetEuropeanWeddingText(direc, index)
	return "uis/views/marriageview/images/europeanweddingimages_atlas", "e_wedding_tips_"..direc.."_"..index
end


function ResPath.GetMidAutumnRankIcon(index)
	if index < 1 or index > 3 then
		return nil, nil
	end
	return "uis/views/festivalactivity/images_atlas", "rank_"..index
end

function ResPath.GetMJNameEffectByIndex(index)
	local name = "UI_sheng"
	if index == 1 then
		name = "UI_xian"
	elseif index == 2 then
		return "UI_shen"
	end
	return "effects/prefab/ui/" .. string.lower(name) .. "_prefab", name
end

function ResPath.GetLongxingLevelIcon(level)
	return "uis/icons/longxing_atlas", "longxing_" .. level
end

function ResPath.GetCoupleHomeImg(asset)
	return "uis/views/couplehome/images_atlas", tostring(asset)
end

function ResPath.GetRankTapByIndex(index)
	if index == 0 then
		return "uis/images_atlas", "rank_easy"
	elseif index == 1 then
		return "uis/images_atlas", "rank_hard"
	else
		return "uis/images_atlas", "rank_easy"
	end
end

function ResPath.GetCrossGolbMid(index)
	return "uis/views/crossgolbal/images/nopack_atlas", "mid_show_img" .. index
end

function ResPath.GetCrossGolbEff()
	return "effects/prefab/ui_x/kuafutarget_zhuzi_prefab", "KuaFuTarget_zhuzi"
end

function ResPath.GetCheckViewImage(asset)
	return "uis/views/checkview/images_atlas", tostring(asset)
end

function ResPath.GetOtherModel(res_id)
	return "actors/other/" .. res_id .."_prefab", tostring(res_id)
end

function ResPath.GetTodayThemeImg(asset)
	return "uis/views/tips/todaythemetips/images_atlas", asset
end

function ResPath.GetKFBorderland(asset)
	return "uis/views/kuafuborderland/images_atlas", asset
end

function ResPath.GetDouqiAsset(asset)
	return "uis/views/douqiview/images_atlas", asset
end
