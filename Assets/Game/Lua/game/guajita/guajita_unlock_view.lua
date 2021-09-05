GuajiTaFbUnlockView = GuajiTaFbUnlockView or BaseClass(BaseView)

function GuajiTaFbUnlockView:__init()
	self.ui_config = {{"uis/views/guajitaview_prefab", "GuajiTaFinishView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.data = nil
	self.is_modal = true									-- 是否模态
	self.background_opacity = 128
	self.is_any_click_close = false							-- 是否点击其它地方要关闭界面
end

function GuajiTaFbUnlockView:LoadCallBack()
	self.dec = self.node_list["TextDec"]
	self.is_one = self.node_list["ShowOne"]
	self.one_img = self.node_list["ImgOne"]
	self.show_three = self.node_list["ShowThree"]
	self.title_img = self.node_list["ImageTitle"]

	self.item_img = {}
	for i = 1, 3 do
		self.item_img[i] = self.node_list["IconImage" .. i]
	end

	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnOkClick, self))
end

function GuajiTaFbUnlockView:ReleaseCallBack()
	self.dec = nil
	self.is_one = nil
	self.one_img = nil
	self.title_img = nil
	self.show_three = nil
	self.item_img = {}
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function GuajiTaFbUnlockView:__delete()

end

function GuajiTaFbUnlockView:SetData(data)
	self.data = data
	self:Open()
end

function GuajiTaFbUnlockView:OpenCallBack()
	self.is_not_reach_power = false
	self:Flush()
end

function GuajiTaFbUnlockView:CloseCallBack()
	self.data = nil
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function GuajiTaFbUnlockView:OnOkClick()
	-- if self.is_not_reach_power then
	-- 	self:OnClickClose()
	-- else
	
		FuBenCtrl.Instance:SendEnterNextFBReq()
		self:Close()
	-- end
end

function GuajiTaFbUnlockView:OnClickClose()
	FuBenCtrl.Instance:SendExitFBReq()
	self:Close()
end

function GuajiTaFbUnlockView:OnFlush()
	if nil == self.data then return end
	local tower_fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local fuben_cfg = GuaJiTaData.Instance:GetRuneTowerFBLevelCfg()
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	if fuben_cfg and tower_fb_info and fuben_cfg[tower_fb_info.fb_today_layer + 1] then
		if capability < fuben_cfg[tower_fb_info.fb_today_layer + 1].capability then
			self.is_not_reach_power = true
		else
			self.is_not_reach_power = false
		end
	end
	local sp_type = self.data.sp_type
	self.is_one:SetActive(sp_type ~= GuaJiTaData.SP_TYPE.TYPE)
	self.show_three:SetActive(sp_type == GuaJiTaData.SP_TYPE.TYPE)
	if sp_type == GuaJiTaData.SP_TYPE.TYPE then
		local item_t = self.data.panel_show
		local name_t = {"", "", ""}
		for i = 1, 1 do
			local item_id = item_t
			if item_id then
				local bundle, asset = ResPath.GetItemIcon(item_id)
				self.item_img[i].image:LoadSprite(bundle, asset, function()
					self.item_img[i].image:SetNativeSize() end)
				name_t[i] = RuneData.Instance:GetNameByItemId(item_id)
			end
		end
		self.dec.text.text = (string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", name_t[1]))
	else
		if sp_type == GuaJiTaData.SP_TYPE.SLOT then
			self.one_img.image:LoadSprite("uis/views/guajitaview/images_atlas", "img_open_slot", function()
				self.one_img.image:SetNativeSize() end)
			self.dec.text.text = (string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", 1))
		else
			self.one_img.image:LoadSprite("uis/views/guajitaview/images_atlas", "img_uplevel", function()
				self.one_img.image:SetNativeSize() end)
			self.dec.text.text = (string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", 5))
		end
	end
	self.title_img.image:LoadSprite("uis/views/guajitaview/images_atlas", "rune_state_" .. sp_type)
	self:CalTime()
end

function GuajiTaFbUnlockView:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 5
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:OnOkClick()
			self.cal_time_quest = nil
		else
			self.node_list["TxtDescText"].text.text = string.format(Language.Tips.PaTaTipsWithRewardBtnTxt, math.floor(timer_cal))
		end
	end, 0)
end