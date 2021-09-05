CheckMaskView = CheckMaskView or BaseClass(BaseRender)
function CheckMaskView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckMaskView:__delete()
	self.mask_attr = nil
	self.fight_text = nil
end


function CheckMaskView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end


function CheckMaskView:OnFlush()
	if self.mask_attr then
		local grade_info = MaskData.Instance:GetMaskGradeCfgInfoByGrade(self.mask_attr.grade)
		if nil == grade_info then return end
		local image_info = MaskData.Instance:GetMaskImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.node_list["TxtName"].text.text = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = MaskData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(MaskShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local zizhi_hp = zi_zhi_cfg.maxhp * self.mask_attr.shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * self.mask_attr.shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * self.mask_attr.shuxingdan_count

		self.node_list["TxtGongji"].text.text = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.node_list["TxtFangyu"].text.text = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.node_list["TxtShengming"].text.text = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.node_list["TxtMingzhong"].text.text = switch_attr_list.ming_zhong or 0 
		self.node_list["TxtShanbi"].text.text = switch_attr_list.shan_bi or 0 
		self.node_list["TxtBaoji"].text.text = switch_attr_list.bao_ji or 0
		self.node_list["TxtKangbao"].text.text = switch_attr_list.jian_ren or 0 
		self.node_list["TxtZengshang"].text.text = switch_attr_list.per_pofang or 0 
		self.node_list["TxtMianshang"].text.text = switch_attr_list.per_mianshang or 0 

		self.node_list["GongJi"]:SetActive(switch_attr_list.gong_ji and switch_attr_list.gong_ji + zizhi_gongji > 0)
		self.node_list["FangYu"]:SetActive(switch_attr_list.fang_yu and switch_attr_list.fang_yu + zizhi_fangyu > 0)
		self.node_list["ShengMing"]:SetActive(switch_attr_list.max_hp and switch_attr_list.max_hp + zizhi_hp > 0)
		self.node_list["MingZhong"]:SetActive(switch_attr_list.ming_zhong and switch_attr_list.ming_zhong > 0)
		self.node_list["ShanBi"]:SetActive(switch_attr_list.shan_bi and switch_attr_list.shan_bi > 0)
		self.node_list["BaoJi"]:SetActive(switch_attr_list.bao_ji and switch_attr_list.bao_ji > 0)
		self.node_list["KangBao"]:SetActive(switch_attr_list.jian_ren and switch_attr_list.jian_ren > 0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.mask_attr.capability
		end

		self:SetModle()
	end
end

function CheckMaskView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.mask_attr then
		self.mask_attr = check_attr.mask_attr
		self:Flush()
	end
end

function CheckMaskView:SetModle()
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.mask_used_imageid = role_info.mask_info.grade == 1 and role_info.mask_info.grade or role_info.mask_info.grade - 1
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end
