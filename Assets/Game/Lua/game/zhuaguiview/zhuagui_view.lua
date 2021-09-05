ZhuaGuiView = ZhuaGuiView or BaseClass(BaseView)

function ZhuaGuiView:__init()
	self.ui_config = {{"uis/views/zhuaguiview_prefab", "ZhuaGuiView"}}
	
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.play_audio = true
end

function ZhuaGuiView:RleaseCallBack()
	if self.hunli_item then
		self.hunli_item:DeleteMe()
	end

	if self.mojing_item then
		self.mojing_item:DeleteMe()
	end
end

function ZhuaGuiView:LoadCallBack()
	self.to_left = false
	self.open_timer = true

	self.hunli_item = ItemCell.New()
	self.hunli_item:SetInstanceParent(self.node_list["hunli_item"])

	self.mojing_item = ItemCell.New()
	self.mojing_item:SetInstanceParent(self.node_list["mojing_item"])

	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickIcon, self))

	self:UpRewardData()
end

function ZhuaGuiView:OpenCallBack()
	local per_info = ZhuaGuiData.Instance:GetZhuaGuiPerInfo()
	if nil == next(per_info) then
		return
	end
	
	self.node_list["TxtAddtion"]:SetActive(per_info.couple_hunli_add_per > 0)
	self.node_list["TxtCouple"]:SetActive(not per_info.couple_hunli_add_per > 0)

	self.node_list["TxtCenter"]:SetActive(true)
	self.node_list["TxtCloseTimer"]:SetActive(false)
	self.node_list["TxtTime"]:SetActive(false)

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	FuBenCtrl.Instance:ShowMonsterHadFlush(true)
	local monster_info = ZhuaGuiData.Instance:GetBaseHunLi()
	FuBenCtrl.Instance:SetMonsterInfo(monster_info.monster_id or 304)
end

function ZhuaGuiView:CloseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function ZhuaGuiView:SwitchButtonState(state)
	self.node_list["FbView"]:SetActive(state)
end

function ZhuaGuiView:ChangeState()
	self.to_left = not self.to_left
end

function ZhuaGuiView:ToLeft(state)
	self.to_left = (state == "1") and true or false
end

function ZhuaGuiView:FlushHunLi()
end

function ZhuaGuiView:FlushFuBenList()
	local fb_list = ZhuaGuiData.Instance:GetZhuaGuiFBInfo()
	local boss_num = 0
	if fb_list.ishave_boss == 1 and fb_list.boss_isdead == 0 then
		boss_num = 1
	else
		boss_num = 0
	end

	-- 胜利后进入
	if fb_list.kick_time ~= 0 and self.open_timer then
		self.open_timer = false

		self.node_list["TxtCenter"]:SetActive(false)
		self.node_list["TxtCloseTimer"]:SetActive(true)
		self.node_list["TxtTime"]:SetActive(true)

		self:FlushTime(fb_list)
		 FuBenCtrl.Instance:ShowMonsterHadFlush(false)
		 FuBenCtrl.Instance:SetMonsterDiffTime(Language.Boss.HadKill)
	end
end

function ZhuaGuiView:UpRewardData()
	local kill_boss_count = ZhuaGuiData.Instance:GetCurDayZhuaGuiInfo().zhuagui_day_catch_count or 0
	local zhuagui_cfg = ZhuaGuiData.Instance:GetZhuaGuiOtherCfg()
	local item_data = {}

	local per_info = ZhuaGuiData.Instance:GetZhuaGuiPerInfo()
	if nil == next(per_info) then
		return
	end

	self.node_list["TxtAddtion"].text.text = string.format(Language.ZhuaGui.HunLiAdd, per_info.couple_hunli_add_per)
	self.node_list["TxtTeamAddtion"].text.text = string.format(Language.ZhuaGui.HunLiAdd2, per_info.team_hunli_add_per)

	if zhuagui_cfg then
		if kill_boss_count < zhuagui_cfg.mojing_reward_time then
			self.node_list["hunli_item"]:SetActive(true)
			self.node_list["mojing_item"]:SetActive(false)
			local base_hunli = ZhuaGuiData.Instance:GetBaseHunLi().give_hunli
			local add_data = ZhuaGuiData.Instance:GetAddHunLiDataByTime(kill_boss_count)
			local team_num = ScoietyData.Instance:GetTeamNum()
			local per_num = ZhuaGuiData.Instance:GetTeamAllPreByNum(team_num)

			local per_couple = 0
			if per_info.couple_hunli_add_per > 0 then
				per_couple = ZhuaGuiData.Instance:GetmarriedHunliAddPer()
			end
			local all_num = base_hunli * ((per_num + per_couple + 100)/100*add_data.reward_per/100)
			item_data = {item_id = ResPath.CurrencyToIconId["hunli"], num = all_num}
			self.hunli_item:SetData(item_data)
		else
			self.node_list["hunli_item"]:SetActive(false)
			self.node_list["mojing_item"]:SetActive(true)
			item_data = {item_id = ResPath.CurrencyToIconId["shengwang"], num = zhuagui_cfg.mojing_reward}
			self.mojing_item:SetData(item_data)
		end
	end
end

function ZhuaGuiView:OnFlush()
	self:FlushHunLi()
	self:FlushFuBenList()
end

function ZhuaGuiView:FlushTime(fb_list)
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		local remain_time = fb_list.kick_time - math.floor(TimeCtrl.Instance:GetServerTime())
		if remain_time < 0 then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		else
			self.node_list["TxtCloseTimer"].text.text = string.format(Language.ZhuaGui.ExitScene, remain_time)
			self.node_list["TxtTime"].text.text = string.format("00:00:%s", remain_time)
		end
	end, 0)
end

function ZhuaGuiView:OnClickIcon()
	local cfg_info = ZhuaGuiData.Instance:GetBaseHunLi()
	local callback = function()
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), cfg_info.flush_pos_x, cfg_info.flush_pos_y, 10, 1)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
end