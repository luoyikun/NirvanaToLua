require("game/activity/activity_daily_view")
require("game/activity/activity_battle_view")
require("game/activity/activity_kuafu_battle_view")

ActivityView = ActivityView or BaseClass(BaseView)

function ActivityView:UIsMove()
	UITween.MoveShowPanel(self.node_list["ActivityPanel"] , Vector3(376 , 8 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["ActivityPanel"] , true , MOVE_TIME , DG.Tweening.Ease.Linear )
end

function ActivityView:__init()
	self.full_screen = true								-- 是否是全屏界面
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/activityview_prefab", "ActivityView"},
		{"uis/views/activityview_prefab", "ActivityPanel", {TabIndex.activity_daily}},
		{"uis/views/activityview_prefab", "BattlePanel", {TabIndex.activity_battle}},
		{"uis/views/activityview_prefab", "KuaFuBattlePanel", {TabIndex.activity_kuafu_battle}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.play_audio = true
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
end

function ActivityView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function ActivityView:ReleaseCallBack()
	if self.daily_view then
		self.daily_view:DeleteMe()
		self.daily_view = nil
	end

	if self.battle_view then
		self.battle_view:DeleteMe()
		self.battle_view = nil
	end

	if self.kuafu_battle_view then
		self.kuafu_battle_view:DeleteMe()
		self.kuafu_battle_view = nil
	end

	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}

	-- 清理变量和对象

	self.wing_start_up = nil

	self.content = nil
		if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function ActivityView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Activity.TabbarName[1],  bundle = "uis/images_atlas", asset = "tab_icon_activity", tab_index = TabIndex.activity_daily, func = BindTool.Bind(self.IsOpenFunDailyView, self)},
		{name = Language.Activity.TabbarName[2],  bundle = "uis/images_atlas", asset = "tab_icon_battle", tab_index = TabIndex.activity_battle, func = BindTool.Bind(self.IsOpenFunBattleView, self)},
		{name = Language.Activity.TabbarName[3],  bundle = "uis/images_atlas", asset = "tab_icon_kuafu", tab_index = TabIndex.activity_kuafu_battle, func = BindTool.Bind(self.IsOpenFunKuaFuBattleView, self)},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["TxtTitle"].text.text = Language.Activity.TitleName

	--右边的滚动描述，滚动框控制
	self.content = self.node_list["Content"]
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	self.node_list["BtnJoin"].button:AddClickListener(BindTool.Bind(self.ClickPart,self))

	--获取组件 奖励物品
	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["item_reward_" .. i])
		item:SetShowOrangeEffect(true)
		item:SetData(nil)
		table.insert(self.item_list, item)
	end

end

function ActivityView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function ActivityView:IsOpenFunDailyView()
	if OpenFunData.Instance:CheckIsHide("activity_daily") then
		local count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.normal)
		return count > 0
	end
	return false
end

function ActivityView:IsOpenFunBattleView()
	if OpenFunData.Instance:CheckIsHide("activity_battle") then
		local count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.battle_field)
		return count > 0
	end
	return false
end

function ActivityView:IsOpenFunKuaFuBattleView()
	if OpenFunData.Instance:CheckIsHide("activity_kuafu_battle") then
		local count = ActivityData.Instance:GetClockActivityCountByType(ActivityData.Act_Type.kuafu_battle_field)
		return count > 0
	end
	return false
end

function ActivityView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	self:UIsMove()
	if nil ~= index_nodes then
		if index == TabIndex.activity_daily then
			self.daily_view = ActivityDailyView.New(index_nodes["ActivityPanel"])
		elseif index == TabIndex.activity_battle then
			self.battle_view = ActivityBattleView.New(index_nodes["BattlePanel"])
		elseif index == TabIndex.activity_kuafu_battle then
			self.kuafu_battle_view = ActivityKuaFuBattleView.New(index_nodes["KuaFuBattlePanel"])
		end
	end

	local act_info1 = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.normal)
	local act_info2 = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.battle_field)
	local act_info3 = ActivityData.Instance:GetClockActivityByType(ActivityData.Act_Type.kuafu_battle_field)
	if index == TabIndex.activity_daily and act_info1[1] then
		self.daily_view:OpenCallBack()
		self.daily_view:UIsMove()
		ActivityCtrl.Instance:SetDetailData(act_info1[1])
	elseif index == TabIndex.activity_battle and act_info2[1] then
		self.battle_view:OpenCallBack()
		self.battle_view:UIsMove()
		ActivityCtrl.Instance:SetDetailData(act_info2[1])
	elseif index == TabIndex.activity_kuafu_battle and act_info3[1] then
		self.kuafu_battle_view:OpenCallBack()
		self.kuafu_battle_view:UIsMove()
		ActivityCtrl.Instance:SetDetailData(act_info3[1])
	end
