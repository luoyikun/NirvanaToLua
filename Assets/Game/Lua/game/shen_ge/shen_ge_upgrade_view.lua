ShenGeUpgradeView = ShenGeUpgradeView or BaseClass(BaseView)
local MAX_NUM = 2

function ShenGeUpgradeView:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/shengeview_prefab", "ShenGeUpgradeView"}}
	self.play_audio = true
	self.fight_info_view = true
	self.is_from_bag = true
	self.cell_list = {}
end

function ShenGeUpgradeView:ReleaseCallBack()
	if self.item then 
		self.item:DeleteMe()
	end
	self.item = nil

	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end
	self.cell_list = {}

	self.fight_text = nil
end

function ShenGeUpgradeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnChange"].button:AddClickListener(BindTool.Bind(self.OnClickChange, self))
	self.node_list["BtnTakeOff"].button:AddClickListener(BindTool.Bind(self.OnClickTakeOff, self))
	self.node_list["BtnTakeOn"].button:AddClickListener(BindTool.Bind(self.OnClickTakeOn, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
	-- self.item:ShowQuality(false)
	-- self.item:SetBackground(false)
	self.item:SetData()
	self.item.node_list["Icon"].image.preserveAspect = true

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtLefhNumber"], "FightPower3")

end

function ShenGeUpgradeView:ShowFromBag(ShowFromBag)
	self.node_list["BtnTakeOn"]:SetActive(ShowFromBag)
	self.node_list["BtnChange"]:SetActive(not ShowFromBag)
	self.node_list["BtnTakeOff"]:SetActive(not ShowFromBag)
end

function ShenGeUpgradeView:ShowNextAttr(ShowNextAttr)

end

function ShenGeUpgradeView:OpenCallBack()
	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
	self:SetPanelData()
end

function ShenGeUpgradeView:CloseCallBack()
	self.node_list["TxtLefhTitle"].text.text = ""
	if nil ~= self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end

	self.node_list["Kuang"].image.enabled = false
	self.node_list["Line"].image.enabled = false
	self.node_list["QualityImage"].raw_image.enabled = false

	ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
	self.data_change_event = nil
end

function ShenGeUpgradeView:OnClickTakeOff()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_UNLOAD_SHENGE, cur_page, self.data.shen_ge_data.index)
	-- 延迟刷新
	local delay_time = GlobalTimerQuest:AddDelayTimer(
		function() 
			ShenGeCtrl.Instance.view:Flush()
		end, 0.1)
	self:Close()
end

function ShenGeUpgradeView:OnClickChange()
	local index = self.data.shen_ge_data.index
	local quyu = math.floor(index / 4) + 1
	local call_back = function(data)
		if nil == data then
			self:Close()
			return
		end
		local cur_page = ShenGeData.Instance:GetCurPageIndex()
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SET_RUAN, data.shen_ge_data.index, cur_page, index)
		self:Close()
	end
	ShenGeCtrl.Instance:ShowSelectView(call_back, {[1] = quyu}, "from_inlay", self.data.shen_ge_data.type)
end

function ShenGeUpgradeView:OnClickTakeOn()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local slot_state_list = ShenGeData.Instance:GetSlotStateList()
	local shen_ge_data = self.data.shen_ge_data
	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == attr_cfg then return end

	local min_index = (attr_cfg.quyu - 1) * 4
	local max_index = min_index + 3
	for i = min_index, max_index do
		local inlay_data = ShenGeData.Instance:GetInlayData(cur_page, i)
		if slot_state_list[i] and (nil == inlay_data or inlay_data.item_id <= 0) then
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SET_RUAN, self.data.shen_ge_data.index, cur_page, i)
			self:Close()
			return
		end
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.HaveNoShenGeCanUse)
	self:Close()
end

function ShenGeUpgradeView:SetData(data)
	self.data = data
	if nil == self.data or self.data.item_id <= 0 then
		return
	end
	self:Open()
	self:LoadCell(data)
end

function ShenGeUpgradeView:LoadCell(data)
	self.current_all_suit = ShenGeData.Instance:GetSuitCfg()
	local count = 0
	self.data_list = {}
	if self.current_all_suit then
		local quality = data.shen_ge_data.quality
		if quality >= 5 then
			quality = 4
		end

		for k, v in ipairs(self.current_all_suit) do
			if v.quality == quality then
				count = count + 1
				table.insert(self.data_list, v)
			end
		end
	end

	self.node_list["TaoZhuangAttr"]:SetActive(count > 0)
	if count > 0 then
		local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
		res_async_loader:Load("uis/views/hunqiview_prefab", "suitcell", nil, function (prefab)
			if not prefab then
				return 
			end
			if count > #self.cell_list then
				for i = #self.cell_list, count - 1 do
					local obj = ResMgr:Instantiate(prefab)
					local cell = ShenGeTipInfoCell.New(obj.gameObject)
					cell:SetInstanceParent(self.node_list["BaseAttrText"], false)
					table.insert(self.cell_list, cell)
				end
			end
			for k, v in pairs(self.cell_list) do
				v:SetData(self.data_list[k], self.is_from_bag)
			end
		end)
	end
