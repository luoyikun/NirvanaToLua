HeFuCityCombatTip = HeFuCityCombatTip or BaseClass(BaseView)
function HeFuCityCombatTip:__init()
	self.ui_config = {
		{"uis/views/hefucitycombatview_prefab", "SkillDesTip"}
	}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function HeFuCityCombatTip:__delete()

end

function HeFuCityCombatTip:ReleaseCallBack()

end

function HeFuCityCombatTip:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function HeFuCityCombatTip:CloseWindow()
	self:Close()
end

function HeFuCityCombatTip:OpenCallBack()
	--设置技能图标
	self.node_list["ImgSkill"].image:LoadSprite(self.asset, self.bunble)
	local other_cfg = CityCombatData.Instance:GetOtherConfig()
	local is_active = FashionData.Instance:GetFashionActFlagById(other_cfg.cz_fashion_yifu_id)
	--设置是否已激活
	local active_des = Language.HunQi.IsActiveDes
	-- if self.level <= 0 or not is_active then
	if not is_active then
		active_des = Language.HunQi.NotActiveDes
	end

	--设置等级和名字
	self.node_list["TxtName"].text.text = self.name .. active_des
	-- self.node_list["TxtLevel"].text.text = string.format(Language.HeFuCombatTip.Level, self.level)

	-- --设置本级属性的展示
	-- if self.now_des ~= "" then
	-- 	self.node_list["PlaneSkillEffect"]:SetActive(true)
	-- 	self.node_list["TxtNowAttr"].text.text = self.now_des
	-- else
	-- 	self.node_list["PlaneSkillEffect"]:SetActive(false)
	-- end

	-- --设置下级属性和升级要求展示
	-- if self.next_des ~= "" then
	-- 	self.node_list["PlaneNextSkillEffect"]:SetActive(false)
	-- 	self.node_list["TxtNextAttr"].text.text = self.next_des
	-- else
	-- 	self.node_list["PlaneNextSkillEffect"]:SetActive(true)
	-- end
end

function HeFuCityCombatTip:CloseCallBack()

end

function HeFuCityCombatTip:SetSkillName(name)
	self.name = name or ""
end

function HeFuCityCombatTip:SetSkillLevel(level)
	self.level = level or 0
end

function HeFuCityCombatTip:SetNowDes(des)
	self.now_des = des or ""
end

function HeFuCityCombatTip:SetNextDes(des)
	self.next_des = des or ""
end

function HeFuCityCombatTip:SetSkillRes(asset, bunble)
	self.asset = asset or ""
	self.bunble = bunble or ""
end