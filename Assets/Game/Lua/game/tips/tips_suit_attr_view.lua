TipsSuitAttrView = TipsSuitAttrView or BaseClass(BaseView)

function TipsSuitAttrView:__init()
	self.ui_config = {{"uis/views/tips/attrtips_prefab", "SuitAttrTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.cur_level = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsSuitAttrView:__delete()

end

function TipsSuitAttrView:LoadCallBack()
	--获取变量
	self.cur_attr_list = {}
	self.next_attr_list = {}
	for i = 1, 8 do
		self.cur_attr_list[i] = {
			attr = self.node_list["TxtCurAttr" .. i],
			show = self.node_list["PanelShowAttr" .. i],
		}
		self.next_attr_list[i] = {
			attr = self.node_list["TxtNextAttr" .. i],
			show = self.node_list["PanelShowNextAttr" .. i],
		}
	end
	--self.node_list["BtnBlock"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtNowFightPower"], "FightPower3")
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtNextFightPower"], "FightPower3")
end

function TipsSuitAttrView:ReleaseCallBack()
	-- 清理变量和对象
	self.cur_attr_list = nil
	self.next_attr_list = nil
	self.fight_text1 = nil
	self.fight_text2 = nil

end

function TipsSuitAttrView:CloseWindow()
	self:Close()
end

function TipsSuitAttrView:OpenCallBack()
	self:Flush()
end

function TipsSuitAttrView:SetCurAttrData(cur_data)
	self.cur_attr_data = cur_data
end

function TipsSuitAttrView:SetNextAttrData(next_attr_data)
	self.next_attr_data = next_attr_data
end

function TipsSuitAttrView:SetFromView(from_view)
	self.from_view = from_view
end

function TipsSuitAttrView:SetCurLevel(cur_level)
	self.cur_level = cur_level or 0
end

function TipsSuitAttrView:OnFlush()
	local show_next = (nil ~= self.next_attr_data)
	local show_cur = (nil ~= self.cur_attr_data)
	self.node_list["ImgArrow"]:SetActive(show_next and show_cur)
	self.node_list["PanShowNext"]:SetActive(show_next)
	self.node_list["PanelShowCur"]:SetActive(show_cur)

	if type(self.cur_attr_data) ~= "table" then
		self.cur_attr_data = {}
	end
	local cur_count = 1
	local cur_attr_str = ""
	local cur_set_attr_key_list = {}
	local change_cur_attr_list = CommonDataManager.GetAttributteNoUnderline(self.cur_attr_data)
	local cur_attr_list =  CommonDataManager.GetOrderAttributte(change_cur_attr_list)
	for k, v in pairs(cur_attr_list) do
		if v.value > 0 then
			self.cur_attr_list[cur_count].show:SetActive(true)
			cur_attr_str = (Language.Common.AttrNameUnderline[v.key] or Language.Common.AttrName[v.key]) ..": ".. string.format("<color='#ffffff'>%s</color>", v.value)
			self.cur_attr_list[cur_count].attr.text.text = cur_attr_str
			cur_set_attr_key_list[cur_count] = v.key
			cur_count = cur_count + 1
		end
	end

	if type(self.next_attr_data) ~= "table" then
		self.next_attr_data = {}
	end

	local next_count = 1
	local next_attr_str = ""
	local key = ""
	local change_next_attr_list = CommonDataManager.GetAttributteNoUnderline(self.next_attr_data)
	local next_attr_list =  CommonDataManager.GetOrderAttributte(change_next_attr_list)
	for k, v in pairs(next_attr_list) do
		if v.value > 0 then
			key = nil ~= cur_set_attr_key_list[next_count] and cur_set_attr_key_list[next_count] or v.key
			self.next_attr_list[next_count].show:SetActive(true)
			next_attr_str = (Language.Common.AttrNameNoUnderline[key] or Language.Common.AttrName[key])..": ".. string.format("<color='#ffffff'>%s</color>", v.value)
			self.next_attr_list[next_count].attr.text.text = next_attr_str

			next_count = next_count + 1
		end
	end

	local cur_cap = CommonDataManager.GetCapability(self.cur_attr_data)
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = cur_cap
	end
	local next_cap = CommonDataManager.GetCapability(self.next_attr_data)
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = next_cap
	end

	local cur_suit_name = self.cur_attr_data.name or ""
	local next_suit_name = self.next_attr_data.name or ""
	local next_cfg_level = self.next_attr_data.level or 0

	if nil ~= next(self.cur_attr_data) then
		local temp_str = ""
		if nil ~= next(self.next_attr_data) then
			temp_str = string.format(Language.Mount.ShowRedStr, self.cur_level..Language.Common.Ji)
			next_suit_name = string.format("%s(%s/%s%s)",next_suit_name,temp_str,next_cfg_level,Language.Common.Ji)

			temp_str = string.format(Language.Mount.ShowGreenStr, self.cur_level..Language.Common.Ji)
			cur_suit_name = string.format("%s(%s)",cur_suit_name,temp_str)
		else
			temp_str = string.format(Language.Mount.ShowGreenStr, self.cur_level..Language.Common.Ji)
			cur_suit_name = string.format("%s(%s)",cur_suit_name,temp_str)
		end
	elseif nil ~= next(self.next_attr_data) then
		temp_str = string.format(Language.Mount.ShowRedStr, self.cur_level..Language.Common.Ji)
		next_suit_name = string.format("%s(%s/%s%s)",next_suit_name,temp_str,next_cfg_level,Language.Common.Ji)
	end

	self.node_list["TxtNowTotalDes"].text.text = cur_suit_name
	self.node_list["TextNextTotalDes"].text.text = next_suit_name
	if nil ~= self.from_view and self.from_view == ViewName.ShengXiaoView then
		if self.cur_attr_data ~= nil and next(self.cur_attr_data) then
			self.node_list["TxtNowTotalDes"].text.text = string.format(Language.ShengXiao.CurTotalXinghun, self.cur_attr_data.level)
		end
		if self.next_attr_data ~= nil and next(self.next_attr_data) then
			self.node_list["TextNextTotalDes"].text.text = string.format(Language.ShengXiao.NextTotalXinghun, self.next_attr_data.level, self.cur_level)
		end
	end
end