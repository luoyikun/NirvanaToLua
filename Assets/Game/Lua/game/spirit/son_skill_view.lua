-- 仙宠-技能-SkillContent
SonSkillView = SonSkillView or BaseClass(BaseRender)

local BAG_MAX_GRID_NUM = 60
local BAG_ROW = 5
local BAG_COLUMN = 4

local SKILL_MAX_GRID_NUM = 10
local SKILL_ROW = 2
local SKILL_COLUMN = 5

local STORAGDE_MAX_GRID_NUM = 60
local STORAGDE_ROW = 5
local STORAGDE_COLUMN = 4

local EFFECT_CD = 1

SonSkillView.ViewType = {
	["SkillView"] = 1,
	["StorageView"] = 2,
}

function SonSkillView:__init(instance)

end

function SonSkillView:LoadCallBack(instance)
	self.items = {}
	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		item_cell:SetToggleGroup(self.node_list["ItemToggleGroup"].toggle_group)
		self.items[i] = {item = self.node_list["Item" .. i], cell = item_cell}
		self.items[i].red_point = self.node_list["item_red_point_" .. i]
	end
	self.effect_root = self.node_list["EffectRoot"]
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Txtzhanli"])

	local list_delegate = self.node_list["SkillBagListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	list_delegate = self.node_list["SkillBookListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.SkillGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.SkillRefreshCell, self)

	self.skill_storage_list = SpiritData.Instance:GetSkillStorageList()
	list_delegate = self.node_list["SkillStorageListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.StorageGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.StorageRefreshCell, self)

	self.cur_click_index = 1
	self.is_first = true
	self.temp_spirit_list = {}
	self.res_id = 0
	self.fix_show_time = 8
	self.is_click_item = false
	self.bag_cells = {}
	self.skill_cells = {}
	self.storage_cells = {}
	self.cur_show_view = SonSkillView.ViewType.SkillView

	self.node_list["SkillPokedexBtn"].toggle:AddClickListener(BindTool.Bind(self.OnClickSkillPokedex, self))
	self.node_list["SkillGetBtn"].toggle:AddClickListener(BindTool.Bind(self.OnClickSkillGet, self))
	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["ToggleFengYin"].toggle:AddClickListener(BindTool.Bind(self.FlsuhStorageView, self))
end

function SonSkillView:__delete()
	for k, v in pairs(self.items) do
		v.cell:DeleteMe()
	end
	self.items = nil
	self.is_first = nil
	self.temp_spirit_list = nil
	self.res_id = nil
	self.fix_show_time = nil

	for k,v in pairs(self.bag_cells) do
		v:DeleteMe()
	end
	self.bag_cells = {}
	for k,v in pairs(self.skill_cells) do
		v:DeleteMe()
	end
	self.skill_cells = {}
	for k,v in pairs(self.storage_cells) do
		v:DeleteMe()
	end
	self.storage_cells = {}
	self.skill_bag_toggle = nil
	self.skill_storage_toggle = nil
	self.fight_text = nil
end

function SonSkillView:SetToggle(skill_bag_toggle, skill_storage_toggle)
	self.skill_bag_toggle = skill_bag_toggle
	self.skill_storage_toggle = skill_storage_toggle
end

function SonSkillView:OpenCallBack(skill_bag_toggle, skill_storage_toggle)
	self.is_first = true
	self.res_id = 0

	for k,v in pairs(self.items) do
		v.cell:SetData({})
		v.cell:SetHighLight(false)
	end
end

function SonSkillView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	self.time_quest = nil
	self.res_id = 0
	self.is_first = true
end

function SonSkillView:OnClickSkillPokedex()
	SpiritCtrl.Instance:OpenSkillBookView()
end

-- 打开技能批量刷新面板
function SonSkillView:OnClickSkillGet()
	SpiritCtrl.Instance:OpenFlsuhSkillBigView()
end

function SonSkillView:SkillGetNumberOfCells()
	return SKILL_MAX_GRID_NUM / SKILL_ROW
end

function SonSkillView:SkillRefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = SpiritSkillRenderGroup.New(cell.gameObject)
		self.skill_cells[cell] = group
	end
	group:SetToggleGroup(self.node_list["SkillBookListView"].toggle_group)

	local cur_sprite_skill_list = self.cur_data and self.cur_data.param.jing_ling_skill_list or {}
	-- local page = math.floor(data_index / SKILL_COLUMN)
	-- local column = data_index - page * SKILL_COLUMN
	-- local grid_count = SKILL_COLUMN * SKILL_ROW
	for i = 1, SKILL_ROW do
		-- local index = (i - 1) * SKILL_COLUMN + column --+ (page * grid_count)
		local index = data_index * SKILL_ROW + i -1
		local data = nil
		data = cur_sprite_skill_list[index]
		data = data or {}
		data.locked = false
		if data.index == nil then
			data.index = index
		end

		group:SetData(i, data)

	end
end

function SonSkillView:StorageGetNumberOfCells()
	return STORAGDE_MAX_GRID_NUM / STORAGDE_ROW
end

function SonSkillView:StorageRefreshCell(cell, data_index)
	local group = self.storage_cells[cell]
	if nil == group  then
		group = SpiritSkillStorageRenderGroup.New(cell.gameObject)
		self.storage_cells[cell] = group
	end

	local page = math.floor(data_index / STORAGDE_COLUMN)
	local column = data_index - page * STORAGDE_COLUMN
	local grid_count = STORAGDE_COLUMN * STORAGDE_ROW
	for i = 1, STORAGDE_ROW do
		local index = (i - 1) * STORAGDE_COLUMN + column + (page * grid_count)
		local data = {}
		data = self.skill_storage_list[index + 1]
		group:SetData(i, data)
	end
end

--点击格子事件
function SonSkillView:HandleSkillOnClick(data, group, group_index, data_index)
end

function SonSkillView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function SonSkillView:BagRefreshCell(cell, data_index)
	local group = self.bag_cells[cell]
	if group == nil  then
		group = SpiritSkillBagGroup.New(cell.gameObject)
		self.bag_cells[cell] = group
	end
	group:SetToggleGroup(self.node_list["SkillBagListView"].toggle_group)
	local book_item_list = SpiritData.Instance:GetBagSkillBookItem()
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	local cur_sprite_index = nil ~= self.cur_data and self.cur_data.index or 0
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count)
		local data = nil
		data = book_item_list[index + 1] or {}
		group:SetData(i, data)
		group:ShowEffect(i, cur_sprite_index, data)
		group:ShowHighLight(i, false)
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
	end
	self:ResetItemsRewardEffect()
