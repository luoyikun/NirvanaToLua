GatherSoulView = GatherSoulView or BaseClass(BaseView)

function GatherSoulView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/hunqiview_prefab", "GatherSoulContent"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.soul_item_list = {}
	self.hunqi_item_list = {}
end

function GatherSoulView:ReleaseCallBack()
	for _, v in ipairs(self.soul_item_list) do
		v:DeleteMe()
	end
	self.soul_item_list = {}

	for _, v in ipairs(self.hunqi_item_list) do
		v:DeleteMe()
	end
	self.hunqi_item_list = {}

	-- if self.model then
	-- 	self.model:DeleteMe()
	-- 	self.model = nil
	-- end

	self.soul_list = nil
	self.hunqi_list = nil
	self.fight_text1 = nil
	self.fight_text2 = nil
end

function GatherSoulView:LoadCallBack()
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self.pos_attr = self.node_list["Attr"].transform.anchoredPosition
	self.pos_now_special = self.node_list["TxtNowSpecial"].transform.anchoredPosition
	self.soul_item_list = {}
	for i = 0, HunQiData.SHENZHOU_ELEMET_MAX_TYPE - 1 do
		local obj = self.node_list["SoulList"].transform:GetChild(i).gameObject
		local soul_cell = HunQiSoulItemCell.New(obj)
		soul_cell:SetIndex(i+1)
		soul_cell:SetClickCallBack(BindTool.Bind(self.ClickSoulCallBack, self))
		table.insert(self.soul_item_list, soul_cell)
	end

	self.hunqi_item_list = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_COUNT-1 do
		local obj = self.node_list["HunQiList"].transform:GetChild(i).gameObject
		local equip_cell = SoulEquipItemCell.New(obj)
		equip_cell:SetIndex(i + 1)
		equip_cell:SetClickCallBack(BindTool.Bind(self.ClickHunQiCallBack, self))
		table.insert(self.hunqi_item_list, equip_cell)
	end

	self.node_list["TitleText"].text.text = Language.HunQi.TxtTitle1
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnFire"].button:AddClickListener(BindTool.Bind(self.ClickFire, self))
	self.node_list["BtnImg"].button:AddClickListener(BindTool.Bind(self.ClickHun, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
end

function GatherSoulView:ClickSoulCallBack(cell)
	if nil == cell then
		return
	end
	cell:SetToggleState(true)
	local index = cell:GetIndex()
	if index == self.select_soul_index then
		return
	end
	self.select_soul_index = index

	self:FlushRight()
end

function GatherSoulView:ClickHunQiCallBack(cell)
	if nil == cell then
		return
	end
	cell:SetToggleState(true)
	local index = cell:GetIndex()
	if index == self.select_hunqi_index then
		return
	end
	self.select_hunqi_index = index

	self.select_soul_index = 1
	self:FlushSoulList()
	self:FlushRight()
	self:FlushModel()
end

function GatherSoulView:CloseWindow()
	self:Close()
end

function GatherSoulView:ClickFire()
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_UPLEVEL_ELEMENT, self.select_hunqi_index-1, self.select_soul_index-1)
end

function GatherSoulView:ClickHun()
	TipsCtrl.Instance:OpenItem({item_id = self.current_item_id})
end

function GatherSoulView:OpenCallBack()
	self.select_hunqi_index = 1
	self.select_soul_index = 1

	self:FlushHunQiList()
	self:FlushSoulList()
	self:FlushRight()
	self:FlushModel()

	--监听物品变化
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function GatherSoulView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function GatherSoulView:ItemDataChangeCallback(item_id)
	--炼魂物品变化
	for _, v in ipairs(HunQiData.ElementItemList) do
		if item_id == v then
			self:Flush()
			return
		end
	end
end

function GatherSoulView:FlushHunQiList()
	local hunqi_data_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_data_list then
		return
	end
	for k, v in ipairs(self.hunqi_item_list) do
		if v:GetIndex() == self.select_hunqi_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:SetData(hunqi_data_list[k])
	end
end

function GatherSoulView:FlushSoulList()
	local hunqi_data_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_data_list then
		return
	end
	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.select_hunqi_index-1)
	local color = ITEM_COLOR[color_num]
	local name_str = ToColorStr(hunqi_name, color)

	local element_level_list = hunqi_data_list[self.select_hunqi_index].element_level_list
	if nil == element_level_list then
		return
	end
	for k, v in ipairs(self.soul_item_list) do
		if v:GetIndex() == self.select_soul_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:SetData({parent_index = self.select_hunqi_index, parent_level = hunqi_data_list[self.select_hunqi_index].weapon_level, level = element_level_list[k]})
	end
end

