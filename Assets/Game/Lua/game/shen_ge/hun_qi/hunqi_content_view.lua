HunQiContentView = HunQiContentView or BaseClass(BaseRender)

local EFFECT_CD = 1

function HunQiContentView:OpenCallBack()
	local left_pos = self.node_list["LeftBtn"].transform.anchoredPosition
	local left_bg_pos = self.node_list["LeftBg"].transform.anchoredPosition
	local right_pos = self.node_list["Right"].transform.anchoredPosition
	local attr_pos = self.node_list["BtnAllAttr"].transform.anchoredPosition
	local soul_pos = self.node_list["BtnSoul"].transform.anchoredPosition

	UITween.MoveShowPanel(self.node_list["LeftBtn"], Vector3(left_pos.x - 300, left_pos.y, left_pos.z))
	UITween.MoveShowPanel(self.node_list["LeftBg"], Vector3(left_bg_pos.x - 300, left_bg_pos.y, left_bg_pos.z))
	UITween.MoveShowPanel(self.node_list["Right"], Vector3(right_pos.x + 500, right_pos.y, right_pos.z))
	UITween.MoveShowPanel(self.node_list["BtnAllAttr"], Vector3(attr_pos.x, attr_pos.y + 160, attr_pos.z))
	UITween.MoveShowPanel(self.node_list["BtnSoul"], Vector3(soul_pos.x, soul_pos.y + 250, soul_pos.z))
	UITween.AlpahShowPanel(self.node_list["Center"], true, nil, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, 0.5 , DG.Tweening.Ease.InExpo)
	
end