end

function ActivityView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ActivityView:ClickPart()
	ActivityCtrl.Instance:ClickPart(true)
end


function ActivityView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold")
	self:PlayerDataChangeCallback("bind_gold")
	self:Flush()
end



function ActivityView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function ActivityView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function ActivityView:HandleClose()
	ViewManager.Instance:Close(ViewName.Activity)
end

function ActivityView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "daily" then
			self.daily_view:FlushDaily()
		elseif k == "battle" then
			self.battle_view:FlushBattle()
		elseif k == "kuafu_battle" then
			self.kuafu_battle_view:FlushKuaFuBattle()
		end
	end
end


--设置右边详细数据
function ActivityView:SetDetailData(data)
	if data == nil then
		return
	end
	self.node_list["TxtActivityTitle"].text.text = data.act_name
	self.node_list["TxtActivityDec"].text.text = data.play_introduction
	local tab_list = Split(data.item_label, ":")
	for k, v in ipairs(self.item_list) do
		if tab_list[k] then
			tab_list[k] = tonumber(tab_list[k])
		end
		v:SetData(nil)
		if data["reward_item" .. k] and next(data["reward_item" .. k]) and data["reward_item" .. k].item_id ~= 0 then
			self.node_list["item_reward_" .. k]:SetActive(true)
			v:SetShowVitualOrangeEffect(true)
			v:SetData(data["reward_item" .. k])
			if tab_list[k]then
				v:SetShowZhuanShu(tab_list[k] == 1)
			end
		else
			self.node_list["item_reward_" .. k]:SetActive(false)
		end
	end
end

-------------------------------------动态生成左边滚动信息条-----------------------------------------

ActivityViewScrollCell = ActivityViewScrollCell or BaseClass(BaseCell)
function ActivityViewScrollCell:__init()
	--点击每个活动item
	self.node_list["ActivityItem"].toggle:AddValueChangedListener(BindTool.Bind(self.ClickItem, self))
	
	self.parent_view = nil
end

function ActivityViewScrollCell:__delete()
	self.count_down = nil
	self.activity_name = nil
	self.part_lv = nil
	self.parent_view = nil
end

