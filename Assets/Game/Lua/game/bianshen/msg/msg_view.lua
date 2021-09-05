-- 幻域-神魔-信息
local MAX_ATTR_NUM = 3
local SERIES = 4

MsgView = MsgView or BaseClass(BaseRender)
function MsgView:__init()
	self.role_cell_list = {}
end

function MsgView:__delete()
	for k,v in pairs(self.role_cell_list) do
		v:DeleteMe()
	end
	self.role_cell_list = {}

	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.item_cell_goods then
		self.item_cell_goods:DeleteMe()
		self.item_cell_goods = nil
	end

	self.fight_text = nil
	self.cur_select_index = nil
	self.select_role_index = nil
	self.goal_data = {}
end

function MsgView:LoadCallBack()
	self.list_index = 1
	self.cur_attr_list = {}
	self.next_attr_list = {}
	self.goal_data = {}
	for i = 1, MAX_ATTR_NUM do
		self.cur_attr_list[BianShenData.SHOW_ATTR[i]] = self.node_list["CurAttr" .. i]
		self.next_attr_list[BianShenData.SHOW_ATTR[i]] = self.node_list["NextAttr" .. i]
	end

	self.node_list["BtnAttrLook"].button:AddClickListener(BindTool.Bind(self.OnClickOpenAttr, self))
	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnSkillView"].button:AddClickListener(BindTool.Bind(self.OnClickOpenSkill, self))
	self.node_list["BtnActive"].button:AddClickListener(BindTool.Bind(self.OnClickUpCurGeneral, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, true, false))
	self.node_list["BtnUse"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))

	self.item_cell_goods = ItemCell.New()
	self.item_cell_goods:SetInstanceParent(self.node_list["ItemParent"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerLabel"])

	local slot_info = BianShenData.Instance:GetCurrentMingJiangInfo()
	if slot_info then
		self.cur_select_index = slot_info.item_seq ~= -1 and slot_info.item_seq + 1 or 1
		self.select_role_index = slot_info.item_seq ~= -1 and slot_info.item_seq + 1 or 1
		if slot_info.item_seq then
			local cfg = BianShenData.Instance:GetSingleDataBySeq(slot_info.item_seq)
			if cfg and cfg.color then
				self.list_index = cfg.color - 2
			end
		end
	end

	-- 主动技能
	self.skill_data_list = BianShenData.Instance:GetSkillCfg()		
	for i = 1, #self.skill_data_list do
		self.node_list["SkillFrame_" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickPassivitySkillToggle, self, self.skill_data_list[i].skill_id, false, false))
		self.node_list["IconSkill_" .. i].image:LoadSprite(ResPath.GetFamousGeneral("Skill_" .. self.skill_data_list[i].skill_id))
	end

	self.node_list["SkillFrame1"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickPassivitySkillToggle, self, nil, true, false))   -- 变身技能id为nil
	self.node_list["SkillFrame2"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickPassivitySkillToggle, self, nil, true, true)) -- 特殊技能

	self.item_list = {}
	self:InitCell()
	self:DestoryGameObject()
	self:UpdateList()
end

function MsgView:OpenCallBack()
	self.cur_role_index = nil
	local slot_info = BianShenData.Instance:GetCurrentMingJiangInfo()
	if slot_info then
		self.cur_select_index = slot_info.item_seq ~= -1 and slot_info.item_seq + 1 or 1
		self.select_role_index = slot_info.item_seq ~= -1 and slot_info.item_seq + 1 or 1
		if slot_info.item_seq then
			local cfg = BianShenData.Instance:GetSingleDataBySeq(slot_info.item_seq)
			if cfg and cfg.color then
				self.list_index = cfg.color - 2
			else
				self.list_index = 1
			end
		end
	end
	self:OnClickSelect(self.list_index)
	self:CheckIsSelect()
end

