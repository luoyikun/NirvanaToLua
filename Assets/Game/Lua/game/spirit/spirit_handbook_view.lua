SpiritHandbook = SpiritHandbook or BaseClass(BaseView)

-- 这两个表必须一致
local BagTag = {Green = 1, Blue = 2, Purple = 3, Orange = 4, Red = 5}
local ColorId = {"green_soul", "blue_soul", "purple_soul", "orange_soul", "red_soul"}

local COLUMN = 4
local Row = 3
local ColorTypes = 5
local AttrName = Language.JingLing.TipsSoulAttr
local Attrkey = {"gongji", "fangyu", "maxhp", "mingzhong", "shanbi", "baoji", "jianren", "dikang_shanghai"}

function SpiritHandbook:__init()
	local handbook = SpiritData.Instance:GetAllSpiritSoulCfg()
	local exp_data = SpiritData.Instance:GetSpiritSoulExpCfg()
	self.soul_list = {red_soul = {}, orange_soul = {}, purple_soul = {}, blue_soul = {}, green_soul = {}}
	for k, v in pairs(handbook) do
		if v and v.hunshou_color and ColorId[v.hunshou_color] then
			table.insert(self.soul_list[ColorId[v.hunshou_color]], v)
		end
	end
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/spiritview_prefab", "SoulHandBookView"}
	}

	exp_data = ListToMap(exp_data, "hunshou_color", "hunshou_level")
	self.soul_data = {}
	for i = 1, ColorTypes do
		table.insert(self.soul_data, exp_data[i][1])
	end
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SpiritHandbook:__delete()
	self.soul_list = nil
	self.soul_data = nil
end

function SpiritHandbook:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	if self.modle_effect then
		ResMgr:Destroy(self.modle_effect)
		self.modle_effect = nil
	end

	self.cell_list = nil
	self.fight_text = nil
end

function SpiritHandbook:LoadCallBack()
	self.cell_list = {}
	self.lastindex = 5

	self.node_list["ListView"].scroll_rect.enabled = false
	self.node_list["TitleText"].text.text = Language.JingLing.Title
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	for i = 1, 5 do
		self.node_list["HuntToggle" .. i].toggle:AddClickListener(BindTool.Bind(self.ToggleColor, self, i))
	end
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerTxt"])
end

function SpiritHandbook:OpenCallBack()
	if self.cell_list[1] then
		self:FlushSoul(BagTag.Red)
	end
	self.node_list["HuntToggle5"].toggle.isOn = true
end

function SpiritHandbook:CloseCallBack()
end


function SpiritHandbook:ToggleColor(state)

	if self.lastindex ~= state then
		self:FlushSoul(state)
	end
	self.lastindex = state
end

function SpiritHandbook:FlushSoul(state) 
	self:SetView(self.soul_list[ColorId[state]])
	self:FlushIntroduce(self.soul_list[ColorId[state]][1])
	self.cell_list[1].items[1].gameobject.toggle.isOn = true
end

function SpiritHandbook:CloseWindow()
	self:Close()
end
function SpiritHandbook:GetCellNumber()
	return 4
end
function SpiritHandbook:CellRefreshDel(cell, data_index, cell_Index)

	local group_cell = nil
	data_index = data_index + 1
	if nil == group_cell then
		group_cell = SoulHandBookGroup.New(cell.gameObject)
		self.cell_list[data_index] = group_cell
	end
	if data_index == 4 then
		self:FlushSoul(BagTag.Red)
	end
end

function SpiritHandbook:FlushIntroduce(itemdata)
	if itemdata then
		self:LoadEffect(itemdata, self.node_list["ModelRoot"])

		local str = "<color=%s>" .. itemdata.name .. "</color>"
		local attr = AttrName[itemdata.hunshou_type + 1]
		local value = self.soul_data[itemdata.hunshou_color][Attrkey[itemdata.hunshou_type + 1]]
		self.node_list["SoulNameTxt"].text.text = string.format(str, SOUL_NAME_COLOR[itemdata.hunshou_color])
		self.node_list["AttrTxt"].text.text = string.format("%s<color=#FFFFFF>+%s</color>", attr, value)

		local fight_table = {}
		local attr_key = Attrkey[itemdata.hunshou_type + 1]
		fight_table[attr_key] = self.soul_data[itemdata.hunshou_color][attr_key]
		local fight = CommonDataManager.GetCapability(fight_table)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = fight
		end
		self.node_list["IntroductionTxt"].text.text = itemdata.description

		local color_name = Common_Five_Rank_Color[itemdata.hunshou_color]
		self.node_list["QualityImg"].image:LoadSprite(ResPath.GetQualityTagBg(color_name))
		self.node_list["QualityTxt"].text.text = Language.QualityAttr[color_name]
	end
