KuafuLiuJieShowInfoView = KuafuLiuJieShowInfoView or BaseClass(BaseRender)

local def_cfg_num =   --读表顺序
{
	[2] = 1,	--皇城
	[1] = 2,	--暴雪
	[3] = 3,	--铁炉
	[4] = 4,	--神木
	[5] = 5,	--黑岩
	[6] = 6,	--时沙
}

function KuafuLiuJieShowInfoView:__init()
	self.show_item = {}
	for i = 1, 6 do
		self.show_item[i] = LiuJieShowItem.New(self.node_list["show_item" .. i])
		self.show_item[i]:SetIndex(i)
	end
end

function KuafuLiuJieShowInfoView:__delete()
	for k, v in pairs(self.show_item) do
		v:DeleteMe()
	end
	self.show_item = nil
end

function KuafuLiuJieShowInfoView:OnFlush()
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	if nil == info or info.kf_battle_list == nil then
		return
	end
	local data_list = info.kf_battle_list
	for i = 1, 6 do
		self.show_item[i]:SetData(data_list[i])
	end
end

local def_prof = 
{
	[1] = 3,
	[3] = 2,
	[4] = 1,
	[5] = 2,
	[6] = 3,
}

local def_sex = 
{
	[1] = 0,
	[3] = 1,
	[4] = 1,
	[5] = 0,
	[6] = 1,
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


LiuJieShowItem = LiuJieShowItem or BaseClass(BaseRender)
function LiuJieShowItem:__init()
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display)
end

function LiuJieShowItem:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.ui_title_img then 
		self.ui_title_img:DeleteMe()
		self.ui_title_img = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.ui_title_res)
end

function LiuJieShowItem:SetData(data)
	if nil == data then
		return
	end
	local id = 0
	if self.index == 2 then
		id = 1
	elseif self.index == 1 then
		id = 2
	else
		id = self.index
	end
	self.current_title_id = KuafuGuildBattleData.Instance:GetOwnReward(id - 1).title_name
	local role_res_id = 0
	local weapon_id = 0
	local weapon_id2 = 0
	self.model:ResetRotation()
	local res_index = KuafuGuildBattleData.Instance:GetShowImage(id)
	local job_cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job

	local part_cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto")
	local cfg_num = def_cfg_num[self.index]
	local weapon_image_id = part_cfg.own_reward[cfg_num].index_0 or 0
	local shizhuang_image_id = part_cfg.own_reward[cfg_num].index_1 or 0


	-- 根据id得到武器外观配置表
	local weapon_is_special = data.shizhuang_wuqi_is_special == 1
	local weapon_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_img
	if weapon_is_special or weapon_image_id ~= 0 then
		weapon_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
	end

	-- 根据id得到时装外观配置表
	local body_is_special = data.shizhuang_body_is_special == 1
	local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_img
	if body_is_special or shizhuang_image_id ~= 0 then
		fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_special_img
	end

	-- -- data.wuqi_id
	local wuqi_image_id = data.shizhuang_wuqi
	local body_image_id = data.shizhuang_body
	local halo_used_imageid = data.halo_used_imageid

	local qilinbi_used_imageid = data.qilinbi_used_imageid
	local mask_used_imageid = data.mask_used_imageid
	local toushi_used_imageid = data.toushi_used_imageid


	if data.guild_id > 0 then	
		self.node_list["Txttop"].text.text = string.format(Language.KuafuGuildBattle.KfGuildShowName,data.guild_name,data.guild_tuanzhang_name .."_s" .. data.server_id)
		self.node_list["Imgtop"]:SetActive(true)
		self.node_list["Imgxuwei"]:SetActive(false)
		local base_prof = PlayerData.Instance:GetRoleBaseProf(data.prof)
		local role_job = job_cfg[base_prof]
		if nil == role_job then
			return
		end

		local body_id = shizhuang_image_id ~= 0 and shizhuang_image_id or body_image_id

		if fashion_cfg[body_id] then
			for k, v in pairs(fashion_cfg[body_id]) do 
				if k == "resouce" .. base_prof .. data.sex then
					role_res_id = v
				end
			end
		else
			role_res_id = role_job["model" .. data.sex]
		end

		local wuqi_id = weapon_image_id ~= 0 and weapon_image_id or wuqi_image_id

		if weapon_cfg[wuqi_id] then
			for k, v in pairs(weapon_cfg[wuqi_id]) do
				if k == "resouce" .. base_prof .. data.sex then
					weapon_id = v
					if base_prof == 3 then
						local t = Split(weapon_id,",")
						weapon_id = t[1]
						weapon_id2 = t[2]
						self.model:SetWeapon2Resid(weapon_id2)
					end
				end
			end
		end



		local halo_id = self:GetHaloId(halo_used_imageid)
		local qilinbi_id = self:GetQiLinBiId(qilinbi_used_imageid, data.sex)
		local mask_id = self:GetMaskId(mask_used_imageid)
		local toushi_id = self:GetTouShiId(toushi_used_imageid)

		self.model:SetWeaponResid(weapon_id)
		self.model:SetRoleResid(role_res_id)
		-- self.model:SetHaloResid(halo_id)
		-- self.model:SetQilinBiResid(qilinbi_id,data.sex)
		-- self.model:SetMaskResid(mask_id)
		-- self.model:SetTouShiResid(toushi_id)
	else
		self.node_list["Txttop"].text.text = Language.KuafuGuildBattle.KfGuildShowNoOccupy
		self.node_list["Imgtop"]:SetActive(false)
		self.node_list["Imgxuwei"]:SetActive(true)
	end

	if self.ui_title == nil then
		local async_loader = AllocAsyncLoader(self, "PlayerTitle_loader")
		async_loader:Load("uis/views/player_prefab", "PlayerTitle", function(obj)
			if IsNil(obj) then
				return
			end

			self.ui_title = obj
			self.ui_title_img = LiuTitleRes.New(obj)
			self.ui_title.transform:SetParent(self.node_list["Title"].transform, false)
			self.ui_title_target = self.ui_title.transform:GetComponent(typeof(UIFollowTarget))
			local name_table = self.ui_title:GetComponent(typeof(UINameTable))
			self.ui_title_res = U3DObject(name_table:Find("Image"))
			self:SetUiTitle(self.ui_title_res)
			self.ui_title:SetActive(true)
		end)
	end
