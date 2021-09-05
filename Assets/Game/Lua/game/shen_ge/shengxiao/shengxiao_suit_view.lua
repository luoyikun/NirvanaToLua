ShengXiaoSuitView = ShengXiaoSuitView or BaseClass(BaseView)

ShengXiaoSuitView.SuitMaxLevel	= 5 									--套装最大等级
function ShengXiaoSuitView:__init()
	self.ui_config = {{"uis/views/shengxiaoview_prefab", "ShengXiaoSuitView"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.open_index = 0

	self.current_all_suit = {}
	self.cell_list = {}
end

function ShengXiaoSuitView:__delete()
	self.current_all_suit = {}
	self.cell_list = {}
end

function ShengXiaoSuitView:LoadCallBack()
	-- self.content = self.node_list["Content"]
	self.cell_list = {}
	local count_orange = 0
	local count_red = 0
	self.current_all_suit = ShengXiaoData.Instance:GetShengXiaoSuitCfgByIndex(self.open_index)
	for k, v in pairs(self.current_all_suit) do
		if v.suit_color == 4 then
			count_orange = count_orange + 1
		elseif v.suit_color == 5 then
			count_red = count_red + 1
		end
	end

	for i = 1, 2 do
		local index = i
		local res_async_loader = AllocResAsyncLoader(self, "loader_" .. index)
		res_async_loader:Load("uis/views/hunqiview_prefab", "suitItem", nil, function (prefab)
			if not prefab then
				return 
			end
			local count = index == 1 and count_orange or count_red
			for i = 1, count do
				local obj = ResMgr:Instantiate(prefab)
				local cell = EquipSuitInfoCell.New(obj.gameObject)
				cell:SetInstanceParent(self.node_list["Content" .. index], false)
				local data = index == 1 and self.current_all_suit[i] or self.current_all_suit[i + count_orange]
				cell:SetData(data)
				-- cell:SetData(self.current_all_suit[i])
				table.insert(self.cell_list, cell)
			end
			self:Flush()
		end)
	end


	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.color_list = {}
	for i = 0, 4 do
		table.insert(self.color_list, self.node_list["TxtColor" .. i])
	end
end

function ShengXiaoSuitView:ShowIndexCallBack()
	self:Flush()
end

-- 销毁前调用
function ShengXiaoSuitView:ReleaseCallBack()
	for k,v in pairs(self.color_list) do
		v = nil
	end
	self.color_list = {}
	self.suit_level = 0

	for _, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.content = nil
end

-- 打开后调用
function ShengXiaoSuitView:OpenCallBack()
	self.suit_level = ShengXiaoSuitView.SuitMaxLevel
	local equip_list = ShengXiaoData.Instance:GetEquipLevelListByindex(self.open_index)
	if equip_list == nil or next(equip_list) == nil then return end

	local hunyin_color = 0
	local hunyin_id = 0
	for k,v in pairs(equip_list) do
		if k < 6 then
			if v > 0 then
				local item_cfg, big_type = ItemData.Instance:GetItemConfig(v)
				local item_name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
				-- local txt = string.format(Language.HunQi.TxtColor, Language.HunYinSuit["color_" .. item_cfg.color], item_cfg.name)
				self.color_list[k].text.text = item_name
				hunyin_color = item_cfg.color
			else
				hunyin_color = 0
				self.color_list[k].text.text = string.format(Language.HunQi.TxtColor, Language.HunYinSuit.color_0, Language.ShengXiao.EquipName[k])
			end
			if self.suit_level > hunyin_color then
				self.suit_level = hunyin_color
			end
		end
	end

	self.current_all_suit = ShengXiaoData.Instance:GetShengXiaoSuitCfgByIndex(self.open_index)
end

function ShengXiaoSuitView:OnFlush()
	local equip_list = ShengXiaoData.Instance:GetEquipLevelListByindex(self.open_index)
	if equip_list == nil or next(equip_list) == nil then return end
	self.new_color_list = {}
	for k, v in pairs(equip_list) do
		if v > 0 then
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v)
			local color_index = item_cfg.color
			if color_index == 6 then   -- 如果是粉色装备，这里按照红色装备处理
				color_index = 5
			end
			self.new_color_list[color_index] = self.new_color_list[color_index] or 0
			self.new_color_list[color_index] = self.new_color_list[color_index] + 1
		end
	end

	self.current_all_suit = ShengXiaoData.Instance:GetShengXiaoSuitCfgByIndex(self.open_index)
	for k, v in pairs(self.cell_list) do
		-- v:SetColorList(self.new_color_list)
		v:SetData(self.current_all_suit[k])
	end

	local has_active_list = {}
	local suit_name_and_color = string.format(Language.HunQi.WeiJiHuoAttr, Language.HunYinSuit["color_txt"])
	for k, v in pairs(self.current_all_suit) do
		if self.new_color_list[v.suit_color] and self.new_color_list[v.suit_color] >= v.need_count then
			table.insert(has_active_list, v)
		end
	end
	if #has_active_list > 0 then
		local cfg = has_active_list[#has_active_list]
		if cfg then
			suit_name_and_color = string.format(Language.HunQi.YiJHuoAttr, Language.HunYinSuit["color_" .. cfg.suit_color], cfg.name)
			self.node_list["TxtSuitLevel"].text.text = suit_name_and_color
		end
	end
	self.node_list["TxtSuitLevel"].text.text = suit_name_and_color

	local count_orange = 0
	local count_red = 0
	self.current_all_suit = ShengXiaoData.Instance:GetShengXiaoSuitCfgByIndex(self.open_index)
	for k, v in pairs(self.current_all_suit) do
		if v.suit_color == 4 then
			count_orange = count_orange + 1
		elseif v.suit_color == 5 then
			count_red = count_red + 1
		end
	end
	local orange_max_num = self.current_all_suit[count_orange].need_count or 0
	local red_max_num = self.current_all_suit[#self.current_all_suit].need_count or 0
	local orange_num = self.new_color_list[4] or 0 						--4代表橙色
	local red_num = self.new_color_list[5] or 0 						--5代表红色
	self.node_list["TextRed"].text.text = string.format(Language.HunQi.RedSuitAttr, red_num, red_max_num)
	self.node_list["TextOrange"].text.text = string.format(Language.HunQi.OrangeSuitAttr, orange_num, orange_max_num)
end

function ShengXiaoSuitView:CloseWindow()
	self:Close()
end

function ShengXiaoSuitView:SetOpenCallBack(index)
	self.open_index = index
end


--------------------------EquipSuitInfoCell-----------------------------
EquipSuitInfoCell = EquipSuitInfoCell or BaseClass(BaseCell)

function EquipSuitInfoCell:__init()
	self.new_color_list ={}
	self.value = 0 --是否显示激活信息
end

function EquipSuitInfoCell:__delete()
	self.new_color_list = {}
end

function EquipSuitInfoCell:SetData(data, value)
	self.data = data
	self.value = value or 0

	self:Flush()
end

function EquipSuitInfoCell:OnFlush()
	if self.data == nil then
		return
	end
	local open_index = ShengXiaoData.Instance:GetEquipListByindex()
	local equip_list = ShengXiaoData.Instance:GetEquipLevelListByindex(open_index)
	if equip_list == nil or next(equip_list) == nil then return end
	self.new_color_list = {}
	for k, v in pairs(equip_list) do
		if v > 0 then
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v)
			local color_index = item_cfg.color
			if color_index == 6 then   -- 如果是粉色装备，这里按照红色装备处理
				color_index = 5
			end
			self.new_color_list[color_index] = self.new_color_list[color_index] or 0
			self.new_color_list[color_index] = self.new_color_list[color_index] + 1
		end
	end

	local num = self.value == 0 and self.new_color_list[self.data.suit_color] or 0
	local color1 = num >= self.data.need_count and TEXT_COLOR.GREEN or COLOR.WHITE

	self.node_list["TxtSuitName"].text.text = ToColorStr(string.format(Language.HunQi.TaoZhuang, self.data.need_count), color1)
	self.node_list["TxtAttr_1"].text.text = string.format(Language.HunQi.AttrList[1], color1, self.data.gongji)
	self.node_list["TxtAttr_2"].text.text = string.format(Language.HunQi.AttrList[2], color1, self.data.fangyu)
	self.node_list["TxtAttr_3"].text.text = string.format(Language.HunQi.AttrList[3], color1, self.data.maxhp)
	self.node_list["TxtAttr_4"].text.text = string.format(Language.HunQi.AttrList[4], color1, self.data.mingzhong)
	self.node_list["TxtAttr_5"].text.text = string.format(Language.HunQi.AttrList[5], color1, self.data.shanbi)
	self.node_list["TxtAttr_6"].text.text = string.format(Language.HunQi.AttrList[6], color1, self.data.baoji)
	self.node_list["TxtAttr_7"].text.text = string.format(Language.HunQi.AttrList[7], color1, self.data.jianren)
	self.node_list["TxtAttr_8"].text.text = string.format(Language.HunQi.AttrList[17], color1, self.data.per_kangbao / 100)
	self.node_list["TxtAttr_9"].text.text = string.format(Language.HunQi.AttrList[16], color1, self.data.per_baoji_hurt / 100)
	self.node_list["TxtAttr_10"].text.text = string.format(Language.HunQi.AttrList[15], color1, self.data.per_baoji / 100)

	self.node_list["AttrGroup1"]:SetActive(self.data.gongji and self.data.gongji > 0 or false)
	self.node_list["AttrGroup2"]:SetActive(self.data.fangyu and self.data.fangyu > 0 or false)
	self.node_list["AttrGroup3"]:SetActive(self.data.maxhp and self.data.maxhp > 0 or false)
	self.node_list["AttrGroup4"]:SetActive(self.data.mingzhong and self.data.mingzhong > 0 or false)
	self.node_list["AttrGroup5"]:SetActive(self.data.shanbi and self.data.shanbi > 0 or false)
	self.node_list["AttrGroup6"]:SetActive(self.data.baoji and self.data.baoji > 0 or false)
	self.node_list["AttrGroup7"]:SetActive(self.data.jianren and self.data.jianren > 0 or false)
	self.node_list["AttrGroup8"]:SetActive(self.data.per_kangbao and self.data.per_kangbao > 0 or false)
	self.node_list["AttrGroup9"]:SetActive(self.data.per_baoji_hurt and self.data.per_baoji_hurt > 0 or false)
	self.node_list["AttrGroup10"]:SetActive(self.data.per_baoji and self.data.per_baoji > 0 or false)
end

-- function EquipSuitInfoCell:SetColorList(color_list)
-- 	self.color_list = color_list or {}
-- end