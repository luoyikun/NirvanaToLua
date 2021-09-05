TipsQuickCompletionView = TipsQuickCompletionView or BaseClass(BaseView)
function TipsQuickCompletionView:__init()
	self.ui_config = {{"uis/views/tips/quickcompletiontip_prefab", "QuickCompletionTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.pinzhi = -1
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsQuickCompletionView:LoadCallBack()
	self.node_list["BtnCanel"].button:AddClickListener(BindTool.Bind(self.ClickCancel, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnOk"].button:AddClickListener(BindTool.Bind(self.ClickOk, self))

	self.dropdown = self.node_list["dropdown"].dropdown
	self.dropdown_2 = self.node_list["dropdown_2"].dropdown

	self.node_list["dropdown"].dropdown.onValueChanged:AddListener(BindTool.Bind(self.AutoPickValueChange, self))
	self.node_list["dropdown_2"].dropdown.onValueChanged:AddListener(BindTool.Bind(self.AutoPickValueChange, self))
	self.node_list["dropdown_3"].dropdown.onValueChanged:AddListener(BindTool.Bind(self.AutoPickValueChange, self))
	end

function TipsQuickCompletionView:ReleaseCallBack()
	-- 清理变量和对象
	self.pinzhi = nil
	self.dropdown = nil
	self.dropdown_2 = nil
	self.xingzuo_show = nil
end

function TipsQuickCompletionView:OpenCallBack()
	self.dropdown.value = 1
	self.dropdown_2.value = 1
	self:Flush()
end

function TipsQuickCompletionView:CloseCallBack()
	self.ok_callback = nil
	self.canel_callback = nil
end

function TipsQuickCompletionView:CloseWindow()
	self.is_auto = false
	self:Close()
end

function TipsQuickCompletionView:ClickCancel()
	self.is_auto = false
	if self.canel_callback then
		self.canel_callback()
	end
	self:Close()
end

function TipsQuickCompletionView:SetTitle(title_name)
	self.title_str = title_name ~= "" and title_name or Language.Common.Remind
end

function TipsQuickCompletionView:SetDesShow(value)
	self.show_des_value = value
end

function TipsQuickCompletionView:SetDes(des)
	self.des_str = des
end

function TipsQuickCompletionView:SetOkCallBack(callback)
	self.ok_callback = callback
end

function TipsQuickCompletionView:SetCanelCallBack(callback)
	self.canel_callback = callback
end

function TipsQuickCompletionView:ShowPinZhi(value)
	self.show_pinzhi_str = value
end

function TipsQuickCompletionView:ShowMoLong(value)
	self.show_mo_long_str = value
end

function TipsQuickCompletionView:SetIsShowOk(value)
	self.is_show_ok_str = value
end

function TipsQuickCompletionView:SetType(value)
	if value == nil then
		self.show_pinzhi_str = false
		self.show_mo_long_str = false
		return
	end
	self.type = value
	self:ShowPinZhi(true)
	if self.type == SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI then
		self:GetMoLong(0)
	elseif self.type == SKIP_TYPE.SKIP_TYPE_SAILING then
		self:GetMiningSea(0)
	elseif self.type == SKIP_TYPE.SKIP_TYPE_MINE then
		self:GetMiningMine(0)
	elseif self.type == SKIP_TYPE.SKIP_TYPE_FISH then
		self:GetFishing(0)
	end
end

function TipsQuickCompletionView:SetBtnDes(ok_des, canel_des)
	self.ok_str = ok_des or Language.Common.Confirm
	self.canel_str = canel_des or Language.Common.Cancel
end

function TipsQuickCompletionView:ClickOk()
	if self.ok_callback then
		self.ok_callback()
	end
	self:Close()
end

function TipsQuickCompletionView:OnFlush()
	self.node_list["TxtTitleName"].text.text = self.title_str
	self.node_list["TxtShowDesc"]:SetActive(self.show_des_value)
	self.node_list["TxtShowDesc"].text.text = self.des_str
	self.node_list["TxtBtnOk"].text.text = self.ok_str
	self.node_list["TxtBtnCancel"].text.text = self.canel_str
	if self.is_show_ok_str ~= nil then
		UI:SetButtonEnabled(self.node_list["BtnOk"], self.is_show_ok_str)
	end

	if self.show_mo_long_str ~= nil then
		self.node_list["dropdown_2"]:SetActive(self.show_mo_long_str)
	end

	if self.show_pinzhi_str ~= nil then
		self.node_list["dropdown"]:SetActive(self.show_pinzhi_str)
	end
end

function TipsQuickCompletionView:AutoPickValueChange(value)
	if value > 0 then
		if self.type == SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI then
			self:GetMoLong(value - 1)
		elseif self.type == SKIP_TYPE.SKIP_TYPE_SAILING then
			self:GetMiningSea(value - 1)
		elseif self.type == SKIP_TYPE.SKIP_TYPE_MINE then
			self:GetMiningMine(value - 1)
		elseif self.type == SKIP_TYPE.SKIP_TYPE_FISH then
			self:GetFishing(value - 1)
		end
	end
	self:Flush()
end

function TipsQuickCompletionView:SetInitText()
	local str = string.format(Language.QuickCompletion[self.type], 0, 0, 0)
	self:SetDesShow(true)
	self:SetDes(str)
end

----------------------------特殊处理函数------------------------------
-- 捕鱼
function TipsQuickCompletionView:GetFishing(value)
	local farm_fish_times = FishingData.Instance:GetFarmFishTimes()
	local bullet_num = FishingData.Instance:GetLeftBulletNum()
	local consume = FishingData.Instance:GetSkipCfgByType(value).consume
	local consume2 = FishingData.Instance:GetSkipCfgByType(-1).consume
	local gold = (farm_fish_times * consume) + (bullet_num * consume2)

	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_FISH], gold,farm_fish_times,bullet_num)

	self:SetDesShow(true)
	self:SetDes(str)
	self.is_show_ok_str = true
	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_FISH, value)
	end
	self:SetOkCallBack(ok_callback)
end
