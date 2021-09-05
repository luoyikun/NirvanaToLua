TipLuoShu = TipLuoShu or BaseClass(BaseView)

local MAXSTARLEVEL = 200
function TipLuoShu:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/player_prefab", "LuoShuUpgradeTip"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

end

function TipLuoShu:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(500, 400, 0)
	self.node_list["Txt"].text.text = Language.Player.LuoShuUpgrade
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpgrade, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
	self.item:SetData()
end

function TipLuoShu:__delete()

end

function TipLuoShu:ReleaseCallBack()
	if nil ~= self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function TipLuoShu:SetSelectInfo(select_info)
	self.select_info = select_info
	self:Flush()
end

function TipLuoShu:OnFlush(param_t)
	if nil == self.select_info then
		return
	end
	self.item:SetData({item_id = self.select_info.item_id_prof})
	local item_cfg = ItemData.Instance:GetItemConfig(self.select_info.item_id)

	local now_level = LuoShuData.Instance:GetLuoShuStarCount(0, self.select_info.seq, self.select_info.index) or -1
	-- self.node_list["TxtName"].text.text = item_cfg.name
	if now_level >= 0 then
		self.node_list["TxtName"].text.text = item_cfg.name .. " lv " .. (now_level + 1)
	else
		self.node_list["TxtName"].text.text = item_cfg.name .." ".. Language.Common.NoActivate
	end

	local other = ConfigManager.Instance:GetAutoConfig("heshen_luoshu_cfg_auto").other

	UI:SetButtonEnabled(self.node_list["BtnUpgrade"], now_level < other[1].max_star_level)

	local item_count = ItemData.Instance:GetItemNumInBagById(self.select_info.item_id_prof)
	local next_data_list = LuoShuData.Instance:GetHeShenLuoShuAllDataByTypeAndSeq(true)
	local need_num = next_data_list[self.select_info.index + 1].consume_jinghua
	if LuoShuData.Instance:GetHeShenLuoShuDataByIndex(self.select_info.index) == -1 then
		need_num = 1
	end
	local str = ""
	local color = item_count >= need_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4
	str = now_level >= other[1].max_star_level and "-- / --" or string.format(ToColorStr(item_count, color)  .. ToColorStr("/" .. need_num, TEXT_COLOR.GREEN_4))
	self.node_list["TxtNextUse"].text.text = str

	if now_level < 0 then
		self.node_list["TxtGrayBtn"].text.text = Language.Player.Activate
	elseif now_level >= MAXSTARLEVEL then
		self.node_list["TxtGrayBtn"].text.text = Language.Common.YiManJi
	else
		self.node_list["TxtGrayBtn"].text.text = Language.Player.UpGrade
	end

	local add_attr_list = {}
	for i = 1, 3 do
		self.node_list["NextAttrs".. i]:SetActive(false)
	end
	local add_attribute = LuoShuData.Instance:GetHeShenLuoShuSingleAttr(self.select_info.index, true)
	add_attribute = CommonDataManager.GetOrderAttributte(add_attribute)
	if nil ~= add_attribute and nil ~= next(add_attribute) then
		local attr_num_2 = 0
		for k,v in pairs(add_attribute) do
			if v.value > 0 then
				table.insert(add_attr_list, v.key)
				attr_num_2 = attr_num_2 + 1
				self.node_list["NextAttrs".. attr_num_2]:SetActive(true)
				self.node_list["TxtNextNum" .. attr_num_2]:SetActive(true)
				self.node_list["TxtNextNum" .. attr_num_2].text.text = v.value
			end
		end
	end
	local single_attr = LuoShuData.Instance:GetHeShenLuoShuSingleAttr(self.select_info.index)
	single_attr = CommonDataManager.GetOrderAttributte(single_attr)
	local attr_num = 0
	local attr_num_3 = 0
	for k,v in pairs(single_attr) do
		if #add_attr_list > 0 then
			for k2,v2 in pairs(add_attr_list) do
				if v.key == v2 then
					attr_num_3 = attr_num_3 + 1
					local attr_name = Language.Common.AttrName[v2]
					self.node_list["TxtAttr" .. attr_num_3]:SetActive(true)
					self.node_list["TxtAttr" .. attr_num_3].text.text = attr_name .. ":"
					self.node_list["TxtNum" .. attr_num_3]:SetActive(true)
					self.node_list["TxtNum" .. attr_num_3].text.text = v.value
				end
			end
		end
		if v.value > 0 then
			attr_num = attr_num + 1
			local attr_name = Language.Common.AttrName[v.key]
			self.node_list["TxtAttr" .. attr_num]:SetActive(true)
			self.node_list["TxtAttr" .. attr_num].text.text = attr_name .. ":"
			self.node_list["TxtNum" .. attr_num]:SetActive(true)
			self.node_list["TxtNum" .. attr_num].text.text = v.value
		end
	end
end

function TipLuoShu:OnClickUpgrade()
	if nil == self.select_info then
		return
	end
	local now_level = LuoShuData.Instance:GetLuoShuStarCount(0, self.select_info.seq, self.select_info.index) or -1
	if now_level < 0 then
		LuoShuCtrl.Instance:SendHeShenLuoShuReq(HESHENLUOSHU_REQ_TYPE.HESHENLUOSHU_REQ_TYPE_ACTIVATION, self.select_info.item_id)
	else
		LuoShuCtrl.Instance:SendHeShenLuoShuReq(HESHENLUOSHU_REQ_TYPE.HESHENLUOSHU_REQ_TYPE_UPGRADELEVEL, self.select_info.item_id)
	end
	-- self:Close()
end
