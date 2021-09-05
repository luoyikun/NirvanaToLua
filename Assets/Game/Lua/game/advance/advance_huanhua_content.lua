AdvanceHuanHuaContent = AdvanceHuanHuaContent or BaseClass(BaseRender)
local MOVE_TIME = 0.5

function AdvanceHuanHuaContent:UIsMove()
	UITween.MoveShowPanel(self.node_list["InfoPanel"] , Vector3(400 , -350 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["SkillPanel"] , Vector3(-50 , -350 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["TitlePanel"] , Vector3(0 , 150 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["TitlePanel"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["BtnPanel"] , Vector3(0 , -500 , 0 ) , MOVE_TIME )
end

function AdvanceHuanHuaContent:LoadCallBack()
	self.node_list["BtnActivate"].button:AddClickListener(BindTool.Bind(self.OnClickActivate, self))
	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpGrade, self))
	self.node_list["BtnUseImage"].button:AddClickListener(BindTool.Bind(self.OnClickUseIma, self))
	self.node_list["BtnSuperPower"].button:AddClickListener(BindTool.Bind(self.ClickSuperPower, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
	
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)

	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.mount_special_image = nil
	self.res_id = nil
	self.fix_show_time = 10
	self.used_imageid = nil
	self.cell_list = {}
	self.prefab_preload_id = 0
	self.must_pro_num = {}
	self.must_pro_num[0] = 0
	self.must_pro_num[1] = 1
	self.used_special_id = nil
	self.old_show_index = TabIndex.mount_huan_hua

	self.now_show_index = AdvanceData.Instance:GetHuanHuaType()
	if self.now_show_index == TabIndex.mount_huan_hua then
		self.data = MountData.Instance
	elseif self.now_show_index == TabIndex.wing_huan_hua then
		self.data = WingData.Instance
	elseif self.now_show_index == TabIndex.halo_huan_hua then
		self.data = HaloData.Instance
	elseif self.now_show_index == TabIndex.foot_huan_hua then
		self.data = FootData.Instance
	elseif self.now_show_index == TabIndex.fight_mount_huan_hua then
		self.data = FightMountData.Instance
	elseif self.now_show_index == TabIndex.fabao_huan_hua then
		self.data = FaBaoData.Instance
	elseif self.now_show_index == TabIndex.fashion_huan_hua then
		self.data = FashionData.Instance
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		self.data = FashionData.Instance
	end
end

function AdvanceHuanHuaContent:CloseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.count ~= nil then
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = nil
	end
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.data = nil
	self.now_show_index = -1

	self.used_special_id = nil
	self.res_id = nil
	self.used_imageid = nil
end

function AdvanceHuanHuaContent:__delete()
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.mount_special_image = nil
	self.data = nil

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function AdvanceHuanHuaContent:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	self.is_show_skill_desc = nil
	self.img_num = nil

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.fight_text = nil
end

function AdvanceHuanHuaContent:ClickSuperPower()
	local data = nil
	if self.now_show_index ~= TabIndex.fashion_huan_hua then
		local special_cfg = self.data:GetSpecialImageCfg(self.index)
		local image_id = special_cfg and special_cfg.image_id or 0
		local index = image_id or 0
		if self.now_show_index == TabIndex.wuqi_huan_hua then
			data = self.data:GetSpecialHuanHuaShowData(self.index, SHIZHUANG_TYPE.WUQI)
		else
			data = self.data:GetSpecialHuanHuaShowData(index)
		end
	else
		local special_cfg = FashionData.Instance:GetShizhuangSpecialImg(self.index)
		local image_id = special_cfg and special_cfg.image_id or 0
		local index = image_id or 0
		data = FashionData.Instance:GetSpecialHuanHuaShowData(index, SHIZHUANG_TYPE.BODY)
	end
	if data then
		TipsCtrl.Instance:ShowSpecialHuanHuaViewView(data)
	end
end

function AdvanceHuanHuaContent:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AdvanceHuanHuaContent:GetMountNumberOfCells()
	if self.now_show_index == TabIndex.fashion_huan_hua then
		local cfg_list = self.data:GetShizhuangSpecialImgCfg()
		return #cfg_list
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		local cfg_list = self.data:GetSpecialImagesCfg()
		return #cfg_list
	else
		local cfg_list = self.data:GetHuanHuaCfgList()
		return #cfg_list
	end
end

function AdvanceHuanHuaContent:RefreshMountCell(cell, cell_index)
	local mount_special_image = {}
	if self.now_show_index == TabIndex.fashion_huan_hua then
		mount_special_image = FashionData.Instance:GetShizhuangSpecialImgCfg()
		local index = mount_special_image[cell_index + 1] and mount_special_image[cell_index + 1].image_id or cell_index + 1
		is_show = FashionData.Instance:CanHuanhuaUpgradeList()[index] ~= nil
		is_specal = TabIndex.fashion_huan_hua
		
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		mount_special_image = self.data:GetSpecialImagesCfg()
		local index = mount_special_image[cell_index + 1] and mount_special_image[cell_index + 1].image_id or cell_index + 1
		is_show =self.data:CanWuQiHuanhuaUpgradeList()[index] ~= nil
		is_specal = TabIndex.wuqi_huan_hua
		
	else
		mount_special_image = self.data:GetHuanHuaCfgList()
		is_show =self.data:CanHuanhuaUpgradeList()[mount_special_image[cell_index + 1].image_id] ~= nil
		if self.now_show_index == TabIndex.fabao_huan_hua then
			is_specal = TabIndex.fabao_huan_hua
		else
			is_specal = 0
		end
	end

	local info_list = AdvanceData.Instance:AdvanceInfo()

	local mount_cell = self.cell_list[cell]
	if mount_cell == nil then
		mount_cell = HuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = mount_cell
	end
	
	local data = {}
	data.head_id = mount_special_image[cell_index + 1].head_id
	data.image_name = mount_special_image[cell_index + 1].image_name
	data.item_id = mount_special_image[cell_index + 1].item_id
	data.index = mount_special_image[cell_index + 1].image_id
	data.is_show = is_show
	data.is_specal = is_specal
	data.info_list = info_list
	mount_cell:SetData(data)
	mount_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
	mount_cell:SetHighLight(self.index == mount_special_image[cell_index + 1].image_id)
	mount_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, mount_special_image[cell_index + 1], data.index, mount_cell))
end

function AdvanceHuanHuaContent:OpenFlush()
	self:UIsMove()

	self.now_show_index = AdvanceData.Instance:GetHuanHuaType()
	if self.now_show_index == TabIndex.mount_huan_hua then
		self.data = MountData.Instance
	elseif self.now_show_index == TabIndex.wing_huan_hua then
		self.data = WingData.Instance
	elseif self.now_show_index == TabIndex.halo_huan_hua then
		self.data = HaloData.Instance
	elseif self.now_show_index == TabIndex.foot_huan_hua then
		self.data = FootData.Instance
	elseif self.now_show_index == TabIndex.fight_mount_huan_hua then
		self.data = FightMountData.Instance
	elseif self.now_show_index == TabIndex.fabao_huan_hua then
		self.data = FaBaoData.Instance
	elseif self.now_show_index == TabIndex.fashion_huan_hua then
		self.data = FashionData.Instance
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		self.data = FashionData.Instance
	end

	if self.now_show_index == TabIndex.mount_huan_hua or self.now_show_index == TabIndex.wing_huan_hua or 
		self.now_show_index == TabIndex.halo_huan_hua or self.now_show_index == TabIndex.foot_huan_hua or 
		self.now_show_index == TabIndex.fight_mount_huan_hua or self.now_show_index == TabIndex.fabao_huan_hua then
		local cfg_list = self.data:GetHuanHuaCfgList()
		if cfg_list then
			self.index = cfg_list[1] and cfg_list[1].image_id or 1
			self:OnFlushCommonAdvance()
		end
	elseif self.now_show_index == TabIndex.fashion_huan_hua then
		local cfg_list = self.data:GetShizhuangSpecialImgCfg()
		if cfg_list then
			self.index = cfg_list[1] and cfg_list[1].image_id or 1
			self:OnFlushFashionAdvance()
		end
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		local cfg_list = self.data:GetSpecialImagesCfg()
		if cfg_list then
			self.index = cfg_list[1] and cfg_list[1].image_id or 1
			self:OnFlushWuQiAdvance()
		end
	end
end

--点击激活按钮
function AdvanceHuanHuaContent:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local mount_special_image = {}
	if self.now_show_index == TabIndex.fashion_huan_hua then
		mount_special_image = FashionData.Instance:GetShizhuangSpecialImage()
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		mount_special_image = FashionData.Instance:GetWuQiImageCfg()
	else
		mount_special_image = self.data:GetSpecialImagesCfg()
	end
	self.item_id = mount_special_image[self.index].item_id
	for k, v in pairs(data_list) do
		if v.item_id == self.item_id then
			PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
			return
		end
	end
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
		return
	end

	if item_cfg.bind_gold == 0 then
		TipsCtrl.Instance:ShowShopView(self.item_id, 2)
		return
	end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
	return
end

--点击升级按钮
function AdvanceHuanHuaContent:OnClickUpGrade()
	local attr_cfg = {}
	local cfg_grade = -1
	local mount_special_image = {}
	if self.now_show_index == TabIndex.fashion_huan_hua then
		attr_cfg = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(self.index)
		cfg_grade = attr_cfg and FashionData.Instance:GetFashionSpecialImageMaxUpLevelById(attr_cfg.special_img_id) or 0
	-- elseif self.now_show_index == TabIndex.wuqi_huan_hua then
	-- 	attr_cfg = FashionData.Instance:GetSpecialImageUpgradeInfo(self.index)
	-- 	cfg_grade = attr_cfg and FashionData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) or 0
	else
		attr_cfg = self.data:GetSpecialImageUpgradeInfo(self.index)
		cfg_grade = attr_cfg and self.data:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) or 0
	end

	if nil ~= attr_cfg and nil ~= next(attr_cfg) then
		if attr_cfg.grade >= cfg_grade then
			return
		end
		if ItemData.Instance:GetItemNumInBagById(attr_cfg.stuff_id) < attr_cfg.stuff_num then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[attr_cfg.stuff_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(attr_cfg.stuff_id)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(attr_cfg.stuff_id, 2)
				return
			end

			local func = function(stuff_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(stuff_id, item_num, is_bind, is_use)
			end

			TipsCtrl.Instance:ShowCommonBuyView(func, attr_cfg.stuff_id, nil, attr_cfg.stuff_num)
			return
		end
	end
	self:SpecialImaUpgrade()
end

function AdvanceHuanHuaContent:SpecialImaUpgrade()
	if self.now_show_index == TabIndex.mount_huan_hua then
		AdvanceCtrl.Instance:MountSpecialImaUpgrade(self.index)
	elseif self.now_show_index == TabIndex.wing_huan_hua then
		AdvanceCtrl.Instance:WingSpecialImaUpgrade(self.index)
	elseif self.now_show_index == TabIndex.halo_huan_hua then
		AdvanceCtrl.Instance:HaloSpecialImaUpgrade(self.index)
	elseif self.now_show_index == TabIndex.foot_huan_hua then
		AdvanceCtrl.Instance:FootSpecialImaUpgrade(self.index)
	elseif self.now_show_index == TabIndex.fight_mount_huan_hua then
		AdvanceCtrl.Instance:FightMountSpecialImaUpgrade(self.index)
	elseif self.now_show_index == TabIndex.fabao_huan_hua then
		AdvanceCtrl.Instance:FaBaoSpecialImaUpgrade(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_FABAOSPECIALIMGUPGRADE , self.index)
	elseif self.now_show_index == TabIndex.fashion_huan_hua then
		FashionCtrl.Instance:SendFashionSpecialImgUpgradeReq(SHIZHUANG_TYPE.BODY, self.index)
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		FashionCtrl.Instance:SendFashionSpecialImgUpgradeReq(SHIZHUANG_TYPE.WUQI, self.index)
	end
end

--点击使用当前形象
function AdvanceHuanHuaContent:OnClickUseIma()
	if self.now_show_index == TabIndex.mount_huan_hua then
		MountCtrl.Instance:SendUseMountImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
	elseif self.now_show_index == TabIndex.wing_huan_hua then
		WingCtrl.Instance:SendUseWingImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
	elseif self.now_show_index == TabIndex.halo_huan_hua then
		HaloCtrl.Instance:SendUseHaloImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
	elseif self.now_show_index == TabIndex.foot_huan_hua then
		FootCtrl.Instance:SendUseFootImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
	elseif self.now_show_index == TabIndex.fight_mount_huan_hua then
		FightMountCtrl.Instance:SendUseFightMountImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
	elseif self.now_show_index == TabIndex.fabao_huan_hua then
		FaBaoCtrl.Instance:SendUseFaBaoImage(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_USESPECIALIMG, self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
	elseif self.now_show_index == TabIndex.fashion_huan_hua then
		FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.BODY, 1, self.index)
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.WUQI, 1, self.index)
	end
end

function AdvanceHuanHuaContent:OnClickListCell(mount_special_data, index, mount_cell)
	self.mount_special_image = mount_special_data
	mount_cell:SetHighLight(true)
	if self.index == index then return end
	if self.count ~= nil then
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = nil
	end
	self.index = index or 1
	self.item_id = mount_special_data.item_id
	self:SetSpecialImageAttr(mount_special_data, index)
end

--获取激活坐骑符数量
function AdvanceHuanHuaContent:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	end
	self.must_pro_num[0] = count
	self.node_list["TxtNeedPro"].text.text = string.format("%s / %s",self.must_pro_num[0],self.must_pro_num[1])
end

function AdvanceHuanHuaContent:SetSpecialImageAttr(mount_special_data, index)
	if self.old_show_index ~= self.now_show_index then
		UIScene:DeleteModel()
	end
	self.node_list["LeastTime"]:SetActive(false)
	if mount_special_data == nil then
		return
	end

	if self.now_show_index == TabIndex.fashion_huan_hua then
		self:SetFashionSpecialImageAttr(mount_special_data, index)
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		self:SetWuQiSpecialImageAttr(mount_special_data, index)
	else
		if self.now_show_index == TabIndex.mount_huan_hua then
			self:SetMountModle(index)
		elseif self.now_show_index == TabIndex.wing_huan_hua then
			self:SetWingModle(index)
		elseif self.now_show_index == TabIndex.halo_huan_hua then
			self:SetHaloModle(index)
		elseif self.now_show_index == TabIndex.foot_huan_hua then
			self:SetFootModle(index)
		elseif self.now_show_index == TabIndex.fight_mount_huan_hua then
			self:SetFightMountModle(index)
		elseif self.now_show_index == TabIndex.fabao_huan_hua then
			self:SetFaBaoModle(index)
		end
		self:SetOtherSpecialImageAttr(mount_special_data, index)
	end
	self.old_show_index = self.now_show_index
end

function AdvanceHuanHuaContent:SetFashionSpecialImageAttr(mount_special_data, index)
	local image_cfg = FashionData.Instance:GetShizhuangSpecialImg(mount_special_data.image_id)
	local attr_cfg = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(mount_special_data.image_id)
	local bit_list = FashionData.Instance:GetSpecialActiveFlag()
	if not image_cfg or not attr_cfg then return end
	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)

	self.grade = 0 ~= bit_list[index] and attr_cfg.grade or -1
	self.node_list["ZuoQiName"].text.text = "Lv.".. attr_cfg.grade .. " " .. "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5] .. ">" .. mount_special_data.image_name .. "</color>"
	self.must_pro_num[1] = attr_cfg.stuff_num or 1
	self.node_list["TxtNeedPro"].text.text = string.format("%s / %s",self.must_pro_num[0],self.must_pro_num[1])
	self:GetHaveProNum(mount_special_data.item_id, attr_cfg.stuff_num)

	local is_show_super = FashionData.Instance:IsShowSuperPower(mount_special_data.image_id, SHIZHUANG_TYPE.BODY)
	local is_active_super = FashionData.Instance:GetStarIsShowSuperPower(mount_special_data.image_id, SHIZHUANG_TYPE.BODY)
	local need_reach_level = FashionData.Instance:GetActiveSuperPowerNeedLevel(mount_special_data.image_id, SHIZHUANG_TYPE.BODY)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	if is_show_super and not is_active_super then
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end

	local special_image_grade = FashionData.Instance:GetSingleSpecialImageGrade(mount_special_data.image_id, SHIZHUANG_TYPE.BODY)
	local attr0 = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(mount_special_data.image_id)
	local attr1 = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(mount_special_data.image_id, special_image_grade + 1)
	local max_grade = self.data:GetFashionSpecialImageMaxUpLevelById(mount_special_data.image_id)
	self:SetAttr(special_image_grade, attr0, attr1, max_grade, mount_special_data.image_id)
	local info_list = FashionData.Instance:GetFashionInfo()
	self.used_imageid = info_list.used_imageid
	self:CleatTime(info_list, mount_special_data)
	self:SetFashionModle(index)

	local data = {item_id = mount_special_data.item_id, is_bind = 0}
	self.item:SetData(data)
	self:IsGrayUpgradeButton(self.index)
	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
