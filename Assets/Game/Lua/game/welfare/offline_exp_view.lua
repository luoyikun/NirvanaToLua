OffLineExpView = OffLineExpView or BaseClass(BaseView)

function OffLineExpView:__init()
	self.ui_config = {{"uis/views/welfare_prefab", "OffLineExpView"}}
	self.play_audio = true
	-- self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function OffLineExpView:LoadCallBack()
	self.select_index = 1				--默认选择第一个档次
	self.gold_text_list = {}
	self.gold_icon = {}
	for i = 1, 3 do
		local gold_text = self.node_list["TxtGold" .. i]
		table.insert(self.gold_text_list, gold_text)

		local tab = self.node_list["Tab" .. i]
		tab.toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectChange, self, i))
		self.gold_icon[i] = self.node_list["GoldIcon" .. i]
	end

	self.node_list["BtnClickGet"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	-- self.node_list["DoubleBtn"].button:AddClickListener(BindTool.Bind(self.ClickDoubleGet, self))
	self.node_list["BtnClickAfter"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	local equip_info = WelfareData.Instance:GetEquipInfo()
	if equip_info == nil or next(equip_info) == nil then return end
	-- self.node_list["TextEquip"]:SetActive(false)
	-- self.node_list["TextEquipDec"]:SetActive(false)
	for i = 1, 6 do
		if equip_info and equip_info["item_count_" .. i] then
			self.node_list["EquipText" .. i].text.text = string.format(Language.LiXian.EquipType[i], equip_info["item_count_" .. i])
			-- self.node_list["EquipText" .. i]:SetActive(equip_info["item_count_" .. i] > 0)
			-- if equip_info["item_count_" .. i] > 0 then
			-- 	self.node_list["TextEquip"]:SetActive(true)
			-- 	self.node_list["TextEquipDec"]:SetActive(true)
			-- end
		end
	end

	self.node_list["CollectPanel"]:SetActive(equip_info.collect_item_count > 0)
	self.node_list["TxtCollect"].text.text = string.format(Language.Welfare.OfflineCollect, equip_info.collect_item_count)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.OffLineExp, BindTool.Bind(self.GetUiCallBack, self))
end

function OffLineExpView:ReleaseCallBack()
	self.gold_text_list = nil
	self.gold_icon = nil

	if self.guide_time then
		GlobalTimerQuest:CancelQuest(self.guide_time)
		self.guide_time = nil
	end
end

function OffLineExpView:ShowIndexCallBack()
	if self.guide_time then
		GlobalTimerQuest:CancelQuest(self.guide_time)
		self.guide_time = nil
	end
	self.guide_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SetGuideTime, self), 0.2)
end

function OffLineExpView:SetGuideTime()
	if WelfareData.Instance:GetIsShowGuide() and self.is_rendering then
		WelfareData.Instance:SetIsShowGuide(false)
		self:SetSortingOrder()
		FunctionGuide.Instance:TriggerGuideById(48)
	end
end

function OffLineExpView:SetSortingOrder()
	local canvas = self:GetRootNode():GetComponentInChildren(typeof(UnityEngine.Canvas))
	if canvas then
		canvas.overrideSorting = true
		canvas.sortingOrder = 8000
	end
end

function OffLineExpView:OnSelectChange(index, isOn)
	if isOn then
		self.select_index = index
		local off_line_exp = WelfareData.Instance:GetOffLineExp()
		off_line_exp = off_line_exp * index
		self.node_list["TxtRoleExp"].text.text = string.format(Language.Welfare.OfflineGetExp, CommonDataManager.ConverMoney2(off_line_exp))
	end
end

function OffLineExpView:CloseCallBack()

end

function OffLineExpView:OpenCallBack()
	self:Flush()
end

function OffLineExpView:ClickGet()
	local off_line_cfg = WelfareData.Instance:GetOffLineExpCfg()
	local select_cfg = off_line_cfg[self.select_index]
	local find_type = select_cfg.type
	WelfareCtrl.Instance:SendGetOffLineExp(find_type)
	self:Close()
end

