TipsCommonView = TipsCommonView or BaseClass(BaseView)

function TipsCommonView:__init()
	self.ui_config = {{"uis/views/tips/commontips_prefab", "CommonTips"}}
	self.ok_func = nil
	self.view_layer = UiLayer.Pop
	self.is_show_no_tip = false
	self.no_tip_state = false
	self.is_show_time = true
	self.prefs_key = nil
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.is_no_tip_toggle = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsCommonView:LoadCallBack()
	self.node_list["NoTips"].toggle:AddValueChangedListener(BindTool.Bind(self.OnNoTipToggleClick, self))
	self.node_list["Recycle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnNoTipToggleClick, self))
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnNoTipToggleClick, self))
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickYes, self))
	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.OnClickNo, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BGBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	if nil ~= self.data or nil ~= self.content then
		self:Flush()
	end
	self.node_list["TipContent"].text.text = ""
end

function TipsCommonView:ReleaseCallBack()
	self.ok_func = nil
end

function TipsCommonView:OpenCallBack()
	self.node_list["NoTips"].toggle.isOn = self.is_no_tip_toggle
	self:Flush()
end

function TipsCommonView:CloseCallBack()
	self.content = nil
	self.cancle_data = nil
	self.ok_func = nil
	self.no_func = nil
	self.data = nil
	self.is_show_no_tip = nil
	self.is_show_time = nil
	self.prefs_key = nil
	self.no_btn_text = nil
	self.cal_time = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.node_list["NoTips"].toggle.isOn then
		self.node_list["NoTips"].toggle.isOn = false
	end

	self.node_list["TxtTime"]:SetActive(false)
end

function TipsCommonView:OnClickYes()
	if self.ok_func ~= nil then
		if self.node_list["NoTips"].toggle.isOn then
			if type(self.prefs_key) == "string" then
				SettingData.Instance:SetCommonTipkey(self.prefs_key, true)
			end
		end
		if self.data ~= nil then
			self.ok_func(self.data)
		elseif self.is_recycle then
			self.ok_func(self.node_list["Recycle"].toggle.isOn)
		else
			self.ok_func()
		end
	end

	self:Close()
end

function TipsCommonView:OnClickNo()
	if self.no_func ~= nil then
		if self.cancle_data ~= nil then
			self.no_func(self.cancle_data)
		else
			self.no_func()
		end
	end

	self:Close()
end

function TipsCommonView:OnClickClose()
	if self.no_func ~= nil and not self.close_unequal_no_fun then
		if self.cancle_data ~= nil then
			self.no_func(self.cancle_data)
		else
			self.no_func()
		end
	end
	self:Close()
end

function TipsCommonView:OnNoTipToggleClick(is_click)
	self.no_tip_state = is_click
end

function TipsCommonView:SetOKCallback(func)
	self.ok_func = func
end

function TipsCommonView:SetNoCallback(func)
	self.no_func = func
end

function TipsCommonView:SetContent(content)
	self.content = content
	self:Flush()
end

function TipsCommonView:SetData(data, cancle_data, is_show_no_tip, show_time, prefs_key, is_recycle, recycle_text, auto_text_des, hide_cancel, boss_id, no_auto_click_yes, no_btn_text, cal_time, auto_click_no, is_no_tip_toggle, close_unequal_no_fun)
	self.prefs_key = prefs_key
	self.data = data
	self.is_show_no_tip = is_show_no_tip or false
	self.is_show_time = show_time or false
	self.is_recycle = is_recycle or false
	self.recycle_content = recycle_text or Language.Tips.HuiShou
	self.auto_text_des = auto_text_des or Language.Tips.TiaoZhan
	self.cancle_data = cancle_data
	self.hide_cancel = hide_cancel
	self.boss_id = boss_id
	self.no_auto_click_yes = no_auto_click_yes
	self.no_btn_text = no_btn_text
	self.cal_time = cal_time
	self.auto_click_no = auto_click_no
	self.close_unequal_no_fun = close_unequal_no_fun
	self.is_no_tip_toggle = not (is_no_tip_toggle ~= nil and is_no_tip_toggle == false)
	if self.root_node ~= nil then
		self:OnFlush()
	end
end

function TipsCommonView:SetTipText(content)
	self.node_list["TipContent"].text.text = content
end

function TipsCommonView:OnFlush(param_list)
	if self.content ~= nil then
		self.node_list["TipContent"].text.text = self.content
		self.node_list["NoTips"]:SetActive(self.is_show_no_tip)
		self.node_list["Recycle"]:SetActive(self.is_recycle)
		if self.is_recycle then
			self.node_list["TxtRecycle"].text.text = self.recycle_content
		end

		if self.is_show_time then
			self.node_list["TxtCancleBtn"].text.text = self.no_btn_text or Language.Society.Leave
			local diff_time = self.cal_time or 6
			if self.count_down == nil then
				self.count_down = CountDown.Instance:AddCountDown(
					diff_time, 1.0, function(elapse_time, total_time)
						local left_time = diff_time - elapse_time
						if left_time <= 0 then
							CountDown.Instance:RemoveCountDown(self.count_down)
							self.count_down = nil
							if self.auto_click_no == true then
								self:OnClickNo()
							else
								self:OnClickYes()
							end
							return
						end
						self.node_list["TxtTime"].text.text = left_time .. self.auto_text_des
						self.node_list["TxtTime"]:SetActive(true)
					end)
			end
		else
			self.node_list["TxtCancleBtn"].text.text = self.no_btn_text or Language.Tips.Cancle
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
		end
	end
	self.node_list["BtnNo"]:SetActive(self.hide_cancel ~= nil)

	if self.boss_id then
		self.node_list["ImgShowMonsterIcon"]:SetActive(true)
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
		if monster_cfg then
			local bundle, asset = nil, nil
			bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
			self.node_list["ImgMonster"].image:LoadSprite(bundle, asset)
		end
	else
		self.node_list["ImgShowMonsterIcon"]:SetActive(false)
	end
end
