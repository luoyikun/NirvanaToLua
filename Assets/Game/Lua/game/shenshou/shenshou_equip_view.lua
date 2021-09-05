ShenShouEquipView = ShenShouEquipView or BaseClass(BaseRender)
local MOVE_TIME = 0.5
function ShenShouEquipView:__init(instance, mother_view)
	self.select_shou_id = 1

	self:InitScroller()

	self.skill_t = {}
	self.goal_data = {}
	for i = 1, 4 do
		local async_loader = AllocAsyncLoader(self, "skill_item_loader_" .. i)
		async_loader:SetParent(self.node_list["Skillpanel"].transform)
		async_loader:Load("uis/views/shenshouview_prefab", "ShenshouSkillItem", function(obj)
			if IsNil(obj) then
				return
			end
			
			local skill_item = ShenShouSkillItem.New(obj)
			skill_item:SetClickCallBack(BindTool.Bind(self.SkillItemClick, self, i, skill_item))
			self.skill_t[i] = skill_item
			local skill_list = ShenShouData.Instance:GetOneShouSkill(self.select_shou_id)
			for k,v in pairs(self.skill_t) do
				if skill_list[k - 1] then
					v:SetData(skill_list[k - 1])
					v:SetIconParcent(k == 2)
				end
				if v.root_node then
					v.root_node:SetActive(skill_list[k - 1] ~= nil)
				end
			end
		end)
	end

	self.equip_t = {}
	self.equip_up_t = {}
	self.plus_t = {}
	for i = 1, 5 do
		local item_cell = ShenShouEquip.New()
		item_cell:SetInstanceParent(self.node_list["Equip" .. i])
		item_cell:ShowHighLight(false)
		item_cell:GetEffectRoot():SetActive(false)
		self.equip_t[i] = item_cell

		self.equip_up_t[i] = self.node_list["Up" .. i]
		self.equip_up_t[i].transform.parent.transform:SetAsLastSibling()

		self.plus_t[i] = self.node_list["Plus" .. i]
	end

	self.attr_t = {}
	for i = 1, 4 do
		self.attr_t[i] = {}
		self.attr_t[i].attr = self.node_list["TxtAttr" .. i]
		self.attr_t[i].attr_add = self.node_list["TxtAttrTxt" .. i]
	end

	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnClickAdd, self))
	self.node_list["BtnAutoTakeOff"].button:AddClickListener(BindTool.Bind(self.OnClickAutoTakeOff, self))
	self.node_list["BtnFight"].button:AddClickListener(BindTool.Bind(self.OnClickFight, self))
	self.node_list["Btnhelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnPackage"].button:AddClickListener(BindTool.Bind(self.OnClickPackageAndXieXia, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, true, false))
	for i = 1, 5 do
		self.node_list["ImgEquipBg" .. i].button:AddClickListener(BindTool.Bind(self.OnClickPackage, self))
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end
function ShenShouEquipView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-131, -30, 0), MOVE_TIME)
	--UITween.MoveShowPanel(self.node_list["RightContent"], Vector3(180, -20, 0), 0.4)
	UITween.MoveShowPanel(self.node_list["Right1"], Vector3(460, 0, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Right2"], Vector3(0, 120, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["MiddleContent"], Vector3(0, -100, 0), MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["MiddleContent"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
end
function ShenShouEquipView:__delete()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if self.equip_t then
		for k,v in pairs(self.equip_t) do
			v:DeleteMe()
		end
		self.equip_t = {}
	end

	if self.skill_t then
		for k,v in pairs(self.skill_t) do
			v:DeleteMe()
		end
		self.skill_t = {}
	end
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	self.model_id = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function ShenShouEquipView:LoadCallBack()
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, 0)
	self.model_id = 0

	self.node_list["Txt_tishi"].text.text = Language.ShenShou.EquipCollectTishi
end

function ShenShouEquipView:FlshGoalContent()
	self.goal_info = ShenShouData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU)
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
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU)
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

function ShenShouEquipView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU, is_other_item)
end

function ShenShouEquipView:ItemDataChangeCallback()
	local remind_active = ShenShouData.Instance:BtnAddRemind()
	self.node_list["BtnAddRemind"]:SetActive(remind_active > 0)
end

function ShenShouEquipView:InitScroller()
	self.cell_list = {}
	self.data = ShenShouData.Instance:GetShenshouListData()

	local delegate = self.node_list["Listview"].list_simple_delegate
	delegate.NumberOfCellsDel = function()
		return #self.data
	end

	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  ShenShouItem.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.node_list["Listview"].toggle_group)
		end
		local cell_data = self.data[data_index]
		target_cell:SetIndex(data_index)
		target_cell:SetData(cell_data)
		target_cell:SetClickCallBack(BindTool.Bind(self.SelectShenShouCallBack, self, data_index))
		target_cell:SetToggle(cell_data.shou_id == self.select_shou_id)
	end
