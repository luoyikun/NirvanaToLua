GuajiTaFbJieSuoView = GuajiTaFbJieSuoView or BaseClass(BaseView)

function GuajiTaFbJieSuoView:__init()
	self.ui_config = {{"uis/views/guajitaview_prefab", "GuajiTaJieSuoTipView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.data = nil
	self.is_modal = true									-- 是否模态
	self.background_opacity = 128
	self.is_any_click_close = false							-- 是否点击其它地方要关闭界面
end

function GuajiTaFbJieSuoView:LoadCallBack()
	-- self.dec = self.node_list["TextDec"]
	self.is_one = self.node_list["ShowOne"]
	self.one_img = self.node_list["ImgOne"]
	-- self.show_three = self.node_list["ShowThree"]
	self.title_img = self.node_list["ImageTitle"]
end

function GuajiTaFbJieSuoView:ReleaseCallBack()
	self.dec = nil
	self.is_one = nil
	self.one_img = nil
	self.title_img = nil
	-- self.show_three = nil
	if self.gj_time_quest then
		GlobalTimerQuest:CancelQuest(self.gj_time_quest)
		self.gj_time_quest = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function GuajiTaFbJieSuoView:__delete()

end

function GuajiTaFbJieSuoView:SetData(data)
	self.data = data
	self:Open()
end

function GuajiTaFbJieSuoView:OpenCallBack()
	self:Flush()
end

function GuajiTaFbJieSuoView:CloseCallBack()
	self.data = nil
	if self.gj_time_quest then
		GlobalTimerQuest:CancelQuest(self.gj_time_quest)
		self.gj_time_quest = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function GuajiTaFbJieSuoView:OnFlush()
	if nil == self.data then return end
	local sp_type = self.data.sp_type
	-- self.is_one:SetActive(sp_type ~= GuaJiTaData.SP_TYPE.TYPE)
	-- self.show_three:SetActive(sp_type == GuaJiTaData.SP_TYPE.TYPE)
	if sp_type == GuaJiTaData.SP_TYPE.TYPE then
		local item_t = self.data.panel_show
		-- local name_t = {"", "", ""}
		for i = 1, 1 do
			local item_id = item_t
			if item_id then
				local bundle, asset = ResPath.GetItemIcon(item_id)
				self.one_img.image:LoadSprite(bundle, asset, function()
					self.one_img.image:SetNativeSize() end)
				-- name_t[i] = RuneData.Instance:GetNameByItemId(item_id)
			end
		end
		-- self.dec.text.text = (string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", name_t[1]))
	else
		if sp_type == GuaJiTaData.SP_TYPE.SLOT then
			self.one_img.image:LoadSprite("uis/views/guajitaview/images_atlas", "img_open_slot", function()
				self.one_img.image:SetNativeSize() end)
			-- self.dec.text.text = (string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", 1))
		else
			self.one_img.image:LoadSprite("uis/views/guajitaview/images_atlas", "img_uplevel", function()
				self.one_img.image:SetNativeSize() end)
			-- self.dec.text.text = (string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", 5))
		end
	end
	self.title_img.image:LoadSprite("uis/views/guajitaview/images_atlas", "rune_state_" .. sp_type)
	if not self.upgrade_timer_quest then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				self:CalTime()
		end, 2)
	end
end

function GuajiTaFbJieSuoView:CalTime()
	if self.gj_time_quest then return end
	local timer_cal = 5
	self.gj_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:Close()
			self.gj_time_quest = nil
		else
			local x, y = self.node_list["Openpos"].transform.localPosition.x, self.node_list["Openpos"].transform.localPosition.y
			self.node_list["GuajiImage"]:SetActive(false)
			self.node_list["Effect"]:SetActive(false)
			UITween.MoveToScaleAndShowPanel(self.node_list["ImgOne"], Vector3(0, 0, 0), Vector3(x, y, 0), 0.8, 2, nil, function()
				GuaJiTaCtrl.Instance:GetFuwenImgState(true)
				GuaJiTaCtrl.Instance:SetCanMove(true)
				self:Close()
			end , 0.85)
		end
	end, 0)
end