end

function AdvanceHuanHuaContent:SetWuQiSpecialImageAttr(mount_special_data, index)
	local image_cfg = FashionData.Instance:GetSpecialImageCfg(mount_special_data.image_id)
	local attr_cfg = FashionData.Instance:GetSpecialImageUpgradeInfo(mount_special_data.image_id)
	local bit_list = FashionData.Instance:GetWuQiSpecialActiveFlag()
	if not image_cfg or not attr_cfg then return end

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	self.grade = 0 ~= bit_list[index] and attr_cfg.grade or -1
	self.node_list["ZuoQiName"].text.text = "Lv.".. attr_cfg.grade .. " " .. "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5] .. ">" .. mount_special_data.image_name .. "</color>"
	self.must_pro_num[1] = attr_cfg.stuff_num or 1
	self.node_list["TxtNeedPro"].text.text = string.format("%s / %s",self.must_pro_num[0],self.must_pro_num[1])
	self:GetHaveProNum(mount_special_data.item_id, attr_cfg.stuff_num)

	local is_show_super = FashionData.Instance:IsShowSuperPower(mount_special_data.image_id, SHIZHUANG_TYPE.WUQI)
	local is_active_super = FashionData.Instance:GetStarIsShowSuperPower(mount_special_data.image_id, SHIZHUANG_TYPE.WUQI)
	local need_reach_level = FashionData.Instance:GetActiveSuperPowerNeedLevel(mount_special_data.image_id, SHIZHUANG_TYPE.WUQI)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	if is_show_super and not is_active_super then
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end

	local special_image_grade = FashionData.Instance:GetSingleSpecialImageGrade(mount_special_data.image_id, SHIZHUANG_TYPE.WUQI)
	local attr0 = self.data:GetSpecialImageUpgradeInfo(mount_special_data.image_id)
	local attr1 = self.data:GetSpecialImageUpgradeInfo(mount_special_data.image_id, nil, true)
	local max_grade = self.data:GetSpecialImageMaxUpLevelById(mount_special_data.image_id)
	self:SetAttr(special_image_grade, attr0, attr1, max_grade, mount_special_data.image_id)
	local info_list = FashionData.Instance:GetWuQiInfo()
	self.used_imageid = info_list.used_imageid
	self:CleatTime(info_list, mount_special_data)
	self:SetWuQiModle(index)

	local data = {item_id = mount_special_data.item_id, is_bind = 0}
	self.item:SetData(data)
	self:IsGrayUpgradeButton(self.index)
	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
