CheckHaloView = CheckHaloView or BaseClass(BaseRender)

function CheckHaloView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckHaloView:__delete()
	self.halo_attr = nil
	self.fight_text = nil
end

function CheckHaloView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckHaloView:OnFlush()
	if self.halo_attr then
		self.node_list["TxtGongji"].text.text = self.halo_attr.gong_ji
		self.node_list["TxtFanyu"].text.text = self.halo_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.halo_attr.max_hp
		self.node_list["TxtMingzhong"].text.text = self.halo_attr.ming_zhong
		self.node_list["TxtShanbi"].text.text = self.halo_attr.shan_bi
		self.node_list["TxtBaoji"].text.text = self.halo_attr.bao_ji
		self.node_list["TxtKangbao"].text.text = self.halo_attr.jian_ren
		self.node_list["TxtZengsheng"].text.text = self.halo_attr.per_pofang
		self.node_list["TxtMianshang"].text.text = self.halo_attr.per_mianshang
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.halo_attr.capability
		end
		local grade = self.halo_attr.client_grade + 1

			local halo_cfg = HaloData.Instance:GetHaloGradeCfg(grade)
			if halo_cfg == nil then return end
			local image_id = halo_cfg.image_id
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..HaloData.Instance:GetHaloImageCfg(image_id)[image_id].image_name.."</color>"

		if self.halo_attr.client_grade == 0 then

			self.node_list["TxtName"].text.text = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(self.halo_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
		end
		self:SetModle()
	end
end

function CheckHaloView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.halo_attr then
		self.halo_attr = check_attr.halo_attr
		self:Flush()
	end
end

function CheckHaloView:SetModle()
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = TableCopy(role_info)
	info.appearance = {}
	-- info.appearance.mask_used_imageid = role_info.mask_info.used_imageid
	-- info.appearance.toushi_used_imageid = role_info.head_info.used_imageid
	-- info.appearance.yaoshi_used_imageid = role_info.waist_info.used_imageid
	-- info.appearance.qilinbi_used_imageid = role_info.arm_info.used_imageid

	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = use_special_img or 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
	-- info.appearance.fashion_wuqi = wuqi_id
	info.appearance.fashion_body = fashion_id
	-- UIScene:SetRoleModelResInfo(info, false, true, true, true, false, false, true)

	UIScene:SetRoleModelResInfo(info, true, true, false, true, false, true)
	-- UIScene:SetRoleModelResInfo(info, false, true, true, true, true, false, true)
	UIScene:ResetLocalPostion()
	UIScene:SetActionEnable(false)

	local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)
end


