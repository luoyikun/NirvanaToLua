-- 仙宠技能批量刷新-FlsuhSpriteSkillBigView
FlushSpiriBigSkillView = FlushSpiriBigSkillView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 10
local BAG_ROW = 2
local BAG_COLUMN = 5

function FlushSpiriBigSkillView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/spiritview_prefab", "FlsuhSpriteSkillBigView"},
	}
	self.play_audio = true
	self.skill_cells = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function FlushSpiriBigSkillView:__delete()

end

function FlushSpiriBigSkillView:OpenCallBack()
	self.has_can_use = false
end

function FlushSpiriBigSkillView:CloseCallBack()
	SpiritData.Instance:SetIsStartQuickFlush(false)
end

function FlushSpiriBigSkillView:ReleaseCallBack()
	self.node_list["SkillList"] = nil
	self.cur_cell_info = nil
	for k,v in pairs(self.skill_cells) do
		v:DeleteMe()
	end
	self.skill_cells = {}
end

function FlushSpiriBigSkillView:LoadCallBack()
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	local cell_info = sprite_info.skill_refresh_item_list[0]
	self.cur_cell_info = cell_info

	self.node_list["Bg"].rect.sizeDelta = Vector3(880, 660, 0)
	self.node_list["Txt"].text.text = Language.JingLing.TabbarName[14]
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnFlsuh"].button:AddClickListener(BindTool.Bind(self.FlsuhSkill, self, 1))
	self.node_list["BtnOneFlush"].button:AddClickListener(BindTool.Bind(self.FlsuhSkill, self, 0))
	self.node_list["BtnAutoFlush"].button:AddClickListener(BindTool.Bind(self.FlsuhSkillAuto, self))
	self.node_list["BtnStop"].button:AddClickListener(BindTool.Bind(self.OnClickStop, self))

	local list_delegate = self.node_list["SkillList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function FlushSpiriBigSkillView:GetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function FlushSpiriBigSkillView:RefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = SpiritFlushSkillGroup.New(cell.gameObject)
		self.skill_cells[cell] = group
	end
	group:SetToggleGroup(self.node_list["SkillList"].toggle_group)
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	local cell_info = sprite_info.skill_refresh_item_list[0]
	local skill_list = cell_info.skill_list
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count) + 1
		local data = {}
		data.skill_id = skill_list[index]
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group.parent_view = self
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
	end
end

--点击格子事件
function FlushSpiriBigSkillView:HandleBagOnClick(data, group, group_index, data_index)
	
end

function FlushSpiriBigSkillView:OpenCallBack(index)
	self:Flush()
end

function FlushSpiriBigSkillView:OnFlush()
	self.has_can_use = false
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	local cell_info = sprite_info.skill_refresh_item_list[0]
	local other_cfg = SpiritData.Instance:GetSpiritOtherCfg()
	local have_num = ItemData.Instance:GetItemNumInBagById(other_cfg.skill_refresh_consume_id)

	local refresh_count = cell_info.refresh_count
	local skill_refresh_cfg = SpiritData.Instance:GetSkliiFlsuhStageByTimes(refresh_count)
	-- 描述处理
	self.node_list["flsuhTxt"].text.text = skill_refresh_cfg.desc or ""

	-- 星星处理
	local stage = skill_refresh_cfg.stage or 0
	local show_star = stage + 1
	local activate_bundle, activate_asset = ResPath.GetImages("star18")
	local gray_bundle, gray_asset = ResPath.GetImages("star17")

	local star_width = 41
	local star_height = 39
	local max_count = skill_refresh_cfg.max_count or 0
	local min_count = skill_refresh_cfg.min_count or 0
	local cur_star_full_times = max_count - min_count
	local cur_star_flush_times = refresh_count - min_count
	local star_percent = cur_star_flush_times / cur_star_full_times
	local cur_star_width = star_width * star_percent

	for i = 1, 8 do
		if i <= show_star then
			self.node_list["star" .. i]:SetActive(true)
			if i == show_star then
				-- 当前的星星要做遮罩显示处理
				self.node_list["star" .. i].rect.sizeDelta = Vector2(cur_star_width, star_height)
			else
				self.node_list["star" .. i].rect.sizeDelta = Vector2(star_width, star_height)
			end
		else
			self.node_list["star" .. i]:SetActive(false)
		end
	end

	-- 网格刷新
	self.node_list["SkillList"].scroller:RefreshActiveCellViews()

	-- 批量刷新消耗显示
	local one_color = TEXT_COLOR.GREEN
	if have_num < other_cfg.refresh_ten_consume_count then
		one_color = TEXT_COLOR.RED
	end
	local str = ToColorStr(have_num, one_color)
	self.node_list["costTxt"].text.text = str .. " / " .. other_cfg.refresh_ten_consume_count

	-- 单刷免费刷新次数
	local free_flush_count = SpiritData.Instance:GetFreeFlushLeftTimes()
	if free_flush_count > 0 then
		self.node_list["TextFreeCount"].text.text = string.format(Language.JingLing.FreeRefreshTimes, free_flush_count)
		self.node_list["TextOneCost"].text.text = ""
		self.node_list["ImgDiamonOne"]:SetActive(false)
	else
		self.node_list["TextFreeCount"].text.text = ""
		local one_color = TEXT_COLOR.GREEN
		if have_num < other_cfg.refresh_one_consume_count then
			one_color = TEXT_COLOR.RED
		end
		local str = ToColorStr(have_num, one_color)
		self.node_list["TextOneCost"].text.text = str .. " / " .. other_cfg.refresh_one_consume_count
		self.node_list["ImgDiamonOne"]:SetActive(true)
	end

	self.node_list["FlushRedPoint"]:SetActive(free_flush_count > 0)
	self:FlushAutoButton()
