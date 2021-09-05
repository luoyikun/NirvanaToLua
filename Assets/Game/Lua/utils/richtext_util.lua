RichTextUtil = RichTextUtil or BaseClass()

local is_small_value = false
local is_not_target = false
local guild_welcome_time = 0
local btn_text_font_size = 20					--有下划线按钮的文本大小

RichTextUtil.TextStr = ""

if nil ~= ResPoolMgr:GetRoot() then
	RichTextGroup.SetPool(ResPoolMgr:GetRoot().transform, function (gameObject)
		if ResPoolMgr:IsPoolObj(gameObject) then
			ResPoolMgr:Release(gameObject)
		else
			ResMgr:Destroy(gameObject)
		end
	end)
end

--是输出文本的需要写在这（AddText操作的为输出文本）!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!非输出文本不要写在这
RichTextUtil.Textlist = {
	["gamename"] = true,
	["camp"] = true,
	["r"] = true,
	["wordcolor"] = true,
	["wordsColor"] = true,
	["guildinfo"] = true,
	["guildinfo2"] = true,
	["money"] = true,
	["chinese_num"] = true,
	["convert_num"] = true,
	["wing"] = true,
	["mount"] = true,
	["shizhuang"] = true,
	["ShenBingUpgrade"] = true,
	["to_decimal"] = true,
	["monster"] = true,
	["red_paper"] = true,
	["activity"] = true,
	["prof"] = true,
	["hunshou"] = true,
	["chengjiu_title"] = true,
	["taozhuang"] = true,
	["bubble"] = true,
	["cross_team_fb"] = true,
	["halo"] = true,
	["cardzu"] = true,
	["shengong"] = true,
	["shenyi"] = true,
	["footprint"] = true,
	["fightmount"] = true,
	["fabao"] = true,
	["newline"] = true,
	["title"] = true,
	["mojie"] = true,
	["role_level"] = true,
	["equipsuit_ss"] = true,
	["equipsuit_cs"] = true,
	["territory"] = true,
	["xiannv_name"] = true,
	["guildpost"] = true,
	["shenzhou_weapon"] = true,
	["shenzhou_skill"] = true,
	["identify_level"] = true,
	["element_name"] = true,
	["shenge"] = true,
	["shenge_combine"] = true,
	["xingzuo_suit"] = true,
	["xingzuo_equip"] = true,
	["discount_buy"] = true,
	["time_limit_gift"] = true,
	["time_limit_gift2"] = true,
	["wangling_task"] = true,
	["qunxian_side"] = true,
	["tianjiangcaibao_task"] = true,
	["guild_maze_help"] = true,
	["guild_maze_chose"] = true,
	["jingling"] = true,
	["wuxing_title"] = true,
	["zhangkong"] = true,
	["xiannv_shengwu"] = true,
	["xiannv_shengwu_skill"] = true,
	["gather"] = true,
	["invest_type"] = true,
	["city"] = true,
	["instant_buy"] = true,
	["cloak"] = true,
	["fanfan"] = true,
	["multimount"] = true,
	["img_fuling_type"] = true,
	["img_fuling_skill_index"] = true,
	["rune_zhuling"] = true,
	["shenyin_zhaoyin"] = true,
	["cross_fish"] = true,
	["time_length"] = true,
	["zhuanzhi_taozhuang"] = true,
	["zhuanzhi_suit_part"] = true,
	["zhuanzhi_suit"] = true,
	["jinjie"] = true,
	["avatar"] = true,
	["upgrade_type"] = true,
	["upgrade_grade"] = true,
	["shenqi_type"] = true,
	["cross_gb_city"] = true,
	["orange_equip_name"] = true,
	["red_equip_name"] = true,
	["r_sex"] = true,
	["uplevel_theme"] = true,
	["zhuanzhi_wake"] = true,
	["guild_item"] = true,
	["tianshenhuti_equip"] = true,
	["douqi_grade"] = true,
	["cross_equip"] = true,
	["tianshu_type"] = true,
}

------------------------------注意-----------------------------------
--如果输出的是文本记得Textlist一定也要加(方便计算文本的数量，同时减少AddText的操作，优化性能)
--------------------------------------------------------------------
function RichTextUtil.Init()
	if nil == RichTextUtil.parse_func_list then
		RichTextUtil.parse_func_list = {
			["showpos"] = RichTextUtil.ParseShowPos,
			["gamename"] = RichTextUtil.ParseGameName,
			["face"] = RichTextUtil.ParseFace,
			["point"] = RichTextUtil.ParsePoint,
			["helppoint"] = RichTextUtil.ParseHelpPoint,
			["scene"] = RichTextUtil.ParseScene,
			["sceneid"] = RichTextUtil.ParseSceneId,
			["scene_id"] = RichTextUtil.ParseSceneId,
			["newline"] = RichTextUtil.ParseNewLine,
			["i"] = RichTextUtil.ParseItem,
			["myi"] = RichTextUtil.ParseMyItem,
			["myeq"] = RichTextUtil.ParseMyItem,
			["guild_item"] = RichTextUtil.ParseGuildWareHouseItem,
			["eq"] = RichTextUtil.ParseItem,
			["camp"] = RichTextUtil.ParseCamp,
			["r"] = RichTextUtil.ParseRole,
			["wordcolor"] = RichTextUtil.ParseWordColor,
			["wordsColor"] = RichTextUtil.ParseWordColor,
			["channelmark"] = RichTextUtil.ParseChannelMark,
			["team"] = RichTextUtil.ParseTeam,
			["teamfb"] = RichTextUtil.ParseTeamFb,
			["guildinfo"] = RichTextUtil.ParseGuildInfo,
			["guildinfo2"] = RichTextUtil.ParseGuildInfo2,
			["guildjoin"] = RichTextUtil.ParseGuildJoin,
			["money"] = RichTextUtil.ParseMoney,
			["chinese_num"] = RichTextUtil.ParseChineseNum,
			["convert_num"] = RichTextUtil.ParseConvertNum,
			["zhuxie_task_item"] = RichTextUtil.ParseZhuXieTaskItem,
			["wing"] = RichTextUtil.ParseWing,
			["wing_name"] = RichTextUtil.ParseWingName,
			["fazhen_name"] = RichTextUtil.ParseFaZhenName,
			["defend_area"] = RichTextUtil.ParseDefendArea,
			["mount"] = RichTextUtil.ParseMount,
			["shizhuang"] = RichTextUtil.ParseFashion,
			["ShenBingUpgrade"] = RichTextUtil.ParseShenBing,
			["qibing"] = RichTextUtil.ParseQiBing,
			["to_decimal"] = RichTextUtil.ParseToDecimal,
			["monster"] = RichTextUtil.ParseMonster,
			["title"] = RichTextUtil.ParseTitle,
			["eq_shenzhu"] = RichTextUtil.ParseEquipShenZhu,
			["eq_quality"] = RichTextUtil.ParseEquipQuality,
			["stone"] = RichTextUtil.ParseStone,
			["csa_sub_type"] = RichTextUtil.ParseCsaSubType,
			["openLink"] = RichTextUtil.ParseOpenLink,
			["qingyuan_card"] = RichTextUtil.ParseQingYuanCard,
			["red_paper"] = RichTextUtil.ParseRedPaper,
			["activityPos"] = RichTextUtil.ParseActivityPos,
			["activity"] = RichTextUtil.ParseActivity,
			["prof"] = RichTextUtil.ParseProf,
			["mountfly"] = RichTextUtil.ParseMountFly,
			["hunshou"] = RichTextUtil.ParseHunShou,
			["chengjiu_title"] = RichTextUtil.ParseChengJiuTitle,
			["xianjie"] = RichTextUtil.ParseXianJie,
			["card_color"] = RichTextUtil.ParseCardColor,
			["card"] = RichTextUtil.ParseCard,
			["gengu_title"] = RichTextUtil.ParseGengu,
			["jingmai_title"] = RichTextUtil.ParseJingmai,
			["mentality"] = RichTextUtil.ParseMentality,
			["shenzhuang"] = RichTextUtil.ParseShenzhuang,
			["jinglingyun"] = RichTextUtil.ParseSpriteCloud,
			["jinglingslot"] = RichTextUtil.ParseSpriteSlot,
			["taozhuang"] = RichTextUtil.ParseTaozhuang,
			["pet_suit_seq"] = RichTextUtil.ParsePet,
			["mine"] = 	RichTextUtil.ParseMine,
			["cardzu"] = RichTextUtil.ParseCardzu,
			["fanfan"] = RichTextUtil.ParseFanFanZhuan,
			["cross_tuanzhan_side"] = RichTextUtil.ParseTuanZhan,
			["multimount"] = RichTextUtil.ParseMulitMount,
			["bubble"] = RichTextUtil.ParseBubble,
			["magic_card"] = RichTextUtil.ParseMagicCard,
			["fish"] = RichTextUtil.ParseFishPond,
			["cross_team_fb"] = RichTextUtil.ParseFindCrossTeammates,
			["guildback"] = RichTextUtil.ParseGuildBack,
			["halo"] = RichTextUtil.ParseHalo,
			["shengong"] = RichTextUtil.ParseShengong,
			["shenyi"] = RichTextUtil.ParseShenyi,
			["footprint"] = RichTextUtil.ParseFootprint,
			["fightmount"] = RichTextUtil.ParseFightMount,
			["fabao"] = RichTextUtil.ParseFaBao,
			["mojie"] = RichTextUtil.ParseMojie,
			["role_level"] = RichTextUtil.ParseRoleLevel,
			["equipsuit_ss"] = RichTextUtil.ParseForgeSuitSS,
			["equipsuit_cs"] = RichTextUtil.ParseForgeSuitCS,
			["zhuanzhi_wake"] = RichTextUtil.ParseForgeJueXing,
			["territory"] = RichTextUtil.ParseTerritory,
			["xiannv_name"] = RichTextUtil.FamousXiannv,
			["guildpost"] = RichTextUtil.ParseGuildPost,
			["shenzhou_weapon"] = RichTextUtil.ParseHunQiName,
			["shenzhou_skill"] = RichTextUtil.ParseHunQiSkill,
			["help_baoxiang"] = RichTextUtil.ParseHelpBaoXiang,
			["visible_level"] = RichTextUtil.ParsePass,
			["shenge"] = RichTextUtil.ParseShenGe,
			["identify_level"] = RichTextUtil.ParseIdentifyLevel,
			["element_name"] = RichTextUtil.ParseElementName,
			["advance_preview"] = RichTextUtil.ParseAdvancePreview,
			["shenge_combine"] = RichTextUtil.ParseShengeCombine,
			["xingzuo_suit"] = RichTextUtil.ParseXingzuoSuit,
			["xingzuo_equip"] = RichTextUtil.ParseXingzuoEquip,
			["discount_buy"] = RichTextUtil.ParseDiscountBuy,
			["time_limit_gift"] = RichTextUtil.ParseTimeLimitGift,
			["time_limit_gift2"] = RichTextUtil.ParseGiftTimeLimit,
			["open_guild"] = RichTextUtil.ParseLinkToGuild,
			["wangling_task"] = RichTextUtil.ParseWanglingTask,
			["qunxian_side"] = RichTextUtil.ParseQunxianSide,
			["tianjiangcaibao_task"] = RichTextUtil.ParseTianjiangcaibaoTask,
			["guild_maze"] = RichTextUtil.ParseGuildMaze,
			["guild_maze_help"] = RichTextUtil.ParseGuildMazeHelp,
			["guild_maze_chose"] = RichTextUtil.ParseGuildMazeChose,
			["jingling"] = RichTextUtil.ParseJingLing,
			["wuxing_title"] = RichTextUtil.ParseWuXingTitle,
			["zhangkong"] = RichTextUtil.ParseZhangKongUp,
			["xiannv_shengwu"] = RichTextUtil.ParseShengWu,
			["xiannv_shengwu_skill"] = RichTextUtil.ParseShengWuSkill,
			["question_answer"] = RichTextUtil.ParseQuestionAnswer,
			["gather"] = RichTextUtil.ParseGather,
			["invest_type"] = RichTextUtil.ParseInvest,
			["guild_xiannv_pos"] = RichTextUtil.ParsGoddressFire,
			["city"] = RichTextUtil.ParseCity,
			["instant_buy"] = RichTextUtil.ParseBuy,
			["cloak"] = RichTextUtil.ParseCloak,
			["zc_guolv"] = RichTextUtil.ParseGuoLv,
			["shenshou_compose_id"] = RichTextUtil.ShenShouCompose,
			["fanfan"] = RichTextUtil.ParseFanFan,
			["img_fuling_type"] = RichTextUtil.ParseImgFuLingType,
			["img_fuling_skill_index"] = RichTextUtil.ParseImgFuLingSkillIndex,
			["rune_zhuling"] = RichTextUtil.ParseRuneZhuLing,
			["liehun_id"] = RichTextUtil.ParseRuneZhaoYin,
			["buy"] = RichTextUtil.MarketBuy,
			["cross_fish"] = RichTextUtil.CrossFish,
			["time_length"] = RichTextUtil.TimeContdom,
			["item_id"] = RichTextUtil.ItemId,
			["zhuanzhi_taozhuang"] = RichTextUtil.ZhuanzhiTaoZhuang,
			["zhuanzhi_suit_part"] = RichTextUtil.ZhuanzhiSuitPart,
			["zhuanzhi_suit"] = RichTextUtil.ZhuanzhiSuit,
			["avatar"] = RichTextUtil.ParseAvatar,
			["shuxingdan_type"] = RichTextUtil.ParseShuxingdanType,
			["shadow_text"] = RichTextUtil.ParseShadowText,
			["outline_text"] = RichTextUtil.ParseOutlineText,
			["text_image"] = RichTextUtil.ParseImage,
			["jinjie"] = RichTextUtil.ParseJinJie,
			["yaoshi"] = RichTextUtil.ParseYaoShi,
			["toushi"] = RichTextUtil.ParseTouShi,
			["qilinbi"] = RichTextUtil.ParseQilinBi,
			["mask"] = RichTextUtil.ParseMask,
			["upgrade_type"] = RichTextUtil.UpgradeType,
			["upgrade_grade"] = RichTextUtil.UpgradeGrade,
			["goal_system"] = RichTextUtil.Goal_System,
			["night_fight_camp"] = RichTextUtil.NightFightCamp,
			["shenqi_type"] = RichTextUtil.ParseShengQi,
			["yzddtop"] = RichTextUtil.ParseYiZhanDaoDi,
			["cross_gb_city"] = RichTextUtil.ParseCrossGbCity,
			["orange_equip_name"] = RichTextUtil.ParseOrangeSuitCollect,
			["red_equip_name"] = RichTextUtil.ParseRedEquipCollect,
			["room_type"] = RichTextUtil.ParseRoomTypepCollect,
			["r_sex"] = RichTextUtil.ParseRoleNameAndSex,
			["uplevel_theme"] = RichTextUtil.ParseAdvancedReturnTxt,
			["guild_gongzi"] = RichTextUtil.ParseGuildGongzi,
			["scene_name"] = RichTextUtil.ParseSceneName,
			["tianshu_type"] = RichTextUtil.ParseTianShuTypeName,
			["chpater_id"] = RichTextUtil.ParseMythChpater,
			["tianshenhuti_equip"] = RichTextUtil.ParseTianshenhutiEquip,
			["douqi_grade"] = RichTextUtil.ParseDouqiGrade,
			["cross_equip"] = RichTextUtil.ParseDouQiEquip,
		}
	end
end

-- 清除richtext.同时移除加载器
function RichTextUtil.ClearRichText(rich_text)
	if not IsNil(rich_text) then
		if nil ~= rich_text.__metaself__ and nil ~= rich_text.__metaself__.rich_text_loaders then
			for k, _ in pairs(rich_text.__metaself__.rich_text_loaders) do
				k:DeleteMe()
			end
			rich_text.__metaself__.rich_text_loaders = nil
			rich_text.__metaself__.rich_text_loaders_counter = nil 
		end
		rich_text:Clear()
	end
end

-- not_target 按钮可穿透, font_size已没用但是去掉太麻烦就不管了
function RichTextUtil.ParseRichText(rich_text, content, font_size, color, is_small, not_target, udl_btn_text_font_size)
	if IsNil(rich_text) or nil == content then return end
	-- 先清空rich_text
	RichTextUtil.TextStr = ""
	RichTextUtil.ClearRichText(rich_text)

	btn_text_font_size = udl_btn_text_font_size or 20					--有下划线按钮的文本大小

	--记录是否显示小图
	is_small_value = is_small

	is_not_target = not_target

	font_size = font_size or 20
	color = color or COLOR.WHITE

	content = CommonDataManager.ParseGameName(content)

	local i, j = 0, 0
	local element_list = {}
	local last_pos = 1
	for loop_count = 1, 100 do
		i, j = string.find(content, "({.-})", j + 1)-- 匹配规则{face;20} {item;26000}
		if nil == i or nil == j then
			if last_pos <= #content then
				table.insert(element_list, {0, string.sub(content, last_pos, -1)})
			end
			break
		else
			if 1 ~= i and last_pos ~= i then
				table.insert(element_list, {0, string.sub(content, last_pos, i - 1)})
			end
			table.insert(element_list, {1, string.sub(content, i, j)})
			last_pos = j + 1
		end
	end
	for i2, v2 in ipairs(element_list) do
		if 0 == v2[1] then
			RichTextUtil.AddText(rich_text, v2[2], color)
		else
			local rule = string.sub(v2[2], 2, -2)
			RichTextUtil.ParseMark(rich_text, Split(rule, ";"), font_size, color)
		end
	end
	if RichTextUtil.TextStr ~= "" then
		if nil == rich_text then
			print_error("rich text is nil!!!!!")
			return
		end

		if nil == rich_text.AddText then
			print_error("rich text AddText is nil!!!!!")
			return
		end
		rich_text:AddText(RichTextUtil.TextStr)
		RichTextUtil.TextStr = ""
	end
end

