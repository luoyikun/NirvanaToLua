HunYinInlayTips = HunYinInlayTips or BaseClass(BaseView)
function HunYinInlayTips:__init()
	self.ui_config = {{"uis/views/hunqiview_prefab", "HunYinInlayTips"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.cell_list ={}
end

function HunYinInlayTips:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClickInlay, self))
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ImgIcon"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
	self.item:SetBackground(false)
	self.item:SetData()

	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
end

function HunYinInlayTips:ReleaseCallBack()
	self.hunyin_info = {}
	self.cell_list ={}
	if self.item then 
		self.item:DeleteMe()
	end
	self.item = nil
	self.fight_text = nil
end

function HunYinInlayTips:OpenCallBack()
	self.current_hunqi_index, self.current_hunyin_index, self.current_item_id = self.open_callback()
	local item_config = self.hunyin_info[self.current_item_id][1]
	if nil ~= item_config then
		self.node_list["TxtName"].text.text = Language.HunYinSuit["color_" .. item_config.hunyin_color] .. item_config.name .. "</color>"
		self.item:SetData({item_id = item_config.hunyin_id})
		-- self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.current_item_id))) 
		self.node_list["Text_hp"].text.text = Language.Common.AttrNameList[2] ..":  " .. item_config.maxhp
		self.node_list["Text_fangyu"].text.text = Language.Common.AttrNameList[3] ..":  " .. item_config.fangyu
		self.node_list["Text_mingzhong"].text.text = Language.Common.AttrNameList[4] ..":  " .. item_config.mingzhong
		self.node_list["Text_gongji"].text.text = Language.Common.AttrNameList[1] ..":  " .. item_config.gongji
		self.node_list["Text_shanbi"].text.text = Language.Common.AttrNameList[5] ..":  " .. item_config.shanbi
		self.node_list["Text_baoji"].text.text = Language.Common.AttrNameList[6] ..":  " .. item_config.baoji
		self.node_list["Text_jianren"].text.text = Language.Common.AttrNameList[7] ..":  " .. item_config.jianren
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapability(item_config)
		end

		self.node_list["Text_hp"]:SetActive(item_config.maxhp > 0)
		self.node_list["Text_fangyu"]:SetActive(item_config.fangyu > 0)
		self.node_list["Text_mingzhong"]:SetActive(item_config.mingzhong > 0)
		self.node_list["Text_gongji"]:SetActive(item_config.gongji > 0)
		self.node_list["Text_shanbi"]:SetActive(item_config.shanbi > 0)
		self.node_list["Text_baoji"]:SetActive(item_config.baoji > 0)
		self.node_list["Text_jianren"]:SetActive(item_config.jianren > 0)

		self:LoadCell(item_config)
	end
end

function HunYinInlayTips:LoadCell(data)
	self.current_all_suit = HunQiData.Instance:GetHunYinSuitCfgByIndex(self.current_hunqi_index)
	local count = 0
	self.data_list = {}
	local quailty = ItemData.Instance:GetItemQuailty(data.hunyin_id)
	if self.current_all_suit then
		for k, v in ipairs(self.current_all_suit) do
			if v.suit_color == quailty or (quailty == 6 and v.suit_color == 5) then
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
					local cell = TipsSuitInfoCell.New(obj.gameObject)
					cell:SetInstanceParent(self.node_list["BaseAttrText"], false)
					table.insert(self.cell_list, cell)
				end
			end
			for k, v in pairs(self.cell_list) do
				v:SetCurrentHunQiIndex(self.current_hunqi_index)
				v:SetData(self.data_list[k])
			end
		end)
	end
end

function HunYinInlayTips:CloseCallBack()
	self.current_hunqi_index = nil
	self.current_hunyin_index = nil
	self.current_item_id = nil
end

function HunYinInlayTips:OnClickInlay()
	local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_hunqi_index, self.current_hunyin_index)
	if is_lock then
		local des = string.format(Language.HunQi.HunYinLock, need_level)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end
	local hunyin_list = HunQiData.Instance:GetHunYinListByIndex(self.current_hunqi_index)
	if hunyin_list and hunyin_list[self.current_hunyin_index] and hunyin_list[self.current_hunyin_index].is_lock == 1 then
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_HUNYIN_INLAY, self.current_hunqi_index - 1, 
			self.current_hunyin_index - 1, ItemData.Instance:GetItemIndex(self.current_item_id))
	end

	self:OnClickClose()
end

function HunYinInlayTips:OnClickClose()
	self.close_callback()
	self:Close()
end

function HunYinInlayTips:SetCloseCallBack(callback)
	self.close_callback = callback
end

function HunYinInlayTips:SetOpenCallBack(callback)
	self.open_callback = callback
end


--------------------------TipsSuitInfoCell-----------------------------
TipsSuitInfoCell = TipsSuitInfoCell or BaseClass(BaseCell)
function TipsSuitInfoCell:__init()
	self.new_color_list = {}
end

function TipsSuitInfoCell:__delete()
	self.new_color_list = {}
end