end

function ShenShouEquipView:SelectShenShouCallBack(data_index)
	self.model_view:ResetRotation()
	self.select_shou_id = data_index
	self:Flush()
end

function ShenShouEquipView:SelectAndJumpToShenShouCallBack(data_index)
	self.model_view:ResetRotation()
	self.select_shou_id = data_index
	for k, v in pairs(self.cell_list) do
		v:SetToggle(v:GetIndex() and data_index == v:GetIndex())
	end
	self.node_list["Listview"].scroller:ReloadData((data_index - 1) / #self.data)
	self:Flush()
end

function ShenShouEquipView:SkillItemClick(index, cell)
	ShenShouCtrl.Instance:OpenSkillTip(index, cell)
end

function ShenShouEquipView:EquipClick(index, cell)
	ShenShouCtrl.Instance:SetDataAndOepnEquipTip(cell:GetData(), ShenShouEquipTip.FromView.ShenShouView, self.select_shou_id)
end

function ShenShouEquipView:OpenCallBack()
	self:Flush()
	-- if self.equip_t then
	-- 	for k,v in pairs(self.equip_t) do
	-- 		v:ImageEnabled(false);
	-- 	end
	-- end
end

function ShenShouEquipView:ResetCell()
	-- body
	if self.equip_t then
		for k,v in pairs(self.equip_t) do
			v:ImageEnabled(true);
		end
	end
end

function ShenShouEquipView:OnClickAdd()
	local extra_num_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").extra_num_cfg
	local extra_zhuzhan_count = ShenShouData.Instance:GetExtraZhuZhanCount()
	if extra_zhuzhan_count < #extra_num_cfg then 
		ShenShouCtrl.Instance:OpenExtraZhuZhanTip()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.CanNotAddZhuZhan)
	end
end

function ShenShouEquipView:OnClickAutoTakeOff()
	for i = 0, 5 do
		ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_TAKE_OFF, self.select_shou_id, i)
	end
end

function ShenShouEquipView:OnClickPackageAndXieXia()
	local is_zhuzhan = ShenShouData.Instance:IsShenShouZhuZhan(self.select_shou_id)
	if is_zhuzhan then
		self:OnClickAutoTakeOff()
	else
		ShenShouCtrl.Instance:OpenShenShouBag(self.select_shou_id)
	end
end

function ShenShouEquipView:OnClickPackage()
	ShenShouCtrl.Instance:OpenShenShouBag(self.select_shou_id)
end

function ShenShouEquipView:OnClickFight()
	-- local is_zhuzhan = ShenShouData.Instance:IsShenShouZhuZhan(self.select_shou_id)
	-- if is_zhuzhan then
	-- 	self:OnClickAutoTakeOff()
	-- else
		ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_ZHUZHAN, self.select_shou_id)
	-- end
end

function ShenShouEquipView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(225)
end

