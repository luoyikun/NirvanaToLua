TipsSpiritDressSoulView = TipsSpiritDressSoulView or BaseClass(BaseView)

function TipsSpiritDressSoulView:__init(instance)
	self.ui_config = {{"uis/views/tips/spiritsoultips_prefab", "SpiritDressSoulTip"}}
	self.view_layer = UiLayer.Pop
	self.callback = nil
	self.play_audio = true
	self.can_level_up = false

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsSpiritDressSoulView:LoadCallBack()
	self.node_list["BtnBack"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnTakeOff"].button:AddClickListener(BindTool.Bind(self.OnClickTakeOff, self))
	self.node_list["BtnUpLevel"].button:AddClickListener(BindTool.Bind(self.OnClickUpLevel, self))
end

function TipsSpiritDressSoulView:ReleaseCallBack()
	if self.soul_item then
		self.soul_item:DeleteMe()
		self.soul_item = nil
	end
	self.is_first_open = nil
end

function TipsSpiritDressSoulView:OpenCallBack()
	self:Flush()
end

function TipsSpiritDressSoulView:CloseCallBack()
	self.data = nil
	self.old_level = nil
	if self.callback then
		self.callback()
	end
end

function TipsSpiritDressSoulView:CloseView()
	self:Close()
end

function TipsSpiritDressSoulView:OnClickTakeOff()
	if nil == self.data then return end
	SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.TAKEOFF, self.data.index)
	self:Close()
end

function TipsSpiritDressSoulView:OnClickUpLevel()
	if nil == self.data then return end
	SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.FUHUN_ADD_EXP, self.data.index, self.data.level + 1)
	if self.can_level_up then
		AudioService.Instance:PlayAdvancedAudio()
	end
	SpiritData.Instance:SetSoulIsPlayEffect(true)
end

function TipsSpiritDressSoulView:SetData(data)
	self.data = data
end

function TipsSpiritDressSoulView:SetCallback(callback)
	self.callback = callback
end

function TipsSpiritDressSoulView:OnFlush()
	if self.data and next(self.data) then
		local attr_cfg = SpiritData.Instance:GetSoulAttrCfg(self.data.id, self.data.level)
		local next_attr_cfg = SpiritData.Instance:GetSoulAttrCfg(self.data.id, self.data.level + 1)
		local soul_cfg = SpiritData.Instance:GetSpiritSoulCfg(self.data.id)
		local storage_exp = SpiritData.Instance:GetSpiritSlotSoulInfo().total_exp or 0
		local attr_name = ""
		if attr_cfg and soul_cfg then
			attr_name = Language.JingLing.TipsSoulAttr[soul_cfg.hunshou_type + 1]
			self.node_list["TxtCurAttr"].text.text = string.format(Language.Tips.NowLevel, attr_name, attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			local str = "<color=".. SOUL_NAME_COLOR[soul_cfg.hunshou_color] .. ">" .. soul_cfg.name .. "</color>"
			self.node_list["TxtName"].text.text = string.format("Lv.%s·%s", self.data.level, str)
			self.node_list["TxtExp"].text.text = string.format("%s / %s", self.data.exp, attr_cfg.exp)
			if storage_exp < attr_cfg.exp - self.data.exp then
				storage_exp = string.format(Language.Mount.ShowRedNum, storage_exp)
				self.can_level_up = false
			else
				self.can_level_up = true
			end
			self.node_list["TxtExpNeed"].text.text = string.format(Language.Tips.JingYanXiaoHao, storage_exp, attr_cfg.exp - self.data.exp)
		end
		self.node_list["Img"]:SetActive(nil ~= next_attr_cfg)
		self.node_list["TxtNextAttr"]:SetActive(nil ~= next_attr_cfg)
		self.node_list["TxtExp"]:SetActive(nil ~= next_attr_cfg)
		self.node_list["TxtExpNeed"]:SetActive(nil ~= next_attr_cfg)

		if nil == next_attr_cfg and attr_cfg and soul_cfg and soul_cfg.hunshou_type then
			self.node_list["TxtCurAttr"].text.text = string.format(Language.Tips.MaxLevel, attr_name, attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]] or 0)
		end

		if next_attr_cfg then
			self.node_list["TxtNextAttr"].text.text = string.format(Language.Tips.NextLevel, attr_name, next_attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			UI:SetButtonEnabled(self.node_list["BtnUpLevel"], true)
			self.node_list["TxtMaxLevel1"]:SetActive(false)
			self.node_list["TxtMaxLevel2"]:SetActive(false)

			if not self.old_level then
				self.old_level = self.data.level
				if self.data and self.data.exp then
					self.node_list["SliderProgressBG"].slider.value = self.data.exp / attr_cfg.exp
				end
			else
				if self.old_level < self.data.level then
					if self.pro_quest ~= nil then
						self.node_list["SliderProgressBG"].slider.value = 0
						GlobalTimerQuest:CancelQuest(self.pro_quest)
						self.pro_quest = nil
					end
					local pro_num = self.data.exp
					self.pro_quest = GlobalTimerQuest:AddRunQuest(function ()
						self.node_list["SliderProgressBG"].slider.value = pro_num
						pro_num = pro_num + 0.1
						if self.node_list["SliderProgressBG"].slider.value >= 1 then
							if self.pro_quest ~= nil then
								GlobalTimerQuest:CancelQuest(self.pro_quest)
								self.pro_quest = nil
							end
							if self.data and self.data.exp then
								self.node_list["SliderProgressBG"].slider.value = self.data.exp / attr_cfg.exp
							end
						end
					end, 0)
					self.old_level = self.data.level
				else
					self.node_list["SliderProgressBG"].slider.value = self.data.exp / attr_cfg.exp
				end
			end

		else
			self.node_list["TxtMaxLevel1"]:SetActive(true)
			self.node_list["TxtMaxLevel2"]:SetActive(true)
			UI:SetButtonEnabled(self.node_list["BtnUpLevel"], false)
			self.node_list["SliderProgressBG"].slider.value = 1
		end
	end
end