end

--点击格子事件
function SonSkillView:HandleBagOnClick(data, group, group_index, data_index)
	if nil == data or nil == data.item_id then
		return
	end

	if nil == self.cur_data then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseEquipJingLing)
		return
	end
	SpiritData.Instance:SetSpiritSkillViewCellData(data)
	SpiritCtrl.Instance:OpenSkillInfoView(SpiritSkillInfo.FromView.SpriteSkillBookBagView)
end

function SonSkillView:ResetItemsRewardEffect()
	if self.bag_cells then
		for k,v in pairs(self.bag_cells) do
			if v.cells then
				for k1,v1 in pairs(v.cells) do
					v1:ResetRewardEffect()
				end
			end
		end
	end
end

function SonSkillView:OnFlush()
	self.cur_data = nil
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}

	for k, v in pairs(self.items) do
		local can_use = SpiritData.Instance:CheckRedPoint(k - 1)
		v.red_point:SetActive(can_use)
		if v.cell:GetData().item_id then
			if nil == spirit_list[k - 1] then
				v.red_point:SetActive(false)
				if self.cur_click_index == k then
					if UIScene.role_model then
						local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
						if part then
							part:DeleteMe()
							self.res_id = 0
						end
					end
				end
				v.cell:SetData({})
				v.cell:ClearItemEvent()
				v.cell:SetInteractable(false)
				v.cell:SetHighLight(false)
				self.cur_click_index = nil
			else
				if v.cell:GetData().param.strengthen_level < spirit_list[k - 1].param.strengthen_level then
					if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
						AudioService.Instance:PlayAdvancedAudio()
						local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
						EffectManager.Instance:PlayAtTransformCenter(bundle_name, asset_name, self.effect_root.transform, 2.0)
						self.effect_cd = Status.NowTime + EFFECT_CD
					end
				end
				v.cell:IsDestroyEffect(false)
				v.cell:SetData(spirit_list[k - 1])
				v.cell:SetHighLight(self.cur_click_index == k)
			end
		elseif spirit_list[k - 1] and nil == v.cell:GetData().item_id and self.is_first then
			if vo.used_sprite_id == spirit_list[k - 1].item_id then
				self.cur_click_index = k
			elseif (not self.cur_click_index and spirit_list[k - 1]) or (not self.temp_spirit_list[k - 1] and spirit_list[k - 1] and not self.is_first) then
				self.cur_click_index = k
			end
			v.cell:SetData(spirit_list[k - 1])
			v.cell:ListenClick(BindTool.Bind(self.OnClickItem, self, k, spirit_list[k - 1], v.cell))
			v.cell:SetInteractable(true)
			v.cell:SetHighLight(self.cur_click_index == k)
		else
			v.cell:SetData({})
			v.cell:SetInteractable(false)
		end
	end

	if self.cur_click_index and spirit_list[self.cur_click_index - 1] then
		self.cur_data = spirit_list[self.cur_click_index - 1]
	end

	self.temp_spirit_list = spirit_list
	self.is_first = false

	local cur_sprite_index = nil ~= self.cur_data and self.cur_data.index or 0
	SpiritData.Instance:SetSkillViewCurSpriteIndex(cur_sprite_index)

	if self.node_list["ToggleXueXi"].toggle.isOn then
		self.cur_show_view = SonSkillView.ViewType.SkillView
	else
		self.cur_show_view = SonSkillView.ViewType.StorageView
	end

	if self.cur_show_view == SonSkillView.ViewType.SkillView then
		self:FlsuhSkillView()
	else
		self:FlsuhStorageView()
	end
	self.node_list["Txtbag"].text.text = Language.JingLing.BagNameList[self.cur_show_view]

	self.node_list["SkillBagListView"]:SetActive(self.cur_show_view == SonSkillView.ViewType.SkillView)
	self.node_list["BagPageButtons"]:SetActive(self.cur_show_view == SonSkillView.ViewType.SkillView)
	self.node_list["SkillStorageListView"]:SetActive(self.cur_show_view == SonSkillView.ViewType.StorageView)
	self.node_list["StoragePageButtons"]:SetActive(self.cur_show_view == SonSkillView.ViewType.StorageView)

	self.node_list["SkillBookListView"].scroller:RefreshActiveCellViews()
	self.node_list["SkillGetRemind"]:SetActive(SpiritData.Instance:ShowGetSkillRedPoint())
	if nil == self.cur_data then
		self.node_list["NameNode"]:SetActive(false)
		return
	end
	self.node_list["NameNode"]:SetActive(true)
	local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.cur_data.item_id)
	if spirit_cfg and spirit_cfg.res_id and spirit_cfg.res_id > 0 then
		if spirit_cfg.res_id ~= self.res_id then
			PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
			local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
			-- 展示场景特效
			UIScene:LoadSceneEffect(bundle, asset)
			local load_list = {{bundle, asset}}
			self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
			if UIScene.role_model then
				local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
				if part then
					part:SetTrigger(ANIMATOR_PARAM.REST)
				end
			end
			self.res_id = spirit_cfg.res_id
		end
	end

	-- 仙宠名字刷新
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
	SpiritData.Instance:SetCurSpiritName(item_cfg.name)
	self.node_list["NameTxt"].text.text = string.format("Lv.%s·%s", self.cur_data.param.strengthen_level, name_str)
	local zhanli = 0
	for k,v in pairs(self.cur_data.param.jing_ling_skill_list) do
		local one_skill_cfg = nil
		one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(v.skill_id)
		if one_skill_cfg then
			zhanli = zhanli + one_skill_cfg.zhandouli
		end
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = zhanli
	end