end

function AdvanceHuanHuaContent:SetOtherSpecialImageAttr(mount_special_data, index)
	local image_cfg = self.data:GetSpecialImageCfg(index)
	local attr_cfg = self.data:GetSpecialImageUpgradeInfo(mount_special_data.image_id)
	local info_list = AdvanceData.Instance:AdvanceInfo()
	self.used_imageid = info_list.used_imageid
	local bit_list = info_list.active_special_image_flag
	if not image_cfg or not attr_cfg or not bit_list then return end

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	self.grade = 0 ~= bit_list[index] and attr_cfg.grade or -1
	self.node_list["ZuoQiName"].text.text = "Lv.".. attr_cfg.grade .. " " .. "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5] .. ">" .. mount_special_data.image_name .. "</color>"
	self.must_pro_num[1] = attr_cfg.stuff_num or 1
	self.node_list["TxtNeedPro"].text.text = string.format("%s / %s",self.must_pro_num[0],self.must_pro_num[1])
	self:GetHaveProNum(mount_special_data.item_id, attr_cfg.stuff_num)

	local is_show_super = self.data:IsShowSuperPower(mount_special_data.image_id)
	local is_active_super = self.data:GetStarIsShowSuperPower(mount_special_data.image_id)
	local need_reach_level = self.data:GetActiveSuperPowerNeedLevel(mount_special_data.image_id)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	if is_show_super and not is_active_super then
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end

	local special_image_grade = self.data:GetSingleSpecialImageGrade(mount_special_data.image_id)
	local attr0 = self.data:GetSpecialImageUpgradeInfo(index)
	local attr1 = self.data:GetSpecialImageUpgradeInfo(index, special_image_grade, true)
	local max_grade = self.data:GetSpecialImageMaxUpLevelById(mount_special_data.image_id)
	self:SetAttr(special_image_grade, attr0, attr1, max_grade, index)

	local data = {item_id = mount_special_data.item_id, is_bind = 0}
	self.item:SetData(data)
	self:IsGrayUpgradeButton(self.index)
	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
