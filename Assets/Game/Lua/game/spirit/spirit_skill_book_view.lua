-- 仙宠-技能图鉴
SpiritSkillBookView = SpiritSkillBookView or BaseClass(BaseView)


function SpiritSkillBookView:__init()
	self.ui_config = {
	{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
	{"uis/views/spiritview_prefab", "SpriteSkillBookView"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function SpiritSkillBookView:__delete()

end

function SpiritSkillBookView:CloseCallBack()
end

function SpiritSkillBookView:ReleaseCallBack()
	for k,v in pairs(self.skill_cells) do
		v:DeleteMe()
	end
	self.skill_cells = {}
end

function SpiritSkillBookView:LoadCallBack()
	self.skill_cells = {}
	self.skill_book_cfg = SpiritData.Instance:GetSpiritSkillBookCfg()
	list_delegate = self.node_list["BookListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.JingLing.Title1
	self.node_list["Bg"].rect.sizeDelta = Vector3(874,600,0)
end

function SpiritSkillBookView:ShowIndexCallBack(index)
	self:Flush()
end

function SpiritSkillBookView:OnFlush(param_list)
	self.node_list["BookListView"].scroller:RefreshActiveCellViews()
end

function SpiritSkillBookView:GetNumberOfCells()
	return SpiritData.Instance:GetSkillBookCfgMaxType()
end

function SpiritSkillBookView:RefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = SpiritSkillBookRender.New(cell.gameObject)
		self.skill_cells[cell] = group
	end

	local data = self.skill_book_cfg[data_index + 1]
	group:SetData(data)
end

-- 仙宠技能图鉴Render
SpiritSkillBookRender = SpiritSkillBookRender or BaseClass(BaseRender)

function SpiritSkillBookRender:__init(instance)
	self.item_list = {}
	self.item_name_list = {}
	self.capacity_list = {}
	self.show_capacity_list = {}
	for i = 1, 5 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetData(nil)
		self.item_list[i] = item
		self.item_name_list[i] = self.node_list["ItemTxt" .. i]
		self.capacity_list[i] = self.node_list["CapacityTxt" .. i]
		self.show_capacity_list[i] = self.node_list["CapacityTxt" ..i]
	end
end

function SpiritSkillBookRender:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end

	self.item_list = {}
end

function SpiritSkillBookRender:SetData(data)
	for i = 1, 5 do
		local item = self.item_list[i]
		local item_name = self.item_name_list[i]
		local text_capacity = self.capacity_list[i]
		local show_capacity = self.show_capacity_list[i]
		local item_id = data["item_id_" .. i]
		local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgByItemId(item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local color = SPRITE_SKILL_LEVEL_COLOR[item_cfg.color]
		local item_cfg_name = ToColorStr(one_skill_cfg.skill_book, color)
		item_name.text.text = item_cfg_name or ""
		item:SetData({["item_id"] = item_id})
		text_capacity.text.text = Language.JingLing.ZhanLi .. (one_skill_cfg.zhandouli or 0)
		show_capacity:SetActive(one_skill_cfg.zhandouli > 0)
	end
	self.node_list["SkillTxt"].text.text = data.type_name or ""
	self.node_list["DesTxt"].text.text = Language.JingLing.SkillDec .. data.des
end
