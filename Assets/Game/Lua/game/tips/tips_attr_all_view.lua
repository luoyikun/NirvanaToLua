-- 女神共鸣-属性总览
TipsAttrAllView = TipsAttrAllView or BaseClass(BaseView)

function TipsAttrAllView:__init()
	self.ui_config = {{"uis/views/tips/attrtips_prefab", "AttrTipAllView"}}
	self.data = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsAttrAllView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"], "FightPower3")
end

function TipsAttrAllView:ReleaseCallBack()
	self.fight_text = nil
end

function TipsAttrAllView:CloseWindow()
	self:Close()
end

function TipsAttrAllView:OpenCallBack()
	self:Flush()
end

function TipsAttrAllView:SetAttrData(data)
	self.data = data or {}
end

function TipsAttrAllView:OnFlush()
	if type(self.data) ~= "table" then
		self.data = {}
	end

	local hp = self.data.max_hp or self.data.maxhp or 0
	local gong_ji = self.data.gong_ji or self.data.gongji or 0
	local fang_yu = self.data.fang_yu or self.data.fangyu or 0
	local ming_zhong = self.data.ming_zhong or self.data.mingzhong or 0
	local shan_bi = self.data.shan_bi or self.data.shanbi or 0
	local bao_ji = self.data.bao_ji or self.data.baoji or 0
	local jian_ren = self.data.jian_ren or self.data.jianren or 0
	local move_speed = self.data.move_speed
	local per_jingzhun = self.data.per_jingzhun
	local per_baoji = self.data.per_baoji
	local per_pofang = self.data.per_pofang
	local per_mianshang = self.data.per_mianshang
	local goddess_gongji = self.data.goddess_gongji or self.data.fujia_shanghai or self.data.xiannv_gongji or 0
	local constant_mianshang = self.data.constant_mianshang or self.data.mian_shang or self.data.mianshang or 0

	if hp and hp >= 0 then
		self.node_list["PanelShowHP"]:SetActive(true)
		self.node_list["TxtHp"].text.text = string.format(Language.Tips.Attribute.Hp, hp)
	else
		self.node_list["PanelShowHP"]:SetActive(false)
	end

	if gong_ji and gong_ji >= 0 then
		self.node_list["PanelShowGongji"]:SetActive(true)
		self.node_list["TxtGongji"].text.text = string.format(Language.Tips.Attribute.Gongji, gong_ji)
	else
		self.node_list["PanelShowGongji"]:SetActive(false)
	end

	if fang_yu and fang_yu >= 0 then
		self.node_list["PanelShowfangyu"]:SetActive(true)
		self.node_list["TxtFangyu"].text.text = string.format(Language.Tips.Attribute.Fangyu, fang_yu)
	else
		self.node_list["PanelShowfangyu"]:SetActive(false)
	end

	if ming_zhong and ming_zhong > 0 then
		self.node_list["PanelShowmingzhong"]:SetActive(true)
		self.node_list["TxtMingzhong"].text.text = string.format(Language.Tips.Attribute.Mingzhong, ming_zhong)
	else
		self.node_list["PanelShowmingzhong"]:SetActive(false)
	end

	if shan_bi and shan_bi > 0 then
		self.node_list["PanelShowShanbi"]:SetActive(true)
		self.node_list["TxtShanbi"].text.text = string.format(Language.Tips.Attribute.Shanbi, shan_bi)
	else
		self.node_list["PanelShowShanbi"]:SetActive(false)
	end

	if bao_ji and bao_ji > 0 then
		self.node_list["PanelShowBaoji"]:SetActive(true)
		self.node_list["TxtBaoji"].text.text = string.format(Language.Tips.Attribute.Baoji, bao_ji)
	else
		self.node_list["PanelShowBaoji"]:SetActive(false)
	end

	if jian_ren and jian_ren > 0 then
		self.node_list["PanelShowKangbao"]:SetActive(true)
		self.node_list["TxtKangbao"].text.text = string.format(Language.Tips.Attribute.KangBao, jian_ren)
	else
		self.node_list["PanelShowKangbao"]:SetActive(false)
	end

	if goddess_gongji and goddess_gongji > 0 then
		self.node_list["PanelShowGoddess"]:SetActive(true)
		self.node_list["TxtGoddessgonji"].text.text =string.format(Language.Tips.Attribute.Goddessgongji, goddess_gongji)
	else
		self.node_list["PanelShowGoddess"]:SetActive(false)
	end

	if constant_mianshang and constant_mianshang > 0 then
		self.node_list["PanelShowMianshang"]:SetActive(true)
		self.node_list["TxtMianshang"].text.text = string.format(Language.Tips.Attribute.Mianshang, constant_mianshang)
	else
		self.node_list["PanelShowMianshang"]:SetActive(false)
	end

	local cap = CommonDataManager.GetCapability(self.data)
	if self.fight_text and self.fight_text.text then
		if cap and cap >= 0 then
			self.fight_text.text.text = cap
		else
			self.fight_text.text.text = 0
		end
	end
	self.node_list["TxtTipsName"].text.text = (self.data.name or Language.JingLing.AttrTipTitle)
end