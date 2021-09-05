ShenYinSuitAttrView = ShenYinSuitAttrView or BaseClass(BaseView)

function ShenYinSuitAttrView:__init()
	self.ui_config = {
		{"uis/views/shenyinview_prefab","ShenYinSuitAllView"},
	}
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenYinSuitAttrView:__delete()

end

function ShenYinSuitAttrView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	for k,v in pairs(self.color_list) do
		v = nil
	end
	self.color_list = {}
	self.new_color_list = {}
	-- self.content = nil
end

function ShenYinSuitAttrView:LoadCallBack()
	self.suit_count = 0
	local count_orange = 0
	local count_red = 0
	self.current_all_suit = ShenYinData.Instance:GetTaoZhuangCfg()
	if self.current_all_suit then
		for k, v in pairs(self.current_all_suit) do
			if v.suit_1 == 0 then
				count_orange = count_orange + 1
			elseif v.suit_1 == 1 then
				count_red = count_red + 1
			end
		end
	end

	self.cell_list = {}
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
				local cell = ShenYinSuitInfoCell.New(obj.gameObject)
				cell:SetInstanceParent(self.node_list["Content" .. index], false)
				local data = index == 1 and self.current_all_suit[i] or self.current_all_suit[i + count_orange]
				cell:SetData(data)
				table.insert(self.cell_list, cell)
			end
			self:Flush()
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = GlobalTimerQuest:AddDelayTimer(
				BindTool.Bind(self.OnDelayUpdate, self), 0.13)
		end)
	end

	self.color_list = {}
	for i = 0, 9 do
		table.insert(self.color_list, self.node_list["TxtColor" .. i])
	end
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
end

function ShenYinSuitAttrView:OnDelayUpdate()
	self.node_list["SuitList"].scroll_rect.verticalNormalizedPosition = 1
end

function ShenYinSuitAttrView:CloseView()
	self:Close()
end

function ShenYinSuitAttrView:OpenCallBack()

	--异步加载刷新格子
	-- self.node_list["SuitList"].list_view:Reload()
	self:Flush()
end

function ShenYinSuitAttrView:OnClickClose()
	self:Close()
end

