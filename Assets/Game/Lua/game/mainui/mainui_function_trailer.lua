MainUIFunctiontrailer = MainUIFunctiontrailer or BaseClass(BaseRender)

local FunTrailerType =
{
	Icon = 0,
	Model = 1,
}

local FunResType =
{
	XIAN_NV = "Goddess",
	MOUNT = "Mount",
	WING = "Wing",
	HALO = "Halo",
	SPIRIT = "Spirit",
	SHENGONG = "GoddessWeapon",
	SHENYI = "Shenyi",
	Role = "Role",
	Weapon = "Weapon",
}

function MainUIFunctiontrailer:__init()
	self.can_reward = false

	self.node_list["BtnTrailer"].button:AddClickListener(BindTool.Bind(self.TrailerClick, self))
	self.node_list["Display"].button:AddClickListener(BindTool.Bind(self.TrailerClick, self))
end

function MainUIFunctiontrailer:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function MainUIFunctiontrailer:OnFlush()
	local cur_trailer_cfg = OpenFunData.Instance:GetCurTrailerCfg()
	self:FlushView(cur_trailer_cfg)
end
function MainUIFunctiontrailer:FlushView(info)
	local scene_type = Scene.Instance:GetSceneType()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if info then
		self.can_reward = level >= info.end_level and OpenFunData.Instance:GetTrailerLastRewardId() < info.id
	elseif self.info then
		self.can_reward = level >= self.info.end_level and OpenFunData.Instance:GetTrailerLastRewardId() < self.info.id
	end

	self.node_list["Effect"]:SetActive(self.can_reward)
	if info and scene_type == 0 then
		self.info = info
		self.root_node:SetActive(true)
		if info.is_model == FunTrailerType.Icon or self.can_reward then
			self.node_list["model_go"]:SetActive(false)
			self.node_list["BtnTrailer"]:SetActive(true)
			local bundle, asset = ResPath.GetMainIcon(info.icon_view)
			self.node_list["ImgTrailer"].image:LoadSpriteAsync(bundle, asset .. ".png")
			if self.node_list["IconName"] then
				self.node_list["IconName"].image:LoadSpriteAsync(bundle, asset .. "Name", function()
					self.node_list["IconName"].image:SetNativeSize()
				end)
			end
		elseif info.is_model == FunTrailerType.Model then
			local display_type = 0
			local res_type = ""
			self.node_list["model_go"]:SetActive(true)
			if not self.model_view then
				self.model_view = RoleModel.New()
				self.model_view:SetDisplay(self.node_list["model"].ui3d_display, MODEL_CAMERA_TYPE.TRAILER)
				self.model_view:SetScale(Vector3(1.5, 1.5, 1.5))
			end
			if nil ~= self.model_view then
				self.node_list["model"].ui3d_display:ResetRotation()
				self.model_view:SetRotation(Vector3(0, 0, 0))
			end
			self.node_list["BtnTrailer"]:SetActive(false)
			if info.res_type == FunResType.XIAN_NV then
				display_type = DISPLAY_TYPE.XIAN_NV
			elseif info.res_type == FunResType.MOUNT then
				display_type = DISPLAY_TYPE.MOUNT
				self.model_view:SetRotation(Vector3(0, -50, 0))
			elseif info.res_type == FunResType.WING then
				display_type = DISPLAY_TYPE.WING
			elseif info.res_type == FunResType.HALO then
				display_type = DISPLAY_TYPE.HALO
			elseif info.res_type == FunResType.SHENGONG then
				display_type = DISPLAY_TYPE.SHENGONG_WEAPON
			elseif info.res_type == FunResType.SHENYI then
				display_type = DISPLAY_TYPE.SHENYI
			elseif info.res_type == FunResType.Role then
				display_type = DISPLAY_TYPE.ROLE
			elseif info.res_type == FunResType.Weapon then
				local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.TRAILER, "weapon/" .. prof)
				self.model_view:SetCameraSettingForce(transform)
			end
			if info.res_type == FunResType.SHENGONG then
				self.node_list["model_go"].animator:SetTrigger("play")
			else
				self.node_list["model_go"].animator:SetTrigger("stop")
			end
			if info.res_type ~= FunResType.XIAN_NV then
				local res_id = info.res_show
				if info.res_type == FunResType.Role or info.res_type == FunResType.Weapon then 		--角色的要分职业
					local tab = Split(info.res_show, "#")
					if tab and tab[prof] then
						res_id = tonumber(tab[prof])
					end
				end
				if ResPath["Get" .. info.res_type .. "Model"] then
					self.model_view:SetMainAsset(ResPath["Get" .. info.res_type .. "Model"](res_id))
				end
			else
				local model_info = {}
				model_info.role_res_id = tonumber(info.res_show)
				model_info.wing_res_id = 13008
				self.model_view:SetGoddessModelResInfo(model_info)
			end
		end

		if self.info and self.can_reward and level >= self.info.auto_level then
			OpenFunCtrl.Instance:SendAdvanceNoitceOperate(ADVANCE_NOTICE_OPERATE_TYPE.ADVANCE_NOTICE_FETCH_REWARD, self.info.id)
		end

		local desc_list = Split(info.open_dec, "#")
		local desc = ""

		if self.can_reward then
			desc = Language.Common.LingQuJiangLi
		elseif #desc_list == 1 then
			desc = info.open_dec
		else
			desc = desc_list[1] .. "\n" .. desc_list[2]
		end
		self.node_list["TxtOpenDesc"].text.text = desc
		self.node_list["TxtOpenDesc1"].text.text = desc

	else
		self.root_node:SetActive(false)
	end
end

function MainUIFunctiontrailer:TrailerClick()
	if self.info then
		TipsCtrl.Instance:OpenFunTrailerTip(self.info)
	end
end