function MsgView:InitCell()
	self.left_bar_list = {}
	for i = 1, 4 do
		self.left_bar_list[i] = {}
		self.left_bar_list[i].select_btn = self.node_list["SelectBtn" .. i]
		self.left_bar_list[i].list = self.node_list["List" .. i]
		self.left_bar_list[i].btn_text = self.node_list["BtnText" .. i]
		self.left_bar_list[i].red_state = self.node_list["RedPoint" .. i]
		self.left_bar_list[i].btn_text_high = self.node_list["TxtBtnHigh" .. i]
		self.node_list["SelectBtn" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSelect, self, i))
	end
end

function MsgView:OnClickSelect(index)
	self.list_index = index
	self:SetSelectItem()
	for i = 1, 4 do
		self.node_list["BtnRightActive" .. i]:SetActive(false)
	end
	self.node_list["BtnRightActive" .. self.list_index]:SetActive(true) 
end

function MsgView:SetSelectItem()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:SetHighLight(self.cur_select_index)
		end
	end
end

function MsgView:DestoryGameObject()
	if nil == next(self.item_list) then
		return
	end
	self.is_load = false
	for k,v in pairs(self.item_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.item_list = {}
	self.item_cell_list = {}
end

function MsgView:UpdateList()
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
	self.left_bar_list[self.list_index].list:SetActive(false)
	self.item_list = {}
	self.item_cell_list = {}

	for i = 1, SERIES do
		local bianshen_item_list = BianShenData.Instance:GetListByColorType(i + 2)
		if bianshen_item_list then
			self.left_bar_list[i].select_btn:SetActive(#bianshen_item_list > 0)
			self.left_bar_list[i].btn_text.text.text = Language.BianShen.ShengQiType[i]
			self.left_bar_list[i].btn_text_high.text.text = Language.BianShen.ShengQiType[i]
			self:LoadCell(i, bianshen_item_list)
		end
	end
end

function MsgView:LoadCell(index, bianshen_item_list)
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader" .. index)
	res_async_loader:Load("uis/views/bianshen_prefab", "BianShenHeadItem", nil, function(prefab)
		if nil == prefab then
			return
		end
		for i = 1, #bianshen_item_list do
			local seq = bianshen_item_list[i].seq + 1
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.left_bar_list[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.left_bar_list[index].list.toggle_group
			local item_cell = BianShenHeadItem.New(obj)
			item_cell:SetTabIndex(1)
			local data = BianShenData.Instance:GetDatalistBySeq(bianshen_item_list[i].seq)
			if data then
				item_cell:SetData(data)
				item_cell:ListenClick(BindTool.Bind(self.OnClickRoleListCell, self, seq, data, item_cell))
				self.item_list[#self.item_list + 1] = obj_transform
			end
			self.item_cell_list[seq] = item_cell
		end
		self:CheckIsSelect()
		self:Flush()
	end)
end

function MsgView:CheckIsSelect()
	self:SetSelectItem()
	if self.left_bar_list[self.list_index].select_btn.accordion_element.isOn then --刷新
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
		return
	end
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
end

function MsgView:OnClickRoleListCell(cell_index, cell_data, item_cell)
	if self.cur_select_index == cell_index then return end
	BianShenData.Instance:SetSelectIndex(cell_index)
	local last_select_data = BianShenData.Instance:GetSingleDataBySeq(self.select_role_index - 1)
	local last_general_info = BianShenData.Instance:GetGeneralSingleInfoBySeq(last_select_data.seq)

	self.select_role_index = cell_data.seq + 1
	self.cur_select_index = cell_index
	self:FlushAllHl()
	self:SetSelectItem()
	self:Flush()
end

function MsgView:GetSelectIndex()
	return self.cur_select_index
end

function MsgView:GetSelectSeq()
	return self.select_role_index
end

function MsgView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
			if v.item_id then
				local index, color = BianShenData.Instance:GetIndexByImageId(v.item_id)
				if index and color then
					self.cur_select_index = index + 1
					self.select_role_index = index + 1
					self.list_index = color - 2
					self:OnClickSelect(self.list_index)
					self:CheckIsSelect()
				end
			end
		end
	end
	self:FlshGoalContent()
	local select_data = BianShenData.Instance:GetSingleDataBySeq(self.select_role_index - 1)
	local general_info = BianShenData.Instance:GetGeneralSingleInfoBySeq(select_data.seq)
	local other_cfg = BianShenData.Instance:GetOtherCfg()

	if nil == select_data or nil == general_info or nil == other_cfg then 
		return
	end

	local is_max_level = general_info.level >= other_cfg.max_level
	local curr_attr_per = BianShenData.Instance:GetPerAttrByLevel(general_info.level)
	for k,v in pairs(select_data) do
		if self.cur_attr_list[k] then
			local att_value = math.ceil(v * curr_attr_per)
			self.cur_attr_list[k].text.text = string.format(Language.BianShen.InfoAttr, CommonDataManager.GetAttrName(k), att_value)
			if not is_max_level then
				local next_attr_per = BianShenData.Instance:GetPerAttrByLevel(general_info.level + 1)
				if next_attr_per then
					local next_attr_value = math.ceil(v * next_attr_per - att_value)
					self.next_attr_list[k].text.text = next_attr_value
				end
			end
		end
	end
	if self.fight_text and self.fight_text.text then
		local level = general_info.level ~= 0 and general_info.level or 1 
		local attr_per = BianShenData.Instance:GetPerAttrByLevel(level)
		self.fight_text.text.text = self:GetCurCapacity(select_data, attr_per)
	end
	local name_str = ToColorStr(select_data.name, ITEM_COLOR[select_data.color])
	if general_info.level ~= 0 then
		self.node_list["LvAndName"].text.text = string.format(Language.BianShen.UpGradeCount, name_str, CommonDataManager.GetDaXie(general_info.level))
	else
		self.node_list["LvAndName"].text.text = name_str
	end
	local data_list = BianShenData.Instance:AfterSortList()
	for i = 1, #self.item_cell_list do
		local data = data_list[i]
		self.item_cell_list[data.seq + 1]:SetData(data)
	end

	self.item_cell_goods:SetData({item_id = select_data.item_id})
	local cur_num = ItemData.Instance:GetItemNumInBagById(select_data.item_id)
	local color_num = cur_num > 0 and 1 or 5 
	self.node_list["MaterialsNum"].text.text = is_max_level and Language.Common.MaxLevelDesc or string.format(Language.BianShen.MaterialsNum, SOUL_NAME_COLOR[color_num], cur_num)

	if self.cur_role_index ~= self.select_role_index then
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			UIScene:SetRoleModelScale(1.3)
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end)
		local bundle, asset = ResPath.GetMingJiangRes(select_data.image_id)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
		self.cur_role_index = self.select_role_index
	end
	local is_active_role = BianShenData.Instance:CheckGeneralIsActive(select_data.seq)
	local str = is_active_role and Language.BianShen.ShengJi or Language.BianShen.JiHuo
	if is_max_level then
		str = Language.BianShen.YiManJi
	end
	UI:SetButtonEnabled(self.node_list["BtnActive"], not is_max_level)
	self.node_list["TxtBtnActive"].text.text = str

	self.node_list["NextAttr"]:SetActive(not is_max_level)

	local slot_info =  BianShenData.Instance:GetCurrentMingJiangInfo()
	if slot_info then
	UI:SetButtonEnabled(self.node_list["BtnUse"], is_active_role)
		self.node_list["BtnUse"]:SetActive(not (select_data.seq == slot_info.item_seq))
		self.node_list["IconUse"]:SetActive(select_data.seq == slot_info.item_seq)
		self.node_list["Remind"]:SetActive(not is_max_level and cur_num > 0)
	end

	-- 被动技能
	local each_passive_cfg = BianShenData.Instance:GetsinglePassive(self.select_role_index - 1)
	if each_passive_cfg then
		self.node_list["IconSkill1"].image:LoadSprite(ResPath.GetFamousGeneral("Skill_" .. each_passive_cfg.icon_id))
	end
	local is_have_skill = general_info.active_skill_type ~= 0	-- 是否有天神技能
	if is_have_skill then
		local spe_passive_cfg = BianShenData.Instance:GetSpePassive(self.select_role_index - 1)
		if spe_passive_cfg and spe_passive_cfg.icon_id then
			self.node_list["IconSkill2"].image:LoadSprite(ResPath.GetFamousGeneral("Skill_" .. spe_passive_cfg.icon_id))
		end
	end
	self.node_list["Skill2"]:SetActive(is_have_skill)

	for i = 1, SERIES do
		local is_show_red = BianShenData.Instance:ShowRemindMsgByColor(i + 2)
		self.left_bar_list[i].red_state:SetActive(is_show_red)
	end

	for k, v in pairs(self.item_cell_list) do
		v:SetUpArrow()
	end
end

--获取激活用于引导
function MsgView:GetBtnActive()
	if self.node_list["BtnActive"] then
		return self.node_list["BtnActive"], BindTool.Bind(self.OnClickUpCurGeneral, self)
	end
end

-- 获取出战用于引导
function MsgView:GetBtnUse()
	if self.node_list["BtnUse"] then
		return self.node_list["BtnUse"], BindTool.Bind(self.OnClickUse, self)
	end
end

function MsgView:OnClickUpCurGeneral()
	local select_data = BianShenData.Instance:GetSingleDataBySeq(self.select_role_index - 1)
	if select_data then
		BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_LEVEL_UP, select_data.seq)
	end
end

function MsgView:OnClickUse()
	local select_data = BianShenData.Instance:GetSingleDataBySeq(self.select_role_index - 1)
	local is_active = BianShenData.Instance:CheckGeneralIsActive(select_data.seq)
	if is_active then
		BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_PUTON, select_data.seq, 0)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.BianShen.NeedActive)
	end
