-- 三界霸主展示
-- BeherrscherShowView
BeherrscherShowView = BeherrscherShowView or BaseClass(BaseView)

function BeherrscherShowView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/activityview_prefab", "BeherrscherShowView"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.act_id = 0
	self.play_audio = true
	self.is_modal = true
	-- self.view_layer = UiLayer.PopTop
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.first_info = {}
	self.first_rank_uid_list = {}
end

function BeherrscherShowView:__delete()

end

function BeherrscherShowView:ReleaseCallBack()
	for i = 1, 3 do
		self.model_list[i]:DeleteMe()
		self.model_list[i] = nil
	end
	self.model_list = {}

	self.first_info = {}
	self.first_rank_uid_list = {}
end

function BeherrscherShowView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["TitleText"].text.text = Language.Activity.SanJieBaZhu

	local title_cfg = ElementBattleData.Instance:GetTitleCfg()
	self.model_list = {}
	for i = 1, 3 do
		local res_id = title_cfg[i].title_id
		local bundle, asset = ResPath.GetTitleIcon(res_id)
		self.node_list["ImgTitle" .. i].image:LoadSprite(bundle, asset)
		self:LoadTitleEff(self.node_list["ImgTitle" .. i], res_id, true)

		self.node_list["ImgTitle" .. i].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, i))
		self.model_list[i] = RoleModel.New()
		self.model_list[i]:SetDisplay(self.node_list["Display_" .. i].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
end

function BeherrscherShowView:OpenCallBack()
	self.first_rank_uid_list = ActivityData.Instance:GetQunxianLuandouFirstRankUid()
	for i = 1, 3 do
		if not self.first_rank_uid_list[i] or self.first_rank_uid_list[i] <= 0 then
			self.node_list["Imgxuwei_" .. i]:SetActive(true)
		else
			CheckCtrl.Instance:SendQueryRoleInfoReq(self.first_rank_uid_list[i])
			CheckCtrl.Instance:SetInfoCallBack(self.first_rank_uid_list[i], function()
				self:Flush()
			end)		
		end 
	end
end

function BeherrscherShowView:OnFlush(param_list)
	self.first_info = ActivityData.Instance:GetQunxianLuandouFirstRankInfo()
	for i = 1, 3 do
		if self.first_info == nil or self.first_info[i] == nil or "" == self.first_info[i] then
			self.node_list["TxtName" .. i].text.text = ""
		else
			self.node_list["TxtName" .. i].text.text = ToColorStr(self.first_info[i],TEXT_COLOR.GREEN_4) 
		end

		if not self.first_rank_uid_list[i] or self.first_rank_uid_list[i] <= 0 then
			self.node_list["Imgxuwei_" .. i]:SetActive(true)
		else
			local info = ActivityData.Instance:GetFirstRankRoleInfo(self.first_rank_uid_list[i])
			if info then
				self.model_list[i]:ResetRotation()
				self.model_list[i]:SetModelResInfo(info, false, true, true, nil, nil, nil, true)
				self.model_list[i]:SetTrigger(ANIMATOR_PARAM.FIGHT)
				self.model_list[i]:SetScale(Vector3(0.9, 0.9, 0.9))
				local prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
				if prof == 3 then 
					local transform = {position = Vector3(0.0, 1.7, 4.5), rotation = Quaternion.Euler(8, 180, 0)}
					self.model_list[i]:SetCameraSetting(transform)
				elseif prof == 1 then
					local transform = {position = Vector3(-0.1, 1.9, 5), rotation = Quaternion.Euler(8, 180, 0)}
					self.model_list[i]:SetCameraSetting(transform)
				elseif prof == 4 then
					local transform = {}
					if i ~= 2 then
						transform = {position = Vector3(0, 1.4, 3.8), rotation = Quaternion.Euler(8, 180, 0)}
					else
						transform = {position = Vector3(0, 1.6, 4.4), rotation = Quaternion.Euler(8, 180, 0)}
					end
					self.model_list[i]:SetCameraSetting(transform)
				end
				self.node_list["Imgxuwei_" .. i]:SetActive(false)
			else
				self.node_list["Imgxuwei_" .. i]:SetActive(true)
			end
		end
	end
end


function BeherrscherShowView:CloseWindow()
	self:Close()
	if Scene.Instance:GetSceneId() == 1201 then		-- 判断是否在三界争锋场景
		-- ElementBattleCtrl.Instance:ExitSceneReq()
	end
end

function BeherrscherShowView:ClickTitle(index)
	local title_cfg = ActivityData.Instance:GetXianMoItemCfg()
	if title_cfg and title_cfg[index] then
		local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
		TipsCtrl.Instance:OpenItem(data)
	end
end

function BeherrscherShowView:LoadTitleEff(parent, title_id, is_active, call_back)
	local title_cfg = TitleData.Instance:GetTitleCfg(title_id)
	if title_cfg and title_cfg.is_zhengui then
		self.title_effect_loader = self.title_effect_loader or {}
		if self.title_effect_loader[parent] then
			self.title_effect_loader[parent]:SetActive(is_active)
			return
		end

		local asset_bundle, asset_name = ResPath.GetTitleEffect("UI_title_eff_" .. title_cfg.is_zhengui)
		local async_loader = self.title_effect_loader[parent] or AllocAsyncLoader(self, "title_effect_loader_" .. title_id)
		async_loader:Load(asset_bundle, asset_name, function(obj)
			obj.transform:SetParent(parent.transform, false)
			obj:SetActive(is_active)
		end)
		self.title_effect_loader[parent] = async_loader
	end
end