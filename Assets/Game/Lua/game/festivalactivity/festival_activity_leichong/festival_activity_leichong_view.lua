FestivalLeiChongView = FestivalLeiChongView or BaseClass(BaseRender)

function FestivalLeiChongView:__init()
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self.jump_page = -1

	local page_count = #FestivalLeiChongData.Instance:GetVesTotalChargeCfg()

	self.cell_list = {}
	self.list_view = self.node_list["ListView"]
	self.list_view.list_page_scroll:SetPageCount(page_count)

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.FlushPage, self))

	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.ClickButton, self))
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.ClickButton, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.ClickChangePage, self, "left"))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.ClickChangePage, self, "right"))
	self.node_list["BtnAddCoin"].button:AddClickListener(BindTool.Bind(self.ClickAddCoin, self))
end

function FestivalLeiChongView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.jump_page = -1
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgItemShow"])
end

function FestivalLeiChongView:OpenCallBack()
	self:Flush()

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE, 
	RA_VERSION_TOTAL_CHARGE_OPERA_TYPE.RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO)
end

function FestivalLeiChongView:GetNumberOfCells()	
	return #FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
end

function FestivalLeiChongView:RefreshCell(cell, cell_index)
	self.scroller_load_complete = true
	if self.jump_page > 0 then
		self.list_view.list_page_scroll:JumpToPage(self.jump_page)
		self.jump_page = -1
	end
	local data = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()

	local prize_cell = self.cell_list[cell]
	if nil == prize_cell then
		prize_cell = LeiChongItemGroup.New(cell)
		self.cell_list[cell] = prize_cell
	end

	local index = cell_index + 1

	prize_cell:SetIndex(index)
	prize_cell:SetData(data[index])
end

function FestivalLeiChongView:ClickButton()
	local page = self.list_view.list_page_scroll:GetNowPage() or 0
	local max_page = self:GetNumberOfCells()
	local charge_value = FestivalLeiChongData.Instance:GetChargeValue()
	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()

	if charge_value >= cfg[page + 1].need_chognzhi then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE, 
		RA_VERSION_TOTAL_CHARGE_OPERA_TYPE.RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, page)

		page = page + 1
		if page > max_page then 
			return
		end
		self.list_view.list_page_scroll:JumpToPage(page)
	else
		 VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		 ViewManager.Instance:Open(ViewName.VipView)
	end
end

function FestivalLeiChongView:ClickAddCoin()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function FestivalLeiChongView:FlushPage()
	if not self.list_view.scroller.isActiveAndEnabled then 
		return 
	end

	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
	if next(cfg) == nil then return end
	local page = self.list_view.list_page_scroll:GetNowPage() or 0
	local received = FestivalLeiChongData.Instance:GetFetchFlag(page)
	local charge_value = FestivalLeiChongData.Instance:GetChargeValue()
	local max_page = self:GetNumberOfCells()
	local complete_flag = charge_value >= cfg[page + 1].need_chognzhi
	local received_flag = received == 1
	self.node_list["TxtTargetNum"].text.text = cfg[page + 1].need_chognzhi


	self.node_list["BtnRecharge"]:SetActive(not complete_flag and not received_flag)
	self.node_list["BtnGet"]:SetActive(complete_flag and not received_flag)
	self.node_list["ImgHasGet"]:SetActive(complete_flag and received_flag)

	self.node_list["BtnLeft"]:SetActive(page > 0)
	self.node_list["BtnRight"]:SetActive(page < max_page - 1)
end

function FestivalLeiChongView:ClickChangePage(dir)
	local page = self.list_view.list_page_scroll:GetNowPage()

	if dir == "left" then
		page = page - 1
	else
		page = page + 1
	end

	self:FlushPage()
	self.list_view.list_page_scroll:JumpToPage(page)
end