function ShenYinSuitAttrView:OnFlush()
	self.current_shenyin_list_info  = ShenYinData.Instance:GetMarkSlotInfo()
	local hunyin_color = 0
	local color_index = 0
	self.new_color_list = {}
	for k,v in pairs(self.current_shenyin_list_info) do
		if -1 ~= v.v_item_id then
			hunyin_color = v.quanlity
			color_index = v.quanlity
			if v.quanlity == 5 then
				color_index = v.quanlity - 1
			end
			self.new_color_list[color_index] = self.new_color_list[color_index] or 0
			self.new_color_list[color_index] = self.new_color_list[color_index] + 1
			local txt = string.format(Language.HunQi.TxtColor, Language.ShenYinSuit["color_" .. hunyin_color], Language.ShenYin.ShenShiName[k + 1])
			self.color_list[k+1].text.text = txt
		else
			hunyin_color = 0
			self.color_list[k + 1].text.text = string.format(Language.HunQi.TxtColor, Language.ShenYinSuit.color_txt, Language.ShenYin.ShenShiName[k + 1])
		end
	end

	self.current_all_suit = ShenYinData.Instance:GetTaoZhuangCfg()
	for k, v in pairs(self.cell_list) do
		v:SetColorList(self.new_color_list)
		v:SetData(self.current_all_suit[k])
	end

	local has_active_list = {}
	local suit_name_and_color = string.format(Language.HunQi.WeiJiHuoAttr, Language.MingWenSuit["color_txt"])
	for k, v in pairs(self.current_all_suit) do
		if self.new_color_list[v.quality] and self.new_color_list[v.quality] >= v.need_count then
			table.insert(has_active_list, v)
		end
	end
	if #has_active_list > 0 then
		local cfg = has_active_list[#has_active_list]
		if cfg then
			suit_name_and_color = string.format(Language.HunQi.YiJHuoAttr, Language.MingWenSuit["color_" .. cfg.quality - 1], cfg.name)
		end
	end
	self.node_list["Suit"].text.text = suit_name_and_color
	-- local quality = self.data.quality + 2 > 6 and self.data.quality or self.data.quality + 2
	-- font_color = Language.MingWenSuit["color_"..quality]
	local count_orange = 0
	self.current_all_suit = ShenYinData.Instance:GetTaoZhuangCfg()
	if self.current_all_suit then
		for k, v in pairs(self.current_all_suit) do
			if v.suit_1 == 0 then
				count_orange = count_orange + 1
			end
		end
	end
	local orange_max_num = self.current_all_suit[count_orange].need_count or 0
	local red_max_num = self.current_all_suit[#self.current_all_suit].need_count or 0
	local orange_num = self.new_color_list[3] or 0 						--3代表橙色
	local red_num = self.new_color_list[4] or 0 						--4代表红色和粉色
	self.node_list["TextRed"].text.text = string.format(Language.HunQi.RedSuitAttr, red_num, red_max_num)
	self.node_list["TextOrange"].text.text = string.format(Language.HunQi.OrangeSuitAttr, orange_num, orange_max_num)
end

--------------------------ShenYinSuitInfoCell-----------------------------
ShenYinSuitInfoCell = ShenYinSuitInfoCell or BaseClass(BaseCell)
function ShenYinSuitInfoCell:__init()
	self.color_list = {}
end

function ShenYinSuitInfoCell:__delete()
	self.color_list = {}
end

function ShenYinSuitInfoCell:OnFlush()
	if self.data == nil then
		return
	end
	local font_color = ""
	-- 套装颜色使用了quality、高聪说配不了，正常颜色值
	local quality = self.data.quality + 1 > 6 and self.data.quality or self.data.quality + 1
	font_color = Language.MingWenSuit["color_"..quality]
	local num = self.color_list[self.data.quality] or 0
	local num_color = ""
	local attr_color = ""
	local color = num >= self.data.need_count and TEXT_COLOR.GREEN or COLOR.LightBlue
	local color1 = num >= self.data.need_count and TEXT_COLOR.GREEN or COLOR.WHITE
	self.node_list["TxtSuitName"].text.text = ToColorStr(string.format(Language.HunQi.TaoZhuang, self.data.need_count), color) 
	
	self.node_list["TxtAttr_1"].text.text = string.format(Language.HunQi.AttrList[1], color1, self.data.gongji)
	self.node_list["TxtAttr_2"].text.text = string.format(Language.HunQi.AttrList[2], color1, self.data.fangyu )
	self.node_list["TxtAttr_3"].text.text = string.format(Language.HunQi.AttrList[3], color1, self.data.maxhp)
	self.node_list["TxtAttr_4"].text.text = string.format(Language.HunQi.AttrList[4], color1, self.data.mingzhong)
	self.node_list["TxtAttr_5"].text.text = string.format(Language.HunQi.AttrList[5], color1, self.data.shanbi)
	self.node_list["TxtAttr_6"].text.text = string.format(Language.HunQi.AttrList[6], color1, self.data.baoji)
	self.node_list["TxtAttr_7"].text.text = string.format(Language.HunQi.AttrList[7], color1, self.data.jianren)
	-- self.node_list["TxtAttr_8"].text.text = string.format(Language.HunQi.AttrList[8], color1, self.data.per_hunshi / 100)
	self.node_list["TxtAttr_8"].text.text = string.format(Language.HunQi.AttrList[8], color1, self.data.per_gongji / 100)
	self.node_list["TxtAttr_9"].text.text = string.format(Language.HunQi.AttrList[9], color1, self.data.per_fangyu / 100)
	self.node_list["TxtAttr_10"].text.text = string.format(Language.HunQi.AttrList[10], color1, self.data.per_maxhp / 100)
	self.node_list["TxtAttr_11"].text.text = string.format(Language.HunQi.AttrList[11], color1, self.data.skill_jianshang_per / 100)

	self.node_list["AttrGroup1"]:SetActive(self.data.gongji > 0)
	self.node_list["AttrGroup2"]:SetActive(self.data.fangyu > 0)
	self.node_list["AttrGroup3"]:SetActive(self.data.maxhp > 0)
	self.node_list["AttrGroup4"]:SetActive(self.data.mingzhong > 0)
	self.node_list["AttrGroup5"]:SetActive(self.data.shanbi > 0)
	self.node_list["AttrGroup6"]:SetActive(self.data.baoji > 0)
	self.node_list["AttrGroup7"]:SetActive(self.data.jianren > 0)
	self.node_list["AttrGroup8"]:SetActive(self.data.per_gongji > 0)
	-- self.node_list["AttrGroup8"]:SetActive(self.data.per_hunshi > 0)
	self.node_list["AttrGroup9"]:SetActive(self.data.per_fangyu > 0)
	self.node_list["AttrGroup10"]:SetActive(self.data.per_maxhp > 0)
	self.node_list["AttrGroup11"]:SetActive(self.data.skill_jianshang_per > 0)
end

function ShenYinSuitInfoCell:SetColorList(color_list)
	self.color_list = color_list or {}
end