end

function FlushSpiriBigSkillView:FlushAutoButton()
	local is_start = SpiritData.Instance:GetIsStartQuickFlush()
	self.node_list["BtnStop"]:SetActive(is_start)
	self.node_list["BtnAutoFlush"]:SetActive(not is_start)
end

function FlushSpiriBigSkillView:FlsuhSkillAuto()
	SpiritData.Instance:ClearSelectFlushList()
	ViewManager.Instance:Open(ViewName.SpiritSkillQuickFlushView)
end

function FlushSpiriBigSkillView:OnClickStop()
	SpiritData.Instance:SetIsStartQuickFlush(false)
end

-- 技能刷新
function FlushSpiriBigSkillView:FlsuhSkill(is_batch_flush)
	local func = function()
		local other_cfg = SpiritData.Instance:GetSpiritOtherCfg()
		local have_num = ItemData.Instance:GetItemNumInBagById(other_cfg.skill_refresh_consume_id)

		if is_batch_flush == 0 then  -- 单次刷新
			if SpiritData.Instance:GetFreeFlushLeftTimes() > 0 then
				SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, 0, is_batch_flush)
				return
			end
			if have_num >= other_cfg.refresh_one_consume_count then
				SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, 0, is_batch_flush)
			else
				local shop_data = ShopData.Instance:GetShopItemCfg(other_cfg.skill_refresh_consume_id)
				if not shop_data then
					return
				end
				local function ok_callback()
					SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, 0, is_batch_flush, 1)
				end
				local differ_num = other_cfg.refresh_one_consume_count - have_num
				local item_cfg = ItemData.Instance:GetItemConfig(other_cfg.skill_refresh_consume_id) or {}
				local color = item_cfg.color or 1
				local color_str = ITEM_COLOR[color]
				local name = item_cfg.name or ""
				local cost = shop_data.gold * differ_num
				local des = string.format(Language.Rune.NotEnoughDes2, color_str, name, cost)
				TipsCtrl.Instance:ShowCommonAutoView("rune_one_xunbao", des, ok_callback)
			end
		else
			if have_num >= other_cfg.refresh_ten_consume_count then
				SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, 0, is_batch_flush)
			else
				local shop_data = ShopData.Instance:GetShopItemCfg(other_cfg.skill_refresh_consume_id)
				if not shop_data then
					return
				end
				local function ok_callback()
					SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, 0, is_batch_flush, 1)
				end
				local differ_num = other_cfg.refresh_ten_consume_count - have_num
				local item_cfg = ItemData.Instance:GetItemConfig(other_cfg.skill_refresh_consume_id) or {}
				local color = item_cfg.color or 1
				local color_str = ITEM_COLOR[color]
				local name = item_cfg.name or ""
				local cost = shop_data.gold * differ_num
				local des = string.format(Language.Rune.NotEnoughDes2, color_str, name, cost)
				TipsCtrl.Instance:ShowCommonAutoView("rune_one_xunbao", des, ok_callback)
			end
		end
	end

	if self.has_can_use then
		TipsCtrl.Instance:ShowCommonAutoView("", Language.JingLing.ContinueToFlush, func)
		return
	end
	func()