--获取解析后的字符串(纯文本的情况下可调用)
function RichTextUtil.GetAnalysisText(content, color)
	RichTextUtil.TextStr = ""
	color = color or COLOR.WHITE
	local i, j = 0, 0
	local element_list = {}
	local last_pos = 1
	for loop_count = 1, 100 do
		i, j = string.find(content, "({.-})", j + 1)-- 匹配规则{face;20} {item;26000}
		if nil == i or nil == j then
			if last_pos <= #content then
				table.insert(element_list, {0, string.sub(content, last_pos, -1)})
			end
			break
		else
			if 1 ~= i and last_pos ~= i then
				table.insert(element_list, {0, string.sub(content, last_pos, i - 1)})
			end
			table.insert(element_list, {1, string.sub(content, i, j)})
			last_pos = j + 1
		end
	end
	local rule
	for i2, v2 in ipairs(element_list) do
		if 0 == v2[1] then
			RichTextUtil.AddText(nil, v2[2], color)
		else
			rule = string.sub(v2[2], 2, -2)
			RichTextUtil.ParseMark(nil, Split(rule, ";"), nil, color)
		end
	end
	return RichTextUtil.TextStr
end

--添加文字
function RichTextUtil.AddText(rich_text, text, color)
	local str = text
	if color then
		str = ToColorStr(text, color)
	end
	RichTextUtil.TextStr = string.format("%s%s", RichTextUtil.TextStr, str)
end

--添加按钮
function RichTextUtil.CreateBtn(rich_text, name, font_size, color, callback, btn_bg_path)
	if nil == rich_text then
		return
	end

	local root_obj = nil
	if is_not_target then
		root_obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "RichButtonNotTarget")
	else
		root_obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "RichButton")
	end

	local root_node = U3DObject(root_obj.gameObject, nil, rich_text.__metaself__)
	local bg_image = U3DObject(root_node.uiname_table:Find("BgImage"), nil, rich_text.__metaself__)
	local bundle, asset = ResPath.GetImages(btn_bg_path or "btn_rich_btn")
	bg_image.image:LoadSpriteAsync(bundle, asset)

	local content = U3DObject(root_node.uiname_table:Find("Text"), nil, rich_text.__metaself__)
	content.text.fontSize = font_size
	content.text.text = ToColorStr(name, color)
	rich_text:AddObject(root_obj)

	if callback then
		callback(root_node.button)
	end
end

--添加下划线按钮
function RichTextUtil.CreateUnderLineBtn(rich_text, name, font_size, color, callback, btn_bg_path, target)
	if nil == rich_text then
		return
	end

	local button_name = ToColorStr(name, color)
	local root_obj = nil
	if target then		--外部调用创建按钮是否可穿透
		is_not_target = not target
	end

	if is_not_target then
		root_obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "RichButtonNotTargetUnderLine")
	else
		root_obj =  ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "RichButtonUnderLine")
	end

	local root_node = U3DObject(root_obj.gameObject, nil, rich_text.__metaself__)
	local content = U3DObject(root_node.uiname_table:Find("Text"), nil, rich_text.__metaself__)
	content.text.fontSize = font_size
	content.text.text = button_name
	
	if is_not_target then
		local bg_image = U3DObject(root_node.uiname_table:Find("BgImage"), nil, rich_text.__metaself__)
		local bundle, asset = ResPath.GetMainUI(btn_bg_path or BUTTON_BG_NAME[GameEnum.ITEM_COLOR_WHITE])
		bg_image.image:LoadSpriteAsync(bundle, asset)
		bg_image:SetActive(true)
	else
		local content_line = U3DObject(root_node.uiname_table:Find("ContentLine"), nil, rich_text.__metaself__)
		local function CheckNameLine(name_num)
			local line = {}
			line[0] = "_"
			if nil ~= name_num then 
				for i = 1, name_num do
					line[i] = line[i - 1] .. "_"
				end
				return line[name_num]
			end
		end

		local line_string = CheckNameLine(#button_name)
		content_line.text.text = string.format(Language.Chat.Underline, color, line_string)
	end

	rich_text:AddObject(root_obj)

	if callback then
		callback(root_node.button)
	end
end

function RichTextUtil.ParseGuildGongzi(rich_text)
	local bundle,asset = ResPath.GetImages("icon_gold_5_bind") 
	RichTextUtil.CreateImage(rich_text, bubble, asset)
end

function RichTextUtil.ParseSceneName(rich_text, params, font_size, color)
	if #params < 3 then return end

	local scene_id = tonumber(params[3])
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_cfg then
		return
	end

	local color_str
	if 8 == string.len(params[2]) then
		color_str = string.sub(params[2], 2, -1)
	else
		color_str = params[2]
	end
	if not string.find(color_str, "#") then
		color_str = "#" .. color_str
	end
	if 7 == string.len(color_str) then
		RichTextUtil.AddText(rich_text, scene_cfg.name, color_str)
	end
end

function RichTextUtil.ParseTianShuTypeName(rich_text, params, font_size, color)
	local tianshu_type_index = tonumber(params[2]) or 0
	local name = TianShuData.Instance:GetTianShuTypeNameByIndex(tianshu_type_index + 1)
	RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW)
end

function RichTextUtil.ParseMythChpater(rich_text, params, font_size, color)
	local chpater_id = tonumber(params[2]) or 0
	local link_type = tonumber(params[3]) or 0
	local name = MythData.Instance:GetChapterNameById(chpater_id)
	if name then
		RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW)
	end
end

--添加图片
function RichTextUtil.CreateImage(rich_text, bubble, asset)
	local function GetImgObj()
		if is_small_value then
			return ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "RichImage_Small")
		else
			return ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "RichImage")
		end
	end
	local obj = GetImgObj()
	local bundle1,asset1 = "", ""
	if obj then
		local image_node = U3DObject(obj.gameObject, nil, rich_text.__metaself__)
		if nil == bubble or nil == asset then
			bundle1,asset1 = ResPath.GetImages(asset) 
			image_node.image:LoadSpriteAsync(bundle1, asset1)
		else
			image_node.image:LoadSpriteAsync(bubble, asset)
		end
		rich_text:AddObject(obj)
	end
end

function RichTextUtil.ParseAvatar(rich_text, params)
	local seq = tonumber(params[2]) or 0
	local head_frame_info = HeadFrameData.Instance:GetChooseAllData(seq)
	if head_frame_info then
		local name = head_frame_info.name
		RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW)
	end
	
end

-- 添加大表情
function RichTextUtil.CreateBigFace(rich_text, index)
	local bundle, asset = ResPath.GetMiscPreloadRes(is_small_value and "BigfaceSlotSmall" or "BigfaceSlot")
	local slot_obj = U3DObject(ResPoolMgr:TryGetGameObject(bundle, asset))
	local is_small = is_small_value
	rich_text:AddObject(slot_obj.gameObject)
	bundle, asset = ResPath.GetResBigFaceByIndex(index, is_small_value and "ImageSmall" .. index or "Image" .. index)

	local child_number = slot_obj.transform.childCount
	for i = 0, child_number - 1 do
		local child = slot_obj.transform:GetChild(i).gameObject
		ResMgr:Destroy(child)
	end

	rich_text.__metaself__.rich_text_loaders_counter = rich_text.__metaself__.rich_text_loaders_counter or 0
	rich_text.__metaself__.rich_text_loaders_counter = rich_text.__metaself__.rich_text_loaders_counter + 1
	local async_loader = AllocAsyncLoader(rich_text.__metaself__, "rich_text_loader" .. rich_text.__metaself__.rich_text_loaders_counter)
	async_loader:Load(bundle, asset, function(obj)
		if IsNil(obj) then
			return
		end

		if is_small then -- prefab里的坐标是乱搞的，太多先在程序里统一改
			local rect_t = obj:GetComponent(typeof(UnityEngine.RectTransform))
			rect_t.anchorMin = Vector2(0.5, 0.5)
			rect_t.anchorMax = Vector2(0.5, 0.5)
			obj.transform:SetLocalPosition(0, 0, 0)
		end

		obj.transform:SetParent(slot_obj.transform, false)
	end)

	rich_text.__metaself__.rich_text_loaders = rich_text.__metaself__.rich_text_loaders or {}
	rich_text.__metaself__.rich_text_loaders[async_loader] = true
end

-- 添加普通动态表情
function RichTextUtil.CreateNormalFace(rich_text, index)
	local bundle, asset = ResPath.GetMiscPreloadRes(is_small_value and "NormalfaceSlotSmall" or "NormalfaceSlot")
	local slot_obj = U3DObject(ResPoolMgr:TryGetGameObject(bundle, asset))
	local is_small = is_small_value
	rich_text:AddObject(slot_obj.gameObject)
	local new_index = 100 + index - 1
	bundle, asset = ResPath.GetResNormalFaceByIndex(new_index, "Image" .. new_index)

	local child_number = slot_obj.transform.childCount
	for i = 0, child_number - 1 do
		local child = slot_obj.transform:GetChild(i).gameObject
		ResMgr:Destroy(child)
	end
	
	rich_text.__metaself__.rich_text_loaders_counter = rich_text.__metaself__.rich_text_loaders_counter or 0
	rich_text.__metaself__.rich_text_loaders_counter = rich_text.__metaself__.rich_text_loaders_counter + 1
	local async_loader = AllocAsyncLoader(rich_text.__metaself__, "rich_text_loader" .. rich_text.__metaself__.rich_text_loaders_counter)
	async_loader:Load(bundle, asset, function(obj)
		if IsNil(obj) then
			return
		end

		if is_small then -- prefab里的坐标是乱搞的，太多先在程序里统一改
			local rect_t = obj:GetComponent(typeof(UnityEngine.RectTransform))
			rect_t.anchorMin = Vector2(0.5, 0.5)
			rect_t.anchorMax = Vector2(0.5, 0.5)
			obj.transform:SetLocalPosition(0, 0, 0)
		end
		local scale = is_small and 0.7 or 0.9
		obj.transform.localScale = Vector3(scale, scale, scale)
		obj.transform:SetParent(slot_obj.transform, false)
	end)

	rich_text.__metaself__.rich_text_loaders = rich_text.__metaself__.rich_text_loaders or {}
	rich_text.__metaself__.rich_text_loaders[async_loader] = true
end

-- 添加特殊表情
function RichTextUtil.CreateSpecial(rich_text, index)
	local function GetSpecialObj()
		if is_small_value then
			return ResPoolMgr:TryGetGameObject(ResPath.GetResSpecialFace("ImageSmall" .. index))
		else
			return ResPoolMgr:TryGetGameObject(ResPath.GetResSpecialFace("Image" .. index))
		end
	end
	local obj = GetSpecialObj()
	if obj then
		rich_text:AddObject(obj)
	end
end

function RichTextUtil.ParseOutlineText(rich_text, params, font_size, color)
	local str = params[2]
	local text_color = params[3]
	local outline_color = params[4]
	local shadow_x = params[5] or 1
	local shadow_y = params[6] or -1

	if nil == str or nil == text_color or nil == outline_color then
		return
	end

	local obj = ResPoolMgr:TryGetGameObject("uis/views/commonwidgets_prefab", "RichOutlineText")
	if obj then
		local image_node = U3DObject(obj.gameObject, nil, rich_text.__metaself__)
		image_node.text.text = str
		image_node.text.fontSize = font_size
		image_node.text.color = StrToColor(text_color)
		image_node.outline.effectColor = StrToColor(outline_color)
		image_node.outline.effectDistance = Vector2(shadow_x, shadow_y)

		rich_text:AddObject(obj)
	end
end

function RichTextUtil.ParseShadowText(rich_text, params, font_size, color)
	local str = params[2]
	local text_color = params[3]
	local shadow_color = params[4]

	if nil == str or nil == text_color or nil == shadow_color then
		return
	end

	local obj = ResPoolMgr:TryGetGameObject("uis/views/commonwidgets_prefab", "RichShadowText")
	if obj then
		local image_node = U3DObject(obj.gameObject, nil, rich_text.__metaself__)
		image_node.text.text = str
		image_node.text.fontSize = font_size
		image_node.text.color = StrToColor(text_color)
		image_node.shadow.effectColor = StrToColor(shadow_color)

		rich_text:AddObject(obj)
	end
end

function RichTextUtil.ParseImage(rich_text, params, font_size, color)
	local bundle = params[2]
	local asset = params[3]
	if nil == bundle or nil == asset then
		return
	end
	local obj = ResPoolMgr:TryGetGameObject("uis/views/commonwidgets_prefab", "RichTextImage")
	if obj then
		local image_node = U3DObject(obj.gameObject, nil, rich_text.__metaself__)
		image_node.image:LoadSpriteAsync(bundle, asset, function ()
			image_node.image:SetNativeSize()
		end)

		rich_text:AddObject(obj)
	end
end

function RichTextUtil.ParseMark(rich_text, params, font_size, color)
	local mark = params[1]
	if nil == mark then return end

	RichTextUtil.Init()
	local func = RichTextUtil.parse_func_list[mark]
	local text_add = RichTextUtil.Textlist[mark]
	if func then
		if not text_add and RichTextUtil.TextStr ~= "" then
			if rich_text then
				rich_text:AddText(RichTextUtil.TextStr)
				RichTextUtil.TextStr = ""
			end

		end
		func(rich_text, params, font_size, color)
	else
		print_error("unknown mark:" .. mark .. "!")
	end
end

--不做任何处理
function RichTextUtil:ParsePass()

end

-- 采集物
function RichTextUtil.ParseGather(rich_text, params, font_size, color)
	local gather_id = params[2] or 0
	gather_id = tonumber(gather_id)
	local gather_config_list = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
	local gather_config = gather_config_list[gather_id]
	local gather_name = gather_config and gather_config.show_name or ""
	color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, gather_name, color)
end

function RichTextUtil.ParseShowPos(rich_text, params, font_size, color)

end

function RichTextUtil.ParseGameName(rich_text, params, font_size, color)
	RichTextUtil.AddText(rich_text, CommonDataManager.GetGameName(), color)
end

function RichTextUtil.ParseFace(rich_text, params, font_size, color)
	local face_id = tonumber(params[2]) or 0
	if face_id >= 1 and face_id < COMMON_CONSTS.BIGCHATFACE_ID_FIRST then
		RichTextUtil.CreateNormalFace(rich_text, face_id)
	elseif face_id >= COMMON_CONSTS.BIGCHATFACE_ID_FIRST and face_id < COMMON_CONSTS.SPECIALFACE_ID_FIRST then
		local id = face_id - COMMON_CONSTS.BIGCHATFACE_ID_FIRST
		RichTextUtil.CreateBigFace(rich_text, id)
	elseif face_id >= COMMON_CONSTS.SPECIALFACE_ID_FIRST then
		local id = face_id - COMMON_CONSTS.SPECIALFACE_ID_FIRST
		RichTextUtil.CreateSpecial(rich_text, id)
	end
end

function RichTextUtil.ParsePoint(rich_text, params, font_size, color)
	if #params < 6 then return end
	local point_text = params[2] .. "(" .. params[3] .. "," .. params[4] .. ")"
	if tonumber(params[6]) >= 0 and tonumber(params[6]) < 100 then
		point_text = string.format(Language.Common.Line, CommonDataManager.GetDaXie(tonumber(params[6]) + 1)) .. point_text
	end
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				local is_cross = tonumber(params[7]) or 0
				if 1 == is_cross then
					local is_mizang = true
					local boss_layer = BossData.Instance:GetCrossLayerBySceneID(tonumber(params[5]) or 0)
					if nil == boss_layer then
						is_mizang = false
						boss_layer = BossData.Instance:GetMiZangCrossLayerBySceneID(tonumber(params[5]) or 0)
					end

					local pos_x = tonumber(params[3]) or 0
					local pos_y = tonumber(params[4]) or 0
					if is_mizang then
						if SceneType.CrossBoss ~= Scene.Instance:GetSceneType() then
							CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_BOSS, boss_layer, nil, nil, pos_x, pos_y)
							return
						end
					else
						if SceneType.KFMiZangBoss ~= Scene.Instance:GetSceneType() then
							CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_CROSS_MIZANG_BOSS, boss_layer, nil, nil, pos_x, pos_y)
							return
						end
					end
				end
				
				if tonumber(params[6]) >= 0 then
					RichTextUtil.FlyToPos(tonumber(params[5]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0, tonumber(params[6]))
				else
					RichTextUtil.FlyToPos(tonumber(params[5]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0)
				end
			end)
		end
	end
	color = CHAT_TEXT_COLOR.GREEN
	RichTextUtil.CreateUnderLineBtn(rich_text, point_text, font_size, color, callback)
end


function RichTextUtil.ParseHelpPoint(rich_text, params, font_size, color)
	if #params < 6 or tonumber(params[6]) == GameVoManager.Instance:GetMainRoleVo().role_id then return end
	local point_text = CommonDataManager.GetDaXie(1) .. params[2] .. "(" .. params[3] .. "," .. params[4] .. ")"

	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				RichTextUtil.FlyToPos(tonumber(params[5]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0, 0)
				MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
			end)
		end
	end
	color = CHAT_TEXT_COLOR.GREEN

	RichTextUtil.CreateUnderLineBtn(rich_text, point_text, font_size, color, callback)
end

function RichTextUtil.ParseScene(rich_text, params, font_size, color)
	if #params < 3 then return end
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				local scene_id = tonumber(params[3])
				if Scene.Instance:GetSceneId() == scene_id then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.HasInTargetScene)
				else
					GuajiCtrl.Instance:MoveToScene(scene_id)
				end
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, params[2], font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseSceneId(rich_text, params, font_size, color)
	if #params < 2 then return end
	local scene_id = tonumber(params[2])
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_cfg then
		return
	end

	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				if Scene.Instance:GetSceneId() == scene_id then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.HasInTargetScene)
				else
					GuajiCtrl.Instance:MoveToScene(scene_id)
				end
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, scene_cfg.name, font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseNewLine(rich_text, params, font_size, color)
	RichTextUtil.AddText(rich_text, "\n")
end

