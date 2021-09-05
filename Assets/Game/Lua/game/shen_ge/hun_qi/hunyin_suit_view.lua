HunYinSuitView = HunYinSuitView or BaseClass(BaseView)

HunYinSuitView.SuitMaxLevel	= 5 									--套装最大等级
function HunYinSuitView:__init()
	self.ui_config = {{"uis/views/hunqiview_prefab", "HunYinSuitView"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.current_all_suit = {}
	self.cell_list = {}
end

function HunYinSuitView:__delete()
	self.current_all_suit = {}
	self.cell_list = {}
end

-- 销毁前调用
function HunYinSuitView:ReleaseCallBack()

	for k,v in pairs(self.color_list) do
		v = nil
	end
	self.color_list = {}
	self.hunyin_info = {}
	self.suit_level = 0

	for _, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.content = nil
end

function HunYinSuitView:LoadCallBack()
	self.cell_list = {}
	self.current_hunqi_index, self.current_hunyin_list_info = self.open_callback()
	self.current_hunqi_index = self.current_hunqi_index - 1
	local count_orange = 0
	local count_red = 0
	self.current_all_suit = HunQiData.Instance:GetHunYinSuitCfgByIndex(self.current_hunqi_index)
	for k, v in pairs(self.current_all_suit) do
		if v.suit_color == 4 then
			count_orange = count_orange + 1
		elseif v.suit_color == 5 or v.suit_color == 6 then
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
				local cell = SuitInfoCell.New(obj.gameObject)
				cell:SetInstanceParent(self.node_list["Content" .. index], false)
				local data = index == 1 and self.current_all_suit[i] or self.current_all_suit[i + count_orange]
				-- cell:SetCurrentHunQiIndex(self.current_hunqi_index + 1)
				cell:SetData(data)
				-- cell:SetData(self.current_all_suit[i])
				table.insert(self.cell_list, cell)
			end
			self:Flush()
		end)
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()

	self.color_list = {}
	for i = 0, 7 do
		table.insert(self.color_list, self.node_list["TxtColor" .. i])
	end
end

function HunYinSuitView:ShowIndexCallBack()
	self:Flush()
end

-- 打开后调用
function HunYinSuitView:OpenCallBack()
	self.suit_level = HunYinSuitView.SuitMaxLevel
	self.current_hunqi_index, self.current_hunyin_list_info = self.open_callback()
	local hunyin_color = 0
	local hunyin_id = 0

	for k,v in pairs(self.current_hunyin_list_info) do
		hunyin_id = v.hunyin_id
		if 0 ~= hunyin_id then
			hunyin_color = self.hunyin_info[hunyin_id][1].hunyin_color
			local txt = string.format(Language.HunQi.TxtColor, Language.HunYinSuit["color_" .. hunyin_color], Language.HunQi.HunShiName[k])
			self.color_list[k].text.text = txt
		else
			hunyin_color = 0
			self.color_list[k].text.text = string.format(Language.HunQi.TxtColor, Language.HunYinSuit.color_0, Language.HunQi.HunShiName[k])
		end
		if self.suit_level > hunyin_color then
			self.suit_level = hunyin_color
		end
	end

	self.current_hunqi_index = self.current_hunqi_index - 1
	self.current_all_suit = HunQiData.Instance:GetHunYinSuitCfgByIndex(self.current_hunqi_index)
end

-- 关闭前调用
function HunYinSuitView:CloseCallBack()
	self.current_hunqi_index = nil
end

function HunYinSuitView:CloseWindow()
	self:Close()
end

function HunYinSuitView:SetOpenCallBack(callback)
	self.open_callback = callback
end

function HunYinSuitView:OnFlush()
	self.current_hunqi_index, self.current_hunyin_list_info = self.open_callback()
	self.current_hunqi_index = self.current_hunqi_index - 1
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
	self.new_color_list = {}
	for k, v in pairs(self.current_hunyin_list_info) do
		if v.hunyin_id > 0 and self.hunyin_info[v.hunyin_id] and self.hunyin_info[v.hunyin_id][1] and self.hunyin_info[v.hunyin_id][1].hunyin_color then
			local color_index = self.hunyin_info[v.hunyin_id][1].hunyin_color
			self.new_color_list[color_index] = self.new_color_list[color_index] or 0
			self.new_color_list[color_index] = self.new_color_list[color_index] + 1
		end
	end
	if self.new_color_list[5] ~= nil or self.new_color_list[6] ~= nil then
		self.new_color_list[5] = (self.new_color_list[5] or 0) + (self.new_color_list[6] or 0)
	end

	self.current_all_suit = HunQiData.Instance:GetHunYinSuitCfgByIndex(self.current_hunqi_index)
	for k, v in pairs(self.cell_list) do
		-- v:SetColorList(self.new_color_list)
		v:SetCurrentHunQiIndex(self.current_hunqi_index + 1)
		v:SetData(self.current_all_suit[k])
	end

	local has_active_list = {}
	local suit_name_and_color = string.format(Language.HunQi.WeiJiHuoAttr, Language.HunYinSuit["color_txt"])
	for k, v in pairs(self.current_all_suit) do
		if self.new_color_list[v.suit_color] and self.new_color_list[v.suit_color] >= v.same_qulitily_count then
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
	self.current_all_suit = HunQiData.Instance:GetHunYinSuitCfgByIndex(self.current_hunqi_index)
	for k, v in pairs(self.current_all_suit) do
		if v.suit_color == 4 then
			count_orange = count_orange + 1
		elseif v.suit_color == 5 or v.suit_color == 6 then
			count_red = count_red + 1
		end
	end
	local orange_max_num = self.current_all_suit[count_orange].same_qulitily_count or 0
	local red_max_num = self.current_all_suit[#self.current_all_suit].same_qulitily_count or 0
	local orange_num = self.new_color_list[4] or 0 						--4代表橙色
	local red_num = self.new_color_list[5] or 0					--5代表红色
	self.node_list["TextRed"].text.text = string.format(Language.HunQi.RedSuitAttr, red_num, red_max_num)
	self.node_list["TextOrange"].text.text = string.format(Language.HunQi.OrangeSuitAttr, orange_num, orange_max_num)
end


--------------------------SuitInfoCell-----------------------------
SuitInfoCell = SuitInfoCell or BaseClass(BaseCell)
function SuitInfoCell:__init()
	self.new_color_list = {}
end

function SuitInfoCell:__delete()
	self.new_color_list = {}
end

function SuitInfoCell:OnFlush()
	if self.data == nil then
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

	if self.new_color_list[5] ~= nil or self.new_color_list[6] ~= nil then
		self.new_color_list[5] = (self.new_color_list[5] or 0) + (self.new_color_list[6] or 0)
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
end

-- function SuitInfoCell:SetColorList(color_list)
-- 	self.color_list = color_list or {}
-- end
function SuitInfoCell:SetCurrentHunQiIndex(index)
	self.current_hunqi_index = index or {}
	self:Flush()
end