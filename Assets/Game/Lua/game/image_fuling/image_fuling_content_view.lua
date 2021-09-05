require("game/image_fuling/image_fuling_window")

ImageFuLingContentView = ImageFuLingContentView or BaseClass(BaseRender)

local MOVE_TIME = 0.4
local MOVE_TIME = 0.5

function ImageFuLingContentView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftPanel"] , Vector3(-150 , -22 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(800 , -22 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["FightBigPowerLabel"] , Vector3(25 , -450 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnTip"] , Vector3(-30 , 100 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["CenterPanel"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function ImageFuLingContentView:__init(instance)
	if instance == nil then
		return
	end
	self.window_view = ImageFulingWindowView.New(ViewName.ImageFulingWindowView)
	self.cur_fuling_type = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT

	self.item_list = {}
	for i = 1, GameEnum.IMG_FULING_SLOT_COUNT do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item"..i])
		self.item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i]:SetInteractable(true)
		self.item_list[i]:ShowQuality(false)
		self.item_list[i]:SetCellLock(true)
		self.item_list[i].root_node.transform:SetLocalScale(0.8, 0.8, 0.8)
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"])

	self.cell_list = {}
	self.list_view_delegate = self.node_list["list_view"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.node_list["list_view"].scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	self.node_list["btn_uplevel"].button:AddClickListener(BindTool.Bind(self.OnOpenItemWindow, self))
	self.node_list["BtnTip"].button:AddClickListener(BindTool.Bind(self.OnOpenHelp, self))

	self.is_cell_active = false
	self.is_scroll_create = false
end

function ImageFuLingContentView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.window_view then
		self.window_view:DeleteMe()
		self.window_view = nil
	end
	self.fight_text = nil
	self.is_cell_active = false
	self:RemoveWindowDelayTime()
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function ImageFuLingContentView:RemoveWindowDelayTime()
	if self.window_delay_time then
		GlobalTimerQuest:CancelQuest(self.window_delay_time)
		self.window_delay_time = nil
	end
end

function ImageFuLingContentView:OnOpenItemWindow()
	self.window_view:SetCurIndex(self.cur_fuling_type)
	ViewManager.Instance:Open(ViewName.ImageFulingWindowView)
	self.window_view:OpenCallBack()
end

function ImageFuLingContentView:OnOpenHelp()
	local tips_id = 236
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ImageFuLingContentView:OnClickItem(img_index)
	local close_call_back = function() self.item_list[img_index]:SetHighLight(false) end

	local info = ImageFuLingData.Instance:GetImgFuLingData(self.cur_fuling_type)
	if info.img_id_list[img_index] <= 0 then
		close_call_back()
		SysMsgCtrl.Instance:ErrorRemind(Language.Advance.UnlockFuLing)
		return
	end
	TipsCtrl.Instance:OpenItem(self.item_list[img_index]:GetData(), nil, nil, close_call_back)
end

function ImageFuLingContentView:OpenCallBack()
	self:UIsMove()
	self:Flush()
end

function ImageFuLingContentView:CloseCallBack()
	self.cur_fuling_type = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT
	if self.node_list["list_view"] and self.node_list["list_view"].gameObject.activeInHierarchy then
		self.node_list["list_view"].scroller:JumpToDataIndex(self.cur_fuling_type)
	end
end

function ImageFuLingContentView:ItemDataChangeCallback()
	if self.node_list["list_view"] then
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ImageFuLingContentView:OnFlush(param_t)
	if self.node_list["list_view"] then
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:OnFlushAll()
end

function ImageFuLingContentView:GetNumberOfCells()
	return GameEnum.IMG_FULING_JINGJIE_TYPE_MAX
end

function ImageFuLingContentView:RefreshView(cell, data_index)
	local fuling_type_cell = self.cell_list[cell]
	if fuling_type_cell == nil then
		fuling_type_cell = ImageFuLingTypeCell.New(cell.gameObject, self)
		fuling_type_cell.root_node.toggle.group = self.node_list["list_view"].toggle_group
		self.cell_list[cell] = fuling_type_cell
	end

	local data_list = ImageFuLingData.Instance:GetFuLingTabInfoList()
	fuling_type_cell:SetData(data_list[data_index + 1])
	
	self.is_cell_active = true
end

function ImageFuLingContentView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if not self.is_scroll_create then
		if self.is_cell_active and self.node_list["list_view"] and self.node_list["list_view"].scroller.isActiveAndEnabled then
			self.node_list["list_view"].scroller:JumpToDataIndex(self.cur_fuling_type)
			self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
			self.is_scroll_create = true
		end
	end
end

function ImageFuLingContentView:SetCurSelectIndex(fuling_type, is_jump)
	if nil == fuling_type then
		return
	end

	self.cur_fuling_type = fuling_type
	self:OnFlushAll()

	if is_jump and self.is_cell_active and self.is_scroll_create and self.node_list["list_view"] and self.node_list["list_view"].scroller.isActiveAndEnabled then
		self.node_list["list_view"].scroller:JumpToDataIndex(fuling_type)
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ImageFuLingContentView:GetCurSelectIndex()
	return self.cur_fuling_type
end

function ImageFuLingContentView:OnFlushAll()
	local item_list = ImageFuLingData.Instance:GetCanConsumeStuff(self.cur_fuling_type)
	self.node_list["ImgRemind"]:SetActive(#item_list > 0)

	local asset, bundle = ResPath.ImgFuLingSkillIcon(self.cur_fuling_type)
	self.node_list["ImgSkill"].image:LoadSprite(asset, bundle)
	local auto_fit_size = true
	local asset, bundle = ResPath.ImgFuLingTypeRawImage(self.cur_fuling_type)
	self.node_list["raw_image"].raw_image:LoadSprite(asset, bundle, function()
		self.node_list["raw_image"]:SetActive(true)
		self.node_list["raw_image"].raw_image:SetNativeSize()
		end)
	local info = ImageFuLingData.Instance:GetImgFuLingData(self.cur_fuling_type)
	if nil == info then
		return
	end

	local skill_cfg = ImageFuLingData.Instance:GetImgFuLingSkillLevelCfg(self.cur_fuling_type, info.skill_level)
	local skill_desc = skill_cfg.description
	skill_desc = string.gsub(skill_desc, "%[param_a]", tonumber(skill_cfg.param_a))
	skill_desc = string.gsub(skill_desc, "%[param_b]", tonumber(skill_cfg.param_b))
	skill_desc = string.gsub(skill_desc, "%[param_c]", tonumber(skill_cfg.param_c / 1000))
	skill_desc = string.gsub(skill_desc, "%[param_d]", tonumber(skill_cfg.param_d / 1000))
	skill_desc = string.gsub(skill_desc, "%[param_e]", tonumber(skill_cfg.param_e))
	self.node_list["Txt"].text.text = skill_desc
	self.node_list["TxtSkillName"].text.text = skill_cfg.skill_name .. " Lv." .. info.skill_level

	local next_skill_cfg = ImageFuLingData.Instance:GetImgFuLingSkillLevelCfg(self.cur_fuling_type, info.skill_level + 1)
	if next_skill_cfg then
		local tag = info.skill_level <= 0 and Language.Advance.JiHuo or Language.Advance.ShengJi
		self.node_list["TxtActiveText"].text.text = string.format(Language.Advance.SkillActiveDesc, next_skill_cfg.img_count_limit, tag)
	else
		self.node_list["TxtActiveText"].text.text = Language.Advance.SkillMaxLevel
	end
	self.node_list["TxtSkill"].text.text = string.format(Language.FuLing.Level,info.level)

	local level_cfg = ImageFuLingData.Instance:GetImgFuLingLevelCfg(self.cur_fuling_type, info.level)
	local level_attr = CommonDataManager.GetAttributteByClass(level_cfg)

	self.node_list["TxtValue1"].text.text = level_cfg and level_attr.max_hp or 0
	self.node_list["TxtValue2"].text.text = level_cfg and level_attr.gong_ji or 0
	self.node_list["TxtValue3"].text.text = level_cfg and level_attr.fang_yu or 0
	self.node_list["TxtValue4"].text.text = level_cfg and level_attr.ming_zhong or 0
	self.node_list["TxtValue5"].text.text = level_cfg and level_attr.shan_bi or 0
	self.node_list["TxtValue6"].text.text = level_cfg and level_attr.bao_ji or 0
	self.node_list["TxtValue7"].text.text = level_cfg and level_attr.jian_ren or 0

	self.node_list["TxtValue15"].text.text = "+" .. (level_cfg and level_cfg.per_add / 100 or 0) .. "%"

	self.node_list["Txt2"].text.text = info.cur_exp .. "/" .. level_cfg.exp
	self.node_list["Slider"].slider.value = info.cur_exp / level_cfg.exp

	local next_level_cfg = ImageFuLingData.Instance:GetImgFuLingLevelCfg(self.cur_fuling_type, info.level + 1)
	for i = 1, 8 do
		self.node_list["ListUpAttr" .. i]:SetActive(nil ~= next_level_cfg)
	end
	-- self.node_list["BtnUpLevel"]:SetActive(nil ~= next_level_cfg)
	UI:SetButtonEnabled(self.node_list["btn_uplevel"],nil ~= next_level_cfg)
	self.node_list["TxtUp"].text.text = nil == next_level_cfg and Language.Common.YiManJi or Language.Common.UpGrade

	local next_level_attr = CommonDataManager.GetAttributteByClass(next_level_cfg)
	local dif_attr = CommonDataManager.LerpAttributeAttr(level_attr, next_level_attr)
	if nil ~= next_level_cfg then
		self.node_list["TxtValue8"].text.text = dif_attr.max_hp
		self.node_list["TxtValue9"].text.text = dif_attr.gong_ji
		self.node_list["TxtValue10"].text.text = dif_attr.fang_yu
		self.node_list["TxtValue11"].text.text = dif_attr.ming_zhong
		self.node_list["TxtValue12"].text.text = dif_attr.shan_bi
		self.node_list["TxtValue13"].text.text = dif_attr.bao_ji
		self.node_list["TxtValue14"].text.text = dif_attr.jian_ren

		local pre_add = level_cfg and level_cfg.per_add or 0
		self.node_list["TxtValue_up"].text.text = "+" .. (next_level_cfg.per_add - pre_add) / 100 .. "%"
	else
		self.node_list["Txt2"].text.text = Language.Common.YiManJi
 		self.node_list["Slider"].slider.value = 1
	end
	self.node_list["ListHP"]:SetActive((nil ~= level_cfg and level_cfg.maxhp > 0) or (nil ~= next_level_cfg and next_level_cfg.maxhp > 0))
	self.node_list["ListAttack"]:SetActive((nil ~= level_cfg and level_cfg.gongji > 0) or (nil ~= next_level_cfg and next_level_cfg.gongji > 0))
	self.node_list["ListDefence"]:SetActive((nil ~= level_cfg and level_cfg.fangyu > 0) or (nil ~= next_level_cfg and next_level_cfg.fangyu > 0))
	self.node_list["ListMingZhong"]:SetActive((nil ~= level_cfg and level_cfg.mingzhong > 0) or (nil ~= next_level_cfg and next_level_cfg.mingzhong > 0))
	self.node_list["ListShanBi"]:SetActive((nil ~= level_cfg and level_cfg.shanbi > 0) or (nil ~= next_level_cfg and next_level_cfg.shanbi > 0))
	self.node_list["ListBaoJi"]:SetActive((nil ~= level_cfg and level_cfg.baoji > 0) or (nil ~= next_level_cfg and next_level_cfg.baoji > 0))
	self.node_list["ListJianRen"]:SetActive((nil ~= level_cfg and level_cfg.jianren > 0) or (nil ~= next_level_cfg and next_level_cfg.jianren > 0))
	self.node_list["Txt3"].text.text = string.format(Language.FuLing.JinJieAttr, Language.Advance.FuLingTabName[self.cur_fuling_type])

	for i = 1, GameEnum.IMG_FULING_SLOT_COUNT do
		local img_id = info.img_id_list[i]
		if nil ~= img_id and img_id > 0 then
			self.item_list[i]:ShowQuality(true)
		else
			self.item_list[i]:ShowQuality(false)
			self.item_list[i]:SetData(nil)
			self.item_list[i]:SetCellLock(true)
		end

		local item_id = ImageFuLingData.Instance:GetSpecialImageActiveItemId(self.cur_fuling_type, img_id)
		if nil ~= item_id then
			self.item_list[i]:SetData({item_id = item_id, num = 1, is_bind = 0})
		end
	end

	local extra_cap = ImageFuLingData.Instance:GetFuLingExtraCapabilityByType(self.cur_fuling_type, info.level)
	local capability = ImageFuLingData.Instance:GetImgFuLingCapability(self.cur_fuling_type, info.level)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability + extra_cap
	end
end

-----------------------ImageFuLingTypeCell-----------------

ImageFuLingTypeCell = ImageFuLingTypeCell or BaseClass(BaseCell)
function ImageFuLingTypeCell:__init(instance, parent)
	self.parent = parent
	self.node_list["FuLingTypeCell"].toggle:AddClickListener(BindTool.Bind(self.OnItemClick, self))
end

function ImageFuLingTypeCell:__delete()
	self.parent = nil
end

function ImageFuLingTypeCell:OnFlush()
	if nil == self.data then
		return
	end
	self.root_node.toggle.isOn = self.parent:GetCurSelectIndex() == self.data

	local asset, bundle = ResPath.GetImgFuLingTypeIcon(self.data)
	self.node_list["ImgSkill"].image:LoadSprite(asset, bundle)

	self.node_list["Txt"].text.text = Language.Advance.FuLingTabName[self.data] .. Language.Advance.FuLing

	local item_list = ImageFuLingData.Instance:GetCanConsumeStuff(self.data)
	self.node_list["ImgRedPoint"]:SetActive(#item_list > 0)
end

function ImageFuLingTypeCell:OnItemClick()
	self.parent:SetCurSelectIndex(self.data)
end