function RichTextUtil.ParseGuildMaze(rich_text, params, font_size, color)
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				GuildCtrl.Instance:SendGuildMazeAnswer(params[2], params[3], params[4])
			end)
		end
	end
	RichTextUtil.CreateUnderLineBtn(rich_text, string.format(Language.Guild.DoorNum, params[3]), font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseGuildMazeHelp(rich_text, params, font_size, color)
	color = params[3]
	RichTextUtil.AddText(rich_text, params[2], color)
	-- RichTextUtil.ParseRichText(rich_text, string.format(Language.Guild.MazeHelp, params[2]))
end

function RichTextUtil.ParseGuildMazeChose(rich_text, params, font_size, color)
	color = params[3]
	RichTextUtil.AddText(rich_text, params[2], color)
	-- RichTextUtil.ParseRichText(rich_text, string.format(Language.Guild.MazeChose, params[2], params[3]))
end

function RichTextUtil.ParseMyItem(rich_text, params, font_size)
	local item_id = tonumber(params[2]) or 0
	local item_cfg, item_type = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		print_error("item_cfg is null. id = " .. item_id)
		return
	end

	local color = CHAT_ITEM_COLOR[item_cfg.color] or COLOR.WHITE
	local btn_bg_path = BUTTON_BG_NAME[item_cfg.color] or BUTTON_BG_NAME[GameEnum.ITEM_COLOR_WHITE]

	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
				local item_data = CommonStruct.ItemDataWrapper()
				item_data.item_id = item_id
				item_data.index = equip_index
				-- item_data.index = nil
				if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and nil ~= params[3] then
					local item_param = Split(params[3], ":")
					item_data.stones = {}

					item_data.has_param = 1
					item_data.param.strengthen_level = tonumber(item_param[2]) or 0
					item_data.param.quality = tonumber(item_param[3]) or 0
					item_data.param.shen_level = tonumber(item_param[4]) or 0
					item_data.param.fuling_level = tonumber(item_param[5]) or 0
					item_data.param.has_lucky = tonumber(item_param[6]) or 0
					item_data.param.star_level = tonumber(item_param[7]) or 0
					item_data.param.xianpin_type_list = {}
					for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do  --8 - 13
						local xianpin_type = tonumber(item_param[7 + i] or 0)
						if xianpin_type > 0 then
							table.insert(item_data.param.xianpin_type_list, xianpin_type)
						end
					end
					item_data.slot_list = {}
					for i = 1, COMMON_CONSTS.MAX_ZHUANZHI_STONE_SLOT do -- 14 - 19
						item_data.slot_list[i] = {}
						item_data.slot_list[i].stone_id = tonumber(item_param[13 + i] or 0)
					end

					local attr_seq_list = {}
					for i = 1, COMMON_CONSTS.EQUIP_BAPTIZE_ONE_PART_MAX_BAPTIZE_NUM do --20 - 25
						attr_seq_list[i] =  tonumber(item_param[19 + i]) or 0
					end
					local baptize_list = {}
					for i = 1, COMMON_CONSTS.EQUIP_BAPTIZE_ONE_PART_MAX_BAPTIZE_NUM do --26 - 31
						baptize_list[i] =  tonumber(item_param[25 + i]) or 0
					end
					item_data.baptize_info = {}
					item_data.baptize_info.attr_seq_list = attr_seq_list
					item_data.baptize_info.baptize_list = baptize_list

					local zhuanzhi_suit_type_list = {}
					for i = 0, COMMON_CONSTS.E_INDEX_MAX do -- 32 - 41
						zhuanzhi_suit_type_list[i] = tonumber(item_param[32 + i]) or 0
					end
					local zhuanzhi_order_list = {}
					for i = 0, COMMON_CONSTS.E_INDEX_MAX do -- 42 - 51
						zhuanzhi_order_list[i] = tonumber(item_param[42 + i]) or 0
					end
					item_data.zhuanzhi_suit_infos = {}
					item_data.zhuanzhi_suit_infos.zhuanzhi_suit_type_list = zhuanzhi_suit_type_list
					item_data.zhuanzhi_suit_infos.zhuanzhi_order_list = zhuanzhi_order_list

					local juexing_list = {}
					for i = 1, 3 do -- 52 - 57
						juexing_list[i] = {}
						for k = 1, 2 do
							if k == 1 then
								juexing_list[i].type = tonumber(item_param[50 + (i * k) + i]) or 0
							end
							if k == 2 then
								juexing_list[i].level = tonumber(item_param[50 + (i * k) + 1]) or 0
							end							
						end
					end
					item_data.chat_juexing_list = {}
					item_data.chat_juexing_list.awakening_in_equip = {}
					item_data.chat_juexing_list.awakening_in_equip = juexing_list
				end
				TipsCtrl.Instance:OpenItem(item_data, TipsFormDef.FROM_CHAT_EUQIP)
			end)
		end
	end
	name = "[" .. item_cfg.name .. "]"
	RichTextUtil.CreateUnderLineBtn(rich_text, name, font_size, color, callback, btn_bg_path)
end

function RichTextUtil.ParseGuildWareHouseItem(rich_text, params, font_size)
	local item_id = tonumber(params[2]) or 0
	local old_data_list = Split(params[3], "|")
	local data_list = {}
	for k, v in pairs(old_data_list) do
		if tonumber(v) ~= 0 then
			table.insert(data_list, tonumber(v))
		end
	end

	local item_cfg, item_type = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		print_error("item_cfg is null. id = " .. item_id)
		return
	end

	local color = CHAT_ITEM_COLOR[item_cfg.color] or COLOR.WHITE
	local btn_bg_path = BUTTON_BG_NAME[item_cfg.color] or BUTTON_BG_NAME[GameEnum.ITEM_COLOR_WHITE]

	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				local item_data = {} 
				item_data.item_id = item_id
				if data_list then
					for k, v in pairs(data_list) do
						if tonumber(v) ~= 0 then
							item_data.index = -1
							item_data.param = {}
							item_data.param.xianpin_type_list = data_list
							break
						end
					end
				end
				TipsCtrl.Instance:OpenItem(item_data, TipsFormDef.GUILD_WAREHOUSE_LOG)
			end)
		end
	end
	name = "[" .. item_cfg.name .. "]"
	RichTextUtil.CreateUnderLineBtn(rich_text, name, font_size, color, callback, btn_bg_path)
end

function RichTextUtil.ParseItem(rich_text, params, font_size, color)
	local item_id = tonumber(params[2]) or 0
	local item_cfg, item_type = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		print_warning("item_cfg is null. id = " .. item_id)
		return
	end

	local item_name = item_cfg.name
	color = CHAT_ITEM_COLOR[item_cfg.color] or COLOR.WHITE
	if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and nil ~= params[3] then
		local item_param = Split(params[3], ":")
		if tonumber(item_param[26]) and tonumber(item_param[26]) > 0 then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			local quality_cfg = ForgeData.Instance:GetEternityEquipCfg(equip_index, tonumber(item_param[26]))
			if quality_cfg then
				item_name = quality_cfg.name .. "·" .. item_name
				color = CHAT_ITEM_COLOR[quality_cfg.quality]
			end
		end 
	end
	-- local btn_bg_path = BUTTON_BG_NAME[item_cfg.color] or BUTTON_BG_NAME[GameEnum.ITEM_COLOR_WHITE]
	local btn_bg_path = "lucency_bg"	--策划要求把原来那个底色去掉，换成了一个透明的底

	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				local item_data = CommonStruct.ItemDataWrapper()
				item_data.item_id = item_id
				item_data.index = nil
				if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and nil ~= params[3] then
					local item_param = Split(params[3], ":")
					item_data.stones = {}

					item_data.has_param = 1
					item_data.param.strengthen_level = tonumber(item_param[2]) or 0
					item_data.param.quality = tonumber(item_param[3]) or 0
					item_data.param.shen_level = tonumber(item_param[4]) or 0
					item_data.param.fuling_level = tonumber(item_param[5]) or 0
					item_data.param.has_lucky = tonumber(item_param[6]) or 0
					item_data.param.star_level = tonumber(item_param[7]) or 0
					item_data.param.xianpin_type_list = {}

					for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do --8 - 13
						local xianpin_type = tonumber(item_param[7 + i] or 0)
						if xianpin_type > 0 then
							table.insert(item_data.param.xianpin_type_list, xianpin_type)
						end
					end

					local attr_seq_list = {}
					for i = 1, COMMON_CONSTS.EQUIP_BAPTIZE_ONE_PART_MAX_BAPTIZE_NUM do --14 - 19
						attr_seq_list[i] =  tonumber(item_param[13 + i]) or 0
					end
					local baptize_list = {}
					for i = 1, COMMON_CONSTS.EQUIP_BAPTIZE_ONE_PART_MAX_BAPTIZE_NUM do --20 - 25
						baptize_list[i] =  tonumber(item_param[19 + i]) or 0
					end
					item_data.baptize_info = {}
					item_data.baptize_info.attr_seq_list = attr_seq_list
					item_data.baptize_info.baptize_list = baptize_list

					item_data.param.eternity_level = tonumber(item_param[26]) or 0
				end
				TipsCtrl.Instance:OpenItem(item_data, TipsFormDef.FROM_CHAT_EUQIP)
			end)
		end
	end

	RichTextUtil.CreateUnderLineBtn(rich_text, item_name, font_size, color, callback, btn_bg_path)
end

function RichTextUtil.ParseCamp(rich_text, params, font_size, color)
	if nil ~= params[2] then
		local camp = tonumber(params[2])
		RichTextUtil.AddText(rich_text, Language.Common.CampName[camp], CHAT_CAMP_COLOR[camp])
	end
end

function RichTextUtil.ParseRole(rich_text, params, font_size, color)
	if nil ~= params[3] then
		RichTextUtil.AddText(rich_text, params[3], CHAT_TEXT_COLOR.GREEN)
	end
end

function RichTextUtil.ParseRoleNameAndSex(rich_text, params, font_size, color)
	if nil ~= params[2] and nil ~= params[3] then
		local color = tonumber(params[3]) == 1 and TEXT_COLOR.BLUE_4 or TEXT_COLOR.PINK
		local text = ToColorStr(params[2], color)
		RichTextUtil.AddText(rich_text, text)
	end
end

function RichTextUtil.ParseWordColor(rich_text, params, font_size, color)
	if #params < 3 then return end

	local color_str
	if 8 == string.len(params[2]) then
		color_str = string.sub(params[2], 2, -1)
	else
		color_str = params[2]
	end
	if not string.find(color_str, "#") then
		color_str = "#" .. color_str
	end
	if 7 == string.len(color_str) then
		RichTextUtil.AddText(rich_text, params[3], color_str)
	end
end

function RichTextUtil.ParseChannelMark(rich_text, params, font_size, color)

end

-- team
function RichTextUtil.ParseTeam(rich_text, params, font_size, color)
	if #params < 3 then return end
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				if params[4] then
					local min_level = tonumber(params[4])
					if min_level > 0 then
						local role_level = GameVoManager.Instance:GetMainRoleVo().level
						if min_level > role_level then
							SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.LevelNotEnough)
							return
						end
					end
				end

				local team_type = params[5] or ""
				local team_index = tonumber(params[3]) or 0
				--记录请求加入的类型
				ScoietyData.Instance:SetReqTeamIndex(team_index, team_type)

				ScoietyCtrl.Instance:JoinTeamReq(team_index)
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, params[2], font_size, TEXT_COLOR.WHITE, callback)
end

-- teamfb
function RichTextUtil.ParseTeamFb(rich_text, params, font_size, color)
	if #params < 4 then return end

	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				DailyCtrl.Instance:SendTeamFbJoinRoom(params[3], params[4])
				DailyCtrl.Instance:SendTeamFbReqRoomList(params[3])
				-- FunOpen.Instance:OpenViewByName(GuideModuleName.Daily, TabIndex.daily_duoren)
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, params[2], font_size, TEXT_COLOR.WHITE, callback)
end

-- guildinfo
function RichTextUtil.ParseGuildInfo(rich_text, params, font_size, color)
	if #params < 3 then return end

	local guild_name = params[3]
	color = TEXT_COLOR.GOLD
	RichTextUtil.AddText(rich_text, guild_name, color)
end

-- guildinfo2
function RichTextUtil.ParseGuildInfo2(rich_text, params, font_size, color)
	if params[3] == "" then
		return
	end
	local guild_name = "【" .. params[3] .. "】"
	color = TEXT_COLOR.GOLD
	RichTextUtil.AddText(rich_text, guild_name, color)
end

-- guildjoin
function RichTextUtil.ParseGuildJoin(rich_text, params, font_size, color)
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				--GuildCtrl.Instance:SendApplyForJoinGuildReq(params[2])
				print(params[2])
				for k,v in pairs(params) do
					print(k,v)
				end
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, Language.Chat.JIARU .. (params[3] or ""), font_size, TEXT_COLOR.WHITE, callback)
end

-- money
function RichTextUtil.ParseMoney(rich_text, params, font_size, color)
	if #params < 3 then return end

	local money_type_str = ""

	local money_type = tonumber(params[3]) or 0
	if 0 == money_type then
		money_type_str = Language.Common.Bind .. Language.Common.Coin
	elseif 1 == money_type then
		money_type_str = Language.Common.Bind .. Language.Common.Gold
	elseif 2 == money_type then
		money_type_str = Language.Common.Coin
	elseif 3 == money_type then
		money_type_str = Language.Common.Gold
	end

	RichTextUtil.AddText(rich_text, params[2], TEXT_COLOR.YELLOW)
	RichTextUtil.AddText(rich_text, money_type_str, color)
end

-- chinese_num
function RichTextUtil.ParseChineseNum(rich_text, params, font_size, color)
	local num = tonumber(params[2]) or 0
	local daxie_num = CommonDataManager.GetDaXie(num)
	if nil ~= daxie_num then
		RichTextUtil.AddText(rich_text, daxie_num, TEXT_COLOR.YELLOW)
	end
end

function RichTextUtil.ParseConvertNum(rich_text, params, font_size, color)
	local num = tonumber(params[2]) or 0
	local convert_num = CommonDataManager.ConverNum(num)
	if nil ~= convert_num then
		RichTextUtil.AddText(rich_text, convert_num, TEXT_COLOR.YELLOW)
	end
end

function RichTextUtil.ParseAdvancedReturnTxt(rich_text, params, font_size, color)
	local num = tonumber(params[2]) or 0
	local act_name =  Language.Activity.GradeReturn[num]
	if nil ~= act_name then
		RichTextUtil.AddText(rich_text, act_name, TEXT_COLOR.YELLOW)
	end
end

-- zhuxie_task_item
function RichTextUtil.ParseZhuXieTaskItem(rich_text, params, font_size, color)
	-- local item_type = tonumber(params[2]) or 0
	-- local cfg = ConfigManager.Instance:GetAutoConfig("activityzhuxie_auto").task_list[item_type]
	-- if cfg and nil ~= cfg.item_name then
	-- 	RichTextUtil.AddText(rich_text, cfg.item_name, font_size, COLOR.YELLOW)
	-- end
end

