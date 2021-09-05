FuBenFailFinishView = FuBenFailFinishView or BaseClass(BaseView)

local ViewNameList = {
	ViewName.Forge, ViewName.Advance, ViewName.Marriage, ViewName.Rune, ViewName.Goddess, ViewName.BianShenView , ViewName.SpiritView
}

local VIEW_TABLE_INDEX = {
	TabIndex.forge_strengthen, TabIndex.mount_jinjie, nil, TabIndex.rune_tower, TabIndex.goddess_info, TabIndex.bian_shen_msg, TabIndex.spirit_spirit,
}

local open_fun_list = {
	"forge",
	"advance",
	"marriage",
	"rune",
	"goddess",
	"bianshen",
	"spiritview",
}

function FuBenFailFinishView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "FailFinishView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].ShiBai) or 0
	end
end

function FuBenFailFinishView:LoadCallBack()
	self.node_list["BtnOK"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	for i = 1, #ViewNameList do
		self.node_list["Btn_help" .. i].button:AddClickListener(BindTool.Bind(self.OnClickButton, self, i))
		local is_show = OpenFunData.Instance:CheckIsHide(open_fun_list[i])
		self.node_list["Btn_help" .. i]:SetActive(is_show)
	end

	self:Flush()
end

function FuBenFailFinishView:ReleaseCallBack()
	-- if self.close_timer_quest ~= nil then
	-- 	GlobalTimerQuest:CancelQuest(self.close_timer_quest)
	-- 	self.close_timer_quest = nil
	-- end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FuBenFailFinishView:OpenCallBack()
	self:AddTimerQuest()
end

function FuBenFailFinishView:CloseCallBack()
	-- if self.close_timer_quest ~= nil then
	-- 	GlobalTimerQuest:CancelQuest(self.close_timer_quest)
	-- 	self.close_timer_quest = nil
	-- end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FuBenFailFinishView:OnClickClose()
	self:CloseView()
end

function FuBenFailFinishView:OnClickButton(index)
	ViewManager.Instance:Open(ViewNameList[index], VIEW_TABLE_INDEX[index])
	self:CloseView()
end

function FuBenFailFinishView:CloseView()
	self:Close()
	FuBenCtrl.Instance:SendExitFBReq()
end

function FuBenFailFinishView:AddTimerQuest()
	-- if self.close_timer_quest == nil then
	-- 	self.close_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseView, self), 5)
	-- end
	local diff_time = 10
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				self:CloseView()
				return
			end
			self.node_list["Btn_text"].text.text = string.format(Language.FuBen.TipClickCountDown, left_time)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end