function TipsSuitInfoCell:OnFlush()
	if self.data == nil then
		self.node_list["suitcell"]:SetActive(false)
		return
	end
	self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_hunqi_index) or {}
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
	self.new_color_list = {}
	for k, v in pairs(self.current_hunyin_list_info) do
		if v.hunyin_id > 0 and self.hunyin_info[v.hunyin_id] and self.hunyin_info[v.hunyin_id][1] and self.hunyin_info[v.hunyin_id][1].hunyin_color then
			local color_index = self.hunyin_info[v.hunyin_id][1].hunyin_color
			self.new_color_list[color_index] = self.new_color_list[color_index] or 0
			self.new_color_list[color_index] = self.new_color_list[color_index] + 1
		end
	end

	if self.new_color_list[5] ~= nil and self.new_color_list[6] ~= nil then
		self.new_color_list[5] = self.new_color_list[5] + self.new_color_list[6]
	end

	local num = self.new_color_list[self.data.suit_color] or 0
	local color = num >= self.data.same_qulitily_count and TEXT_COLOR.GREEN or COLOR.LightBlue
	local color1 = num >= self.data.same_qulitily_count and TEXT_COLOR.GREEN or COLOR.WHITE
	self.node_list["TxtSuitName"].text.text = ToColorStr(string.format(Language.HunQi.TaoZhuang, self.data.same_qulitily_count), color) 
	
	self.node_list["TxtAttr_1"].text.text = string.format(Language.HunQi.AttrList[1], color1, self.data.gongji)
	self.node_list["TxtAttr_2"].text.text = string.format(Language.HunQi.AttrList[2], color1, self.data.fangyu )
	self.node_list["TxtAttr_3"].text.text = string.format(Language.HunQi.AttrList[3], color1, self.data.maxhp)
	self.node_list["TxtAttr_4"].text.text = string.format(Language.HunQi.AttrList[4], color1, self.data.mingzhong)
	self.node_list["TxtAttr_5"].text.text = string.format(Language.HunQi.AttrList[5], color1, self.data.shanbi)
	self.node_list["TxtAttr_6"].text.text = string.format(Language.HunQi.AttrList[6], color1, self.data.baoji)
	self.node_list["TxtAttr_7"].text.text = string.format(Language.HunQi.AttrList[7], color1, self.data.jianren)
	-- self.node_list["TxtAttr_8"].text.text = string.format(Language.HunQi.AttrList[8], color1, self.data.per_hunshi / 100)
	self.node_list["TxtAttr_8"].text.text = string.format(Language.HunQi.AttrList[8], color1, self.data.per_gongji / 100)
	-- self.node_list["TxtAttr_9"].text.text = string.format(Language.HunQi.AttrList[9], color1, self.data.per_fangyu / 100)
	self.node_list["TxtAttr_10"].text.text = string.format(Language.HunQi.AttrList[10], color1, self.data.per_maxhp / 100)
	self.node_list["TxtAttr_11"].text.text = string.format(Language.HunQi.AttrList[11], color1, self.data.skill_jianshang_per / 100)
	self.node_list["TxtAttr_12"].text.text = string.format(Language.HunQi.AttrList[12], color1, self.data.per_pofang / 100)
	self.node_list["TxtAttr_13"].text.text = string.format(Language.HunQi.AttrList[13], color1, self.data.shanbi_per / 100)
	self.node_list["TxtAttr_14"].text.text = string.format(Language.HunQi.AttrList[14], color1, self.data.per_mianshang / 100)

	self.node_list["AttrGroup1"]:SetActive(self.data.gongji and self.data.gongji > 0 or false)
	self.node_list["AttrGroup2"]:SetActive(self.data.fangyu and self.data.fangyu > 0 or false)
	self.node_list["AttrGroup3"]:SetActive(self.data.maxhp and self.data.maxhp > 0 or false)
	self.node_list["AttrGroup4"]:SetActive(self.data.mingzhong and self.data.mingzhong > 0 or false)
	self.node_list["AttrGroup5"]:SetActive(self.data.shanbi and self.data.shanbi > 0 or false)
	self.node_list["AttrGroup6"]:SetActive(self.data.baoji and self.data.baoji > 0 or false)
	self.node_list["AttrGroup7"]:SetActive(self.data.jianren and self.data.jianren > 0 or false)
	self.node_list["AttrGroup8"]:SetActive(self.data.per_gongji and self.data.per_gongji > 0 or false)
	self.node_list["AttrGroup8"]:SetActive(self.data.per_hunshi and self.data.per_hunshi > 0 or false)
	self.node_list["AttrGroup9"]:SetActive(false)
	self.node_list["AttrGroup10"]:SetActive(self.data.per_maxhp and self.data.per_maxhp > 0 or false)
	self.node_list["AttrGroup11"]:SetActive(self.data.skill_jianshang_per and self.data.skill_jianshang_per > 0 or false)
	self.node_list["AttrGroup12"]:SetActive(self.data.per_pofang and self.data.per_pofang > 0 or false)
	self.node_list["AttrGroup13"]:SetActive(self.data.shanbi_per and self.data.shanbi_per > 0 or false)
	self.node_list["AttrGroup14"]:SetActive(self.data.per_mianshang and self.data.per_mianshang > 0 or false)
	self.node_list["suitcell"]:SetActive(true)
end

-- function TipsSuitInfoCell:SetColorList(color_list)
-- 	self.color_list = color_list or {}
-- end
function TipsSuitInfoCell:SetCurrentHunQiIndex(index)
	self.current_hunqi_index = index or {}
	self:Flush()
end