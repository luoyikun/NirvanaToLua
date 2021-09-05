--宠物喂养
LittlePetFeedView = LittlePetFeedView or BaseClass(BaseRender)

function LittlePetFeedView:__init()
	self.select_index = 1
	-- for i = 1, 4 do
	self.stuff_list = ItemCell.New()
	self.stuff_list:SetInstanceParent(self.node_list["Item"])
	-- end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNum"])

	self.pet_cell_list = {}
    self.list_view = self.node_list["ListView"]
    local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetPetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshPetCell, self)

	self.pet_model = RoleModel.New()
	self.pet_model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.pet_model:SetRotation(Vector3(0, -30, 0))

	self.node_list["BtnIsCanFeed"].button:AddClickListener(BindTool.Bind(self.ClickFeed, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickOpen, self))
end

function LittlePetFeedView:__delete()
	self.fight_text = nil
	self.pet_cell_list = {}

	if self.pet_model ~= nil then
		self.pet_model:DeleteMe()
		self.pet_model = nil
	end
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end

	for k, v in pairs(self.pet_cell_list) do
		v:DeleteMe()
	end
	self.pet_cell_list = {}

	self.stuff_list:DeleteMe()
end

function LittlePetFeedView:OpenCallBack()
	self.select_index = 1
	self.model_res_id = 0
	self:GetEquipLittlePetDataList()
	self.list_view.scroller:ReloadData(0)
	self:FlushModle()
	self:DoPanelTweenPlay()
	self:OnFlush()
end

function LittlePetFeedView:CloseCallBack()
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end

function LittlePetFeedView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Top"], Vector3(-40, 487, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], Vector3(705, -380, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-885, -28, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

--刷新宠物信息
function LittlePetFeedView:GetEquipLittlePetDataList()
	self.pet_data_list = self:GetSortEquipDataList()
end

--左边宠物列表
function LittlePetFeedView:GetPetNumberOfCells()
	local count = #self.pet_data_list
	if count == 0 then
		self.node_list["NoEquipPet"]:SetActive(true)
		self.node_list["Mask"]:SetActive(false)
		self.node_list["Display"]:SetActive(false)
		self.node_list["Title1"]:SetActive(true)
		self.node_list["Title2"]:SetActive(false)
		self.node_list["NameIma"]:SetActive(false)
	else
		self.node_list["NoEquipPet"]:SetActive(false)
		self.node_list["Mask"]:SetActive(true)
		self.node_list["Display"]:SetActive(true)
		self.node_list["Title1"]:SetActive(false)
		self.node_list["Title2"]:SetActive(true)
		self.node_list["NameIma"]:SetActive(true)
	end
	return count
end

function LittlePetFeedView:RefreshPetCell(cell, data_index)
	data_index = data_index + 1
	local all_equip_list = self:GetSortEquipDataList()
	local pet_cell = self.pet_cell_list[cell]
	if nil == pet_cell then
		pet_cell = LittlePetFeedCell.New(cell.gameObject)
		pet_cell:SetToggleGroup(self.list_view.toggle_group)
		pet_cell:SetClickCallBack(BindTool.Bind(self.OnClickCellCallBack, self))
		self.pet_cell_list[cell] = pet_cell
	end
	local data = all_equip_list[data_index]
	pet_cell:SetIndex(data_index)
	pet_cell:SetData(data)
	pet_cell:SetHighLight(data_index == self.select_index)
end

function LittlePetFeedView:GetSortEquipDataList()
	self.equip_pet_cfg_list = LittlePetData.Instance:GetAllEquipPetCfgDataList()
	local all_equip_list = LittlePetData.Instance:GetSortAllPetList()
	local final_all_equip_list = {}
	if all_equip_list == nil or nil == next(all_equip_list) then return final_all_equip_list end
	for i = 1, #all_equip_list do
		local data = all_equip_list[i]
		for k,v in pairs(self.equip_pet_cfg_list) do
			if data.index == v.index and data.id == v.id and data.info_type == v.info_type then
				data = v
				table.insert(final_all_equip_list, data)
			end
		end
	end
	return final_all_equip_list
end

function LittlePetFeedView:OnClickCellCallBack(cell)
	if cell == nil then
		return
	end
	local index = cell:GetIndex()
	if self.select_index == index then
		return
	end
	self.select_index = index
	self:FlushAllHightLight()
	self:ChangeRemindPoint()
	self:FlushView()
end

function LittlePetFeedView:OnClickOpen()
	MarketData.Instance:SetPurchaseItemId(4)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 4})
end