end

function ShenGeUpgradeView:SetCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function ShenGeUpgradeView:SetIsFromBag(value)
	self.is_from_bag = value or false
end

function ShenGeUpgradeView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if not self:IsOpen() then return end

	if self.is_from_bag and info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SIGLE_CHANGE then
		self.data = ShenGeData.Instance:GetShenGeItemData(self.data.shen_ge_data.index)
		self:SetPanelData()
	elseif not self.is_from_bag and info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SHENGE_INFO then
		self.data = ShenGeData.Instance:GetInlayData(param1, self.data.shen_ge_data.index)
		self:SetPanelData()
	end
end

function ShenGeUpgradeView:SetPanelData()
	self.item:SetData(self.data)
	if nil == self.data or nil == self.data.shen_ge_data then
		return
	end
	local shen_ge_data = self.data.shen_ge_data
	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == attr_cfg then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local level_str = attr_cfg.name
	local txt_title = "<color=%s>%s</color>"
	self.node_list["TxtLefhTitle"].text.text = string.format(txt_title, TEXT_COLOR.WHITE, level_str)
	self.node_list["ImgWearIcon"]:SetActive(not self.is_from_bag)

	local bundle, asset = ResPath.GetQualityRawBgIcon(item_cfg.color)
	self.node_list["QualityImage"].raw_image:LoadSprite(bundle, asset, function()
		self.node_list["QualityImage"]:SetActive(true) end)
	self.node_list["Kuang"].image:LoadSprite(ResPath.GetQualityKuangBgIcon(item_cfg.color))
	self.node_list["Line"].image:LoadSprite(ResPath.GetQualityTopBg(item_cfg.color))

	local _, _, name =  ShenGeData.Instance:GetShenGeQualityByItemId(self.data.item_id)

	-- self.node_list["TxtEquipType"]:SetActive(true)
	self.node_list["TxtEquipType"].text.text = string.format(Language.ShenGe.ShenGeTypeName, name or "" )

	local fragment = (attr_cfg.next_level_need_marrow_score)

	local had_fragments = ShenGeData.Instance:GetFragments(true)
	local had_fragments_str = ShenGeData.Instance:GetFragments()
	local str = ""
	if had_fragments < attr_cfg.next_level_need_marrow_score then
		str = ToColorStr(had_fragments_str,TEXT_COLOR.RED_4)
	else
		str = ToColorStr(had_fragments_str,TEXT_COLOR.GREEN_4)
	end
	local all_fragment = str

	self:SetCurAttr(attr_cfg)

	self:ShowFromBag(self.is_from_bag)
end

