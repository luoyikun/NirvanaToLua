CityCombatView = CityCombatView or BaseClass(BaseView)

function CityCombatView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		-- {"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/citycombatview_prefab", "CityCombatView"},
		-- {"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.is_modal = true
	self.full_screen = true
	self.play_audio = true

	self.left_title = 0
	self.right_title = 0
end

function CityCombatView:__delete()

end

function CityCombatView:ReleaseCallBack()
	if self.cz_item_cell_list then
		for k,v in pairs(self.cz_item_cell_list) do
			v:DeleteMe()
		end
	end
	self.cz_item_cell_list = nil

	if self.cy_item_cell_list then
		for k,v in pairs(self.cy_item_cell_list) do
			v:DeleteMe()
		end
	end
	self.cy_item_cell_list = nil
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.wife_model then
		self.wife_model:DeleteMe()
		self.wife_model = nil
	end
end

function CityCombatView:LoadCallBack()
	-- self.node_list["TitleText"].text.text = Language.Activity.DailyActTips6
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnTeQuan"].button:AddClickListener(BindTool.Bind(self.OpenTip, self))
	self.node_list["BtnMobai"].button:AddClickListener(BindTool.Bind(self.ClickWorship, self))
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.ClickExchange, self))
	self.node_list["RoleTitleBtn"].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, 1))
	self.node_list["WifeTitleBtn"].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, 2))
	self.node_list["CollectiveReward"].button:AddClickListener(BindTool.Bind(self.OpenCollectiveRewardCfg, self))
	self.cz_item_cell_list = {}
	for i = 1, 4 do
		self.cz_item_cell_list[i] = ItemCell.New()
		self.cz_item_cell_list[i]:SetInstanceParent(self.node_list["ItemChengZhu" .. i])
		self.cz_item_cell_list[i]:SetActive(false)
	end
	local event_trigger = self.node_list["RotateEventTriggerMan"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragMan, self))

	local event_trigger = self.node_list["RotateEventTriggerWoman"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragWoman, self))
	self.cy_item_cell_list = {}
	for i = 1, 2 do
		self.cy_item_cell_list[i] = ItemCell.New()
		self.cy_item_cell_list[i]:SetInstanceParent(self.node_list["ItemNormal" .. i])
		self.cy_item_cell_list[i]:SetActive(false)
	end
end

function CityCombatView:OpenCallBack()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function CityCombatView:CloseCallBack()
	if self.role_info then
		GlobalEventSystem:UnBind(self.role_info)
		self.role_info = nil
	end
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function CityCombatView:OnRoleDragMan(data)
	local role_info = CityCombatData.Instance:GetCityOwnerRoleInfo()
	if role_info and role_info.sex == 0 then
		if self.wife_model then
			self.wife_model:Rotate(0, -data.delta.x * 0.25, 0)
		end
	else
		if self.role_model then
			self.role_model:Rotate(0, -data.delta.x * 0.25, 0)
		end
	end
end

function CityCombatView:OnRoleDragWoman(data)
	local role_info = CityCombatData.Instance:GetCityOwnerRoleInfo()
	if role_info and role_info.sex == 0 then
		if self.role_model then
			self.role_model:Rotate(0, -data.delta.x * 0.25, 0)
		end
	else
		if self.wife_model then
			self.wife_model:Rotate(0, -data.delta.x * 0.25, 0)
		end
	end
end

function CityCombatView:ClickExchange()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_shengwang)
end
function CityCombatView:CloseWindow()
	self:Close()
end

function CityCombatView:ClickWorship()
	CityCombatCtrl.Instance:GoWorship()
end

function CityCombatView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GONGCHENGZHAN)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function CityCombatView:ClickEnter()
	local act_info = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GONGCHENGZHAN)
	if not next(act_info) then return end

	if GameVoManager.Instance:GetMainRoleVo().level < act_info.min_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.JoinEventActLevelLimit, act_info.min_level))
		return
	end

	local act_is_ready = ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.GONGCHENGZHAN)
	local act_is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENGZHAN)
	if not act_is_ready and not act_is_open then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.GONGCHENGZHAN, 0)
	ViewManager.Instance:CloseAll()
end

function CityCombatView:FlushReward()
	local other_config = CityCombatData.Instance:GetOtherConfig()
	if nil == other_config then
		return
	end
	for k,v in pairs(other_config.cz_reward_item) do
		if v.item_id > 0 then
			if self.cz_item_cell_list[k + 1] then
				self.cz_item_cell_list[k + 1]:SetActive(true)
				self.cz_item_cell_list[k + 1]:SetData(v)
			end
		end
	end
	for k,v in pairs(other_config.cy_reward_item) do
		if v.item_id > 0 then
			if self.cy_item_cell_list[k + 1] then
				self.cy_item_cell_list[k + 1]:SetActive(true)
				self.cy_item_cell_list[k + 1]:SetData(v)
			end
		end
	end
end

