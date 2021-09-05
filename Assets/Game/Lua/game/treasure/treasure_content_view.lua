TreasureContentView = TreasureContentView or BaseClass(BaseRender)

TREASURE_FUNCTION_OPEN = 40

--常量定义
local BAG_ROW = 4						-- 列数
local BAG_COLUMN = 3					-- 行数
local MAX_EFFECT = 6					-- 拥有特效物品数量

local TreasurePrice = {
	{CHEST_SHOP_MODE.CHEST_SHOP_MODE_1, CHEST_SHOP_MODE.CHEST_SHOP_MODE_10, CHEST_SHOP_MODE.CHEST_SHOP_MODE_50},
	{CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1, CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10, CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30},
	{CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1, CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10, CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30},
}

local ImgItemResPath = {
	{"icon_key1", "icon_key10", "icon_key30"},
	{"icon2_key1", "icon2_key10", "icon2_key30"},
	{"icon3_key1", "icon3_key10", "icon3_key30"},
}

function TreasureContentView:__init(instance)
	if nil == instance then return end

	self.show_frame = TreasureFrameItem.New(self.node_list["show_frame"])

	self.node_list["OneTimesBtn"].button:AddClickListener(BindTool.Bind(self.OpenOneClick, self))
	self.node_list["Btn01"].button:AddClickListener(BindTool.Bind(self.OpenTenClick, self))
	self.node_list["Btn02"].button:AddClickListener(BindTool.Bind(self.OpenFiftyClick, self))
	self.node_list["ToggleCheckBox"].button:AddClickListener(BindTool.Bind(self.CheckBoxClick, self))
	-- self.node_list["DanMuToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickDanMu, self)) 	-- 弹幕的屏蔽，不要删了

	self.node_list["ImgCheckBox"]:SetActive(TreasureData.Instance:GetIsShield())

	self.contain_cell_list = {}
	for i=1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetShowOrangeEffect(true)
		item:SetData(nil)
		table.insert(self.contain_cell_list, item)
	end
	-- local list_delegate = self.node_list["list_view"].list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.xunbao_type = 1
end

--用于功能引导
function TreasureContentView:GetGuideOneTimesBtn()
	if self.node_list["OneTimesBtn"] then
		return self.node_list["OneTimesBtn"], BindTool.Bind(self.OpenOneClick, self)
	end
end

function TreasureContentView:__delete()
	if self.show_frame then
		self.show_frame:DeleteMe()
	end
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TreasureContentView:OpenCallBack()
	local right_pos = self.node_list["RightPanel"].transform.anchoredPosition
	local under_pos = self.node_list["UnderPanel"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(right_pos.x, right_pos.y + 600, right_pos.z))
	UITween.MoveShowPanel(self.node_list["UnderPanel"], Vector3(under_pos.x, under_pos.y - 200, under_pos.z))
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure1)
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure2)
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure3)
end

function TreasureContentView:OpenOneClick()
	local choujiang_index = TreasureData.Instance:GetChouJiangIndex()
	if choujiang_index == TREASURE_TYPE.TREASURE1 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	elseif choujiang_index == TREASURE_TYPE.TREASURE2 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1)
	elseif choujiang_index == TREASURE_TYPE.TREASURE3 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2)
	end
end

function TreasureContentView:OpenTenClick()
	local choujiang_index = TreasureData.Instance:GetChouJiangIndex()
	if choujiang_index == TREASURE_TYPE.TREASURE1 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	elseif choujiang_index == TREASURE_TYPE.TREASURE2 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1)
	elseif choujiang_index == TREASURE_TYPE.TREASURE3 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2)
	end
end

function TreasureContentView:OpenFiftyClick()
	local choujiang_index = TreasureData.Instance:GetChouJiangIndex()
	if choujiang_index == TREASURE_TYPE.TREASURE1 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	elseif choujiang_index == TREASURE_TYPE.TREASURE2 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1)
	elseif choujiang_index == TREASURE_TYPE.TREASURE3 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2)
	end
