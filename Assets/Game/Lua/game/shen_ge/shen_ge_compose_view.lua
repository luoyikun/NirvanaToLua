ShenGeComposeView = ShenGeComposeView or BaseClass(BaseView)
local EFFECT_CD = 1
local MAX_COMPOSE_NUM = 3

function ShenGeComposeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengeview_prefab", "ShenGeComposeView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	
	self.fight_info_view = true
	self.click_index = -1
	self.had_set_data_list = {}
	self.had_set_data_count = 0
	self.effect_cd = 0
	self.itemcell_list = {}
end

function ShenGeComposeView:ReleaseCallBack()
	self.effect_cd = nil
	for _, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end
end

function ShenGeComposeView:LoadCallBack()
	self.node_list["Txt"].text.text = Language.ShenGe.HeCheng
	self.node_list["Bg"].rect.sizeDelta = Vector3(871,590,0)

	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickYes, self))
	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.OnClickAutomatic, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.item_list = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item"..i])
		item:SetClearListenValue(false)
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		item:ShowQuality(true)
		item.node_list["Icon"].image.preserveAspect = true
		self.item_list[i] = item
	end

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)

end

function ShenGeComposeView:OpenCallBack()
	self:ClearItemData()
end
function ShenGeComposeView:OnClickClose()
	ShenGeCtrl.Instance:RecoverData()
	self:Close()
end
function ShenGeComposeView:CloseCallBack()
	ShenGeCtrl.Instance:RecoverData()
end

function ShenGeComposeView:OnClickYes()
	
	if self.had_set_data_count < MAX_COMPOSE_NUM then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.MaterialNoEnough)
		return
	end
	if  nil == self.had_set_data_list[1] and nil == self.had_set_data_list[2] and nil == self.had_set_data_list[3] then 
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.MaterialNoEnough)
	end
	UI:SetButtonEnabled(self.node_list["BtnYes"],false)
	TipsCtrl.Instance:OpenMoveItemView(self.itemcell_list[1], self.node_list["Item2"] , self.node_list["Item1"], 0.5, true)
	TipsCtrl.Instance:OpenMoveItemView(self.itemcell_list[2], self.node_list["Item3"] , self.node_list["Item1"], 0.5, true)
	self.node_list["Item2"]:SetActive(false)
	self.node_list["Item3"]:SetActive(false)
	GlobalTimerQuest:AddDelayTimer(function()
		self:PlayUpStarEffect()
	end, 0.5)
	
	local ok_func = function()
		if next(self.had_set_data_list) then 
			if nil ~= self.had_set_data_list[1] and nil ~= self.had_set_data_list[2] and nil ~= self.had_set_data_list[3] then 
				ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_COMPOSE,
				self.had_set_data_list[1].shen_ge_data.index,
				self.had_set_data_list[2].shen_ge_data.index,
				self.had_set_data_list[3].shen_ge_data.index)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.MaterialNoEnough)
			end
		end
	end
	if self.had_set_data_list[1].shen_ge_data.level > 1
		or self.had_set_data_list[2].shen_ge_data.level > 1
		or self.had_set_data_list[3].shen_ge_data.level > 1 then
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenGe.ComposeTip , nil, nil, true, false, "compose_shen_ge", false, "", "", false, nil, true, Language.Common.Cancel, nil, false)
		return
	end
	GlobalTimerQuest:AddDelayTimer(function()
		ok_func()
		local flag = ShenGeData.Instance:GetAutomaticComposeFlag()
		if flag == SHENGE_AUTOMATIC_COMPOSE_FLAG.NO_START then 
			UI:SetButtonEnabled(self.node_list["BtnYes"],true)
		end
	end, 1.2)

end



function ShenGeComposeView:OnClickNo()
	self:ClearItemData()
end

-- function ShenGeComposeView:OnClickClose()
-- 	self:Close()
-- end