function ShenShouEquipView:OnFlush(param_t)
	self:FlshGoalContent()
	self.data = ShenShouData.Instance:GetShenshouListData()
	if self.node_list["Listview"].scroller.isActiveAndEnabled then
		-- self.node_list["Listview"].scroller:RefreshAndReloadActiveCellViews(true)
		for k, v in pairs(self.cell_list) do
			v:FlushRemind()
		end
	end
	local remind_active = ShenShouData.Instance:BtnAddRemind()
	self.node_list["BtnAddRemind"]:SetActive(remind_active > 0)
	local shenshou_list = ShenShouData.Instance:GetShenshouList(self.select_shou_id)
	local is_visible = ShenShouData.Instance:GetShenShouHasRemindImg(self.select_shou_id)
	local is_active  = ShenShouData.Instance:IsShenShouActive(self.select_shou_id)
	local last_active = self.node_list["Feng"].gameObject.activeInHierarchy
	self.node_list["Feng"]:SetActive(not is_active)
	if not is_active and last_active == is_active then 
		UITween.ScaleShowPanel(self.node_list["Feng"], Vector3(0.7, 0.7, 0.7))
	end
	--UI:SetGraphicGrey(self.node_list["DisPlayBoss"], not is_active)
	UI:SetGraphicGrey(self.node_list["Display"], not is_active)
	UI:SetButtonEnabled(self.node_list["BtnFight"], is_active)
	local flag = false
	local quality_requirement = ShenShouData.Instance:GetQualityRequirement(self.select_shou_id)
	for k,v in pairs(quality_requirement) do
		local str = Language.ShenShou.ItemDesc[v.slot_need_quality] .. Language.ShenShou.ZhuangBeiLeiXing[v.slot]
		self.plus_t[v.slot + 1].text.text = "<color=" .. ITEM_TIP_COLOR[v.slot_need_quality] .. ">" .. str .. "</color>"
	end
	if shenshou_list then
		for k, v in pairs(shenshou_list.equip_list) do
			self.plus_t[k]:SetActive(v.item_id == 0)
			self.equip_t[k]:SetData(v)
			self.equip_t[k].root_node:SetActive(v.item_id > 0)
			flag = ShenShouData.Instance:GetHasBetterShenShouEquip(v, self.select_shou_id, k)
			local is_up_arrow = flag
			self.equip_up_t[k].image.enabled = is_up_arrow
			if v.item_id > 0 then
				self.equip_t[k]:ListenClick(BindTool.Bind(self.EquipClick, self, k, self.equip_t[k]))
			end
		end
	else
		for k,v in pairs(self.equip_t) do
			flag = ShenShouData.Instance:GetHasBetterShenShouEquip(nil, self.select_shou_id, k)
			local is_up_arrow = flag
			self.equip_up_t[k].image.enabled = is_up_arrow
			v.root_node:SetActive(false)
			self.plus_t[k]:SetActive(true)
		end
	end

	local other_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").other[1]
	local extra_zhuzhan_count = ShenShouData.Instance:GetExtraZhuZhanCount()
	local zhuzhan_num = ShenShouData.Instance:GetZhuZhanNum()
	self.node_list["TxtBtnAdd"].text.text = Language.ShenShou.ZhuZhan .. "：" .. zhuzhan_num .. " / " .. extra_zhuzhan_count + other_cfg.default_zhuzhan_count

	local shou_cfg = ShenShouData.Instance:GetShenShouCfg(self.select_shou_id)
	if next(shou_cfg) then
		if self.model_id ~= shou_cfg.model_id then
			local bundle, asset = ResPath.GetLongqiModel(shou_cfg.model_id)
			self.model_view:SetMainAsset(bundle, asset)
			self.model_id = shou_cfg.model_id
		end
	else
		self.model_view:ClearModel()
	end
	local is_zhuzhan = ShenShouData.Instance:IsShenShouZhuZhan(self.select_shou_id)
	local btn_text = is_zhuzhan and Language.ShenShou.ZhaoHui or Language.ShenShou.ZhuZhan
	self.node_list["TxtBtnFight"].text.text = btn_text

	local btn_text = is_zhuzhan and Language.ShenShou.YiJianXieXia or Language.ShenShou.EquipBag
	self.node_list["TextBag"].text.text = btn_text
	
	local shenshou_list = ShenShouData.Instance:GetShenshouList(self.select_shou_id)
	local num = 0
	if shenshou_list then
		for k, v in pairs(shenshou_list.equip_list) do
			if v.item_id > 0 then
				num = num + 1
			end
		end
	end
	local is_full_chuzhan = ShenShouData.Instance:IsFullZhuZhan()
	self.node_list["RedPoint"]:SetActive(num >= 5 and not is_zhuzhan and not is_full_chuzhan)
	
	local shenshou_base_struct = CommonDataManager.GetAttributteByClass(shou_cfg)
	local eq_struct = ShenShouData.Instance:GetOneShenShouAttr(self.select_shou_id)
	local attr_keys = CommonDataManager.GetAttrKeyList()
	local base_content = ""

	local index = 0
	for k, v in pairs(attr_keys) do
		local shou_base_value = math.floor(shenshou_base_struct[v])
		local eq_add_value = math.floor(eq_struct[v])
		local attr_name = Language.Common.AttrName[v]
		if attr_name and shou_base_value > 0 then
			index = index + 1
			if self.attr_t[index] then
				self.attr_t[index].attr:SetActive(true)
				local all_attr_num = shou_base_value + eq_add_value
				self.attr_t[index].attr.text.text = "<color=#d0d8ff>" .. attr_name .. "：</color>" .. all_attr_num
			end
		end
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = self.data[self.select_shou_id].zonghe_pingfen
	end
	for i = index + 1, 4 do
		self.attr_t[i].attr:SetActive(false)
		self.attr_t[i].attr.text.text = ""
	end

	local skill_list = ShenShouData.Instance:GetOneShouSkill(self.select_shou_id)
	for k,v in pairs(self.skill_t) do
		if skill_list[k - 1] then
			v:SetIsActive(is_active)
			v:SetData(skill_list[k - 1])
		end
		if v.root_node then
			v.root_node:SetActive(skill_list[k - 1] ~= nil)
		end
	end
end

------------------------------------------------------------------
ShenShouSkillItem = ShenShouSkillItem or BaseClass(BaseCell)