end

function TreasureContentView:OnClickDanMu()
	local choujiang_index = TreasureData.Instance:GetChouJiangIndex()

	RollingBarrageData.Instance:RecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, self.node_list["DanMuToggle"].toggle.isOn)

	if self.node_list["DanMuToggle"].toggle.isOn then
		ViewManager.Instance:Close(ViewName.RollingBarrageView)
	else
		RollingBarrageData.Instance:SetNowCheckType(choujiang_index)
		ViewManager.Instance:Open(ViewName.RollingBarrageView)
	end
end

function TreasureContentView:GetNumberOfCells()
	local item_cfg_list = TreasureData.Instance:GetShowCfg(self.xunbao_type)
	if nil == item_cfg_list then return 0 end

	local temp = (#item_cfg_list / BAG_COLUMN) % BAG_ROW
	local num = 0
	if temp == 0 then
		num = #item_cfg_list / BAG_COLUMN
	else
		num = #item_cfg_list / BAG_COLUMN + (BAG_ROW - temp)
	end
	local page = num / BAG_ROW
	self.node_list["list_view"].list_page_scroll:SetPageCount(page)
	for i = 1,2 do
		self.node_list["PageToggle" .. i]:SetActive(i <= page and page > 1)
	end
	return num
end

function TreasureContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TreasureShowCell.New(cell.gameObject,self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:Flush()
end

function TreasureContentView:CheckBoxClick()
	local treasure_data = TreasureData.Instance
	local is_shield = treasure_data:GetIsShield()
	treasure_data:SetIsShield(not is_shield)

	self.node_list["ImgCheckBox"]:SetActive(not is_shield)
end

function TreasureContentView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "treasure1" then
			TreasureData.Instance:SetChouJiangIndex(TREASURE_TYPE.TREASURE1)
			self.xunbao_type = TREASURE_TYPE.TREASURE1
		elseif k == "treasure2" then
			TreasureData.Instance:SetChouJiangIndex(TREASURE_TYPE.TREASURE2)
			self.xunbao_type = TREASURE_TYPE.TREASURE2
		elseif k == "treasure3" then
			TreasureData.Instance:SetChouJiangIndex(TREASURE_TYPE.TREASURE3)
			self.xunbao_type = TREASURE_TYPE.TREASURE3
		end
	end

	local choujiang_index = TreasureData.Instance:GetChouJiangIndex()

	self.node_list["ShowTxt1"]:SetActive(choujiang_index == TREASURE_TYPE.TREASURE1)
	self.node_list["ShowTxt2"]:SetActive(choujiang_index == TREASURE_TYPE.TREASURE2)
	self.node_list["ShowTxt3"]:SetActive(choujiang_index == TREASURE_TYPE.TREASURE3)



	self:FlushTime()
	self:FlushText()
	-- self.node_list["list_view"].list_page_scroll:JumpToPageImmidate(0)
	-- for k,v in pairs(self.contain_cell_list) do
	-- 	v:Flush()
	-- end
	local choujiang_index = TreasureData.Instance:GetChouJiangIndex()
	local zhen_xi_list = TreasureData.Instance:GetXunBaoZhenXiCfg()
	if zhen_xi_list[choujiang_index] then
		if self.rare_item_id == nil or self.rare_item_id ~= zhen_xi_list[choujiang_index].rare_item_id then
			if zhen_xi_list[choujiang_index] then
				self.rare_item_id = zhen_xi_list[choujiang_index].rare_item_id
				self.show_frame:SetData(zhen_xi_list[choujiang_index].rare_item_id)
			end
		end
	end
	self.node_list["ImgRareText"]:SetActive(TreasureData.Instance:IsFlashChange())
	--self.node_list["DanMuToggle"].toggle.isOn = RollingBarrageData.Instance:GetRecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)

	local show_cfg = TreasureData.Instance:GetShowCfgByType()
	if show_cfg == nil then
		return
	end
	for i,v in ipairs(self.contain_cell_list) do
		self.contain_cell_list[i]:SetData(show_cfg[i])
		if show_cfg[i] and show_cfg[i].is_specil == 1 then
			self.contain_cell_list[i]:ShowExtremeEffect(true, 4)
		end
	end

end

function TreasureContentView:FlushTime()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		local can_chest_time = TreasureData.Instance:GetChestFreeTime()
		local remain_time = can_chest_time - TimeCtrl.Instance:GetServerTime()

		self.node_list["TxtFree"]:SetActive(remain_time < 0)
		self.node_list["Effect"]:SetActive(remain_time < 0)
		self.node_list["TxtTime"]:SetActive(remain_time >= 0)
		self.node_list["ImgRedPoint"]:SetActive(remain_time < 0 or self.my_item_1_count > 0)

		if remain_time < 0 then
			self.node_list["Node1"]:SetActive(false)
			GlobalTimerQuest:CancelQuest(self.timer_quest)
		else
			local time_str = string.format(Language.Treasure.ShowFreeTime, TimeUtil.FormatSecond(remain_time))
			self.node_list["TxtTime"].text.text = time_str
		end
	end, 1)