end

function AdvanceHuanHuaContent:SetAttr(special_image_grade, attr0, attr1, max_grade, special_index)
	local switch_attr_list_1 = CommonDataManager.GetOrderAttributte(attr1)
	local switch_attr_list_0 = CommonDataManager.GetOrderAttributte(attr0)
	if special_image_grade == 0 then
		local index = 0
		for k, v in pairs(switch_attr_list_1) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = switch_attr_list_0[k].value or 0
				self.node_list["Arrow" .. index]:SetActive(true)
				self.node_list["AddValue" .. index]:SetActive(true)
				self.node_list["AddValue" .. index].text.text = (switch_attr_list_1[k].value - switch_attr_list_0[k].value) or 0
			end
		end
		local capability = CommonDataManager.GetCapability(attr1)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
	elseif special_image_grade >= max_grade then
		local index = 0
		for k, v in pairs(switch_attr_list_0) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = v.value
				self.node_list["Arrow" .. index]:SetActive(false)
				self.node_list["AddValue" .. index]:SetActive(false)
			end
		end
		local capability = CommonDataManager.GetCapability(attr0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
	else
		local index = 0
		for k, v in pairs(switch_attr_list_0) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = v.value
				self.node_list["Arrow" .. index]:SetActive(true)
				self.node_list["AddValue" .. index]:SetActive(true)
				self.node_list["AddValue" .. index].text.text = (switch_attr_list_1[k].value - switch_attr_list_0[k].value) or 0
			end
		end
		local capability = CommonDataManager.GetCapability(attr0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
	end

	local active_grade, attr_type, attr_value = self.data:GetHuanHuaSpecialAttrActiveType(nil, special_index)
	if active_grade and attr_type and attr_value then
		if special_image_grade < active_grade then
			local str = string.format(Language.Advance.OpenLevel, active_grade)
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = special_image_grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = self.data:GetHuanHuaSpecialAttrActiveType(i, special_index)
				if next_attr_value then
					if next_attr_value ~= attr_value then
						special_attr = next_attr_value - attr_value
						str = string.format(Language.Advance.NextLevelAttr, next_active_grade, special_attr / 100)
						break
					end
				end
			end
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		end
	else
		self.node_list["TxtSpecialAttr"]:SetActive(false)
	end
end

function AdvanceHuanHuaContent:CleatTime(info_list, mount_special_data)
	if info_list and info_list.valid_timestamp_list then
		local cleartime = info_list.valid_timestamp_list[mount_special_data.image_id]
		self.node_list["LeastTime"]:SetActive(cleartime ~= 0)
		local servertime = TimeCtrl.Instance:GetServerTime()
		local offtime = cleartime - servertime
		if cleartime ~= 0 and self.count == nil then
			self:ClickTimer(offtime)
			self.count = CountDown.Instance:AddCountDown(offtime, 1, function ()
				offtime = offtime - 1
				if offtime <= 0 then
					if self.count ~= nil then
						CountDown.Instance:RemoveCountDown(self.count)
						self.count = nil
					end
				else
					local temptime = TimeUtil.FormatSecond(offtime - 1, 10)
					self.node_list["TxtTime"].text.text = string.format(Language.Advance.LeastTime3, tostring(temptime))
				end
			end)
		end
	end
end

function AdvanceHuanHuaContent:ClickTimer(offtime)
	offtime = offtime - 1
	local temptime = TimeUtil.FormatSecond(offtime - 1, 10)
	self.node_list["TxtTime"].text.text = string.format(Language.Advance.LeastTime3,tostring(temptime))
end

function AdvanceHuanHuaContent:SetMountModle(index)
	local image_cfg = MountData.Instance:GetSpecialImageCfg(index)
	if self.res_id == image_cfg.res_id then
		return
	end
	self.res_id = image_cfg.res_id

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
	transform.rotation = Quaternion.Euler(0, -173, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetLayer(1, 1)
			part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		obj.gameObject.transform.localPosition = Vector3(0, 0, 0)

		local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("mount_huanhua", self.res_id)
		if advance_transform_cfg then
			obj.gameObject.transform.localPosition = advance_transform_cfg.position
			obj.gameObject.transform.localRotation = advance_transform_cfg.rotation
		else
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -60, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetMountModel(self.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

function AdvanceHuanHuaContent:SetWingModle(index)
	local image_cfg = WingData.Instance:GetSpecialImageCfg(index)
	if self.res_id == image_cfg.res_id then
		return
	end
	self.res_id = image_cfg.res_id

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -172, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			if prof == GameEnum.ROLE_PROF_1 then      --男剑
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 158, 0)
			elseif prof == GameEnum.ROLE_PROF_2 then  --男琴
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -155, 0)
			elseif prof == GameEnum.ROLE_PROF_3 then  --女剑
				 obj.gameObject.transform.localRotation = Quaternion.Euler(0, 169, 0)
			elseif prof == GameEnum.ROLE_PROF_4 then  -- 小萝莉
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -170, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -170, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetWingModel(image_cfg.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			local info = {}
			info.wing_info = {used_imageid = image_cfg.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID}
			info.prof = prof
			info.sex = vo.sex
			info.is_not_show_weapon = true
			local fashion_info = FashionData.Instance:GetFashionInfo()
			local is_used_special_img = fashion_info.is_used_special_img
			info.is_normal_fashion = is_used_special_img == 0 and true or false
			info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}

			UIScene:SetRoleModelResInfo(info)
		end)
end

function AdvanceHuanHuaContent:SetHaloModle(index)
	local image_cfg = HaloData.Instance:GetSpecialImageCfg(index)
	if self.res_id == image_cfg.res_id then
		return
	end
	self.res_id = image_cfg.res_id

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -172, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetHaloModel(image_cfg.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			local info = {}
			info.halo_info = {used_imageid = image_cfg.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID}
			info.prof = PlayerData.Instance:GetRoleBaseProf()
			info.sex = vo.sex
			info.is_not_show_weapon = true
			local fashion_info = FashionData.Instance:GetFashionInfo()
			local is_used_special_img = fashion_info.is_used_special_img
			info.is_normal_fashion = is_used_special_img == 0 and true or false
			info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
			UIScene:SetRoleModelResInfo(info)
		end)
end

function AdvanceHuanHuaContent:SetFootModle(index)
	local image_cfg = FootData.Instance:GetSpecialImageCfg(index)
	if self.res_id == image_cfg.res_id then
		return
	end
	self.res_id = image_cfg.res_id

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -172, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -90, 0)
		end
	end
	
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetFootModel(image_cfg.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			local info = {}
			info.foot_info = {used_imageid = image_cfg.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID}
			info.prof = PlayerData.Instance:GetRoleBaseProf()
			info.sex = vo.sex
			info.is_not_show_weapon = true
			local fashion_info = FashionData.Instance:GetFashionInfo()
			local is_used_special_img = fashion_info.is_used_special_img
			info.is_normal_fashion = is_used_special_img == 0 and true or false
			info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
			UIScene:SetRoleModelResInfo(info, false, false, false, false, true)
		end)
