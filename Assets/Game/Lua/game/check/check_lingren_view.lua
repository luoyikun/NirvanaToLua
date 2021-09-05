CheckLingRenView = CheckLingRenView or BaseClass(BaseRender)
function CheckLingRenView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckLingRenView:__delete()
	self.lingren_attr = nil
	self.fight_text = nil
end


function CheckLingRenView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end


function CheckLingRenView:OnFlush()
	if self.lingren_attr then
		local cur_attr = LingRenData.Instance:GetLevelAttrCfg(self.lingren_attr.level)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(ShenBingShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local zizhi_hp = zi_zhi_cfg.maxhp * self.lingren_attr.shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * self.lingren_attr.shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * self.lingren_attr.shuxingdan_count

		self.node_list["TxtGongji"].text.text = (cur_attr.gongji or 0) + zizhi_gongji
		self.node_list["TxtFangyu"].text.text = (cur_attr.fangyu or 0) + zizhi_fangyu
		self.node_list["TxtShengming"].text.text = (cur_attr.maxhp or 0) + zizhi_hp 
		self.node_list["TxtMingzhong"].text.text = cur_attr.ming_zhong or 0 
		self.node_list["TxtShanbi"].text.text = cur_attr.shan_bi or 0 
		self.node_list["TxtBaoji"].text.text = cur_attr.baoji or 0
		self.node_list["TxtKangbao"].text.text = cur_attr.jian_ren or 0 
		self.node_list["TxtZengshang"].text.text = cur_attr.per_pofang or 0 
		self.node_list["TxtMianshang"].text.text = cur_attr.per_mianshang or 0 
		self.node_list["TxtPoJia"].text.text = cur_attr.per_jingzhun or 0 

		self.node_list["GongJi"]:SetActive(cur_attr.gongji and cur_attr.gongji + zizhi_gongji > 0)
		self.node_list["FangYu"]:SetActive(cur_attr.fangyu and cur_attr.fangyu + zizhi_fangyu > 0)
		self.node_list["ShengMing"]:SetActive(cur_attr.maxhp and cur_attr.maxhp + zizhi_hp > 0)
		self.node_list["MingZhong"]:SetActive(cur_attr.ming_zhong and cur_attr.ming_zhong > 0)
		self.node_list["ShanBi"]:SetActive(cur_attr.shan_bi and cur_attr.shan_bi > 0)
		self.node_list["BaoJi"]:SetActive(cur_attr.baoji and cur_attr.baoji > 0)
		-- self.node_list["KangBao"]:SetActive(cur_attr.jian_ren and cur_attr.jian_ren > 0)
		self.node_list["KangBao"]:SetActive(false)
		-- self.node_list["JingZhun"]:SetActive(true)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.lingren_attr.capability
		end

		self.node_list["TxtName"].text.text = string.format("Lv.%s ", self.lingren_attr.level) .." " .. Language.Common.ShenBingName

		self:SetModle()
	end
end

function CheckLingRenView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.lingren_attr then
		self.lingren_attr = check_attr.lingren_attr
		self:Flush()
	end
end

function CheckLingRenView:SetModle()
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetHunQiModel(17007)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end
