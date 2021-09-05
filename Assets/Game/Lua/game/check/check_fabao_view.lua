CheckFaBaoView = CheckFaBaoView or BaseClass(BaseRender)

function CheckFaBaoView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckFaBaoView:__delete()
	self.fight_text = nil
end

function CheckFaBaoView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckFaBaoView:OnFlush()
	if self.fabao_attr then
		local fabao_attr = self.fabao_attr
		self.node_list["TxtGongji"].text.text = self.fabao_attr.gong_ji
		self.node_list["TxtFangyu"].text.text = self.fabao_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.fabao_attr.max_hp
		self.node_list["TxtMingzhong"].text.text = self.fabao_attr.ming_zhong
		self.node_list["TxtShanbi"].text.text = self.fabao_attr.shan_bi
		self.node_list["TxtBaoji"].text.text = self.fabao_attr.bao_ji
		self.node_list["TxtKangbao"].text.text = self.fabao_attr.jian_ren
		self.node_list["TxtZengshang"].text.text = self.fabao_attr.per_pofang
		self.node_list["TxtMianshang"].text.text = self.fabao_attr.per_mianshang
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.fabao_attr.capability
		end
		local grade = self.fabao_attr.client_grade + 1

			local fabao_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(grade)
			if fabao_cfg == nil then return end
			local image_id = fabao_cfg.image_id
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FaBaoData.Instance:GetFaBaoImageCfg(image_id)[image_id].image_name.."</color>"


		if self.fabao_attr.client_grade == 0 then
			self.node_list["TxtName"].text.text = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(self.fabao_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])


		end
		self:SetModle()
	end
end

function CheckFaBaoView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.fabao_attr then
		self.fabao_attr = check_attr.fabao_attr
		self:Flush()
	end
end

function CheckFaBaoView:SetModle()
	if self.fabao_attr.client_grade + 1 ~= 0 then

		if self.fabao_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = FaBaoData.Instance:GetSpecialImagesCfg()[self.fabao_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = FaBaoData.Instance:GetFaBaoImageCfg()[self.fabao_attr.used_imageid].res_id
		end
		local fabao_res_id = res_id

		local call_back = function(model, obj)
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end
		UIScene:SetModelLoadCallBack(call_back)
		local bundle, asset = ResPath.GetFaBaoModel(fabao_res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "baoju")
		transform.rotation = Quaternion.Euler(0, -168, 0)
		UIScene:SetCameraTransform(transform)
	end
end