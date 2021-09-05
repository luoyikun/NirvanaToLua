ImageFuLingTalentView = ImageFuLingTalentView or BaseClass(BaseRender)
local MOVE_TIME = 0.5
local TALENTTYPE = 19
local IMG_TALENT_SLOT_COUNT = 7
local OPEN_LEVEL = 8
function ImageFuLingTalentView:UIsMove()
	local up_pos = self.node_list["Left_Panel"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["Left_Panel"] , Vector3(up_pos.x - 200, up_pos.y, up_pos.z) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnGuanZhu"] , Vector3(-60 , 120 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnHelp"] , Vector3(40 , 200, 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnPackage"] , Vector3(-60 , 20 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["FP_panel"] , Vector3(21 , -400 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right_Panel"] , Vector3(0, -100 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["Right_Panel"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function ImageFuLingTalentView:UISuxingMove()
	UITween.MoveShowPanel(self.node_list["SkillGridPanel"] , Vector3(-300 , -30 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BackpackButton"] , Vector3(-55 , 220 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnPanel"] , Vector3(0 , -400 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["RightTop"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function ImageFuLingTalentView:__init(instance)
	if instance == nil then
		return
	end

	self.cur_talent_type = TALENT_TYPE.TALENT_MOUNT
	self.now_talent_type = TALENT_TYPE.TALENT_MOUNT
	self.cell_list = {}
	self.list_view_delegate = self.node_list["List_View"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.node_list["List_View"].scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	self.equip_skill_cell_list = {}
	for i = 1, GameEnum.TALENT_SKILL_GRID_MAX_NUM do
		self.equip_skill_cell_list[i] = FuLingTalentEquipCell.New(self.node_list["EquipCell"..i], self)
	end

	self.flush_skill_cell_list = {}
	for i = 1, GameEnum.TALENT_CHOUJIANG_GRID_MAX_NUM do
		self.flush_skill_cell_list[i] = FuLingTalentSkillCell.New(self.node_list["SkillCell"..i])
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FP_panel"])
	self.node_list["TextGold1"].text.text = ImageFuLingData.Instance:GetTalentFlushCost(1)
	self.node_list["TextGold2"].text.text = ImageFuLingData.Instance:GetTalentFlushCost(9)
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnOpenHelp, self))
	self.node_list["BtnPackage"].toggle:AddClickListener(BindTool.Bind(self.OnOpenBag, self))
	self.node_list["BtnGuanZhu"].toggle:AddClickListener(BindTool.Bind(self.ClickFocus, self))
	self.node_list["BackpackButton"].toggle:AddClickListener(BindTool.Bind(self.ClickFocus, self))
	self.node_list["BtnOnce"].button:AddClickListener(BindTool.Bind(self.OnFlushOne, self))
	self.node_list["BtnAll"].button:AddClickListener(BindTool.Bind(self.OnFlushNine, self))
end

function ImageFuLingTalentView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.equip_skill_cell_list) do
		v:DeleteMe()
	end
	self.equip_skill_cell_list = {}

	for k,v in pairs(self.flush_skill_cell_list) do
		v:DeleteMe()
	end
	self.flush_skill_cell_list = {}
	self.fight_text = nil
end

function ImageFuLingTalentView:OpenCallBack()
	self:Flush()
end

function ImageFuLingTalentView:CloseCallBack()
	self.flush_one = false
	self.flush_nine = false
end

function ImageFuLingTalentView:ItemDataChangeCallback()
	self:OnFlushTalentEquipView()
	if self.node_list["List_View"] then
		self.node_list["List_View"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:OnFlushRedPoint()
end

function ImageFuLingTalentView:OnOpenTalent()
	self.node_list["TalentContent"]:SetActive(true)
	self.node_list["AwakenContent"]:SetActive(false)
	self:OnFlushTalentEquipView()
end

function ImageFuLingTalentView:OnOpenSuXing()
	self.node_list["TalentContent"]:SetActive(false)
	self.node_list["AwakenContent"]:SetActive(true)
	self:OnFlushChouJiangView()
end

function ImageFuLingTalentView:OnOpenHelp()
	local tips_id = 252
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ImageFuLingTalentView:OnOpenBag()
	ViewManager.Instance:Open(ViewName.TalentBagView, nil, "equip_talent", {})
end

function ImageFuLingTalentView:ClickFocus()
	ViewManager.Instance:Open(ViewName.WakeUpFocusView)
end

function ImageFuLingTalentView:OnFlushOne()
	if self.button_flag then
		return
	end
	if WakeUpFocusData.Instance:IsFocusCorrect() then
		TipsCtrl.Instance:ShowCommonTip(function ()
			self.flush_one = true
			ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH, 0)
			self.button_flag = false
			if self.delay_button_timer then
				GlobalTimerQuest:CancelQuest(self.delay_button_timer)
			end
			self.delay_button_timer = GlobalTimerQuest:AddDelayTimer(function ()
				if self.button_flag then
					self.button_flag = false
				end
			end,0.5)
		end, nil, Language.FocusTips.GetCorrect)
		return
	end
	self.flush_one = true
	self.button_flag = true
	ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH, 0)
end

function ImageFuLingTalentView:OnFlushNine()
	if self.button_flag then
		return
	end
	if WakeUpFocusData.Instance:IsFocusCorrect() then
		TipsCtrl.Instance:ShowCommonTip(function ()
			self.flush_nine = true
			ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH, 1)
			self.button_flag = false
			if self.delay_button_timer then
				GlobalTimerQuest:CancelQuest(self.delay_button_timer)
			end
			self.delay_button_timer = GlobalTimerQuest:AddDelayTimer(function ()
				if self.button_flag then
					self.button_flag = false
				end
			end,0.5)
		end, nil, Language.FocusTips.GetCorrect)
		return
	end

	self.flush_nine = true
	ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_REFRESH, 1)
	self.button_flag = true
	if self.delay_button_timer then
		GlobalTimerQuest:CancelQuest(self.delay_button_timer)
	end
	self.delay_button_timer = GlobalTimerQuest:AddDelayTimer(function ()
		if self.button_flag then
			self.button_flag = false
		end
	end,0.5)
