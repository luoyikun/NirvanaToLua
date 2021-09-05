TipKfLiujieReward = TipKfLiujieReward or BaseClass(BaseView)

function TipKfLiujieReward:__init()
	self.ui_config = {
		{"uis/views/tips/kuafuliujierewardtips_prefab", "TipsKuafuLiujieReward"}
	}
	self.item_list = {}
	self.play_audio = true
	-- self.view_layer = UiLayer.Pop
	self.title_id = 0
	self.top_title_id = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

local def_prof =
{
	[1] = 4,
	[3] = 3,
	[4] = 2,
	[5] = 1,
	[6] = 3,
}

local def_sex =
{
	[1] = 0,
	[2] = 1,
	[3] = 0,
	[4] = 1,
	[5] = 1,
	[6] = 0,
}

local def_area =   --title id 对应 服务器发的
{
	[1] = 2,	--皇城
	[2] = 1,	--暴雪
	[3] = 3,	--铁炉
	[4] = 4,	--神木
	[5] = 5,	--黑岩
	[6] = 6,	--时沙
}


local def_cfg_num =   --读表顺序
{
	[2] = 1,	--皇城
	[1] = 2,	--暴雪
	[3] = 3,	--铁炉
	[4] = 4,	--神木
	[5] = 5,	--黑岩
	[6] = 6,	--时沙
}


function TipKfLiujieReward:__delete()
	self.title_id = nil
	self.top_title_id = nil
end

function TipKfLiujieReward:ReleaseCallBack()
	self.data_list = nil
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end

	if self.tips_model then
		self.tips_model:DeleteMe()
		self.tips_model = nil
	end
	self.item_list = {}
	self.tips_model = nil
	self.fight_text_one = nil
	self.fight_text_two = nil
	self.fight_text_liujie = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
end

