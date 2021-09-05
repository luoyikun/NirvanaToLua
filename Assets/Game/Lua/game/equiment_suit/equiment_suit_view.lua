EquimentSuitView = EquimentSuitView or BaseClass(BaseView)
local RING_INDEX_1 = 8
local RING_INDEX_2 = 10

function EquimentSuitView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
			{"uis/views/player_prefab", "EquipmentSuitView"},
	}

	self.play_audio = true
	self.alert1 = nil
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end
 
function EquimentSuitView:__delete()

end

function EquimentSuitView:ReleaseCallBack()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function EquimentSuitView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(760, 608, 0)
	self.node_list["Txt"].text.text = Language.Forge.EquimentSuitName
	self.node_list["RawImgBg"].raw_image:LoadSprite("uis/rawimages/equiment_suit_bg", "equiment_suit_bg.png", function()
		self.node_list["RawImgBg"]:SetActive(true)
		self.node_list["RawImgBg"].raw_image:SetNativeSize()
	end)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["SuitButton"].button:AddClickListener(BindTool.Bind(self.OnClickActivation, self))
	self.cells = {}
	self:InitScroller()
end

function EquimentSuitView:InitScroller()
	
	for i = 1, 11 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		self.cells[i] = item
	end
end

function EquimentSuitView:OpenCallBack()
	self:OnEquipDataListChange()
end

function EquimentSuitView:OnEquipDataListChange()
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

function EquimentSuitView:ShowIndexCallBack(index)
	self:Flush()
end

function EquimentSuitView:OnClickActivation()
		local suit_level = EquimentSuitData.Instance:GetEquimentSuitLevel()
		local data_list = EquimentSuitData.Instance:GetEquimentSuitCfg(suit_level)
		if data_list == nil then return end
		local need_num = EquimentSuitData.Instance:GetEquimentSuitNeed(data_list.equip_level)
		if need_num == data_list.need_count then
			EquimentSuitCtrl.Instance:SendGetSuitActiveInfo(data_list.order)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Forge.EquimentSuitSys)
		end
end

function EquimentSuitView:SetData(equiplist)
	local suit_level = EquimentSuitData.Instance:GetEquimentSuitLevel()
	local data_list = EquimentSuitData.Instance:GetEquimentSuitCfg(suit_level)
	for k, v in pairs(self.cells) do
		v:ShowGetEffect(false)
		if equiplist[k - 1] and equiplist[k - 1].item_id then
			v:SetData(equiplist[k - 1])
			v:SetIconGrayScale(false)
			v:ShowHighLight(true)
			v:ShowQuality(false)
			v:SetHighLight(self.cur_index == k)
			v:ShowEquipGrade(true)
			v:SetBackground(false)
			v:SetIsShowTips(false)
			v:SetVisibleBindLock(false)
			v:ShowEquipFenEffect(false)
			v:SetVisibleShowStar(false)
			v:ShowStrengthLable(false)
			v:ShowEquipRedEffect(false)
			local cfg = ItemData.Instance:GetItemConfig(equiplist[k - 1].item_id)
			if cfg and cfg.color == GameEnum.ITEM_COLOR_PINK then
				v:ShowGetEffect(false)
			end
			local item_cfg = ItemData.Instance:GetItemConfig(equiplist[k - 1].item_id) 
			if item_cfg.limit_level < data_list.equip_level then
				v:SetIconGrayScale(true)
				v:ShowEquipGradeText(data_list.equip_level)
				-- v:SetIsShowTips(false)
			else
				v:SetIconGrayScale(false)
				-- v:ListenClick(BindTool.Bind(self.OnClickItem1, self, k, equiplist[k - 1], v))
			end
		else
			local data = {}
			v:ShowQuality(false)
			data.is_bind = 0
			data.item_id = EquipData.Instance:GetDefaultIcon(k - 1)
			v:SetData(data)
			v:SetIconGrayScale(true)
			v:SetHighLight(false)
			v:SetBackground(false)
			v:ShowHighLight(false)
			v:ShowEquipGrade(false)
			v:ListenClick(BindTool.Bind(function ()
			end))
		end
	end