function LittlePetFeedView:FlushAllHightLight()
	for k,v in pairs(self.pet_cell_list) do
		local index = v:GetIndex()
		v:SetHighLight(index == self.select_index)
	end
end


function LittlePetFeedView:OnFlush()
	self:FlushView()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(false)
end

--数据刷新
function LittlePetFeedView:FlushView()
	self:GetEquipLittlePetDataList()
	self:OnFlushStuffList()
	self:FlushLittlePetAttr()
	self:FlushModle(true)
	self:ChangeRemindPoint()
end

--喂养材料
function LittlePetFeedView:OnFlushStuffList()
	local info = self.pet_data_list[self.select_index]
	if info == nil then
		return
	end
	local pet_level = info.feed_level or 0
	local name = info.name or ""
	local item_cfg = ItemData.Instance:GetItemConfig(info.item_id)
	local quality_type = LittlePetData.Instance:GetLittlePetItemQualityTypeByItemID(info.item_id)
	if item_cfg == nil then
		return
	end
	local cfg = LittlePetData.Instance:GetLittlePetCfg()
	self.node_list["PetLevel1"].text.text = "Lv." .. pet_level
	self.node_list["PetLevel2"].text.text = "Lv." .. pet_level
	self.node_list["PetName1"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	self.node_list["PetName2"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	self.node_list["BtnBuy"]:SetActive(item_cfg.color > 3)
	local stuff_data = LittlePetData.Instance:GetGridUpgradeStuffDataListByLevel(quality_type, pet_level) or {}
	if info then
		self.node_list["Item"]:SetActive(true)
		self.node_list["Stuff"]:SetActive(true)
		if cfg[info.id] then
			local data = stuff_data[cfg[info.id].quality_type]
			if data then
				self.stuff_list:SetData(data)
				local stuff_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
				local color = stuff_num >= data.need_stuff_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
				self.node_list["Stuff"].text.text = "<color="..color..">"..stuff_num.."</color>".." / "..data.need_stuff_num
			end
		end
	else
		self.node_list["Item"]:SetActive(false)
		self.node_list["Stuff"]:SetActive(false)
	end
end

--模型刷新
function LittlePetFeedView:FlushModle(flag)
	local data = self.pet_data_list[self.select_index]
	if data == nil then
		return
	end

	local model_flush_falg = flag
	if flag and data.res_id == self.model_res_id then return end
	local bundle, asset = ResPath.GetLittlePetModel(data.res_id)
	self.model_res_id = data.res_id
	self.pet_model:SetMainAsset(bundle, asset)
	self.pet_model:SetTrigger("rest")
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.pet_model:SetTrigger("rest")
	end, 15)
end

function LittlePetFeedView:FlushLittlePetAttr()
	local data = self.pet_data_list[self.select_index]
	if data == nil then
		return
	end
	local quality_type = LittlePetData.Instance:GetLittlePetItemQualityTypeByItemID(data.item_id)
	local feed_level = data and data.feed_level or 0
	local attr_cfg = LittlePetData.Instance:GetFeedAttrCfgByLevel(quality_type, feed_level)
	local next_attr_cfg = LittlePetData.Instance:GetFeedAttrCfgByLevel(quality_type, feed_level + 1)
	local base_power = LittlePetData.Instance:CalPetBaseFightPower(false, data.item_id)
	local base_attr_list = LittlePetData.Instance:GetLittlePetBaseAttr(data.item_id)
	local base_add_power = 0

	local attr_precent = 0
	local base_attr = 0
	if attr_cfg ~= nil then
		base_attr = attr_cfg.base_attr_add_per
	end
	attr_precent = base_attr / 10000
	-- local show_per = attr_precent * 100
	local attr_list = CommonDataManager.GetAttributteNoUnderline(attr_cfg, true)
	local next_attr_list = CommonDataManager.GetAttributteNoUnderline(next_attr_cfg, true)
	local diff_attr_list = CommonDataManager.LerpAttributeAttrNoUnderLine(attr_list, next_attr_list)
	--小宠物基础属性加成
	if data ~= nil then
		base_add_power = LittlePetData.Instance:GetSinglePetFeedBaseAddPower(data.item_id, attr_precent)
	end
	--喂养加成
	local feed_power = CommonDataManager.GetCapability(attr_list)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = feed_power + base_add_power + base_power
	end
	if attr_list and base_attr_list and next(attr_list) ~= nil and next(base_attr_list) ~= nil then
		self.node_list["GongJi"].text.text = attr_list.gongji + base_attr_list.gongji
		self.node_list["FangYu"].text.text = attr_list.fangyu + base_attr_list.fangyu
		self.node_list["ShengMing"].text.text = attr_list.maxhp + base_attr_list.maxhp
	end
	local quality_type = LittlePetData.Instance:GetLittlePetItemQualityTypeByItemID(data.item_id)
	local max_feed_level = LittlePetData.Instance:GetMaxFeedLevel(quality_type)
	if feed_level >= max_feed_level then
		UI:SetButtonEnabled(self.node_list["BtnIsCanFeed"], false)
		self.node_list["BtnTxtIsCanFeed"].text.text = Language.LittlePet.YiManJi
		self.node_list["Stuff"].text.text = "- / -"
		self.node_list["GongJiNextAttr"]:SetActive(false)
		self.node_list["FangYuNextAttr"]:SetActive(false)
		self.node_list["ShengMingNextAttr"]:SetActive(false)
	else
		UI:SetButtonEnabled(self.node_list["BtnIsCanFeed"], true)
		self.node_list["BtnTxtIsCanFeed"].text.text = Language.LittlePet.WeiYang
		self.node_list["GongJiNextAttr"]:SetActive(true)
		self.node_list["FangYuNextAttr"]:SetActive(true)
		self.node_list["ShengMingNextAttr"]:SetActive(true)
		self.node_list["GongJiNextText"].text.text = diff_attr_list.gongji
		self.node_list["FangYuNextText"].text.text = diff_attr_list.fangyu
		self.node_list["ShengMingNextText"].text.text = diff_attr_list.maxhp
	end
end

--点击喂养
function LittlePetFeedView:ClickFeed()
	local count = self:GetPetNumberOfCells()
	if count > 0 then
		local data_list = self:GetSortEquipDataList()
		local select_index = data_list[self.select_index].index
		local param = data_list[self.select_index] or 0
		LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_FEED, select_index, param.info_type or 0)
	else	
		SysMsgCtrl.Instance:ErrorRemind(Language.LittlePet.NoEquipPetTip)
	end