function FestivalLeiChongView:OnFlush()
	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
	if next(cfg) == nil then
		return
	end

	local page = self.list_view.list_page_scroll:GetNowPage()
	local received = FestivalLeiChongData.Instance:GetFetchFlag(page)
	local charge_value = FestivalLeiChongData.Instance:GetChargeValue()
	local jump_page = 0

	local complete_flag = charge_value >= cfg[page + 1].need_chognzhi
	local received_flag = received == 1
	self.node_list["TxtChargeCount"].text.text = charge_value

	self.node_list["BtnRecharge"]:SetActive(not complete_flag and not received_flag)
	self.node_list["BtnGet"]:SetActive(complete_flag and not received_flag)

	self:FlushModule()

	for k, v in pairs(cfg) do
		if charge_value >= v.need_chognzhi and FestivalLeiChongData.Instance:GetFetchFlag(v.seq) == 0 then
			jump_page = v.seq or 0
			break
		elseif charge_value < v.need_chognzhi then
			jump_page = v.seq or 0
			break
		end
	end

	-- if self.list_view.scroller.isActiveAndEnabled and self.scroller_load_complete then	
	-- 	self.list_view.list_page_scroll:JumpToPage(jump_page)
	-- else
	-- 	self.jump_page = jump_page
	-- end

	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetTime, self), 1)
		self:SetTime()
	end
end

function FestivalLeiChongView:SetTime()
	local time = ActivityData.Instance:GetActivityResidueTime(2213)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.node_list["TxtRemainTime"].text.text = TimeUtil.FormatSecond(time, 10)

end

function FestivalLeiChongView:FlushModule()
	local page = self.list_view.list_page_scroll:GetNowPage()
	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
	local index = HeadFrameData.Instance:GetPrefabByItemId(cfg[page + 1].res_id)
	local item_cfg = ItemData.Instance:GetItemConfig(cfg[page + 1].res_id)

	if item_cfg.is_display_role == DISPLAY_TYPE.HEAD_FRAME then
		self.node_list["ImgItemShow"]:SetActive(true)
		self.node_list["Display"]:SetActive(false)
		self.node_list["ImgItemShow"].image:LoadSprite(ResPath.GetHeadFrameIcon(index))
		local name = ToColorStr(item_cfg.name, item_cfg.color)
		-- self.node_list["TxtName"].text.text = name
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = item_cfg.power
		end
	else
		self.node_list["ImgItemShow"]:SetActive(false)
		self.node_list["Display"]:SetActive(true)
	end

	self:SetRoleModel(item_cfg.is_display_role, cfg[page + 1].res_id)
	self:SetFightPower(item_cfg.is_display_role, cfg[page + 1].res_id)

end



function FestivalLeiChongView:SetFightPower(display_role, item_id)
	local fight_power = 0
	local cfg = {}
	-- self.node_list["TxtName"].text.text = self.node_list["TxtName"].text.text
	
	if display_role == DISPLAY_TYPE.MOUNT then
		local mount_cfg = MountData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(mount_cfg) do
			if v ~= nil and v.item_id == item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.WING then
		local wing_cfg = WingData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(wing_cfg) do
			if v ~= nil and v.item_id == item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.FASHION or display_role == DISPLAY_TYPE.SHIZHUANG then
		local fashion_cfg = FashionData.Instance:GetShizhuangImgCfg()
		for k, v in pairs(fashion_cfg) do
			if v ~= nil and v.active_stuff_id == item_id then
				cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.HALO then
		local halo_cfg = HaloData.Instance:GetSpecialImagesCfg()
			for k, v in pairs(halo_cfg) do
				if v ~= nil and v.item_id == item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end

	elseif display_role == DISPLAY_TYPE.SPIRIT then
			self.limet_index = 1

	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		local fightmount_cfg = FightMountData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(fightmount_cfg) do
			if v ~= nil and v.item_id == item_id then
				cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.SHENGONG then
		local shenggong_cfg = ShengongData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(shenggong_cfg) do
			if v ~= nil and v.item_id == item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.SHENYI then
		local shenyi_cfg = ShenyiData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(shenyi_cfg) do
			if v ~= nil and v.item_id == item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		if goddess_cfg ~= nil and goddess_cfg.huanhua ~= nil then
			for k, v in pairs(goddess_cfg.huanhua) do
				if v ~= nil and v.active_item == item_id then
					cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				end
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))

	elseif display_role == DISPLAY_TYPE.FABAO then
		local fabao_cfg = FaBaoData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(fabao_cfg) do
			if v ~= nil and v.item_id == item_id then
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