end

--刷新
function EquimentSuitView:OnFlush(param_t, index)
	local suit_level = EquimentSuitData.Instance:GetEquimentSuitLevel()
	local data_list = EquimentSuitData.Instance:GetEquimentSuitCfg(suit_level)
	if data_list == nil then return  end
	self:OnEquipDataListChange()
	local need_num = EquimentSuitData.Instance:GetEquimentSuitNeed(data_list.equip_level)
	self.node_list["ProgressBG"].slider.value = (need_num / data_list.need_count)
	self.node_list['SuitLevelText'].text.text = string.format(Language.Forge.EquimentSuitAtt, data_list.equip_level)
	self.node_list["GongjiText"]:SetActive(data_list.gongji > 0)
	self.node_list["FangyuText"]:SetActive(data_list.fangyu > 0)
	self.node_list["MaxhpText"]:SetActive(data_list.maxhp > 0)
	self.node_list["ZhufuText"]:SetActive(data_list.per_zhufuyiji > 0)
	self.node_list['GongjiText'].text.text = string.format(Language.Forge.EquimentSuitGJ, data_list.gongji)
	self.node_list['FangyuText'].text.text = string.format(Language.Forge.EquimentSuitFY, data_list.fangyu)
	self.node_list['MaxhpText'].text.text = string.format(Language.Forge.EquimentSuitHP, data_list.maxhp)
	self.node_list['ZhufuText'].text.text = string.format(Language.Forge.EquimentSuitZF, math.ceil(data_list.per_zhufuyiji / 100))
	local color = need_num >= data_list.need_count and "#89F201FF" or "#F9463bFF"
	self.node_list['SuitScheduleTxt'].text.text = string.format(Language.Forge.EquimentSuitSchedule, color, need_num, data_list.need_count)
	local is_show = EquimentSuitData.Instance:SetSuitActiveFlag(data_list.order)
	if need_num == data_list.need_count and not is_show then
		UI:SetButtonEnabled(self.node_list["SuitButton"], true)
		self.node_list["BtnText"].text.text = Language.Common.Activate
	elseif need_num == data_list.need_count and is_show then
		UI:SetButtonEnabled(self.node_list["SuitButton"], false)
		self.node_list["BtnText"].text.text = Language.Common.YiActivate
	else
		UI:SetButtonEnabled(self.node_list["SuitButton"], false)
		self.node_list["BtnText"].text.text = Language.Common.Activate
	end

end


-- function EquimentSuitView:OnClickItem1(index, data, cell)
-- 	if data == nil or not next(data) then
-- 		cell:SetHighLight(false)
-- 		if index == RING_INDEX_1 or index == RING_INDEX_2 then
-- 			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
-- 			ViewManager.Instance:Close(ViewName.Player)
-- 		else
-- 			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
-- 		end
-- 		return
-- 	end
-- 	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
-- 	if not item_cfg then
-- 		cell:SetHighLight(false)
-- 		if index == RING_INDEX_1 or index == RING_INDEX_2 then
-- 			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
-- 			ViewManager.Instance:Close(ViewName.Player)
-- 		else
-- 			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
-- 		end
-- 		return
-- 	end
-- 	self.cur_index = index
-- 	cell:SetHighLight(self.cur_index == index)
-- 	local close_callback = function ()
-- 		cell:SetHighLight(false)
-- 		self.cur_index = nil
-- 	end

-- 	if data.param then
-- 		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
-- 		local shen_info = EquipmentShenData.Instance:GetEquipData(equip_index)
-- 		data.param.angel_level = shen_info and shen_info.level or 0
-- 	end
-- 	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_PLAYER_INFO, nil, close_callback)
-- end

