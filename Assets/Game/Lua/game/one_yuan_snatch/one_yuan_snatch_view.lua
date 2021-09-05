require("game/one_yuan_snatch/snatch_content_view")
require("game/one_yuan_snatch/integral_content_view")
require("game/one_yuan_snatch/log_content_view")
require("game/one_yuan_snatch/ticket_content_view")

OneYuanSnatchView = OneYuanSnatchView or BaseClass(BaseView)

function OneYuanSnatchView:__init(instance)
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/oneyuansnatch_prefab", "SnatchContent", {TabIndex.one_yuan_panel_snatch}},
		{"uis/views/oneyuansnatch_prefab", "IntegralContent", {TabIndex.one_yuan_panel_integral}},
		{"uis/views/oneyuansnatch_prefab", "LogContent", {TabIndex.one_yuan_panel_log}},
		{"uis/views/oneyuansnatch_prefab", "TicketContent", {TabIndex.one_yuan_panel_ticket}},
		{"uis/views/oneyuansnatch_prefab", "OneYuanSnatchView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
	}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false

	self.def_index = TabIndex.one_yuan_panel_ticket
end

function OneYuanSnatchView:__delete()

end

function OneYuanSnatchView:CloseCallBack()

end

function OneYuanSnatchView:OpenCallBack()
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_INFO)
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_BUY_RECORD)
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT_INFO)
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_SERVER_RECORD_INFO)
	local time = ActivityData.Instance:GetCrossRandActivityResidueTime(ACTIVITY_TYPE.KF_ONEYUANSNATCH) or 0
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 6
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 2
	end
	self.node_list["TxtTime"].text.text = string.format(Language.OneYuanSnatch.last_time, TimeUtil.FormatSecond(time, time_type))
	self:FlushNextTime()
end

function OneYuanSnatchView:ReleaseCallBack()
	if self.snatch_view then
		self.snatch_view:DeleteMe()
		self.snatch_view = nil
	end

	if self.integral_view then
		self.integral_view:DeleteMe()
		self.integral_view = nil
	end

	if self.log_view then
		self.log_view:DeleteMe()
		self.log_view = nil
	end

	if self.ticket_view then
		self.ticket_view:DeleteMe()
		self.ticket_view = nil
	end

	if self.countdown_time then
		GlobalTimerQuest:CancelQuest(self.countdown_time)
		self.countdown_time = nil
	end
end

function OneYuanSnatchView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.OneYuanSnatch.TabbarName[1], tab_index = TabIndex.one_yuan_panel_ticket},
		{name = Language.OneYuanSnatch.TabbarName[2], tab_index = TabIndex.one_yuan_panel_snatch},
		{name = Language.OneYuanSnatch.TabbarName[3], tab_index = TabIndex.one_yuan_panel_integral},
		{name = Language.OneYuanSnatch.TabbarName[4], tab_index = TabIndex.one_yuan_panel_log},
	}
	for i = 1,4 do
		self.node_list["Toggle" .. i].toggle:AddClickListener(BindTool.Bind(self.ChangeToIndex, self, tab_cfg[i].tab_index))
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function OneYuanSnatchView:OnFlush(param_list)
	if param_list then
		for k, v in pairs(param_list) do
			if k == "snatch" and self.snatch_view then
				self.snatch_view:Flush()
			elseif k == "integral" and self.integral_view then
				self.integral_view:Flush()
			elseif k == "log" and self.log_view then
				self.log_view:Flush()
			elseif k == "ticket" and self.ticket_view then
				self.ticket_view:Flush()
			end
		end
	end
end


function OneYuanSnatchView:ShowIndexCallBack(index, index_nodes)
	if index_nodes then
		if index == TabIndex.one_yuan_panel_ticket then
			self.ticket_view = SnatchTicketView.New(index_nodes["TicketContent"])
		elseif index == TabIndex.one_yuan_panel_snatch then
			self.snatch_view = SnatchContentView.New(index_nodes["SnatchContent"])
		elseif index == TabIndex.one_yuan_panel_integral then
			self.integral_view = IntegralContentView.New(index_nodes["IntegralContent"])
		elseif index == TabIndex.one_yuan_panel_log then
			self.log_view = SnatchLogView.New(index_nodes["LogContent"])
		end
	end

	if self.ticket_view and index == TabIndex.one_yuan_panel_ticket then
		self.ticket_view:OpenCallBack()
	elseif self.snatch_view and index == TabIndex.one_yuan_panel_snatch then
		self.snatch_view:OpenCallBack()
	elseif self.integral_view and index == TabIndex.one_yuan_panel_integral then
		self.integral_view:OpenCallBack()
	elseif self.log_view and index == TabIndex.one_yuan_panel_log then
		self.log_view:OpenCallBack()
	end

	self.node_list["ImgTime"]:SetActive(index == TabIndex.one_yuan_panel_ticket or index == TabIndex.one_yuan_panel_snatch)
	local bundle,asset = ResPath.GetRawImage("bg_activity_panel_two", true)
	if index == TabIndex.one_yuan_panel_log then
		bundle,asset = ResPath.GetRawImage("bg_oneyuan_log2", true)
	end
	self.node_list["BgUnder"].raw_image:LoadSprite(bundle,asset)
end

function OneYuanSnatchView:FlushNextTime()
	local diff_time_func = function(elapse_time, total_time)
		if elapse_time >= total_time then
			if self.countdown_time then
				GlobalTimerQuest:CancelQuest(self.countdown_time)
				self.countdown_time = nil
			end
			return 
		end
		local time = math.floor(total_time - elapse_time + 0.5)
		local time_type = 1
		if time > 3600 * 24 then
			time_type = 6
		elseif time > 3600 then
			time_type = 1
		else
			time_type = 2
		end
		if self.node_list and self.node_list["TxtTime"] then
			self.node_list["TxtTime"].text.text = string.format(Language.OneYuanSnatch.last_time, TimeUtil.FormatSecond(time, time_type))
		end
	end
	if nil == self.countdown_time then
		local time = ActivityData.Instance:GetCrossRandActivityResidueTime(ACTIVITY_TYPE.KF_ONEYUANSNATCH) or 0
		self.countdown_time = CountDown.Instance:AddCountDown(time, 1, diff_time_func)
	end
end





