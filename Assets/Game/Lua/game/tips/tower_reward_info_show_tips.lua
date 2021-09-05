-- 爬塔副本完成解锁传世佩剑提示框-TowerRewardInfoShowTips
TowerRewardInfoShowTips = TowerRewardInfoShowTips or BaseClass(BaseView)

local VIEW_STATE = {
	TOWER_MOJIE = 1,

}
function TowerRewardInfoShowTips:__init()
	self.ui_config = {{"uis/views/tips/patatips_prefab", "TowerRewardInfoShowTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = false							-- 是否点击其它地方要关闭界面
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TowerRewardInfoShowTips:__delete()

end

function TowerRewardInfoShowTips:LoadCallBack()
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClickOK, self))
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.OnClickCancel, self))
end

function TowerRewardInfoShowTips:ReleaseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TowerRewardInfoShowTips:OpenCallBack()
	self.is_not_reach_power = false
	self.view_state = VIEW_STATE.TOWER_MOJIE
	self.ok_callback = function ()
		self:Close()
	end

	self.cancle_callback = function ()
		self:Close()
	end
end

function TowerRewardInfoShowTips:CloseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TowerRewardInfoShowTips:OnFlush(param_list)
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
	local fuben_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	if tower_fb_info and fuben_cfg and fuben_cfg[tower_fb_info.today_level + 1] then
		if capability < fuben_cfg[tower_fb_info.today_level + 1].capability then
			self.is_not_reach_power = true
		else
			self.is_not_reach_power = false
		end
	end
	self:SetFlag(param_list)
	self:ConstructData()
	self:ShowIcon()
	self:CalTime()
end

function TowerRewardInfoShowTips:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 30
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 3 then
			self:OnClickOK()
			UI:SetButtonEnabled(self.node_list["BtnConfirm"], false)
			self.node_list["TxtDescText"].text.text = string.format(Language.Tips.PaTaTipsWithRewardBtnTxtTwo, math.floor(timer_cal))
		elseif timer_cal <= 0 then 
			self.cal_time_quest = nil
		else
			self.node_list["TxtDescText"].text.text = string.format(Language.Tips.PaTaTipsWithRewardBtnTxtTwo, math.floor(timer_cal))
		end
	end, 0)
end

----显示处理

function TowerRewardInfoShowTips:SetFlag(param_list)
	for k,v in pairs(param_list) do
		if k == ViewName.FuBenTowerInfoView then
			self.view_state = VIEW_STATE.TOWER_MOJIE
			self.ok_callback = v.ok_callback
			self.cancle_callback = v.no_call_back
			return
		end
	end
end

function TowerRewardInfoShowTips:ConstructData()
	if self.view_state == VIEW_STATE.TOWER_MOJIE then
		local cfg = FuBenData.Instance:GetCurMojie()
		if cfg then
			self.skill_id = cfg.skill_id % 10
			self.skill_idtwo = cfg.skill_id 
			self.info_image_bundle, self.info_image_asset = ResPath.GetTowerPeiJianIcon(self.skill_id + 1)
			self.desc_value = FuBenData.Instance:GetSkillDesc(self.skill_id,self.skill_idtwo)
			self.txt_name = FuBenData.Instance:GetName(cfg.skill_id)
		else
			self:Close()
		end
	end
end

function TowerRewardInfoShowTips:ShowIcon()
	if CheckInvalid(self.info_image_bundle) or CheckInvalid(self.info_image_asset) then return end
	if self.view_state == VIEW_STATE.TOWER_MOJIE then
		self.node_list["ImgOne"].raw_image:LoadSprite(self.info_image_bundle, self.info_image_asset, function()
				self.node_list["ImgOne"].raw_image:SetNativeSize()
		end)
		local tmp_id = self.skill_id % 10 + 1
		local tmp_id2 = math.modf((self.skill_id + 1)/ 10)
		tmp_id2 = tmp_id2 > 0 and 3 or 2 										--策划要求显示中级跟高级特效
		local roadA = "KGH_mingjian_" .. 0 .. tmp_id .. "_0" .. tmp_id2
		local roadB = "KGH_mingjian_" .. tmp_id .. "_0" .. tmp_id2
		local asset1 = tmp_id < 10 and roadA or roadB

		local bundle_name, asset_name = ResPath.GetUiMingJianEffect(asset1)
		self.node_list["Node_effect"]:ChangeAsset(bundle_name, asset_name)

		self.node_list["TextDec"].text.text = self.desc_value
		self.node_list["TextName"].text.text = self.txt_name
	end
end


---点击事件

function TowerRewardInfoShowTips:OnClickOK()
	if self.view_state == VIEW_STATE.TOWER_MOJIE then
		-- if self.is_not_reach_power then
		-- 	self:cancle_callback()
		-- 	self:Close()
		-- else
			if self.node_list["MjReward"] then
					local x, y = self.node_list["MjReward"].transform.localPosition.x, self.node_list["MjReward"].transform.localPosition.y
					UITween.MoveToShowPanel(self.node_list["Showjihuo"], Vector3(0, 0, 0), Vector3(x, y, 0), 2, nil, function()
						self:ok_callback()
						self:Close()
					end)
			end
		-- end
	end
end

function TowerRewardInfoShowTips:OnClickCancel()
	if self.view_state == VIEW_STATE.TOWER_MOJIE then
		self:cancle_callback()
		self:Close()
	end
end