-- wing
function RichTextUtil.ParseWing(rich_text, params, font_size, color)
	local wing_grade = tonumber(params[2]) or 0
	local skill_level = tonumber(params[3]) or 0
	if wing_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img[wing_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.YELLOW)
		end
	else
		-- local client_grade = math.max(wing_grade - 1, 1)
		local grade_cfg = WingData.Instance:GetWingGradeCfg(wing_grade)
		local skill_level = tonumber(params[3]) or 0
		local skill_cfg = WingData.Instance:GetWingSkillCfg()
		local other_cfg = WingData.Instance:GetOhterCfg()
		if not grade_cfg or not skill_cfg or not other_cfg then return end
		local skill_info_cfg = {}
		local skill_idx = other_cfg.medal_skill_index or 0
		for k,v in pairs(skill_cfg) do
			if v.skill_idx == skill_idx and v.skill_level == skill_level then
				skill_info_cfg = v
			end
		end

		local image_list = ConfigManager.Instance:GetAutoConfig("wing_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			local show_color = math.floor(wing_grade / 3 + 1) >= 5 and 5 or math.floor(wing_grade / 3 + 1)
			color = CHAT_SOUL_NAME_COLOR[show_color]
			local str = ""
			if skill_idx == 0 or skill_level == 0 or not skill_info_cfg.skill_name then
				str = string.format(Language.JinJieChuanWen.ChuanWen2, image_list.image_name)
			else
				str = string.format(Language.JinJieChuanWen.ChuanWen1, image_list.image_name, skill_info_cfg.skill_name)
			end
			RichTextUtil.AddText(rich_text, str, color)
		end
	end
	-- local cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[wing_level]
	-- if cfg and nil ~= cfg.big_grade then
	-- 	local daxie_jie = CommonDataManager.GetDaXie(cfg.big_grade)
	-- 	RichTextUtil.AddText(rich_text, daxie_jie, font_size, COLOR.YELLOW)
	-- end
end

-- wing_name
function RichTextUtil.ParseWingName(rich_text, params, font_size, color)
	-- local wing_level = tonumber(params[2]) or 1
	-- local role_prof = RoleData.Instance:GetRoleBaseProf(tonumber(params[3])) or 1
	-- local wing_level_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[wing_level] or ConfigManager.Instance:GetAutoConfig("wing_auto").jinhua[1]
	-- if nil ~= wing_level_cfg then
	-- 	local wing_name = wing_level_cfg["wing_name_" .. role_prof] or ""
	-- 	RichTextUtil.AddText(rich_text, wing_name, font_size, GRADE_COCOR[wing_level_cfg.big_grade])
	-- end
end

-- fazhen_name
function RichTextUtil.ParseFaZhenName(rich_text, params, font_size, color)
	-- local fazhen_grade = tonumber(params[2]) or 0
	-- local fazhen_name = WingData.Instance:GetFaZhenName(fazhen_grade) or ""
	-- local fazhen_color = FAZHEN_COCOR3B[fazhen_grade] or COLOR.WHITE
	-- RichTextUtil.AddText(rich_text, fazhen_name, font_size, fazhen_color)
end

-- defend_area
function RichTextUtil.ParseDefendArea(rich_text, params, font_size, color)
	-- local defend_area_id = tonumber(params[2]) or 0
	-- local deend_area_name = GuildBattleData.Instance:GetDefendAreaName(defend_area_id)
	-- if deend_area_name then
	-- 	RichTextUtil.AddText(rich_text, deend_area_name.area_name, font_size, COLOR.YELLOW)
	-- end
end

-- mount
function RichTextUtil.ParseMount(rich_text, params, font_size, color)
	local mount_grade = tonumber(params[2]) or 0
	local skill_level = tonumber(params[3]) or 0
	if mount_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img[mount_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.YELLOW)
		end
	else
		-- local client_grade = math.max(mount_grade - 1, 1)
		local grade_cfg = MountData.Instance:GetMountGradeCfg(mount_grade)
		local skill_cfg = MountData.Instance:GetMountSkillCfg()
		local other_cfg = MountData.Instance:GetOhterCfg()
		if not grade_cfg or not skill_cfg or not other_cfg then return end
		local skill_info_cfg = {}
		local skill_idx = other_cfg.medal_skill_index or 0
		for k,v in pairs(skill_cfg) do
			if v.skill_idx == skill_idx and v.skill_level == skill_level then
				skill_info_cfg = v
			end
		end

		local image_list = ConfigManager.Instance:GetAutoConfig("mount_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			local show_color = math.floor(mount_grade / 3 + 1) >= 5 and 5 or math.floor(mount_grade / 3 + 1)
			color = CHAT_SOUL_NAME_COLOR[show_color]

			local str = ""
			if skill_idx == 0 or skill_level == 0 or not skill_info_cfg.skill_name then
				str = string.format(Language.JinJieChuanWen.ChuanWen2, image_list.image_name)
			else
				str = string.format(Language.JinJieChuanWen.ChuanWen1, image_list.image_name, skill_info_cfg.skill_name)
			end
			RichTextUtil.AddText(rich_endtext, str, color)
		end
	end
end

function RichTextUtil.ParseFashion(rich_text, params, font_size, color)
	local fashion_grade = tonumber(params[2]) or 0
	local grade_cfg = FashionData.Instance:GetShiZhuangGradeCfg(fashion_grade)
	local name = ""
	if grade_cfg then
		local image_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_img[grade_cfg.image_id]
		local show_color = math.floor(fashion_grade / 3 + 1) >= 5 and 5 or math.floor(fashion_grade / 3 + 1)
		color = CHAT_SOUL_NAME_COLOR[show_color]
		name = image_list.image_name or ""
	end

	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseShenBing(rich_text, params, font_size, color)
	local wuqi_grade = tonumber(params[2]) or 0
	local grade_cfg = FashionData.Instance:GetWuQiGradeCfg(wuqi_grade)
	if not grade_cfg then return end

	local image_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_img[grade_cfg.image_id]
	if nil ~= image_list and nil ~= image_list.image_name then
		local show_color = math.floor(wuqi_grade / 3 + 1) >= 5 and 5 or math.floor(wuqi_grade / 3 + 1)
		color = CHAT_SOUL_NAME_COLOR[show_color]
		RichTextUtil.AddText(rich_text, image_list.image_name, color)
	end
end

-- halo
function RichTextUtil.ParseHalo(rich_text, params, font_size, color)
	local halo_grade = tonumber(params[2]) or 0
	local skill_level = tonumber(params[3]) or 0
	if halo_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("halo_auto").special_img[halo_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.YELLOW)
		end
	else
		-- local client_grade = math.max(halo_grade - 1, 1)
		local grade_cfg = HaloData.Instance:GetHaloGradeCfg(halo_grade)
		local skill_cfg = HaloData.Instance:GetHaloSkillCfg()
		local other_cfg = HaloData.Instance:GetOhterCfg()
		if not grade_cfg or not skill_cfg or not other_cfg then return end

		local skill_info_cfg = {}
		local skill_idx = other_cfg.medal_skill_index or 0
		for k,v in pairs(skill_cfg) do
			if v.skill_idx == skill_idx and v.skill_level == skill_level then
				skill_info_cfg = v
			end
		end

		local image_list = ConfigManager.Instance:GetAutoConfig("halo_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			local show_color = math.floor(halo_grade / 3 + 1) >= 5 and 5 or math.floor(halo_grade / 3 + 1)
			color = CHAT_SOUL_NAME_COLOR[show_color]
			local str = ""
			if skill_idx == 0 or skill_level == 0 or not skill_info_cfg.skill_name then
				str = string.format(Language.JinJieChuanWen.ChuanWen2, image_list.image_name)
			else
				str = string.format(Language.JinJieChuanWen.ChuanWen1, image_list.image_name, skill_info_cfg.skill_name)
			end
			RichTextUtil.AddText(rich_text, str, color)
		end
	end
end

-- shengong
function RichTextUtil.ParseShengong(rich_text, params, font_size, color)
	local shengong_grade = tonumber(params[2]) or 0
	if shengong_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("shengong_auto").special_img[shengong_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.YELLOW)
		end
	else
		-- local client_grade = math.max(shengong_grade - 1, 1)
		local grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_grade)
		if not grade_cfg then return end

		local image_list = ConfigManager.Instance:GetAutoConfig("shengong_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			local show_color = math.floor(shengong_grade / 3 + 1) >= 5 and 5 or math.floor(shengong_grade / 3 + 1)
			color = CHAT_SOUL_NAME_COLOR[show_color]
			RichTextUtil.AddText(rich_text, image_list.image_name, color)
		end
	end
end

-- shenyi
function RichTextUtil.ParseShenyi(rich_text, params, font_size, color)
	local shenyi_grade = tonumber(params[2]) or 0
	if shenyi_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img[shenyi_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.YELLOW)
		end
	else
		-- local client_grade = math.max(shenyi_grade - 1, 1)
		local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_grade)
		if not grade_cfg then return end

		local image_list = ConfigManager.Instance:GetAutoConfig("shenyi_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			local show_color = math.floor(shenyi_grade / 3 + 1) >= 5 and 5 or math.floor(shenyi_grade / 3 + 1)
			color = CHAT_SOUL_NAME_COLOR[show_color]
			RichTextUtil.AddText(rich_text, image_list.image_name, color)
		end
	end
end

-- footprint
function RichTextUtil.ParseFootprint(rich_text, params, font_size, color)
	local footprint_grade = tonumber(params[2]) or 0
	if footprint_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("footprint_auto").special_img[footprint_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.YELLOW)
		end
	else
		-- local client_grade = math.max(footprint_grade - 1, 1)
		local grade_cfg = FootData.Instance:GetFootGradeCfg(footprint_grade)
		if not grade_cfg then return end

		local image_list = ConfigManager.Instance:GetAutoConfig("footprint_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			local show_color = math.floor(footprint_grade / 3 + 1) >= 5 and 5 or math.floor(footprint_grade / 3 + 1)
			color = CHAT_SOUL_NAME_COLOR[show_color]
			RichTextUtil.AddText(rich_text, image_list.image_name, color)
		end
	end
end

-- fightmount
function RichTextUtil.ParseFightMount(rich_text, params, font_size, color)
	local fight_mount_grade = tonumber(params[2]) or 0
	local skill_level = tonumber(params[3]) or 0
	if fight_mount_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_img[fight_mount_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.YELLOW)
		end
	else
		-- local client_grade = math.max(fight_mount_grade - 1, 1)
		local grade_cfg = FightMountData.Instance:GetMountGradeCfg(fight_mount_grade)
		local skill_cfg = FightMountData.Instance:GetMountSkillCfg()
		local other_cfg = FightMountData.Instance:GetOhterCfg()
		if not grade_cfg or not skill_cfg or not other_cfg then return end

		local skill_info_cfg = {}
		local skill_idx = other_cfg.medal_skill_index or 0
		for k,v in pairs(skill_cfg) do
			if v.skill_idx == skill_idx and v.skill_level == skill_level then
				skill_info_cfg = v
			end
		end

		local image_list = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			local show_color = math.floor(fight_mount_grade / 3 + 1) >= 5 and 5 or math.floor(fight_mount_grade / 3 + 1)
			color = CHAT_SOUL_NAME_COLOR[show_color]
			local str = ""
			if skill_idx == 0 or skill_level == 0 or not skill_info_cfg.skill_name then
				str = string.format(Language.JinJieChuanWen.ChuanWen2, image_list.image_name)
			else
				str = string.format(Language.JinJieChuanWen.ChuanWen1, image_list.image_name, skill_info_cfg.skill_name)
			end
			RichTextUtil.AddText(rich_text, str, color)
		end
	end
end

function RichTextUtil.ParseFaBao(rich_text, params, font_size, color)
	local fabao_grade = tonumber(params[2]) or 0
	local skill_level = tonumber(params[3]) or 0
	if fabao_grade > 1000 then
		local image_list = ConfigManager.Instance:GetAutoConfig("fabao_auto").special_img[fabao_grade - 1000]
		if nil ~= image_list and nil ~= image_list.name then
			RichTextUtil.AddText(rich_text, image_list.name, TEXT_COLOR.YELLOW)
		end
	else
		-- local client_grade = math.max(fight_mount_grade - 1, 1)
		local grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_grade)
		local skill_cfg = FaBaoData.Instance:GetFaBaoSkillCfg()
		local other_cfg = FaBaoData.Instance:GetOhterCfg()
		if not grade_cfg or not skill_cfg or not other_cfg then return end

		local skill_info_cfg = {}
		local skill_idx = other_cfg.medal_skill_index or 0
		for k,v in pairs(skill_cfg) do
			if v.skill_idx == skill_idx and v.skill_level == skill_level then
				skill_info_cfg = v
			end
		end


		local image_list = ConfigManager.Instance:GetAutoConfig("fabao_auto").image_list[grade_cfg.image_id]
		if nil ~= image_list and nil ~= image_list.show_grade and nil ~= image_list.image_name then
			local show_color = math.floor(fabao_grade / 3 + 1) >= 5 and 5 or math.floor(fabao_grade / 3 + 1)
			color = CHAT_SOUL_NAME_COLOR[show_color]

			local str = ""
			if skill_idx == 0 or skill_level == 0 or not skill_info_cfg.skill_name then
				str = string.format(Language.JinJieChuanWen.ChuanWen2, image_list.image_name)
			else
				str = string.format(Language.JinJieChuanWen.ChuanWen1, image_list.image_name, skill_info_cfg.skill_name)
			end
			RichTextUtil.AddText(rich_text, str, color)
		end
	end
end

-- mojie
function RichTextUtil.ParseMojie(rich_text, params, font_size, color)
	local mojie_type = tonumber(params[2]) or 0
	local mojie_level = tonumber(params[3]) or 0
	RichTextUtil.AddText(rich_text, MojieData.Instance:GetMojieName(mojie_type, mojie_level), TEXT_COLOR.YELLOW)
end

-- role_level
function RichTextUtil.ParseRoleLevel(rich_text, params, font_size, color)
	local role_level = tonumber(params[2]) or 0
	RichTextUtil.AddText(rich_text, PlayerData.GetLevelString(role_level), TEXT_COLOR.YELLOW)
end

-- qibing
function RichTextUtil.ParseQiBing(rich_text, params, font_size, color)
	-- local qibing_level = tonumber(params[2]) or 1
	-- local qibing_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").qibing[qibing_level]
	-- if nil ~= qibing_cfg and nil ~= qibing_cfg.name then
	-- 	RichTextUtil.AddText(rich_text, qibing_cfg.name, font_size, GRADE_COCOR3B[qibing_level] or COLOR.WHITE)
	-- end
end

--to_decimal
function RichTextUtil.ParseToDecimal(rich_text, params, font_size, color)
	local rate = tonumber(params[2]) or 0
	RichTextUtil.AddText(rich_text, rate / 100, TEXT_COLOR.YELLOW)
end

--monster
function RichTextUtil.ParseMonster(rich_text, params, font_size, color)
	local monster_config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[tonumber(params[2]) or 0]
	if nil ~= monster_config and nil ~= monster_config.name then
		RichTextUtil.AddText(rich_text, monster_config.name, TEXT_COLOR.YELLOW)
	end
end

--title
function RichTextUtil.ParseTitle(rich_text, params, font_size, color)
	local title_config = TitleData.Instance:GetTitleCfg(tonumber(params[2]) or 0)
	if nil ~= title_config and nil ~= title_config.name then
		local text_color = params[3] and tostring("#" .. params[3]) or nil
		RichTextUtil.AddText(rich_text, title_config.name, text_color)
	end
end

--forge_suit_ss
function RichTextUtil.ParseForgeSuitSS(rich_text, params, font_size, color)
	local suit_name = ForgeData.Instance:GetSuitName(tonumber(params[2]), 1)
	if nil ~= suit_name then
		RichTextUtil.AddText(rich_text, suit_name, TEXT_COLOR.YELLOW, text_attr)
	end
end

--forge_suit_cs
function RichTextUtil.ParseForgeSuitCS(rich_text, params, font_size, color)
	local suit_name = ForgeData.Instance:GetSuitName(tonumber(params[2]),-1)
	if nil ~= suit_name then
		RichTextUtil.AddText(rich_text, suit_name, TEXT_COLOR.YELLOW, text_attr)
	end
end

function RichTextUtil.ParseForgeJueXing(rich_text, params, font_size, color)
	local cfg = ForgeData.Instance:GetJueXingAttrCfg(tonumber(params[2]), tonumber(params[3]))
	if nil ~= cfg then
		local suit_name = string.format("<color=#FF9E0EFF>%s</color>,%s",cfg.skill_name, cfg.skill_dec)
		RichTextUtil.AddText(rich_text, suit_name)
	end
end

--jinjie
function RichTextUtil.ParseJinJie(rich_text, params, font_size, color)
	local system_type = tonumber(params[2])
	local system_name = system_type and Language.JinJieReward.SystemName[system_type]
	if nil ~= system_name then
		RichTextUtil.AddText(rich_text, system_name, TEXT_COLOR.YELLOW)
	end
end

--territory
function RichTextUtil.ParseTerritory(rich_text, params, font_size, color)
	local cfg = GuildData.Instance:GetTerritoryConfig(tonumber(params[2]))
	local territory_name = ""
	if cfg then
		territory_name = cfg.territory_name
	end
	RichTextUtil.AddText(rich_text, territory_name, TEXT_COLOR.YELLOW, text_attr)
end

--famousxiannv
function RichTextUtil.FamousXiannv(rich_text, params)
	local cfg = GoddessData.Instance:GetXianNvCfg(tonumber(params[2]))
	local xiannv_name = ""
	if cfg then
		xiannv_name = cfg.name
	end
	RichTextUtil.AddText(rich_text, xiannv_name, CHAT_TEXT_COLOR.GREEN)
end

--guildpost
function RichTextUtil.ParseGuildPost(rich_text, params)
	local post_name = GUILD_POST_NAME[tonumber(params[2])] or ""
	RichTextUtil.AddText(rich_text, post_name)
end

--shenzhou_weapon
function RichTextUtil.ParseHunQiName(rich_text, params)
	local name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(tonumber(params[2]))
	local color = CHAT_ITEM_COLOR[color_num]
	RichTextUtil.AddText(rich_text, name, color)
end

--shenzhou_skill
function RichTextUtil.ParseHunQiSkill(rich_text, params)
	local skill_name = HunQiData.Instance:GetHunQiSkillByIndex(tonumber(params[2]))
	local color = TEXT_COLOR.ORANGE
	RichTextUtil.AddText(rich_text, skill_name, color)
end

function RichTextUtil.ParseHelpBaoXiang(rich_text, params, font_size, color)
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				local help_uid = tonumber(params[2])
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				if help_uid == main_role_vo.role_id then
					SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotHelpSelf)
					return
				end
				HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_HELP_OTHER_BOX, help_uid)
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, Language.HunQi.HelpBtnText, font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseShenGe(rich_text, params, font_size, color)
	local seq = tonumber(params[2])
	local cfg = ShenGeData.Instance:GetChoujiangCfg(seq)
	local name = ""
	if cfg then
		local item_id = ShenGeData.Instance:GetShenGeItemId(cfg[1].types, cfg[1].quality)
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		color = CHAT_ITEM_COLOR[item_cfg.color] or COLOR.WHITE
		name = item_cfg.name
	end

	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseZhangKongUp(rich_text, params, color)
	local grid = tonumber(params[2])
	local shenli_name = ShenGeData.Instance:GetShenliName(grid)
	color = COLOR.GREEN

	RichTextUtil.AddText(rich_text, shenli_name, color)
end

--tianshenhuti_equip
function RichTextUtil.ParseTianshenhutiEquip(rich_text, params, font_size, color)
	local equip_name, color = TianshenhutiData.Instance:GetEquipName(tonumber(params[2]))
	if nil ~= equip_name then
		RichTextUtil.AddText(rich_text, equip_name, ITEM_COLOR[color], text_attr)
	end
end

function RichTextUtil.ParseDouqiGrade(rich_text, params, font_size, color)
	local grade = tonumber(params[2])
	local str = ""
	local info = DouQiData.Instance:GetDouqiGradeCfg(grade)
	if info then
		str = info.grade_name
	end
	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.ParseDouQiEquip(rich_text, params)
	local grade = tonumber(params[2])
	local str = ""
	local cfg = ItemData.Instance:GetItemConfig(grade)
	if cfg then
		str = cfg.name
	end
	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.ParseShengWu(rich_text, params, color)
	local shengwu_id = tonumber(params[2])
	local shengwu_id_name = GoddessData.Instance:GetXianNvShengWuCfgName(shengwu_id)
	color = COLOR.YELLOW

	RichTextUtil.AddText(rich_text, shengwu_id_name, color)
end

function RichTextUtil.ParseShengWuSkill(rich_text, params, color)
	local shengwu_id = tonumber(params[2])
	local shengwu_id_name = GoddessData.Instance:GetXianNvShengWuSkillName(shengwu_id)
	color = COLOR.YELLOW

	RichTextUtil.AddText(rich_text, shengwu_id_name, color)
end

--答题
function RichTextUtil.ParseQuestionAnswer(rich_text)

end

function RichTextUtil.ParseIdentifyLevel(rich_text, params)
	local big_level = tonumber(params[2])
	local small_level = tonumber(params[3])

	local attr_info = HunQiData.Instance:GetidentifyLevelInfo(big_level, small_level)
	if nil == attr_info then
		return
	end
	attr_info = attr_info[1]
	local name = attr_info.name
	local color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseElementName(rich_text, params)
	local element_type = tonumber(params[2])
	local name = HunQiData.Instance:GetElementNameByType(element_type)
	local color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseAdvancePreview(rich_text, params, font_size, color)
	local role_id = tonumber(params[2])
	local name = params[3]
	color = params[4] or TEXT_COLOR.WHITE
	local btn_color = BUTTON_BG_NAME[tonumber(params[5])] or BUTTON_BG_NAME[GameEnum.ITEM_COLOR_WHITE]
	local tab_index = tonumber(params[6])
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				local info_call_back = function()
					CheckCtrl.Instance:SetCurIndex(tab_index, true)
					ViewManager.Instance:Open(ViewName.CheckEquip)
				end
				CheckData.Instance:SetCurrentUserId(role_id)
				CheckCtrl.Instance:SetInfoCallBack(role_id, info_call_back)
				CheckCtrl.Instance:SendQueryRoleInfoReq(role_id)
			end)
		end
	end

	RichTextUtil.CreateUnderLineBtn(rich_text, name, font_size, color, callback, btn_color)
