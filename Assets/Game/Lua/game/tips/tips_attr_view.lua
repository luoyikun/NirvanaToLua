TipsAttrView = TipsAttrView or BaseClass(BaseView)

function TipsAttrView:__init()
	self.ui_config = {{"uis/views/tips/attrtips_prefab", "AttrTipView"}}
	self.data = {}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.no_pofang = false
end

function TipsAttrView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"], "FightPower3")
end

function TipsAttrView:ReleaseCallBack()
	self.fight_text = nil
	self.has_pofang = nil
end

function TipsAttrView:CloseWindow()
	self:Close()
end

function TipsAttrView:CloseCallBack()
	self.from_view = nil
end

function TipsAttrView:OpenCallBack()
	self:Flush()
end

function TipsAttrView:SetAttrData(data)
	self.data = data or {}
end

function TipsAttrView:SetHasPoFang(enable)
	self.no_pofang = enable
end

function TipsAttrView:SetFromView(from_view)
	self.from_view = from_view
end

function TipsAttrView:SetShowZhanli(not_show_zhanli)
	if not_show_zhanli then
		self.not_show_zhanli = true
	end
end

function TipsAttrView:OnFlush()
	if type(self.data) ~= "table" then
		self.data = {}
	end
	local hp = self.data.max_hp or self.data.maxhp or -1
	local gong_ji = self.data.gong_ji or self.data.gongji or -1
	local fang_yu = self.data.fang_yu or self.data.fangyu or -1
	local ming_zhong = self.data.ming_zhong or self.data.mingzhong or -1
	local shan_bi = self.data.shan_bi or self.data.shanbi or -1
	local bao_ji = self.data.bao_ji or self.data.baoji or -1
	local jian_ren = self.data.jian_ren or self.data.jianren or -1
	local per_jingzhun = self.data.per_jingzhun or self.data.per_jingzhun or -1

	local per_baoji = self.data.per_baoji or self.data.baoji_per or -1
	local per_kang_bao = self.data.per_kang_bao or self.data.kang_bao_per or self.data.per_kangbao or -1
	local per_mianshang = self.data.per_mianshang or self.data.per_mianshang or -1
	local per_pofang = self.data.per_pofang or self.data.per_pofang or -1
	local per_gongji = self.data.per_gongji or self.data.per_gongji or -1
	local per_maxhp = self.data.per_maxhp or self.data.per_maxhp or -1
	local goddess_gongji = self.data.goddess_gongji or self.data.fujia_shanghai or self.data.xiannv_gongji or -1
	local constant_mianshang = self.data.constant_mianshang or self.data.mian_shang or self.data.mianshang or -1
	local constant_zengshang = self.data.constant_zengshang or self.data.zeng_shang or self.data.zengshang or -1
	local huixinyiji = self.data.huixinyiji or self.data.hxyj or -1
	local huixinyiji_hurt_per = self.data.huixinyiji_hurt_per or self.data.hxyj_hurt_per or -1
	local pvp_jianshang = self.data.pvp_jianshang or self.data.reduce_hurt or -1
	local pvp_zengshang = self.data.pvp_zengshang or self.data.add_hurt or -1
	local pve_jianshang = self.data.pve_jianshang or self.data.pve_jianshang_per or -1
	local pve_zengshang = self.data.pve_zengshang or self.data.pve_zengshang_per or -1
	local per_baoji_hurt = self.data.per_baoji_hurt or -1
	local per_kang_bao_hurt = self.data.per_kang_bao_hurt or -1
	local zhufuyiji_per = self.data.zhufuyiji_per or self.data.per_zhufuyiji or -1
	local gedang_per = self.data.gedang_per or self.data.per_gedang or -1
	local gedang_dikang_per = self.data.gedang_dikang_per or self.data.per_gedang_dikang or -1
	local gedang_jianshang = self.data.gedang_jianshang or -1
	local skill_zengshang = self.data.skill_zengshang or -1
	local skill_jianshang = self.data.skill_jianshang or -1
	local mingzhong_per = self.data.mingzhong_per or self.data.per_mingzhong or -1
	local shanbi_per = self.data.shanbi_per or self.data.per_shanbi or -1
	local dikang_shanghai = self.data.dikang_shanghai or self.data.dikang_shanghai or -1
	if hp and hp >= 0 then
		self.node_list["PanelShowHP"]:SetActive(true)
		self.node_list["TxtHp"].text.text = string.format(Language.Tips.Attribute.Hp,hp)
	else
		self.node_list["PanelShowHP"]:SetActive(false)
	end

	if gong_ji and gong_ji >= 0 then
		self.node_list["PanelShowGongji"]:SetActive(true)
		self.node_list["TxtGongji"].text.text = string.format(Language.Tips.Attribute.Gongji,gong_ji)
	else
		self.node_list["PanelShowGongji"]:SetActive(false)
	end

	if fang_yu and fang_yu >= 0 then
		self.node_list["PanelShowfangyu"]:SetActive(true)
		self.node_list["TxtFangyu"].text.text = string.format(Language.Tips.Attribute.Fangyu,fang_yu)
	else
		self.node_list["PanelShowfangyu"]:SetActive(false)
	end

	if ming_zhong and ming_zhong >= 0 then
		self.node_list["PanelShowmingzhong"]:SetActive(true)
		self.node_list["TxtMingzhong"].text.text = string.format(Language.Tips.Attribute.Mingzhong,ming_zhong)
	else
		self.node_list["PanelShowmingzhong"]:SetActive(false)
	end

	if shan_bi and shan_bi >= 0 then
		self.node_list["PanelShowShanbi"]:SetActive(true)
		self.node_list["TxtShanbi"].text.text = string.format(Language.Tips.Attribute.Shanbi,shan_bi)
	else
		self.node_list["PanelShowShanbi"]:SetActive(false)
	end

	if bao_ji and bao_ji >= 0 then
		self.node_list["PanelShowBaoji"]:SetActive(true)
		self.node_list["TxtBaoji"].text.text = string.format(Language.Tips.Attribute.Baoji,bao_ji)
	else
		self.node_list["PanelShowBaoji"]:SetActive(false)
	end

	if jian_ren and jian_ren >= 0 then
		self.node_list["PanelShowKangbao"]:SetActive(true)
		self.node_list["TxtKangbao"].text.text = string.format(Language.Tips.Attribute.KangBao,jian_ren)
	else
		self.node_list["PanelShowKangbao"]:SetActive(false)
	end

	if per_jingzhun and per_jingzhun >=0 then
		self.node_list["PanelPerJingZhun"]:SetActive(true)
		self.node_list["TxtPerJingZhun"].text.text = string.format(Language.Tips.Attribute.PerJingZhun, per_jingzhun)
	else
		self.node_list["PanelPerJingZhun"]:SetActive(false)
	end

	if dikang_shanghai and dikang_shanghai >= 0 then
		self.node_list["PaneDikangShanghai"]:SetActive(true)
		self.node_list["TxtDiKangShangHai"].text.text = string.format(Language.Tips.Attribute.DiKangShangHai, dikang_shanghai)
	else
		self.node_list["PaneDikangShanghai"]:SetActive(false)
	end

	if self.no_pofang then
		self.node_list["PaneDikangShanghai"]:SetActive(true)
		self.node_list["PanelPerJingZhun"]:SetActive(false)
	else
		self.node_list["PaneDikangShanghai"]:SetActive(false)
	end


	-- if per_baoji and per_baoji >=0 then
	-- 	self.node_list["BaoJi_Per"]:SetActive(true)
	-- 	self.node_list["TxtBaoJiPer"].text.text = string.format(Language.Tips.Attribute.BaoJiPer, per_baoji / 100 .. "%")
	-- else
	-- 	self.node_list["BaoJi_Per"]:SetActive(false)
	-- end

	-- if per_kang_bao and per_kang_bao >=0 then
	-- 	self.node_list["KangBao_Per"]:SetActive(true)
	-- 	self.node_list["TxtKangBaoPer"].text.text = string.format(Language.Tips.Attribute.KangBaoPer, per_kang_bao / 100 .. "%")
	-- else
	-- 	self.node_list["KangBao_Per"]:SetActive(false)
	-- end

	-- if per_pofang and per_pofang >=0 then
	-- 	self.node_list["PoFang_Per"]:SetActive(true)
	-- 	self.node_list["TxtPoFangPer"].text.text = string.format(Language.Tips.Attribute.PoFangPer, per_pofang / 100 .. "%")
	-- else
	-- 	self.node_list["PoFang_Per"]:SetActive(false)
	-- end

	-- if per_mianshang and per_mianshang >=0 then
	-- 	self.node_list["MiShang_Per"]:SetActive(true)
	-- 	self.node_list["TxtMiShangPer"].text.text = string.format(Language.Tips.Attribute.MiShangPer, per_mianshang / 100 .. "%")
	-- else
	-- 	self.node_list["MiShang_Per"]:SetActive(false)
	-- end

	-- if skill_zengshang and skill_zengshang >=0 then
	-- 	self.node_list["Skill_ZengShang"]:SetActive(true)
	-- 	self.node_list["TxtSkillZengShang"].text.text = string.format(Language.Tips.Attribute.SkillZengShang, skill_zengshang / 100 .. "%")
	-- else
	-- 	self.node_list["Skill_ZengShang"]:SetActive(false)
	-- end

	-- if skill_jianshang and skill_jianshang >=0 then
	-- 	self.node_list["SkillJianShang"]:SetActive(true)
	-- 	self.node_list["TxtSkillJianShang"].text.text = string.format(Language.Tips.Attribute.SkillJianShang, skill_jianshang / 100 .. "%")
	-- else
	-- 	self.node_list["SkillJianShang"]:SetActive(false)
	-- end

	-- if mingzhong_per and mingzhong_per >=0 then
	-- 	self.node_list["MingZhong_Per"]:SetActive(true)
	-- 	self.node_list["TxtMingZhongPer"].text.text = string.format(Language.Tips.Attribute.MingZhongPer, mingzhong_per / 100 .. "%")
	-- else
	-- 	self.node_list["MingZhong_Per"]:SetActive(false)
	-- end

	-- if shanbi_per and shanbi_per >=0 then
	-- 	self.node_list["ShanBi_Per"]:SetActive(true)
	-- 	self.node_list["TxtShanBiPer"].text.text = string.format(Language.Tips.Attribute.ShanBiPer, shanbi_per / 100 .. "%")
	-- else
	-- 	self.node_list["ShanBi_Per"]:SetActive(false)
	-- end



	local cap = CommonDataManager.GetCapability(self.data)
	if self.fight_text and self.fight_text.text then
		if cap and cap >= 0 then
			self.fight_text.text.text = cap
		else
			self.fight_text.text.text = 0
		end

		if self.not_show_zhanli then
			self.node_list["TxtFightPower"]:SetActive(false)
		else
			self.node_list["TxtFightPower"]:SetActive(true)
		end
	end
	self.node_list["TxtTipsName"].text.text = self.data.name or Language.JingLing.AttrTipTitle

	self:FromViewHighAttr()
