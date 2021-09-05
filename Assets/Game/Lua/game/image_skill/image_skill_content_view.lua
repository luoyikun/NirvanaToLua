ImageSkillContentView = ImageSkillContentView or BaseClass(BaseRender)

function ImageSkillContentView:__init(instance)
	ImageSkillContentView.Instance = self
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
	self.node_list["invest_btn"].button:AddClickListener(BindTool.Bind(self.OnGoClick, self))
	self.item_list = {}
	local item_info_list = ImageSkillData.Instance:GetGiftInfoList() or {}
	for i = 1, 3 do
		if item_info_list[i] then
			self.item_list[i] = ItemCell.New()
			self.item_list[i]:SetInstanceParent(self.node_list["item_" .. i])
			self.item_list[i]:SetShowOrangeEffect(true)
			self.item_list[i]:SetData(item_info_list[i])
		end
	end

	UI:SetGraphicGrey(self.node_list["invest_btn"], not (ImageSkillCtrl.Instance.is_buy))
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	local data = ImageSkillData.Instance:GetBaiBeiItemCfg()
	if data then
		self:ShowModel(data.model_show)
		local item_cfg = ItemData.Instance:GetItemConfig(data.model_show)
		if item_cfg then
			self.node_list["ImageName"].text.text = item_cfg.name
		end
		if self.fight_text and self.fight_text.text and data.power_2 then
			self.fight_text.text.text = data.power_2
		end
		self.node_list["MoneyText"].text.text = data.baibeifanli_price_2
		self.node_list["MoneyText2"].text.text = data.baibeifanli_value
	end
	
	
end

function ImageSkillContentView:__delete()
	self.node_list["TxtInvestBtn"] = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.fight_text = nil
end

-- function ImageSkillContentView:CancelHighLight()
-- 	for k,v in pairs(self.item_list) do
-- 		v:ShowHighLight(false)
-- 	end
-- end

function ImageSkillContentView:ShowModel(item_id)
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	self.model:SetRotation(Vector3(0, 0, 0))
	self.model:SetLocalPosition(Vector3(0, 0, 0))
	self.model:ClearModel()
	if cfg then
		local display_role = cfg.is_display_role
		if display_role == DISPLAY_TYPE.WING then
			local res_id = 0
			for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			local bundle, asset = ResPath.GetWingModel(res_id)
			self.model:SetMainAsset(bundle, asset)
			local transform = {position = Vector3(0.0, 1.5, 4.9), rotation = Quaternion.Euler(0, 180, 0)}
			self.model:SetCameraSetting(transform)
		else
			self.model:ChangeModelByItemId(data.model_show)
		end
	end
	self.model:ShowRest()
end


function ImageSkillContentView:OnGoClick()
	local cfg = ImageSkillData.Instance:GetBaiBeiItemCfg()
	if cfg == nil then
		return
	end
	local price = cfg.baibeifanli_price_2
	local level_limit = cfg.baibeifanli_level_limit_2
	local role_money = GameVoManager.Instance:GetMainRoleVo().gold
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	local func = function ()
		if role_money >= price then
			if role_level >= level_limit then
				if bags_grid_num >= 4 then
					ImageSkillCtrl.Instance:SendBaiBeiFanLiBuy()
					UI:SetGraphicGrey(self.node_list["invest_btn"], false)
					UI:SetGraphicGrey(self.node_list["TxtInvestBtn"], false)
					ImageSkillCtrl.Instance.is_buy = false
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
				end
			else
				TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.BuyNeedLevle, level_limit))
			end
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Common.ImageSkillTips, price))
end


-- function ImageSkillContentView:SetModelState()
-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
-- 	local vect = Vector3(0, 0, 0)
-- 	if main_role_vo.prof == GameEnum.ROLE_PROF_1 then
-- 		vect = Vector3(0, 0, 0)
-- 	elseif main_role_vo.prof == GameEnum.ROLE_PROF_2 then
-- 		vect = Vector3(0, 0, 0)
-- 	elseif main_role_vo.prof == GameEnum.ROLE_PROF_3  then
-- 		vect = Vector3(0, 0, 0)
-- 	elseif main_role_vo.prof == GameEnum.ROLE_PROF_4 then
-- 		vect = Vector3(0, -45, 0)
-- 	else
-- 		vect = Vector3(0, 0, 0)
-- 	end
-- 	self.model:SetRotation(vect)
-- 	self.model:SetBool("fight", true)
-- end