end

function SonSkillView:OnClickItem(index, data, cell)
	cell:SetHighLight(true)
	if self.cur_click_index == index then
		return
	end
	self.cur_data = data
	self.cur_click_index = index
	self.is_click_item = true

	self:Flush()
end

function SonSkillView:OpenSkillView()
	self.cur_show_view = SonSkillView.ViewType.SkillView
	self:Flush()
end

function SonSkillView:OpenStorageView()
	self.cur_show_view = SonSkillView.ViewType.StorageView
	self:Flush()
end

function SonSkillView:FlsuhSkillView()
	if self.skill_bag_toggle then
		self.skill_bag_toggle.toggle.isOn = true
	end

	self.node_list["SkillBagListView"].scroller:RefreshActiveCellViews()
end

function SonSkillView:FlsuhStorageView()
	if self.skill_storage_toggle then
		self.skill_storage_toggle.toggle.isOn = true
	end

	self.skill_storage_list = SpiritData.Instance:GetSkillStorageList()
	self.node_list["SkillStorageListView"].scroller:RefreshActiveCellViews()
end

function SonSkillView:OnClickHelp()
	local tip_id = 43
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

function SonSkillView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end

function SonSkillView:UITween()
	UITween.MoveShowPanel(self.node_list["BtnPanel"], Vector3(-60.7, 170, 0), 0.7)
	-- UITween.MoveShowPanel(self.node_list["HelpBtn"], Vector3(63.5, 30, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["SkillList"], Vector3(127, -70, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Background"], Vector3(307, 2, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-200, -24, 0), 0.7)
	
	UITween.AlpahShowPanel(self.node_list["NameNode"], true, 0.5, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["TaiZi"], true, 0.5, DG.Tweening.Ease.InExpo)
end

---------------------------------------------------------------------
-- 仙宠技能格子
SpiritSkillBagGroup = SpiritSkillBagGroup or BaseClass(BaseRender)
function SpiritSkillBagGroup:__init(instance)
	self.cells = {}
	for i = 1, BAG_ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
end

function SpiritSkillBagGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function SpiritSkillBagGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function SpiritSkillBagGroup:ShowEffect(i, sprite_index, data)
	if data == nil then
		return
	end
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgByItemId(data.item_id)
	if one_skill_cfg then
		local skill_id = one_skill_cfg.skill_id
		local skill_type = one_skill_cfg.skill_type
		local to_learn_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
		if to_learn_skill_cfg then
			local pre_skill_id = to_learn_skill_cfg.pre_skill
			if sprite_index and skill_id and skill_type then
				local _, has_pre_skill = SpiritData.Instance:GetLearnSkillCellIndex(sprite_index, skill_id)
				local is_null = SpiritData.Instance:CheckIsNull(sprite_index)
				local has_learn = SpiritData.Instance:CheckHasLearnOrNot(sprite_index, skill_id, skill_type)
				if pre_skill_id == 0 and is_null and not has_learn then
					has_pre_skill = true
				end
				self.cells[i]:ShowItemRewardEffect(has_pre_skill)
				return
			end
		end
	end
	self.cells[i]:ShowItemRewardEffect(false)
end

function SpiritSkillBagGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function SpiritSkillBagGroup:SetToggleGroup(toggle_group)
	for k, v in ipairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function SpiritSkillBagGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function SpiritSkillBagGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function SpiritSkillBagGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

-------------------------------------------------------------------
-- 仙宠技能格子
SpiritSkillRenderGroup = SpiritSkillRenderGroup or BaseClass(BaseRender)

function SpiritSkillRenderGroup:__init(instance)
	self.skills = {}
	for i = 1, SKILL_ROW do
		self.skills[i] = SpiritSkillRenderCell.New(self.node_list["Item" .. i])
		self.skills[i]:AddClickEventListener(BindTool.Bind(self.OnClickSkillItem, self, i))
	end
end

function SpiritSkillRenderGroup:OnClickSkillItem(index)
	local data = self.skills[index]:GetData()
	if nil == data then
		return
	end

	local cur_select_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex() or 0
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}
	local cur_sprite_info = spirit_list[cur_select_sprite_index] or {}
	
	local is_slot_open = false
	local is_show_add_icon = false
	if cur_sprite_info.param then
		is_slot_open = (cur_sprite_info.param.jing_ling_skill_list[data.index].is_slot_open ~= 0)

		if not is_slot_open then
			if data.index > 0 then
				is_show_add_icon = (cur_sprite_info.param.jing_ling_skill_list[data.index - 1].is_slot_open ~= 0) and true or false
			else
				is_show_add_icon = true
			end
		end
	end

	if not is_slot_open and not is_show_add_icon then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SkillCellNotOpen)
		return
	end

	if is_show_add_icon and not is_slot_open then
		local callback = function()
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_OPEN_SKILL_SLOT, cur_select_sprite_index, data.index, nil, nil, nil)
		end
		local skill_slot_open_cfg = SpiritData.Instance:GetSkillSlotOpenCfg()
		TipsCtrl.Instance:ShowCommonAutoView("", string.format(Language.JingLing.SkillSlotOpen, skill_slot_open_cfg[data.index + 1].gold), callback, nil, false)
	end

	if data.skill_id == 0 then
		return
	end

	SpiritData.Instance:SetSpiritSkillViewCellData(data)
	SpiritCtrl.Instance:OpenSkillInfoView(SpiritSkillInfo.FromView.SpriteSkillView)
