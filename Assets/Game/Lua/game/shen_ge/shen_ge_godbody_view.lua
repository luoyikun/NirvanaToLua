ShenGeGodBodyView = ShenGeGodBodyView or BaseClass(BaseRender)
local EFFECT_CD = 1
local MOVE_TIME = 0.5
function ShenGeGodBodyView:UIsMove()
	
	UITween.MoveShowPanel(self.node_list["MiddleContent"] , Vector3(0 , -100 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleUp"] , Vector3(0 , 150 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right1"] , Vector3(550 , 0 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right2"] , Vector3(0 , 150 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["LeftContent"] , Vector3(-210 , 0 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["MiddleContent"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["MiddleContent"] ,Vector3(0.7 , 0.7 , 0.7 ) , MOVE_TIME )

end
function ShenGeGodBodyView:__init(instance)
	self:SetNotifyDataChangeCallBack()
	self.can_send = true
	self.list_index = 0
	self.point_index = 1
	self.effect_cd = 0
	self:InitScroller()

	self.toggle_value_list = {}
	for i = 1, 3 do
		self.node_list["Toggle" .. i].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickToggle, self, i))
		self.toggle_value_list[i] = 0
	end

	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self.node_list["SutffCell"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"])

	self.point_item_list = {}
	for i = 0, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM-1 do
		local obj = self.node_list["PointList"].transform:GetChild(i).gameObject
		local point_item = PointCell.New(obj)
		point_item:SetIndex(i+1)
		point_item:SetClickCallBack(BindTool.Bind(self.ClickPointCallBack, self))
		table.insert(self.point_item_list, point_item)
	end
	self.node_list["BtnLevelUp"].button:AddClickListener(BindTool.Bind(self.OnClickXiLian, self))
	self.node_list["AutoBuyToggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.AutoBuyChange, self))
	self.node_list["BtnHeip"].button:AddClickListener(BindTool.Bind(self.OnClickTips, self))
	self.is_auto_buy_stone = 0
	self:ResetToggle("first_flush")

	ShenGeData.Instance:SetShenGeStoneNum()
	RemindManager.Instance:Fire(RemindName.ShenGe_Godbody)
end

function ShenGeGodBodyView:CloseCallBack()
	ShenGeData.Instance:SetShenGeStoneNum()
end

function ShenGeGodBodyView:OpenCallBack()

end

function ShenGeGodBodyView:__delete()
	self.fight_text = nil
	self:RemoveNotifyDataChangeCallBack()
	self.list_index = nil
	self.point_index = nil
	if self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for _, v in ipairs(self.point_item_list) do
		v:DeleteMe()
	end
	self.point_item_list = {}
	if nil ~= self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end
end

function ShenGeGodBodyView:MainRoleLevelChange()
	
end

function ShenGeGodBodyView:InitScroller()
	self.cell_list = {}
	self.data = ShenGeData.Instance:GetShenquListData()
	local delegate = self.node_list["ListView"].list_simple_delegate

	self.show_num = ShenGeData.Instance:GetShenquShowCount()
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		-- return ShenGeData.Instance:GetShenquCount()
		return self.show_num
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  ShenquItem.New(cell.gameObject,self)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		end
		local cell_data = self.data[data_index]
		target_cell:SetData(cell_data)
		target_cell:SetCellIndex(data_index - 1)
		target_cell:SetClickCallBack(BindTool.Bind(self.SelectShenquCallBack, self, cell_data.shenqu_id))
		target_cell:SetToggle(cell_data.shenqu_id == self.list_index)
		target_cell:FlushHl()
	end
end

function ShenGeGodBodyView:ReleaseCallBack()
	if self.effect_cd then
		self.effect_cd = nil
	end

	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ShenGeGodBodyView:OnFlush(param)
	for k,v in pairs(param) do
		if k.shenqu_info ~= nil then 
			self.can_send = true
		end 	
	end
	
	self.show_num = ShenGeData.Instance:GetShenquShowCount()
	self:ResetToggle("Flush")
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushRightContent()
	self:FlushPointList()
	self:FlushEffect()
end


function ShenGeGodBodyView:FlushPointList()
	for k, v in ipairs(self.point_item_list) do
		if k == self.point_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:Flush()
	end
end

function ShenGeGodBodyView:FlushRightContent()
	local cfg = ShenGeData.Instance:GetShenquCfgById(self.list_index)
	if nil == cfg then return end

	if self.stuff_cell ~= nil then
		self.stuff_cell:SetData({item_id = cfg.stuff_id})
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = 0
	end
	local xilian_count = -1
	for i = 1, 3 do
		if self.toggle_value_list[i] > 0 then
			xilian_count = xilian_count + 1
		end
	end
	xilian_count = xilian_count < 0 and 0 or xilian_count
	xilian_count = cfg["stuff_num_" .. xilian_count]
	
	local item_amount_val = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	local item_amount_str = ""
	self.node_list["TxtStuff"].text.text = string.format("%s / %s", item_amount_val, xilian_count)
	if item_amount_val == 0 then
		item_amount_str = ToColorStr(item_amount_val,TEXT_COLOR.RED_4)
	else
		item_amount_str = ToColorStr(item_amount_val,TEXT_COLOR.GREEN_4)
	end
	self.node_list["TxtStuff"].text.text = string.format("%s / %s", item_amount_str, xilian_count)


	local cur_info = ShenGeData.Instance:GetOnePointInfo(self.list_index, self.point_index)
	if nil == cur_info or not next(cur_info) then return end
	local ready_count = 0
	for i = 1, 3 do
		if cur_info[i].attr_point >= 0 then
			if cur_info[i].attr_point + 1 == self.point_index then
				ready_count = ready_count + 1
			end
			local point_cfg = ShenGeData.Instance:GetShenquXiLianCfg(self.list_index, cur_info[i].attr_point)
			self.node_list["TxtValue" .. i].text.text = Language.ShenGe.NameList[cur_info[i].attr_point + 1] .. "<color=#D0D8FF>+</color>" .. string.format(Language.ShenGe.NumColor, TEXT_COLOR.GREEN_4, cur_info[i].attr_value)
			self.node_list["ImgProgressBG" .. i].slider.value = point_cfg and (cur_info[i].attr_value / point_cfg[1]["max_" .. point_cfg[1].point_type]) or 0
		else
			self.node_list["TxtValue" .. i].text.text = Language.ShenGe.ZWSX
			self.node_list["ImgProgressBG" .. i].slider.value = (0)
		end
	end
	local point_attr = ShenGeData.Instance:GetOnePointInfoAttr(self.list_index, self.point_index)
	if self.fight_text and self.fight_text.text then
		if ready_count >= cfg.perfect_num or ShenGeData.Instance:GetAttrPointInfoNumByShenQuId(self.list_index) > 0 then
			local value = (cfg.value_percent / 100 * CommonDataManager.GetCapabilityCalculation(point_attr)) * ShenGeData.Instance:GetAttrPointInfoNumByShenQuId(self.list_index)
			self.fight_text.text.text = math.ceil(CommonDataManager.GetCapabilityCalculation(point_attr) + value)
		else
			self.fight_text.text.text = math.ceil(CommonDataManager.GetCapabilityCalculation(point_attr))
		end
	end
	local color = ready_count == cfg.perfect_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4
	local color_use_txt = "#D0D8FF"
	if ShenGeData.Instance:ISAllShowCommonAuto(self.list_index,  self.point_index) then 
		color_use_txt = "#D0D8FF"
	end
	self.node_list["TxtDesc"].text.text = string.format(Language.ShenGe.ShenQuDesc, color, ready_count, cfg.perfect_num, Language.ShenGe.NameList[self.point_index])
	--self:ResetToggle()
	UI:SetButtonEnabled(self.node_list["BtnLevelUp"], false)
	for i = 1, 3 do
	 	if self.node_list["Toggle" .. i].toggle.isOn == true then 
	 		UI:SetButtonEnabled(self.node_list["BtnLevelUp"], true)
	 		break
	 	end
	end 
end

function ShenGeGodBodyView:ItemDataChangeCallback()
	self:FlushRightContent()
end

function ShenGeGodBodyView:OnClickXiLian()
	if self.can_send then 
		
		local cfg = ShenGeData.Instance:GetShenquCfgById(self.list_index)
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[cfg.stuff_id]
		
		local xilian_count = 0
		for i = 1, 3 do
			if self.toggle_value_list[i] > 0 then
				xilian_count = xilian_count + 1
			end
		end
	
		local item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
		local need_num = 0
		if xilian_count > 0 then
			need_num = cfg["stuff_num_" ..xilian_count - 1]
		end
	
		if item_num < need_num  and self.is_auto_buy_stone == 0 then
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(cfg.stuff_id)
				return
			end
	
			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				if is_buy_quick then
					self.node_list["AutoBuyToggle"].toggle.isOn = true
					self.is_auto_buy_stone = 1
				end
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, cfg.stuff_id, nil, need_num)
			return
		end
	
		if ShenGeData.Instance:ISShowCommonAuto(self.list_index, self.point_index, self.toggle_value_list) then
			TipsCtrl.Instance:ShowCommonAutoView("shen_ge_god_body_view", Language.ShenGe.TipsDesc,
				function() ShenGeCtrl.Instance:SendShenquReq(self.list_index, self.point_index - 1, 
					self.is_auto_buy_stone, self.toggle_value_list)
					self.can_send = false
					self:PlayXiLianEffect()	
				end,
				function() return end)
			return
		end
		if self.toggle_value_list[1] ~= 0 or self.toggle_value_list[2] ~= 0 or self.toggle_value_list[3] ~= 0 then 
			ShenGeCtrl.Instance:SendShenquReq(self.list_index, self.point_index - 1, self.is_auto_buy_stone, self.toggle_value_list)
			self.can_send = false
			self:PlayXiLianEffect()
		end
	end
end

function ShenGeGodBodyView:PlayXiLianEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["godbody_effect"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ShenGeGodBodyView:SelectShenquCallBack(data_index)
	self.list_index = data_index
	self:FlushAllHl()
	self:ResetToggle()
	self:Flush()
end
function ShenGeGodBodyView:FlushEffect()
	for k,v in pairs(self.point_item_list) do
		local point_index = v:GetIndex()
		local cur_info = ShenGeData.Instance:GetOnePointInfo(self.list_index, point_index)
		if ShenGeData.Instance:ISAllShowCommonAuto(self.list_index, point_index) then
			v:SetEffectPlay(true)
		else
			v:SetEffectPlay(false)
		end
	end
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end
function ShenGeGodBodyView:ClickPointCallBack(cell)
	if nil == cell then
		return
	end
	local index = cell:GetIndex()
	cell:SetToggleState(true)
	for k, v in ipairs(self.point_item_list) do
		if v ~= cell then
			v:SetToggleState(false)
		end
	end
	
	if index == self.point_index then
		return
	end
	
	self.point_index = index
	self:ResetToggle()
	self:FlushRightContent()
end

function ShenGeGodBodyView:ResetToggle(flush)
	local data_list = ShenGeData.Instance:ISShowCommonAutoList(self.list_index, self.point_index, self.toggle_value_list ,flush)
	if "Flush" == flush then 
		for k,v in pairs(data_list) do
			if v == true then 
				self.toggle_value_list[k] = 0
				self.node_list["Toggle" .. k].toggle.isOn = false
			end
		end
	else
		for k,v in pairs(data_list) do
			if v == true then 
				self.toggle_value_list[k] = 0
				self.node_list["Toggle" .. k].toggle.isOn = false
			else
				self.toggle_value_list[k] = 1
				self.node_list["Toggle" .. k].toggle.isOn = true	
			end
		end
	end
end

function ShenGeGodBodyView:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

function ShenGeGodBodyView:OnClickTips()
	local tips_id = 238
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenGeGodBodyView:OnClickToggle(i, is_on)
	if is_on then
		self.toggle_value_list[i] = 1
		self:FlushRightContent()
	else
		local count = 0
		local index = -1
		for k,v in pairs(self.toggle_value_list) do
			if v > 0 then
				count = count + 1
				index = k
			end
		end
		if count == 1 and index == i then
			self.node_list["Toggle" .. i].toggle.isOn = true
			SysMsgCtrl.Instance:ErrorRemind(Language.ShenGe.OneLast)
			return
		end
		self.toggle_value_list[i] = 0
		self:FlushRightContent()
	end
end

function ShenGeGodBodyView:FlushAllHl()
	for k,v in pairs(self.cell_list) do
		v:FlushHl()
	end
end


function ShenGeGodBodyView:GetListIndex()
	return self.list_index
end
function ShenGeGodBodyView:SetNotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end
function ShenGeGodBodyView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		if ItemData.Instance then
			ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
			self.item_data_event = nil
		end
	end
end
---------ShenquItem-----------
ShenquItem = ShenquItem or BaseClass(BaseCell)

function ShenquItem:__init(instance, parent)
	self.parent = parent
	self.node_list["GodBodyCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["TxtCapblity"]:SetActive(true)
end

function ShenquItem:__delete()
	self.parent = nil
end

function ShenquItem:SetCellIndex(index)
	self.cell_index = index
end

function ShenquItem:SetToggleGroup(group)
  	self.root_node.toggle.group = group
end

function ShenquItem:SetToggle(value)
  	self.root_node.toggle.isOn = value
end

function ShenquItem:OnFlush(param_t)
	if not self.data then return end
	self.node_list["CellItem"].image:LoadSprite("uis/views/shengeview/images_atlas", "shenqu_" .. self.data.shenqu_id)
	
	local shenqu_yiman = ShenGeData.Instance:ShenQuItemAllActive(self.data.shenqu_id)
	self.node_list["YiMan"]:SetActive(shenqu_yiman)
	 
	local one_attr_list = ShenGeData.Instance:GetTotalAttrList(self.data.shenqu_id)
	local cfg = ShenGeData.Instance:GetShenquCfgById(self.data.shenqu_id)
	local value = (cfg.value_percent / 100 * CommonDataManager.GetCapabilityCalculation(one_attr_list)) * ShenGeData.Instance:GetAttrPointInfoNumByShenQuId(self.data.shenqu_id)
	self.node_list["TxtCapblity"].text.text = string.format(Language.ShenGe.Capblity, math.ceil(CommonDataManager.GetCapabilityCalculation(one_attr_list) + value))
	local shenqu_id = 0
	if self.data.shenqu_id > 0 then
		shenqu_id = self.data.shenqu_id - 1
	end
	
	local shenqu_history_max_cap = ShenGeData.Instance:GetShenQuHistoryMaxCap(shenqu_id)
	local result = shenqu_history_max_cap >= self.data.fighting_capacity
	self.node_list["TxtCapblity"]:SetActive(result)
	self.node_list["TxtNoAcitve"]:SetActive(not result)
	self.node_list["TxtNoAcitve"].text.text = Language.Common.NoActivate
	UI:SetGraphicGrey(self.node_list["CellItem"], not result)

	local item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	self.node_list["ImgRedPoint"]:SetActive(item_num > 0 and (shenqu_history_max_cap >= self.data.fighting_capacity) and  not shenqu_yiman)


end

function ShenquItem:FlushHl()
	if self.node_list["ImgBg"] then
		self.node_list["ImgBg"]:SetActive(self.parent:GetListIndex() == self.cell_index)
	end
end

function ShenquItem:OnClick()
	local shenqu_id = 0
	if self.data.shenqu_id > 0 then
		shenqu_id = self.data.shenqu_id - 1
	end
	local shenqu_history_max_cap = ShenGeData.Instance:GetShenQuHistoryMaxCap(shenqu_id)
	if shenqu_history_max_cap < self.data.fighting_capacity then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.ShenGe.ShenGeDesc, self.data.fighting_capacity))
		return
	end
	UI:SetButtonEnabled(self.parent.node_list["BtnLevelUp"], shenqu_history_max_cap >= self.data.fighting_capacity)
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end
-------------------------------PointCell------------------------------
-------------------------------------------------------------------------------
PointCell = PointCell or BaseClass(BaseCell)

local Effect_Res_List = {
	[1] = "UI_xingling_lvse",
	[2] = "UI_xingling_lanse",
	[3] = "UI_xingling_zise",
	[4] = "UI_xingling_huangse",
	[5] = "UI_xingling_hongse",
	[6] = "UI_xingling_hongse",
	[7] = "UI_xingling_hongse",
}

function PointCell:__init()
	self.node_list["ImgPoint"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))

	GlobalTimerQuest:AddDelayTimer(function ()
					self.init_pos = self.root_node.transform.anchoredPosition
					self:PlaySelectAction()
				end, 0.5)
end

function PointCell:__delete()
	self.init_pos = nil
end

function PointCell:OnFlush()
	self.node_list["TxtValue"].text.text = Language.OneWordAttr.NameList[self.index]
	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetShenGeImg("img_attr_".. self.index))
	

end
function PointCell:SetEffectPlay(bool)
	self.node_list["Effect"]:SetActive(bool)
end

function PointCell:SetToggleState(state)

	self.root_node.toggle.isOn = state
	if self.init_pos then
		self:PlaySelectAction()
	end
end

function PointCell:PlaySelectAction()
	if self.root_node.toggle.isOn then
		if nil == self.tween then
			self.tween = self.root_node.transform:DOAnchorPosY(self.init_pos.y + 10, 0.5)
			self.tween:SetEase(DG.Tweening.Ease.InOutSine)
			self.tween:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
		end
	else
		if self.tween then
			self.tween:Pause()
			self.tween = nil
		end

		self.root_node.transform.anchoredPosition = self.init_pos
	end
end
