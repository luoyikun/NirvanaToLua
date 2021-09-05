GoldTextView = GoldTextView or BaseClass(BaseRender)

function GoldTextView:__init()
	self.item_list = {}
	for i = 1, 8 do
		local item_cell = GoldItem.New(self.node_list["Item" .. i])
		item_cell:SetHandle(self)
		item_cell:SetIndex(i - 1)
		item_cell:SetData(nil)
		table.insert(self.item_list, item_cell)
	end

	self.item_cell = {}
	for i = 1, 2 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self.node_list["ItemCell" .. i]
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
	self.node_list["BtnSumAttr"].button:AddClickListener(BindTool.Bind(self.ClickAttr, self))
	self.node_list["Btn1"].button:AddClickListener(BindTool.Bind(self.ClickBtn, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.cur_tuhaojin_color = 0
	self.max_tuhaojin_color = 0
	self.total_attr = CommonStruct.Attribute()
end

function GoldTextView:__delete()
	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
	end
	self.fight_text = nil
end

function GoldTextView:ClickAttr()
	TipsCtrl.Instance:ShowAttrView(self.total_attr)
end

function GoldTextView:ClickBtn()
	CoolChatCtrl.Instance:SendTuhaojinUpLevelReq()
end

function GoldTextView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(7)
end

function GoldTextView:FlushGoldTextView()
	local tuhaojin_level = CoolChatData.Instance:GetTuHaoJinLevel() or 0
	local max_level = CoolChatData.Instance:GetTuHaoJinMaxLevel() or 0
	if max_level <= tuhaojin_level then
		self.node_list["Txtbtn"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["Btn1"], false)
	else
		self.node_list["Txtbtn"].text.text = Language.Common.UpGrade
		UI:SetButtonEnabled(self.node_list["Btn1"], true)
	end

	self.cur_tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0
	self.max_tuhaojin_color = CoolChatData.Instance:GetTuHaoJinMaxColor() or 0
	self.node_list["TxtLevel"].text.text = string.format(Language.Activity.XXLevel,tuhaojin_level)
	self.total_attr = CoolChatData.Instance:GetJingHuaAllAttr()
	local capability = CommonDataManager.GetCapability(self.total_attr) or 0
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end
	local list = CoolChatData.Instance:GetAllJingHuaItemCfg()
	local flag = false
	if list then
		for k, v in ipairs(list) do
			if self.item_list[k] then
				self.item_list[k]:SetData(v)
			end
		end
	end

	local tuhaojin_cfg = CoolChatData.Instance:GetGoldTextConfig()
	if tuhaojin_cfg then
		local level_cfg = tuhaojin_cfg.level_cfg
		if level_cfg then
			local cfg = level_cfg[tuhaojin_level + 1]
			if cfg then
				local item = TableCopy(cfg.common_item)
				if item.item_id > 0 then
					self.item_cell[1].obj:SetActive(true)
					item.num = 1
					self.item_cell[1].cell:SetData(item)
					local need_num = cfg.common_item.num or 0
					local has_num = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0
					if has_num < need_num then
						self.node_list["TxtBaseCell1"].text.text = ToColorStr(has_num, COLOR.RED) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
					else
						self.node_list["TxtBaseCell1"].text.text = ToColorStr(has_num, COLOR.GREEN) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
					end
				else
					self.item_cell[1].obj:SetActive(false)
				end
				local prof = Scene.Instance:GetMainRole().vo.prof
				local base_prof = PlayerData.Instance:GetRoleBaseProf(prof)
				local prof_item = TableCopy(cfg.prof_one_item)
				if base_prof == 2 then
					prof_item = TableCopy(cfg.prof_two_item)
				elseif base_prof == 3 then
					prof_item = TableCopy(cfg.prof_three_item)
				elseif base_prof == 4 then
					prof_item = TableCopy(cfg.prof_four_item)
				end
				need_num = prof_item.num or 0
				has_num = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
				if has_num < need_num then
					self.node_list["TxtBaseCell2"].text.text = ToColorStr(has_num, COLOR.RED) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
				else
					self.node_list["TxtBaseCell2"].text.text = ToColorStr(has_num, COLOR.GREEN) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
				end
				if max_level <= tuhaojin_level then
					self.node_list["TxtBaseCell2"].text.text = ToColorStr( "- / -")
				end
				prof_item.num = 1
				self.item_cell[2].cell:SetData(prof_item)
				if cfg.is_need_prof_item == 0 then
					self.item_cell[2].obj:SetActive(false)
				else
					self.item_cell[2].obj:SetActive(true)
				end
			end
		end
	end
end

-----------------Item-----------

GoldItem = GoldItem or BaseClass(BaseCell)

function GoldItem:__init()


	self.is_active = false

	self.node_list["ImgRedPoint"]:SetActive(false)
	self.node_list["Txt"]:SetActive(false)
	self.node_list["Cell"].button:AddClickListener(BindTool.Bind(self.Click, self))
end

function GoldItem:__delete()

end

function GoldItem:Click()
	if not self.is_active then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.GoldTextNotActive)
		return
	end
	CoolChatCtrl.Instance:SendUseTuHaoJinReq(self.index)
end

function GoldItem:OnFlush()
	if not self.data or not next(self.data) then return end


	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then return end
	local bubble, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgIcon"].image:LoadSprite(bubble, asset)
	self.node_list["TxtLevel"].text.text = string.format(Language.Chat.KaiFang, self.data.limit_level)
	self.node_list["ImgLevel"]:SetActive(true)
	if self.handele then
		if self.handele.cur_tuhaojin_color == self.index then
			self.node_list["ImgHL"]:SetActive(true)
			self.node_list["TxtLevel"].text.text = ToColorStr(Language.Common.HasUsed, "#00FF00FF")--(ToColorStr(Language.Common.HasUsed, TEXT_COLOR.GREEN)
		else
			self.node_list["ImgHL"]:SetActive(false)
		end
		if self.handele.max_tuhaojin_color < self.index then
			self.node_list["ImgLock"]:SetActive(true)
			UI:SetGraphicGrey(self.node_list["ImgIcon"], true)
			self.is_active = false
		else
			self.node_list["ImgLock"]:SetActive(false)
			UI:SetGraphicGrey(self.node_list["ImgIcon"], false)
			self.is_active = true
			if self.handele.cur_tuhaojin_color ~= self.index then
				self.node_list["ImgLevel"]:SetActive(false)
			end
		end
	end
end

function GoldItem:SetHandle(handele)
	self.handele = handele
end

function GoldItem:SetIndex(index)
	self.index = index
end