-- 仙宠-图鉴-SpiritLingPo
SpiritLingPoView = SpiritLingPoView or BaseClass(BaseRender)

function SpiritLingPoView__init(Instance)
	
end

function SpiritLingPoView:LoadCallBack()
	self.cur_index = 1
	self.cell_list = {}
	self.attr_list = {}
	for i = 1, 3 do
		self.attr_list[i] = self.node_list["AttrTxt" .. i]
	 end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])

	self.node_list["AdvanceBtn"].button:AddClickListener(BindTool.Bind(self.OnClickAdvance, self))
	self.node_list["BtnAttr"].button:AddClickListener(BindTool.Bind(self.OnclickArrTip, self))

	self.list_view = self.node_list["list_view"]
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["NumTxt"])
end

function SpiritLingPoView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self:CancelSliderQuest()
	self.cur_index = 1
	self.fight_text = nil
end

function SpiritLingPoView:OnClickAdvance()
	local item_info = SpiritData.Instance:GetLingAdvanceItemInfo(self.cur_lingpo_list[self.cur_index].type)
	if item_info.my_count < item_info.need_num then
		TipsCtrl.Instance:ShowItemGetWayView(item_info.data.item_id)
	else
		local t = SpiritData.Instance:GetLingPoCurCfg(self.cur_lingpo_list[self.cur_index].type)
		if SpiritData.Instance:IsBetterSprite(t.stuff_id) then
			local ok_fun = function ()
				SpiritData.Instance:SetCurAdvanceLingPoType(self.cur_lingpo_list[self.cur_index].type)
				SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVELCARD, self.cur_lingpo_list[self.cur_index].type)
			end
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, Language.JingLing.LingPoBetterTips)
			return
		end
		SpiritData.Instance:SetCurAdvanceLingPoType(self.cur_lingpo_list[self.cur_index].type)
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVELCARD, self.cur_lingpo_list[self.cur_index].type)
	end
end

function SpiritLingPoView:OnclickArrTip()
	TipsCtrl.Instance:ShowSpiritPlusView(self.cur_lingpo_list)
end

function SpiritLingPoView:SetCurIndex(index)
	if index ~= self.cur_index then
		self.cur_index = index
		self:Flush("flush_modle", {[1] = true})
	end
end

function SpiritLingPoView:GetCurIndex()
	return self.cur_index
end

--获得排序后的列表
function SpiritLingPoView:GetCurLingpoList()
	return self.cur_lingpo_list
end

--判空
function SpiritLingPoView:CheckIsNil()
	local spirit_data = SpiritData.Instance
	local info = spirit_data:GetLingPoInfo(self.cur_lingpo_list[self.cur_index].type)
	if not info or not next(info) then return end

	local t = spirit_data:GetLingPoCurCfg(self.cur_lingpo_list[self.cur_index].type, info.level)
	if not t.cfg or not next(t.cfg) then return end

	return info, t
end

function SpiritLingPoView:ShowIndexToGetSortList()
	self.cur_lingpo_list = SpiritData.Instance:GetLingPoSortList()
	self:SetCurIndex(1)
	self.list_view.scroller:JumpToDataIndex(0)
end

function SpiritLingPoView:OnFlush(...)
	self:FlushAttr()
	self:FlushBag()
	self.list_view.scroller:RefreshActiveCellViews()

	local param = {...}
	if param[1]["flush_modle"] then
		self:FlushModel()
	end
end