function OffLineExpView:ClickDoubleGet()
	local off_line_cfg = WelfareData.Instance:GetOffLineExpCfg()
	local select_cfg = off_line_cfg[2]

	local hour, min, sec  = WelfareData.Instance:GetOffLineTime()
	--计算倍数
	local multiple = 1
	if hour > 0 then
		if min > 0 or sec > 0 then
			multiple = hour + 1
		else
			multiple = hour
		end
	end

	local offline_info = WelfareData.Instance:GetOffLineExpInfo()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if offline_info == nil or offline_info.double_cost_gold == nil then return end
	
	local diff_value = main_vo.bind_gold - offline_info.double_cost_gold or 0
	if diff_value < 0 then
		local function ok_func()
			if PlayerData.GetIsEnoughAllGold(diff_value) then
				local find_type = select_cfg.type
				WelfareCtrl.Instance:SendGetOffLineExp(find_type)
				self:Close()
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		end
		local des = string.format(Language.Common.ToUseGold, math.abs(diff_value))
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)
	else
		local find_type = select_cfg.type
		WelfareCtrl.Instance:SendGetOffLineExp(find_type)
		self:Close()
	end
end

function OffLineExpView:CloseWindow()
	self:Close()
end

function OffLineExpView:OnFlush()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local off_line_exp = WelfareData.Instance:GetOffLineExp()
	self.node_list["TxtRoleExp"].text.text = string.format(Language.Welfare.OfflineGetExp, CommonDataManager.ConverMoney2(off_line_exp))

	-- local off_line_mojing = WelfareData.Instance:GetOffLineMojing()
	-- off_line_mojing = off_line_mojing * self.select_index
	-- self.node_list["TxtMojing"].text.text = string.format(Language.Welfare.OfflineGetMoJing, CommonDataManager.ConverMoney2(off_line_mojing))

	local role_exp = GameVoManager.Instance:GetMainRoleVo().exp
	local cur_exp = role_exp + off_line_exp
	local offline_info = WelfareData.Instance:GetOffLineExpInfo()
	if offline_info.role_level_after_fetch and offline_info.role_level_after_fetch > main_vo.level then
		self.node_list["TxtLevel"].text.text = string.format(Language.Welfare.OfflindeLevel, PlayerData.GetLevelString(main_vo.level))
		self.node_list["TxtUpLevel"].text.text = PlayerData.GetLevelString(offline_info.role_level_after_fetch)
		self.node_list["TxtUpLevel"]:SetActive(true)
	else
		self.node_list["TxtLevel"].text.text = string.format(Language.Welfare.OfflindeLevel, PlayerData.GetLevelString(main_vo.level))
		self.node_list["TxtUpLevel"]:SetActive(false)
	end

	local hour, min, sec = WelfareData.Instance:GetOffLineTime()
	local off_time_des = self:GetTimeStr(hour, min, sec)
	local hour1, min1, sec1 = WelfareData.Instance:GetOffLineDoublelTime()
	local double_time_des = self:GetTimeStr(hour1, min1, sec1)
	local exp_buff_rate = offline_info.exp_buff_effect_rate > 1 and offline_info.exp_buff_effect_rate or 2 --没有使用经验药水的时候显示2倍药水
	self.node_list["TxtOffTime"].text.text = string.format(Language.Welfare.OfflineTime, off_time_des)
	self.node_list["TextTime"].text.text = string.format(Language.Welfare.OfflineDoubleTime, exp_buff_rate, double_time_des)

	--计算倍数
	local multiple = 1
	if hour > 0 then
		if min > 0 or sec > 0 then
			multiple = hour + 1
		else
			multiple = hour
		end
	end

	local off_line_cfg = WelfareData.Instance:GetOffLineExpCfg()
	for k, v in ipairs(self.gold_text_list) do
		local cost = off_line_cfg[k].diamond * multiple
		local cost_des = ""
		if main_vo.bind_gold < cost then
			cost_des = ToColorStr(tostring(cost), TEXT_COLOR.RED)
		else
			cost_des = ToColorStr(tostring(cost), TEXT_COLOR.YELLOW)
		end
		v.text.text = cost > 0 and cost_des or ""
		self.gold_icon[k]:SetActive(cost > 0)
	end
end

function OffLineExpView:GetTimeStr(hour, min, sec)
	local off_time_des = ""
	if hour and hour > 0 then
		off_time_des = off_time_des .. string.format(Language.OpenServer.TimeHour, hour)
	end
	if min and min > 0 then
		off_time_des = off_time_des .. string.format(Language.OpenServer.TimeMin, min)
	end
	if sec and sec > 0 then
		off_time_des = off_time_des .. string.format(Language.Role.XXMiao, sec)
	end
	if off_time_des == "" then
		off_time_des = "0时"
	end
	return off_time_des
end

function OffLineExpView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.OffLineExpTop then
		return self.node_list["TopContent"], BindTool.Bind(self.CloseWindow, self)
	elseif ui_name == GuideUIName.OffLineExpDown then
		return self.node_list["DownContent"], BindTool.Bind(self.SetSortingOrder, self)
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end