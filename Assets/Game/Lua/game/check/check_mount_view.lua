CheckMountView = CheckMountView or BaseClass(BaseRender)

function CheckMountView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckMountView:__delete()
	self.mount_attr = nil
	self.fight_text = nil
end

function CheckMountView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckMountView:OnFlush()
	if self.mount_attr then
		local mount_attr = self.mount_attr
		self.node_list["TxtGongji"].text.text = self.mount_attr.gong_ji
		self.node_list["TxtFangyu"].text.text = self.mount_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.mount_attr.max_hp
		self.node_list["TxtMingzhong"].text.text = self.mount_attr.ming_zhong
		self.node_list["TxtShanbi"].text.text = self.mount_attr.shan_bi
		self.node_list["TxtBaoji"].text.text = self.mount_attr.bao_ji
		self.node_list["TxtKangbao"].text.text = self.mount_attr.jian_ren
		self.node_list["TxtZengshang"].text.text = self.mount_attr.per_pofang
		self.node_list["TxtMianshang"].text.text = self.mount_attr.per_mianshang
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.mount_attr.capability
		end
		local grade = self.mount_attr.client_grade + 1

		local mount_cfg = MountData.Instance:GetMountGradeCfg(grade)
		if mount_cfg == nil then return end
		local image_id = mount_cfg.image_id
		local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
		local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..MountData.Instance:GetMountImageCfg(image_id)[image_id].image_name.."</color>"


		if self.mount_attr.client_grade == 0 then
			self.node_list["TxtName"].text.text = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(self.mount_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color]) 
		end
		self:SetModle()
	end
end

function CheckMountView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.mount_attr then
		self.mount_attr = check_attr.mount_attr
		self:Flush()
	end
end

function CheckMountView:SetModle()
	
	if self.mount_attr.client_grade + 1 ~= 0 then
		if self.mount_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = MountData.Instance:GetSpecialImagesCfg()[self.mount_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = MountData.Instance:GetMountImageCfg()[self.mount_attr.used_imageid].res_id
		end
		local mount_res_id = res_id

		local call_back = function(model, obj)
			model:SetTrigger(ANIMATOR_PARAM.REST)
			if obj then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -60, 0)
			end
		end
		UIScene:SetModelLoadCallBack(call_back)
		local bundle, asset = ResPath.GetMountModel(mount_res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		-- UIScene:LoadSceneEffect(bundle, asset)
		UIScene:ModelBundle(bundle_list, asset_list)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
		transform.rotation = Quaternion.Euler(0, -168, 0)
		UIScene:SetCameraTransform(transform)
	end
end