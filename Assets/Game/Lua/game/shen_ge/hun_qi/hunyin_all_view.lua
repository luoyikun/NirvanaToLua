HunYinAllView = HunYinAllView or BaseClass(BaseView)
function HunYinAllView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/hunqiview_prefab", "AllHunYinContent"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function HunYinAllView:__delete()

end

function HunYinAllView:LoadCallBack()
	self.node_list["BtnGreen"].button:AddClickListener(BindTool.Bind(self.ClickGreen, self))
	self.node_list["BtnBlue"].button:AddClickListener(BindTool.Bind(self.ClickBlue, self))
	self.node_list["BtnPurple"].button:AddClickListener(BindTool.Bind(self.ClickPurple, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClosen, self))

	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerGreen"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerBlue"])
	self.fight_text3 = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerPurple"])

	self.node_list["Txt"].text.text = Language.HunQi.TxtTitle2
	self.node_list["Bg"].rect.sizeDelta = Vector3(780, 530, 0)

	self.green_cell_data = {}
	self.blue_cell_data = {}
	self.purple_cell_data = {}

	self.top_hunyin_count = 0
	self.hunyin_all = HunQiData.Instance:GetHunYinAllInfo()
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()

	local top_hunyin = {}
	for k,v in pairs(self.hunyin_all) do
		local color_id = v.hunyin_color
		if color_id == 2 then
			self.green_cell_data = v
		end
		if color_id == 3 then
			self.blue_cell_data = v
		end
		if color_id == 4 then
			self.purple_cell_data = v
		end
		if color_id == 5 then
			self.top_hunyin_count = self.top_hunyin_count + 1
			table.insert(top_hunyin, v)
		end
	end

	self.top_list = {}
		for i = 1, self.top_hunyin_count do
		local top_obj = self.node_list["top_list"].transform:GetChild(i - 1).gameObject
		local top_item = TopCell.New(top_obj)
		top_item:SetData(top_hunyin[i])
		top_item:SetClickCallBack(BindTool.Bind(self.SlotClick, self))
		table.insert(self.top_list, top_item)
	end
end

-- 销毁前调用
function HunYinAllView:ReleaseCallBack()
	for k,v in pairs(self.top_list) do
		v:DeleteMe()
	end
	self.top_list = {}
	self.fight_text1 = nil
	self.fight_text2 = nil
	self.fight_text3 = nil
end

-- 打开后调用
function HunYinAllView:OpenCallBack()
	local asset, bundle = ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.green_cell_data.hunyin_id))
	self.node_list["ImgGreen"].image:LoadSprite(asset, bundle, function()
			self.node_list["ImgGreen"].image:SetNativeSize()
			end)
	asset, bundle = ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.blue_cell_data.hunyin_id))
	self.node_list["ImgBlue"].image:LoadSprite(asset, bundle, function()
			self.node_list["ImgBlue"].image:SetNativeSize()
			end)
	asset, bundle = ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.purple_cell_data.hunyin_id))
	self.node_list["ImgPurple"].image:LoadSprite(asset, bundle, function()
			self.node_list["ImgPurple"].image:SetNativeSize()
			end)
	-- self.node_list["EffectGreen"]:ChangeAsset(ResPath.GetEffect(self.green_cell_data.effect))
	-- self.node_list["EffectBlue"]:ChangeAsset(ResPath.GetEffect(self.blue_cell_data.effect))
	-- self.node_list["EffectPurple"]:ChangeAsset(ResPath.GetEffect(self.purple_cell_data.effect))
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = CommonDataManager.GetCapability(self.hunyin_info[self.green_cell_data.hunyin_id][1])
	end
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = CommonDataManager.GetCapability(self.hunyin_info[self.blue_cell_data.hunyin_id][1])
	end
	if self.fight_text3 and self.fight_text3.text then
		self.fight_text3.text.text = CommonDataManager.GetCapability(self.hunyin_info[self.purple_cell_data.hunyin_id][1])
	end

end

-- 关闭前调用
function HunYinAllView:CloseCallBack()
	-- override
end

function HunYinAllView:ClickGreen()
	self:ShowAttrView(self.green_cell_data.hunyin_id)
end

function HunYinAllView:ClickBlue()
	self:ShowAttrView(self.blue_cell_data.hunyin_id)
end

function HunYinAllView:ClickPurple()
	self:ShowAttrView(self.purple_cell_data.hunyin_id)
end

function HunYinAllView:SlotClick(item_cell)
	local hunyin_id = item_cell:GetData().hunyin_id
	self:ShowAttrView(hunyin_id)
end

function HunYinAllView:ShowAttrView(hunyin_id)
	hunyin_id = hunyin_id or 0
	local data = self.hunyin_info[hunyin_id][1]
	local attr_info = {}
	attr_info.maxhp = data.maxhp
	attr_info.gongji = data.gongji
	for k,v in pairs(self.hunyin_all) do
	 	if v.hunyin_id == hunyin_id then
	 		attr_info.name = v.name
	 	end
	 end
	TipsCtrl.Instance:ShowAttrView(attr_info)
end

function HunYinAllView:ClickClosen()
	self:Close()
end
-----------------TopCell----------------------
TopCell = TopCell or BaseClass(BaseCell)
function TopCell:__init()
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanLi"])
end

function TopCell:__delete()
	self.hunyin_info = {}
	self.fight_text = nil
end

function TopCell:OnFlush()
	local data = self:GetData()
	if nil ~= data then
		local item_id = data.hunyin_id
		--self.node_list["Effect"]:ChangeAsset(ResPath.GetEffect(data.effect))
		local asset, bundle = ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(item_id))
		self.node_list["Img"].image:LoadSprite(asset, bundle, function()
				self.node_list["Img"].image:SetNativeSize()
				end)
		local attr_data = self.hunyin_info[item_id][1]
		local attr_info = CommonStruct.AttributeNoUnderline()
		attr_info.maxhp = attr_data.maxhp
		attr_info.gongji = attr_data.gongji
		attr_info.fangyu = attr_data.fangyu
		attr_info.mingzhong = attr_data.mingzhong
		attr_info.shanbi = attr_data.shanbi
		attr_info.baoji = attr_data.baoji
		attr_info.jianren = attr_data.jianren
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapability(attr_info)
		end
	end
end