end

function LittlePetFeedView:ClickHelp()
	local tip_id = 277
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

--红点
function LittlePetFeedView:ChangeRemindPoint()
	local data = self.pet_data_list[self.select_index]
	if data == nil then
		return
	end
	local pet_level = data and data.feed_level or 0
	local id = data and data.id or 0
	local quality_type = LittlePetData.Instance:GetLittlePetItemQualityTypeByItemID(data.item_id)
	local is_show = false
	local count = self:GetPetNumberOfCells()
	if count > 0 then
		local feed_flag = LittlePetData.Instance:CanFeedPetByFeedLevel(quality_type, pet_level, id) or 0
		if feed_flag == 1 then
			is_show = true
		end
	end
	self.node_list["ShowRedPoint"]:SetActive(is_show)
end
--------------------------------------------LittlePetCell---------------------------------------------------------------
LittlePetFeedCell = LittlePetFeedCell or BaseClass(BaseCell)

function LittlePetFeedCell:__init()
	self.node_list["FeedItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNum"], "FightPower3")
end

function LittlePetFeedCell:__delete()
	self.fight_text = nil
end

function LittlePetFeedCell:SetData(data)
	if data == nil then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then
		return
	end
	--计算战力
	local feed_power = LittlePetData.Instance:GetFeedAttrCfgByIndex(data.index, data.info_type, data.item_id) or 0
	local base_power = LittlePetData.Instance:CalPetBaseFightPower(false, data.item_id) or 0
	local toy_power = LittlePetData.Instance:GetSinglePetToyPower(data.index, data.info_type) or 0
	local power = feed_power + base_power + toy_power

	--是否显示红点
	local feed_level = data.feed_level
	local id = data.id
	local quality_type = LittlePetData.Instance:GetLittlePetItemQualityTypeByItemID(data.item_id)
	local feed_flag = LittlePetData.Instance:CanFeedPetByFeedLevel(quality_type, feed_level, id) 
	if feed_flag == 1 then
		is_show = true
	else
		is_show =false
	end
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["Sprite"].image:LoadSprite(bundle, asset)
	self.node_list["IsLover"]:SetActive(data.lover_flag)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
	self.node_list["RedPoint"]:SetActive(is_show)
	local bg_bundle, bg_asset = ResPath.GetLittlePetBg(Common_Five_Rank_Color[item_cfg.color])
	if bg_bundle and bg_asset then
		self.node_list["head_frame"].image:LoadSprite(bg_bundle, bg_asset)
	end
end

function LittlePetFeedCell:OnFlush()

end

function LittlePetFeedCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function LittlePetFeedCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function LittlePetFeedCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end