end

function TreasureContentView:FlushText()
	local cfg = TreasureData.Instance:GetOtherCfg()
	local choujiang_index = TreasureData.Instance:GetChouJiangIndex()
	local item_1 = cfg.equip_use_itemid
	local item_2 = cfg.equip_10_use_itemid
	local item_3 = cfg.equip_30_use_itemid
	if choujiang_index == TREASURE_TYPE.TREASURE2 then
		item_1 = cfg.equip1_use_itemid
		item_2 = cfg.equip1_10_use_itemid
		item_3 = cfg.equip1_30_use_itemid
	elseif choujiang_index == TREASURE_TYPE.TREASURE3 then
		item_1 = cfg.equip2_use_itemid
		item_2 = cfg.equip2_10_use_itemid
		item_3 = cfg.equip2_30_use_itemid
	end
	local item_data = ItemData.Instance
	self.my_item_1_count = item_data:GetItemNumInBagById(item_1)
	local my_item_2_count = item_data:GetItemNumInBagById(item_2)
	local my_item_3_count = item_data:GetItemNumInBagById(item_3)

	local can_chest_time = TreasureData.Instance:GetChestFreeTime()
	local remain_time = can_chest_time - TimeCtrl.Instance:GetServerTime()
	local is_free = remain_time <= 0
	if is_free then
		self.node_list["Node1"]:SetActive(false)
	end

	self.node_list["TxtFree"]:SetActive(is_free)
	self.node_list["ImgRedPoint"]:SetActive(is_free or self.my_item_1_count > 0)
	self.node_list["ImgRedPoint10"]:SetActive(my_item_2_count > 0)
	self.node_list["ImgRedPoint30"]:SetActive(my_item_3_count > 0)

	self.node_list["ItemNum1"]:SetActive(self.my_item_1_count > 0 and not is_free)
	self.node_list["ItemNum10"]:SetActive(my_item_2_count > 0)
	self.node_list["ItemNum30"]:SetActive(my_item_3_count > 0)

	self.node_list["Node1"]:SetActive(self.my_item_1_count <= 0 and not is_free)
	self.node_list["Node2"]:SetActive(my_item_2_count <= 0)
	self.node_list["Node3"]:SetActive(my_item_3_count <= 0)

	self.node_list["Txt"].text.text = Language.Common.X .. self.my_item_1_count
	self.node_list["TxtBtnGold2"].text.text = Language.Common.X .. my_item_2_count
	self.node_list["TxtBtnGold3"].text.text = Language.Common.X .. my_item_3_count
	for i = 1, 3 do
		self.node_list["TxtBtn" .. i].text.text = TreasureData.Instance:GetTreasurePrice(TreasurePrice[choujiang_index][i])
		local asset, bundle = ResPath.GetTreasureItemIcon(ImgItemResPath[choujiang_index][i])
		self.node_list["ImgItem" .. i].image:LoadSprite(asset, bundle)
	end
