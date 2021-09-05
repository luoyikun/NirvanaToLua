CheckFightMountView = CheckFightMountView or BaseClass(BaseRender)

function CheckFightMountView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckFightMountView:__delete()
	self.mount_attr = nil
	self.fight_text = nil
end

function CheckFightMountView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckFightMountView:OnFlush()
 	if self.mount_attr then
 		self.node_list["TxtGongji"].text.text = self.mount_attr.gong_ji
		self.node_list["TxtFanyu"].text.text = self.mount_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.mount_attr.max_hp
		self.node_list["TxtMingzhong"].text.text = self.mount_attr.ming_zhong
		self.node_list["TxtShanbi"].text.text = self.mount_attr.shan_bi
		self.node_list["TxtBaoji"].text.text = self.mount_attr.bao_ji
		self.node_list["TxtKangbao"].text.text = self.mount_attr.jian_ren
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.mount_attr.capability
		end
		local grade = self.mount_attr.client_grade + 1

			local fightmount_cfg = FightMountData.Instance:GetMountGradeCfg(grade)
			if nil == fightmount_cfg then return end
			local image_id = fightmount_cfg.image_id
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FightMountData.Instance:GetMountImageCfg(image_id)[image_id].image_name.."</color>"


		if self.mount_attr.client_grade == 0 then

			self.node_list["TxtName"].text.text = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(self.mount_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
		end
		self:SetModle()
 	end
end

function CheckFightMountView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.fight_attr then
		self.mount_attr = check_attr.fight_attr
		self:Flush()
	end
end

function CheckFightMountView:SetModle()
	local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
	if self.mount_attr.client_grade + 1 ~= 0 then
		if self.mount_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = FightMountData.Instance:GetSpecialImagesCfg()[self.mount_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			if self.mount_attr.used_imageid == 0 then
				res_id = 0
			else
				res_id = FightMountData.Instance:GetMountImageCfg()[self.mount_attr.used_imageid].res_id
			end
		end
		local mount_res_id = res_id
		local call_back = function(model, obj)
			if obj then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
			end
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end
		UIScene:SetModelLoadCallBack(call_back)
		local bundle, asset = ResPath.GetFightMountModel(mount_res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "fightmount")
		transform.rotation = Quaternion.Euler(25, -168, 0)
		UIScene:SetCameraTransform(transform)
	end
end