end

function ImageFuLingTalentView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "anim" then
			if self.flush_one then
				self.flush_one = false
				self:RollSkillCell(0)
			elseif self.flush_nine then
				self.flush_nine = false
				self:RollSkillCell(1)
			end
		elseif k == "all" then
			if not self.is_rotation then
				self:OnFlushAll()
			end
		end
	end
end

function ImageFuLingTalentView:RollSkillCell(roll_type)
	self.is_rotation = true
	if roll_type == 1 then --1：所有，0：第一个
		for i = 1, GameEnum.TALENT_CHOUJIANG_GRID_MAX_NUM do
			self.node_list["SkillCell"..i].rect:SetLocalScale(1, 1, 1)
			local target_scale = Vector3(0, 1, 1)
			local target_scale2 = Vector3(1, 1, 1)
			self.tweener1 = self.node_list["SkillCell"..i].rect:DOScale(target_scale, 0.3)

			local func2 = function()
				self.tweener2 = self.node_list["SkillCell"..i].rect:DOScale(target_scale2, 0.3)
				self.is_rotation = false
				self:OnFlushAll()
			end
			self.tweener1:OnComplete(func2)

		end
	elseif roll_type == 0 then
		self.node_list["SkillCell"..1].rect:SetLocalScale(1, 1, 1)
		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)
		self.tweener1 = self.node_list["SkillCell"..1].rect:DOScale(target_scale, 0.3)

		local func2 = function()
			self.tweener2 =self.node_list["SkillCell"..1].rect:DOScale(target_scale2, 0.3)
			self.is_rotation = false
			self:OnFlushAll()
		end
		self.tweener1:OnComplete(func2)
	end
end

function ImageFuLingTalentView:SetDataFlag(flag)
	self.button_flag = flag
end

