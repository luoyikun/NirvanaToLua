KaifuActivityPanelSix = KaifuActivityPanelSix or BaseClass(BaseRender)
--panel6 对应的是预制体的名字
local PaiHangBang_Index = {
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT,
		PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO,
	}

local RankType = {
		RANK_TAB_TYPE.MOUNT,
		RANK_TAB_TYPE.WING,
		RANK_TAB_TYPE.FASHION,
		RANK_TAB_TYPE.SHENBING,
		RANK_TAB_TYPE.FABAO,
		RANK_TAB_TYPE.FOOT,
		RANK_TAB_TYPE.HALO,
	}

local MAX_CELL_NUM = 3

function KaifuActivityPanelSix:__init(instance)
	self.list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	self.node_list["BtnPaiHangBang"].button:AddClickListener(BindTool.Bind(self.OnClickPaiHangBang, self))
	self.item_list = {}
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCapValue"])
	self.limet_index = 0

	for i = 1, MAX_CELL_NUM do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["CellItem"..i])
	end

	self.cell_list = {}
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["DisplayModel"].ui3d_display)
end

function KaifuActivityPanelSix:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.temp_display_role = nil
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["EffectTitle"])
end

-- 点击查看排行榜
function KaifuActivityPanelSix:OnClickPaiHangBang()
	local grade, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.activity_type)
	if RankCtrl.Instance and jinjie_type then
		RankCtrl.Instance:GetRankView():SetCurIndex(RankType[jinjie_type])
		RankCtrl.Instance:SendGetPersonRankListReq(PaiHangBang_Index[jinjie_type])
	end
	ViewManager.Instance:Open(ViewName.Ranking)
end

function KaifuActivityPanelSix:GetNumberOfCells()
	return (#KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type) - 1)
end

function KaifuActivityPanelSix:RefreshCell(cell, data_index)
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(self.activity_type)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelSixListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local is_get = KaifuActivityData.Instance:IsGetReward(data_index + 2, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(data_index + 2, self.activity_type)

	cell_item:SetData(cfg[data_index + 2], is_get, is_complete)
	cell_item.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self, cfg[data_index + 2], is_get, is_complete))
end

function KaifuActivityPanelSix:OnClickGet(cfg, is_get, is_complete)
	if cfg and is_complete and not is_get then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, cfg.seq or 0)
	end
end

function KaifuActivityPanelSix:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(self.activity_type)

	if rank_info then
		if rank_info.top1_uid and rank_info.top1_uid <= 0 then
			self.node_list["TxtCurTitle"].text.text = Language.Activity.NoFirstRole
		else
			self.node_list["TxtFirstName"].text.text = rank_info.role_name or ""
		end
		local flag = rank_info.top1_uid <= 0
		self.node_list["TxtCurTitle"]:SetActive(flag)
		self.node_list["TxtFirstName"]:SetActive(not flag)
	end

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.activity_type == self.temp_activity_type then
		self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	else
		if self.node_list["ScrollerListView"].scroller.isActiveAndEnabled then
			self.node_list["ScrollerListView"].scroller:ReloadData(0)
		end
	end



	self.temp_activity_type = self.activity_type
	self:SetFirstInfo(self.temp_activity_type)
	local item_gift_list = ItemData.Instance:GetGiftItemListByProf(cfg[1].reward_item[0].item_id)
	local display_role = 0
	local item_cfg = nil
	local item_id = 0
	local is_destory_effect = true

	-- self.node_list["EffectTitle"].image:LoadSprite(ResPath.GetTitleIcon())

	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_gift_list[k])
		if item_gift_list[k] then
			v:SetGiftItemId(cfg[1].reward_item[0].item_id)
			for _, v2 in pairs(cfg[1].item_special or {}) do
				if v2.item_id == item_gift_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end

			if is_destory_effect then
				v:IsDestoryActivityEffect(is_destory_effect)
				v:SetActivityEffect()
			end

			v:SetData(item_gift_list[k])
			item_cfg = ItemData.Instance:GetItemConfig(item_gift_list[k].item_id)
			if display_role == 0 then
				display_role = item_cfg and item_cfg.is_display_role or 0
				item_id = item_gift_list[k].item_id
			end
		end
	end
	self:SetFightPower(display_role, item_id)
end

