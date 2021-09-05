TipsEquipAttrView = TipsEquipAttrView or BaseClass(BaseView)

function TipsEquipAttrView:__init()
	self.ui_config = {{"uis/views/tips/attrtips_prefab", "EquipAttrView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.attr_list = {}
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsEquipAttrView:__delete()
end

function TipsEquipAttrView:ReleaseCallBack()
	for k, v in pairs(self.attr_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.attr_list = {}
	self.fight_text = nil
end

function TipsEquipAttrView:CloseCallBack()
	self.curr_count = 1
	self.attr_data_tab = nil
	for k, v in pairs(self.attr_list) do
		v.gameObject:SetActive(false)
	end
end

function TipsEquipAttrView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["NoAttrBtn"].button:AddClickListener(BindTool.Bind(self.ClickOpenForge, self))
	self.node_list["FightPower"]:SetActive(false)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"], "FightPower3")

	for i = 1, self.node_list["ObjGroup"].transform.childCount do
		self.attr_list[i] = self.node_list["ObjGroup"].transform:FindHard("Attr" .. i)
		self.attr_list[i].gameObject:SetActive(false)
	end
end

function TipsEquipAttrView:SetData(attr_type, attr_data_tab)
	self.attr_type = attr_type
	self.curr_count = 1
	self.attr_data_tab = attr_data_tab
	self:Flush()
end

function TipsEquipAttrView:OnFlush()
	if self.attr_type == "yongheng_attr" then
		self:SetYonghengAttr()
	elseif self.attr_type == "deity_suit_attr" then
		self:SetDeitySuitAttr()
	elseif self.attr_type == "baizhan_suit_attr" then
		self:SetBaiZhanSuitAttr()		
	elseif self.attr_type == "red_suit_collect_attr" then
		self:SetRedSuitCollectAttr()
	elseif self.attr_type == "medal_attr" then
		self:SetMedalAttr()
	elseif self.attr_type == "check_attr" then
		self:SetCheckAppearanceAttr()
	elseif self.attr_type == "douqi_suit_attr" then
		self:SetDouqiSuitAttr()
	end
end

function TipsEquipAttrView:SetText(str)
	local obj = self.attr_list[self.curr_count].gameObject
	obj:GetComponent(typeof(UnityEngine.UI.Text)).text = str
	obj:SetActive(true)
	self.curr_count = self.curr_count + 1
end

-- 根据属性配置获得名字和数值
function TipsEquipAttrView:GetAttrNameAndValue(attr_tab)
	local attr_sequence = {
		["gongji"] = 1, ["gong_ji"] = 1,
		["fangyu"] = 2, ["fang_yu"] = 2,
		["hp"] = 3, ["max_hp"] = 3, ["maxhp"] = 3, 
		["mingzhong"] = 4, ["ming_zhong"] = 4,
		["shanbi"] = 5, ["shan_bi" ]= 5,
		["baoji"] = 6, ["bao_ji"] = 6,
		["jianren"] = 7, ["jian_ren"] = 7,
	}
	local total_attr = {}
	local count = 1
	for k, v in pairs(attr_tab) do
		-- if v > 0 then
		if attr_sequence[k] then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(k)
			total_attr[count].value = math.ceil(v)
			total_attr[count].sequence = attr_sequence[k]
			count = count + 1
		end
	end
	table.sort(total_attr, SortTools.KeyLowerSorter("sequence"))
	return total_attr
end

-- 设置属性
function TipsEquipAttrView:SetAttrObjList(attr_list)
	for k, v in pairs(attr_list) do
		if v then
			local str = ToColorStr(v.name, TEXT_COLOR.WHITE) .. ToColorStr(": ", TEXT_COLOR.WHITE) .. v.value
			self:SetText(str)
			-- self:SetText("")
		end
	end
end

-- 永恒/太极属性
function TipsEquipAttrView:SetYonghengAttr()
	self.node_list["AttrName"].text.text = Language.Player.AttrBtnText[1]

	local attr_tab, yongheng_suit = ForgeData.Instance:GetYonghengAllAttr()
	local attr_list = self:GetAttrNameAndValue(attr_tab)
	if not next(attr_list) and not yongheng_suit then
		self.node_list["NoAttrText"]:SetActive(true)
		self.node_list["NoAttrBtn"]:SetActive(false)
		return
	else
		self.node_list["NoAttrText"]:SetActive(false)
		self.node_list["NoAttrBtn"]:SetActive(false)
	end
	local fight_power = CommonDataManager.GetCapabilityCalculation(attr_tab)
	self.node_list["FightPower"]:SetActive(true)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end

	self:SetAttrObjList(attr_list)
	if yongheng_suit then
		local str1 = string.format(Language.Forge.YonghengCurPercent1, yongheng_suit.hxyj / 100)
		local str2 = string.format(Language.Forge.YonghengCurPercent2, yongheng_suit.hxyj_hurt_per / 100)
		self:SetText(str1)
		self:SetText(str2)
	else
		local str1 = string.format(Language.Forge.YonghengCurPercent1, 0)
		local str2 = string.format(Language.Forge.YonghengCurPercent2, 0)
		self:SetText(str1)
		self:SetText(str2)
	end
end

-- 百战属性
function TipsEquipAttrView:SetBaiZhanSuitAttr()
	self.node_list["FightPower"]:SetActive(false)
	self.node_list["NoAttrBtn"]:SetActive(false)
	self.node_list["NoAttrText"]:SetActive(true)
	self.node_list["AttrName"].text.text = Language.Player.BaiZhanAttrBtnText

	local baizhan_order_count_list = ForgeData.Instance:GetBaiZhanOrderCountListAll()
	local max_order = ForgeData.Instance:GetBaiZhanListMaxOrder()
	for i = 0, max_order do
		if baizhan_order_count_list[i] then
			local cfg = ForgeData.Instance:GetBaiZhanAttrListByOrder(i)
			local name = ForgeData.Instance:GetBaiZhanNameListByOrder(i)
			if cfg and name then
				self.node_list["NoAttrText"]:SetActive(false)

				local suit_had_count, suit_total_count = 0, 0
				if baizhan_order_count_list[i] then
					suit_had_count = baizhan_order_count_list[i]
				end
				if cfg and cfg[#cfg] and cfg[#cfg].same_order_num then
					suit_total_count = cfg[#cfg].same_order_num
				end
				local suit_count_str = ""
				if suit_had_count > 0 and suit_total_count > 0 then
					suit_count_str = "(" .. suit_had_count .. "/" .. suit_total_count .. ")"
				end
				local str = ToColorStr(name .. suit_count_str, TEXT_COLOR.ORANGE_5)
				if cfg and cfg[1] and cfg[1].same_order_num and baizhan_order_count_list[i] >= cfg[1].same_order_num then
					self:SetText(str)
				end
				
				for k, v in ipairs(cfg) do
					local suit_str = string.format(Language.Forge.SuitCount, v.same_order_num)
					local suit_str2 = ToColorStr(suit_str, "#00000000")
					for k2, v2 in pairs(Language.Forge.BaiZhanSuitShowType) do
						if v[v2] and v[v2] > 0 then
							local suit_attr = Language.Forge.BaiZhanSuitShowAttr[v2]
							local space_str = ""
							if v.same_order_num < 10 then
								space_str = ToColorStr("0", "#00000000")
							end							
							if string.find(v2, "per") then
								local str = ""
								if suit_str then
									str = suit_str .. space_str .. string.format(suit_attr, ToColorStr((v[v2] / 100 ).. "%", TEXT_COLOR.GREEN))
									suit_str = nil
								else
									str = suit_str2 .. space_str .. string.format(suit_attr, ToColorStr((v[v2] / 100 ).. "%", TEXT_COLOR.GREEN))
								end
								if baizhan_order_count_list[i] >= v.same_order_num then
									self:SetText(str)
								end
							else
								local str = ""
								if suit_str then
									str = suit_str .. space_str .. string.format(suit_attr, ToColorStr(v[v2], TEXT_COLOR.GREEN))
									suit_str = nil
								else
									str = suit_str2 .. space_str .. string.format(suit_attr, ToColorStr(v[v2], TEXT_COLOR.GREEN))
								end
								if baizhan_order_count_list[i] >= v.same_order_num then
									self:SetText(str)
								end
							end
						end
					end
				end
				if cfg and cfg[1] and cfg[1].same_order_num and baizhan_order_count_list[i] >= cfg[1].same_order_num then
					self:SetText(" ")
				end	
			end
		end
	end
end

-- 套装属性
function TipsEquipAttrView:SetDeitySuitAttr()
	self.node_list["FightPower"]:SetActive(false)
	self.node_list["AttrName"].text.text = Language.Player.AttrBtnText[4]
	local fangyu_attr, gongji_attr, zhizun_attr = ForgeData.Instance:GetDeitySuitAllAttr()
	if not next(fangyu_attr) and not next(gongji_attr) and not next(zhizun_attr) then
		self.node_list["NoAttrText"]:SetActive(true)
		self.node_list["NoAttrBtn"]:SetActive(true)
		return
	else
		self.node_list["NoAttrText"]:SetActive(false)
		self.node_list["NoAttrBtn"]:SetActive(false)
	end

	-- 防御属性
	local had_fangyu_suit = {}
	for k, v in pairs(fangyu_attr) do
		if not had_fangyu_suit["type" .. v.suit_index .. "order" .. v.equip_order] then
			had_fangyu_suit["type" .. v.suit_index .. "order" .. v.equip_order] = true
			local str = ToColorStr(Language.Forge.SuitTypeName4[v.suit_index] .. Language.Forge.SuitOrderName[v.equip_order], TEXT_COLOR.ORANGE_5)
			self:SetText(str)
		end

		local suit_str = string.format(Language.Forge.SuitCount, v.same_order_num)
		local suit_str2 = ToColorStr(suit_str, "#00000000")
		-- self:SetText("   " .. str)

		for k2, v2 in pairs(Language.Forge.SuitShowType) do
			if v[v2] and v[v2] > 0 then
				local suit_attr = Language.Forge.SuitShowAttr[v2]
				if string.find(v2, "per") then
					local str = ""
					if suit_str then
						str = suit_str .. " " .. string.format(suit_attr, ToColorStr((v[v2] / 100 ).. "%", TEXT_COLOR.GREEN))
						suit_str = nil
					else
						str = suit_str2 .. " " .. string.format(suit_attr, ToColorStr((v[v2] / 100 ).. "%", TEXT_COLOR.GREEN))
					end
					self:SetText(str)
				else
					local str = ""
					if suit_str then
						str = suit_str .. " " .. string.format(suit_attr, ToColorStr(v[v2], TEXT_COLOR.GREEN))
						suit_str = nil
					else
						str = suit_str2 .. " " .. string.format(suit_attr, ToColorStr(v[v2], TEXT_COLOR.GREEN))
					end
					self:SetText(str)
				end
			end
		end
		self:SetText(" ")
	end

	--攻击属性
	local had_gongji_suit = {}
	for k, v in pairs(gongji_attr) do
		if not had_gongji_suit[v.suit_index] then
			had_gongji_suit[v.suit_index] = true
			local str = ToColorStr(Language.Forge.SuitTypeName4[v.suit_index] .. Language.Forge.ShouShiSuitName, TEXT_COLOR.ORANGE_5)
			self:SetText(str)
		end

		local suit_str = string.format(Language.Forge.SuitCount, v.same_order_num)
		local suit_str2 = ToColorStr(suit_str, "#00000000")
		-- self:SetText("   " .. str)

		for k2, v2 in pairs(Language.Forge.SuitShowType) do
			local suit_attr = Language.Forge.SuitShowAttr[v2]
			if v[v2] and v[v2] > 0 then
				if string.find(v2, "per") then
					local str = ""
					if suit_str then
						str = suit_str .. " " .. string.format(suit_attr, ToColorStr((v[v2] / 100) .. "%", TEXT_COLOR.GREEN))
						suit_str = nil
					else
						str = suit_str2 .. " " .. string.format(suit_attr, ToColorStr((v[v2] / 100) .. "%", TEXT_COLOR.GREEN))
					end
					self:SetText(str)
				else
					local str = ""
					if suit_str then
						str = suit_str .. " " .. string.format(suit_attr, ToColorStr(v[v2], TEXT_COLOR.GREEN))
						suit_str = nil
					else
						str = suit_str2 .. " " .. string.format(suit_attr, ToColorStr(v[v2], TEXT_COLOR.GREEN))
					end
					self:SetText(str)
				end
			end
		end
		self:SetText(" ")
	end

	-- 至尊属性
	for k, v in pairs(zhizun_attr) do
		local str = Language.Forge.ZhizunSuit .. "(2/2)"
		local str2 = string.format(Language.Forge.ZhizunSuitAttr2, ToColorStr(v.show_zengshang / 100 .. "%", TEXT_COLOR.WHITE))
		self:SetText(str)
		self:SetText("       " .. str2)
	end
end

-- 红装收集总属性
function TipsEquipAttrView:SetRedSuitCollectAttr()
	if nil == self.attr_data_tab or not next(self.attr_data_tab) then
		self.node_list["NoAttrText"]:SetActive(true)
		self.node_list["NoAttrBtn"]:SetActive(false)
		return
	else
		self.node_list["NoAttrText"]:SetActive(false)
		self.node_list["NoAttrBtn"]:SetActive(false)
	end

	self.node_list["AttrName"].text.text = Language.SuitCollect.EquipAttrTitle
	local attr_list = self:GetAttrNameAndValue(self.attr_data_tab)
	self:SetAttrObjList(attr_list)

	local fight_power = CommonDataManager.GetCapability(self.attr_data_tab)
	self.node_list["FightPower"]:SetActive(true)

	local collect_cfg = SuitCollectionData.Instance:GetRedItemType(self.attr_data_tab.seq)
	local title_power = 0
	if collect_cfg then
		local equip_list = SuitCollectionData.Instance:GetRedEquipCollect(self.attr_data_tab.seq)
		local star_count = 0
		for k, v in pairs(equip_list) do
			if v and v.param and v.param.xianpin_type_list and next(v.param.xianpin_type_list) then
				star_count = star_count + #v.param.xianpin_type_list
			end
		end
		local percent = collect_cfg.star_add_attr_percent * math.floor(star_count)
		local desc = string.format(Language.SuitCollect.SuitAddPercent2, percent)
		self:SetText(desc)

		local star_info = SuitCollectionData.Instance:GetRedStarsInfo(self.attr_data_tab.seq)
		local active_equip_num = star_info and star_info.item_count or 0
		local is_huanxing = SuitCollectionData.Instance:GetRedIsActive(self.attr_data_tab.seq) or 0
		local active_need_count = SuitCollectionData.Instance:GetRedActiveSuitCount() or 0
		if active_need_count <= active_equip_num and is_huanxing == 1 then
			local title_cfg = TitleData.Instance:GetTitleCfg(self.attr_data_tab.reward_title_id)
			local title_attr_list = CommonDataManager.GetAttributteNoUnderline(title_cfg)
			title_attr_list = CommonDataManager.MulAttributeNoUnderline(title_attr_list, 1 + (percent / 100))
			title_power = CommonDataManager.GetCapability(title_attr_list)
		end
	end
	self.fight_text.text.text = (fight_power + title_power)
end

-- 灵印总属性
function TipsEquipAttrView:SetMedalAttr()
	if nil == self.attr_data_tab or not next(self.attr_data_tab) then
		self.node_list["NoAttrText"]:SetActive(true)
		return
	else
		self.node_list["NoAttrText"]:SetActive(false)
	end

	self.node_list["AttrName"].text.text = Language.BaoJu.MedalAttrTital
	local attr_list = self:GetAttrNameAndValue(self.attr_data_tab)
	self:SetAttrObjList(attr_list)
	local fight_power = CommonDataManager.GetCapabilityCalculation(self.attr_data_tab)
	self.node_list["FightPower"]:SetActive(true)
	self.fight_text.text.text = fight_power
end

-- 查看角色外观属性
function TipsEquipAttrView:SetCheckAppearanceAttr()
	self.node_list["AttrName"].text.text = Language.Tip.JiChuShuXing2

	local attr_tab = {}
	for k, v in pairs(self.attr_data_tab) do
		if k ~= "move_speed" and tonumber(v) > 0 then
			attr_tab[k] = v
		end
	end
	local attr_list = self:GetAttrNameAndValue(attr_tab)
	self:SetAttrObjList(attr_list)
end

-- 斗气套装属性
function TipsEquipAttrView:SetDouqiSuitAttr()
	self.node_list["FightPower"]:SetActive(false)
	self.node_list["AttrName"].text.text = Language.Douqi.DouqiSuitTitle

	local suit_attr_data = DouQiData.Instance:GetSuitAllAttr()
	if nil == suit_attr_data or not next(suit_attr_data) then return end

	local sort_attr_data = {}
	local temp_grade_tab = {}
	for k, v in pairs(suit_attr_data) do
		if not temp_grade_tab[v.suit_order] then
			temp_grade_tab[v.suit_order] = true
			table.insert(sort_attr_data, v)
		end
	end

	table.sort(sort_attr_data, function (a, b)
		return a.suit_order > b.suit_order
	end)

	for k, v in pairs(sort_attr_data) do
		local total_suit_attr_cfg = DouQiData.Instance:GetDouqiEquipClientSuitAttr(v.suit_order)
		if total_suit_attr_cfg then
			local douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(v.suit_order)
			local suit_name = douqi_cfg and (douqi_cfg.grade_name .. Language.Douqi.TaoZhuang) or ""
			self:SetText(ToColorStr(string.format("【%s】", suit_name), TEXT_COLOR.ORANGE_5))
			for k2, v2 in pairs(total_suit_attr_cfg) do
				if v.suit_type >= v2.need_count then
					local need_count_text = string.format(Language.Douqi.SuitCount, v2.need_count)

					for k3, v3 in pairs(Language.Douqi.DouqiSuitShowType) do
						if v2[v3] and v2[v3] > 0 then
							local attr_name = Language.Douqi.DouqiSuitShowAttr[v3]
							if string.find(v3, "per") then
								local temp_attr = string.format("%s:%s%%", attr_name, v2[v3] / 100)
								self:SetText(ToColorStr(need_count_text .. temp_attr, TEXT_COLOR.GREEN))
							else
								local temp_attr = string.format("%s:%s", attr_name, v2[v3])
								self:SetText(ToColorStr(need_count_text .. temp_attr, TEXT_COLOR.GREEN))
							end
						end
						if is_add_text then
							need_count_text = ToColorStr(need_count_text, "#00000000")
							is_add_text = false
						end
					end
					self:SetText("")
				end
			end
		end
	end
end

function TipsEquipAttrView:CloseWindow()
	self:Close()
end

function TipsEquipAttrView:ClickOpenForge()
	self:Close()
	ViewManager.Instance:Open(ViewName.Forge, TabIndex.forge_deity_suit)
end