end

function MsgView:GetBtnActiveFirstOnClick()
	return BindTool.Bind(self.OnClickUpCurGeneral, self)
end

function MsgView:FlushAllHl()
	for k,v in pairs(self.role_cell_list) do
		v:FlushHL()
	end
end

function MsgView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(311)
end

function MsgView:OnClickOpenAttr()
	local attr_cfg, capability = BianShenData.Instance:GetFamousCapAndAttr()
	local attr_tmp = {}
	for k,v in pairs(BianShenData.Attr) do
		attr_tmp[v] = attr_cfg[v]
	end
	TipsCtrl.Instance:ShowAttrView(attr_tmp)
end

function MsgView:OnClickOpenSkill()
	TipsCtrl.Instance:OpenFamousSkilllView()
end

function MsgView:GetCurCapacity(select_data, attr_per)
	local read_data = {}
	local attr = CommonDataManager.GetAttributteNoUnderline(select_data)
	for k,v in pairs(attr) do
		if v > 0 then
			table.insert(read_data, {key = k, value = v * attr_per})
		end
	end
		
	local attribute = CommonStruct.AttributeNoUnderline()
	if read_data then
		for k,v in pairs(read_data) do
			if v ~= nil and attribute[v.key] ~= nil then
				attribute[v.key] = attribute[v.key] + v.value
			end
		end
	end

	return CommonDataManager.GetCapability(attribute)
end

function MsgView:OnClickPassivitySkillToggle(skill_id, is_passivity_skill, is_special_skill)
	BianShenCtrl.Instance:OpenSkillTipView(skill_id, self.select_role_index, is_passivity_skill, is_special_skill)
end

function MsgView:UITween()
	UITween.MoveShowPanel(self.node_list["BottomPanel"], Vector3(-125, -426, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(274, -28, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["ListPanel"], Vector3(-800, -29, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Title"], Vector3(234, 440, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BtnGrop"], Vector3(-500, 500, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function MsgView:FlshGoalContent()
	self.goal_info = BianShenData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = BianShenData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER)
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
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = BianShenData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER)
				if goal_cfg_info then
					local attr_percent = BianShenData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER)
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

function MsgView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER, is_other_item)
end