function GatherSoulView:FlushRight()
	--刷新总属性值
	local attr_list = HunQiData.Instance:GetAllElementAttrInfo(self.select_hunqi_index)
	if nil == attr_list then
		return
	end
	self.node_list["TxtHp"].text.text = string.format(Language.HunQi.HP, attr_list.max_hp)
	self.node_list["TxtGongJi"].text.text = string.format(Language.HunQi.GongJi, attr_list.gong_ji)
	self.node_list["TxtFangYu"].text.text = string.format(Language.HunQi.FangYu, attr_list.fang_yu)
	local capability = CommonDataManager.GetCapability(attr_list)
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = capability
	end
	local special_num = string.format("%.1f", attr_list.special / 100)
	self.node_list["TxtSpecialnumber"].text.text = string.format(Language.HunQi.SpecialNumber, special_num .. "%")

	local hunqi_data_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_data_list then
		return
	end
	local select_hunqi_index = self.select_hunqi_index
	local select_soul_index = self.select_soul_index
	local element_level_list = hunqi_data_list[select_hunqi_index].element_level_list
	if nil == element_level_list then
		return
	end
	local select_soul_level = element_level_list[select_soul_index] or 0
	local attr_info = HunQiData.Instance:GetSoulAttrInfo(select_hunqi_index - 1, select_soul_index - 1, select_soul_level)
	if nil == attr_info then
		return
	end
	attr_info = attr_info[1]
	local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(select_hunqi_index - 1, select_soul_index - 1, select_soul_level + 1)
	--设置当前属性
	local attr_des = ""
	local attr_ibutte = CommonDataManager.GetAttributteNoUnderline(attr_info)
	local attr_type = ""
	local attr_num = 0
	if select_soul_level == 0 then
		if nil ~= next_attr_info then
			next_attr_info = next_attr_info[1]
			local next_attr_ibutte = CommonDataManager.GetAttributteNoUnderline(next_attr_info)
			for k, v in pairs(next_attr_ibutte) do
				if v > 0 then
					attr_type = k
					break
				end
			end
		end
	else
		for k, v in pairs(attr_ibutte) do
			if v > 0 then
				attr_type = k
				attr_num = v
				break
			end
		end
	end
	local attr_name = CommonDataManager.GetAttrName(attr_type)
	attr_des = attr_name .. "：<color=#ffffff>" .. attr_num .. "</color>"
	self.node_list["TxtAttrStr"].text.text = attr_des

	--设置当前属性战斗力
	local capability = CommonDataManager.GetCapability(attr_ibutte)
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = capability
	end

	--设置当前属性百分比
	self.node_list["TxtNowSpecial"].text.text = string.format(Language.HunQi.NowSpecial, attr_info.attr_add_per / 100 .. "%")

	if nil == next_attr_info then
		self.node_list["TxtCost"].text.text = ""
		self.node_list["TxtCost1"].text.text = ""
		self.node_list["BtnImg"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["BtnFire"], false)
		self.node_list["TxtButton"].text.text = Language.Common.YiManJi
		self.node_list["TxtUpAttr"].text.text = ""
		self.node_list["TxtNextSpecial"].text.text = ""
		self.node_list["ImgUp"]:SetActive(false)
		self.node_list["TxtNowSpecial"].transform.anchoredPosition = Vector3(self.pos_now_special.x, self.pos_now_special.y - 50, self.pos_now_special.z)
		self.node_list["Attr"].transform.anchoredPosition = Vector3(self.pos_attr.x, self.pos_attr.y - 50, self.pos_attr.z)
	else
		self.node_list["ImgUp"]:SetActive(true)
		next_attr_info = next_attr_info[1] or next_attr_info
		UI:SetButtonEnabled(self.node_list["BtnFire"], true)
		self.node_list["TxtButton"].text.text = Language.HunQi.RongHuo
		--设置下级增加属性
		local next_attr_num = next_attr_info[attr_type] or 0
		local up_attr_num = next_attr_num - attr_num
		self.node_list["TxtUpAttr"].text.text = up_attr_num

		--设置下级增加属性百分比
		local next_add_attr_info = HunQiData.Instance:GetNextAddAttrInfo(select_hunqi_index - 1, select_soul_index - 1, select_soul_level)
		if nil ~= next_add_attr_info then
			next_add_attr_info = next_add_attr_info[1]
			self.node_list["TxtNextSpecial"]:SetActive(true)
			local next_add_percent_num = string.format("%.1f", next_add_attr_info.attr_add_per / 100)
			local next_level = next_add_attr_info.element_level
			self.node_list["TxtNextSpecial"].text.text = string.format(Language.HunQi.NextSpecialAttr, next_add_percent_num .. "%", select_soul_level ,next_level)
			self.node_list["TxtNowSpecial"].transform.anchoredPosition = self.pos_now_special
			self.node_list["Attr"].transform.anchoredPosition = self.pos_attr
		else
			self.node_list["TxtNextSpecial"]:SetActive(false)
		end

		--设置消耗显示
		local cost_des = ""
		local huqi_level_limit = attr_info.huqi_level_limit
		--当魂器没有达到相应的等级
		if huqi_level_limit > hunqi_data_list[select_hunqi_index].weapon_level then
			self.node_list["BtnImg"]:SetActive(false)
			self.node_list["TxtCost1"].text.text = ""
			cost_des = string.format(Language.HunQi.NeedHunQiLevelDes, hunqi_data_list[select_hunqi_index].weapon_level, huqi_level_limit)
		else
			local item_data = attr_info.up_level_item
			local item_id = item_data.item_id or 0
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if nil == item_cfg then
				return
			end
			local item_name = item_cfg.name or ""
			local item_color = ITEM_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
			local now_num = ItemData.Instance:GetItemNumInBagById(item_id)
			local cost_num = item_data.num or 0
			local now_num_str = now_num
			if now_num < cost_num then
				now_num_str = ToColorStr(now_num, TEXT_COLOR.RED_1)
			end
			self.node_list["TxtCost"].text.text = Language.HunQi.NeedCostDes1
			cost_des = string.format(Language.HunQi.NeedCostDes1, ToColorStr(item_name, item_color), now_num_str, cost_num)
			self.current_item_id =  item_data.item_id
			self.node_list["BtnImg"]:SetActive(true)
			local bundle, asset = ResPath.GetHunQiImg("SoulIcon" .. select_soul_index)
			self.node_list["BtnImg"].image:LoadSprite(bundle, asset)

			if now_num < cost_num then
				self.node_list["TxtCost1"].text.text = "<color=#F9463B>" .. now_num .. "</color> / " .. cost_num
			else
				self.node_list["TxtCost1"].text.text = "<color=#89f201>" .. now_num .. " / " .. cost_num .. "</color>"
			end
		end
		self.node_list["TxtCost"].text.text = cost_des
	end
