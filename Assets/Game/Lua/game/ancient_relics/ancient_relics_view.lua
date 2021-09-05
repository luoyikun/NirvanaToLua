AncientRelicsView = AncientRelicsView or BaseClass(BaseView)

function AncientRelicsView:__init()
	self.ui_config = {{"uis/views/ancientrelics_prefab", "AncientRelicsInfoView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true

	self.role_change_callback = BindTool.Bind(self.RoleChangeCallBack, self)
end

function AncientRelicsView:LoadCallBack()

	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.AddGatherCount, self))


	self.cur_gather_count = ""
	self.max_gather_count = ""

	self.item_name_1 = Language.AncientRelics.ItemName1
	self.item_name_2 = Language.AncientRelics.ItemName2
	self.item_name_3 = Language.AncientRelics.ItemName3
	self.item_color_1 = "#00aaff"
	self.item_color_2 = "#aa00ff"
	self.item_color_3 = "#ffaa00"
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function AncientRelicsView:__delete()
	self.cur_gather_count = nil
	self.max_gather_count = nil
	self.cur_color = nil
end

function AncientRelicsView:AddGatherCount()
	local function ok_callback()
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_BUY_GATHER_TIME)
	end
	local other_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto").other[1]
	local str = string.format(Language.AncientRelics.BuyGatherTips, other_cfg.buy_day_gather_num_cost)
	TipsCtrl.Instance:ShowCommonAutoView("ancient_relics_gather_times", str, ok_callback)
end

function AncientRelicsView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	self.show_panel = nil
	self.leave_stone = nil
	self.cur_gather_count = nil
	self.max_gather_count = nil
	self.nomal_count = nil
	self.better_count = nil
	self.best_count = nil
	self.cur_color = nil
	self.next_time = nil
	self.item_name_1 = nil
	self.item_name_2 = nil
	self.item_name_3 = nil
	self.item_color_1 = nil
	self.item_color_2 = nil
	self.item_color_3 = nil
	self.show_tips = nil
end

function AncientRelicsView:OpenCallBack()
	PlayerData.Instance:ListenerAttrChange(self.role_change_callback)

	self:Flush()
end

function AncientRelicsView:CloseCallBack()
	PlayerData.Instance:UnlistenerAttrChange(self.role_change_callback)
end

function AncientRelicsView:RoleChangeCallBack(key, value, old_value)
	if key == "vip_level" then
		if value > 0 then
			self.node_list["TxtShowTips"]:SetActive(false)
		else
			self.node_list["TxtShowTips"]:SetActive(true)
		end
	end
end

function AncientRelicsView:SwitchButtonState(enable)
	self.node_list["NodeTaskParent"]:SetActive(enable)
end

function AncientRelicsView:OnFlush(param_t)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.vip_level > 0 then
		self.node_list["TxtShowTips"]:SetActive(false)
	else
		self.node_list["TxtShowTips"]:SetActive(true)
	end

	local info = AncientRelicsData.Instance:GetInfo()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto").other[1]
	self.node_list["TxtLeaveStone"].text.text = string.format(Language.AncientRelics.leaveStone, info.scene_leave_num)
	self.cur_gather_count = info.today_gather_times
	local total_count = other_cfg.role_day_gather_num + info.today_buy_gather_times
	self.max_gather_count = total_count
	self.nomal_count = info.normal_item_num
	self.node_list["TxtNormalCount"].text.text = string.format("<color=%s>%s</color>:<color=#32d45e>%s</color>", self.item_color_1, self.item_name_1, self.nomal_count)
	self.better_count = info.rare_item_num
	self.node_list["TxtBetterCount"].text.text = string.format("<color=%s>%s</color>:<color=#32d45e>%s</color>", self.item_color_2, self.item_name_2, self.better_count)
	self.best_count = info.unique_item_num
	self.node_list["TxtBestCount"].text.text = string.format("<color=%s>%s</color>:<color=#32d45e>%s</color>", self.item_color_3, self.item_name_3, self.best_count)
	self.cur_color = info.today_gather_times < total_count and "#32d45e" or "#ff0000"
	self.node_list["TxtGatherCount"].text.text = string.format(Language.AncientRelics.GatherCountHave, self.cur_color, self.cur_gather_count, self.max_gather_count)
	if self.next_timer == nil then
		self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	end
	local gather_reward_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto").gather_reward
	for i = 1, 3 do
		if gather_reward_cfg[i] and gather_reward_cfg[i].gather_reward[0] then
			local item = gather_reward_cfg[i].gather_reward[0]
			local item_cfg = ItemData.Instance:GetItemConfig(item.item_id)
			if item_cfg then
				-- self["item_name_" .. i].text.text = item_cfg.name
				-- self["item_color_" .. i].text.text = ITEM_COLOR[item_cfg.color] or ITEM_COLOR[1]
			end
		end
	end
end

function AncientRelicsView:FlushNextTime()
	local info = AncientRelicsData.Instance:GetInfo()
	local time = math.max(info.next_refresh_time - TimeCtrl.Instance:GetServerTime(), 0)
	if time > 3600 then
		self.node_list["TxtNextTime"].text.text = string.format(Language.AncientRelics.ReshTime, TimeUtil.FormatSecond(time, 1))
	else
		self.node_list["TxtNextTime"].text.text = string.format(Language.AncientRelics.ReshTime, TimeUtil.FormatSecond(time, 2))
	end
end