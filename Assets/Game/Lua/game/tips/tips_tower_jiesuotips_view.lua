TowerJieSuoView = TowerJieSuoView or BaseClass(BaseView)

local VIEW_STATE = {
	TOWER_MOJIE = 1,
}
function TowerJieSuoView:__init()
	self.ui_config = {{"uis/views/tips/patatips_prefab", "TowerTaJieSuoTipView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.data = nil
	self.is_modal = true									-- 是否模态
	self.background_opacity = 128
	self.is_any_click_close = false							-- 是否点击其它地方要关闭界面
end

function TowerJieSuoView:LoadCallBack()
	-- self.dec = self.node_list["TextDec"]
	self.is_one = self.node_list["ShowOne"]
	self.one_img = self.node_list["ImgOne"]
	-- self.show_three = self.node_list["ShowThree"]
	self.title_img = self.node_list["ImageTitle"]
end

function TowerJieSuoView:ReleaseCallBack()
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

function TowerJieSuoView:__delete()

end

function TowerJieSuoView:SetData(data)

end

function TowerJieSuoView:OpenCallBack()
	FuBenCtrl.Instance:GetFuwenImgState(false)
	self:Flush()
end

function TowerJieSuoView:CloseCallBack()
	self.data = nil
	if self.gj_time_quest then
		GlobalTimerQuest:CancelQuest(self.gj_time_quest)
		self.gj_time_quest = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	FuBenData.Instance:SetIsCanOpenJieSuo(false)
end

function TowerJieSuoView:OnFlush()
	self:ConstructData()
	self:ShowIcon()
	if not self.upgrade_timer_quest then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				self:CalTime()
		end, 2)
	end
end

function TowerJieSuoView:ConstructData()
	local cfg = FuBenData.Instance:GetNextRewardTowerMojieCfg()

	if cfg then
		self.skill_id = cfg.skill_id % 10 + 1
		self.info_image_bundle, self.info_image_asset = ResPath.GetSkillIcon("peijian_skill_" .. self.skill_id)--ResPath.GetTowerPeiJianIcon(self.skill_id + 1)
		self.txt_name = FuBenData.Instance:GetName(cfg.skill_id)
	else
		self:Close()
	end
end

function TowerJieSuoView:ShowIcon()
	if CheckInvalid(self.info_image_bundle) or CheckInvalid(self.info_image_asset) then return end
	self.node_list["ImgOne"].image:LoadSprite(self.info_image_bundle, self.info_image_asset, function()
			self.node_list["ImgOne"].image:SetNativeSize()
	end)

	-- self.node_list["TextDec"].text.text = self.desc_value

	self.node_list["TextName"]:SetActive(true)
	self.node_list["TextName"].text.text = self.txt_name
end

function TowerJieSuoView:CalTime()
	if self.gj_time_quest then return end
	local timer_cal = 3
	self.gj_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:Close()
			self.gj_time_quest = nil
		else
			local x, y = self.node_list["Openpos"].transform.localPosition.x, self.node_list["Openpos"].transform.localPosition.y
			self.node_list["GuajiImage"]:SetActive(false)
			self.node_list["Effect"]:SetActive(false)
			self.node_list["TextName"]:SetActive(false)
			UITween.MoveToScaleAndShowPanel(self.node_list["ImgOne"], Vector3(0, 0, 0), Vector3(x, y, 0), 0.8, 2, nil, function()
				FuBenCtrl.Instance:GetFuwenImgState(true)
				FuBenCtrl.Instance:SetCanMove(true)
				self:Close()
			end)
		end
	end, 0)
end