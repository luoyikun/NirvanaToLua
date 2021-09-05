CoupleHomePreView = CoupleHomePreView or BaseClass(BaseView)

function CoupleHomePreView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_1"},
		{"uis/views/couplehome_prefab", "PreviewView"},
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_2"},
	}
	self.theme_type = -1
	self.is_modal = true
	self.is_any_click_close = true
end

function CoupleHomePreView:__delete()
end

function CoupleHomePreView:ReleaseCallBack()
	self.res = nil
	self.theme_name = nil
end

function CoupleHomePreView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(800, 535, 0)
	self.node_list["Bg1"].rect.sizeDelta = Vector3(800, 535, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.CoupleHome.ThemeHouseName
	-- self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function CoupleHomePreView:CloseWindow()
	self:Close()
end

function CoupleHomePreView:SetThemeType(theme_type)
	self.theme_type = theme_type
end

function CoupleHomePreView:OpenCallBack()
	local theme_cfg_info = CoupleHomeHomeData.Instance:GetThemeCfgInfoByThemeType(self.theme_type)
	if theme_cfg_info == nil then
		return
	end

	local theme_name = Language.CoupleHome.ThemeType[theme_cfg_info.theme_type] or ""
	-- self.node_list["NameText"].text.text = theme_name
	self.node_list["Txt"].text.text = theme_name

	local theme_type = theme_cfg_info.theme_type
	local bundle, asset = ResPath.GetRawImage("theme_preview_" .. theme_type, true)
	self.node_list["Image"].raw_image:LoadSprite(bundle, asset)
end