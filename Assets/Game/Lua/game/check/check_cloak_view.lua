CheckCloakView = CheckCloakView or BaseClass(BaseRender)

function CheckCloakView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckCloakView:__delete()
	self.cloak_attr = nil
	self.fight_text = nil
end


function CheckCloakView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckCloakView:OnFlush()
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
	info.is_normal_fashion = is_used_special_img == 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	-- local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
	-- info.appearance.fashion_wuqi = wuqi_id
	info.appearance.fashion_body = fashion_id

	if self.cloak_attr then
		self.node_list["TxtGongji"].text.text = self.cloak_attr.gong_ji
		self.node_list["TxtFangyu"].text.text = self.cloak_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.cloak_attr.max_hp
		self.node_list["TxtKangbao"].text.text = self.cloak_attr.jian_ren
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.cloak_attr.capability
		end

		if self.cloak_attr.capability > 0 and self.cloak_attr.used_imageid <= 0 then
			local cfg = CloakData.Instance:GetCloakLevelCfg(self.cloak_attr.cloak_level)
			info.cloak_info.used_imageid = cfg and cfg.active_image or 0
		end

		if self.cloak_attr.capability <= 0 and self.cloak_attr.used_imageid == 0 then
			self.node_list["TxtName"].text.text = Language.Advance.NotActiveImg
		else
			local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(self.cloak_attr.cloak_level)
			if cloak_level_cfg == nil then return end
			local used_imageid = cloak_level_cfg.active_image
			if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
				used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
			end

			local color = math.floor((used_imageid - 1) / 2) + 1
			local name_str = " <color="..SOUL_NAME_COLOR[color]..">" .. "Lv." .. self.cloak_attr.cloak_level  .." " .. CloakData.Instance:GetImageListInfo(used_imageid).image_name.."</color>"
			self.node_list["TxtName"].text.text = name_str
		end
		self:SetModle(info)
	end
end

function CheckCloakView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.cloak_attr then
		self.cloak_attr = check_attr.cloak_attr
		self:Flush()
	end
end

function CheckCloakView:SetModle(info)
	local call_back = function(model, obj)
		local prof = PlayerData.Instance:GetRoleBaseProf()
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS)
			if prof == GameEnum.ROLE_PROF_1 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 130, 0)
			elseif prof == GameEnum.ROLE_PROF_2 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 170, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 145, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, false)
	UIScene:SetActionEnable(false)

	local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)
end