end

----------------------------------------------------------------------
TreasureFrameItem = TreasureFrameItem or BaseClass(BaseCell)
function TreasureFrameItem:__init()
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["model"].ui3d_display, 0)
	self.is_load_effect = false
end

function TreasureFrameItem:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function TreasureFrameItem:OnFlush()
	if nil == self.data then return end 
	local res_id = self.data
	local res_id2 = self.data .."_01"
	local bundle_name, asset_name = ResPath.GetTreasureEffect(res_id)
	local bundle_name2, asset_name2 = ResPath.GetTreasureEffect(res_id2)
	if bundle_name and asset_name then
		self.node_list["effect"]:ChangeAsset(bundle_name, asset_name)
		self.node_list["effect"]:SetActive(true)
	end
	if bundle_name2 and asset_name2 then
		self.node_list["effect2"]:ChangeAsset(bundle_name2, asset_name2)
		self.node_list["effect2"]:SetActive(true)
	end
	--特效大小不一样，策划说写死
	local start_pos4 = Vector3(0 , 60 , 0)
	local end_pos4 = Vector3(0 , 90 , 0)
	local scale = 2
	if self.data == 26701 then
		start_pos4 = Vector3(-20 , 40 , 0)
		end_pos4 = Vector3(-20, 70 , 0)
		scale = 1.9
	elseif self.data == 26702 then
		start_pos4 = Vector3(-35 , 40 , 0)
		end_pos4 = Vector3(-35, 80 , 0)
		scale = 1.9
	end
	self.node_list["effect2"].transform.localScale = Vector3(scale, scale, scale)
	UITween.MoveLoop(self.node_list["effect2"], start_pos4, end_pos4, 1)
end

function TreasureFrameItem:SetModelEffect()
	if not self.is_load_effect then
		self.is_load_effect = true
		local bundle, asset = ResPath.GetUiXEffect("UI_tongyongbaoju_2")
		local res_async_loader = AllocResAsyncLoader(self, "effect_loader")
		res_async_loader:Load(bundle, asset, nil, function(obj)
			if obj then
				local transform = obj.transform
				transform:SetParent(self.node_list["effect"].transform, false)
				transform.localScale = Vector3(1, 1, 1)
				self.is_load_effect = false
			end
		end)
	end
end
----------------------------------------------------------------
--------------cell----------------------------------------------
----------------------------------------------------------------
-- TreasureShowCell = TreasureShowCell  or BaseClass(BaseCell)
-- function TreasureShowCell:__init()
-- 	self.item_cells = {}
-- 	for i = 1, BAG_COLUMN do
-- 		self.item_cells[i] = {}
-- 		self.item_cells[i] = ItemCell.New()
-- 		self.item_cells[i]:SetInstanceParent(self.node_list["item_" .. i])
-- 	end
-- end

-- function TreasureShowCell:__delete()
-- 	for k,v in pairs(self.item_cells) do
-- 		v:DeleteMe()
-- 	end
-- 	self.item_cells = {}
-- end

-- function TreasureShowCell:OnFlush()
-- 	self.show_cfg = TreasureData.Instance:GetShowCfgByType()
-- 	for i = 1, BAG_COLUMN do
-- 		local index = CommonDataManager.GetCellIndexList(self.index, BAG_ROW, BAG_COLUMN)[i]
-- 		self.item_cells[i]:SetData(self.show_cfg[index])
-- 		self.item_cells[i]:IsDestoryActivityEffect(index > MAX_EFFECT)
-- 		self.item_cells[i]:SetActivityEffect()
-- 	end
-- end