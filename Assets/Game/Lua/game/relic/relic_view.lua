RelicView = RelicView or BaseClass(BaseView)

local MAX_BOSS_NUM = 1

function RelicView:__init()
	self.ui_config = {{"uis/views/relicview_prefab", "RelicView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	
	self.temp_box_num = 0
	self.flush_box_total_time = 0
end

function RelicView:__delete()

end

function RelicView:LoadCallBack()

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

end

function RelicView:OpenCallBack()
	self.temp_box_num = 0
	self:Flush()
	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickBossIcon, self))
end

function RelicView:CloseCallBack()
	self:RemoveCountDown()
end

function RelicView:ReleaseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

function RelicView:SwitchButtonState(enable)
	self.node_list["PanelTrackAndMapInfo"]:SetActive(enable)
end
function RelicView:OnClickBossIcon()
	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	if info.now_boss_num <= 0 then return end

	local x, y = GuajiCtrl.Instance:GetMonsterPos()

	if x and y then
		self:MoveToPosOperateFight(x, y)
	end
end

function RelicView:MoveToPosOperateFight(x, y)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	local scene_id = Scene.Instance:GetSceneId()
	
	local callback = function()
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 3, 0)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
end

function RelicView:OnFlush(param_t)
	self:SetInfo()
	self:FlushBoxTime()
	self:SetBossIconInfo()

	FuBenCtrl.Instance:FlushFbIconView("xzyj_info")
end

function RelicView:SetInfo()
	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	local molong_box = info.gather_box_num_list[4]
	local huangjin_box = info.gather_box_num_list[3]
	local diji_box = info.gather_box_num_list[1] + info.gather_box_num_list[2]
	local cfg = RelicData.Instance:GetRelicCfg().other[1]
	self.node_list["TxtRestNum"].text.text = string.format(Language.AncientRelics.RestNum, 	RelicData.Instance:GetGoldBoxRestNum())
	self.node_list["TxtDiJi"].text.text = string.format(Language.AncientRelics.NO3,  diji_box .. "/" .. cfg.common_box_gather_limit)
	self.node_list["TxtMolong"].text.text = string.format(Language.AncientRelics.NO1, molong_box)
	self.node_list["TxtGild"].text.text = string.format(Language.AncientRelics.NO2, huangjin_box)

	-- -- 活动是否开启
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI)
		self.node_list["TxtTime"]:SetActive(not RelicData.Instance:IsShowBtnEffect())
		self.node_list["Time_title"]:SetActive(not RelicData.Instance:IsShowBtnEffect())
		self.node_list["TxtRestNum"].text.text = string.format(Language.AncientRelics.RestNum, is_open and info.now_boss_num and info.next_boss_refresh_time > 0)
end

function RelicView:SetBossIconInfo()
	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	-- 活动是否开启
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI)

	-- 下面的 FuBenCtrl 那些，是设置右边BOSS头像的显示的
	FuBenCtrl.Instance:SetMonsterIconState(true)

	local boss_flush_time = info.now_boss_num <= 0 and (info.next_boss_refresh_time - TimeCtrl.Instance:GetServerTime()) or 0
	FuBenCtrl.Instance:SetMonsterDiffTime(boss_flush_time)

	local str = ""
	if not is_open or (info.next_boss_refresh_time <= 0 and info.now_boss_num <= 0) then
		str = Language.ShengXiao.FlushBossTime
	else
		str = string.format(Language.ShengXiao.ClickGoTo, info.now_boss_num, MAX_BOSS_NUM)
	end

	local is_flush = false
	if info.now_boss_num > 0 or info.next_boss_refresh_time <= 0 then
		is_flush = true
	end
	FuBenCtrl.Instance:ShowMonsterHadFlush(is_flush, str)
	FuBenCtrl.Instance:SetMonsterIconGray(info.now_boss_num <= 0)
end

function RelicView:FlushBoxTime()
	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	self.flush_box_total_time = math.floor(info.next_box_refresh_time - TimeCtrl.Instance:GetServerTime())
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI)

	if self.flush_box_total_time > 3601 then
		self:DiffTime(0, info.next_box_refresh_time, true)
		self.node_list["Time_title"].text.text = Language.ShengXiao.FlushText .. "："
		self:RemoveCountDown()
		return
	end

	if nil == self.count_down then
		self:DiffTime(0, self.flush_box_total_time)
		self.count_down = CountDown.Instance:AddCountDown(self.flush_box_total_time, 1, BindTool.Bind(self.DiffTime, self))
		self.node_list["Time_title"].text.text = Language.ShengXiao.FlushCountDownText .. "："
	end
end

function RelicView:DiffTime(elapse_time, total_time, is_not_count_down)
	local left_time = math.floor(total_time - elapse_time)
	local the_time_text = TimeUtil.FormatSecond(left_time, 4)
	if is_not_count_down then
		local time_tab = os.date('*t', left_time)
		the_time_text = string.format(Language.Common.HourAndMinute, time_tab.hour, time_tab.min)
	end
	 self.node_list["TxtTime"].text.text = ToColorStr(the_time_text, COLOR.GREEN) 

	if left_time <= 0 then
		self:RemoveCountDown()
	end
end

function RelicView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end