end

function RichTextUtil.ParseShengeCombine(rich_text, params)
	local color = TEXT_COLOR.YELLOW
	local index = tonumber(params[2])
	local cfg = ShenGeData.Instance:GetShenGeGroupCfg(index + 1) or {}
	local name = cfg.name or ""

	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseXingzuoSuit(rich_text, params)
	local name = ShengXiaoData.Instance:GetSuitCfgByLevel(tonumber(params[2])).name
	local color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseXingzuoEquip(rich_text, params)
	local name = ShengXiaoData.Instance:GetZodiacInfoByIndex(tonumber(params[2]) + 1, 1).name
	local color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseDiscountBuy(rich_text, params)
	local name = DisCountData.Instance:GetPhaseNameByPhase(tonumber(params[2]))
	local color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, name, color)
	DisCountData.Instance:SetPhaseIndex(tonumber(params[2]))
end

function RichTextUtil.ParseTimeLimitGift(rich_text, params)
	local color = TEXT_COLOR.YELLOW
	local index = tonumber(params[2])
	local cfg = KaifuActivityData.Instance:GetRealGiftShopCfg()[index+1] or {}
	local name = cfg.name or ""

	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseGiftTimeLimit(rich_text, params)
	local color = TEXT_COLOR.YELLOW
	local index = tonumber(params[2])
	local cfg = GiftLimitBuyData.Instance:GetRealGiftShopCfg()[index+1] or {}
	local name = cfg.name or ""

	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseLinkToGuild(rich_text, params)
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				ViewManager.Instance:Open(ViewName.GuildRedPacket)
			end)
		end
	end
	local color = CHAT_TEXT_COLOR.GREEN
	RichTextUtil.CreateUnderLineBtn(rich_text, params[2], font_size, color, callback)
end

function RichTextUtil.ParseWanglingTask(rich_text, params)
	local name = TombExploreData.Instance:GetTaskCfgByID(tonumber(params[2])).task_name
	local color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseQunxianSide(rich_text, params)
	local name = ElementBattleData.Instance:GetCampName(tonumber(params[2])).side_name
	local color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ParseTianjiangcaibaoTask(rich_text, params)
	local name = SkyMoneyData.Instance:GetSkyMoneyTaskCfgById(tonumber(params[2])).name
	local color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, name, color)
end

--eq_shenzhu
function RichTextUtil.ParseEquipShenZhu(rich_text, params, font_size, color)
	-- local shenzhu = tonumber(params[2]) or 0
	-- local prefixion = shenzhu > 0 and EquipmentData.Instance:GetShengzhuPrefixion(shenzhu) .. "·" or ""
	-- RichTextUtil.AddText(rich_text, prefixion, font_size, COLOR.YELLOW)
end

--eq_quality
function RichTextUtil.ParseEquipQuality(rich_text, params, font_size, color)
	-- local quality = tonumber(params[2]) or 0
	-- local color_name = Language.Common.ColorName[quality + 1] or ""
	-- color = EQUIP_COLOR[quality] or COLOR.WHITE
	-- RichTextUtil.AddText(rich_text, color_name, font_size, color)
end

--stone
function RichTextUtil.ParseStone(rich_text, params, font_size, color)
	-- local stone_type = tonumber(params[2]) or 0
	-- local stone_name = BaoshiData.Instance:GetStoneNameByType(stone_type) or ""
	-- local str = stone_name .. Language.Equip.BaoShi
	-- RichTextUtil.AddText(rich_text, str, font_size, COLOR.YELLOW)
end

--csa_sub_type
function RichTextUtil.ParseCsaSubType(rich_text, params, font_size, color)
	local sub_type = tonumber(params[2]) or 0
	local name = HefuActivityData.Instance:GetCombineActTimeConfig(sub_type).name
	RichTextUtil.AddText(rich_text, name, color)
end

--openLink
function RichTextUtil.ParseOpenLink(rich_text, params, font_size, color)
	local link_type = tonumber(params[2]) or 0
	local link_cfg = RichTextUtil.GetOpenLinkCfg(link_type)
	local link_name = nil ~= link_cfg and link_cfg.name or "unknown link type:" .. link_type

	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				RichTextUtil.DoByLinkType(link_type, params[3], params[4], params[5])
			end)
		end
	end
	if link_type == CHAT_LINK_TYPE.GUILD_APPLY and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE) then
		GuildCtrl.Instance:SendAllGuildInfoReq()
	end
	RichTextUtil.CreateBtn(rich_text, link_name, font_size, COLOR.WHITE, callback)
end

--qingyuan_card
function RichTextUtil.ParseQingYuanCard(rich_text, params, font_size, color)
	-- local card_info = MarryData.Instance:GetCardInfoByIdAndLevel(tonumber(params[2]),tonumber(params[3]))
	-- if nil ~= card_info and nil ~= card_info.card_name then
	-- 	RichTextUtil.AddText(rich_text, card_info.card_name, font_size, COLOR.YELLOW)
	-- end
end

--red_paper
function RichTextUtil.ParseRedPaper(rich_text, params, font_size, color)
	local red_type = tonumber(params[2]) or 0
	local total_gold_num = tonumber(params[3]) or 0
	local can_fetch_times = tonumber(params[4]) or 0
	local red_type_text = Language.RedEnvelopes.HongbaoType[red_type] or ""
	local text_content = can_fetch_times .. Language.Common.UnitName[1] .. red_type_text .. Language.RedEnvelopes.CWTxt1 .. total_gold_num .. Language.Common.Gold
	if red_type == RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL then
		text_content = red_type_text .. Language.RedEnvelopes.CWTxt2
	end
	RichTextUtil.AddText(rich_text, text_content, TEXT_COLOR.YELLOW)
end

--activityPos
function RichTextUtil.ParseActivityPos(rich_text, params, font_size, color)
	if #params < 5 then return end
	local pos_type = tonumber(params[5]) or 0
	local desc = Language.Common.ActivityPosStr[pos_type] or ""
	local point_text = desc.. "(" .. params[3] .. "," .. params[4] .. ")"
	if pos_type == 2 or pos_type == 4 then
		point_text = desc
	end
	local function callback(btn)
		if nil ~= btn then
			local is_user = MarriageData.Instance:IsMarryUser()
			if is_user then return end
			btn:AddClickListener(function()
				RichTextUtil.FlyToPos(tonumber(params[2]) or 0, tonumber(params[3]) or 0, tonumber(params[4]) or 0)
			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, point_text, font_size, color, callback)
end

--activity
function RichTextUtil.ParseActivity(rich_text, params, font_size, color)
	local act_type = tonumber(params[2])
	if nil == act_type then return end
	local act_name = ""
	local act_name = ActivityData.Instance:GetActivityNameByType(tonumber(params[2]))
	act_name = act_name .. Language.OpenServer.HuoDongText
	color = TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, act_name, color)
end

--prof
function RichTextUtil.ParseProf(rich_text, params, font_size, color)
	local prof = tonumber(params[2]) and tonumber(params[2]) or 0
	local base_prof, grade = prof % 10, math.floor(prof / 10)
	local prof_name = ZhuanZhiData.Instance:GetProfNameCfg(base_prof, grade) or ""
	RichTextUtil.AddText(rich_text, prof_name, TEXT_COLOR.YELLOW)
end

--mountfly
function RichTextUtil.ParseMountFly(rich_text, params, font_size, color)
	-- local fly_level = tonumber(params[2]) or 0
	-- local name = MountData.Instance:GetFlyNameByFlyLevel(fly_level)
	-- RichTextUtil.AddText(rich_text, name, font_size, COLOR.YELLOW)
end

-- 精灵命魂
function RichTextUtil.ParseHunShou(rich_text, params, font_size, color)
	if #params < 2 then return end
	local cfg = SpiritData.Instance:GetSpiritSoulCfg(tonumber(params[2]))
	if nil == cfg then
		return
	end
	RichTextUtil.AddText(rich_text, cfg.name, TEXT_COLOR.YELLOW)
end

--chengjiu_title
function RichTextUtil.ParseChengJiuTitle(rich_text, params, font_size, color)
	if #params < 2 then return end
	local cfg = AchieveData.Instance:GetAchieveTitleDataByLevel(tonumber(params[2]))
	if nil == cfg then
		return
	end
	RichTextUtil.AddText(rich_text, cfg.name, AchieveData.Instance:GetTitleColor(cfg.level) or TEXT_COLOR.YELLOW)
end

--xianjie
function RichTextUtil.ParseXianJie(rich_text, params, font_size, color)
	-- if #params < 3 then return end
	-- local cfg = ShengWangData.GetXianJieCfgByLv(tonumber(params[3]))
	-- if nil == cfg then
	-- 	return
	-- end
	-- RichTextUtil.AddText(rich_text, cfg.name, font_size, Str2C3b(params[2]))
end

--card_color
function RichTextUtil.ParseCardColor(rich_text, params, font_size, color)
	-- local color = tonumber(params[2]) or 1
	-- local color_name = Language.Card.ColorName[color]
	-- if nil ~= color_name then
	-- 	RichTextUtil.AddText(rich_text, color_name, font_size, CHAT_ITEM_COLOR[color])
	-- end
end

--card 神域
function RichTextUtil.ParseCard(rich_text, params, font_size, color)
	local card_id = tonumber(params[2]) or 1
	-- local prof = tonumber(params[3]) or 1
	-- local card_name = SwordArtOnlineData.Instance:GetCardZuInfoById(card_id)
	-- if nil ~= card_name then
	-- 	RichTextUtil.AddText(rich_text, card_name, font_size, TEXT_COLOR.YELLOW)
	-- end
end

function RichTextUtil.ParseMine(rich_text, params, font_size, color)
	local mine_index = tonumber(params[2]) or 0
	local name = GoldHuntData.Instance:GetMineralInfo(mine_index)
	if nil ~= name then
		RichTextUtil.AddText(rich_text, name, font_size, COLOR.YELLOW,text_attr)
	end
end

function RichTextUtil.ParseFanFanZhuan(rich_text, params, font_size, color)
	-- local fanfan_index = tonumber(params[1]) or 0
	-- local cfg = FanfanzhuanData.Instance:GetWrodInfo(fanfan_index)
	-- if nil ~= cfg and nil ~= cfg.word then
	-- 	RichTextUtil.AddText(rich_text, cfg.word, font_size, COLOR.YELLOW,text_attr)
	-- end
end

function RichTextUtil.ParseTuanZhan(rich_text, params, font_size, color)
	-- local side = tonumber(params[2])
	-- local side_name = Language.KuafuTeambattle["side" .. side] or ""
	-- local color = 0 == side and COLOR.RED or COLOR.PURPLE
	-- RichTextUtil.AddText(rich_text, side_name, font_size, color)
end

function RichTextUtil.ParseMulitMount(rich_text, params, font_size, color)
	local seq = tonumber(params[2])
	local mount_name = MultiMountData.Instance:GetMountNameByIndex(seq) or ""
	RichTextUtil.AddText(rich_text, mount_name, CHAT_SOUL_NAME_COLOR[seq] or COLOR.YELLOW)
end

function RichTextUtil.ParseBubble(rich_text, params, font_size, color)
	local seq = tonumber(params[2])
	local cfg = CoolChatData.Instance:GetBubbleCfg()
	local bubble_name = ""
	for k, v in ipairs(cfg) do
		if v.seq == seq + 1 then
			bubble_name = v.name
			break
		end
	end
	RichTextUtil.AddText(rich_text, bubble_name, COLOR.YELLOW)
end

function RichTextUtil.ParseCardzu(rich_text, params, font_size, color)
	local card_id = tonumber(params[2]) or 0
	-- local card_name = SwordArtOnlineData.Instance:GetCardZuInfoById(card_id).cardzu_name
	-- if nil ~= card_name then
	-- 	RichTextUtil.AddText(rich_text, card_name, COLOR.YELLOW)
	-- end
end

-- gengu_title
function RichTextUtil.ParseGengu(rich_text, params, font_size, color)
	-- local gengu_level = tonumber(params[2]) or 0
	-- local cfg = XiuLianData.Instance:GetGenGuTitle(gengu_level)
	-- if nil ~= cfg and nil ~= cfg.title_name then
	-- 	RichTextUtil.AddText(rich_text, cfg.title_name, font_size, COLOR.YELLOW)
	-- end
end

-- jingmai_title
function RichTextUtil.ParseJingmai(rich_text, params, font_size, color)
	-- local jingmai_level = tonumber(params[2]) or 0
	-- local cfg = XiuLianData.Instance:GetMentalityTitle(jingmai_level)
	-- if nil ~= cfg and nil ~= cfg.gradename then
	-- 	RichTextUtil.AddText(rich_text, cfg.gradename, font_size, COLOR.YELLOW)
	-- end
end

-- mentality
function RichTextUtil.ParseMentality(rich_text, params, font_size, color)
	-- local gengu_type = (tonumber(params[2]) or 0) + 1
	-- local gengu_name = Language.Meridian.NameList[gengu_type]
	-- if nil ~= gengu_name then
	-- 	RichTextUtil.AddText(rich_text, gengu_name, font_size, COLOR.YELLOW)
	-- end
end

-- shenzhuang
function RichTextUtil.ParseShenzhuang(rich_text, params, font_size, color)
	-- local index = tonumber(params[2]) or 0
	-- local level = tonumber(params[3]) or 1
	-- level = math.max(level, 1)
	-- local shenzhuang_name = EquipmentShenData.Instance:GetShenzhuangName(index, level)
	-- if nil ~= shenzhuang_name then
	-- 	RichTextUtil.AddText(rich_text, shenzhuang_name, font_size, COLOR.YELLOW)
	-- end
end

-- jinglingyun
function RichTextUtil.ParseSpriteCloud(rich_text, params, font_size, color)
	-- local image_id = tonumber(params[2]) or 0
	-- local cloud_name = JingLingData.GetFlyNameByImgid(image_id)
	-- if nil ~= cloud_name then
	-- 	RichTextUtil.AddText(rich_text, cloud_name, font_size, COLOR.YELLOW)
	-- end
end

-- jinglingslot
function RichTextUtil.ParseSpriteSlot(rich_text, params, font_size, color)
	-- local index = tonumber(params[2]) or 0
	-- local strength_level = tonumber(params[3]) or 0
	-- local slot_name = JingLingData.GetJinglingEquipName(index, strength_level)
	-- if nil ~= slot_name then
	-- 	RichTextUtil.AddText(rich_text, slot_name, font_size, COLOR.YELLOW)
	-- end
end

-- taozhuang
function RichTextUtil.ParseTaozhuang(rich_text, params, font_size, color)
	local tz_type = tonumber(params[2]) or 0
	local param = tonumber(params[3]) or 0
	local tz_name = ""
	if tz_type == TAOZHUANG_TYPE.BAOSHI_TAOZHUANG then
		tz_name = ForgeData.Instance:GetTotalGemCfgByLevel(param)
	elseif tz_type == TAOZHUANG_TYPE.STREGNGTHEN_TAOZHUANG then
		tz_name = ForgeData.Instance:GetTotalStrengthNameByLevel(param)
	elseif tz_type == TAOZHUANG_TYPE.EQUIP_UP_STAR_TAPZHUANG then
		tz_name = ForgeData.Instance:GetTotleStarBySeq(param)
	end
	if nil ~= tz_name then
		RichTextUtil.AddText(rich_text, tz_name, COLOR.YELLOW)
	end
end

-- pet
function RichTextUtil.ParsePet(rich_text, params, font_size, color)
	-- local tz_index = tonumber(params[2]) or 0
	-- local cfg = EquipmentShenData.Instance:GetTaoZhuangCfg(tz_index)
	-- if nil ~= cfg and nil ~= cfg.zuhe_name then
	-- 	RichTextUtil.AddText(rich_text, cfg.zuhe_name, font_size, COLOR.YELLOW)
	-- end
end

-- 神域
function RichTextUtil.ParseSwordArtOnline(rich_text, params, font_size, color)
	-- local tz_index = tonumber(params[2]) or 0
	-- local cfg = EquipmentShenData.Instance:GetTaoZhuangCfg(tz_index)
	-- if nil ~= cfg and nil ~= cfg.zuhe_name then
	-- 	RichTextUtil.AddText(rich_text, cfg.zuhe_name, font_size, COLOR.YELLOW)
	-- end
end

-- 魔卡
function RichTextUtil.ParseMagicCard(rich_text, params, font_size, color)
	-- local tz_index = tonumber(params[2]) or 0
	-- local cfg = MagicCardData.Instance:GetInfoById(tz_index)
	-- local cur_color = MagicCardData.Instance:GetRgbByColor(cfg.color)
	-- if nil ~= cfg and nil ~= cfg.card_name then
	-- 	local function callback(btn)
	-- 		if nil ~= btn then
	-- 			btn:AddClickListener(function()
	-- 				local item_data = {}
	-- 				item_data = {item_id = cfg.item_id, num = 1, is_bind = 0, show_red_point = false, card_id = cfg.card_id}
	-- 				TipsCtrl.Instance:OpenItem(item_data)
	-- 			end)
	-- 		end
	-- 	end
	-- 	RichTextUtil.CreateBtn(rich_text, cfg.card_name, font_size, cur_color, callback)
	-- end
end

-- 鱼塘
function RichTextUtil.ParseFishPond(rich_text, params, font_size, color)
	-- local tz_index = tonumber(params[2]) or 0
	-- local cfg = FishpondData.Instance:GetFishCfgByType(tz_index)
	-- local name = ""
	-- if nil ~= cfg and nil ~= cfg.fish_id then
	-- 	name = ItemData.Instance:GetItemConfig(cfg.fish_id).name
	-- end
	-- if "" ~= name then
	-- 	RichTextUtil.AddText(rich_text, name, font_size, COLOR.YELLOW)
	-- end
end

function RichTextUtil.ParseFindCrossTeammates(rich_text, params, font_size, color)
	-- print_warning(rich_text, params, font_size, color)
	-- for k,v in pairs(params) do
	-- 	print_warning(k,v)
	-- end