end

function TipsAttrView:FromViewHighAttr()
	if not self.from_view then return end

	if self.from_view == "hunqi" then
		self.node_list["PanelShowHP"]:SetActive(true)
		self.node_list["PanelShowGongji"]:SetActive(true)
		self.node_list["PanelShowfangyu"]:SetActive(true)
		self.node_list["PanelShowmingzhong"]:SetActive(false)
		self.node_list["PanelShowShanbi"]:SetActive(false)
		self.node_list["PanelShowBaoji"]:SetActive(false)
		self.node_list["PanelShowKangbao"]:SetActive(false)
		self.node_list["PanelPerJingZhun"]:SetActive(false)
		self.node_list["PaneDikangShanghai"]:SetActive(false)
	elseif self.from_view == "baobao_guard" then
		self.node_list["PanelShowmingzhong"]:SetActive(false)
		self.node_list["PanelShowShanbi"]:SetActive(false)
		self.node_list["PanelShowBaoji"]:SetActive(false)
		self.node_list["PanelShowKangbao"]:SetActive(false)
		self.node_list["PanelPerJingZhun"]:SetActive(false)
		self.node_list["PaneDikangShanghai"]:SetActive(false)		
	elseif self.from_view == "xingxiang" then
		self.node_list["PanelShowmingzhong"]:SetActive(false)
		self.node_list["PanelShowShanbi"]:SetActive(false)
		self.node_list["PanelShowBaoji"]:SetActive(false)
		self.node_list["PanelShowKangbao"]:SetActive(false)
		self.node_list["PanelPerJingZhun"]:SetActive(false)
		self.node_list["PaneDikangShanghai"]:SetActive(false)
	end
end