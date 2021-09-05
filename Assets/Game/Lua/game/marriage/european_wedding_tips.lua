EuropeanWeddingTips = EuropeanWeddingTips or BaseClass(BaseView)

function EuropeanWeddingTips:__init()
	self.ui_config = {{"uis/views/marriageview_prefab","EuropeanWeddingTips"}}
	self.is_modal = true
end

function EuropeanWeddingTips:__delete()

end

function EuropeanWeddingTips:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickCloseView, self))
	self.node_list["Title"].button:AddClickListener(BindTool.Bind(self.OnClickTitle, self))
end

function EuropeanWeddingTips:ReleaseCallBack()
	if self.self_model then
		self.self_model:DeleteMe()
		self.self_model = nil
	end

	if self.love_model then
		self.love_model:DeleteMe()
		self.love_model = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleModel"])
end

function EuropeanWeddingTips:OpenCallBack()
	self:Flush()
end

function EuropeanWeddingTips:CloseCallBack()
	local self_weapon_part = self.self_model.draw_obj:GetPart(SceneObjPart.Weapon)
	if self_weapon_part then
		self_weapon_part:RemoveModel()
	end

	local lover_weapon_part = self.love_model.draw_obj:GetPart(SceneObjPart.Weapon)
	if lover_weapon_part then
		lover_weapon_part:RemoveModel()
	end
end

function EuropeanWeddingTips:OnFlush()
	if next(self.data) == nil then
		return
	end

	-- 刷新右边内容
	local bundle, asset = ResPath.GetTitleIcon(self.data.title_id)
	self.node_list["TitleModel"].image:LoadSprite(bundle, asset)
	TitleData.Instance:LoadTitleEff(self.node_list["TitleModel"], self.data.title_id, true)
	local power_value = MarriageData.Instance:GetEuropeanMarriageTipPower(self.data.hunli_type)
	self.node_list["Number"].text.text = power_value * 2
	if self.data.hunli_type == 3 then		
		self.node_list["imagesText"]:SetActive(false)
		self.node_list["imagesText1"]:SetActive(true)
	elseif self.data.hunli_type == 4 then
		self.node_list["imagesText1"]:SetActive(false)
		self.node_list["imagesText"]:SetActive(true)
	end
	-- 刷新提示字体
	-- local type_index = self.data.hunli_type - 2
	-- local bundle, asset = ResPath.GetEuropeanWeddingText("down", type_index)
	-- self.node_list["Text2"].image:LoadSprite(bundle, asset, function()
	-- 			self.node_list["Text2"].image:SetNativeSize()
	-- 		end)
	-- 刷新左边内容
	self:FlushDisPlay()
end

function EuropeanWeddingTips:OnClickCloseView()
	self:Close()
end

function EuropeanWeddingTips:InitDisPlay()
	if not self.self_model then
		self.self_model = RoleModel.New("wedding_tips_model")
		self.self_model:SetDisplay(self.node_list["SelfDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	if not self.love_model then
		self.love_model = RoleModel.New("wedding_tips_model")
		self.love_model:SetDisplay(self.node_list["LoverDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
end

function EuropeanWeddingTips:FlushDisPlay()
	if self.data == nil then
		return
	end
	self:InitDisPlay()

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	-- 设置自己的模型
	-- 第一档配置第一个为时装，第二档为武器，故写死reward_item读取写死
	local my_prof =  PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	local res_id = FashionData.GetFashionResByItemId(self.data.reward_type[0].item_id, main_role_vo.sex, my_prof) or 0
	local weapon_id = 0
	if self.data.reward_type[1] then
		weapon_id = FashionData.GetWeaponResByItemId(self.data.reward_type[1].item_id, main_role_vo.sex, my_prof) or 0
	end
	self.self_model:SetRoleResid(res_id)
	-- if weapon_id > 0 then
	-- 	self.self_model:SetWeaponResid(weapon_id)
	-- end
	if weapon_id and my_prof ~= 3 then
		self.self_model:SetWeaponResid(weapon_id)
		if weapon_id > 0 then
			-- self.self_model:SetTrigger(ANIMATOR_PARAM.FIGHT)
		end
	end
	if my_prof == 3 and weapon_id then
		local temp = Split(weapon_id, ",")
		local my_weapon_id1 = tonumber(temp[1])
		local my_weapon_id2 = tonumber(temp[2])
		self.self_model:SetWeaponResid(my_weapon_id1)
		self.self_model:SetWeapon2Resid(my_weapon_id2)
		if my_weapon_id2 then
			-- self.self_model:SetTrigger(ANIMATOR_PARAM.FIGHT)
		end
	end

	-- 设置伴侣的模型
	local lover_sex = main_role_vo.sex == GameEnum.FEMALE and GameEnum.MALE or GameEnum.FEMALE
	local lover_prof = MarriageData.Instance:GetLoverProf()
	local lover_res_id = FashionData.GetFashionResByItemId(self.data.reward_type[0].item_id, lover_sex, lover_prof) or 0
	local lover_weapon_id = 0
	local lover_weapon_id1 = 0
	local lover_weapon_id2 = 0
	local lover_weapon_id3 = 0
	if self.data.reward_type[1] and lover_prof ~= 3 then
		lover_weapon_id = FashionData.GetWeaponResByItemId(self.data.reward_type[1].item_id, lover_sex, lover_prof) or 0
	elseif self.data.reward_type[1] and  lover_prof == 3 then
		lover_weapon_id3 = FashionData.GetWeaponResByItemId(self.data.reward_type[1].item_id, lover_sex, lover_prof)
		if lover_weapon_id3 ~= nil then
			local temp = Split(lover_weapon_id3, ",")
			lover_weapon_id1 = tonumber(temp[1])
			lover_weapon_id2 = tonumber(temp[2])
		end
	end

	self.love_model:SetRoleResid(lover_res_id)
	if lover_weapon_id > 0 and lover_prof ~= 3 then
		self.love_model:SetWeaponResid(lover_weapon_id)
		-- self.love_model:SetTrigger(ANIMATOR_PARAM.FIGHT)
	end
	if lover_prof == 3  and lover_weapon_id3 ~= 0 then
		self.love_model:SetWeaponResid(lover_weapon_id1)
		self.love_model:SetWeapon2Resid(lover_weapon_id2)
		-- self.love_model:SetTrigger(ANIMATOR_PARAM.FIGHT)
	end
end

function EuropeanWeddingTips:OnClickTitle()
	if self.data == nil then
		return
	end

	local title_info = TitleData.Instance:GetUpgradeCfg(self.data.title_id)
	if title_info == nil then
		return
	end
	TipsCtrl.Instance:OpenItem({item_id = title_info.stuff_id})
end

function EuropeanWeddingTips:SetData(data)
	self.data = data
end