function ShenGeUpgradeView:SetCurAttr(attr_cfg)
	local attr_list = {}
	for k = 1 , MAX_NUM do
		local attr_value = attr_cfg["add_attributes_"..(k - 1)]
		local attr_type = attr_cfg["attr_type_"..(k - 1)]
		local attr_key = Language.ShenGe.AttrType[attr_type]
		if attr_value > 0 then
			self.node_list["TxtLefhAttr" .. k]:SetActive(true)
			
			if attr_type == 8 or attr_type == 9 then
				self.node_list["TxtLefhAttr" .. k].text.text = Language.ShenGe.AttrTypeName[attr_type].."："..(attr_value / 100).."%"
			else
				attr_list[attr_key] = attr_value
				local attr_value_text=Language.ShenGe.AttrTypeName[attr_type].."<color=#ffffff>：</color>"..ToColorStr(attr_value, TEXT_COLOR.GREEN)
				self.node_list["TxtLefhAttr" .. k].text.text = attr_value_text
			end
		else
			self.node_list["TxtLefhAttr" .. k].text.text = ""
			self.node_list["TxtLefhAttr" .. k]:SetActive(false)
		end
	end

	local power = CommonDataManager.GetCapabilityCalculation(attr_list)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = Language.Common.ZhanLi .. ": " .. power + attr_cfg.capbility
	end

	local count_orange = 0
	local count_red = 0
	self.current_all_suit = ShenGeData.Instance:GetSuitCfg()
	for k, v in pairs(self.current_all_suit) do
		if v.quality == 3 then
			count_orange = count_orange + 1
		elseif v.quality == 4 then
			count_red = count_red + 1
		end
	end
	local data_info = ShenGeData.Instance:GetShenGeQualityInfo()
	local orange_max_num = self.current_all_suit[count_orange].need_count or 0
	local red_max_num = self.current_all_suit[#self.current_all_suit].need_count or 0
	local orange_num = data_info[4] or 0
	local red_num = data_info[5]or 0
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if self.is_from_bag then
		if item_cfg and item_cfg.color == GameEnum.ITEM_COLOR_ORANGE then
			self.node_list["SuitName"].text.text = string.format(Language.HunQi.OrangeSuitName2)
		else
			self.node_list["SuitName"].text.text = string.format(Language.HunQi.RedSuitName2)
		end
	else
		if item_cfg and item_cfg.color == GameEnum.ITEM_COLOR_ORANGE then
			self.node_list["SuitName"].text.text = string.format(Language.HunQi.OrangeSuitName, orange_num, orange_max_num)
		else
			self.node_list["SuitName"].text.text = string.format(Language.HunQi.RedSuitName, red_num, red_max_num)
		end
	end
end

function ShenGeUpgradeView:OnClickClose()
	self:Close()
end


--------------------------ShenGeTipInfoCell-----------------------------
ShenGeTipInfoCell = ShenGeTipInfoCell or BaseClass(BaseCell)
function ShenGeTipInfoCell:__init()
	self.from_view = false
end

function ShenGeTipInfoCell:__delete()

end

function ShenGeTipInfoCell:SetData(data, from_view)
	self.data = data
	self.from_view = from_view

	self:Flush()
end

function ShenGeTipInfoCell:OnFlush()
	if self.data == nil then
		self.node_list["suitcell"]:SetActive(false)
		return
	end
	self.node_list["suitcell"]:SetActive(true)
	local num = 0
	local data_info = ShenGeData.Instance:GetShenGeQualityInfo()
	if not self.from_view then
		num = data_info[self.data.quality + 1] or 0
	end

	local color1 = num >= self.data.need_count and TEXT_COLOR.GREEN or COLOR.WHITE
	self.node_list["TxtSuitName"].text.text = ToColorStr(string.format(Language.HunQi.TaoZhuang, self.data.need_count), color1)
	self.node_list["TxtAttr_1"].text.text = string.format(Language.HunQi.AttrList[1], color1, self.data.gongji)
	self.node_list["TxtAttr_2"].text.text = string.format(Language.HunQi.AttrList[2], color1, self.data.fangyu)
	self.node_list["TxtAttr_3"].text.text = string.format(Language.HunQi.AttrList[3], color1, self.data.maxhp)
	self.node_list["TxtAttr_4"].text.text = string.format(Language.HunQi.AttrList[4], color1, self.data.mingzhong)
	self.node_list["TxtAttr_5"].text.text = string.format(Language.HunQi.AttrList[5], color1, self.data.shanbi)
	self.node_list["TxtAttr_6"].text.text = string.format(Language.HunQi.AttrList[6], color1, self.data.baoji)
	self.node_list["TxtAttr_7"].text.text = string.format(Language.HunQi.AttrList[7], color1, self.data.jianren)
	self.node_list["TxtAttr_8"].text.text = string.format(Language.HunQi.AttrList[8], color1, self.data.per_gongji / 100)
	self.node_list["TxtAttr_9"].text.text = string.format(Language.HunQi.AttrList[9], color1, self.data.per_fangyu / 100)
	self.node_list["TxtAttr_10"].text.text = string.format(Language.HunQi.AttrList[10], color1, self.data.per_maxhp / 100)
	self.node_list["TxtAttr_11"].text.text = string.format(Language.HunQi.AttrList[14], color1, self.data.per_mianshang / 100)

	self.node_list["AttrGroup1"]:SetActive(self.data.gongji and self.data.gongji > 0 or false)
	self.node_list["AttrGroup2"]:SetActive(self.data.fangyu and self.data.fangyu > 0 or false)
	self.node_list["AttrGroup3"]:SetActive(self.data.maxhp and self.data.maxhp > 0 or false)
	self.node_list["AttrGroup4"]:SetActive(self.data.mingzhong and self.data.mingzhong > 0 or false)
	self.node_list["AttrGroup5"]:SetActive(self.data.shanbi and self.data.shanbi > 0 or false)
	self.node_list["AttrGroup6"]:SetActive(self.data.baoji and self.data.baoji > 0 or false)
	self.node_list["AttrGroup7"]:SetActive(self.data.jianren and self.data.jianren > 0 or false)
	self.node_list["AttrGroup8"]:SetActive(self.data.per_gongji and self.data.per_gongji > 0)
	self.node_list["AttrGroup9"]:SetActive(self.data.per_fangyu and self.data.per_fangyu > 0)
	self.node_list["AttrGroup10"]:SetActive(self.data.per_maxhp and self.data.per_maxhp > 0)
	self.node_list["AttrGroup11"]:SetActive(self.data.per_mianshang and self.data.per_mianshang > 0)
end