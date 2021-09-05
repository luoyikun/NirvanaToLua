RuneItemTips = RuneItemTips or BaseClass(BaseView)
function RuneItemTips:__init()
	self.ui_config = {{"uis/views/rune_prefab", "RuneItemTips"}}
	self.play_audio = true
	self.view_layer = UiLayer.Pop

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.index = -1
end

function RuneItemTips:__delete()
end

function RuneItemTips:ReleaseCallBack()
	self.fight_text = nil
end

function RuneItemTips:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLiNumTxt"], "FightPower3")
end

function RuneItemTips:SetData(data)
	self.data = data
end

function RuneItemTips:SetCloseCallBack(callback)
	self.callback = callback
end

function RuneItemTips:OpenCallBack()
	self:FlushView()
end

function RuneItemTips:CloseCallBack()
	self.index = -1
	if self.callback then
		self.callback()
		self.callback = nil
	end
end

function RuneItemTips:CloseWindow()
	self:Close()
end

function RuneItemTips:FlushView()
	if not self.data or not next(self.data) then
		return
	end
	local quality = self.data.quality
	local types = self.data.types or self.data.type
	local level = self.data.level
	local data = RuneData.Instance:GetAttrInfo(quality, types, level)
	if not next(data) then
		return
	end

	local item_id = RuneData.Instance:GetRealId(quality, types)
	if item_id > 0 then
		self.node_list["TopIcon"].image:LoadSprite(ResPath.GetItemIcon(item_id))
	end

	local name_color = RUNE_COLOR[data.quality] or TEXT_COLOR.WHITE
	local name = Language.Rune.AttrTypeName[data.types] or ""
	local name_des = ToColorStr(name, name_color)
	self.node_list["TopName"].text.text = name_des
	self.node_list["LevelDes"].text.text = string.format(Language.Rune.Level, data.level)

	local types_des = Language.Rune.RuneType1
	if data.types == GameEnum.RUNE_JINGHUA_TYPE then
		types_des = Language.Rune.RuneType2
	end
	self.node_list["TypeDes"].text.text = string.format(Language.Rune.Types, types_des)
	
	local pass_layer = RuneData.Instance:GetPassLayerByItemId(item_id)
	if pass_layer > 0 then
		local pass_des = string.format(Language.Rune.PassLayerDes, pass_layer)
		self.node_list["PassDes"].text.text = pass_des
	else
		self.node_list["PassDes"].text.text = ""
	end

	self.node_list["AttrText2"]:SetActive(false)
	local attr_type_name = ""
	local attr_value = 0
	if data.types == GameEnum.RUNE_JINGHUA_TYPE then
		--符文精华特殊处理
		attr_type_name = Language.Rune.JingHuaAttrName
		attr_value = data.dispose_fetch_jinghua
		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrText1"].text.text = str
		self.node_list["AttrText2"].text.text = ""
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = 0
		end
		return
	end
	attr_type_name = Language.Rune.AttrName[data.attr_type_0] or ""
	attr_value = data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(data.attr_type_0) then
		attr_value = (data.add_attributes_0/100.00) .. "%"
	end
	
	local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	self.node_list["AttrText1"].text.text = attr_des
	if data.attr_type_1 > 0 then
		attr_type_name = Language.Rune.AttrName[data.attr_type_1] or ""
		attr_value = data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(data.attr_type_1) then
			attr_value = (data.add_attributes_1/100.00) .. "%"
		end
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrText2"].text.text =attr_des
		self.node_list["AttrText2"]:SetActive(true)
	else
		self.node_list["AttrText2"].text.text = ""
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = data.power
	end
end