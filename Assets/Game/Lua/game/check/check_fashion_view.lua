CheckFaShionView = CheckFaShionView or BaseClass(BaseRender)

function CheckFaShionView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckFaBaoView:__delete()
	self.fight_text = nil
end

function CheckFaShionView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckFaShionView:OnFlush()
	if self.fashion_attr then
		local fashion_attr = self.fashion_attr
		self.node_list["TxtGongji"].text.text = self.fashion_attr.gong_ji
		self.node_list["TxtFangyu"].text.text = self.fashion_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.fashion_attr.max_hp
		self.node_list["TxtMingzhong"].text.text = self.fashion_attr.ming_zhong
		self.node_list["TxtShanbi"].text.text = self.fashion_attr.shan_bi
		self.node_list["TxtBaoji"].text.text = self.fashion_attr.bao_ji
		self.node_list["TxtKangbao"].text.text = self.fashion_attr.jian_ren
		self.node_list["TxtZengshang"].text.text = self.fashion_attr.per_pofang
		self.node_list["TxtMianshang"].text.text = self.fashion_attr.per_mianshang
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.fashion_attr.capability
		end
		local grade = self.fashion_attr.client_grade + 1


		local fashion_cfg = FashionData.Instance:GetWuQiGradeCfg(grade)
		if nil == fashion_cfg then return end
		
		local image_id = fashion_cfg.image_id

		local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
		local image_id_cfg = FashionData.Instance:GetShizhuangImg(image_id)
		if not image_id_cfg then return end

		local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_id_cfg.image_name.."</color>"


		if self.fashion_attr.client_grade == 0 then

			self.node_list["TxtName"].text.text = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(self.fashion_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])

		end
		self:SetModle()
	end
end

function CheckFaShionView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.fashion_attr then
		self.fashion_attr = check_attr.fashion_attr
		self:Flush()
	end
end

function CheckFaShionView:SetModle()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info == nil then return end

	if self.fashion_attr.client_grade + 1 ~= 0 then
		local info = TableCopy(role_info)
		info.appearance = {}
		-- info.appearance.mask_used_imageid = role_info.mask_info.used_imageid
		-- info.appearance.toushi_used_imageid = role_info.head_info.used_imageid
		-- info.appearance.yaoshi_used_imageid = role_info.waist_info.used_imageid
		-- info.appearance.qilinbi_used_imageid = role_info.arm_info.used_imageid

		local fashion_info = role_info.shizhuang_part_list[2]
		local wuqi_info = role_info.shizhuang_part_list[1]
		local is_used_special_img = fashion_info.use_special_img
		info.is_normal_fashion = is_used_special_img == 0
		-- info.is_normal_wuqi = wuqi_info.use_special_img == 0
		local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		-- local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
		-- info.appearance.fashion_wuqi = wuqi_id
		info.appearance.fashion_body = fashion_id
		UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
		UIScene:ResetLocalPostion()

		local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(8, -168, 0)
		UIScene:SetCameraTransform(transform)
	end
end