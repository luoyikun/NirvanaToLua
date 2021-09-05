TipsLockVipView = TipsLockVipView or BaseClass(BaseView)

local IMAGE_LIST_LENGTH = 2

function TipsLockVipView:__init()
	self.ui_config = {{"uis/views/tips/lockviptips_prefab", "LockVipTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsLockVipView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["BtnChongZhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi, self))
end

function TipsLockVipView:ReleaseCallBack()
end

function TipsLockVipView:SetOpenReason(index)
	self.reason = index
	self:Flush()
end

-- 符文塔挂机权限是客户端定义的，直接写死
function TipsLockVipView:ShowRuneImage()
	self:SetOpenReason(99)
end

function TipsLockVipView:OpenCallBack()
	self:Flush()
end

function TipsLockVipView:OnClickCloseButton()
	self:Close()
end

function TipsLockVipView:CloseCallBack()

end

function TipsLockVipView:OnFlush()
	local str = Language.Vip.LockVip[self.reason]
	if nil == str or str == "" then
		self.node_list["TxtVipLevel"].text.text = Language.Vip.DefaultLockVip1
		self.node_list["TxtNotice"].text.text = Language.Vip.DefaultLockVip2
	else
		local level = self:CalculateVipLevel()
		if level == 1 then
			self.node_list["TxtVipLevel"].text.text = Language.Vip.FirstCharge
		else
			self.node_list["TxtVipLevel"].text.text = string.format(Language.Vip.VipLevel, level)
		end
		self.node_list["TxtNotice"].text.text = str
	end

end

function TipsLockVipView:CalculateVipLevel()
	-- 符文塔特殊处理
	if self.reason == 99 then
		local other_cfg = GuaJiTaData.Instance:GetRuneOtherCfg()
		if other_cfg then
			return other_cfg.auto_vip_limit or 0
		end
	end
	local now_vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local next_vip_level = now_vip_level
	local is_change = false
	local vip_config = VipData.Instance:GetVipLevelCfg()
	if vip_config then
		local info = vip_config[self.reason]
		if info then
			local number = info["param_" .. now_vip_level] or 0
			for i = now_vip_level + 1, 15 do
				local next_number = info["param_" .. i] or 0
				if next_number > number then
					next_vip_level = i
					is_change = true
					break
				end
			end
		end
	end
	return next_vip_level, is_change
end

function TipsLockVipView:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end