function HunQiContentView:__init()
	self.effect_cd = 0
	self.select_hunqi_index = 0								--选择的魂器index
	self.select_kapai_index = 0								--选择的卡牌index

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
	self.hunqi_equip_list = {}
	self.goal_data = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_COUNT - 1 do
		local obj = self.node_list["EquipList"].transform:GetChild(i).gameObject
		local equip_cell = HunQiEquipItemCell.New(obj)
		equip_cell:SetIndex(i + 1)
		equip_cell:SetClickCallBack(BindTool.Bind(self.ClickHunQiCallBack, self))
		table.insert(self.hunqi_equip_list, equip_cell)
	end

	self.oct_agon_list = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_SLOT_COUNT-1 do
		local obj = self.node_list["Octagon"].transform:GetChild(i).gameObject
		local oct_agon_cell = OctAgonItemCell.New(obj)
		oct_agon_cell:SetIndex(i+1)
		oct_agon_cell:SetClickCallBack(BindTool.Bind(self.ClickKaPaiCallBack, self))
		table.insert(self.oct_agon_list, oct_agon_cell)
	end

	self.cost_item = ItemCell.New()
	self.cost_item:SetInstanceParent(self.node_list["ItemCell"])

	self.node_list["BtnJiHuo"].button:AddClickListener(BindTool.Bind(self.ClickButton, self))
	self.node_list["BtnAllAttr"].button:AddClickListener(BindTool.Bind(self.OpenAttrView, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnSoul"].button:AddClickListener(BindTool.Bind(self.OpenSoul, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false, true))

	self:InitView()
end

function HunQiContentView:__delete()
	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end

	for _, v in ipairs(self.hunqi_equip_list) do
		v:DeleteMe()
	end
	self.hunqi_equip_list = {}

	for _, v in ipairs(self.oct_agon_list) do
		v:DeleteMe()
	end
	self.oct_agon_list = {}

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function HunQiContentView:FlshGoalContent()
	self.goal_info = HunQiData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON)
				if goal_cfg_info then
					local title_id = goal_cfg_info.reward_show
					local item_id = goal_cfg_info.reward_item[0].item_id
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[0] == 1

					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					local cfg = TitleData.Instance:GetTitleCfg(title_id)
					if nil == cfg then
						return
					end
					local zhanli = CommonDataManager.GetCapabilityCalculation(cfg)
					local bundle, asset = ResPath.GetTitleIcon(title_id)
					self.node_list["Img_chenghao"].image:LoadSprite(bundle, asset, function() 
						TitleData.Instance:LoadTitleEff(self.node_list["Img_chenghao"], title_id, true)
						UI:SetGraphicGrey(self.node_list["Img_chenghao"], self.goal_info.active_flag[0] == 0)
						end)
					self.node_list["Txt_fightpower"].text.text = Language.Goal.PowerUp .. zhanli
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch)
					self.node_list["little_goal_redpoint"]:SetActive(self.goal_data.can_fetch)
				end
			else
				self.node_list["Txt_lefttime"]:SetActive(false)
				self.node_list["Node_little_goal"]:SetActive(false)
			end
		else
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON)
					local item_id = goal_cfg_info.reward_item[0].item_id
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					if item_cfg == nil then
						return
					end
					local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
					self.node_list["Img_touxiang"].image:LoadSprite(item_bundle, item_asset)
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[1] == 1
					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					self.node_list["Txt_shuxing"].text.text = string.format(Language.Goal.AttrAdd, attr_percent/100) .. "%"
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
					self.node_list["big_goal_redpoint"]:SetActive(self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
				end
			else
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(false)
				self.node_list["Txt_shuxing"]:SetActive(false)
			end
		end

		self.goal_data.left_time = diff_time
		if self.count_down == nil then
			function diff_time_func(elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0 then
					if self.count_down ~= nil then
						self.node_list["Txt_lefttime"]:SetActive(false)
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					return
				end
				if left_time > 0 then
					self.node_list["Txt_lefttime"]:SetActive(true)
					self.node_list["Txt_lefttime"].text.text = Language.Goal.FreeTime .. TimeUtil.FormatSecond(left_time, 10)
				else
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
				if self.goal_info.fetch_flag[0] == 1 and self.goal_info.fetch_flag[1] == 1 then
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
			end

			diff_time_func(0, diff_time)
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		end
	end
end

function HunQiContentView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON, is_other_item)
end

function HunQiContentView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(173)
end

function HunQiContentView:OpenSoul()
	ViewManager.Instance:Open(ViewName.GatherSoulView)
end

function HunQiContentView:ClickRelicsBtn()
	local  level  = PlayerData.Instance:GetRoleVo().level
	local skip_gather_level_limit = HunQiData.Instance:GetOtherCfg().skip_gather_level_limit
	local left_gather_times = HunQiData.Instance:GetTodayLeftGatherTimes()
	if level >= skip_gather_level_limit and left_gather_times > 0 then
			GlobalTimerQuest:AddDelayTimer(function ()
				self:OnClickQuick()
			end, 0)
		return
	end

	local function ok_callback()
		ViewManager.Instance:Close(ViewName.HunQiView)
		GuajiCtrl.Instance:MoveToScene(AncientRelicsData.SCENE_ID)
	end

	local des = Language.HunQi.GoToAncientRelicsDes
	HunQiCtrl.Instance:ShowRelicTips(des,nil,ok_callback,Language.Common.Cancel, Language.Common.Confirm)
	ViewManager.Instance:Open(ViewName.TipsGoToRelicView)
end

function HunQiContentView:OnClickQuick()
	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_SHENZHOU_WEAPON, -1)
	end

	local gather_callback = function ()
		ViewManager.Instance:Close(ViewName.HunQiView)
		GuajiCtrl.Instance:MoveToScene(AncientRelicsData.SCENE_ID)
	end

	local left_gather_times = HunQiData.Instance:GetTodayLeftGatherTimes()
	local skip_gather_consume = HunQiData.Instance:GetOtherCfg().skip_gather_consume
	local gold = left_gather_times * skip_gather_consume

	local str = Language.HunQi.GoToAncientRelicsDes ..string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_SHENZHOU_WEAPON], gold, left_gather_times)
	
--给小tips传值
	HunQiCtrl.Instance:ShowRelicTips(str, gather_callback, ok_callback, Language.HunQi.GoToGather, Language.HunQi.QuickFinish)
	ViewManager.Instance:Open(ViewName.TipsGoToRelicView)
