ShenGeAttrView = ShenGeAttrView or BaseClass(BaseView)

function ShenGeAttrView:__init()
	self.ui_config = {{"uis/views/shengeview_prefab", "ShenGeAttrView"}}
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.total_suit_num = ShenGeData.Instance:GetNewSuitNum()
end

function ShenGeAttrView:ReleaseCallBack()
	for k,v in pairs(self.suit_item_list) do
		v:DeleteMe()
	end
	self.suit_item_list = {}
	self.suit_list_view = nil
end

function ShenGeAttrView:LoadCallBack()
	self.suit_item_list = {}
	self.suit_list_view = self.node_list["SuitListView"]

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))


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
			local cell = ShenGeSuitInfoCell.New(obj.gameObject)
			cell:SetInstanceParent(self.node_list["Content" .. index], false)
			local data = index == 1 and self.current_all_suit[i] or self.current_all_suit[i + count_orange]
			cell:SetData(data)
		end
		self:Flush()
		end)
	end
end

function ShenGeAttrView:OpenCallBack()
	self:Flush()
end

function ShenGeAttrView:CloseView()
	self:Close()
end

function ShenGeAttrView:OnFlush()
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
	self.node_list["TextOrange"].text.text = string.format(Language.HunQi.OrangeSuitAttr, orange_num, orange_max_num)
	self.node_list["TextRed"].text.text = string.format(Language.HunQi.RedSuitAttr, red_num, red_max_num)
end

--------------------------ShenGeSuitInfoCell-----------------------------
ShenGeSuitInfoCell = ShenGeSuitInfoCell or BaseClass(BaseCell)
function ShenGeSuitInfoCell:__init()
	self.color_list = {}
end

function ShenGeSuitInfoCell:__delete()
	self.color_list = {}
end

function ShenGeSuitInfoCell:OnFlush()
	if self.data == nil then
		return
	end

	-- local quality = self.data.quality >= 2 and self.data.quality - 2 or 0
	local data_info = ShenGeData.Instance:GetShenGeQualityInfo()
	local num = data_info[self.data.quality + 1] or 0
	local color = num >= self.data.need_count and TEXT_COLOR.GREEN or COLOR.LightBlue
	local color1 = num >= self.data.need_count and TEXT_COLOR.GREEN or COLOR.WHITE
	self.node_list["TxtSuitName"].text.text = ToColorStr(string.format(Language.HunQi.TaoZhuang, self.data.need_count), color)
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

	self.node_list["AttrGroup1"]:SetActive(self.data.gongji > 0)
	self.node_list["AttrGroup2"]:SetActive(self.data.fangyu > 0)
	self.node_list["AttrGroup3"]:SetActive(self.data.maxhp > 0)
	self.node_list["AttrGroup4"]:SetActive(self.data.mingzhong > 0)
	self.node_list["AttrGroup5"]:SetActive(self.data.shanbi > 0)
	self.node_list["AttrGroup6"]:SetActive(self.data.baoji > 0)
	self.node_list["AttrGroup7"]:SetActive(self.data.jianren > 0)
	self.node_list["AttrGroup8"]:SetActive(self.data.per_gongji > 0)
	self.node_list["AttrGroup9"]:SetActive(self.data.per_fangyu > 0)
	self.node_list["AttrGroup10"]:SetActive(self.data.per_maxhp > 0)
	self.node_list["AttrGroup11"]:SetActive(self.data.per_mianshang > 0)
end

function ShenGeSuitInfoCell:SetColorList(color_list)
	self.color_list = color_list or {}
end