function ShenShouSkillItem:__init()
	self.node_list["ShenshouSkillItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ShenShouSkillItem:__delete()
	self.is_active = nil
end

function ShenShouSkillItem:SetIsActive(is_active)
	self.is_active = is_active
end

function ShenShouSkillItem:OnFlush(param_t)
	self.root_node:SetActive(self.data ~= nil)
	if not self.data then return end

	self.node_list["TxtLevel"].text.text = ""

	local skill_cfg = ShenShouData.Instance:GetShenShouSkillCfg(self.data.skill_type, self.data.level)
	if nil == skill_cfg then return end

	local bundle, asset = ResPath.GetShenShouSkillIcon(skill_cfg.icon_id)
	self.node_list["ImgSkill"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["TxtLevel"].text.text = skill_cfg.description_2
	
	if self.data.skill_type == 28 or self.data.skill_type == 29 or self.data.skill_type == 30 then 	
		-- 这里写死这些技能是加百分比的
		local attr = {}
		if self.data.skill_type == 28 then
			attr.gedang_per = skill_cfg.param_1
		elseif self.data.skill_type == 29 then
			attr.mingzhong_per = skill_cfg.param_1
		elseif self.data.skill_type == 30 then
			attr.per_pofang = skill_cfg.param_1
		else
			return
		end
		local cap = CommonDataManager.GetCapability(attr)
		if cap > 0 and self.is_active then
			self.node_list["SkillCapBg"]:SetActive(true)
			self.node_list["SkillCap"].text.text = string.format(Language.Common.GaoZhanLi, cap)
			self.node_list["icon_percent"]:SetActive(false)
		else
			self.node_list["SkillCapBg"]:SetActive(false)
			self.node_list["SkillCap"].text.text = ""
			self.node_list["icon_percent"]:SetActive(true)
		end
	else
		self.node_list["SkillCapBg"]:SetActive(false)
		self.node_list["icon_percent"]:SetActive(false)
	end
end

function ShenShouSkillItem:SetIconParcent(enabled)
	self.node_list["icon_percent"]:SetActive(enabled)
end

-----------------------------------------------------------------

ShenShouItem = ShenShouItem or BaseClass(BaseCell)

function ShenShouItem:__init()
	self.root_node.toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.root_node.toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleClick, self))

	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, 0)
	self.model_id = 0
end

function ShenShouItem:OnToggleClick()
	self:TextState()
end

function ShenShouItem:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
	end
	self.model_id = nil
end

function ShenShouItem:SetToggleGroup(group)
  	self.root_node.toggle.group = group
end

function ShenShouItem:SetToggle(value)
  	self.root_node.toggle.isOn = value
end

function ShenShouItem:SetIndex(index)
	self.index = index
end

function ShenShouItem:GetIndex()
	 return self.index
end

function ShenShouItem:OnFlush(param_t)
	if not self.data then return end
	self.node_list["TxtName"].text.text = string.format("<color=%s>%s</color>", ITEM_TIP_COLOR[self.data.quality], self.data.name)
	self.node_list["ImgFlag"]:SetActive(self.data.has_zhuzhan)
	self.node_list["ImgRemind"]:SetActive(self.data.show_remind_bg)

	local is_active = ShenShouData.Instance:IsShenShouActive(self.data.shou_id)
	UI:SetGraphicGrey(self.node_list["ImgBg"], not is_active)

	self:TextState()

	local shou_cfg = ShenShouData.Instance:GetShenShouCfg(self.data.shou_id)
	if next(shou_cfg) then
		if self.model_id ~= shou_cfg.model_id then
			local bundle, asset = ResPath.GetLongqiModel(shou_cfg.model_id)
			self.model_view:SetMainAsset(bundle, asset)
			self.model_id = shou_cfg.model_id
		end
	end

	local is_show, _, cfg = DisCountData.Instance:IsOpenYiZheAllBySystemId(Sysetem_Id_Jump.Long_Qi)
	self.node_list["XianShiImg"]:SetActive(false)
	if is_show and cfg and cfg.system_index then
		for k, v in pairs(cfg.system_index) do
			local index_list = Split(v, "|")
			for k, v in pairs(index_list) do
				if tonumber(v) == self.index then
					self.node_list["XianShiImg"]:SetActive(true)
					break
				end
			end
		end
	end
end

function ShenShouItem:TextState()
	if not self.data then return end

	local color = self.root_node.toggle.isOn and "#FFFFFF" or "#FFFFFF"
	self.node_list["TxtCap"].text.text = "<color='" .. color .. "'>" .. Language.Wing.ZhanDouLi .. self.data.zonghe_pingfen .. "</color>"
end

function ShenShouItem:FlushRemind()
	local is_show = ShenShouData.Instance:GetShenShouIsShowRemindImg(self.data.shou_id)
	self.node_list["ImgRemind"]:SetActive(is_show)

	local is_zhuzhan = ShenShouData.Instance:IsShenShouZhuZhan(self.data.shou_id)
	self.node_list["ImgFlag"]:SetActive(is_zhuzhan)
end