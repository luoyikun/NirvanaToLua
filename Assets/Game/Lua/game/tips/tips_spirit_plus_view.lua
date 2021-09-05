-- 精灵图鉴属性提示框
TipsSpiritPlusView = TipsSpiritPlusView or BaseClass(BaseView)

function TipsSpiritPlusView:__init()
	self.ui_config = {{"uis/views/spiritview_prefab", "TipSpiritTuJian"}}
	self.is_modal = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsSpiritPlusView:__delete()

end

function TipsSpiritPlusView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.next_attr_list = {}
	for i = 1, 3 do
		self.next_attr_list[i] = self.node_list["NextTxt" .. i]
	end
end

function TipsSpiritPlusView:ReleaseCallBack()
	self.next_attr_list = {}
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleImg"])
end

function TipsSpiritPlusView:FlushTitleFrame()
	local spirit_data = SpiritData.Instance
	local attr_list = spirit_data:GetLingPoTitleAttr()
	
	for i = 1, 3 do
	   self.next_attr_list[i].text.text = attr_list[i]
	end
	local title_info = spirit_data:GetCurTitleInfo()
	self.node_list["TotalLevelTxt"].text.text = title_info.desc

	self.node_list["TitleImg"].image:LoadSprite(ResPath.GetTitleIcon(title_info.title_id))
	TitleData.Instance:LoadTitleEff(self.node_list["TitleImg"], title_info.title_id, true)
end

function TipsSpiritPlusView:CloseWindow()
	self:Close()
end

function TipsSpiritPlusView:CloseCallBack()

end

function TipsSpiritPlusView:OpenCallBack()
	if self.spirit_data then 
		self:FlushTitleFrame()
	end
end

function TipsSpiritPlusView:SetData(data)
	self.spirit_data = data
end


