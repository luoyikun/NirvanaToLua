-- 礼物收割-场景UI
-- GiftHarvestInfoView

GiftFuBenInfoView = GiftFuBenInfoView or BaseClass(BaseView)

function GiftFuBenInfoView:__init()
	self.ui_config = {
		{"uis/views/fubenview_prefab", "GiftHarvestInfoView"},
	}

	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.out_time = 0
	
end

function GiftFuBenInfoView:LoadCallBack()
	self.item_cell_list = {}

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	
	local item = ChristmaGiftData.Instance:GetAward()
	for k,v in pairs(item) do
		local cell  = ItemCell.New()
		cell:SetData(item[k])
		cell:SetInstanceParent(self.node_list["item1"])
		table.insert(self.item_cell_list, cell)
	end
	
end

function GiftFuBenInfoView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function GiftFuBenInfoView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = nil
	
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	
end

function GiftFuBenInfoView:OpenCallBack()
	self:Flush()
	local loader = AllocAsyncLoader(self, "skill_button_loader")
	loader:Load("uis/views/fubenview_prefab", "Gift_Fuben_Skill", function (obj)
		if IsNil(obj) then
			return
		end
		MainUICtrl.Instance:ShowActivitySkill(obj)
		if nil == self.skill_render then
			self.skill_render = GiftSkillView.New(obj)
			self.skill_render:Flush()
		end
	end)
end

function GiftFuBenInfoView:CloseCallBack()
	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function GiftFuBenInfoView:SwitchButtonState(enable)
	self.node_list["ShowPanel"]:SetActive(enable)
end

function GiftFuBenInfoView:OnFlush(param_t)
	self.node_list["text_name"].text.text = Language.ChristmaGift.Gift_FuBen_LeftName
	self:UpdataTime()
	self.node_list["Score"].text.text = string.format(Language.ChristmaGift.GetScore, ChristmaGiftData.Instance:GetMeData().get_score)
	if self.skill_render then
		self.skill_render:Flush()
	end
end

function GiftFuBenInfoView:UpdataTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	local time_cfg = ChristmaGiftData.Instance:GetRoundTime(ChristmaGiftData.Instance:GetSceneRound() or 6)
	if time_cfg == nil then
		return
	end
	local round_end_time = self:GetTime(time_cfg.round_end_time)
	self.count_down = CountDown.Instance:AddCountDown(9999, 1, function ()
		self.node_list["Remain_Time"].text.text = TimeUtil.FormatSecond(round_end_time - os.time(), 2)
	end)
end

function GiftFuBenInfoView:GetTime(timr)
	local h  = math.floor(timr / 100)
	local m  = math.floor(timr % 100)
	return TimeUtil.NowDayTimeStart(os.time()) + (h * 60 * 60) + (m * 60) 
end