function ImageFuLingTalentView:GetNumberOfCells()
	return GameEnum.TALENT_TYPE_MAX
end

function ImageFuLingTalentView:RefreshView(cell, data_index)
	local talent_type_cell = self.cell_list[cell]
	if talent_type_cell == nil then
		talent_type_cell = ImageTalentTypeCell.New(cell.gameObject, self)
		talent_type_cell.root_node.toggle.group = self.node_list["List_View"].toggle_group
		self.cell_list[cell] = talent_type_cell
	end

	local data_list = ImageFuLingData.Instance:GetTalentTabInfoList()
	talent_type_cell:SetIndex(data_index)
	talent_type_cell:SetData(data_list[data_index + 1])
	
	self.is_cell_active = true
end

function ImageFuLingTalentView:FlushCell()
	for k, v in pairs(self.cell_list) do
		v:FlushHightLight()
	end
end

function ImageFuLingTalentView:ScrollerScrolledDelegate(go, param1, param2, param3)

	if not self.is_scroll_create then
		if self.is_cell_active and self.node_list["List_View"] and self.node_list["List_View"].scroller.isActiveAndEnabled then
			self.node_list["List_View"].scroller:JumpToDataIndex(self.cur_talent_type)
			self.node_list["List_View"].scroller:RefreshAndReloadActiveCellViews(true)
			self.is_scroll_create = true
		end
	end
end

function ImageFuLingTalentView:GetCurSelectIndex()
	return self.cur_talent_type
end

function ImageFuLingTalentView:GetNowSelectIndex()
	return self.now_talent_type
end

