CheckWingView = CheckWingView or BaseClass(BaseRender)

function CheckWingView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckWingView:__delete()
	self.wing_attr = nil
	self.fight_text = nil
end

function CheckWingView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckWingView:OnFlush()
	if self.wing_attr then
		self.node_list["TxtGongji"].text.text = self.wing_attr.gong_ji
		self.node_list["TxtFanyu"].text.text = self.wing_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.wing_attr.max_hp
		self.node_list["TxtMingzhong"].text.text = self.wing_attr.ming_zhong
		self.node_list["TxtShanbi"].text.text = self.wing_attr.shan_bi
		self.node_list["TxtBaoji"].text.text = self.wing_attr.bao_ji
		self.node_list["TxtKangbao"].text.text = self.wing_attr.jian_ren
		self.node_list["TxtZengshang"].text.text = self.wing_attr.per_pofang
		self.node_list["TxtMianshang"].text.text = self.wing_attr.per_mianshang
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.wing_attr.capability
		end
		local grade = self.wing_attr.client_grade + 1

			local used_imageid = self.wing_attr.used_imageid
			local is_spec = false
			if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
				is_spec = true
				used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
			end
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..WingData.Instance:GetImageListInfo(used_imageid, is_spec).image_name.."</color>"


		if self.wing_attr.client_grade == 0 then

			self.node_list["TxtName"].text.text = name_str
		else

			local grade_txt = CheckData.Instance:GetGradeName(self.wing_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color]) 

		end
		self:SetModle()
	end
end

function CheckWingView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.wing_attr then
		self.wing_attr = check_attr.wing_attr
		self:Flush()
	end
end

function CheckWingView:SetModle()
	local role_info = CheckData.Instance:GetRoleInfo()

	local info = {}
	info.wing_info = {used_imageid = role_info.wing_info.grade == 1 and role_info.wing_info.grade or role_info.wing_info.grade - 1}
	info.prof = role_info.prof
	info.sex = role_info.sex
	local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.shizhuang_part_list = {{image_id = 0}, {image_id = fashion_id}}

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS)
			if base_prof == GameEnum.ROLE_PROF_3 or base_prof == GameEnum.ROLE_PROF_2 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -155, 0)
			elseif base_prof == GameEnum.ROLE_PROF_1 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 170, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -170, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	UIScene:SetRoleModelResInfo(info, true, false, true, true, false, true)
	-- UIScene:SetRoleModelResInfo(info, false, false, true, true, false, true)
	UIScene:SetActionEnable(false)

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)
end
