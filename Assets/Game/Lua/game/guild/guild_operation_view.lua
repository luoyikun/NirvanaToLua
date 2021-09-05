GuildOperationView = GuildOperationView or BaseClass(BaseView)

function GuildOperationView:__init()
	self.ui_config = {
		{"uis/views/guildview_prefab", "OperationWindow"},
	}
	self.is_modal = true
	self.is_any_click_close = true
end

-- 打开操作面板
function GuildOperationView:LoadCallBack()
	self.node_list["BtnCloseOperate"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["ButtonInSetting"].button:AddClickListener(BindTool.Bind(self.OpenInvite, self))
	self.node_list["ButtonMemberIn"].button:AddClickListener(BindTool.Bind(self.OnOpenApplyWindow, self))
	self.node_list["ButtonQuitGuild"].button:AddClickListener(BindTool.Bind(self.QuitGuild, self))
	self.node_list["ButtonTanHe"].button:AddClickListener(BindTool.Bind(self.SendGuildCheckCanDelate, self))
end

function GuildOperationView:__delate()
end

function GuildOperationView:ReleaseCallBack()

end
function GuildOperationView:OpenCallBack()
	self:Flush()
end

function GuildOperationView:OpenInvite()
	local post = GuildData.Instance:GetGuildPost()
	if post then
		if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
			return
		end
	end	
	GuildCtrl.Instance:OpenOpearteZhaoRenView()
end

function GuildOperationView:QuitGuild()
	local describe = ""
	local yes_func = nil

	local post = GuildData.Instance:GetGuildPost()
	if post then
		if post == GuildDataConst.GUILD_POST.TUANGZHANG then
			yes_func = BindTool.Bind(self.SendQuitGuildReq, self, 1)
			describe = Language.Guild.ConfirmDismissGuildTip
		else
			yes_func = BindTool.Bind(self.SendQuitGuildReq, self, 0)
			describe = Language.Guild.QuitGuildTip
		end
	end

	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 请求退出公会 flag = 1 解散公会
function GuildOperationView:SendQuitGuildReq(flag)
	if flag == 1 then
		local guild_id = GuildData.Instance.guild_id
		if guild_id then
			GuildCtrl.Instance:SendDismissGuildReq(guild_id)
		end
	else
		GuildCtrl.Instance:SendQuitGuildReq()
	end
	self:Close()
end

-- 检查能否弹劾会长
function GuildOperationView:SendGuildCheckCanDelate()
	local describe = Language.Guild.ConfirmTanHeMengZhuTip
	local yes_func = function() 
		GuildCtrl.Instance:SendGuildCheckCanDelateReq()
		self:Close()
	end
	local delete_id = GuildData.Instance:GetGuildDeleteId()
	if not delete_id then return end
	local number = ItemData.Instance:GetItemNumInBagById(delete_id)
	if number < 1 then
		local func = function(item_id, num, is_bind, is_tip_use) 
			ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0) 
			TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, delete_id, nil, 1)
	else
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

--打开申请列表
function GuildOperationView:OnOpenApplyWindow()
	ViewManager.Instance:Open(ViewName.GuildApply)
end

function GuildOperationView:OnFlush(param)
	self.node_list["ButtonInSetting"]:SetActive(true)
	self.node_list["ButtonTanHe"]:SetActive(true)
	post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG then
		self.node_list["ButtonTanHe"]:SetActive(false)
	elseif post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.node_list["ButtonInSetting"]:SetActive(false)
	end
	if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
		self.node_list["RedPointMemberIn"]:SetActive(true)
	else

		self.node_list["RedPointMemberIn"]:SetActive(false)
	end

	local info = GuildData.Instance:GetGuildMemberInfo()
	if info then
		if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
			self.node_list["ExitGuildText"].text.text = Language.Guild.JieSanXianMeng
		else
			self.node_list["ExitGuildText"].text.text = Language.Guild.TuiChuGuild
		end
	end
end

-------------------------------------------------------------------- 招人面板 -----------------------------------------------------------------------
GuildOperationZhaoRenView = GuildOperationZhaoRenView or BaseClass(BaseView)
function GuildOperationZhaoRenView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/guildview_prefab", "InviteWindow"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp	
end