function SpiritLingPoView:AutoSelectCell()
	for i,v in ipairs(self.cur_lingpo_list) do
		local item_info = SpiritData.Instance:GetLingAdvanceItemInfo(v.type)
		if item_info then
			local enough = item_info.my_count >= item_info.need_num
			if enough then
				self:SetCurIndex(i)
				-- self.list_view.scroller:JumpToDataIndex(i - 1)
				local scrollerOffset = 0
				local cellOffset = 0
				local useSpacing = false
				local scrollerTweenType = self.list_view.scroller.snapTweenType
				local scrollerTweenTime = 1
				local scroll_complete = nil
				self.list_view.scroller:JumpToDataIndex(
					i - 1, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
				break
			end
		end
	end
end

--刷新属性
function SpiritLingPoView:FlushAttr()
	local info, t = self:CheckIsNil()
	if not info or not t then return end

	local spirit_data = SpiritData.Instance
	self:FlushSlider(false)

	local is_over_zeor = info.level > 0
	local next_info = spirit_data:GetLingPoCfg(self.cur_lingpo_list[self.cur_index].type, info.level + 1)
	if info.level == 0 then
		next_info = spirit_data:GetLingPoCfg(self.cur_lingpo_list[self.cur_index].type, 1)
	end

	for i = 1, 3 do
		local des = string.format(Language.SpiritAttr[i], t.cfg["attr_value" .. i])
		local des1 = string.format(Language.SpiritAttr[i], 0)
		self.attr_list[i].text.text = des1
		self.node_list["NextAttrTxt" .. i].text.text = 0
		
		self.attr_list[i].text.text = is_over_zeor and des or des1

		if next_info then
			if info.level == 0 then
				self.node_list["NextAttrTxt" .. i].text.text = next_info["attr_value" .. i]
			else
				self.node_list["NextAttrTxt" .. i].text.text = next_info["attr_value" .. i] - t.cfg["attr_value" .. i]
			end
			
		end
		
	end

	local total_zhanli = 0
	for k,v in pairs(self.cur_lingpo_list) do
		total_zhanli = total_zhanli + spirit_data:GetLingPoZhanLi(v.type, spirit_data:GetLingPoInfo(v.type).level)
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = total_zhanli
	end
	local max_level = spirit_data:GetLingPoMaxLevel()
	UI:SetButtonEnabled(self.node_list["AdvanceBtn"], info.level < max_level)
	for i = 1, 3 do
		self.node_list["ArrowImg" .. i]:SetActive(info.level < max_level)
		self.node_list["NextAttr" .. i]:SetActive(info.level < max_level)
	end

	local title_info = spirit_data:GetCurTitleInfo()
	self.node_list["BtnAttr"].image:LoadSprite(ResPath.GetTitleIcon(title_info.title_id))
end

--刷新物品
function SpiritLingPoView:FlushBag()
	local spirit_data = SpiritData.Instance
	local item_info = spirit_data:GetLingAdvanceItemInfo(self.cur_lingpo_list[self.cur_index].type)
	local color = spirit_data:GetLingPoCountColor(self.cur_lingpo_list[self.cur_index].type)
	if not next(item_info) then return end
	local has_item = item_info.my_count > 0
	self.item_cell:SetData(item_info.data)
	self.item_cell:SetItemNumVisible(has_item)
	self.item_cell:SetNum(item_info.my_count)
	self.item_cell:SetIconGrayScale(not has_item)
	self.item_cell:ShowQuality(has_item)
end

--刷新模型
function SpiritLingPoView:FlushModel()
	local spirit_data = SpiritData.Instance
	local ling_po_show_id = spirit_data:GetLingPoSpiritId(self.cur_lingpo_list[self.cur_index].type)
	if ling_po_show_id == 0 then return end

	local spirit_cfg = spirit_data:GetSpiritResIdByItemId(ling_po_show_id)
	if spirit_cfg == nil then return end

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

	local item_cfg = ItemData.Instance:GetItemConfig(ling_po_show_id)
	if not item_cfg then return end
	local name_str ="<color=%s>" .. spirit_cfg.name .. "</color>"
	self.node_list["ZhoudingTxt"].text.text = string.format(name_str, SOUL_NAME_COLOR[item_cfg.color])
end

--刷新滑动条
function SpiritLingPoView:FlushSlider(is_paly_anim)
	local info, t = self:CheckIsNil()
	if not info and not t then return end
	self.node_list["TextLevel"].text.text = string.format(Language.EquipShen.LingPoLevel, info.level)

	local spirit_data = SpiritData.Instance
	if not is_paly_anim then
		local max_level = spirit_data:GetLingPoMaxLevel()
		if info.level < max_level then
			self.node_list["SliderTxt"].text.text = info.exp.."/"..t.exp
			self.node_list["ProgressBarTxt"].slider.value = info.exp/t.exp
		else
			self.node_list["SliderTxt"].text.text = Language.EquipShen.DJYM
			self.node_list["ProgressBarTxt"].slider.value = 1
		end
		return
	end

	self.node_list["ProgressBarTxt"].slider.value = info.exp/t.exp
	local time = spirit_data:CheckLingpoAnimTime(info.exp, t.exp)
	self:SliderQuest(time + 0.1)
end

function SpiritLingPoView:CancelSliderQuest()
	if self.timer_quest then
	   GlobalTimerQuest:CancelQuest(self.timer_quest)
	   self.timer_quest = nil
	end
end

--客户端表现进度条动画
function SpiritLingPoView:SliderQuest(time)
	self:CancelSliderQuest()
	local info, t = self:CheckIsNil()
	if not info and not t then return end

	local spirit_data = SpiritData.Instance
	local fix_time = time
	self.timer = 0
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer + UnityEngine.Time.deltaTime
		if self.timer < fix_time - 0.1 then
			local pricent = self.timer/(fix_time - 0.1)
			self.node_list["ProgressBarTxt"].slider.value = pricent
			self.node_list["SliderTxt"].text.text = math.ceil(pricent * t.exp).."/".. t.exp

		end

		if self.timer >= fix_time then
			local max_level = spirit_data:GetLingPoMaxLevel()
			if info.level < max_level then
				self:FlushSlider(false)
				self:CancelSliderQuest()
			end
		end
	end, 0)