end

function LiuJieShowItem:GetHaloId(index)
	local halo_config = ConfigManager.Instance:GetAutoConfig("halo_auto")
	local image_cfg = nil
	local halo_res_id = 0
	if halo_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = halo_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = halo_config.image_list[index]
		end
		if image_cfg then
			halo_res_id = image_cfg.res_id
		end
	end
	return halo_res_id
end

function LiuJieShowItem:GetQiLinBiId(index, sex)
	local qilinbi_res_id = 0
	if index > 0 then
		qilinbi_res_id = QilinBiData.Instance:GetResIdByImageId(index, sex)
	end
	return qilinbi_res_id
end

function LiuJieShowItem:GetMaskId(index)
	local mask_res_id = 0
	if index > 0 then
		mask_res_id = MaskData.Instance:GetResIdByImageId(index)
	end
	return mask_res_id
end

function LiuJieShowItem:GetTouShiId(index)
	local toushi_res_id = 0
	if index > 0 then
		toushi_res_id = TouShiData.Instance:GetResIdByImageId(index)
	end
	return toushi_res_id
end

function LiuJieShowItem:SetUiTitle(ui_title_res)
	self.ui_title_res = ui_title_res
	self:FlushTitle()
end

function LiuJieShowItem:FlushTitle()
	local bundle, asset = ResPath.GetTitleIcon(self.current_title_id)
	if self.ui_title_res then
		self.ui_title_img:loadImage(bundle,asset)
		TitleData.Instance:LoadTitleEff(self.ui_title_res, self.current_title_id, true)
	end
end

function LiuJieShowItem:SetIndex(index)
	self.index = index
end

----------------------ui_title_res-----------------
LiuTitleRes = LiuTitleRes or BaseClass(BaseRender)
function LiuTitleRes:__init( )

end

function LiuTitleRes:loadImage(bundle,asset )
	self.node_list["Image"].image:LoadSprite(bundle,asset .. ".png")
end