function GuildOperationZhaoRenView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(463,526,0)
	self.node_list["Txt"].text.text = Language.Guild.ZhaoRen
	local event_table = self.node_list["InviteWindow"]:GetComponent(typeof(UINameTable))
	U3DObject(event_table:Find("LevelInput")).event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.ClickLevelInput, self))
	U3DObject(event_table:Find("FpInput")).event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.ClickFPInput, self))

	U3DObject(event_table:Find("ButtonSaveSetting")).button:AddClickListener(BindTool.Bind(self.OnSaveSetting, self))
	U3DObject(event_table:Find("BtnCancel")).button:AddClickListener(BindTool.Bind(self.OnCancel, self))

	U3DObject(event_table:Find("ToggleUnlimited")).toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickNoLimit, self))

	self.toggle_forbid = U3DObject(event_table:Find("ToggleForbid")).toggle
	self.toggle_approver = U3DObject(event_table:Find("ToggleApprover")).toggle
	self.toggle_unlimited = U3DObject(event_table:Find("ToggleUnlimited")).toggle
	self.level_input = U3DObject(event_table:Find("LevelInput")):GetComponent("InputField")
	self.fp_input = U3DObject(event_table:Find("FpInput")):GetComponent("InputField")

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
end

function GuildOperationZhaoRenView:OnClickCloseButton()
	self:Close()
end

function GuildOperationZhaoRenView:ReleaseCallBack()
	self.toggle_forbid = nil
	self.toggle_approver = nil
	self.toggle_unlimited = nil
	self.level_input = nil
	self.fp_input = nil
end

function GuildOperationZhaoRenView:OpenCallBack()
	UI:SetGraphicGrey(self.level_input, false)
	UI:SetGraphicGrey(self.fp_input, false)

	self.level_input.text = Language.Daily.CapNoLimmit
	self.fp_input.text = Language.Daily.CapNoLimmit
	if GuildDataConst.GUILDVO.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.APPROVAL then
		self.toggle_approver.isOn = true
	elseif GuildDataConst.GUILDVO.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.FORBID then
		self.toggle_forbid.isOn = true
	else
		self.toggle_unlimited.isOn = true
		UI:SetGraphicGrey(self.level_input, true)
		UI:SetGraphicGrey(self.fp_input, true)

		self.level_input.text = tostring(GuildDataConst.GUILDVO.applyfor_need_level)
		self.fp_input.text = tostring(GuildDataConst.GUILDVO.applyfor_need_capability)
	end
end

function GuildOperationZhaoRenView:OnSaveSetting()
	local need_capability = 0
	local need_level = 0
	local model = GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS
	if self.toggle_unlimited.isOn then
		model = GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS
		need_capability = tonumber(self.fp_input.text) or 0
		need_level = tonumber(self.level_input.text) or 0
	elseif self.toggle_forbid.isOn then
		model = GuildDataConst.GUILD_SETTING_MODEL.FORBID
	else
		model = GuildDataConst.GUILD_SETTING_MODEL.APPROVAL
	end
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		GuildCtrl.Instance:SendSettingGuildReq(guild_id, model, need_capability, need_level)
		 GuildDataConst.GUILDVO.applyfor_setup = model
		 GuildDataConst.GUILDVO.applyfor_need_level = need_level
		 GuildDataConst.GUILDVO.applyfor_need_capability = need_capability
	end
	self:Close()
end

function GuildOperationZhaoRenView:OnCancel()
	self:Close()
end

function GuildOperationZhaoRenView:ClickLevelInput()
	if self.toggle_unlimited.isOn then
		TipsCtrl.Instance:OpenCommonInputView(self.level_input.text, function(num) self.level_input.text = num end, nil, COMMON_CONSTS.ROLE_MAX_LEVEL)
	end
end

function GuildOperationZhaoRenView:ClickFPInput()
	if self.toggle_unlimited.isOn then
		TipsCtrl.Instance:OpenCommonInputView(self.fp_input.text, function(num) self.fp_input.text = num end, nil, 99999999)
	end
end

function GuildOperationZhaoRenView:ClickNoLimit(switch)
	if not switch then
		self.level_input.text = Language.Daily.CapNoLimmit
		self.fp_input.text = Language.Daily.CapNoLimmit
	else
		self.level_input.text = "0"
		self.fp_input.text = "0"
	end
	UI:SetGraphicGrey(self.level_input, not switch)
	UI:SetGraphicGrey(self.fp_input, not switch)
end