function ShenGeComposeView:OnClickHelp()
	local tips_id = 168
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenGeComposeView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["effect_root"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end


-- function ShenGeComposeView:TheData(data)
-- 	self.itemcell_list = data
-- end

-- function ShenGeComposeView:SetItemMove()
-- 	local target_obj = self.node_list["Item1"]
-- 	if nil == target_obj then
-- 		return
-- 	end
-- 	TipsCtrl.Instance:OpenMoveItemView(self.itemcell_list, self.node_list["Item2"] , self.node_list["Item1"], 1, true)
-- end

function ShenGeComposeView:OnClickItem(index)
	local call_back = function(data)
		self.item_list[index]:SetHighLight(false)
		if nil ~= data then
			if nil == self.item_list[index]:GetData().item_id then
				self.had_set_data_count = self.had_set_data_count + 1
			end
			self.item_list[index]:SetData(data)
			self.node_list["ImgPlus" .. index]:SetActive(false)
			self.had_set_data_list[index] = data
			
			-- 第一次选择，自动填充同样的神格
			if self.click_index <= 0 then
				local list = ShenGeData.Instance:GetBagSameQualityAndTypesItemDataList(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.index)
				for k, v in pairs(self.item_list) do
					if nil == v:GetData().item_id and nil ~= list[1] then
						self.had_set_data_count = self.had_set_data_count + 1
						v:SetData(list[1])
						self.node_list["ImgPlus" .. k]:SetActive(false)
						self.had_set_data_list[k] = list[1]
						table.remove(list, 1)
					end
				end
			end
			self.click_index = index
			self.itemcell_list[1] = self.item_list[2]:GetData()
			self.itemcell_list[2] = self.item_list[3]:GetData()
		end

		if self.had_set_data_count == MAX_COMPOSE_NUM then
			local shen_ge_kind = self.had_set_data_list[1].shen_ge_kind
			local quality = self.had_set_data_list[1].shen_ge_data.quality
			local composite_prob = ShenGeData.Instance:GetCompseSucceedRate(shen_ge_kind, quality)
			self.node_list["TxtTips"]:SetActive(true)
			self.node_list["TxtTips"].text.text = string.format(Language.ShenGe.CompositePrecent, composite_prob)
		end
	end
	-- 在自动进阶时，不能点击，弹出自动进阶的提示
	local flag = ShenGeData.Instance:GetAutomaticComposeFlag()
	if flag ~= SHENGE_AUTOMATIC_COMPOSE_FLAG.NO_START then
		self.item_list[index]:ShowHighLight(false)
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenGe.ComposeAutomatic)
		return
	end
	-- 判断点击是否清除的
	if self.had_set_data_list and self.had_set_data_count >= 0 and self.had_set_data_list[index] then
		self:ClearItemDataByIndex(index)
		return
	end
	self.had_set_data_list.count = self.had_set_data_count
	ShenGeCtrl.Instance:ShowSelectView(call_back, self.had_set_data_list, "from_compose")
	-- self.item:SetData()
	-- self.item:SetDefualtQuality()
	-- self.item:OnlyShowQuality(true)
end

function ShenGeComposeView:OnDataChange(info_type, param1, param2, param3)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO then
		self:ClearItemData()
	end
end

function ShenGeComposeView:ClearItemData()
	for k, v in pairs(self.item_list) do
		v:SetData()
		self.node_list["ImgPlus" .. k]:SetActive(true)
	end
	self.had_set_data_list = {}
	self.click_index = -1
	self.had_set_data_count = 0
	self.node_list["TxtTips"]:SetActive(false)
	self.node_list["Item2"]:SetActive(true)
	self.node_list["Item3"]:SetActive(true)
end
--自动合成------------------------------------------------------------------------------------------
function ShenGeComposeView:OnClickAutomatic()
	local flag = ShenGeData.Instance:GetAutomaticComposeFlag()
	if flag == SHENGE_AUTOMATIC_COMPOSE_FLAG.NO_START then
		ShenGeData.Instance:SetAutomaticComposeFlag(SHENGE_AUTOMATIC_COMPOSE_FLAG.COMPOSE_REQUIRE)
		ShenGeData.Instance:SetSelectComposeList(self.had_set_data_list)
		ShenGeCtrl.Instance:AutomaticComposeAction()
	else
		ShenGeCtrl.Instance:RecoverData()	--取消
	end
end
-- 清除某个格子的状态
function ShenGeComposeView:ClearItemDataByIndex(index)
	if nil == index or index <= 0 or index > MAX_COMPOSE_NUM or self.had_set_data_count <= 0 then return end
	for k, v in pairs(self.item_list) do
		if k == index then
			v:ShowHighLight(false)
			v:SetData()
			self.node_list["ImgPlus" .. k]:SetActive(true)
		end
	end

	--self:ClearComposeData()
	self.had_set_data_list[index] = nil
	self.had_set_data_count = self.had_set_data_count - 1
	self.click_index = self.had_set_data_count <= 0 and -1 or index
	self.node_list["TxtTips"]:SetActive(false)
end

function ShenGeComposeView:ClearComposeData()
	--self.item:SetData()
	--self.item:SetDefualtQuality()
	--self.item:OnlyShowQuality(true)
end

function ShenGeComposeView:SetDataSameItem()
	self:CacleDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self:ShowDataSameItem()
		--self:ClearComposeData()
	end, 0.2)
end

function ShenGeComposeView:CacleDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ShenGeComposeView:ShowDataSameItem()
	local select_list = ShenGeData.Instance:GetSelectComposeList()
	for k, v in pairs(self.item_list) do
		if nil ~= select_list[k] then
			v:SetData(select_list[k])
			self.had_set_data_count = self.had_set_data_count + 1
			self.node_list["ImgPlus" .. k]:SetActive(false)
			self.had_set_data_list[k] = select_list[k]	
		end
	end
	self.itemcell_list[1] = self.item_list[2]:GetData()
	self.itemcell_list[2] = self.item_list[3]:GetData()
end
function ShenGeComposeView:HideProb(state)
	self.node_list["TxtTips"]:SetActive(state)	-- 合成成功率显示
end

function ShenGeComposeView:FlushComposeButton(state)	-- 设置按钮的状态
	if state then 
		self.node_list["TxtBtnAuto"].text.text = Language.ShenGe.BtnCanelAutomatic
		UI:SetButtonEnabled(self.node_list["BtnYes"], false)
	else
		self.node_list["TxtBtnAuto"].text.text = Language.ShenGe.BtnAutomatic
		UI:SetButtonEnabled(self.node_list["BtnYes"], true)	
	end
end