function CityCombatView:FlushTuanZhangModel()
	local own_info = CityCombatData.Instance:GetCityOwnerInfo()
	local role_info = CityCombatData.Instance:GetCityOwnerRoleInfo()
	local other_cfg = CityCombatData.Instance:GetOtherConfig()
	if nil ~= role_info  then
		local res_id = 0
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == other_cfg.cz_fashion_yifu_id then
				res_id = v["resouce" .. (role_info.prof % 10) .. role_info.sex]
			end
		end
		local weapon_res_id, weapon2_res_id = CityCombatData.Instance:GetWeaponUse(role_info)
		if not self.role_model then
			self.role_model = RoleModel.New()
			if  role_info.sex == 0 then
				self.role_model:SetDisplay(self.node_list["RoleWifeDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
				self.node_list["TxtWifeName"].text.text = role_info.role_name
				self.node_list["RoleWifeDisplay"]:SetActive(true)
				self.node_list["ImgWife"]:SetActive(false)
			else
				self.role_model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
				self.node_list["TxtHuizhangName"].text.text = role_info.role_name
				self.node_list["RoleDisplay"]:SetActive(true)
				self.node_list["ImgChengZhu"]:SetActive(false)
			end
			
			self.role_model:SetModelResInfo(role_info, false, true, true)
			self.role_model:SetRoleResid(res_id)
			self.role_model:SetWeaponResid(weapon_res_id or 0)
			self.role_model:SetWeapon2Resid(weapon2_res_id or 0)
		end
		if other_cfg then
			local title_node_1 = nil
			if role_info.sex == 0 then
				self.right_title = other_cfg.cz_chenghao
				title_node_1 = self.node_list["ImgWifeTitle"]
			else
				self.left_title = other_cfg.cz_chenghao
				title_node_1 = self.node_list["ImgHuizhangTitle"]
			end
			title_node_1.image:LoadSprite(ResPath.GetTitleIcon(other_cfg.cz_chenghao))
			TitleData.Instance:LoadTitleEff(title_node_1, other_cfg.cz_chenghao, true)
		end
	end

	local lover_info = CityCombatData.Instance:GetLoverRoleInfo()
	if nil ~= lover_info then
		--self.node_list["RoleWifeInfo"]:SetActive(true)
		self.node_list["RoleWifeDisplay"]:SetActive(true)
		self.node_list["ImgWife"]:SetActive(false)
		local res_id = 0
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == other_cfg.cz_lover_fashion_yifu_id then
				res_id = v["resouce" .. (lover_info.prof % 10) .. lover_info.sex]
			end
		end
		local weapon_res_id2, weapon2_res_id2 = CityCombatData.Instance:GetWeaponUse(lover_info)

		if not self.wife_model then
			self.wife_model = RoleModel.New()
			if lover_info.sex == 0 then
				self.wife_model:SetDisplay(self.node_list["RoleWifeDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
				self.node_list["TxtWifeName"].text.text = lover_info.role_name
				self.node_list["RoleWifeDisplay"]:SetActive(true)
				self.node_list["ImgWife"]:SetActive(false)
				-- self.node_list["HuiZhangWifeName"]:SetActive(true)
			else
				self.wife_model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
				self.node_list["TxtHuizhangName"].text.text = lover_info.role_name
				self.node_list["RoleDisplay"]:SetActive(true)
				self.node_list["ImgChengZhu"]:SetActive(false)
				-- self.node_list["ImgHuiZhangName"]:SetActive(true)
			end

			self.wife_model:SetModelResInfo(lover_info, false, true, true)
			self.wife_model:SetRoleResid(res_id)
			self.wife_model:SetWeaponResid(weapon_res_id2 or 0)
			self.wife_model:SetWeapon2Resid(weapon2_res_id2 or 0)
		end
		if other_cfg then
			local title_id = GameEnum.FEMALE == lover_info.sex and other_cfg.cz_wife_title_id or other_cfg.cz_husband_title_id
			local title_node = nil
			if lover_info.sex == 0 then
				self.right_title = title_id
				title_node = self.node_list["ImgWifeTitle"]
			else
				self.left_title = title_id
				title_node = self.node_list["ImgHuizhangTitle"]
			end
			title_node.image:LoadSprite(ResPath.GetTitleIcon(title_id or 0))
			TitleData.Instance:LoadTitleEff(title_node, title_id or 0, true)
		end
		
	end
end

function CityCombatView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.GONGCHENGZHAN)
	if not next(act_info) then return end

	self.open_day_list = Split(act_info.open_day, ":")

	self:SetTitleTime(act_info)

	local own_info = CityCombatData.Instance:GetCityOwnerInfo()
	if own_info and own_info.guild_id and own_info.guild_id > 0 and own_info.owner_id > 0 then
		self.node_list["HuiZhangWifeName"]:SetActive(true)
		self.node_list["ImgHuiZhangName"]:SetActive(true)

		-- self.node_list["RoleWifeDisplay"]:SetActive(own_info.sex == 0)
		-- self.node_list["RoleDisplay"]:SetActive(not (own_info.sex == 0))
		-- self.node_list["ImgWife"]:SetActive(not (own_info.sex == 0))
		-- self.node_list["ImgChengZhu"]:SetActive(own_info.sex == 0)

		if own_info.sex == 0 then
			self.node_list["TxtWifeName"].text.text = own_info.owner_name
		else
			self.node_list["TxtHuizhangName"].text.text = own_info.owner_name
		end

		local guild_info = GuildData.Instance:GetGuildInfoById(own_info.guild_id)
		if guild_info then
			self.node_list["TxtGuildName"].text.text = guild_info.guild_name
		end
	else
		local game_vo = GameVoManager.Instance:GetMainRoleVo()
		--self.node_list["ImgHuiZhangName"]:SetActive(false)
		self.node_list["RoleDisplay"]:SetActive(false)
		self.node_list["ImgChengZhu"]:SetActive(true)
		--self.node_list["RoleWifeInfo"]:SetActive(false)
		self.node_list["RoleWifeDisplay"]:SetActive(false)
		self.node_list["ImgWife"]:SetActive(true)
		self.node_list["TxtHuizhangName"].text.text = Language.KuafuGuildBattle.KfNoOccupy
		self.node_list["TxtGuildName"].text.text = Language.Common.ZanWu
	end

	local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP)
	self.node_list["Effects"]:SetActive(is_act_open)
	self.node_list["TxtMoBaiTime"]:SetActive(not is_act_open)
	self.node_list["TxtMoBaiOpen"]:SetActive(is_act_open)
	self:FlushTuanZhangModel()
	self:FlushReward()
	local score_type = EXCHANGE_PRICE_TYPE.SHENGWANG
	local nume = CommonDataManager.ConverMoney(ExchangeData.Instance:GetCurrentScore(score_type))
	self.node_list["TxtShengWang"].text.text = nume
end

function CityCombatView:SetTitleTime(act_info)
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENGZHAN)
	self.node_list["TxtDay"]:SetActive(not is_open)
	self.node_list["TxtTitle"]:SetActive(not is_open)
	self.node_list["TxtHasOpen"]:SetActive(is_open)

	self.node_list["TxtDay"].text.text = ActivityData.Instance:GetCurServerOpenDayText(ACTIVITY_TYPE.GONGCHENGZHAN, act_info) or ""
end

function CityCombatView:ActivityCallBack(activity_type)
	if activity_type == ACTIVITY_TYPE.GONGCHENGZHAN then
		self:Flush()
	end
end

function CityCombatView:OpenCollectiveRewardCfg()
	local other_cfg = CityCombatData.Instance:GetOtherConfig()
	local team_main_reward_list = {}
	local team_other_reward_list = nil
	if other_cfg and other_cfg.team_reward_item and other_cfg.team_reward_item[0] then
		for i = 1, other_cfg.team_reward_item[0].num do
			team_main_reward_list[i] = {}
			team_main_reward_list[i] = {item_id = other_cfg.team_reward_item[0].item_id, num = 1, other_cfg.team_reward_item[0].is_bind}
		end
	end

	TipsCtrl.Instance:OpenJiTiRewardTip(team_main_reward_list, team_other_reward_list, ACTIVITY_TYPE.GONGCHENGZHAN)
end

function CityCombatView:OpenTip()
	local level = CityCombatData.Instance:GetTeQuanLevel()
	local hefu_info = CityCombatData.Instance:GetHefuCfg().other[1]
	local name = Language.HeFuCombatTip.City_Master
	local tequan_level = level
	local max_level = hefu_info.gcz_sepcial_attr_add_limit / hefu_info.gcz_sepcial_attr_add
	local asset, bunble = ResPath.GetHeFuCityRes("Icon_tip")
	local now_des = ""
	local next_des = ""
	
	if level > 0 then
		now_des = string.format(Language.HeFuCombatTip.Tequan_Info, hefu_info.gcz_sepcial_attr_add / 100 * level.."%")
	else
		now_des = Language.HeFuCombatTip.No_Level
	end

	if level < max_level then
		next_des = string.format(Language.HeFuCombatTip.Tequan_Info, hefu_info.gcz_sepcial_attr_add / 100 * (level + 1).."%")
	else
		next_des = Language.HeFuCombatTip.Max_Level
	end

	CityCombatCtrl.Instance:ShowTequanTips(name, tequan_level, now_des, next_des, asset, bunble)
end

local item_cfg = {
	[3000] = 22218, -- 城主称号
	[3006] = 24888, -- 城主夫人称号
	[3007] = 24889, -- 城主夫君称号
}

function CityCombatView:ClickTitle(index)
	local item_num = 0
	if index == 1 then
		item_num = item_cfg[self.left_title] or 0
		if item_num > 0 then
			local data = {item_id = item_num, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	else
		item_num = item_cfg[self.right_title] or 0
		if item_num > 0 then
			local data = {item_id = item_num, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end
end