end

function SpiritLingPoView:OnClose()
	self:CancelSliderQuest()
end

function SpiritLingPoView:GetNumberOfCells()
	return SpiritData.Instance:GetLingPoCfgCount()
end

function SpiritLingPoView:RefreshView(cell, data_index)
	--灵魄类型从0起
	data_index = data_index + 1
	local ling_po_cell = self.cell_list[cell]
	if ling_po_cell == nil then
		ling_po_cell = SpiritLingPoCell.New(cell.gameObject)
		ling_po_cell.parent = self
		self.cell_list[cell] = ling_po_cell
	end
	ling_po_cell:SetIndex(data_index)
	ling_po_cell:Flush()
end

function SpiritLingPoView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local is_lingpo_id = SpiritData.Instance:CheckIsLingpoItem(item_id)
	if not is_lingpo_id then return end

	local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
	local flush_modle = my_count == 0
	local item_info = SpiritData.Instance:GetLingAdvanceItemInfo(self.cur_lingpo_list[self.cur_index].type)
	if item_info and item_info.my_count < item_info.need_num then
		self:AutoSelectCell()
	end
	if flush_modle then
		self:Flush("flush_modle", {[1] = true})
	else
		self:Flush()
	end
end

function SpiritLingPoView:UITween()
	UITween.MoveShowPanel(self.node_list["BtnAttr"], Vector3(-30, 279, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BottomPanel"], Vector3(237, 2, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["ListBG"], Vector3(-1300, 0, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["NameNode"], true, 0.5, DG.Tweening.Ease.InExpo)
	--UITween.AlpahShowPanel(self.node_list["TaiZi"], true, 0.5, DG.Tweening.Ease.InExpo)
end

-----------------------SpiritLingPoCell-----------------------------------------------------------------

SpiritLingPoCell = SpiritLingPoCell or BaseClass(BaseCell)
function SpiritLingPoCell:__init()
	self.node_list["SpiritLingPoCell"].button:AddClickListener(BindTool.Bind(self.OnItemClick, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickBlock, self, self.item_cell))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["NumberTxt"], "FightPower3")
end

function SpiritLingPoCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.parent = nil
	self.fight_text = nil
end

function SpiritLingPoCell:OnFlush()
	if self.parent:GetCurLingpoList() and self.index then
		self.lingpo_type = self.parent:GetCurLingpoList()[self.index].type
		self.node_list["RedPointImg"]:SetActive(SpiritData.Instance:CheckLingpoCellRedPoint(self.lingpo_type))
	end
	self:FlushInfo()
	self:FlushLingPoItem()
end

function SpiritLingPoCell:OnClickBlock(cell)
	cell:SetHighLight(false)
end

function SpiritLingPoCell:FlushInfo()
	local spirit_data = SpiritData.Instance
	local info = spirit_data:GetLingPoInfo(self.lingpo_type)
	if not info or not next(info) then return end
	local item_info = spirit_data:GetLingAdvanceItemInfo(self.lingpo_type)

	self.node_list["LevelTxt"].text.text = string.format("Lv.%s", info.level)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = spirit_data:GetLingPoZhanLi(self.lingpo_type, info.level)
	end
	self.item_cell:SetData(item_info.data)
	self.item_cell:SetItemCellGrade(true, info.level)
	local cur_index = self.parent:GetCurIndex() or 0
	self.node_list["HL"]:SetActive(cur_index == self.index)
end

--刷新仙宠名称、品质
function SpiritLingPoCell:FlushLingPoItem()
	local spirit_data = SpiritData.Instance
	local ling_po_show_id = 0
	if self.lingpo_type then
		ling_po_show_id = spirit_data:GetLingPoSpiritId(self.lingpo_type)
	end
	if ling_po_show_id == 0 then return end

	local item_cfg = ItemData.Instance:GetItemConfig(ling_po_show_id)
	if not item_cfg or not next(item_cfg) then return end
	
	self.node_list["QualityImg"].image:LoadSprite(ResPath.GetItemQualityTagBg(Common_Five_Rank_Color[item_cfg.color]))
	self.node_list["QualityTxt"].text.text = Language.QualityAttr[Common_Five_Rank_Color[item_cfg.color]]

	local spirit_cfg = spirit_data:GetSpiritResIdByItemId(ling_po_show_id)
	if spirit_cfg == nil then return end
	
	local name_str ="<color=%s>" .. spirit_cfg.name .. "</color>"
	self.node_list["NameTxt"].text.text = string.format(name_str, SOUL_NAME_COLOR[item_cfg.color])
end

function SpiritLingPoCell:OnItemClick()
	self.parent:SetCurIndex(self.index)
end