function TipKfLiujieReward:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnOK"].button:AddClickListener(BindTool.Bind(self.ClickOK, self))

	for i = 1, 3 do
		local item_obj = self.node_list["Item" .. i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		item_cell:SetShowOrangeEffect(true)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end
	self.tips_model = RoleModel.New()
	self.tips_model:SetDisplay(self.node_list["Display"].ui3d_display,MODEL_CAMERA_TYPE.BASE)
	self.fight_text_one = CommonDataManager.FightPower(self, self.node_list["TxtZhanLi"])
	self.fight_text_two = CommonDataManager.FightPower(self, self.node_list["TxtTitleZhanLi"])
	self.fight_text_liujie = CommonDataManager.FightPower(self, self.node_list["FightPower"])
end

function TipKfLiujieReward:SetData(items, show_gray, ok_callback, show_button, title_id, top_title_id, act_type, show_redpoint, close_callback)
	self.data_list = items
	self.show_gray_data = show_gray
	self.ok_callback = ok_callback
	self.show_button_value = show_button
	self.show_redpoint = show_redpoint
	self.title_id = title_id
	self.top_title_id = top_title_id
	self.act_type = act_type
	self.close_callback = close_callback
end

function TipKfLiujieReward:CloseView()
	self:Close()
end

function TipKfLiujieReward:CloseCallBack()
	if self.close_callback then
		self.close_callback()
	end
end

function TipKfLiujieReward:ClickOK()
	if self.ok_callback then
		self.ok_callback()
	end
end

function TipKfLiujieReward:OpenCallBack()
	self.tips_model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self:Flush()
end

function TipKfLiujieReward:OnFlush()
	local get_area_id = def_area[self.top_title_id]
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end
		if self.show_button_value == nil then
			self.node_list["BtnOK"]:SetActive(false)
		else
			self.node_list["BtnOK"]:SetActive(self.show_button_value)
			self.node_list["TxtAllGet"]:SetActive(not self.show_button_value)
		end
		if self.show_redpoint == nil then
			self.node_list["red_point"]:SetActive(false)
		else
			self.node_list["red_point"]:SetActive(self.show_redpoint)
		end
	end

	if nil ~= self.top_title_id then
		if tonumber(self.top_title_id) then
			if self.top_title_id > 0 then
				local str = Language.RecordRank.NameList[self.top_title_id]
				self.node_list["toptext2"].text.text = string.format(Language.Activity.TopText2, Language.RecordRank.NameList[self.top_title_id])
				self.node_list["toptext2"]:SetActive(true)
				self.node_list["TxtTop"]:SetActive(false)
			end
		else
			self.node_list["toptext2"]:SetActive(false)
			self.node_list["TxtTop"]:SetActive(true)
			self.node_list["TxtTop"].text.text = string.format(Language.Activity.TopText, self.top_title_id)
		end
	end

	--设置模型
	if self.act_type == ACTIVITY_TYPE.GUILDBATTLE then
		local reward_mount_id = GuildFightData.Instance:GetRewardMountSpecialId()

		local power_text = ItemData.GetFightPower(reward_mount_id)
		self:SetGuildWarRewardModelRes()
		self.node_list["TxtArms"]:SetActive(false)
		self.node_list["NodePower"]:SetActive(true)
		self.node_list["TxtMount"]:SetActive(true)
		if self.fight_text_one and self.fight_text_one.text then
			self.fight_text_one.text.text = power_text
		end

		local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag()
		if guild_war_info then
			local flag = guild_war_info.had_fetch == 1
			UI:SetButtonEnabled(self.node_list["BtnOK"], not flag)
			self.node_list["red_point"]:SetActive(not flag)
			self.node_list["BtnText"].text.text = flag and Language.RecordRank.Havecollect or Language.RecordRank.Collect
		end
		self.node_list["LiuJie"]:SetActive(false)
		self.node_list["GuildWar"]:SetActive(true)
		self.node_list["FightPower"]:SetActive(false)
	else
		self:SetModelRes()
		self.node_list["TxtArms"]:SetActive(true)
		self.node_list["NodePower"]:SetActive(false)
		self.node_list["TxtMount"]:SetActive(false)
		self.node_list["TxtArms"].text.text = Language.RecordRank.DescWord[1]
		self.node_list["TxtArmsLiujie"].text.text = Language.RecordRank.DescWord[1]
		if self.fight_text_liujie and self.fight_text_liujie.text then
			self.fight_text_liujie.text.text = 15000 .. "+" 						--WJ策划说写死
		end
		if get_area_id == 2 then 
			self.node_list["TxtArms"].text.text = Language.RecordRank.DescWord[2]
			self.node_list["TxtArmsLiujie"].text.text = Language.RecordRank.DescWord[2]
			if self.fight_text_liujie and self.fight_text_liujie.text then
				self.fight_text_liujie.text.text = 30000 .. "+" 						--WJ策划说写死
			end
		end
		self.node_list["LiuJie"]:SetActive(true)
		self.node_list["GuildWar"]:SetActive(false)
		self.node_list["FightPower"]:SetActive(true)
	end

	if self.title_id > 0 then
		local bundle, asset = ResPath.GetTitleIcon(self.title_id)
		self.node_list["ImgTitle"].image:LoadSprite(bundle, asset, function()
			--self.node_list["ImgTitle"].image:SetNativeSize()
		end)
		TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle"], self.title_id, true)
		local title_cfg = TitleData.Instance:GetTitleCfg(self.title_id)
		if self.fight_text_two and self.fight_text_two.text then
			self.fight_text_two.text.text = CommonDataManager.GetCapabilityCalculation(title_cfg)
		end
	end
	

end

function TipKfLiujieReward:SetModelRes()
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo() 
	if info == nil then
		return
	end

	local reward_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto")
	if reward_cfg == nil or reward_cfg.shizhuang_special_img == nil then
		return 
	end
	
	local fashion_cfg = reward_cfg.shizhuang_special_img
	local weapon_cfg = reward_cfg.weapon_special_img

	local rolezhuansheng_cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto")
	if rolezhuansheng_cfg == nil or rolezhuansheng_cfg.job == nil then
		return
	end

	local part_cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto")
	if part_cfg == nil or part_cfg.own_reward == nil then
		return
	end

	local job_cfg = rolezhuansheng_cfg.job
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()	
	if main_role_vo == nil then
		return
	end

	local res_index = KuafuGuildBattleData.Instance:GetShowImage(2) or 0
	local get_area_id = def_area[self.top_title_id] or 0		--城市对应相应霸主的信息

	if info.kf_battle_list == nil or info.kf_battle_list[get_area_id] == nil then   --霸主信息
		return
	end

	local data = info.kf_battle_list[get_area_id]
	if data.prof == nil or data.sex == nil or nil == job_cfg or job_cfg[data.prof % 10] == nil then 
		return
	end

	local role_job = job_cfg[data.prof % 10]
	self.tips_model:ResetRotation()
	self.tips_model:ClearModel()
	if data.guild_id == nil then
		return 
	end

	local role_info = data     
	if data.guild_id <= 0 then
		role_info = main_role_vo
	end

	local weapon_id = 0
	local role_res_id = 0
	local cfg_num = def_cfg_num[get_area_id]
	local weapon_image_id = part_cfg.own_reward[cfg_num].index_0
	local shizhuang_image_id = part_cfg.own_reward[cfg_num].index_1

	if (shizhuang_image_id ~= 0 and fashion_cfg[shizhuang_image_id] == nil) or 
		(weapon_image_id ~= 0 and weapon_cfg[weapon_image_id] == nil) then return end

		if get_area_id == 2 then
			for k, v in pairs(fashion_cfg[shizhuang_image_id]) do
				if k == "resouce" .. (role_info.prof % 10) .. role_info.sex then
					local role_id  = v
					if nil ~= role_id then
						role_res_id = role_id
					end
				end
			end

			for k, v in pairs(weapon_cfg[weapon_image_id]) do
				if k == "resouce" .. (role_info.prof % 10) .. role_info.sex then
					local weapon_part_id  = v
					if nil ~= weapon_part_id then
						weapon_id = weapon_part_id
					end
				end
			end
		else
			if data.guild_id > 0 then 		-- 从职业表中拿到角色模型

				role_res_id = role_job["model" .. role_info.sex]
				for k, v in pairs(weapon_cfg[weapon_image_id]) do
					if k == "resouce" .. (role_info.prof % 10) .. role_info.sex then
						local weapon_part_id  = v
						if nil ~= weapon_part_id then
							weapon_id = weapon_part_id
						end
					end
				end

				-- for k, v in pairs(reward_cfg.own_reward[cfg_num]) do
				-- 	if k == "prof_type_prof_" .. (role_info.prof % 10) .. 1 then
				-- 		local weapon_part_id = v
				-- 		if nil ~= weapon_part_id and weapon_part_id ~= "" then
				-- 			weapon_id = weapon_part_id
				-- 		end
				-- 	end
				-- end
			else 	--其他5个城市，无城主
				role_res_id = job_cfg[def_prof[get_area_id]]["model" .. def_sex[get_area_id]]
				for k, v in pairs(weapon_cfg[weapon_image_id]) do
					if k == "resouce" .. def_prof[get_area_id] .. def_sex[get_area_id] then
						local weapon_part_id  = v
						if nil ~= weapon_part_id then
							weapon_id = weapon_part_id
						end
					end
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
		self.tips_model:SetTrigger(ANIMATOR_PARAM.FIGHT)
		self.tips_model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
end

function TipKfLiujieReward:SetGuildWarRewardModelRes()
	local now_cfg = GuildFightData.Instance:GetConfig()
	if nil == now_cfg then
		return
	end

	local model_show = now_cfg.other[1].path
	local open_day_list = Split(model_show, ",")
	local bundle, asset = open_day_list[1], open_day_list[2]
	self.tips_model:SetMainAsset(bundle, asset)
	self.tips_model:SetRotation(Vector3(0, -45, 0))
end