function ImageFuLingTalentView:SetCurSelectIndex(talent_type, is_jump)
	self.now_talent_type = talent_type or self.now_talent_type
	local info = {}
	local info_list = {}
	local num = 0
	for i = 0, IMG_TALENT_SLOT_COUNT do
		if i == TALENT_TYPE.TALENT_MOUNT then
			info = MountData.Instance:GetMountInfo()
		elseif i == TALENT_TYPE.TALENT_WING then
			info = WingData.Instance:GetWingInfo()
		elseif i == TALENT_TYPE.TALENT_HALO then	
			info = HaloData.Instance:GetHaloInfo()
		elseif i == TALENT_TYPE.TALENT_FIGHTMOUNT then	
			info = FightMountData.Instance:GetFightMountInfo()
		elseif i == TALENT_TYPE.TALENT_SHENGGONG then
			info = FashionData.Instance:GetFashionInfo()
		elseif i == TALENT_TYPE.TALENT_SHENYI then	
			info = FashionData.Instance:GetWuQiInfo()
		elseif i == TALENT_TYPE.TALENT_FOOTPRINT then	
			info = FootData.Instance:GetFootInfo()
		elseif i == TALENT_TYPE.TALENT_FABAO then	
			info = FaBaoData.Instance:GetFaBaoInfo()
		end
		info_list[i] = next(info) and info.grade > OPEN_LEVEL or false
	end
	if nil == talent_type then
		if info_list[self.cur_talent_type] then
			talent_type = self.cur_talent_type
		else
			for k, v in pairs(info_list) do
				if v == true then
					talent_type = k
					self.now_talent_type = k
					break
				end
			end
		end
	else
		if not info_list[talent_type] then
			if info_list[self.cur_talent_type] then
				talent_type = self.cur_talent_type
			else
				for k, v in pairs(info_list) do
					if v == true then
						num = num + 1
						talent_type = k
						break
					end
				end
				if num == 0 then
					talent_type = self.cur_talent_type
				end
			end
		end
	end

	self.cur_talent_type = talent_type or self.cur_talent_type
	self:OnFlushTalentEquipView()
	if is_jump and self.is_cell_active and self.is_scroll_create and self.node_list["List_View"] and self.node_list["List_View"].scroller.isActiveAndEnabled then
		self.node_list["List_View"].scroller:JumpToDataIndex(self.cur_talent_type)
		self.node_list["List_View"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushCell()
end

function ImageFuLingTalentView:OnFlushAll()
	self:OnFlushChouJiangView()
	self:OnFlushTalentEquipView()

	if self.node_list["List_View"] and self.node_list["List_View"].scroller.isActiveAndEnabled then
		self.node_list["List_View"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	self:OnFlushRedPoint()
end

function ImageFuLingTalentView:OnFlushRedPoint()
	self.node_list["FlushOneRed"]:SetActive(ImageFuLingData.Instance:GetFreeChouJiangTimes() > 0)
end

function ImageFuLingTalentView:OnFlushChouJiangView()
	local choujiang_info = ImageFuLingData.Instance:GetTalentChoujiangPageInfo()
	if nil == choujiang_info then
		return
	end

	for i = 1, GameEnum.TALENT_CHOUJIANG_GRID_MAX_NUM do
		local data = choujiang_info[i]
		if self.flush_skill_cell_list[i] then
			self.flush_skill_cell_list[i]:SetData(data)
		end
	end

	local stage_cfg = ImageFuLingData.Instance:GetTalentStageConfigByTimes(ImageFuLingData.Instance:GetCurChouJiangTimes())
	self.node_list["TextProb"].text.text = nil ~= stage_cfg and stage_cfg.dess or ""
	
	local max_stage_cfg = ImageFuLingData.Instance:GetTalentChouJiangMaxtStageConfig()
	local cur_count = ImageFuLingData.Instance:GetCurChouJiangTimes()
	self.node_list["TextLucky"].text.text = string.format(Language.ImageFuLing.LuckyValue, ToColorStr(cur_count, TEXT_COLOR.GREEN_4))
	self.node_list["ProgressBG"].slider.value = cur_count / max_stage_cfg.min_count

	local free_count = ImageFuLingData.Instance:GetFreeChouJiangTimes()
	self.node_list["FlushOneCost"]:SetActive(free_count <= 0)
	self.node_list["FreeTimeText"]:SetActive(free_count > 0)
	self.node_list["FreeTimeText"].text.text = string.format(Language.ImageFuLing.Free_Times, free_count)
end

function ImageFuLingTalentView:OnFlushTalentEquipView()
	local talent_info = ImageFuLingData.Instance:GetTalentAllInfo()
	if nil == next(talent_info) then
		return
	end

	for k, v in pairs(self.equip_skill_cell_list) do
		local data = talent_info[self.cur_talent_type][k - 1]
		v:SetIndex(k - 1)
		v:SetData(data)
	end

	self.node_list["PackageRed"]:SetActive(false)

	local capability = ImageFuLingData.Instance:GetTalentCapability(self.cur_talent_type)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end

	local talent_type_cfg = ImageFuLingData.Instance:GetTalentConfig(self.cur_talent_type)
	local type_skill_cfg = ImageFuLingData.Instance:GetTalentTypeFirstConfigBySkillType(talent_type_cfg.skill_type)
	local item_cfg = ItemData.Instance:GetItemConfig(type_skill_cfg.book_id)
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetAsset(bundle, asset)

	local top_talent_info = talent_info[self.cur_talent_type][GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1]
	if top_talent_info and 1 == top_talent_info.is_open then
		if 0 ~= top_talent_info.skill_id then
			local skill_cfg = ImageFuLingData.Instance:GetTalentSkillConfig(top_talent_info.skill_id, top_talent_info.skill_star)
			local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
			local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
			self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetAsset(bundle, asset)
			self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetIconGrayVisible(false)
			self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:ShowQuality()
		else
			self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetIconGrayVisible(true)
			self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:ShowQuality()
		end
	else
		self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetIconGrayVisible(true)
		self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetChildSiblingIndex()
		self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:ShowQuality()
	end
end


-----------------------ImageTalentTypeCell-----------------

ImageTalentTypeCell = ImageTalentTypeCell or BaseClass(BaseCell)
function ImageTalentTypeCell:__init(instance, parent)
	self.parent = parent
	self.info_list = {}
	
	self.node_list["FuLingTypeCell"].toggle:AddClickListener(BindTool.Bind(self.OnItemClick, self))
end

function ImageTalentTypeCell:__delete()
	self.parent = nil
	self.info_list = nil
end

function ImageTalentTypeCell:OnFlush()
	self:GetInfoList()
	if nil == self.data then
		return
	end
	self.parent:FlushCell()
	self.node_list["ImgSkill"].image:LoadSprite(ResPath.GetImgFuLingTypeIcon(self.data))
	UI:SetGraphicGrey(self.node_list["ImgSkill"], not self.info_list[self.data])
	self.node_list["Txt"].text.text = Language.Advance.FuLingTabName[self.data] .. Language.Advance.Talent
	local is_show_red_point = ImageFuLingData.Instance:GetIsShowTalentRedPoint(self.data)
	self.node_list["ImgRedPoint"]:SetActive(is_show_red_point)
end

function ImageTalentTypeCell:OnItemClick()
	self:GetInfoList()
	if not self.info_list[self.data] then
		TipsCtrl.Instance:ShowSystemMsg(Language.Advance.TalentTabName[self.data]..Language.Advance.WuJieOpen)
	end
	self.parent:SetCurSelectIndex(self.data)
end

function ImageTalentTypeCell:GetInfoList()
	local info = {}
	for i = 0, IMG_TALENT_SLOT_COUNT do
		if i == TALENT_TYPE.TALENT_MOUNT then
			info = MountData.Instance:GetMountInfo()
		elseif i == TALENT_TYPE.TALENT_WING then
			info = WingData.Instance:GetWingInfo()
		elseif i == TALENT_TYPE.TALENT_HALO then	
			info = HaloData.Instance:GetHaloInfo()
		elseif i == TALENT_TYPE.TALENT_FIGHTMOUNT then	
			info = FightMountData.Instance:GetFightMountInfo()
		elseif i == TALENT_TYPE.TALENT_SHENGGONG then	
			info = FashionData.Instance:GetFashionInfo()
		elseif i == TALENT_TYPE.TALENT_SHENYI then	
			info = FashionData.Instance:GetWuQiInfo()
		elseif i == TALENT_TYPE.TALENT_FOOTPRINT then	
			info = FootData.Instance:GetFootInfo()
		elseif i == TALENT_TYPE.TALENT_FABAO then	
			info = FaBaoData.Instance:GetFaBaoInfo()
		end
		self.info_list[i] = next(info) and info.grade > OPEN_LEVEL or false
	end
end

function ImageTalentTypeCell:FlushHightLight()
	self.node_list["HightLight"]:SetActive(self.parent:GetCurSelectIndex() == self.data)
end


-----------------------------------------------------------------------------------------------------------------------
--FuLingTalentEquipCell
-----------------------------------------------------------------------------------------------------------------------

FuLingTalentEquipCell = FuLingTalentEquipCell or BaseClass(BaseCell)

function FuLingTalentEquipCell:__init(instance, parent)
	self.parent = parent
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickItem, self))
	self.item_cell:SetInteractable(true)
