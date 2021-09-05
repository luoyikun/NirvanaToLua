TipsTotalAttrView = TipsTotalAttrView or BaseClass(BaseView)

function TipsTotalAttrView:__init()
	self.ui_config = {{"uis/views/tips/attrtips_prefab", "TotalAttrTips"}}
	self.view_layer = UiLayer.Pop

	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsTotalAttrView:LoadCallBack()
	self.node_list["BtnBlock"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BTNClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.fight_text_curr = CommonDataManager.FightPower(self, self.node_list["TxtFightpowerCur"], "FightPower3")
	self.fight_text_next = CommonDataManager.FightPower(self, self.node_list["TxtFightpowerNext"], "FightPower3")
end

function TipsTotalAttrView:ReleaseCallBack()
	self.fight_text_curr = nil
	self.fight_text_next = nil
end

function TipsTotalAttrView:CloseWindow()
	self:Close()
end

function TipsTotalAttrView:CloseCallBack()
	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
end

function TipsTotalAttrView:OpenCallBack()
	self:Flush()
end

function TipsTotalAttrView:SetTotalLevelName(total_level_name)
	self.total_level_name = total_level_name or ""
end

function TipsTotalAttrView:SetTitleName(title_name)
	self.title_str = title_name or ""
end

function TipsTotalAttrView:SetNowLevel(level)
	self.now_level = level or ""
end

function TipsTotalAttrView:SetAttrList(list)
	self.attr_list = list or {}
end

function TipsTotalAttrView:SetNextAttrList(list)
	self.next_attr_list = list or {}
end

function TipsTotalAttrView:GetAttrDes(attr_list)
	local attr_des = ""

	local is_attr_ibutte = false		--是否进阶属性
	for k, v in pairs(attr_list) do
		if CommonDataManager.GetAdvanceAttrName(k) ~= "nil" then
			is_attr_ibutte = true
			break
		end
	end

	--生成对应属性表
	local attribute = {}
	if is_attr_ibutte then
		attribute = CommonDataManager.GetAdvanceAttributteByClass(attr_list)
	else
		attribute = CommonDataManager.GetAttributteNoUnderline(attr_list)
	end

	--开始生成文本
	for k, v in pairs(attribute) do
		local attr_name = ""
		local temp_attr_des = ""

		if v > 0 then
			if is_attr_ibutte then
				attr_name = CommonDataManager.GetAdvanceAttrName(k)
				temp_attr_des = attr_name .. ": " .. ToColorStr(v/100, TEXT_COLOR.GRAY_WHITE) .. "%"
			else
				attr_name = CommonDataManager.GetAttrName(k)			--先获取属性名
				temp_attr_des = attr_name .. ": " .. ToColorStr(v, TEXT_COLOR.GRAY_WHITE)
			end
			if attr_des == "" then
				attr_des = temp_attr_des
			else
				attr_des = attr_des .. "\n" .. temp_attr_des
			end
		end
	end

	attr_des = attr_des == "" and Language.Common.No or attr_des
	return attr_des
end

function TipsTotalAttrView:GetNextAttrDes(attr_list, is_next)
	local total_level = attr_list.total_level or attr_list.total_strength_level or attr_list.total_star or attr_list.shen_level or attr_list.level or attr_list.total_stone_level or 0

	local total_level_name = self.total_level_name ~= "" and self.total_level_name or Language.Forge.AllTotalLevel
	local suit_name = total_level_name
	local total_level = ToColorStr(string.format(Language.Activity.XXLevel, total_level), TEXT_COLOR.LOWBLUE)
	local now_level = ToColorStr(string.format(Language.Activity.XXLevel, self.now_level), TEXT_COLOR.RED)
	local total_str = ""
	if is_next then
		total_str = "(".. now_level .. "/" .. total_level .. ")"
	else
		now_level = ToColorStr(string.format(Language.Activity.XXLevel, self.now_level), TEXT_COLOR.LOWBLUE)
		total_str = "(" .. now_level .. ")"
	end
	return total_level_name, total_str
end

function TipsTotalAttrView:OnFlush()
	self.node_list["TxtTitleName"].text.text = self.title_str
	local havenext = false
	if next(self.next_attr_list) then
		havenext = true
		self.node_list["PanelShowNext"]:SetActive(havenext)
	else
		havenext =false
		self.node_list["PanelShowNext"]:SetActive(havenext)
	end
	local havenow = false
	if next(self.attr_list) then
		havenow = true
		self.node_list["PanelShowNow"]:SetActive(havenow)
	else
		havenow = false
		self.node_list["PanelShowNow"]:SetActive(havenow)
	end
	self.node_list["ImgArrow"]:SetActive(havenow and havenext)

	self:SetTotalLevelName(self.attr_list.name)
	--设置当前套装等级

	local now_total_des = ForgeData.Instance:GetTotalLevelDes(self.attr_list, nil, self.total_level_name, self.now_level)
	self.node_list["TxtCurTotalDes"].text.text = now_total_des
	--设置当前套装属性
	self:SetCurAttValue()
	local now_power = CommonDataManager.GetCapabilityCalculation( self.attr_list )
	if self.fight_text_curr and self.fight_text_curr.text then
		self.fight_text_curr.text.text = now_power
	end

	if next(self.next_attr_list) then
		--设置下级套装等级
		self:SetTotalLevelName(self.next_attr_list.name)
		local next_total_des, level_des = self:GetNextAttrDes(self.next_attr_list, true)
		self.node_list["TxtNextTotalDes"].text.text = next_total_des .. level_des
		local next_power = CommonDataManager.GetCapabilityCalculation( self.next_attr_list )
		if self.fight_text_next and self.fight_text_next.text then
			self.fight_text_next.text.text = next_power
		end

		--设置下级套装属性
		self:SetNextAttValue()
	end
end

function TipsTotalAttrView:SetCurAttValue()
	self.node_list["TxtCurhp"].text.text = string.format(Language.Marriage.Hp, self.attr_list.maxhp)
	self.node_list["TxtCurgongji"].text.text = string.format(Language.Marriage.GoJi, self.attr_list.gongji)
	self.node_list["TxtCurfangyu"].text.text = string.format(Language.Marriage.FangYu, self.attr_list.fangyu)
end

function TipsTotalAttrView:SetNextAttValue()
	self.node_list["TxtNextHp"].text.text = string.format(Language.Marriage.Hp, self.next_attr_list.maxhp)
	self.node_list["TxtNextGongji"].text.text = string.format(Language.Marriage.GoJi, self.next_attr_list.gongji)
	self.node_list["TxtNextFangyu"].text.text = string.format(Language.Marriage.FangYu, self.next_attr_list.fangyu)
end