end

--获得魂器技能的描述
function HunQiContentView:SkillDescribe()
	local hunqi_index = self.select_hunqi_index-1
	local level = HunQiData.Instance:GetHunQiLevelByIndex(hunqi_index)
	local skill_info = HunQiData.Instance:GetSkillInfoByIndex(hunqi_index, level)
	local next_skill_info = HunQiData.Instance:GetSkillInfoByIndex(hunqi_index, level, true)
	if nil == skill_info then
		return
	end

	local skill_name = HunQiData.Instance:GetHunQiSkillByIndex(hunqi_index)
    local skill_level = skill_info.skill_level
	local skill_res_id = HunQiData.Instance:GetHunQiSkillResIdByIndex(hunqi_index)
	local asset, bunble = ResPath.GetHunQiSkillRes(skill_res_id)
	local now_des = ""
	local next_des = ""
	local levelup_des = ""
	
	now_des = skill_info.skill_dec

	if nil ~= next_skill_info then
		next_des = next_skill_info.skill_dec
		levelup_des = string.format(Language.HunQi.LevelUpDes, next_skill_info.level)
		self.node_list["TxtSkillLevelUpDes"]:SetActive(false)
	else
		next_des = Language.HunQi.YiManJi
		self.node_list["TxtSkillLevelUpDes"]:SetActive(false)
	end

	--设置是否已激活
	local active_des = Language.HunQi.IsActiveDes
	if level <= 0 then
		active_des = Language.HunQi.NotActiveDes
	end
	self.node_list["TxtSkilActivelDes"].text.text = active_des

	local hunqi_name, hunqi_color = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.select_hunqi_index - 1)

	--设置技能属性的名字
	self.node_list["TxtSkillDesNow"].text.text = now_des
	self.node_list["TxtSkillDesNext"].text.text = next_des
	self.node_list["TxtSkillName"].text.text = skill_name
	self.node_list["TxtSkillLevelUpDes"].text.text = ToColorStr(hunqi_name, ITEM_COLOR[hunqi_color]) .. levelup_des
end

function HunQiContentView:OpenAttrView()
	local attr_list = HunQiData.Instance:GetAllAttrInfo()
	TipsCtrl.Instance:ShowAttrView(attr_list, nil, "hunqi")
end

function HunQiContentView:ClickButton()
	if self.select_hunqi_index <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotSelectHunQi)
		return
	end
	if self.select_kapai_index <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotSelectKaPai)
		return
	end

	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_UPGRADE_WEAPON_SLOT, self.select_hunqi_index-1, self.select_kapai_index-1)
end

function HunQiContentView:FlushLeftView()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end
	for k, v in ipairs(self.hunqi_equip_list) do
		if k == self.select_hunqi_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:SetData(hunqi_list[k])
	end
	self:FlushLeftContent()
end

function HunQiContentView:FlushLeftContent()
	--刷新采集次数
	local left_gather_times = HunQiData.Instance:GetTodayLeftGatherTimes()
	local count_des = ToColorStr(left_gather_times, TEXT_COLOR.GREEN)

	if left_gather_times <= 0 then
		count_des = ToColorStr(left_gather_times, TEXT_COLOR.RED)
	end
	self.node_list["TxtRelicsTime"].text.text = string.format(Language.HunQi.RelicsTime, count_des)

	self:FlshGoalContent()
end

function HunQiContentView:FlushModel()
	if self.select_hunqi_index > 0 then
		local bundle, asset = ResPath.GetYiHuoImg(self.select_hunqi_index)
		self.node_list["ImgYiHuo"].image:LoadSprite(bundle,asset)
		self.node_list["NodeEffect"]:ChangeAsset(ResPath.GetHunYinEffect(HunQiData.EFFECT_PATH[self.select_hunqi_index]))
	end
end