function KaifuActivityPanelSix:SetRoleModel(display_role, item_id)
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0

	if self.model and self.temp_display_role ~= display_role then
		local halo_part = self.model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = self.model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = self.model.draw_obj:GetPart(SceneObjPart.Wing)
		if halo_part then
			halo_part:RemoveModel()
		end
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
	end

	if self.temp_display_role ~= display_role then
		self.temp_display_role = display_role
		if display_role == DISPLAY_TYPE.MOUNT then
			for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					bundle, asset = ResPath.GetMountModel(v.res_id)
					res_id = v.res_id
					break
				end
			end

		elseif display_role == DISPLAY_TYPE.WING then
			for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWingResid(res_id)

		elseif display_role == DISPLAY_TYPE.FASHION then
			for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
				if v.item_id == item_id then
					local weapon_res_id = 0
					local weapon2_res_id = 0
					local temp_res_id = 0

					if v.part_type == 1 then
						temp_res_id = v["resouce"..(game_vo.prof % 10)..game_vo.sex]
						weapon_res_id = main_role:GetWeaponResId()
						weapon2_res_id = main_role:GetWeapon2ResId()
					else
						temp_res_id = main_role:GetRoleResId()
						weapon_res_id = v["resouce"..(game_vo.prof % 10)..game_vo.sex]
						local temp = Split(weapon_res_id, ",")
						weapon_res_id = temp[1]
						weapon2_res_id = temp[2]
					end

					self.model:SetRoleResid(temp_res_id)
					self.model:SetWeaponResid(weapon_res_id)
					if weapon2_res_id then
						self.model:SetWeapon2Resid(weapon2_res_id)
					end
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.SHIZHUANG then
			local image_cfg = nil
			for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
				if v.item_id == item_id then
					image_cfg = v
					break
				end
			end
			if image_cfg then
				local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
				local res_id = image_cfg["resouce" .. (role_vo.prof % 10) .. role_vo.sex]
				self.model:SetRoleResid(res_id)
			end
		elseif display_role == DISPLAY_TYPE.HALO then
				for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
					if v.item_id == item_id then
						res_id = v.res_id
						break
					end
				end
				self.model:SetRoleResid(main_role:GetRoleResId())
				self.model:SetHaloResid(res_id)
		elseif display_role == DISPLAY_TYPE.SPIRIT then
			for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
				if v.id == item_id then
					bundle, asset = ResPath.GetSpiritModel(v.res_id)
					res_id = v.res_id
					break
				end
			end

		elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
			for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					bundle, asset = ResPath.GetFightMountModel(v.res_id)
					res_id = v.res_id
					break
				end
			end

		elseif display_role == DISPLAY_TYPE.SHENGONG then
			for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					local info = {}
					info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
					info.weapon_res_id = v.res_id
					self:SetModel(info, DISPLAY_TYPE.SHENGONG)
					return
				end
			end

		elseif display_role == DISPLAY_TYPE.SHENYI then
			for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					local info = {}
					info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
					info.wing_res_id = v.res_id
					self:SetModel(info, DISPLAY_TYPE.SHENYI)
					return
				end
			end

		elseif display_role == DISPLAY_TYPE.XIAN_NV then
			local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
			if goddess_cfg then
				local xiannv_resid = 0
				local xiannv_cfg = goddess_cfg.xiannv
				if xiannv_cfg then
					for k, v in pairs(xiannv_cfg) do
						if v.active_item == item_id then
							xiannv_resid = v.resid
							break
						end
					end
				end

				if xiannv_resid == 0 then
					local huanhua_cfg = goddess_cfg.huanhua
					if huanhua_cfg then
						for k, v in pairs(huanhua_cfg) do
							if v.active_item == item_id then
								xiannv_resid = v.resid
								break
							end
						end
					end
				end

				if xiannv_resid > 0 then
					local info = {}
					info.role_res_id = xiannv_resid
					bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
					self:SetModel(info, DISPLAY_TYPE.XIAN_NV)
					return
				end
				res_id = xiannv_resid
			end

		elseif display_role == DISPLAY_TYPE.BUBBLE then
			local index = CoolChatData.Instance:GetBubbleIndexByItemId(item_id)
			if index > 0 then
				local PrefabName = "BubbleChat" .. index
				
				self.async_loader:SetParent(self.ani_obj.transform)
				self.async_loader:Load("uis/chatres_prefab", PrefabName)
			end

		elseif display_role == DISPLAY_TYPE.ZHIBAO then
			for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
				if v.active_item == item_id then
					bundle, asset = ResPath.GetFaBaoModel(v.image_id)
					res_id = v.image_id
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.TITLE then 	-- 称号
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			local asset,bundle = ResPath.GetTitleModel(item_cfg and item_cfg.param1 or 0)
			self.node_list["EffectTitle"].image:LoadSprite(asset, bundle)
			TitleData.Instance:LoadTitleEff(self.node_list["EffectTitle"], item_cfg and item_cfg.param1 or 0, true)	
		end
	end

	if bundle and asset and self.model then
		self.model:SetMainAsset(bundle, asset)
		if display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
			self.model:SetTrigger(ANIMATOR_PARAM.REST)
		end

	elseif display_role == DISPLAY_TYPE.TITLE then
		if self.model then
			self.model:ClearModel()
		end
	end