end

function GatherSoulView:FlushModel()
	if self.select_hunqi_index > 0 then
		local bundle, asset = ResPath.GetYiHuoImg(self.select_hunqi_index)
		self.node_list["ImgYiHuo"].image:LoadSprite(bundle, asset)
		self.node_list["NodeEffect"]:ChangeAsset(ResPath.GetHunYinEffect(HunQiData.EFFECT_PATH[self.select_hunqi_index]))
	end
end

--改变模型特效
function GatherSoulView:FlushModelEffect()
end

function GatherSoulView:OnFlush()
	self:FlushHunQiList()
	self:FlushSoulList()
	self:FlushRight()
end

function GatherSoulView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(219)
end

-------------------------------HunQiSoulItemCell------------------------------------------
HunQiSoulItemCell = HunQiSoulItemCell or BaseClass(BaseCell)
function HunQiSoulItemCell:__init()
	self.node_list["ToggleSoulItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function HunQiSoulItemCell:__delete()

end

function HunQiSoulItemCell:OnFlush()
	if nil == self.data then
		return
	end

	self.node_list["TxtLevel"].text.text = Language.HunQi.LevelText .. self.data.level

	--设置是否已激活
	UI:SetGraphicGrey(self.node_list["ImgIcon"], self.data.level <= 0)
	self.node_list["Effect"]:SetActive(self.data.level > 0)
	self.node_list["Effect1"]:SetActive(self.data.level > 0)

	--判断是否显示红点
	local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(self.data.parent_index - 1, self.index - 1, self.data.level + 1)
	if nil == next_attr_info then
		self.node_list["ImgRedPoint"]:SetActive(false)
	else
		local attr_info = HunQiData.Instance:GetSoulAttrInfo(self.data.parent_index - 1, self.index - 1, self.data.level)
		if nil == attr_info then
			return
		end
		attr_info = attr_info[1]
		if self.data.parent_level >= attr_info.huqi_level_limit then
			local up_level_item = attr_info.up_level_item
			local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
			if have_num >= up_level_item.num then
				self.node_list["ImgRedPoint"]:SetActive(true)
			else
				self.node_list["ImgRedPoint"]:SetActive(false)
			end
		else
			self.node_list["ImgRedPoint"]:SetActive(false)
		end
	end
end

function HunQiSoulItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end


-------------------------------SoulEquipItemCell------------------------------------------
SoulEquipItemCell = SoulEquipItemCell or BaseClass(BaseCell)
function SoulEquipItemCell:__init()
	self.node_list["ToggleHunQiItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function SoulEquipItemCell:__delete()

end

function SoulEquipItemCell:OnFlush()
	if nil == self.data then
		return
	end

	self.node_list["TxtLevel"].text.text = Language.HunQi.LevelText .. self.data.weapon_level

	--设置图标
	local model_res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.index - 1)
	local param = model_res_id - 17000
	local res_id = "HunQi_" .. param
	local asset, bunble = ResPath.GetHunQiImg(res_id)
	self.node_list["ImgIcon"].image:LoadSprite(asset, bunble)

	--设置是否已激活
	UI:SetGraphicGrey(self.node_list["ImgIcon"], self.data.weapon_level <= 0)

	--判断是否显示红点
	local element_level_list = self.data.element_level_list
	local is_show = false
	for k, v in ipairs(element_level_list) do
		local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(self.index - 1, k - 1, v + 1)
		if next_attr_info then
			local attr_info = HunQiData.Instance:GetSoulAttrInfo(self.index - 1, k - 1, v)
			attr_info = attr_info[1]
			--判断等级是否足够
			if attr_info.huqi_level_limit <= self.data.weapon_level then
				local up_level_item = attr_info.up_level_item
				local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
				if have_num >= up_level_item.num then
					is_show = true
					break
				end
			end
		end
	end
	self.node_list["ImgRedPoint"]:SetActive(is_show)
end

function SoulEquipItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end