ShenYinTianXiangAttrView = ShenYinTianXiangAttrView or BaseClass(BaseView)

function ShenYinTianXiangAttrView:__init()
	self.ui_config = {{"uis/views/shenyinview_prefab", "TianXiangAttrTipAllView"}}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.view_cfg = {}
	self.index_cfg = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenYinTianXiangAttrView:__delete()

end

function ShenYinTianXiangAttrView:ReleaseCallBack()
	self.attr_list = {}
	self.capability = nil
	self.active_num_2 = nil
	self.active_num_3 = nil
	self.show_baoji = nil
	self.show_jianren = nil
	self.show_mingzhong = nil
	self.show_shanbi = nil
	self.baoji_attr = nil
	self.mianshang_attr = nil
	self.mingzhong_attr = nil
	self.shanbi_attr = nil
	self.fight_text = nil
end

function ShenYinTianXiangAttrView:LoadCallBack()
	self.attr_list = {}
	for i = 1, 3 do
		self.attr_list[i] = {}
		self.attr_list[i].gongji_attr = self.node_list["GongJiTxt" .. i]
		self.attr_list[i].fangyu_attr = self.node_list["FangyuTxt" .. i]
		self.attr_list[i].hp_attr = self.node_list["HpTxt" .. i]
		self.attr_list[i].show_gongji = self.node_list["ShowGongJiTxt" .. i]
		self.attr_list[i].show_fangyu = self.node_list["ShowFangYuTxt" .. i]
		self.attr_list[i].show_hp = self.node_list["ShowHpTxt" .. i]
	end
	--self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["CapabilityTxt"], "FightPower3")
end

function ShenYinTianXiangAttrView:OpenCallBack()
	self:Flush()
end

function ShenYinTianXiangAttrView:OnClickClose()
	self:Close()
end

function ShenYinTianXiangAttrView:ShowIndexCallBack(index)
	self:Flush()
end


function ShenYinTianXiangAttrView:OnFlush(param_t)
	self.bead_list = ShenYinData.Instance:GetBeadList()
	local att = ShenYinData.Instance:CountAtt()
	local sea, tx, sea_len, tx_len= ShenYinData.Instance:CountSeasonsAndTianXiang()

	local info_data = {}
	table.insert(info_data, att)
	table.insert(info_data, sea)
	table.insert(info_data, tx)
	local combat_power = CommonStruct.Attribute()
	for k, v in pairs(info_data) do
		self.attr_list[k].gongji_attr.text.text = string.format(Language.ShenYin.GongJiValue,v.gong_ji)
		self.attr_list[k].fangyu_attr.text.text = string.format(Language.ShenYin.FangYuValue,v.fang_yu)
		self.attr_list[k].hp_attr.text.text = string.format(Language.ShenYin.HpValue,v.max_hp)
		self.attr_list[k].show_gongji:SetActive(v.gong_ji >= 0)
		self.attr_list[k].show_fangyu:SetActive(v.fang_yu >= 0)
		self.attr_list[k].show_hp:SetActive(v.max_hp >= 0)
		combat_power = CommonDataManager.AddAttributeAttr(combat_power, v)
	end
	self.node_list["NumTxt2"].text.text = string.format(Language.ShenYin.Activate,sea_len)
	self.node_list["NumTxt3"].text.text = string.format(Language.ShenYin.Activate,tx_len)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text =  Language.Common.ZhanLi .. ":" .. CommonDataManager.GetCapability(combat_power)
	end
	self.node_list["ShowBaojiTxt"]:SetActive(att.bao_ji >= 0)
	self.node_list["ShowKangBaoTxt"]:SetActive(att.jian_ren >= 0)
	self.node_list["ShowMingzhongTxt"]:SetActive(att.ming_zhong >= 0)
	self.node_list["ShowShanbiTxt"]:SetActive(att.shan_bi >= 0)
	self.node_list["BaoJiTxt1"].text.text = string.format(Language.ShenYin.BaoJiValue,att.bao_ji)
	self.node_list["KangBaoTxt"].text.text = string.format(Language.ShenYin.KangBaoValue,att.jian_ren)
	self.node_list["MingZhongTxt"].text.text = string.format(Language.ShenYin.MingZhongValue,att.ming_zhong)
	self.node_list["ShanBiTxt"].text.text = string.format(Language.ShenYin.ShanBiValue,att.shan_bi)
end


