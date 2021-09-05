CoupleHomeTotalAttrView = CoupleHomeTotalAttrView or BaseClass(BaseView)

function CoupleHomeTotalAttrView:__init()
	self.ui_config = {{"uis/views/couplehome_prefab", "TotalAttrView"}}
	self.select_house_index = 0
	self.is_modal = true
	self.is_any_click_close = true
end

function CoupleHomeTotalAttrView:__delete()
end

function CoupleHomeTotalAttrView:ReleaseCallBack()
	for _, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	self.furniture_content = nil
	self.fight_text = nil
end

function CoupleHomeTotalAttrView:LoadCallBack()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Power"])
	self:CreateAttrFurnitureCell()

	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function CoupleHomeTotalAttrView:CreateAttrFurnitureCell()
	self.furniture_content = self.node_list["FurnitureContent"]

	self.cell_list = {}
	local max_furniture_count = CoupleHomeHomeData.Instance:GetMaxFurnitureCount()
	local res_async_loader = AllocResAsyncLoader(self, "cell_res_async_loader")
	res_async_loader:Load("uis/views/couplehome_prefab", "AttrFurnitureCell", nil, function (prefab)
		if not prefab then return end

		for i = 1, max_furniture_count do
			local obj = ResMgr:Instantiate(prefab)
			local cell = CoupleHomeAttrFurnitureCell.New(obj.gameObject)
			cell:SetInstanceParent(self.furniture_content)

			cell:SetSelectHouseClientIndex(self.select_house_index)
			cell:SetFurnitureIndex(i - 1)
			cell:Flush()

			table.insert(self.cell_list, cell)
		end
	end)
end

function CoupleHomeTotalAttrView:CloseWindow()
	self:Close()
end

function CoupleHomeTotalAttrView:SetSelectHouseClientIndex(select_house_index)
	self.select_house_index = select_house_index
end

function CoupleHomeTotalAttrView:OpenCallBack()
	self:Flush()
end

function CoupleHomeTotalAttrView:UpdateFurnitureAttr()
	for _, v in ipairs(self.cell_list) do
		v:SetSelectHouseClientIndex(self.select_house_index)
		v:Flush()
	end
end

function CoupleHomeTotalAttrView:OnFlush()
	local total_attr = CoupleHomeHomeData.Instance:GetTotalAttr()
	self.node_list["Hp"].text.text = Language.CoupleHome.hp .. ToColorStr(total_attr.maxhp, TEXT_COLOR.WHITE)
	self.node_list["GongJi"].text.text = Language.CoupleHome.gongji .. ToColorStr(total_attr.gongji, TEXT_COLOR.WHITE)
	self.node_list["FangYu"].text.text = Language.CoupleHome.fangyu .. ToColorStr(total_attr.fangyu, TEXT_COLOR.WHITE)

	local power = CommonDataManager.GetCapabilityCalculation(total_attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end

	local now_furniture_count = CoupleHomeHomeData.Instance:GetNowFurnitureCount(self.select_house_index)
	local max_furniture_count = CoupleHomeHomeData.Instance:GetMaxFurnitureCount()
	self.node_list["Text"].text.text = string.format(Language.CoupleHome.NowFurnitureCount, now_furniture_count, max_furniture_count)

	self:UpdateFurnitureAttr()
end

-----------------------CoupleHomeAttrFurnitureCell------------------------
CoupleHomeAttrFurnitureCell = CoupleHomeAttrFurnitureCell or BaseClass(BaseRender)
function CoupleHomeAttrFurnitureCell:__init()
	self.select_house_index = 0
	self.furniture_index = -1

	self.text_obj = self.root_node.text
end

function CoupleHomeAttrFurnitureCell:__delete()
end

function CoupleHomeAttrFurnitureCell:SetSelectHouseClientIndex(select_house_index)
	self.select_house_index = select_house_index
end

function CoupleHomeAttrFurnitureCell:SetFurnitureIndex(furniture_index)
	self.furniture_index = furniture_index
end

function CoupleHomeAttrFurnitureCell:OnFlush()
	local color = TEXT_COLOR.WHITE
	local house_info = CoupleHomeHomeData.Instance:GetHouseInfoByIndex(self.select_house_index)
	if house_info then
		local furniture_list = house_info.furniture_list
		local furniture_info = furniture_list[self.furniture_index]
		local item_id = furniture_info and furniture_info.item_id or 0
		if item_id > 0 then
			color = TEXT_COLOR.GREEN
		end
	end
	
	local name = Language.CoupleHome.FurnitureName[self.furniture_index] or "null"
	name = ToColorStr(name, color)
	self.text_obj.text = name
end