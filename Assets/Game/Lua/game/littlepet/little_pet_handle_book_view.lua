-- 宠物图鉴
LittlePetHandleBookView = LittlePetHandleBookView or BaseClass(BaseView)

local PET_GROUP_ROW = 4
local PET_GROUP_COLUMN = 4
local MAX_PAGE_COUNT = 5
function LittlePetHandleBookView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/littlepetview_prefab","LittlePetHandleBookView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LittlePetHandleBookView:__delete()

end

function LittlePetHandleBookView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(932,636,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.LittlePet.HandleBook
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Power"])

	self.item_group_list = self.node_list["ListView"]
	local list_simple_delegate = self.item_group_list.list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetItemGroupNumOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshItemGroupCell, self)
	self.item_display_group = {}

	self.model_display = self.node_list["Display"]
	self.model = RoleModel.New("little_pet_handle_book_panel")
	self.model:SetDisplay(self.model_display.ui3d_display, MODEL_CAMERA_TYPE.BASE)
end

function LittlePetHandleBookView:ReleaseCallBack()
	self.fight_text = nil
	for k,v in pairs(self.item_display_group) do
		v:DeleteMe()
	end
	self.item_display_group = {}
	self.item_group_list = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.model_display = nil
end

function LittlePetHandleBookView:OpenCallBack()
	-- 计算页数
	local page_grid_num = PET_GROUP_ROW * PET_GROUP_COLUMN
	local total_grid_num = #LittlePetData.Instance:GetLittlePetCfg()
	local total_page_count = math.ceil(total_grid_num / page_grid_num)
	self.item_group_list.list_page_scroll:SetPageCount(total_page_count)
	-- 只有1页的情况下不显示toggle
	total_page_count = total_page_count == 1 and 0 or total_page_count
	for i = 1, MAX_PAGE_COUNT do
        if total_page_count < i then 
            self.node_list["PageToggle" .. i]:SetActive(false)
        else
            self.node_list["PageToggle" .. i]:SetActive(true)
        end
    end
	self.cur_index = 1
	local pet_cfg = LittlePetData.Instance:GetLittlePetCfg()[self.cur_index]
	local item_cfg = ItemData.Instance:GetItemConfig(pet_cfg.active_item_id)
	if item_cfg then
		self.node_list["PetName"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
		local power = LittlePetData.Instance:CalPetBaseFightPower(false, pet_cfg.active_item_id)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = power
		end
	end
 	self:SetModel(self.cur_index)

	self:Flush()
end

function LittlePetHandleBookView:CloseCallBack()
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end

function LittlePetHandleBookView:GetItemGroupNumOfCell()
	local page_grid_num = PET_GROUP_ROW * PET_GROUP_COLUMN
	local total_grid_num = #LittlePetData.Instance:GetLittlePetCfg()
	local page_count = total_grid_num - page_grid_num

	page_count = (page_count > 0) and page_count or 0
	local page = 0
	if page_count > 0 then
		page = math.floor(page_count / PET_GROUP_ROW / PET_GROUP_COLUMN) + 1
	end

	return (page_grid_num + page * PET_GROUP_ROW * PET_GROUP_COLUMN) / PET_GROUP_ROW
end

function LittlePetHandleBookView:RefreshItemGroupCell(cell, data_index)
	local group = self.item_display_group[cell]
	if nil == group then
		group = LittlePetHandleBookGroup.New(cell)
		group:SetToggleGroup(self.item_group_list.toggle_group)
		self.item_display_group[cell] = group
	end

	-- 计算索引
	local page = math.floor(data_index / PET_GROUP_COLUMN)
	local column = data_index - page * PET_GROUP_COLUMN
	local grid_count = PET_GROUP_COLUMN * PET_GROUP_ROW
	for i = 1, PET_GROUP_ROW do
		-- 获取竖列索引
		local index = (i - 1) * PET_GROUP_COLUMN  + column + (page * grid_count)

		-- 获取数据信息
		local cfg_data = LittlePetData.Instance:GetLittlePetCfg()[index + 1]
		local data = {}
		if cfg_data then
			data.item_id = cfg_data.active_item_id
			data.is_null = false
		else
			data.is_null = true
		end

		if data.index == nil then
			data.index = index + 1
		end
		if data.index==1 then
			self.temp_cell=group
		end
		group:SetData(i, data)
		group:SetHighLight(i, ((self.cur_index - 1) == index and nil ~= data.item_id))
		group:ListenClick(i, BindTool.Bind(self.HandleItemOnClick, self, data, group, i, index))
	end
end

function LittlePetHandleBookView:OnFlush()
	self.node_list["ListView"].scroller:ReloadData(0)
end

function LittlePetHandleBookView:SetModel(index)
	local pet_cfg = LittlePetData.Instance:GetLittlePetCfg()[index]
	if pet_cfg == nil then
		return
	end
	local res_id = pet_cfg.using_img_id or 0
	local bundle, asset = ResPath.GetLittlePetModel(res_id)
	self.model:SetMainAsset(bundle, asset)
	self.model:SetRotation(Vector3(0, -30, 0))
	self.node_list["PetDes"].text.text = pet_cfg.pet_description
	self.model:SetTrigger("rest")
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.model:SetTrigger("rest")
		end, 10)
end

function LittlePetHandleBookView:HandleItemOnClick(data, group, i, index)
	if data == nil or data.item_id == nil then
		return
	end
	if self.cur_index == data.index then
		return
	end
	self.cur_index = data.index
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg then
		self.node_list["PetName"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
		local power = LittlePetData.Instance:CalPetBaseFightPower(false, data.item_id)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = power
		end
	end
 	self:SetModel(data.index)
 	group:SetHighLight(i, ((self.cur_index - 1) == index and nil ~= data.item_id))
end

---------------------- 小宠物图鉴组 ----------------------
LittlePetHandleBookGroup = LittlePetHandleBookGroup or BaseClass(BaseCell)

function LittlePetHandleBookGroup:__init(instance)
	self.cells = {}

	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item"..i])
		self.cells[i] = item
		self.node_list["Lock"..i].button:AddClickListener(BindTool.Bind(self.OnClickLock, self))
	end
end

function LittlePetHandleBookGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function LittlePetHandleBookGroup:SetData(i, data)
	if data.is_null then
		UI:SetGraphicGrey(self.node_list["Item"..i], true)
		self.node_list["Lock"..i]:SetActive(true)
	else
		UI:SetGraphicGrey(self.node_list["Item"..i], false)
		self.node_list["Lock"..i]:SetActive(false)
		self.cells[i]:SetData({item_id = data.item_id})
	end
end

function LittlePetHandleBookGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function LittlePetHandleBookGroup:SetToggleGroup(toggle_group)
	self.cells[1]:SetToggleGroup(toggle_group)
	self.cells[2]:SetToggleGroup(toggle_group)
	self.cells[3]:SetToggleGroup(toggle_group)
	self.cells[4]:SetToggleGroup(toggle_group)
end

function LittlePetHandleBookGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function LittlePetHandleBookGroup:OnClickLock(i, enable)
	TipsCtrl.Instance:ShowSystemMsg(Language.LittlePet.BookItemLockTips)
end


----------------------------------------------------------------