function HunQiContentView:FlushCostDes()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end

	local kapai_level_list = hunqi_list[self.select_hunqi_index].weapon_slot_level_list

	if nil == kapai_level_list then
		return
	end

	local select_kapai_level = kapai_level_list[self.select_kapai_index] or 0
	local select_kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index-1, self.select_kapai_index-1, select_kapai_level)
	if nil == select_kapai_data then
		return
	end

	local item_data = select_kapai_data[1].up_level_item or {}
	local item_id = item_data.item_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	local item_name = item_cfg.name or ""
	local item_color = ITEM_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
	local now_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local cost_num = item_data.num or 0
	local now_num_str = now_num
	local braces_color = "#89f201"

	if now_num < cost_num then
		now_num_str = ToColorStr(now_num, TEXT_COLOR.RED_1)
		braces_color = TEXT_COLOR.RED_1
	end

	-- local cost_des = string.format(Language.HunQi.NeedCostDes2, ToColorStr(item_name, item_color), 
	-- 	"<color="..braces_color..">("..now_num_str, cost_num..")</color>")
	local cost_des = string.format("%s / %s", "<color=" .. braces_color .. ">" .. now_num_str .. "</color>", cost_num)
	self.node_list["TxtCost"].text.text = cost_des
	self.cost_item:SetData({item_id = item_id})
end

function HunQiContentView:FlushRightView()
	if self.select_hunqi_index <= 0 then
		self.node_list["ImgContent"]:SetActive(false)
		return
	end

	self.node_list["ImgContent"]:SetActive(true)

	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end

	--设置魂器名字
	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.select_hunqi_index - 1)
	local color = ITEM_COLOR[color_num]
	hunqi_name = ToColorStr(hunqi_name, color)
	self.node_list["TxtHQName"].text.text = hunqi_name

	--设置卡牌数据
	local kapai_level_list = hunqi_list[self.select_hunqi_index].weapon_slot_level_list
	if nil == kapai_level_list then
		return
	end

	local select_index = 0
	local is_select_change = false
	local is_active_skill = true

	for k, v in ipairs(self.oct_agon_list) do
		--判断卡牌红点
		local is_show_redpoint = false
		local kapai_level = kapai_level_list[k]
		if nil ~= kapai_level and kapai_level < HunQiData.SLOT_MAX_LEVEL then
			local kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index-1, k-1, kapai_level)
			if nil ~= kapai_data then
				kapai_data = kapai_data[1]
				local up_level_item_data = kapai_data.up_level_item
				local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
				if now_item_num >= up_level_item_data.num then
					is_show_redpoint = true
				end
			end
		end

		if is_show_redpoint and not is_select_change then
			select_index = k
			is_select_change = true
		end
		if self.select_kapai_index == k and is_show_redpoint then
			select_index = self.select_kapai_index
		end

		v:ShowRedPoint(is_show_redpoint)
		local res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.select_hunqi_index-1)
		local data = {parent_res_id = res_id, level = kapai_level}
		v:SetData(data)
	end

	--设置技能是否已激活
	local hunqi_level = HunQiData.Instance:GetHunQiLevelByIndex(self.select_hunqi_index-1)
	UI:SetGraphicGrey(self.node_list["ImgSkill"], hunqi_level == 0)
	--设置技能图标
	local skill_res_id = HunQiData.Instance:GetHunQiSkillResIdByIndex(self.select_hunqi_index-1)
	local bundle, asset = ResPath.GetHunQiSkillRes(skill_res_id) 
	self.node_list["ImgSkill"].image:LoadSprite(bundle, asset)

	--设置技能等级
	local skill_info = HunQiData.Instance:GetSkillInfoByIndex(self.select_hunqi_index-1, hunqi_level)
	if nil ~= skill_info then
		self.node_list["TxtSkillLevel"].text.text = string.format(Language.HunQi.SkillLevel, skill_info.skill_level)
	end

	--刷新选中
	if select_index > 0 then
		self.select_kapai_index = select_index
	end

	for k, v in ipairs(self.oct_agon_list) do
		if k == self.select_kapai_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
	end

	--设置战斗力
	local capability = HunQiData.Instance:GetHunQiCapability(self.select_hunqi_index)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end

	--设置消耗描述
	self:FlushCostDes()

	--判断卡牌是否满级
	local select_kapai_level = kapai_level_list[self.select_kapai_index] or 0
	if select_kapai_level >= HunQiData.SLOT_MAX_LEVEL then
		self.node_list["TxtCost"].text.text = Language.Common.MaxLevelDesc
		self.node_list["TxtBtn"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["BtnJiHuo"], false)
	else
		UI:SetButtonEnabled(self.node_list["BtnJiHuo"], true)
		if select_kapai_level <= 0 then
			self.node_list["TxtBtn"].text.text = Language.Common.Activate
		else
			self.node_list["TxtBtn"].text.text = Language.Common.UpGrade
		end
	end
