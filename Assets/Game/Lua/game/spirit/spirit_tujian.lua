-- 仙宠-猎取-仙宠图鉴-SpiritTujian
SpiritTujian = SpiritTujian or BaseClass(BaseView)

local MAX_GRID_NUM = 16
local ROW = 4
local COLUMN = 4

function SpiritTujian:__init(instance)
self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/spiritview_prefab", "SpiritTujian"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true
end

function SpiritTujian:LoadCallBack(instance)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(980, 620, 0)
	self.node_list["RawImgBg"].rect.sizeDelta = Vector3(976, 616, 0)
	self.node_list["RawImgBg"].raw_image:LoadSprite("uis/rawimages/spirit_tujian_bg", "spirit_tujian_bg.jpg", function()
		self.node_list["RawImgBg"]:SetActive(true)
	end)
	self.node_list["Txt"].text.text = Language.JingLing.TabbarName[1] .. Language.JingLing.TabbarName[2]

	local list_simple_delegate = self.node_list["ListView"].list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.cur_index = 0
	self.temp_illustrated_data = nil
	self.display_items = {}

	self.illustrated_model = RoleModel.New()
	self.illustrated_model:SetDisplay(self.node_list["illustruate_display"].ui3d_display)
	
	self.show_toggles = {}
	self.page_count = 1
	for i = 1, 4 do
		self.show_toggles[i] = self.node_list["PageToggle" .. i]
	end

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightTxt"])

	local event_trigger = self.node_list["EventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnSpiritDragMan, self))
end

function SpiritTujian:OpenCallBack()
	self:IllustrateDefulatShow(15016)
	self:RefreshDisplayItem()
end

function SpiritTujian:CloseCallBack()
	self.temp_illustrated_data = nil
	self.cur_index = 0
end

function SpiritTujian:__delete()
	
end

function SpiritTujian:ReleaseCallBack()
	for k, v in pairs(self.display_items) do
		v:DeleteMe()
	end
	self.display_items = {}

	if self.illustrated_model then
		self.illustrated_model:DeleteMe()
		self.illustrated_model = nil
	end
	self.fight_text = nil
end

function SpiritTujian:OnFlush()
	
end

function SpiritTujian:OnSpiritDragMan(data)
	if self.illustrated_model then
		self.illustrated_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function SpiritTujian:RefreshDisplayItem()
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		local page_count = #SpiritData.Instance:GetSpiritResourceCfg() - MAX_GRID_NUM
		local page = 0
		if self.page_count ~= (page_count + 1) then
			self.node_list["ListView"].scroller:ReloadData(0)
		else
			self.node_list["ListView"].scroller:RefreshActiveCellViews()
		end
		if page_count > 0 then
			page = math.floor(page_count / ROW / COLUMN) + 1
			for i = 1, page do
				self.show_toggles[i]:SetActive(true)
			end
			if page ~= 4 then
				for i = page + 1, 4 do
					self.show_toggles[i]:SetActive(false)
				end
			end
		else
			for i = 1, 4 do
				self.show_toggles[i]:SetActive(false)
			end
		end
		self.page_count = page_count + 1
	end
end

function SpiritTujian:SetRoleModel(display_role,data)
	local bundle, asset = nil, nil
	local res_id = 0
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == data.item_id 	 then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id ==data.item_id then
				bundle, asset = ResPath.GetWingModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == data.item_id or v.id==data.id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	end

	if bundle and asset and self.illustrated_model then
		self.illustrated_model:SetMainAsset(bundle, asset)
		self.illustrated_model:LoadSceneEffect(bundle, asset .. "_UIeffect", self.node_list["illustruate_display"].transform:Find("FitScale"))
		self.illustrated_model:SetRotation(Vector3(0, -15, 0))
	end
end

function SpiritTujian:GetNumOfCell()
	local page_count = #SpiritData.Instance:GetSpiritResourceCfg() - MAX_GRID_NUM
	page_count = (page_count > 0) and page_count or 0
	local list_page_scroll = self.node_list["ListView"].list_page_scroll
	local page = 0
	if page_count > 0 then
		page = math.floor(page_count / ROW / COLUMN) + 1
	end
	list_page_scroll:SetPageCount(page + 1)
	return (MAX_GRID_NUM + page * ROW * COLUMN) / ROW
end


function SpiritTujian:RefreshCell(cell, data_index)
	local group = self.display_items[cell]
	if nil == group then
		group = DisplaySpiritItemGroup.New(cell)
		group:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.display_items[cell] = group
	end
	-- 计算索引
	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW
	for i = 1, ROW do
		local index = (i - 1) * COLUMN  + column + (page * grid_count)
		--竖行遍历

		-- 获取数据信息
		local data = SpiritData.Instance:GetDisPlaySpiritListFromHigh()[index + 1]
		data = data or {}
		if data.id then
			data.item_id = data.id
			local cfg = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)-- 获取仙宠天赋属性
			if index <= 5 then
				for i = 1, 7 do
					if cfg["type" .. i] > 0  then
						data.param.xianpin_type_list = data.param.xianpin_type_list or {}
						data.param.xianpin_type_list[i] = i
					end
				end
			end
		end
		data.locked = false
		if data.index == nil then
			data.index = index
		end
		if data.index == 1 then
			self.temp_cell = group
		end
		group:SetData(i, data)
		group:SetHighLight(i, (self.cur_index == index and nil ~= data.item_id))
		group:ListenClick(i, BindTool.Bind(self.HandleItemOnClick, self, data, group, i, index))
		group:SetInteractable(i, (nil ~= data.item_id or data.locked))
	end