end

function SpiritHandbook:SetView(soul_list)
	local m = 1
	for j = 1, Row do
		for i = 1, COLUMN do
			if soul_list[m] then
				self.cell_list[i].items[j]:SetData(soul_list[m])
				m = m + 1
			else
				local soul_item = self.cell_list[i].items[j]
				soul_item:SetLock()
				local item_gameobject = soul_item.gameobject
				if item_gameobject.toggle.enabled == true then
					item_gameobject.toggle.enabled = false
				else
					item_gameobject.toggle.enabled = true
					item_gameobject.toggle.enabled = false
				end
			end
		end
	end
end

function SpiritHandbook:LoadEffect(itemdata, model_root)
	if self.modle_effect and itemdata.hunshou_id < 0 then
		self.modle_effect:SetActive(false)
		return
	end

	local bundle_name, asset_name = ResPath.GetUiJingLingMingHunResid(itemdata.hunshou_effect)
	local async_loader = AllocAsyncLoader(self, "soul_effect")
	async_loader:SetParent(model_root.transform)
	async_loader:Load(bundle_name, asset_name, function (obj)
		if IsNil(obj) then
			return
		end
		self.modle_effect = obj.gameObject
	end)
end
--------------------SoulHandBookGroup---------------------------
SoulHandBookGroup = SoulHandBookGroup or BaseClass(BaseRender)
function SoulHandBookGroup:__init()
	self.items = {}
	for i = 1, 3 do
		self.items[i] = SoulHandBookItem.New(self.node_list["SoulHandbookItem" .. i])
	end
end

function SoulHandBookGroup:__delete()
	for k, v in ipairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end
-------------------SoulHandBookItem-----------------------
SoulHandBookItem = SoulHandBookItem or BaseClass(BaseRender)
function SoulHandBookItem:__init()
	self.max_Level = 100
	self.effect = nil
	self.is_load = false
	self.is_stop_load_effect = false
	self.gameobject = self.node_list["Self"]
	self.gameobject.toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
	self.gameobject.toggle.group = SpiritCtrl.Instance.spirit_handbook_view.node_list["ListView"].toggle_group
end

function SoulHandBookItem:__delete()

end

function SoulHandBookItem:SetToggleHighLight(state)

end
function SoulHandBookItem:ClickItem()
	if self.data then
		if self.gameobject.toggle.isOn == true then
			SpiritCtrl.Instance.spirit_handbook_view:FlushIntroduce(self.data)
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.NoOpen)
	end

end
function SoulHandBookItem:SetData(data)
	self.data = data
	if self.data then
		self:LoadEffect(data, self.node_list["Icon"])
		local str = "<color=%s>" .. self.data.name .. "</color>"
		self.node_list["NameTxt"].text.text = string.format(str, SOUL_NAME_COLOR[self.data.hunshou_color])
	else

	end
end

function SoulHandBookItem:SetLock()
	self.node_list["ItemImg"].image:LoadSprite(ResPath.GetIconLock("02"))
end

function SoulHandBookItem:LoadEffect(itemdata, model_root)
	if self.modle_effect and itemdata.hunshou_id < 0 then
		self.modle_effect:SetActive(false)
		return
	end

	local bundle_name, asset_name = ResPath.GetUiJingLingMingHunResid(itemdata.hunshou_effect)
	local async_loader = AllocAsyncLoader(self, "soul_effect")
	async_loader:SetParent(model_root.transform)
	async_loader:Load(bundle_name, asset_name, function (obj)
		if IsNil(obj) then
			return
		end
		self.modle_effect = obj.gameObject
	end)
end