end

function RichTextUtil.ParseGuildBack(rich_text, params, font_size, color)
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
			end)
		end
	end

	RichTextUtil.CreateBtn(rich_text, Language.Guild.ReturnStation, font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseImgFuLingType(rich_text, params, font_size, color)
	local fuling_type = tonumber(params[2])
	RichTextUtil.AddText(rich_text, Language.Advance.FuLingTabName[fuling_type] or "", CHAT_TEXT_COLOR.GREEN)
end

function RichTextUtil.ParseImgFuLingSkillIndex(rich_text, params, font_size, color)
	local skill_index = tonumber(params[2])
	local skill_name = ImageFuLingData.Instance:GetImgFuLingSkillName(skill_index, 1)
	RichTextUtil.AddText(rich_text, skill_name, CHAT_TEXT_COLOR.GREEN)
end

function RichTextUtil.ParseRuneZhuLing(rich_text, params, font_size, color)
	local cfg = RuneData.Instance:GetRuneZhulingGradeCfg(tonumber(params[2]), tonumber(params[3]))
	if nil ~= cfg then
		RichTextUtil.AddText(rich_text, CommonDataManager.GetDaXie(cfg.client_grade), CHAT_TEXT_COLOR.GREEN)
	end
end

function RichTextUtil.ParseRuneZhaoYin(rich_text, params, font_size, color)
	local virtual_item_id = ShenYinData.Instance:GetHunShouVItemIdByIndex(tonumber(params[2]))
	local shenyin_cfg = ShenYinData.Instance:GetItemCFGByVItemID(virtual_item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(shenyin_cfg.item_id)
	if nil ~= item_cfg then
		RichTextUtil.AddText(rich_text, item_cfg.name, CHAT_ITEM_COLOR[item_cfg.color])
	end
end

function RichTextUtil.FlyToPos(scene_id, x, y, scene_key)
	local now_scene_id = Scene.Instance:GetSceneId()
	if now_scene_id == scene_id then
		local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
		if GuajiCtrl.CheckRange(x, y, 1) then
			local now_scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
			if scene_key and scene_key == now_scene_key then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.IsArrive)
				return
			end
		end
	else
		--当前场景无法传送
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type ~= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
			return
		end

		--目标场景无法传送
		local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
		if scene_config then
			local scene_type = scene_config.scene_type
			if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene(scene_id) then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotEnterScene)
				return
			end
		end
	end
	local callback = function()
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0, false, scene_key)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	
end

--点击链接类型
function RichTextUtil.DoByLinkType(link_type, param1, param2, param3)
	local link_cfg = RichTextUtil.GetOpenLinkCfg(link_type)
	if nil == link_cfg then
		print("请先配置", link_type)
		return
	end
	if link_type == CHAT_LINK_TYPE.GUILD_APPLY then								-- 仙盟申请
		if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.HasInGuild)
		else
			-- ViewManager.Instance:Open(link_cfg.view_name)
			GuildCtrl.Instance:SendApplyForJoinGuildReq(tonumber(param1))
			--FunOpen.Instance:OpenViewByName(link_cfg.view_name, link_cfg.index)
		end

	elseif link_type == CHAT_LINK_TYPE.GOLDEN_PIG_ACTIVITY then
		local golden_cfg = KaifuActivityData.Instance:GetGoldenCallPositionCfg(tonumber(param1))		--金猪召唤(龙神夺宝)
		MapLocalView:FlyToPos(golden_cfg.scene_id, golden_cfg.pos_x, golden_cfg.pos_y)

	elseif link_type == CHAT_LINK_TYPE.HUSONG then								-- 我要护送
		YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()

	elseif link_type == CHAT_LINK_TYPE.TOMB_BOSS then							-- 击杀皇陵BOSS
		TombExploreCtrl.Instance:GoToBoss()
	elseif link_type == CHAT_LINK_TYPE.CAN_JIA_HUN_YAN then						-- 婚宴副本
		MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_JOIN_HUNYAN, tonumber(param1) or 0)

	elseif link_type == CHAT_LINK_TYPE.WO_QIUHUN then							-- 我要求婚
		local user_info = {user_id = tonumber(param1) or 0, gamename = param2, sex = tonumber(param3) or 0}
		local can_mry, str = MarriageData.Instance:CheckCanMarry(user_info, true)
		if nil ~= can_mry then
			MarryCtrl.Instance:OpenProposeView(user_info.user_id, str)
		else
			SysMsgCtrl.Instance:ErrorRemind(str)
		end

	elseif link_type == CHAT_LINK_TYPE.WO_CHONGZHI then							-- 我要充值
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif link_type == CHAT_LINK_TYPE.DAY_DANBI then
			ViewManager.Instance:Open(ViewName.KaifuActivityView, 61)
	elseif link_type == CHAT_LINK_TYPE.WO_JINGLING_HALO then   -- 情缘副本 同意组队
		-- if nil ~= Scene.Instance:GetMainRole() and nil ~= Scene.Instance:GetMainRole().vo.level and Scene.Instance:GetMainRole().vo.level >= 650 then
		-- FunOpen.Instance:OpenViewByName(link_cfg.view_name, link_cfg.tab_index)
		ViewManager.Instance:Open(link_cfg.view_name, link_cfg.tab_index)
		-- else
		-- SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.JingLingHaloLevel)
		-- end
	elseif link_type == CHAT_LINK_TYPE.CROSS_FB_TEAMMATE then   -- 跨服组队招募队员

	elseif link_type == CHAT_LINK_TYPE.ZHENBAOGE then   -- 珍宝阁
		local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		if role_level >= act_cfg.min_level then
			ViewManager.Instance:Open(ViewName.TreasureLoftView)
		else
			local level_str = PlayerData.GetLevelString(act_cfg.min_level)
			local tip_str = string.format(Language.Common.FunOpenTaskLevelLimit, level_str)
			SysMsgCtrl.Instance:ErrorRemind(tip_str)
		end
	elseif link_type == CHAT_LINK_TYPE.VIP then							-- 成为vip
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif link_type == CHAT_LINK_TYPE.DA_FU_HAO then				--大富豪
		-- if DaFuHaoData.Instance:GetLimitLevel() > GameVoManager.Instance:GetMainRoleVo().level then
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.CrossTeam.Levellimit)
		-- 	return
		-- end
		-- local cfg = DaFuHaoData.Instance:GetDaFuHaoOtherCfg()
		-- if cfg then
			-- local scene_id = cfg.position[1].scene_id
			-- if scene_id == Scene.Instance:GetSceneId() then
			-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
			-- else
				-- GuajiCtrl.Instance:MoveToScenePos(cfg.scene_id, cfg.fly_pos_x, cfg.fly_pos_y, true, 0)
				-- DaFuHaoCtrl.Instance:SendGetGatherInfoReq()
			-- end
		-- end
	elseif link_type == CHAT_LINK_TYPE.GUILD_WELLCOME then
		if guild_welcome_time > Status.NowTime then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.SpeackMax)
			return
		end
		guild_welcome_time = Status.NowTime + 5
		local str = Language.Chat.GuildWellCome[math.random(4)]
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, str)
		ChatCtrl.Instance:RefreshGuildChatMsg()

	elseif link_type == CHAT_LINK_TYPE.MAGIC_WEAPON_VIEW then
		GuajiCtrl.Instance:MoveToScene(AncientRelicsData.SCENE_ID)
	elseif link_type == CHAT_LINK_TYPE.BONFRIE then
		GuildBonfireCtrl.SendGuildBonfireGotoReq()
	elseif link_type == CHAT_LINK_TYPE.GUILD_MIJING then
		local function ok_callback()
			ViewManager.Instance:Close(ViewName.ChatGuild)
			GuildMijingCtrl.SendGuildFbEnterReq()
		end
		local des = Language.Guild.GoToGuildMiJing
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	elseif link_type == CHAT_LINK_TYPE.GUILD_CALLIN then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if guild_id > 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.HasInGuild)
			return
		end
		GuildCtrl.Instance:SendApplyForJoinGuildReq(param1)
	elseif link_type == CHAT_LINK_TYPE.XING_ZUO_YI_JI then 		-- 星座遗迹
		ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI, 0)
		ViewManager.Instance:CloseAll()
	elseif link_type == CHAT_LINK_TYPE.WO_DISCOUNT then
		local phase = DisCountData.Instance:GetPhaseIndex()					--一折抢购
		if phase == 0 then
			if not OpenFunData.Instance:CheckIsHide("DisCount") then
				SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
				return
			end
			ViewManager.Instance:Open(ViewName.DisCount)
		else
			if not OpenFunData.Instance:CheckIsHide("DisCount") then
				SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
				return
			end
			DisCountCtrl.Instance:JumpToViewIndex(phase)
			ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {phase})
		end
	elseif link_type == CHAT_LINK_TYPE.ADD_FRIEND then
		if tonumber(param1) == GameVoManager.Instance:GetMainRoleVo().role_id then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotAddSelf)
			return
		end
		ScoietyCtrl.Instance:AddFriendReq(param1)

	elseif link_type == CHAT_LINK_TYPE.JUBAOPEN then
		JuBaoPenCtrl.Instance:OpenView()
	elseif link_type == CHAT_LINK_TYPE.FUBEN_TOUZI then
		-- ACTIVITY_TYPE_TO_INDEX 不是全局的是local的，真TM的是人才，没办法写死66
		--ViewManager.Instance:Open(ViewName.KaifuActivityView, ACTIVITY_TYPE_TO_INDEX[TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_FuBenTouZi])
		if KaifuActivityData.Instance:ShowFbTouzi() and KaifuActivityData.Instance:IsAllFetchFBTouZi() == false then
			ViewManager.Instance:Open(ViewName.TouziActivityView, 66)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.ActivityEndDes)
		end
	elseif link_type == CHAT_LINK_TYPE.BOSS_TOUZI then
		if KaifuActivityData.Instance:ShowBossTouzi() and KaifuActivityData.Instance:IsAllFetchBossTouZi() == false then
			ViewManager.Instance:Open(ViewName.TouziActivityView, 67)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.ActivityEndDes)
		end
	elseif link_type == CHAT_LINK_TYPE.SHENYUBOSS_TOUZI then
		if KaifuActivityData.Instance:ShowShenYuBossTouzi() and KaifuActivityData.Instance:IsAllFetchShenYuBossTouZi() == false then
			ViewManager.Instance:Open(ViewName.TouziActivityView, 68)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.ActivityEndDes)
		end
	elseif link_type == CHAT_LINK_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE then
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
			return
		end
		ViewManager.Instance:Open(ViewName.KaifuActivityView, 26)
	elseif link_type == CHAT_LINK_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_ONE then
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
			return
		end
		ViewManager.Instance:Open(ViewName.CrazyHappyView, 4)
	elseif link_type == CHAT_LINK_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_TWO then
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
			return
		end
		ViewManager.Instance:Open(ViewName.CrazyHappyView, 5)
	elseif link_type == CHAT_LINK_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_THREE then
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
			return
		end
		ViewManager.Instance:Open(ViewName.CrazyHappyView, 6)
	elseif link_type == CHAT_LINK_TYPE.SEND_GTFT_RECORD then
		if tonumber(param1) == -1 and tonumber(param2) == -1 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotInGroup)
			return
		end
		SendGiftCtrl.Instance:SetIsFromRecordView(true)
		SendGiftData.Instance:SetSelectIndexAndType(tonumber(param1), tonumber(param2))
		ViewManager.Instance:Open(ViewName.SendGiftView, TabIndex.send_gift_zengsong)
	elseif link_type == CHAT_LINK_TYPE.SEND_GTFT_RECORD_CONTINUE then
		if tonumber(param1) == -1 and tonumber(param2) == -1 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotInGroup)
			return
		end
		SendGiftCtrl.Instance:SetIsFromRecordView(true)
		SendGiftData.Instance:SetSelectIndexAndType(tonumber(param1), tonumber(param2))
		ViewManager.Instance:Open(ViewName.SendGiftView, TabIndex.send_gift_zengsong)
	elseif link_type == CHAT_LINK_TYPE.HEFU_BOSS then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ENTER)
	elseif link_type == CHAT_LINK_TYPE.DUIHUAN_SHOP then
		if tonumber(param1) == EXCHANGE_PRICE_TYPE.TREASURE then
			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_exchange)
		elseif tonumber(param1) == EXCHANGE_PRICE_TYPE.GUANGHUI then
			ViewManager.Instance:Open(ViewName.ArenaActivityView, TabIndex.exchange_guanghui)
		else
			ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_shengwang)
		end
	elseif link_type == CHAT_LINK_TYPE.IMG_FULING then
		AdvanceData.Instance:SetHuanHuaType(TabIndex.wuqi_huan_hua)
		AdvanceData.Instance:SetImageFulingType(IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI)
		ViewManager.Instance:Open(ViewName.AdvanceHuanhua,TabIndex.mount_huanhua,"wuqihuanhuaview",{TALENT_TYPE.TALENT_SHENYI})
		AdvanceCtrl.Instance:FlushView("wuqihuanhuaview")
	elseif link_type == CHAT_LINK_TYPE.GUILD_DATI then
		local act_id = ACTIVITY_TYPE.GUILD_ANSWER
		ActivityCtrl.Instance:ShowDetailView(act_id)
	elseif link_type == CHAT_LINK_TYPE.GUILDYUNBIAO_TAKEPARK then
		local act_id = ACTIVITY_TYPE.GUILD_BONFIRE
		ActivityCtrl.Instance:ShowDetailView(act_id)
		ViewManager.Instance:Close(ViewName.ChatGuild)
	elseif link_type == CHAT_LINK_TYPE.CHATSINGLE then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local real_role_id = CrossServerData.Instance:GetRoleId()
		real_role_id = real_role_id > 0 and real_role_id or role_vo.role_id

		if real_role_id == tonumber(param1) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Market.SelfChatSinger)
			return
		end
		-- PlayerCtrl.Instance:CSFindRoleByName(param1)

		PlayerCtrl.Instance:SendFindRoleByUUID(role_vo.plat_type, tonumber(param1))
		ScoietyCtrl.Instance:SetWaitOperaName(tonumber(param1), param2, param3)
	elseif link_type == CHAT_LINK_TYPE.LOOKCROSSRANK then
		if not IS_ON_CROSSSERVER then
			CrossRankCtrl.Instance:SetSelectTable(1)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		end
	elseif link_type == CHAT_LINK_TYPE.LOOKCROSSRANKMEILI then
		if not IS_ON_CROSSSERVER then
			CrossRankCtrl.Instance:SetSelectTable(2)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		end
	elseif link_type == CHAT_LINK_TYPE.LOOKCROSSRANKQINYUAN then
		if not IS_ON_CROSSSERVER then
			CrossRankCtrl.Instance:SetSelectTable(3)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		end
	else
		if link_type == CHAT_LINK_TYPE.WO_DAILY_RECHARGE or link_type == CHAT_LINK_TYPE.LEIJI_RECHARGE then
			if IS_ON_CROSSSERVER then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
				return
			end
		end

		ViewManager.Instance:Open(link_cfg.view_name, link_cfg.tab_index)
	end
	ViewManager.Instance:Close(ViewName.Chat)
end

function  RichTextUtil.ParseJingLing(rich_text, param, font_size, color)
	local cfg = SpiritData.Instance:GetSpiritResourceCfg()
	local name = ""
	for k,v in pairs(cfg) do
		if v.id == tonumber(param[2]) then
			name = v.name
			break
		end
	end
	RichTextUtil.AddText(rich_text, name, CHAT_COLOR.GREEN)
end

function  RichTextUtil.ParseWuXingTitle(rich_text, param, font_size, color)
	local cfg = SpiritData.Instance:GetWuXing()
	local title = cfg[tonumber(param[2])].title
	RichTextUtil.AddText(rich_text, title, TEXT_COLOR.PURPLE)
end

function RichTextUtil.ParseInvest(rich_text, param, font_size, color)
	local invest_type = Language.KaiFuInvestType[tonumber(param[2])]
	-- local invest_type = "活跃投资"
	RichTextUtil.AddText(rich_text, invest_type, TEXT_COLOR.YELLOW)
end

function RichTextUtil.ParseCity(rich_text, param, font_size, color)
	local name = MapFindData.Instance:GetNameById(tonumber(param[2]))
	RichTextUtil.AddText(rich_text,name,TEXT_COLOR.YELLOW)
end

