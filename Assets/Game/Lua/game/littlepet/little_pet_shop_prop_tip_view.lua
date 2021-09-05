LittlPetPropTipView = LittlPetPropTipView or BaseClass(BaseView)

function LittlPetPropTipView:__init()
	self.ui_config = {{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
	{"uis/views/littlepetview_prefab", "LittlePetShopPropTip"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LittlPetPropTipView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(342, 404, 0)
	self.node_list["Txt"].text.text = Language.Common.JiangPinYuLan
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"], "FightPower3")
end

function LittlPetPropTipView:ReleaseCallBack()
	self.fight_text = nil
end

function LittlPetPropTipView:OpenCallBack()
	self.node_list["Scroller"].scroll_rect.normalizedPosition = Vector2(0, 1)

	local name_str = "<color="..SOUL_NAME_COLOR[self.data.name_color]..">"..self.data.name.."</color>"
	local bundle1, asset1 = ResPath.GetQualityIcon(self.data.name_color)
	self.node_list["Quality"].image:LoadSprite(bundle1, asset1)
	self.node_list["Name"].text.text = name_str
	self.node_list["Detail"].text.text = self.data.detail

	local is_pet = false
	local cfg, big_type = ItemData.Instance:GetItemConfig(self.data.icon_pic)
	if cfg then
		local bundle, asset = ResPath.GetItemIcon(cfg.icon_id)
		self.node_list["Icon"].image:LoadSprite(bundle, asset)
		if GameEnum.ITEM_BIGTYPE_EXPENSE == big_type and cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET then
			is_pet = true
		end
	end
	-- local power = is_pet and LittlePetData.Instance:CalPetBaseFightPower(false, self.data.icon_pic) or 0
	if self.fight_text and self.fight_text.text and self.data.zhanli then
		self.fight_text.text.text = self.data.zhanli
	end
end

function LittlPetPropTipView:CloseCallBack()
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
	self.close_call_back = nil
end

function LittlPetPropTipView:CloseButton()
	self:Close()
end

function LittlPetPropTipView:SetData(data, close_call_back)
	self.data = data
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end
	self:Open()
end