end

function HunQiContentView:UpGradeResult(result)
	if result ~= 1 then
		return
	end
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
				bundle_name,
				asset_name,
				self.node_list["EffectObj"].transform,
				2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function HunQiContentView:FlushElementRed()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if hunqi_list == nil then
		return
	end

	local is_show = false
	for k1, v1 in ipairs(hunqi_list) do
		if is_show then
			break
		end
		local hunqi_level = v1.weapon_level
		local element_level_list = v1.element_level_list
		for k2, v2 in ipairs(element_level_list) do
			local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(k1-1, k2-1, v2+1)
			if nil ~= next_attr_info then
				local attr_info = HunQiData.Instance:GetSoulAttrInfo(k1-1, k2-1, v2)
				attr_info = attr_info[1]
				local limit_level = attr_info.huqi_level_limit
				if hunqi_level >= limit_level then
					local up_level_item = attr_info.up_level_item
					local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
					if have_num >= up_level_item.num then
						is_show = true
						break
					end
				end
			end
		end
	end
	--self.node_list["ImgRed"]:SetActive(is_show)
	self.node_list["NodeSoulEffect"]:SetActive(is_show)
end

function HunQiContentView:InitView()
	self.select_hunqi_index = 1
	self.select_kapai_index = 1
	--打开界面的时候初始化技能描述面板,因为开始默认初始值为select_hunqi_index为1
	self:SkillDescribe()
	self:FlushLeftView()
	self:FlushModel()
	self:FlushRightView()
	self:FlushElementRed()
end

function HunQiContentView:FlushView()
	self:SkillDescribe()
	self:FlushLeftView()
	self:FlushRightView()
	self:FlushElementRed()
end

function HunQiContentView:ClickHunQiCallBack(cell)
	if nil == cell then
		return
	end
	local index = cell:GetIndex()
	if index == self.select_hunqi_index then
		return
	end
	self.select_hunqi_index = index

	--刷新技能描述
	self:SkillDescribe()
	self.select_kapai_index = 1
	self:FlushModel()
	self:FlushRightView()
	self:FlushLeftContent()
end

function HunQiContentView:ClickKaPaiCallBack(cell)
	cell:SetToggleState(true)
	if nil == cell then
		return
	end
	local index = cell:GetIndex()
	if index == self.select_kapai_index then
		return
	end
	self.select_kapai_index = index

	local data = cell:GetData()
	local level = data.level

	--设置消耗描述
	local select_kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index-1, index-1, level)
	if nil == select_kapai_data then
		return
	end
	local item_data = select_kapai_data[1].up_level_item or {}
	local item_id = item_data.item_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end
	local item_name = item_cfg.name or ""
	local item_color = ITEM_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
	local now_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local cost_num = item_data.num or 0
	local now_num_str = now_num
	local braces_color = "#89f201"
	if now_num < cost_num then
		now_num_str = ToColorStr(now_num, TEXT_COLOR.RED_1)
		braces_color = TEXT_COLOR.RED_1
	end
	local cost_des = string.format("%s / %s", "<color=" .. braces_color .. ">" .. now_num_str .. "</color>", cost_num)
	self.node_list["TxtCost"].text.text = cost_des
	self.cost_item:SetData({item_id = item_id})
	
	if level >= HunQiData.SLOT_MAX_LEVEL then
		self.node_list["TxtCost"].text.text = Language.Common.MaxLevelDesc
		self.node_list["TxtBtn"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["BtnJiHuo"], false)
	else
		UI:SetButtonEnabled(self.node_list["BtnJiHuo"], true)
		if level <= 0 then
			self.node_list["TxtBtn"].text.text = Language.Common.Activate
		else
			self.node_list["TxtBtn"].text.text = Language.Common.UpGrade
		end
	end
