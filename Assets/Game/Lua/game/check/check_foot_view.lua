CheckFootView = CheckFootView or BaseClass(BaseRender)

function CheckFootView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckFootView:__delete()
	self.foot_attr = nil
	self.fight_text = nil
end

function CheckFootView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckFootView:OnFlush()
	if self.foot_attr then
		self.node_list["TxtGongji"].text.text = self.foot_attr.gong_ji
		self.node_list["TxtFangyu"].text.text = self.foot_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.foot_attr.max_hp
		self.node_list["TxtMingzhong"].text.text = self.foot_attr.ming_zhong
		self.node_list["TxtShanbi"].text.text = self.foot_attr.shan_bi
		self.node_list["TxtBaoji"].text.text = self.foot_attr.bao_ji
		self.node_list["Txtkangbao"].text.text = self.foot_attr.jian_ren
		self.node_list["TxtZengshang"].text.text = self.foot_attr.per_pofang
		self.node_list["TxtMianshang"].text.text = self.foot_attr.per_mianshang
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.foot_attr.capability
		end
		local grade = self.foot_attr.client_grade + 1

			local foot_cfg = FootData.Instance:GetFootGradeCfg(grade)
			if nil == foot_cfg then return end
			local image_id = foot_cfg.image_id
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FootData.Instance:GetFootImageCfg(image_id)[image_id].image_name.."</color>"

		if self.foot_attr.client_grade == 0 then

			self.node_list["TxtName"].text.text = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(self.foot_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])

		end
		self:SetModle()
	end
end

function CheckFootView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.foot_attr then
		self.foot_attr = check_attr.foot_attr
		self:Flush()
	end
end

function CheckFootView:SetModle()
	local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	end
	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -90, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = TableCopy(role_info)
	info.appearance = {}
	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, true, true, true)
	UIScene:SetActionEnable(false)

	local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)
end


function CheckFootView:StopFoot()
	local role_info = CheckData.Instance:GetRoleInfo()
	UIScene:SetRoleModelResInfo(role_info, true, true, true, true, false, true)
end