end

------------------------------------------------------------------------------------
SpiritFlushSkillGroup = SpiritFlushSkillGroup or BaseClass(BaseRender)

function SpiritFlushSkillGroup:__init(instance)
	self.skills = {}
	for i = 1, BAG_ROW do
		self.skills[i] = {}
		self.skills[i].obj = self.node_list["Skill" .. i]
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetData(nil)
		self.skills[i].item = item
		self.skills[i].node_list = U3DNodeList(self.skills[i].obj:GetComponent(typeof(UINameTable)))
		self.node_list["SkillBtn" .. i].button:AddClickListener(BindTool.Bind(self.BuySkill, self, i))
	end
end

function SpiritFlushSkillGroup:__delete()
	self.skills = {}
	self.parent_view = nil
end

function SpiritFlushSkillGroup:BuySkill(item_index)
	local data = self.skills[item_index].data
	if nil == data or data.skill_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseFlushSkill)
		return
	end
	
	local skill_index = data.index
	SpiritData.Instance:SetIsStartQuickFlush(false)
	SpiritData.Instance:ClearSelectFlushList()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_GET, 0, skill_index)
	SpiritCtrl.Instance:CloseFlsuhSkillBigView()
end

function SpiritFlushSkillGroup:SetData(i, data)
	
	self.skills[i].data = data
	local skill_item = self.skills[i]
	skill_item.node_list["NameTxt"]:SetActive(false)
	skill_item.node_list["Tips"]:SetActive(false)
	skill_item.node_list["Improve"]:SetActive(false)

	local item = self.skills[i].item
	local skill_id = data.skill_id
	local sprite_index = 0
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	if nil == one_skill_cfg then
		skill_item.node_list["SkillTxt"].text.text = ""
		item:SetData(nil)
		item:ShowItemRewardEffect(false)
		return
	end

	local sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	local is_show_spirit_name = false
	for i=0, 3 do
		is_show_spirit_name = SpiritData.Instance:GetHasLearnSkillList(i, skill_id, one_skill_cfg.skill_type)
		if is_show_spirit_name == true then
			if self.parent_view then
				self.parent_view.has_can_use = true
			end
			sprite_index = i
			break
		end
	end
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}
	local sprite_name_id = spirit_list[sprite_index] and spirit_list[sprite_index].item_id or 0

	if sprite_name_id ~= 0 then
		local sprite_name = ItemData.Instance:GetItemConfig(sprite_name_id).name
		skill_item.node_list["NameTxt"].text.text = sprite_name
	end
	-- 图标名字设置
	local item_color = SPRITE_SKILL_LEVEL_COLOR_TWO[one_skill_cfg.skill_level]
	local item_name = ToColorStr(one_skill_cfg.skill_name, item_color)
	skill_item.node_list["SkillTxt"].text.text = item_name
	skill_item.node_list["NameTxt"]:SetActive(is_show_spirit_name)
	skill_item.node_list["Tips"]:SetActive(is_show_spirit_name)
	skill_item.node_list["Improve"]:SetActive(is_show_spirit_name)

	
	local start_pos4 = Vector3(31 , -12 , 0)
	local end_pos4 = Vector3(31 , 0 , 0)
	UITween.MoveLoop(skill_item.node_list["Improve"], start_pos4, end_pos4, 1)
	item:SetData({["item_id"] = one_skill_cfg.book_id})
	if one_skill_cfg.skill_id then
		local list = SpiritData.Instance:GetSelectFlushList()
		item:ShowItemRewardEffect(nil ~= list[one_skill_cfg.skill_id])
	end

end

function SpiritFlushSkillGroup:ListenClick(i, handler)
end

function SpiritFlushSkillGroup:SetToggleGroup(toggle_group)
end

function SpiritFlushSkillGroup:SetHighLight(i, enable)
end

function SpiritFlushSkillGroup:ShowHighLight(i, enable)
end

function SpiritFlushSkillGroup:SetInteractable(i, enable)
end