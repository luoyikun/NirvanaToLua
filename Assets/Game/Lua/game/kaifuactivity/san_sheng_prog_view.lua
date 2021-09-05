SanShengProgView = SanShengProgView or BaseClass(BaseView)

local MAX_NUM = 3

function SanShengProgView:__init()
	-- self.view_layer = UiLayer.MainUI
	self.ui_config = {
			{"uis/views/kaifuactivity/childpanel_prefab", "SanShengProgView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SanShengProgView:ReleaseCallBack()

end

function SanShengProgView:__delete()

end

function SanShengProgView:LoadCallBack()
	local str = GameVoManager.Instance:GetMainRoleVo().lover_name
	self.node_list["TxtCoupleName"].text.text = str
	if nil == str or str == "" then
		self.node_list["TxtCoupleName"].text.text = Language.Marriage.NoPartner
	end
end

function SanShengProgView:OpenCallBack()
	self:Flush()
end

function SanShengProgView:FlushProgress()
	local info = KaifuActivityData.Instance:GetPerfectLoverInfo()
	if info then
		local bit_list = bit:d2b(info.perfect_lover_type_record_flag)
		for i = 1 , MAX_NUM do
			local is_reach = bit_list[32 - (i - 1)] == 1
			local str = is_reach and ToColorStr(1, TEXT_COLOR.GREEN_4) or ToColorStr(0, TEXT_COLOR.RED_4)
			self.node_list["TxtWedding" .. i].text.text = str .. " / <color=#89F201FF>1</color>"
		end
	end
end

function SanShengProgView:OnFlush()
	self:FlushProgress()
end