end

function SpiritSkillRenderGroup:__delete()
	for k, v in pairs(self.skills) do
		v:DeleteMe()
	end
	self.skills = {}
end

function SpiritSkillRenderGroup:SetData(i, data)
	self.skills[i]:SetData(data)
end

function SpiritSkillRenderGroup:ListenClick(i, handler)

end

function SpiritSkillRenderGroup:SetToggleGroup(toggle_group)

end

function SpiritSkillRenderGroup:SetHighLight(i, enable)

end

function SpiritSkillRenderGroup:ShowHighLight(i, enable)

end

function SpiritSkillRenderGroup:SetInteractable(i, enable)

end

------------------------------------------------------------------------------------------------------------------
-- 技能封印格子
SpiritSkillStorageRenderGroup = SpiritSkillStorageRenderGroup or BaseClass(BaseRender)

function SpiritSkillStorageRenderGroup:__init(instance)
	self.skills = {}
	for i = 1, STORAGDE_ROW do
		self.skills[i] = SpiritSkillStorageRenderCell.New(self.node_list["Item" .. i])
		self.skills[i]:AddClickEventListener(BindTool.Bind(self.OnClickSkillItem, self, i))
	end
end

function SpiritSkillStorageRenderGroup:__delete()
	for k, v in pairs(self.skills) do
		v:DeleteMe()
	end
	self.skills = {}