function ActivityViewScrollCell:OnFlush()

	local open_day_list = Split(self.data.open_day, ":")
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	local server_time_str = os.date("%H:%M", server_time)
	if now_weekday == 0 then now_weekday = 7 end
	local time_str = ""

	self.node_list["End"]:SetActive(false)
	self.node_list["ImgNotStart"]:SetActive(false)
	self.node_list["ImgStart"]:SetActive(false)
	self.node_list["ImgReady"]:SetActive(false)

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local real_min_level, real_max_level = ActivityData.Instance:GetRealLevelLimit(self.data.act_id)
	self.data.min_level = real_min_level
	self.data.max_level = real_max_level
	if self.data.min_level > role_level then
		local temp = self.data.min_level/100
		local value = math.floor(temp)
		local temp_val = value
		if 0 == temp_val then
			temp_val = 1
		end
		local temp_level = 100
		if temp > value then
			temp_level = self.data.min_level%(temp_val*100)
		else
			value = value - 1
		end
		time_str = string.format(Language.Activity.LevelOpen,temp_level,value)
		self.node_list["Mask"]:SetActive(true)
	elseif self.data.max_level < role_level then
		self.node_list["Mask"]:SetActive(true)
		self.node_list["End"]:SetActive(true)
		self.node_list["TxtActivityCD"].text.text = ToColorStr(Language.Activity.ActivityArriveMaxLelvel, TEXT_COLOR.RED) 
	else
		local though_time = true
		local is_today_open = false
		for _, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				is_today_open = true
				local open_time_tbl = Split(self.data.open_time, "|")
				local open_time_str = open_time_tbl[1]
				local end_time_tbl = Split(self.data.end_time, "|")
				local end_time_str = end_time_tbl[1]

				for k2, v2 in ipairs(end_time_tbl) do
					if v2 > server_time_str then
						though_time = false
						open_time_str = open_time_tbl[k2]
						end_time_str = v2
						break
					end
				end
				time_str = open_time_str .. "-" .. end_time_str
				break
			end
		end

		if ActivityData.Instance:IsAchieveLevelInLimintConfigById(self.data.act_id) or self.data.act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI then
			local cfg = ActivityData.Instance:GetActivityConfig(self.data.act_id) or {}
				self.node_list["Mask"]:SetActive(false)
			if ActivityData.Instance:GetActivityIsOpen(self.data.act_id) or cfg.is_allday == 1 then
				self.node_list["ImgStart"]:SetActive(true)
			elseif ActivityData.Instance:GetActivityIsReady(self.data.act_id) then  --添加活动准备中
				self.node_list["ImgReady"]:SetActive(true)
			elseif is_today_open and not though_time then
				self.node_list["ImgNotStart"]:SetActive(true)
			else
				self.node_list["Mask"]:SetActive(true)
				self.node_list["End"]:SetActive(true)
			end
		else
			self.node_list["Mask"]:SetActive(true)
			self.node_list["ImgNotStart"]:SetActive(false)
			self.node_list["ImgReady"]:SetActive(false)
			self.node_list["ImgStart"]:SetActive(false)
			self.node_list["End"]:SetActive(true)
		end

		-- if self.data.act_id == ACTIVITY_TYPE.SHUIJING or self.data.act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS then		--对特定活动进行日期区间限制
		-- 	if not is_today_open then
		-- 		self.node_list["ImgStart"]:SetActive(false)
		-- 		self.node_list["ImgReady"]:SetActive(false)
		-- 		self.node_list["ImgNotStart"]:SetActive(false)
		-- 		self.node_list["Mask"]:SetActive(true)
		-- 		self.node_list["End"]:SetActive(true)
		-- 	end
		-- end


		if not is_today_open then
			local str = Language.Common.Week
			for i = 1, #open_day_list do
				local day = tonumber(open_day_list[i])
				day = Language.Common.DayToChs[day] or ""
				str = str .. day
				if i ~= #open_day_list then
					str = str .. "、"
				end
			end
			time_str=str..Language.Common.Open
		end
	end
	if time_str ~= "" then
		self.node_list["TxtActivityCD"].text.text = string.format(Language.Activity.ActivityViewCD, time_str)
	end

	self.node_list["TxtActivityName"].text.text = self.data.act_name
	local minest_level = ActivityData.Instance:GetMinestLevelLimit(self.data.act_id)
	if minest_level then
		self.node_list["TxtActivityPartLV"].text.text = string.format(Language.Activity.ActivityPartLV, minest_level)
	end
	if self.data.max_level < role_level then
		self.node_list["TxtActivityPartLV"].text.text = string.format(Language.Activity.ActivityPartLV2, self.data.min_level, self.data.max_level)
	end


	local bundle, asset = ResPath.GetActivityRawimage(self.data.act_type, self.data.act_id)
	self.node_list["Bg"].raw_image:LoadSprite(bundle, asset)

	if nil ~= self.parent_view then
		local parent_select_index = self.parent_view:GetSelectIndex()
		local index = self:GetIndex()
		if parent_select_index == index then
			self.root_node.toggle.isOn = true
		else
			self.root_node.toggle.isOn = false
		end
	end
	--角标 以后加

end

function ActivityViewScrollCell:ClickItem()
	if nil ~= self.parent_view then
		self.parent_view:SetSelectIndex(self:GetIndex())
	end
	if self.root_node.toggle.isOn then
		ActivityCtrl.Instance:SetDetailData(self.data)
	end
end

function ActivityViewScrollCell:SetParentView(parent_view)
	self.parent_view = parent_view
end