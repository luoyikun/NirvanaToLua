TipsPlayerAttrView = TipsPlayerAttrView or BaseClass(BaseView)

function TipsPlayerAttrView:__init()
	self.ui_config = {{"uis/views/player_prefab", "TipsPlayerAttrView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsPlayerAttrView:__delete()

end

function TipsPlayerAttrView:LoadCallBack()
	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function TipsPlayerAttrView:ReleaseCallBack()
	-- 清理变量和对象
end

function TipsPlayerAttrView:SetChckInfoData(check_info)
	self.check_info = check_info
end

function TipsPlayerAttrView:CloseCallBack()
	self.check_info = nil
end

function TipsPlayerAttrView:OpenCallBack()
	self:Flush()
end

function TipsPlayerAttrView:OnFlush()
	local vo = self.check_info or GameVoManager.Instance:GetMainRoleVo()

	self.node_list["Hp"].text.text = vo.base_max_hp
	self.node_list["GongJi"].text.text = vo.base_gongji
	self.node_list["FangYu"].text.text = vo.base_fangyu
	self.node_list["MingZhong"].text.text = vo.base_mingzhong
	self.node_list["ShanBi"].text.text = vo.base_shanbi
	self.node_list["BaoJi"].text.text = vo.base_baoji
	self.node_list["KangBao"].text.text = vo.base_jianren
	self.node_list["Speed"].text.text = vo.base_move_speed
	self.node_list["FuJiaShangHai"].text.text = vo.base_fujia_shanghai + vo.base_constant_zengshang 			-- 增伤+女神伤害 类型50 + 59
	self.node_list["DiKangShnagHai"].text.text = vo.base_dikang_shanghai + vo.base_constant_mianshang			-- 抵抗+女神抵抗 类型51 + 60

	self.node_list["ShangHaiJianMian"].text.text = string.format("%.1f", vo.base_per_mianshang / 100) .. "%"
	self.node_list["ShangHaiJiaCheng"].text.text = string.format("%.1f", vo.base_per_pofang / 100) .. "%"
	self.node_list["PoJia"].text.text = string.format("%.1f", vo.base_per_jingzhun / 100) .. "%"

	self.node_list["SkillZengShang"].text.text = string.format("%.1f", vo.base_skill_zengshang / 100) .. "%"
	self.node_list["SkillJianShang"].text.text = string.format("%.1f", vo.base_skill_jianshang / 100) .. "%"
	self.node_list["MingZhongLv"].text.text = string.format("%.1f", vo.base_mingzhong_per / 100) .. "%"
	self.node_list["ShanBiLv"].text.text = string.format("%.1f", vo.base_shanbi_per / 100) .. "%"
	self.node_list["BaoJiLv"].text.text = string.format("%.1f", vo.base_per_baoji / 100) .. "%"
	self.node_list["BaoJiShangHai"].text.text = string.format("%.1f", vo.base_per_baoji_hurt / 100) .. "%"
	self.node_list["KangBaoLv"].text.text = string.format("%.1f", vo.base_per_kangbao / 100) .. "%"
	self.node_list["BaoShangDiKang"].text.text = string.format("%.1f", vo.base_per_kangbao_hurt / 100) .. "%"
	self.node_list["HuiXinLv"].text.text = string.format("%.1f", vo.base_huixinyiji / 100) .. "%"
	self.node_list["HuiXinShangHai"].text.text = string.format("%.1f", vo.base_huixinyiji_hurt_per / 100) .. "%"
	self.node_list["GeDangLv"].text.text = string.format("%.1f", vo.base_gedang_per / 100) .. "%"
	self.node_list["GeDangJianMian"].text.text = string.format("%.1f", vo.base_gedang_jianshang / 100) .. "%"
	self.node_list["PVEShangHaiJiaCheng"].text.text = string.format("%.1f", vo.pve_zengshang / 100) .. "%"
	self.node_list["PVEShangHaiJianMian"].text.text = string.format("%.1f", vo.pve_jianshang / 100) .. "%"
	self.node_list["PVPShangHaiJiaCheng"].text.text = string.format("%.1f", vo.pvp_zengshang / 100) .. "%"
	self.node_list["PVPShangHaiJianMian"].text.text = string.format("%.1f", vo.pvp_jianshang / 100) .. "%"
	self.node_list["ZhuFuYIJiLv"].text.text = string.format("%.1f", vo.base_zhufuyiji_per / 100) .. "%"
end