function RichTextUtil.ParsGoddressFire(rich_text, param)
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				RichTextUtil.FlyToPos(tonumber(param[2]), tonumber(param[4]), tonumber(param[5]), tonumber(param[3]))
			end)
		end
	end

	RichTextUtil.CreateBtn(rich_text, "立即前往", font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseBuy(rich_text,param,font_size,color)
	local name = ActivityData.Instance:GetActivityNameByType(tonumber(params[2]))
	RichTextUtil.AddText(rich_text,name,CHAT_TEXT_COLOR.GREEN)
end

function RichTextUtil.ParseCloak(rich_text,params,font_size,color)
	local cfg = CloakData.Instance:GetImageListInfo(tonumber(params[2]))
	if nil ~= cfg then
		RichTextUtil.AddText(rich_text,cfg.image_name, CHAT_TEXT_COLOR.GREEN)
	end
end


function RichTextUtil.ParseFanFan(rich_text,params,font_size,color)
	local word_info = PuzzleData.Instance:GetWrodInfo(tonumber(params[2]))
	if word_info then
		RichTextUtil.AddText(rich_text, word_info.word, CHAT_TEXT_COLOR.GREEN)
	end
end

function RichTextUtil.ParseGuoLv(rich_text,params,font_size,color)
end

function RichTextUtil.MarketBuy(rich_text,params,font_size,color)
end

function RichTextUtil.ShenShouCompose(rich_text,params,font_size,color)
	local item_id = tonumber(params[2])
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(item_id)
	local name = shenshou_equip_cfg.name
	color = CHAT_ITEM_COLOR[shenshou_equip_cfg.quality]
	RichTextUtil.AddText(rich_text, name, color)
end

function RichTextUtil.ZhuanzhiTaoZhuang(rich_text, params, font_size, color)
	local cfg = ForgeData.Instance:GetTotleStarInfoBySeq(params[3])
	local suit_name = cfg.name
	if nil ~= suit_name then
		RichTextUtil.AddText(rich_text, suit_name, font_size, text_color)
	end
end

function RichTextUtil.ZhuanzhiSuitPart(rich_text, params, font_size, color)
	local name = ""
	local text_color = COLOR.WHITE
	local data_list = ForgeData.Instance:GetZhuanzhiEquipAll()
	for k, v in pairs(data_list) do
		if k == tonumber(params[3]) then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				local suit_type = tonumber(params[2])
				name = Language.Forge.SuitTypeName3[suit_type] .. "·" .. item_cfg.name

				text_color = CHAT_ITEM_COLOR[item_cfg.color] or text_color
			end
		end
	end

	if "" ~= name then
		RichTextUtil.AddText(rich_text, name, font_size, text_color)
	end
end

function RichTextUtil.ZhuanzhiSuit(rich_text, params, font_size, color)
	local name = ""
	local text_color = COLOR.WHITE
	local suit_group_cfg = ForgeData.Instance:GetZhuanzhiSuitAttrType(tonumber(params[3]))
	if suit_group_cfg then
		local suit_type = tonumber(params[2])
		name = Language.Forge.SuitTypeName3[suit_type] .. Language.Forge.SuitGroupTypeName[suit_group_cfg.group_type]
	end

	if "" ~= name then
		RichTextUtil.AddText(rich_text, name, font_size, text_color)
	end
end

function RichTextUtil.ParseShuxingdanType(rich_text, params, font_size, color)
	local shuxingdan = ""
	if tonumber(params[2]) == SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_ZIZHI then
		shuxingdan = Language.MultiMount.ZiZhi
	elseif tonumber(params[2]) == SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG then
		shuxingdan = Language.MultiMount.Growup
	end

	if "" ~= shuxingdan then
		RichTextUtil.AddText(rich_text, shuxingdan, font_size, color)
	end
end


function RichTextUtil.ParseYaoShi(rich_text, params)
	local grade = tonumber(params[2])
	local str = ""
	local grade_info = WaistData.Instance:GetWaistGradeCfgInfoByGrade(grade)
	if grade_info then
		local image_info = WaistData.Instance:GetWaistImageCfgInfoByImageId(grade_info.image_id)
		if image_info then
			str = ToColorStr(image_info.image_name, CHAT_SOUL_NAME_COLOR[image_info.colour])
		end
	end
	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.ParseTouShi(rich_text, params)
	local grade = tonumber(params[2])
	local str = ""
	local grade_info = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(grade)
	if grade_info then
		local image_info = TouShiData.Instance:GetTouShiImageCfgInfoByImageId(grade_info.image_id)
		if image_info then
			str = ToColorStr(image_info.image_name, CHAT_SOUL_NAME_COLOR[image_info.colour])
		end
	end
	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.ParseQilinBi(rich_text, params)
	local grade = tonumber(params[2])
	local str = ""
	local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(grade)
	if grade_info then
		local image_info = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
		if image_info then
			str = ToColorStr(image_info.image_name, CHAT_SOUL_NAME_COLOR[image_info.colour])
		end
	end
	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.ParseMask(rich_text, params)
	local grade = tonumber(params[2])
	local str = ""
	local grade_info = MaskData.Instance:GetMaskGradeCfgInfoByGrade(grade)
	if grade_info then
		local image_info = MaskData.Instance:GetMaskImageCfgInfoByImageId(grade_info.image_id)
		if image_info then
			str = ToColorStr(image_info.image_name, CHAT_SOUL_NAME_COLOR[image_info.colour])
		end
	end
	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.ParseShengQi(rich_text, params)
	local shenqi_id = tonumber(params[3])
	local shenbing_inlay_cfg = ShenqiData.Instance:GetShenbingInlayCfg()
	local baojia_inlay_cfg = ShenqiData.Instance:GetBaojiaInlayCfg()
	local string = ""
	if tonumber(params[2]) == 0 then
		string = Language.ShenQi.ShenqiType[0] .. shenbing_inlay_cfg[shenqi_id].name
	else
		string = Language.ShenQi.ShenqiType[1] .. baojia_inlay_cfg[shenqi_id].name
	end

	local color = COLOR.RED
	RichTextUtil.AddText(rich_text, string, color)
end

function RichTextUtil.ParseYiZhanDaoDi(rich_text, params, font_size, color)
	local function callback(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				local info_call_back = function()
					PlayerData.Instance:SetIsReturnTalkSystem(true)
					ViewManager.Instance:Open(ViewName.CheckEquip)
				end
				local uid = tonumber(params[2]) or 0
				CheckData.Instance:SetCurrentUserId(uid)
				CheckCtrl.Instance:SetInfoCallBack(uid, info_call_back)
				CheckCtrl.Instance:SendQueryRoleInfoReq(uid)

			end)
		end
	end
	RichTextUtil.CreateBtn(rich_text, params[3], font_size, TEXT_COLOR.WHITE, callback)
end

function RichTextUtil.ParseCrossGbCity(rich_text, params)--, font_size, color)
	local index = tonumber(params[2])
	local str = Language.RecordRank.TaxesPlace[index + 1] or ""
	local color = params[3] or TEXT_COLOR.YELLOW
	RichTextUtil.AddText(rich_text, str, color)
end

function RichTextUtil.ParseOrangeSuitCollect(rich_text, params)
	local str = ""
	local color = TEXT_COLOR.WHITE
	local collect_cfg = SuitCollectionData.Instance:GetOrangeItemType(tonumber(params[2]))
	if collect_cfg then
		str = collect_cfg.name
		color = CHAT_SOUL_NAME_COLOR[4]
	end
	RichTextUtil.AddText(rich_text, str, color)
end

function RichTextUtil.ParseRedEquipCollect(rich_text, params)
	local str = ""
	local color = TEXT_COLOR.WHITE
	local collect_cfg = SuitCollectionData.Instance:GetRedItemType(tonumber(params[2]))
	if collect_cfg then
		str = collect_cfg.name
		color = CHAT_SOUL_NAME_COLOR[5]
	end
	RichTextUtil.AddText(rich_text, str, color)
end

function RichTextUtil.ParseRoomTypepCollect(rich_text, params)
	local str = ""
	local color = TEXT_COLOR.WHITE
	local room_name = Language.CoupleHome.ThemeType[tonumber(params[2])]
	if room_name then
		str = room_name
		color = CHAT_SOUL_NAME_COLOR[7]
	end
	RichTextUtil.AddText(rich_text, str, color)
end

function RichTextUtil.UpgradeType(rich_text, params)
	local upgrade_type = tonumber(params[2])
	local str = Language.Advance.AdvanceUpgradeType[upgrade_type] or ""
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW)
end

function RichTextUtil.Goal_System(rich_text, params)
	local reward_type = tonumber(params[2])
	local str = Language.Goal.Reward_type[reward_type] or ""
	RichTextUtil.AddText(rich_text, str, TEXT_COLOR.YELLOW)
end

function RichTextUtil.UpgradeGrade(rich_text, params)
	local upgrade_type = tonumber(params[2])
	local grade = tonumber(params[3])
	local skill_level = tonumber(params[4]) or 0
	local text_color = COLOR.WHITE
	local str = ""
	local cfg = {}
	local skill_cfg = nil
	local other_cfg = nil
	if upgrade_type == UPGRADE_TYPE.LING_ZHU then
		local grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(grade_info.image_id)
		end
	elseif  upgrade_type == UPGRADE_TYPE.XIAN_BAO then
		local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = XianBaoData.Instance:GetXianBaoImageCfgInfoByImageId(grade_info.image_id)
		end
	elseif  upgrade_type == UPGRADE_TYPE.LING_TONG then
		local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(grade_info.image_id)
			skill_cfg = LingChongData.Instance:GetSkillCfg()
			other_cfg = LingChongData.Instance:GetOtherCfg()
		end
	elseif  upgrade_type == UPGRADE_TYPE.LING_GONG then
		local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(grade_info.image_id)
		end
	elseif  upgrade_type == UPGRADE_TYPE.LING_QI then
		local grade_info = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(grade_info.image_id)
		end
	elseif  upgrade_type == UPGRADE_TYPE.WEI_YAN then
		local grade_info = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = WeiYanData.Instance:GetWeiYanImageCfgInfoByImageId(grade_info.image_id)
		end
	elseif  upgrade_type == UPGRADE_TYPE.SHOU_HUAN then
		local grade_info = ShouHuanData.Instance:GetShouHuanGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = ShouHuanData.Instance:GetShouHuanImageCfgInfoByImageId(grade_info.image_id)
		end
	elseif  upgrade_type == UPGRADE_TYPE.TAIL then
		local grade_info = TailData.Instance:GetTailGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = TailData.Instance:GetTailImageCfgInfoByImageId(grade_info.image_id)
		end
	elseif  upgrade_type == UPGRADE_TYPE.FLY_PET then
		local grade_info = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(grade)
		if nil ~= grade_info then
			cfg = FlyPetData.Instance:GetFlyPetImageCfgInfoByImageId(grade_info.image_id)
			skill_cfg = FlyPetData.Instance:GetSkillCfg()
			other_cfg = FlyPetData.Instance:GetOtherCfg()
		end
	end

	if cfg and next(cfg) and skill_cfg == nil and other_cfg == nil then
		str = ToColorStr(cfg.image_name, CHAT_SOUL_NAME_COLOR[cfg.colour])
	elseif cfg and next(cfg) and skill_cfg  and other_cfg  then
		local skill_info_cfg = {}
		local skill_idx = other_cfg.medal_skill_index or 0
		for k,v in pairs(skill_cfg) do
			if v.skill_idx == skill_idx and v.skill_level == skill_level then
				skill_info_cfg = v
			end
		end

		local dec = ""
		if skill_idx == 0 or skill_level == 0 or not skill_info_cfg.skill_name then
			dec = string.format(Language.JinJieChuanWen.ChuanWen2, cfg.image_name)
		else
			dec = string.format(Language.JinJieChuanWen.ChuanWen1, cfg.image_name, skill_info_cfg.skill_name)
		end

		str = ToColorStr(dec, CHAT_SOUL_NAME_COLOR[cfg.colour])
	end

	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.NightFightCamp(rich_text, params)
	local str = ""
	local camp = tonumber(params[2])
	if Language.NightFight.SideName[camp] then
		str = Language.NightFight.SideName[camp]
	end

	RichTextUtil.AddText(rich_text, str)
end

