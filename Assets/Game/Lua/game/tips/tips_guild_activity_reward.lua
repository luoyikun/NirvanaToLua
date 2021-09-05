TipsGuildActivityReward = TipsGuildActivityReward or BaseClass(BaseView)

function TipsGuildActivityReward:__init()
	self.ui_config = {
		{"uis/views/tips/tipsguildactivityreward_prefab", "TipsGuildActivityReward"}
	}
	self.item_list = {}
	self.play_audio = true
	self.activity_id = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsGuildActivityReward:__delete()

end

function TipsGuildActivityReward:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}

	if self.lingkun_item_list then
		for k,v in pairs(self.lingkun_item_list) do
			if v then	
				v:DeleteMe()
			end
		end
	end
	self.lingkun_item_list = {}

	if self.tips_model then
		self.tips_model:DeleteMe()
		self.tips_model = nil
	end
	self.tips_model = nil

	self.fight_text_title = nil
	self.fight_text = nil
	self.fight_text_lingkun = nil


	if TitleData.Instance ~= nil then
		TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
		TitleData.Instance:ReleaseTitleEff(self.node_list["ImgLingKun"])
	end
end

function TipsGuildActivityReward:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnOK"].button:AddClickListener(BindTool.Bind(self.ClickOK, self))
	self.lingkun_item_list = {}
	for i = 1, 4 do
		local item_obj = self.node_list["Item" .. i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		item_cell:SetShowOrangeEffect(true)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
		-- table.insert(self.item_list, item_cell)

		local lingkun_cell = ItemCell.New()
		lingkun_cell:SetInstanceParent(self.node_list["LingKunItem" .. i])
		lingkun_cell:SetShowOrangeEffect(true)
		table.insert(self.lingkun_item_list, lingkun_cell)
	end
	self.tips_model = RoleModel.New()
	self.tips_model:SetDisplay(self.node_list["Display"].ui3d_display,MODEL_CAMERA_TYPE.BASE)
	self.fight_text_title = CommonDataManager.FightPower(self, self.node_list["TxtTitleZhanLi"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
	self.fight_text_lingkun = CommonDataManager.FightPower(self, self.node_list["LingKunPower"])
end

function TipsGuildActivityReward:CloseView()
	self:Close()
end

function TipsGuildActivityReward:ClickOK()
	ActivityCtrl.Instance:ShowDetailView(self.activity_id, true)
end

function TipsGuildActivityReward:OpenCallBack()
end

function TipsGuildActivityReward:OnFlush()
	self:SetModelRes()
	self:SetItemData()
	self:ShowLingKunShow()
	self:GuildActTipsTxt()
end

function TipsGuildActivityReward:SetData(id)
	self.activity_id = id
end

function TipsGuildActivityReward:SetModelRes()
	local role_info = GameVoManager.Instance:GetMainRoleVo()
	if self.activity_id == ACTIVITY_TYPE.GONGCHENGZHAN then
		local other_cfg = CityCombatData.Instance:GetOtherConfig()
		local res_id = 0
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == other_cfg.cz_fashion_yifu_id then
				res_id = v["resouce" .. (role_info.prof % 10) .. role_info.sex]
			end
		end
		local bundle, asset = ResPath.GetFashionShizhuangModel(res_id)
		self.tips_model:SetMainAsset(bundle, asset)

		local power_text = ItemData.GetFightPower(other_cfg.cz_fashion_yifu_id)
		if self.fight_text then
			self.fight_text.text.text = power_text or 0
		end
	elseif self.activity_id == ACTIVITY_TYPE.GUILDBATTLE then
		local now_cfg = GuildFightData.Instance:GetConfig()
		if now_cfg then
			local model_show = now_cfg.other[1].path
			local open_day_list = Split(model_show, ",")
			local bundle, asset = open_day_list[1], open_day_list[2]
			self.tips_model:SetMainAsset(bundle, asset)
			self.tips_model:SetRotation(Vector3(0, -45, 0))
		end
		local reward_mount_id = GuildFightData.Instance:GetRewardMountSpecialId()
		local power_text = ItemData.GetFightPower(reward_mount_id)
		if self.fight_text then
			self.fight_text.text.text = power_text or 0
		end
	elseif self.activity_id == ACTIVITY_TYPE.KF_GUILDBATTLE then
		local own_cfg = KuafuGuildBattleData.Instance:GetOwnReward(0)		-- 直接取皇城的
		if own_cfg then
			local shizhuang_image_id = own_cfg.index_1
			local weapon_image_id = own_cfg.index_0
			local role_res_id = 0
			local weapon_id = 0
			local reward_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto")
			if reward_cfg == nil or reward_cfg.shizhuang_special_img == nil then
				return 
			end
			
			local fashion_cfg = reward_cfg.shizhuang_special_img
			local weapon_cfg = reward_cfg.weapon_special_img

			for k, v in pairs(fashion_cfg[shizhuang_image_id]) do
				if k == "resouce" .. (role_info.prof % 10) .. role_info.sex then
					local role_id = v
					if nil ~= role_id then
						role_res_id = role_id
					end
				end
			end

			for k, v in pairs(weapon_cfg[weapon_image_id]) do
				if k == "resouce" .. (role_info.prof % 10) .. role_info.sex then
					local weapon_part_id = v
					if nil ~= weapon_part_id then
						weapon_id = weapon_part_id
					end
				end
			end

			self.tips_model:SetRoleResid(role_res_id)
			if type(weapon_id) == 'string' then
				local tmp_split_list = Split(weapon_id,",")
				self.tips_model:SetWeaponResid(tmp_split_list[1])
				self.tips_model:SetWeapon2Resid(tmp_split_list[2])
			else
				self.tips_model:SetWeaponResid(weapon_id)
			end
			if self.fight_text then
				self.fight_text.text.text = 30000 .. "+"
			end
		end
	end
end

function TipsGuildActivityReward:ShowLingKunShow()
	if self.activity_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB then
		self.node_list["LeftPanel"]:SetActive(false)
		self.node_list["LingKun"]:SetActive(true)
		self.node_list["Items"]:SetActive(false)
		self.node_list["PanelTitle"]:SetActive(false)
		self.node_list["PanelPower"]:SetActive(false)
		local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB)
		if act_info then
		local tab_list = Split(act_info.item_label, ":")
			for i = 1, 4 do
			if tab_list[i] then
				tab_list[i] = tonumber(tab_list[i])
				end
				if act_info["reward_item" .. i] and next(act_info["reward_item" .. i]) and act_info["reward_item" .. i].item_id ~= 0 then
					self.node_list["LingKunItem" .. i]:SetActive(true)
					self.lingkun_item_list[i]:SetData(act_info["reward_item" .. i])
				if tab_list[i]then
					self.lingkun_item_list[i]:SetShowZhuanShu(tab_list[i] == 1)
					end
				else
					self.node_list["LingKunItem" .. i]:SetActive(false)
				end
			end

			local title_id = act_info.title_id
			local bundle, asset = ResPath.GetTitleIcon(title_id)
			self.node_list["ImgLingKun"].image:LoadSprite(bundle, asset)
			TitleData.Instance:LoadTitleEff(self.node_list["ImgLingKun"], title_id, true)
			local title_cfg = TitleData.Instance:GetTitleCfg(title_id)
			if title_cfg then
				if self.fight_text_lingkun and self.fight_text_lingkun.text then
					self.fight_text_lingkun.text.text = CommonDataManager.GetCapabilityCalculation(title_cfg)
				end
			end
		end
	else
		self.node_list["LeftPanel"]:SetActive(true)
		self.node_list["LingKun"]:SetActive(false)
		self.node_list["Items"]:SetActive(true)
		self.node_list["PanelTitle"]:SetActive(true)
		self.node_list["PanelPower"]:SetActive(true)
	end
end

function TipsGuildActivityReward:SetItemData()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.activity_id)
	if act_info then
	local tab_list = Split(act_info.item_label, ":")
		if act_info.team_reward_item ~= nil then
			for k, v in pairs(self.item_list) do
				if act_info.team_reward_item[k] then
					v.item_cell:SetData(act_info.team_reward_item[k])
					v.item_obj:SetActive(true)
				else
					v.item_obj:SetActive(false)
				end
			end
		end
		-- for i = 1, 4 do
	-- 	if tab_list[i] then
	-- 		tab_list[i] = tonumber(tab_list[i])
		-- 	end
		-- 	if act_info["reward_item" .. i] and next(act_info["reward_item" .. i]) and act_info["reward_item" .. i].item_id ~= 0 then
		-- 		self.node_list["Item" .. i]:SetActive(true)
		-- 		self.item_list[i]:SetShowVitualOrangeEffect(true)
		-- 		self.item_list[i]:SetData(act_info["reward_item" .. i])
	-- 		if tab_list[i]then
	-- 			self.item_list[i]:SetShowZhuanShu(tab_list[i] == 1)
		-- 		end
		-- 	else
		-- 		self.node_list["Item" .. i]:SetActive(false)
		-- 	end
		-- end
		local title_id = act_info.title_id
		local bundle, asset = ResPath.GetTitleIcon(title_id)
		self.node_list["ImgTitle" ].image:LoadSprite(bundle, asset)
		TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle"], title_id, true)
		local title_cfg = TitleData.Instance:GetTitleCfg(act_info.title_id)
		if title_cfg then
			if self.fight_text_title and self.fight_text_title.text then
				self.fight_text_title.text.text = CommonDataManager.GetCapabilityCalculation(title_cfg)
			end
		end
	end
end

function TipsGuildActivityReward:GuildActTipsTxt()
	if self.activity_id == ACTIVITY_TYPE.GONGCHENGZHAN then
		self.node_list["ActRewardTxt"]:SetActive(true)
		self.node_list["AllRewardTxt"]:SetActive(false)
		self.node_list["JiTiText"]:SetActive(true)
		self.node_list["ActRewardTxt"].text.text = Language.Activity.GuildActRewardTip[2]
	elseif self.activity_id == ACTIVITY_TYPE.GUILDBATTLE then
		self.node_list["ActRewardTxt"]:SetActive(true)
		self.node_list["AllRewardTxt"]:SetActive(true)
		self.node_list["JiTiText"]:SetActive(true)
		self.node_list["ActRewardTxt"].text.text = Language.Activity.GuildActRewardTip[1]
	elseif self.activity_id == ACTIVITY_TYPE.KF_GUILDBATTLE then
		self.node_list["ActRewardTxt"]:SetActive(true)
		self.node_list["AllRewardTxt"]:SetActive(true)
		self.node_list["JiTiText"]:SetActive(true)
		self.node_list["ActRewardTxt"].text.text = Language.Activity.GuildActRewardTip[3]
	else
		self.node_list["ActRewardTxt"]:SetActive(false)
		self.node_list["AllRewardTxt"]:SetActive(false)
		self.node_list["JiTiText"]:SetActive(false)
	end
end