end

function SpiritSkillStorageRenderGroup:OnClickSkillItem(index)
	local data = self.skills[index]:GetData()
	if nil == data or data.skill_id == 0 then
		return
	end

	SpiritData.Instance:SetSpiritSkillViewCellData(data)
	SpiritCtrl.Instance:OpenSkillInfoView(SpiritSkillInfo.FromView.SpriteSkillStorageView)
end

function SpiritSkillStorageRenderGroup:SetData(i, data)
	self.skills[i]:SetData(data)
end


----------------------------------------------------------------------------------------------------------------------
--SpiritSkillRenderCell

SpiritSkillRenderCell = SpiritSkillRenderCell or BaseClass(BaseCell)
function SpiritSkillRenderCell:__init(instance)

end

function SpiritSkillRenderCell:__delete()

end

function SpiritSkillRenderCell:OnFlush()
	if nil == self.data then
		return
	end
	local data = self.data
	local cur_select_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex() or 0
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}
	local cur_sprite_info = spirit_list[cur_select_sprite_index] or {}

	local skill_id = data.skill_id or 0

	local is_slot_open = false
	local is_show_add_icon = false
	local num = 0
	if cur_sprite_info.param then
		-- 当前槽位是否开启true 关闭false
		is_slot_open = (cur_sprite_info.param.jing_ling_skill_list[data.index].is_slot_open ~= 0)
		
		if not is_slot_open then
			if data.index > 0 then
				is_show_add_icon = (cur_sprite_info.param.jing_ling_skill_list[data.index - 1].is_slot_open ~= 0) and true or false
			else
				is_show_add_icon = true
			end
		end


		for i,v in pairs(cur_sprite_info.param.jing_ling_skill_list) do
			if v.is_slot_open ~= 0 then
				num = num + 1
			end
		end
	end
	-- self.node_list["ImgLock"]:SetActive(not is_slot_open and not is_show_add_icon)
	-- self.node_list["AddIcon"]:SetActive(is_show_add_icon)
	-- 去掉了加号开启

	self.node_list["Item"].button.interactable = true
	if num + 1 <= data.index then
		UI:SetGraphicGrey(self.node_list["ImgLock"], true)
	else
		UI:SetGraphicGrey(self.node_list["ImgLock"], false)
	end
	self.node_list["ImgLock"]:SetActive(not is_slot_open)

	if num == 0 then
		UI:SetButtonEnabled(self.node_list["ImgLock"], false)
		self.node_list["Item"].button.interactable = false
	end

	if skill_id == 0 then
		self.node_list["IcomImg"].image.enabled = false
		self.node_list["NameText"].text.text = ""
	end
	local skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	self.node_list["NameImg"].image.enabled = skill_id > 0

	if skill_id > 0 then
		local skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritIcon("skill_" .. skill_id)
		local bundle, asset = nil, nil
		if skill_cfg.skill_level == 1 then
			bundle, asset = ResPath.GetItemQualityCcCircleTagBg("blue")
		elseif skill_cfg.skill_level == 2 then
			bundle, asset = ResPath.GetItemQualityCcCircleTagBg("purple")
		elseif skill_cfg.skill_level == 3 then
			bundle, asset = ResPath.GetItemQualityCcCircleTagBg("orange")
		elseif skill_cfg.skill_level == 4 then
			bundle, asset = ResPath.GetItemQualityCcCircleTagBg("red")
		else
			bundle, asset = ResPath.GetItemQualityCcCircleTagBg("pink")
		end
		
		self.node_list["IcomImg"].image:LoadSprite(skill_icon_bundle, skill_icon_asset)
		self.node_list["NameImg"].image:LoadSprite(bundle, asset)
		self.node_list["NameText"].text.text = skill_cfg.skill_name
	end

	self.node_list["FlagImg"]:SetActive(data.can_move == 1)
end



------------------------------------------------------------------------------------------------------
--SpiritSkillStorageRenderCell

SpiritSkillStorageRenderCell = SpiritSkillStorageRenderCell or BaseClass(BaseCell)

function SpiritSkillStorageRenderCell:__init(instance)

end

function SpiritSkillStorageRenderCell:__delete()

end

function SpiritSkillStorageRenderCell:OnFlush()
	if nil == self.data then
		return
	end
	local data = self.data
	local skill_id = data.skill_id
	self.node_list["ImgLock"]:SetActive(false)
	-- 图标图片设置 
	if skill_id == 0 then
		self.node_list["IcomImg"].image.enabled = false
	end
	if skill_id > 0 then
		local skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritIcon("skill_" .. skill_id)
		self.node_list["IcomImg"].image:LoadSprite(skill_icon_bundle, skill_icon_asset)
	end
end