end

function FuLingTalentEquipCell:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function FuLingTalentEquipCell:SetIndex(index)
	self.seq = index
end

function FuLingTalentEquipCell:OnFlush()
	if nil == self.data then
		return
	end
	if 1 == self.data.is_open then
		self.item_cell:SetCellLock(false)
		if 0 ~= self.data.skill_id then
			local skill_cfg = ImageFuLingData.Instance:GetTalentSkillConfig(self.data.skill_id, self.data.skill_star)
			local item_num = ItemData.Instance:GetItemNumInBagById(skill_cfg.need_item_id)
			self.node_list["BtnImprove"]:SetActive(item_num >= skill_cfg.need_item_count)
			self.node_list["ImgAdd"]:SetActive(false)
			self.item_cell:ShowQuality(true)
			self.item_cell:SetData({item_id = skill_cfg.book_id})
			self.item_cell:SetShowStar(skill_cfg.skill_star)
		else
			local select_info = {talent_type = self.parent:GetCurSelectIndex(), grid_index = self.seq}
			local item_list = ImageFuLingData.Instance:GetBagTalentBookItems(select_info)
			self.node_list["BtnImprove"]:SetActive(#item_list > 0)
			self.node_list["ImgAdd"]:SetActive(true)
			self.item_cell:SetData({})
			self.item_cell:ShowQuality(false)
		end
	else
		self.node_list["BtnImprove"]:SetActive(false)
		self.node_list["ImgAdd"]:SetActive(false)
		self.item_cell:SetCellLock(true)
		self.item_cell:SetData({})
		self.item_cell:ShowQuality(false)
	end
end

function FuLingTalentEquipCell:SetAsset(bundle, asset)
	self.item_cell:SetAsset(bundle, asset)
end

function FuLingTalentEquipCell:SetIconGrayVisible(bundle, asset)
	self.item_cell:SetIconGrayVisible(bundle, asset)
end

function FuLingTalentEquipCell:SetChildSiblingIndex()
	self.item_cell:SetChildSiblingIndex("CellLock", 7)
end

function FuLingTalentEquipCell:ShowQuality()
	self.item_cell:ShowQuality(false)
end

function FuLingTalentEquipCell:OnClickItem()
	if nil == self.data then
		return
	end

	self.item_cell:SetToggle(false)
	local select_info = { talent_type = self.parent:GetCurSelectIndex(), grid_index = self.seq}
	if 1 ~= self.data.is_open then
		if select_info.grid_index == GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1 then
			ImageFuLingCtrl.Instance:OpenTalentSkillUpgradeView(select_info)
		else
			local str = ImageFuLingData.Instance:GetTalentGridActiveCondition(self.parent:GetCurSelectIndex(), self.seq)
			if nil ~= str then
				SysMsgCtrl.Instance:ErrorRemind(str)
			end
		end
		return
	end

	if 0 ~= self.data.skill_id then
		if select_info.grid_index == GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1 then
			ImageFuLingCtrl.Instance:OpenTalentSkillUpgradeView(select_info)
		else
			ImageFuLingCtrl.Instance:OpenTalentUpgradeView(select_info)
		end
	else
		if select_info.grid_index == GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1 and #ImageFuLingData.Instance:GetBagTalentBookItems(select_info) <= 0 then
			ImageFuLingCtrl.Instance:OpenTalentSkillUpgradeView(select_info)
		else
			ViewManager.Instance:Open(ViewName.TalentBagView, nil, "equip_talent", select_info)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------
--FuLingTalentSkillCell
-----------------------------------------------------------------------------------------------------------------------

FuLingTalentSkillCell = FuLingTalentSkillCell or BaseClass(BaseCell)

function FuLingTalentSkillCell:LoadCallBack()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.node_list["BtnSkill"].button:AddClickListener(BindTool.Bind(self.OnClickBtn, self))
end

function FuLingTalentSkillCell:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function FuLingTalentSkillCell:OnFlush()
	if nil == self.data then
		return
	end
	local skill_cfg = ImageFuLingData.Instance:GetTalentSkillConfig(self.data.skill_id, 0)
	if nil ~= skill_cfg then
		self.item_cell:ShowQuality(true)
		self.item_cell:SetData({item_id = skill_cfg.book_id})
		self.node_list["Effect"]:SetActive(skill_cfg.skill_type > TALENTTYPE)
		local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
		if item_cfg then
			self.node_list["TextName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color or 0])
		end
	else
		self.item_cell:ShowQuality(false)
		self.item_cell:SetData(nil)
		self.node_list["TextName"].text.text = ""
		self.node_list["Effect"]:SetActive(false)
	end

	local is_focus = WakeUpFocusData.Instance:IsFocus(self.data.skill_id)
	self.node_list["EffectGuanZhu"]:SetActive(is_focus)
end
-- end

function FuLingTalentSkillCell:OnClickBtn()
	if nil == self.data then
		return
	end
	ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_AWAKE, self.data.seq)
end