end

-------------------------------HunQiEquipItemCell------------------------------
HunQiEquipItemCell = HunQiEquipItemCell or BaseClass(BaseCell)
function HunQiEquipItemCell:__init()
	self.node_list["ToggleEquip"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function HunQiEquipItemCell:__delete()

end

function HunQiEquipItemCell:OnFlush()
	if nil == self.data then
		return
	end

	local level = self.data.weapon_level
	local lv_des = Language.HunQi.LevelText .. level
	self.node_list["TxtLevel"].text.text = lv_des
	self.node_list["TxtLevel1"].text.text = lv_des

	local cell_index = self:GetIndex()
	local yi_huo_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(cell_index - 1)
	local color = ITEM_COLOR[color_num]
	yi_huo_name = ToColorStr(yi_huo_name, color)

	self.node_list["TxtHideName"].text.text = yi_huo_name
	self.node_list["TxtHighLightName"].text.text = yi_huo_name

	--判断是否激活
	if level <= 0 then
		UI:SetGraphicGrey(self.node_list["Img"], true)
	else
		UI:SetGraphicGrey(self.node_list["Img"], false)
	end

	--设置红点
	local is_show = false
	local kapai_level_list = self.data.weapon_slot_level_list

	if nil == kapai_level_list then
		return
	end

	for k, v in ipairs(kapai_level_list) do
		if v < HunQiData.SLOT_MAX_LEVEL then
			local kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.index-1, k-1, v)
			if nil ~= kapai_data then
				kapai_data = kapai_data[1]
				local up_level_item_data = kapai_data.up_level_item
				local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
				if now_item_num >= up_level_item_data.num then
					is_show = true
					break
				end
			end
		end
	end

	self.node_list["ImgRedPoint"]:SetActive(is_show)

	--设置图标
	local model_res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.index-1)
	local param = model_res_id - 17000
	local res_id = "HunQi_" .. param
	local bundle, asset = ResPath.GetHunQiImg(res_id)
	self.node_list["Img"].image:LoadSprite(bundle, asset)
	
	local is_open, _, data_list = DisCountData.Instance:IsOpenYiZheAllBySystemId(Sysetem_Id_Jump.Yi_Huo)
	if is_open then
		for k, v in pairs(data_list.system_index) do
			local index_list = Split(v, "|")
			for k1, v1 in pairs(index_list) do
				if tonumber(v1) == self.index then
					self.node_list["IconYiZhe"].image:LoadSprite("uis/images_atlas", "label_status_xianshiyizhe")
					self.node_list["IconYiZhe"].image:SetNativeSize()
					break
				end
			end
		end
	end

end

function HunQiEquipItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end

-------------------------------OctAgonItemCell------------------------------
OctAgonItemCell = OctAgonItemCell or BaseClass(BaseCell)
function OctAgonItemCell:__init()
	self.node_list["Toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function OctAgonItemCell:__delete()

end

function OctAgonItemCell:OnFlush()
	if nil == self.data then
		return
	end

	local flag = self.data.level <= 0
	UI:SetGraphicGrey(self.node_list["ImgNormal"], flag)
	self.node_list["TxtNum"].text.text = self.data.level

	if self.data.parent_res_id then
		local parent_param = self.data.parent_res_id - 17000
		local res_id = "KaPai" .. parent_param .. "_" .. self.index
		local bundle, asset = ResPath.GetHunQiImg(res_id)
		self.node_list["ImgNormal"].image:LoadSprite(bundle, asset)
	end
end

function OctAgonItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end

function OctAgonItemCell:ShowRedPoint(state)
	self.node_list["ImgRedPoint"]:SetActive(state)
end