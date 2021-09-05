ShenGePropTipView = ShenGePropTipView or BaseClass(BaseView)

function ShenGePropTipView:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/shengeview_prefab", "ShenGeBlessPropTip"}}
	self.play_audio = true
	self.fight_info_view = true
end

function ShenGePropTipView:LoadCallBack()
	self.node_list["Image"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"], "FightPower3")
end

function ShenGePropTipView:ReleaseCallBack()
	self.fight_text = nil
end

function SelectEquipView:OpenCallBack()
	
end

function ShenGePropTipView:OpenCallBack()
	self.node_list["Scroller"].scroll_rect.normalizedPosition = Vector2(0, 1)

	local name_str = "<color="..SOUL_NAME_COLOR[self.data.color]..">"..self.data.name.."</color>"
	self.node_list["TxtTitleIconName"].text.text = name_str
	self.node_list["TxtDescribe"].text.text = self.data.detail
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = Language.Common.ZhanLi .. ": " .. self.data.zhanli
	end

	local bundle, asset = ResPath.GetItemIcon(self.data.item_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
	self.node_list["ImgIcon"].image.preserveAspect = true

	local bundle1, asset1 = ResPath.GetQualityIcon(self.data.color)
	self.node_list["ImgQuality"].image:LoadSprite(bundle1, asset1)
end

function ShenGePropTipView:CloseCallBack()

end

function ShenGePropTipView:CloseButton()
	self:Close()
end

function ShenGePropTipView:SetData(data)
	self.data = data
	self:Open()
end