function RichTextUtil.GetOpenLinkCfg(link_type)
	if RichTextUtil.link_cfg_list == nil then
		RichTextUtil.link_cfg_list = {
			[CHAT_LINK_TYPE.GUILD_APPLY] = {name = "申请加入", view_name = ViewName.Guild, tab_index = nil},
			[CHAT_LINK_TYPE.EQUIP_QIANG_HUA] = {name = "我要强化", view_name = ViewName.Forge, tab_index = TabIndex.forge_strengthen},
			[CHAT_LINK_TYPE.MOUNTJINJIE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.mount_jinjie},
			[CHAT_LINK_TYPE.HUSONG] = {name = "我要护送", view_name = ViewName.Husong, tab_index = nil},
			[CHAT_LINK_TYPE.EQUIP_UP_STAR] = {name = "我要升星", view_name = ViewName.Forge, tab_index = TabIndex.forge_up_star},
			[CHAT_LINK_TYPE.GUILD_JUANXIAN] = {name = "我要捐献", view_name = ViewName.Guild, tab_index = nil},
			[CHAT_LINK_TYPE.EQUIP_FULING] = {name = "我要附灵", view_name = ViewName.Equipment, tab_index = TabIndex.equipment_fuling},
			[CHAT_LINK_TYPE.MOUNT_LIEHUN] = {name = "我要猎魂", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_soul},
			[CHAT_LINK_TYPE.JINGLING_UPLEVEL] = {name = "我要升级", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_spirit},
			[CHAT_LINK_TYPE.ACHIEVE_UP] = {name = "我要提升", view_name = ViewName.BaoJu, tab_index = TabIndex.baoju_achieve_title},
			[CHAT_LINK_TYPE.EQUIP_JICHENG] = {name = "我要继承", view_name = ViewName.Equipment, tab_index = TabIndex.equipment_jicheng},
			[CHAT_LINK_TYPE.XIANJIE_UP] = {name = "我要提升", view_name = ViewName.ShengWang, tab_index = TabIndex.shengwang_xianjie},
			[CHAT_LINK_TYPE.EQUIP_UPLEVEL] = {name = "我要进阶", view_name = ViewName.Equipment, tab_index = TabIndex.equipment_levelup},
			[CHAT_LINK_TYPE.ROLE_BAOSHI] = {name = "我要镶嵌", view_name = ViewName.Forge, tab_index = TabIndex.forge_baoshi},
			[CHAT_LINK_TYPE.ROLE_WINGUP] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.wing_jinjie},
			[CHAT_LINK_TYPE.DA_FU_HAO] = {name = "立即前往", view_name = ViewName.Advance, tab_index = TabIndex.wing_jinjie},
			[CHAT_LINK_TYPE.VIP]= {name = "成为VIP", view_name = ViewName.Vip, tab_index = nil},
			[CHAT_LINK_TYPE.BOSS_WORLD] = {name = "前往击杀", view_name = ViewName.Activity, tab_index = TabIndex.activity_boss},
			[CHAT_LINK_TYPE.BOSS_JINGYING] = {name = "前往击杀", view_name = ViewName.Boss, tab_index = nil},
			[CHAT_LINK_TYPE.XUNBAO] = {name = "我要寻宝", view_name = ViewName.Treasure, tab_index = TabIndex.treasure_choujiang},
			[CHAT_LINK_TYPE.SPIRIT_XUNBAO] = {name = "猎取宠物", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_hunt},
			[CHAT_LINK_TYPE.ZHI_ZUN_YUE_KA] = {name = "变身至尊", view_name = ViewName.MonthCard, tab_index = nil},
			[CHAT_LINK_TYPE.SUI_JI_CHOU_JIANG] = {name = "我要抽奖", view_name = ViewName.ActRoller, tab_index = nil},
			[CHAT_LINK_TYPE.CAN_JIA_HUN_YAN] = {name = "我要参加", view_name = ViewName.CanJiaHunYan, tab_index = nil},
			[CHAT_LINK_TYPE.WO_QIUHUN] = {name = "我要求婚", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.FAZHEN_UP] = {name = "我要进阶", view_name = ViewName.RoleView, tab_index = TabIndex.role_wf},
			[CHAT_LINK_TYPE.MOUNT_FLY] = {name = "我要飞升", view_name = ViewName.Mount, tab_index = TabIndex.mount_flyup},
			[CHAT_LINK_TYPE.WO_CHONGZHI] = {name = "我要充值", view_name = ViewName.VipView, tab_index = nil},
			[CHAT_LINK_TYPE.DAY_DANBI] = {name = "查看活动", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.PaTa] = {name = "我要挑战", view_name = ViewName.FuBen, tab_index = TabIndex.fb_tower},
			[CHAT_LINK_TYPE.GENGU]  =  {name = "提升根骨", view_name = ViewName.RoleView, tab_index = TabIndex.role_gengu},
			[CHAT_LINK_TYPE.JINGMAI]  =  {name = "提升经脉", view_name = ViewName.RoleView, tab_index = TabIndex.role_jingmai},
			[CHAT_LINK_TYPE.SPRITE_FLY]  =  {name = "我要进阶", view_name = ViewName.Sprite, tab_index = TabIndex.jingling_train_fly},
			[CHAT_LINK_TYPE.FORGE_EQUIP_UPLEVEL]  =  {name = "我要升级", view_name = ViewName.Forge, tab_index = TabIndex.forge_cast},
			[CHAT_LINK_TYPE.SHEN_GRADE]  =  {name = "我要进阶", view_name = ViewName.ShenEquip, tab_index = TabIndex.equipmentshen_jinjie},
			[CHAT_LINK_TYPE.WO_LINGYU_FB]  =  {name = "我要挑战", view_name = ViewName.Daily, tab_index = TabIndex.daily_richang},
			[CHAT_LINK_TYPE.ZHENBAOGE]  =  {name = "套装探秘", view_name = ViewName.Zhenbaoge, tab_index = nil},
			[CHAT_LINK_TYPE.MIJINGTAOBAO]  =  {name = "秘境淘宝", view_name = ViewName.MiJingTaoBao, tab_index = nil},
			[CHAT_LINK_TYPE.WO_LOTTERYTREE] = {name = "神帝转盘", view_name = ViewName.ZhuangZhuangLe, tab_index = nil},
			[CHAT_LINK_TYPE.WO_KINGDRAW] = {name = "大奖翻翻乐", view_name = ViewName.FanFanZhuanView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_LINGQI] =  {name = "我要灵器", view_name = ViewName.ShenEquip, tab_index = TabIndex.lq_shuxing},
			[CHAT_LINK_TYPE.WO_WAKUANG] =  {name = "我要狩猎", view_name = ViewName.GoldHuntView, tab_index = nil},
			[CHAT_LINK_TYPE.DIVINATION] =  {name = "占星好礼", view_name = ViewName.LuckyDrawView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_FANFANZHUAN] =  {name = "翻翻乐", view_name = ViewName.PuzzleView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_MULTIMOUNT] =  {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_multi_mount},
			[CHAT_LINK_TYPE.WO_FARM_HUNT] =  {name = "我要抽奖", view_name = ViewName.Marry, tab_index = TabIndex.marry_farm_hunt},
			-- [CHAT_LINK_TYPE.WO_MAGIC_CARD] =  {name = "我要魔卡", view_name = ViewName.MoLong, tab_index = TabIndex.magic_lottery},
			[CHAT_LINK_TYPE.WO_JINGLING_HALO] =  {name = "我要进阶", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_halo},
			[CHAT_LINK_TYPE.WO_TREASURE_BUSINESSMAN] =  {name = "奇珍商城", view_name = ViewName.TreasureBusinessmanView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_MOUNTJINGPO] =  {name = "我要进阶", view_name = ViewName.MountJingPo, tab_index = nil},
			[CHAT_LINK_TYPE.CROSS_FB_TEAMMATE] =  {name = "申请加入", view_name = ViewName.FuBen, tab_index = TabIndex.fb_many_people},
			[CHAT_LINK_TYPE.TOMB_BOSS] =  {name = "立即前往", view_name = ViewName.FuBen, tab_index = TabIndex.fb_many_people},
			[CHAT_LINK_TYPE.SPIRIT_FAZHEN] = {name = "我要进阶", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_fazhen},
			[CHAT_LINK_TYPE.HALO_UPGRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.halo_jinjie},
			[CHAT_LINK_TYPE.FIGHT_MOUNT_UPGRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.fight_mount},
			[CHAT_LINK_TYPE.FABAO_UPGRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.fabao_jinjie},
			[CHAT_LINK_TYPE.SHENGONG_UPGRADE] = {name = "我要进阶", view_name = ViewName.Goddess, tab_index = TabIndex.goddess_shengong},
			[CHAT_LINK_TYPE.SHENYI_UPGRADE] = {name = "我要进阶", view_name = ViewName.Goddess, tab_index = TabIndex.goddess_shenyi},
			[CHAT_LINK_TYPE.FOOTPRINT_UPGRADE] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.foot_jinjie},
			[CHAT_LINK_TYPE.GUILD_WELLCOME] = {name = "打个招呼", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.TIANSHEN_ZHUANGBEI] = {name = "前往进阶", view_name = ViewName.Player, tab_index = TabIndex.role_rebirth},
			[CHAT_LINK_TYPE.MAGIC_WEAPON_VIEW] = {name = "前往夺宝", view_name = ViewName.MagicWeaponView, tab_index = nil},
			[CHAT_LINK_TYPE.MARRY_TUODAN] = {name = "我来瞅瞅", view_name = ViewName.Marriage, tab_index = TabIndex.marriage_honey},
			[CHAT_LINK_TYPE.KF_BOSS] = {name = "立即前往", view_name = ViewName.ShenYuBossView, tab_index = TabIndex.kf_boss},
			[CHAT_LINK_TYPE.BONFRIE] = {name = "立即前往", view_name = "", tab_index = ""},
			[CHAT_LINK_TYPE.GUILD_MIJING] = {name = "立即前往", view_name = "", tab_index = ""},
			[CHAT_LINK_TYPE.GUILD_CALLIN] = {name = "加入仙盟", view_name = "", tab_index = ""},
			[CHAT_LINK_TYPE.WO_COMPOSE] = {name = "我要合成", view_name = ViewName.Forge, tab_index = TabIndex.forge_compose},
			[CHAT_LINK_TYPE.WO_RUNE] = {name = "我要战魂", view_name = ViewName.Rune, tab_index = TabIndex.rune_treasure},
			[CHAT_LINK_TYPE.FASHION] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.fashion_jinjie},
			[CHAT_LINK_TYPE.SHEN_BING] = {name = "我要进阶", view_name = ViewName.Advance, tab_index = TabIndex.role_shenbing},
			[CHAT_LINK_TYPE.SHEN_GE_BLESS] = {name = "我要召星", view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_bless},
			[CHAT_LINK_TYPE.XING_ZUO_YI_JI] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.SHEN_GE_COMPOSE] = {name = "我要合成", view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_compose},
			[CHAT_LINK_TYPE.SHENGXIAO_TU] = {name = "我要拼图", view_name = ViewName.ShengXiaoView, tab_index = TabIndex.shengxiao_piece},
			[CHAT_LINK_TYPE.WO_HUNQI_DAMO] = {name = "我要铸魂", view_name = ViewName.HunQiView, tab_index = TabIndex.hunqi_damo},
			[CHAT_LINK_TYPE.WO_DAILY_RECHARGE] = {name = "前往查看", view_name = ViewName.LeiJiDailyView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_LEVEL_TOUZHI] = {name = "我要投资", view_name = ViewName.KaifuActivityView, tab_index = 63},
			[CHAT_LINK_TYPE.WO_YUE_TOUZHI] = {name = "我要投资", view_name = ViewName.KaifuActivityView, tab_index = 64},
			[CHAT_LINK_TYPE.WO_ZERO_GIFT] = {name = "我要领取", view_name = ViewName.FreeGiftView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_FENG_SHEN] = {name = "我要挑战", view_name = ViewName.MolongMibaoView, tab_index = nil},
			[CHAT_LINK_TYPE.WO_DISCOUNT] = {name = "我要抢购", view_name = ViewName.DisCount, tab_index = nil},
			[CHAT_LINK_TYPE.WO_TEMP_GIFT] = {name = "我要抢购", view_name = ViewName.KaifuActivityView, tab_index = 8}, --礼包限购
			[CHAT_LINK_TYPE.WO_SELF_BUY] = {name = "我要特价", view_name = ViewName.KaifuActivityView, tab_index = 9},
			[CHAT_LINK_TYPE.WO_SHENGE_INLAY] = {name = "我要升级", view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_inlay},
			[CHAT_LINK_TYPE.WO_SPIRIT_UPGRADE] = {name = "我要提升", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_spirit},
			[CHAT_LINK_TYPE.SHENMI_SHOP] = {name = "我要购买", view_name = ViewName.Shop, tab_index = TabIndex.shop_youhui},
			[CHAT_LINK_TYPE.ADD_FRIEND] = {name = "加好友", view_name="", tab_index=""},
			[CHAT_LINK_TYPE.RED_EQUIP_JINJIE] = {name = "我要红装", view_name= ViewName.Forge, tab_index= TabIndex.forge_red_equip},
			[CHAT_LINK_TYPE.ARENA_SHENGLI] = {name = "我要挑战", view_name= ViewName.ArenaActivityView, tab_index= TabIndex.arena_view},
			[CHAT_LINK_TYPE.ZHANGKONG_SHENGJI] = {name = "我要升级", view_name= ViewName.ShenGeView, tab_index= TabIndex.shen_ge_zhangkong},
			[CHAT_LINK_TYPE.JUBAOPEN] = {name = "我要投资", view_name= "", tab_index = nil},
			[CHAT_LINK_TYPE.FUBEN_TOUZI] = {name = "我要投资", view_name= "", tab_index = nil},
			[CHAT_LINK_TYPE.BOSS_TOUZI] = {name = "我要投资", view_name= "", tab_index = nil},
			[CHAT_LINK_TYPE.SHENYUBOSS_TOUZI] = {name = "我要投资", view_name= "", tab_index = nil},
			[CHAT_LINK_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE] = {name = "累计充值", view_name = ""},
			[CHAT_LINK_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_ONE] = {name = "累计充值", view_name = ""},
			[CHAT_LINK_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_TWO] = {name = "累充回馈", view_name = ""},
			[CHAT_LINK_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_THREE] = {name = "累充豪礼", view_name = ""},
			[CHAT_LINK_TYPE.FORTE_ENTERNITY] = {name = "我要锻造", view_name= ViewName.Forge, tab_index = TabIndex.forge_yongheng},
			[CHAT_LINK_TYPE.GOLDEN_PIG_ACTIVITY] = {name = "立即前往", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.GODDESS_SHENGWU] = {name = "我要升级", view_name = ViewName.Goddess, tab_index = TabIndex.goddess_shengwu},
			[CHAT_LINK_TYPE.GODDESS_GONGMING] = {name = "我要升级", view_name = ViewName.Goddess, tab_index = TabIndex.goddess_gongming},
			[CHAT_LINK_TYPE.KAIFU_INVEST] = {name = "我要投资", view_name = ViewName.KaifuActivityView, tab_index = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST + 100000},
			[CHAT_LINK_TYPE.DUIHUAN_SHOP] = {name = "我要兑换", view_name = ViewName.Exchange, tab_index = TabIndex.exchange_shengwang},
			[CHAT_LINK_TYPE.MAP_FIND] = {name = "宝藏猎人", view_name = ViewName.MapFindView},
			[CHAT_LINK_TYPE.RUSH_BUY] = {name = "限时秒杀", view_name = ViewName.TimeLimitSaleView},
			[CHAT_LINK_TYPE.PIFENG_UPLEVEL] = {name = "我要升级", view_name = ViewName.Advance, tab_index = TabIndex.cloak_jinjie},
			[CHAT_LINK_TYPE.SPIRIT_MEET] = {name = "我要捕捉", view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_meet},
			[CHAT_LINK_TYPE.GODDESS_INFO] = {name = "我要兑换", view_name = ViewName.Exchange, tab_index = TabIndex.exchange_shengwang},
			[CHAT_LINK_TYPE.SHENSHOU_HUANLING] = {name = "我要唤灵", view_name = ViewName.ShenShou, tab_index = TabIndex.shenshou_huanling},
			[CHAT_LINK_TYPE.LEIJI_RECHARGE] = {name = "累计充值", view_name = ViewName.LeiJiRechargeView},
			[CHAT_LINK_TYPE.SHENGE_GODBODY] = {name = "我要修炼", view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_godbody},
			[CHAT_LINK_TYPE.IMG_FULING] = {name = "我要赋灵", view_name = ViewName.AdvanceHuanhua, tab_index = TabIndex.img_fuling_content},
			[CHAT_LINK_TYPE.RUNE_ZHULING] = {name = "我要祭炼", view_name = ViewName.Rune, tab_index = TabIndex.rune_zhuling},
			[CHAT_LINK_TYPE.HUNQI_XILIAN] = {name = "我要融火", view_name = ViewName.HunQiView, tab_index = TabIndex.hunqi_xilian},
			[CHAT_LINK_TYPE.SYMBOL_XILIAN] = {name = "我要炼魂", view_name = ViewName.Symbol, tab_index = TabIndex.symbol_yuanhun},
			[CHAT_LINK_TYPE.SHENYIN_ZHAOYIN] = {name = "我要召印", view_name = ViewName.ShenYinView, tab_index = TabIndex.shenyin_liehun},
			[CHAT_LINK_TYPE.MARKET_BUY] = {name = "我要购买", view_name = ViewName.Market, tab_index = TabIndex.market_buy},
			[CHAT_LINK_TYPE.YAOSHI_UPGRADE] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_waist},
			[CHAT_LINK_TYPE.TOUSHI_UPGRADE] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_toushi},
			[CHAT_LINK_TYPE.QILINBI_UPGRADE] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_qilinbi},
			[CHAT_LINK_TYPE.MASK_UPGRADE] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_mask},
			[CHAT_LINK_TYPE.ZhuanZhiUpStar] = {name = "我要升星", view_name = ViewName.Forge, tab_index = TabIndex.forge_up_star},
			[CHAT_LINK_TYPE.Guild_Invite_Assist] = {name = "我要协助",view_name = ViewName.Guild, tab_index = TabIndex.guild_box},
			[CHAT_LINK_TYPE.SECRET_TREASURE_HUNTING] = {name = "我要寻宝", view_name = ViewName.SecretTreasureHuntingView, tab_index = nil},
			[CHAT_LINK_TYPE.HAPPY_HIT_EGG] = {name = "我要砸蛋", view_name = ViewName.HappyHitEggView, tab_index = nil},
			[CHAT_LINK_TYPE.LING_BOSS] = {name = "立即前往",view_name = ViewName.LingKunBattleDetailView, tab_index = nil},
			[CHAT_LINK_TYPE.HAPPY_ERNIE] = {name = "我要摇奖", view_name = ViewName.HappyErnieView, tab_index = nil},
			[CHAT_LINK_TYPE.HUNYAN_QINGTIE] = {name = "我要请帖", view_name = ViewName.WeddingDeMandView, tab_index = nil},
			[CHAT_LINK_TYPE.INSANE_ERNIE] = {name = "我要摇奖", view_name = ViewName.FestivalView, tab_index = 3},
			[CHAT_LINK_TYPE.UPGRADE_LINGZHU] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_lingzhu},
			[CHAT_LINK_TYPE.UPGRADE_XIANBAO] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_xianbao},
			[CHAT_LINK_TYPE.UPGRADE_LINGTONG] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_lingtong},
			[CHAT_LINK_TYPE.UPGRADE_LINGGONG] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_linggong},
			[CHAT_LINK_TYPE.UPGRADE_LINGQI] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_lingqi},
			[CHAT_LINK_TYPE.UPGRADE_WEIYAN] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_weiyan},
			[CHAT_LINK_TYPE.UPGRADE_SHOUHUAN] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_shouhuan},
			[CHAT_LINK_TYPE.UPGRADE_TAIL] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_tail},
			[CHAT_LINK_TYPE.UPGRADE_FLYPET] = {name = "我要进阶", view_name = ViewName.AppearanceView, tab_index = TabIndex.appearance_flypet},
			[CHAT_LINK_TYPE.LEIJI_CHONGZHI] = {name = "我要奖励", view_name = ViewName.FestivalView, tab_index = 14},
			[CHAT_LINK_TYPE.HEFU_BOSS] = {name = "立即前往", view_name = "",},
			[CHAT_LINK_TYPE.KUAFU_BOSSTIP] = {name = "立即前往", view_name = ViewName.ShenYuBossView, tab_index = TabIndex.kf_boss},
			[CHAT_LINK_TYPE.FORGE_BAPTIZE] = {name = "我要附灵", view_name = ViewName.Forge, tab_index = TabIndex.forge_deity_intersify},
			[CHAT_LINK_TYPE.BIAOBAI] = {name = "我要表白", view_name = ViewName.BiaoBaiQiang},
			[CHAT_LINK_TYPE.SHENYUBOSS_SHENYU] = {name = "立即前往", view_name = ViewName.ShenYuBossView, tab_index = TabIndex.shenyu_secret},
			[CHAT_LINK_TYPE.SHENYUBOSS_YOUMING] = {name = "立即前往", view_name = ViewName.ShenYuBossView, tab_index = TabIndex.shenyu_youming},
			[CHAT_LINK_TYPE.GUILD_DATI] = {name = "立即前往", view_name = ViewName.ActivityDetail},
			[CHAT_LINK_TYPE.SEND_GTFT_RECORD] = {name = "继续赠送", view_name= "", tab_index = nil},
			[CHAT_LINK_TYPE.SEND_GTFT_RECORD_CONTINUE] = {name = "我要回礼", view_name= "", tab_index = nil},
			[CHAT_LINK_TYPE.YUNYOUBOSS] = {name = "我要击杀", view_name = ViewName.Map, tab_index = nil},
			[CHAT_LINK_TYPE.CHATSINGLE] = {name = "立即私聊", view_name = ViewName.ChatGuild, tab_index = nil},
			[CHAT_LINK_TYPE.GIFTLIMITBUY] = {name = "我要抢购", view_name = ViewName.GiftLimitBuy, tab_index = nil},
			[CHAT_LINK_TYPE.TIANSHUSKILL] = {name = "我要技能", view_name = ViewName.TianShuView, tab_index = nil},
			[CHAT_LINK_TYPE.GUILDYUNBIAO_TAKEPARK] = {name = "我要参加", view_name = "", tab_index = nil},
			[CHAT_LINK_TYPE.FORGEEXCHANGE] = {name = "我要合成", view_name = ViewName.Forge, tab_index = TabIndex.forge_exchange},
			[CHAT_LINK_TYPE.LOOKCROSSRANK] = {name = "查看排行", view_name = ViewName.CrossRankView, tab_index = nil},
			[CHAT_LINK_TYPE.LOOKCROSSRANKMEILI] = {name = "查看排行", view_name = ViewName.CrossRankView, tab_index = nil},
			[CHAT_LINK_TYPE.LOOKCROSSRANKQINYUAN] = {name = "查看排行", view_name = ViewName.CrossRankView, tab_index = nil},
			[CHAT_LINK_TYPE.FORGEJUEXING] = {name = "我要觉醒", view_name = ViewName.Forge, tab_index = TabIndex.forge_jue_xing},
			[CHAT_LINK_TYPE.LUCKY_SHOPPING] = {name = "立即参与", view_name = ViewName.LuckyShoppingView, tab_index = nil},
			[CHAT_LINK_TYPE.MYTH_PIANZHAN] = {name = "我要升级", view_name = ViewName.MythView, tab_index = TabIndex.myth_pianzhan},
			[CHAT_LINK_TYPE.MYTH_GONGMING] = {name = "我要冥想", view_name = ViewName.MythView, tab_index = TabIndex.myth_gongming},
			[CHAT_LINK_TYPE.MYTH_COMPOSE] = {name = "我要合成", view_name = ViewName.MythView, tab_index = TabIndex.myth_compose},
			[CHAT_LINK_TYPE.KFArena] = {name = "我要挑战", view_name = ViewName.KFArenaActivityView, tab_index = TabIndex.kf_arena_view},
			[CHAT_LINK_TYPE.DOUQI_GRADE] = {name = "斗气修炼", view_name = ViewName.DouQiView, tab_index = TabIndex.douqi_grade},
			[CHAT_LINK_TYPE.DOUQI_BAOXIANG] = {name = "斗气宝箱", view_name = ViewName.DouQiView, tab_index = TabIndex.douqi_grade},
			[CHAT_LINK_TYPE.DOUQI_REFINE] = {name = "斗气炼制", view_name = ViewName.DouQiView, tab_index = TabIndex.douqi_refine},
			[CHAT_LINK_TYPE.DALE_GOU] = {name = "前往购买", view_name = ViewName.DaLeGouView},
		}
	end
	return RichTextUtil.link_cfg_list[link_type]
end

function RichTextUtil.CrossFish(rich_text, params, font_size, color)
	local tz_index = tonumber(params[2]) or 0
	local cfg = CrossFishingData.Instance:GetFishingCfg()
	local name = ""
	if nil ~= cfg.fish then
		for k,v in pairs(cfg.fish) do
			if v.type == tz_index then
				name = v.name
				break
			end
		end
	end
	if "" ~= name then
		RichTextUtil.AddText(rich_text, name, TEXT_COLOR.YELLOW)
	end
end

function RichTextUtil.TimeContdom(rich_text, params)
	local time = tonumber(params[2]) or 0
	local time_list = TimeUtil.Format2TableDHMS(time)
	time = string.format(Language.Common.TimeStr3, time_list.hour, time_list.min, time_list.s)
	if time then
		RichTextUtil.AddText(nil, time, TEXT_COLOR.YELLOW)
	end
end

function RichTextUtil.ItemId(rich_text, params)
	local imp_item_id = tonumber(params[2]) or 0
	local cfg = EquipData.GetXiaoGuiCfgById(imp_item_id)
	local name
	if cfg then
		name = cfg.imp_guard_name
	end
	if name then
		RichTextUtil.AddText(nil, name, TEXT_COLOR.YELLOW)
	end
end