end

function SpiritTujian:IllustrateDefulatShow(item_id)
	local defulat_item_id=item_id or math.random(15001,15016)
	local defulat_data=SpiritData.Instance:GetSpiritResourceCfg()
	defulat_data=ListToMap(defulat_data,"id")
	local data=defulat_data[defulat_item_id]
	local defulat_item_cfg=ItemData.Instance:GetItemConfig(defulat_item_id)
	self.node_list["Txtdescription"].text.text = defulat_data[defulat_item_id].description
	self:SetRoleModel(defulat_item_cfg.is_display_role,data)
	local str="<color=%s>" .. defulat_item_cfg.name .. "</color>"
	self.node_list["NameTxt"].text.text = string.format(str, SOUL_NAME_COLOR[defulat_item_cfg.color])
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapability(self:CalculatePower(defulat_item_id,1))
	end
	self.node_list["Imgquality"].image:LoadSprite(ResPath.GetQualityTagBg(Common_Five_Rank_Color[defulat_item_cfg.color]))
	self.node_list["Imgshizhanhui"].text.text = Language.QualityAttr[Common_Five_Rank_Color[defulat_item_cfg.color]]
	self.cur_index=0
	self.node_list["illustruate_display"].ui3d_display:ResetRotation()

	if self.node_list["ListView"].scroller.isActiveAndEnabled then
	  self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

function SpiritTujian:CalculatePower(item_id,level)
	local spirit_data=SpiritData.Instance:GetSpiritLevelConfig()
	spirit_data=ListToMap(spirit_data,"item_id","level")
	return spirit_data[item_id][level]
end

function SpiritTujian:HandleItemOnClick(data, group, i, index)
	if data == nil or data.item_id == nil then
		return
	end
	if data == self.temp_illustrated_data then --重复选中同一仙宠 禁止刷新显示
		return
	end
	if self.node_list then
		self.cur_index = index
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
		self:SetRoleModel(item_cfg.is_display_role,data)
		local str="<color=%s>" .. item_cfg.name .. "</color>"
		self.node_list["NameTxt"].text.text = string.format(str, SOUL_NAME_COLOR[item_cfg.color])
		local spirit_data = SpiritData.Instance:GetSpiritResourceCfg()
		spirit_data = ListToMap(spirit_data,"id")
		self.node_list["Txtdescription"].text.text = spirit_data[data.item_id].description
		self.fight_text.text.text = CommonDataManager.GetCapability(self:CalculatePower(data.item_id,1))
		self.node_list["Imgquality"].image:LoadSprite(ResPath.GetQualityTagBg(Common_Five_Rank_Color[item_cfg.color]))

		self.node_list["Imgshizhanhui"].text.text = Language.QualityAttr[Common_Five_Rank_Color[item_cfg.color]]
		self.temp_illustrated_data = data
		self.node_list["illustruate_display"].ui3d_display:ResetRotation()
		group:SetHighLight(i, (self.cur_index == index and nil ~= data.item_id))
	end
	
end

------------spirit_ShowSpecialItem---------------------------------------------------------------
DisplaySpiritItemGroup = DisplaySpiritItemGroup or BaseClass(BaseRender)

function DisplaySpiritItemGroup:__init(instance)
	self.cells = {}

	for i = 1, 4 do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item" .. i])
	end

end

function DisplaySpiritItemGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function DisplaySpiritItemGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function DisplaySpiritItemGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function DisplaySpiritItemGroup:SetToggleGroup(toggle_group)
	for i = 1, 4 do
		self.cells[i]:SetToggleGroup(toggle_group)
	end

end

function DisplaySpiritItemGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function DisplaySpiritItemGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function DisplaySpiritItemGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end