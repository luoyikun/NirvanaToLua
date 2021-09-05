SuitAttrTipView = SuitAttrTipView or BaseClass(BaseView)

function SuitAttrTipView:__init()
	self.ui_config = {{"uis/views/clothespress_prefab", "SuitAttrTipView"}}
	self.is_any_click_close = true
	self.is_modal = true
	self.play_audio = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SuitAttrTipView:LoadCallBack()
	self.data_index = 1

	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.CloseButton, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TextCapability"], "FightPower3")
end

function SuitAttrTipView:ReleaseCallBack()
	self.fight_text = nil
end

function SuitAttrTipView:OpenCallBack()
	if self.data_list and self.data_list.attr and self.data_list.desc then
		local attr_list = self.data_list.attr
		local part_num = self.data_list.part_num
		local active_part_num = self.data_list.active_part_num
		local color = active_part_num < part_num and TEXT_COLOR.RED or TEXT_COLOR.BLACK_1
		local str = ToColorStr(active_part_num, color)
		local desc_num = "(" .. str .. " / " .. part_num .. ")"
		
		self.node_list["Hp"].text.text = Language.Player.AttrNameShengYin.maxhp .. " " .. attr_list.maxhp
		self.node_list["Gongji"].text.text = Language.Player.AttrNameShengYin.gongji .. " " .. attr_list.gong_ji
		self.node_list["Fangyu"].text.text = Language.Player.AttrNameShengYin.fangyu .. " " .. attr_list.fang_yu
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = attr_list.power
		end
		local desc = self.data_list.desc .. "  " .. desc_num
		self.node_list["TextDesc1"].text.text = desc
		local desc2 = self.data_list.desc_2
		if desc2 ~= "" then
			self.node_list["TextDesc2"]:SetActive(true)
			self.node_list["TextDesc2"].text.text = (desc2 .. "  " .. desc_num)
		else
			self.node_list["TextDesc2"]:SetActive(false)
		end
	end
end

function SuitAttrTipView:GetDataListBySuitIndex()
	self.data_list = ClothespressData.Instance:GetSuitAttrDataListBySuitIndex(self.data_index)
end

function SuitAttrTipView:CloseButton()
	self:Close()
end

function SuitAttrTipView:SetData(data_index)
	self.data_index = data_index
	self:GetDataListBySuitIndex()
	self:Open()
end