end

function KaifuActivityPanelSix:SetFightPower(display_role, item_id)
	local fight_power = 0
	local cfg = {}

	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.FASHION or display_role == DISPLAY_TYPE.SHIZHUANG then
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.active_stuff_id == item_id then
				cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end

	elseif display_role == DISPLAY_TYPE.SPIRIT then
			self.limet_index = 1

	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		for k, v in pairs(goddess_cfg.huanhua) do
			if v.active_item == item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))

	elseif display_role == DISPLAY_TYPE.FABAO then
		for k, v in pairs(FaBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = FaBaoData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		cfg = ZhiBaoData.Instance:FindZhiBaoHuanHuaByStuffID()
		if cfg then
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
		end

	elseif display_role == DISPLAY_TYPE.TITLE then
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		cfg = TitleData.Instance:GetTitleCfg(item_cfg and item_cfg.param1 or 0)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
end

function KaifuActivityPanelSix:SetModel(info, display_type)
	self.model:ResetRotation()
	self.model:SetGoddessModelResInfo(info)
end

function KaifuActivityPanelSix:SetFirstInfo(activity_type)
	local rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(activity_type)
	if rank_info  == nil or next(rank_info) == nil then return end

	local avatar_path_big = AvatarManager.Instance:GetAvatarKey(rank_info.top1_uid, true)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(rank_info.top1_uid)
	if rank_info.top1_uid <= 0 then
		self.node_list["RawPortrait"]:SetActive(false)
		self.node_list["ImgPortrait"]:SetActive(false)
		self.node_list["TxtFirstName"] = ""
		return
	end

	self.node_list["TxtFirstName"] = rank_info.role_name
	AvatarManager.Instance:SetAvatar(rank_info.top1_uid, self.node_list["RawPortrait"], self.node_list["ImgPortrait"], rank_info.role_sex, rank_info.role_prof, true)
end



PanelSixListCell = PanelSixListCell or BaseClass(BaseRender)

local MAX_CELL_NUM = 3

function PanelSixListCell:__init(instance)
	self.cells = {}
	for i = 1, MAX_CELL_NUM do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["CellItem" .. i])
	end
end

function PanelSixListCell:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function PanelSixListCell:SetData(data, is_get, is_complete)
	if data == nil then return end
	self.node_list["TxtTitle"].text.text = data.description

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_list = {}
	local gift_id = 0

	for k, v in pairs(data.reward_item) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_id = v.item_id
			local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)
			if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
				item_gift_list = {v}
			end
			for _, v2 in pairs(item_gift_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
				if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
					table.insert(item_list, v2)
				end
			end
		else
			table.insert(item_list, v)
		end
	end

	local is_destory_effect = true
	for k, v in pairs(self.cells) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			for _, v2 in pairs(data.item_special or {}) do
				if v2.item_id == item_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end

			if is_destory_effect then
				v:IsDestoryActivityEffect(is_destory_effect)
				v:SetActivityEffect()
			end

			v:SetGiftItemId(gift_id)
			v:SetData(item_list[k])
		end
	end

	self.node_list["ImgHasGet"]:SetActive(is_get and not((data.cond2 and data.cond2 > 0) and not is_get))
	self.node_list["BtnGet"]:SetActive((data.cond2 > 0 and not is_get) and not(is_get))
	self.node_list["TxtLog"]:SetActive(not((data.cond2 > 0 and not is_get)))
	UI:SetButtonEnabled(self.node_list["BtnGet"], is_complete)
end