function FestivalLeiChongView:SetRoleModel(display_role, item_id)
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0

	self.model:SetRotation(Vector3(0,0,0))
	self.model:SetScale(Vector3(0.8,0.8,0.8))

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
		self.model:ClearModel()
	end
	if self.temp_display_role ~= display_role or self.temp_display_role == DISPLAY_TYPE.FASHION or self.temp_display_role == DISPLAY_TYPE.SHIZHUANG or self.temp_display_role == DISPLAY_TYPE.WING then
		self.temp_display_role = display_role
		if display_role == DISPLAY_TYPE.MOUNT then
			local mount_cfg = MountData.Instance:GetSpecialImagesCfg()
			for k, v in pairs(mount_cfg) do
				if v ~= nil and v.item_id == item_id then
					bundle, asset = ResPath.GetMountModel(v.res_id)
					res_id = v.res_id
					self.node_list["TxtName"].text.text = v.image_name
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.WING then
			local wing_cfg = WingData.Instance:GetSpecialImagesCfg()
			for k, v in pairs(wing_cfg) do
				if v ~= nil and v.item_id == item_id then
					res_id = v.res_id
					self.node_list["TxtName"].text.text = v.image_name
					break
				end
			end
			self.model:SetRotation(Vector3(0,180,0))
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWingResid(res_id)
		elseif display_role == DISPLAY_TYPE.FASHION then
			local fashion_cfg = FashionData.Instance:GetShizhuangImgCfg()
			for k, v in pairs(fashion_cfg) do
				if v ~= nil and v.item_id == item_id then
					local weapon_res_id = 0
					local weapon2_res_id = 0
					local temp_res_id = 0
					if v.part_type == 1 then
						temp_res_id = v["resouce" .. (game_vo.prof % 10) .. game_vo.sex]
						weapon_res_id = main_role:GetWeaponResId()
						weapon2_res_id = main_role:GetWeapon2ResId()
					else
						temp_res_id = main_role:GetRoleResId()
						weapon_res_id = v["resouce" .. (game_vo.prof % 10) .. game_vo.sex]
						local temp = Split(weapon_res_id, ",")
						weapon_res_id = temp[1]
						weapon2_res_id = temp[2]
					end
					self.model:SetRoleResid(temp_res_id)
					self.model:SetWeaponResid(weapon_res_id)
					if weapon2_res_id then
						self.model:SetWeapon2Resid(weapon2_res_id)
					end
					self.node_list["TxtName"].text.text = v.image_name
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.SHIZHUANG then
			local image_cfg = nil
			local fashion_cfg = FashionData.Instance:GetShizhuangImgCfg()
			for k, v in pairs(fashion_cfg) do
				if v ~= nil and v.item_id == item_id then
					image_cfg = v
					self.node_list["TxtName"].text.text = v.image_name
					break
				end
			end
			if image_cfg then
				local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
				local res_id = image_cfg["resouce" .. (role_vo.prof % 10) .. role_vo.sex]
				self.model:SetRoleResid(res_id)
			end
		elseif display_role == DISPLAY_TYPE.HALO then
			local halo_cfg = HaloData.Instance:GetSpecialImagesCfg()
				for k, v in pairs(halo_cfg) do
					if v ~= nil and v.item_id == item_id then
						res_id = v.res_id
						
						self.node_list["TxtName"].text.text = v.image_name
						break
					end
				end

				self.model:SetRoleResid(main_role:GetRoleResId())
				self.model:SetHaloResid(res_id)
		elseif display_role == DISPLAY_TYPE.SPIRIT then
			local spirit_cfg = SpiritData.Instance:GetSpiritResourceCfg()
			for k, v in pairs(spirit_cfg) do
				if v ~= nil and v.id == item_id then
					bundle, asset = ResPath.GetSpiritModel(v.res_id)
					res_id = v.res_id
					self.node_list["TxtName"].text.text = v.image_name
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
			local fightmount_cfg = FightMountData.Instance:GetSpecialImagesCfg()
			for k, v in pairs(fightmount_cfg) do
				if v ~= nil and v.item_id == item_id then
					bundle, asset = ResPath.GetFightMountModel(v.res_id)
					res_id = v.res_id
					self.node_list["TxtName"].text.text = v.image_name
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.SHENGONG then
			local shengong_cfg = ShengongData.Instance:GetSpecialImagesCfg()
			for k, v in pairs(shengong_cfg) do
				if v ~= nil and v.item_id == item_id then
					res_id = v.res_id
					local info = {}
					info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
					info.weapon_res_id = v.res_id
					self:SetModel(info, DISPLAY_TYPE.SHENGONG)
					self.node_list["ImgItemShow"]:ChangeAsset("", "")
					self.node_list["TxtName"].text.text = v.image_name
					return
				end
			end
		elseif display_role == DISPLAY_TYPE.SHENYI then
			local shenyi_cfg = ShenyiData.Instance:GetSpecialImagesCfg()
			for k, v in pairs(shenyi_cfg) do
				if v ~= nil and v.item_id == item_id then
					res_id = v.res_id
					local info = {}
					info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
					info.wing_res_id = v.res_id
					self:SetModel(info, DISPLAY_TYPE.SHENYI)
					self.node_list["ImgItemShow"]:ChangeAsset("", "")
					self.node_list["TxtName"].text.text = v.image_name
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
							self.node_list["TxtName"].text.text = v.image_name
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
								self.node_list["TxtName"].text.text = v.image_name
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

			local index = CoolChatData.Instance:GetBubbleIndexByItemId(item_id) or 0
			if index > 0 then
				local PrefabName = "BubbleChat" .. index

				local async_loader = AllocAsyncLoader(self, "chatres_loader")
				async_loader:Load("uis/chatres_prefab", PrefabName, function(obj)
					if not IsNil(obj) then
						obj.transform:SetParent(self.ani_obj.transform, false)
					end
				end)
			end
		elseif display_role == DISPLAY_TYPE.ZHIBAO then
			local zhibao_cfg = ZhiBaoData.Instance:GetActivityHuanHuaCfg()
			for k, v in pairs(zhibao_cfg) do
				if v ~= nil and v.active_item == item_id then
					bundle, asset = ResPath.GetFaBaoModel(v.image_id)
					res_id = v.image_id
					self.node_list["TxtName"].text.text = v.image_name
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.TITLE then 	-- 称号
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			self.node_list["ImgItemShow"]:ChangeAsset(ResPath.GetTitleModel(item_cfg and item_cfg.param1 or 0))
			TitleData.Instance:LoadTitleEff(self.node_list["ImgItemShow"], item_cfg and item_cfg.param1 or 0, true)
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

	if display_role == DISPLAY_TYPE.MOUNT then
		self.model:SetRotation(Vector3(0,-35,0))
	end
	if display_role ~= DISPLAY_TYPE.TITLE then
		self.node_list["ImgItemShow"]:ChangeAsset("", "")
	end

	
end



-----------------------------LeiChongItemGroup--------------------------
LeiChongItemGroup = LeiChongItemGroup or BaseClass(BaseCell)

function LeiChongItemGroup:__init()
	self.cell_list = {}

	for i = 1, 4 do 
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		self.cell_list[i] = item_cell
	end


end

function LeiChongItemGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function LeiChongItemGroup:OnFlush()
	local item_group = ItemData.Instance:GetGiftItemList(self.data.reward_item[0].item_id)


	for i = 1, #self.cell_list do
		self.cell_list[i]:SetData(item_group[i])
		self.cell_list[i]:SetItemActive(item_group[i] ~= nil)
	end
end