end

function AdvanceHuanHuaContent:SetFightMountModle(index)
	local image_cfg = FightMountData.Instance:GetSpecialImageCfg(index)
	if self.res_id == image_cfg.res_id then
		return
	end
	self.res_id = image_cfg.res_id

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "fightmount")
	transform.rotation = Quaternion.Euler(25, -170, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			-- model:SetTrigger(ANIMATOR_PARAM.REST)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetFightMountModel(image_cfg.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

function AdvanceHuanHuaContent:SetFaBaoModle(index)
	local image_cfg = FaBaoData.Instance:GetSpecialImageCfg(index)
	if self.res_id == image_cfg.res_id then
		return
	end
	self.res_id = image_cfg.res_id

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "baoju")
	transform.rotation = Quaternion.Euler(0, -170, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 30, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetFaBaoModel(image_cfg.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

function AdvanceHuanHuaContent:SetFashionModle(index)
	local image_cfg = FashionData.Instance:GetShizhuangSpecialImg(index)
	local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local res_id = image_cfg["resouce" .. prof .. role_vo.sex]
	if self.res_id == res_id then
		return
	end
	self.res_id = res_id

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -172, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetFashionShizhuangModel(res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)

	self.used_special_id = FashionData.Instance:GetShizhuangUseSpecialImg()
end

function AdvanceHuanHuaContent:SetWuQiModle(index)
	local image_cfg = FashionData.Instance:GetWuQiSpecialImageCfg(index)
	local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local res_id = image_cfg["resouce" .. prof .. role_vo.sex]
	if self.res_id == res_id then
		return
	end
	self.res_id = res_id
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -172, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.FIGHT)
			if prof == GameEnum.ROLE_PROF_4 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local load_list = {}
	if tonumber(prof .. role_vo.sex) == 30 then   
		local tmp_split_list = Split(res_id, ",")
		for i = 1, #tmp_split_list do
			load_list[i] = ResPath.GetWeaponModel(tmp_split_list[i])
		end
	else
		local  bundle, asset = ResPath.GetWeaponModel(res_id)
		load_list = {{bundle,asset}}
	end

	PrefabPreload.Instance:StopLoad(self.pre_load_id)
	self.pre_load_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local info = {}
		info.prof = PlayerData.Instance:GetRoleBaseProf()
		info.sex = vo.sex
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		info.is_normal_wuqi = false
		info.shizhuang_part_list = {{image_id = image_cfg.image_id}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
		UIScene:SetRoleModelResInfo(info, false, false, false, true)
	end)
end


--设置激活按钮显示和隐藏
function AdvanceHuanHuaContent:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = {}
	local active_flag = {}
	local is_fashion = false
	if self.now_show_index == TabIndex.fashion_huan_hua then
		info_list = FashionData.Instance:GetFashionInfo()
		active_flag = FashionData.Instance:GetSpecialActiveFlag()
		is_fashion = true
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		info_list = FashionData.Instance:GetWuQiInfo()
		active_flag = FashionData.Instance:GetWuQiSpecialActiveFlag()
		is_fashion = true
	else
		info_list = AdvanceData.Instance:AdvanceInfo()
		active_flag = info_list.active_special_image_flag
		is_fashion = false
	end
	if is_fashion then
		local is_active = (0 ~= active_flag[image_id])
		local is_used_special_img = (1 == info_list.is_used_special_img) --true为不使用 false为使用
		self.node_list["BtnActivate"]:SetActive(not is_active) --把64位转换成table,返回1，表示激活
		if is_active then
			if is_used_special_img then
				self.node_list["BtnUseImage"]:SetActive(image_id ~= info_list.use_special_img)
				self.node_list["BtnImageUsed"]:SetActive(image_id == info_list.use_special_img)
			else
				self.node_list["BtnUseImage"]:SetActive(true)
				self.node_list["BtnImageUsed"]:SetActive(false)
			end
		else
			self.node_list["BtnUseImage"]:SetActive(false)
			self.node_list["BtnImageUsed"]:SetActive(false)
		end
	else
		local bit_list = active_flag
		self.node_list["BtnActivate"]:SetActive(bit_list[image_id] and 0 == bit_list[image_id])
		self.node_list["BtnUseImage"]:SetActive(bit_list[image_id] and 0 ~= bit_list[image_id])
		self.node_list["BtnImageUsed"]:SetActive(bit_list[image_id] and 0 ~= bit_list[image_id])
		local used_imageid = 0
		if info_list.is_used_special_img and info_list.is_used_special_img == 1 then
			used_imageid = info_list.used_special_id
		else
			used_imageid = info_list.used_imageid
		end
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			self.node_list["BtnUseImage"]:SetActive(bit_list[image_id] and image_id ~= (used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
														and 0 ~= bit_list[image_id])
			self.node_list["BtnImageUsed"]:SetActive(bit_list[image_id] and image_id == (used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
														and 0 ~= bit_list[image_id])
		else
			self.node_list["BtnUseImage"]:SetActive(bit_list[image_id] and 0 ~= bit_list[image_id])
			self.node_list["BtnImageUsed"]:SetActive(false)
		end
	end
end

--设置升级按钮显示和隐藏
function AdvanceHuanHuaContent:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end

	local special_img_up = {}
	local info_list = {}
	if self.now_show_index == TabIndex.fashion_huan_hua then
		local special_img_up = FashionData.Instance:GetFashionSpecialImageUpgradeCfg()
		local bit_list = FashionData.Instance:GetSpecialActiveFlag()
		if special_img_up[image_id] then
			self.node_list["BtnUpGrade"]:SetActive(0 ~= bit_list[image_id])
		else
			self.node_list["BtnUpGrade"]:SetActive(false)
		end
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		local special_img_up = FashionData.Instance:GetSpecialImageUpgradeCfg()
		local bit_list = FashionData.Instance:GetWuQiSpecialActiveFlag()
		if special_img_up[image_id] then
			self.node_list["BtnUpGrade"]:SetActive(0 ~= bit_list[image_id])
		else
			self.node_list["BtnUpGrade"]:SetActive(false)
		end
	else
		info_list = AdvanceData.Instance:AdvanceInfo()
		special_img_up = self.data:GetSpecialImageUpgradeCfg()
		self:IsShowBtnGrade(info_list, special_img_up, image_id)
	end
end

function AdvanceHuanHuaContent:IsShowBtnGrade(info_list, special_img_up, image_id)
	local bit_list = info_list.active_special_image_flag

	if special_img_up[image_id] then
		self.node_list["BtnUpGrade"]:SetActive(0 ~= bit_list[image_id])
	else
		self.node_list["BtnUpGrade"]:SetActive(false)
	end
end

--升级按钮是否置灰
function AdvanceHuanHuaContent:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local mount_special_image = {}
	local upgrade_cfg = {}
	local image_id = -1
	if self.now_show_index == TabIndex.fashion_huan_hua then
		mount_special_image = FashionData.Instance:GetShizhuangSpecialImage()
		upgrade_cfg = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(mount_special_image[index].image_id)
		image_id = FashionData.Instance:GetFashionSpecialImageMaxUpLevelById(mount_special_image[index].image_id)
	elseif self.now_show_index == TabIndex.wuqi_huan_hua then
		mount_special_image = FashionData.Instance:GetWuQiImageCfg()
		upgrade_cfg = FashionData.Instance:GetSpecialImageUpgradeInfo(mount_special_image[index].image_id)
		image_id = FashionData.Instance:GetSpecialImageMaxUpLevelById(mount_special_image[index].image_id)
	else
		mount_special_image = self.data:GetSpecialImagesCfg()
		upgrade_cfg = self.data:GetSpecialImageUpgradeInfo(mount_special_image[index].image_id)
		image_id = self.data:GetSpecialImageMaxUpLevelById(mount_special_image[index].image_id)
	end

	if upgrade_cfg.grade < image_id then
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
		self.node_list["BtnUpGradeText"].text.text = Language.Common.UpGrade
	else
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
		self.node_list["BtnUpGradeText"].text.text = Language.Common.YiManJi
		self.node_list["TxtNeedPro"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
	end
end

function AdvanceHuanHuaContent:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if (k == "mounthuanhua" and self.now_show_index == TabIndex.mount_huan_hua) or (k == "winghuanhua" and self.now_show_index == TabIndex.wing_huan_hua ) or 
			(k == "halohuanhua" and self.now_show_index == TabIndex.halo_huan_hua) or (k == "foothuanhua" and self.now_show_index == TabIndex.foot_huan_hua) or 
			(k == "fightmounthuanhua" and self.now_show_index == TabIndex.fight_mount_huan_hua) or (k == "fabaohuanhua"and self.now_show_index == TabIndex.fabao_huan_hua) then
			self:OnFlushCommonAdvance(k,v)
		elseif k == "fashionhuanhua" and self.now_show_index == TabIndex.fashion_huan_hua then
			self:OnFlushFashionAdvance(k,v)
		elseif k == "wuqihuanhuaview" and self.now_show_index == TabIndex.wuqi_huan_hua then
			self:OnFlushWuQiAdvance(k,v)
		elseif k == "open_advance_huanhua_flush" then
			self:OpenFlush(k,v)
			self.node_list["ListView"].scroller:ReloadData(0)
		end
	end
end

function AdvanceHuanHuaContent:OnFlushCommonAdvance(key, value)
	if value and value.id then
		local index , num = self.data:CanHuanhuaIndexByImageId(value.id)
		if index then
			self.grade = nil
			self.index = index
			local cfg_list = self.data:GetHuanHuaCfgList()
			num = num > 5 and num or num - 1
			self.node_list["ListView"].scroller:ReloadData(num / #cfg_list)
		end
	end
	local special_image_cfg = self.data:GetSpecialImagesCfg()
	local upgrade_cfg = self.data:GetSpecialImageUpgradeInfo(special_image_cfg[self.index].image_id)
	local info_list = AdvanceData.Instance:AdvanceInfo()
	local bit_list = info_list.active_special_image_flag
	if not self.grade or (upgrade_cfg and upgrade_cfg.grade and bit_list and bit_list[self.index] and self.grade < upgrade_cfg.grade and 0 ~= bit_list[self.index]) or 
		(self.used_special_id ~= info_list.used_special_id) then
		self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
		self:IsShowUpGrade(self.index)
		self:SetSpecialImageAttr(special_image_cfg[self.index], self.index)
		self:IsGrayUpgradeButton(self.index)
	end
	self:IsShowActivate(self.index)
	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
end

function AdvanceHuanHuaContent:OnFlushFashionAdvance(key, value)
	if value and value.id then
		local index , num = self.data:CanShizhuangHuanhuaIndexByImageId(value.id)
		if index then
			self.grade = nil
			self.index = index
			local cfg_list = self.data:GetShizhuangSpecialImgCfg()
			num = num > 5 and num or num - 1
			self.node_list["ListView"].scroller:ReloadData(num / #cfg_list)
		end
	end
	local fashion_special_image = FashionData.Instance:GetShizhuangSpecialImage()
	if not fashion_special_image then return end
	local image_id = fashion_special_image[self.index] and fashion_special_image[self.index].image_id
	local upgrade_cfg = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(image_id)
	if not upgrade_cfg then return end
	
	local info_list = FashionData.Instance:GetFashionInfo()
	local bit_list = FashionData.Instance:GetSpecialActiveFlag() or {}
	if not self.grade or (bit_list[image_id] and self.grade < upgrade_cfg.grade and 0 ~= bit_list[image_id])
		or (self.used_special_id ~= info_list.use_special_img) then
		self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
		self:IsShowUpGrade(self.index)
		self:SetSpecialImageAttr(fashion_special_image[self.index], self.index)
		self:IsGrayUpgradeButton(self.index)
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:IsShowActivate(self.index)
end

function AdvanceHuanHuaContent:OnFlushWuQiAdvance(key, value)
	if value and value.id then
		local index , num = self.data:CanHuanhuaIndexByImageId(value.id)
		if index then
			self.grade = nil
			self.index = index
			local cfg_list = self.data:GetSpecialImagesCfg()
			num = num > 5 and num or num - 1
			self.node_list["ListView"].scroller:ReloadData(num / #cfg_list)
		end
	end
	local wuqi_special_image = FashionData.Instance:GetWuQiImageCfg()
	if not wuqi_special_image then return end
	local image_id = wuqi_special_image[self.index] and wuqi_special_image[self.index].image_id
	local upgrade_cfg = FashionData.Instance:GetSpecialImageUpgradeInfo(image_id)
	if not upgrade_cfg then return end
	local info_list = FashionData.Instance:GetWuQiInfo()
	local bit_list = FashionData.Instance:GetWuQiSpecialActiveFlag() or {}
	if not self.grade or (upgrade_cfg.grade and bit_list[image_id] and self.grade < upgrade_cfg.grade and 0 ~= bit_list[image_id])
		or (self.used_special_id ~= info_list.use_special_img) then
		self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
		self:IsShowUpGrade(self.index)
		self:SetSpecialImageAttr(wuqi_special_image[self.index], self.index)
		self:IsGrayUpgradeButton(self.index)
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:IsShowActivate(self.index)
end

------------------------------------------------------------------------------------------------
HuanHuaCell = HuanHuaCell or BaseClass(BaseRender)

function HuanHuaCell:__init()
end

function HuanHuaCell:SetData(data)
	if data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. data.image_name .. "</color>"
	self.node_list["TxtName"].text.text = name_str

	self.node_list["ImgRemind"]:SetActive(data.is_show)
	self:ShowLabel(data, data.index)
end

function HuanHuaCell:ListenClick(handler)
	self.node_list["HuanHuaItem"].toggle:AddClickListener(handler)
end

function HuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function HuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function HuanHuaCell:ShowLabel(data, image_id)
	if image_id == nil then
		return
	end
	
	if data.is_specal == 0 then
		local bit_list = data.info_list.active_special_image_flag
		self.node_list["ImgYiHuanHua"]:SetActive(0 ~= bit_list[image_id])
		UI:SetGraphicGrey(self.node_list["ImgIcon"], 0 == bit_list[image_id])
		if data.info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			self.node_list["ImgYiHuanHua"]:SetActive(image_id == (data.info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
														and 0 ~= bit_list[image_id])
		else
			self.node_list["ImgYiHuanHua"]:SetActive(false)
		end
	elseif data.is_specal == TabIndex.fabao_huan_hua then
		local bit_list = data.info_list.active_special_image_flag

		local is_active = (0 ~= bit_list[image_id])
		local is_used_special_img = (1 == data.info_list.is_used_special_img)
		UI:SetGraphicGrey(self.node_list["ImgIcon"], not is_active)

		if is_active then
			if is_used_special_img then
				self.node_list["ImgYiHuanHua"]:SetActive(image_id == data.info_list.used_special_id - GameEnum.MOUNT_SPECIAL_IMA_ID)
			else
				self.node_list["ImgYiHuanHua"]:SetActive(false)
			end
		else
			self.node_list["ImgYiHuanHua"]:SetActive(false)
		end
	elseif data.is_specal == TabIndex.wuqi_huan_hua then
		local info_list = FashionData.Instance:GetWuQiInfo()
		local active_special_image_flag = FashionData.Instance:GetWuQiSpecialActiveFlag()
		local bit_list = active_special_image_flag

		local is_active = (0 ~= bit_list[image_id])
		local is_used_special_img = (1 == info_list.is_used_special_img)
		UI:SetGraphicGrey(self.node_list["ImgIcon"], not is_active)
		if is_active then
			if is_used_special_img then
				self.node_list["ImgYiHuanHua"]:SetActive(image_id == info_list.use_special_img)
			else
				self.node_list["ImgYiHuanHua"]:SetActive(false)
			end
		else
			self.node_list["ImgYiHuanHua"]:SetActive(false)
		end
	elseif data.is_specal == TabIndex.fashion_huan_hua then
		local info_list = FashionData.Instance:GetFashionInfo()
		local active_special_image_flag = FashionData.Instance:GetSpecialActiveFlag()
		local bit_list = active_special_image_flag

		local is_active = (0 ~= bit_list[image_id])
		local is_used_special_img = (1 == info_list.is_used_special_img)
		UI:SetGraphicGrey(self.node_list["ImgIcon"], not is_active)
		if is_active then
			if is_used_special_img then
				self.node_list["ImgYiHuanHua"]:SetActive(image_id == info_list.use_special_img)
			else
				self.node_list["ImgYiHuanHua"]:SetActive(false)
			end
		else
			self.node_list["ImgYiHuanHua"]:SetActive(false)
		end
	end
end