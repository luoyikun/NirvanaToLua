
LoginGift7View = LoginGift7View or BaseClass(BaseView)

local GODDESS_TOGGLE_INDEX = 4		-- 女神标签

function LoginGift7View:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/7logingift_prefab", "7LoginGift"}
	}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.item_list = {}
	self.login_bt_list = {}
	self.is_modal = true
end

function LoginGift7View:__delete()
end

function LoginGift7View:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.LoginGift7View)
	end

	for i = 1, 6 do
		if self.item_list[i] ~= nil then
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil
		end
	end

	for i = 1, 7 do
		if self.login_bt_list[i] ~= nil then
			self.login_bt_list[i]:DeleteMe()
		end

		if nil ~= self["model" .. i] then
			self["model" .. i]:DeleteMe()
			self["model" .. i] = nil
		end
	end
	self.login_bt_list = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.stone_model then
		self.stone_model:DeleteMe()
		self.stone_model = nil
	end

	if self.equip_bg_effect_obj then
		ResMgr:Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end

	self.async_loader = nil
end

function LoginGift7View:LoadCallBack()
	-- self.node_list["Name"].text.text = Language.Activity.QiTian
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["RewardBtn"].button:AddClickListener(BindTool.Bind(self.ReceiveAward, self))
	for i = 1, 7 do
		self.node_list["GiftEvent" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.ToggleEvent, self, i))
	end

	self.item_list = {}
	for i = 1, 6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_" .. i])
	end

	self.cur_chosen_gift = 0
	self.login_bt_list = {}
	for i = 1, 7 do
		self.login_bt_list[i] = LoginButtonItem.New(self.node_list["GiftEvent" .. i])
		self["model" .. i] = RoleModel.New()
		self["model" .. i]:SetDisplay(self.node_list["Display" .. i].ui3d_display, MODEL_CAMERA_TYPE.TIPS)
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.stone_model = RoleModel.New()
	self.stone_model:SetDisplay(self.node_list["DisplayStone"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	--功能引导注册(可能有问题)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.LoginGift7View, BindTool.Bind(self.GetUiCallBack, self))
end

function LoginGift7View:SetModelDisplay(bundle, asset, display_type, model_type)
	if display_type == 1 then
		self:SetShowModel(false)
		self.node_list["ImgDisplayImage"].image:LoadSprite(bundle, asset .. ".png")
	elseif display_type == 0 then
		self:SetShowModel(true)
		if self.model then
			self.model:ClearModel()
		end
		if model_type == DISPLAY_TYPE.HALO then
			local main_role = Scene.Instance:GetMainRole()
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(asset)

		elseif model_type == DISPLAY_TYPE.XIAN_NV then
			self.model:SetMainAsset(bundle,asset)
			self.model:SetTrigger("show_idle_1")

		elseif model_type == DISPLAY_TYPE.MOUNT then
			self.model:SetMainAsset(bundle, asset, function()
				self.model:SetRotation(Vector3(0, -45, 0))
			end)
			self.model:SetTrigger(ANIMATOR_PARAM.REST)

		elseif model_type == DISPLAY_TYPE.WING then
			self.model:SetMainAsset(bundle, asset)

		elseif model_type == DISPLAY_TYPE.WEAPON then
			self.model:SetMainAsset(bundle, asset)
		elseif model_type == DISPLAY_TYPE.GATHER then
			self.model:SetMainAsset(bundle, asset)
		elseif model_type == 0 then
			local cfg = LoginGift7Ctrl.Instance.login_gift7_data:GetDataByDay(self.cur_chosen_gift)
			if not cfg then return end

			if self.cur_chosen_gift == 6 then
				self.stone_model:SetMainAsset(bundle, asset)
			else
				self.model:SetMainAsset(bundle, asset)
			end
		else
			self.model:SetMainAsset(bundle, asset)
		end
		self.model:ResetRotation()
	end

	-- self:SetShowNormalDisplay(self.cur_chosen_gift == 6) 							-- 宝石在配置那里配了不是0， 所以不用区别
end

function LoginGift7View:SetShowNormalDisplay(is_show)
	self.node_list["Display"]:SetActive(not is_show)
	self.node_list["DisplayStone"]:SetActive(is_show)
end

function LoginGift7View:SetShowModel(is_show)
	self.node_list["Display"]:SetActive(is_show)
	self.node_list["DisplayStone"]:SetActive(is_show)
	self.node_list["ImgDisplayImage"]:SetActive(not is_show)
end

function LoginGift7View:OpenCallBack()
	self.cur_chosen_gift = LoginGift7Data.Instance:GetGiftInfo().account_total_login_daycount
	if self.cur_chosen_gift > 7 then
		self.cur_chosen_gift = 7
	end
	-- 从女神面板跳转过来
	if self:GetShowIndex() == TabIndex.seven_login_goddess then
		self.cur_chosen_gift = GODDESS_TOGGLE_INDEX
	end
	self.temp_day = self.cur_chosen_gift

	for i = 1, self.cur_chosen_gift do
		self:FlushRewardState(i)
	end

	if nil ~= self.node_list["GiftEvent" .. self.cur_chosen_gift] then
		self.node_list["GiftEvent" .. self.cur_chosen_gift].toggle.isOn = true
	end

	self.node_list["TxtDayText"].text.text = self.cur_chosen_gift
	-- self.node_list["TxtYuanBaoText"].text.text = LoginGift7Data.Instance:GetGiftRewardByDay(self.cur_chosen_gift)
	local gift_data = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift)
	local bundle = gift_data.path
	local asset = gift_data.show_item

	self.node_list["EffectModel"]:SetActive(true)

	--路径不对，后面可能还要改
	if self.cur_chosen_gift == 7 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local num_str = string.format("%02d", gift_data.show_item)
		bundle, asset = ResPath.GetWeaponShowModel("100" .. (main_role_vo.prof % 10) .. num_str)
	else
		bundle = bundle .. "_prefab"
	end

	self:SetModelDisplay(bundle, asset, gift_data.tu, gift_data.show_model)

	local login_day_list = LoginGift7Data.Instance:GetLoginDayList()
	local logingift7_cfg = LoginGift7Data.Instance:GetGiftRewardCfg()
	if not logingift7_cfg then return end

	local data = {}
	for i = 1, 7 do
		data = LoginGift7Data.Instance:GetDataByDay(i)
		self.node_list["TxtDayGift" .. i].text.text = data.reward_text
		if login_day_list[i] == 1 then
			self.login_bt_list[i]:ShowRedPoint(true)
		else
			self.login_bt_list[i]:ShowRedPoint(false)
		end

		-- local bundle, asset = ResPath.GetSevenDayGift(data.day_picture)
		-- self.node_list["ImgGiftIcon" .. i].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["TxtGiftName" .. i].text.text = data.reward_text
	end

	local reward_list = LoginGift7Data.Instance:GetRewardList(self.cur_chosen_gift)
	local gift_item_id = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift).reward_item.item_id
	for i = 1, 6 do
		if reward_list[i] then
			if i == 1 then
				self.item_list[i]:SetActivityEffect()
			end
			self.item_list[i]:SetGiftItemId(gift_item_id)
			self.item_list[i]:SetData(reward_list[i])
			self.item_list[i]:SetParentActive(true)
			if i == 1 then
				self.item_list[i]:IsDestoryActivityEffect(false)
				self.item_list[i]:SetActivityEffect()
			else
				self.item_list[i]:IsDestoryActivityEffect(true)
				self.item_list[i]:SetActivityEffect()
			end
		else
			self.item_list[i]:SetParentActive(false)
		end
	end

	if self:CurDayIsReceive(self.cur_chosen_gift) then
		self:SetToggleNextOn()
	else
		self.node_list["GiftEvent" .. self.cur_chosen_gift].toggle.isOn = true
	end

	self.node_list["TxtReceiveName"].text.text = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift).show_dec1

	-- local bundle, asset = ResPath.GetSevenDayGift("word_" .. self.cur_chosen_gift)
	-- self.node_list["ImgWordBG"].image:LoadSprite(bundle, asset .. ".png")


	-- local bundle, asset = ResPath.GetSevenDayGift("word_desc_" .. self.cur_chosen_gift)
	-- self.node_list["ImgGiftDesc"].image:LoadSprite(bundle, asset .. ".png")

	if gift_data.can_spin then
		self.node_list["ImgDisplayBlock"]:SetActive(gift_data.can_spin == 0)
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	for i = 1, 7 do
		local gift_data = LoginGift7Data.Instance:GetDataByDay(i)
		if not gift_data then return end
		local bundle = gift_data.path
		local asset = gift_data.show_item

		--路径不对，后面可能还要改
		if i == 7 then
			local num_str = string.format("%02d", gift_data.show_item)
			bundle, asset = ResPath.GetWeaponShowModel("100" .. (main_role_vo.prof % 10) .. num_str)
		else
			bundle = bundle .. "_prefab"
		end

		local scale = gift_data.scale
		if gift_data.show_model == DISPLAY_TYPE.HALO then
			local main_role = Scene.Instance:GetMainRole()
			self["model" .. i]:SetRoleResid(main_role:GetRoleResId())
			self["model" .. i]:SetHaloResid(asset)

		elseif gift_data.show_model == DISPLAY_TYPE.XIAN_NV then
			self["model" .. i]:SetMainAsset(bundle, asset)
			self["model" .. i]:SetTrigger("show_idle_1")

		elseif gift_data.show_model == DISPLAY_TYPE.MOUNT then
			self["model" .. i]:SetMainAsset(bundle, asset, function()
				self["model" .. i]:SetRotation(Vector3(0, -45, 0))
			end)
			self["model" .. i]:SetTrigger(ANIMATOR_PARAM.REST)

		elseif gift_data.show_model == DISPLAY_TYPE.WING then
			self["model" .. i]:SetMainAsset(bundle, asset)

		elseif gift_data.show_model == DISPLAY_TYPE.WEAPON then
			self["model" .. i]:SetMainAsset(bundle, asset)

		elseif gift_data.show_model == DISPLAY_TYPE.GATHER then
			self["model" .. i]:SetMainAsset(bundle, asset)
		else
			local rotation = Vector3(0, 0, 0)
			self["model" .. i]:SetMainAsset(bundle, asset)
			self["model" .. i]:SetRotation(rotation)
		end
	end

	self.async_loader = self.async_loader or AllocAsyncLoader(self, "model_effect_loader")
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_tongyongbaoju_1")
	self.async_loader:Load(bundle_name, asset_name, function(obj)
		if not IsNil(obj) then
			local transform = obj.transform
			transform:SetParent(self.node_list["EffectModel"].transform, false)
			transform.localScale = Vector3(3, 3, 3)
			self.equip_bg_effect_obj = obj.gameObject
			self.color = 0
		end
	end)
end

function LoginGift7View:CloseCallBack()
	self.cur_chosen_gift = 1
end

function LoginGift7View:CloseView()
	self:Close()
end

function LoginGift7View:FlushRewardState(fecth_day)
	local reward_id = fecth_day
	if reward_id == 0 then
		reward_id = 1
	end

	if self:CurDayIsReceive(reward_id) then
		UI:SetButtonEnabled(self.node_list["RewardBtn"], false)
		self.node_list["TxtRewardBtn"].text.text = Language.Common.YiLingQu
		if fecth_day > 0 then
			self.login_bt_list[fecth_day]:ShowGotGift(true)
			self.login_bt_list[fecth_day]:ShowRedPoint(false)
		end
		-- 设置已领取的值为2
		LoginGift7Data.Instance:SetLoginDay(reward_id,2)
	else
		UI:SetButtonEnabled(self.node_list["RewardBtn"], true)
		self.node_list["TxtRewardBtn"].text.text = Language.Common.LingQuJiangLi
	end
end

function LoginGift7View:ReceiveAward()
	if not self:CurDayIsReceive(self.cur_chosen_gift) then
		self.temp_day = self.cur_chosen_gift
		LoginGift7Ctrl.Instance:SendSevenDayLoginRewardReq(self.cur_chosen_gift)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.LoginDayNotFull)
	end
end

function LoginGift7View:ToggleEvent(index)
	if index ~= GODDESS_TOGGLE_INDEX then
		self:ShowIndex()
	end
	self.node_list["TxtReceiveName"].text.text = LoginGift7Data.Instance:GetDataByDay(index).show_dec1
	self.cur_chosen_gift = index
	local reward_list = LoginGift7Data.Instance:GetRewardList(index)
	local gift_item_id = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift).reward_item.item_id

	for i = 1, 6 do
		if reward_list[i] then
			self.item_list[i]:SetGiftItemId(gift_item_id)
			self.item_list[i]:SetData(reward_list[i])
			self.item_list[i]:SetParentActive(true)
		else
			self.item_list[i]:SetParentActive(false)
		end
	end
	local gift_data = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift)
	local bundle = gift_data.path
	local asset = gift_data.show_item

	--路径不对，后面可能还要改
	if index == 7 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local num_str = string.format("%02d", gift_data.show_item)
		bundle, asset = ResPath.GetWeaponShowModel("100" .. (main_role_vo.prof % 10) .. num_str)
	else
		bundle = bundle .. "_prefab"
	end

	self:SetModelDisplay(bundle, asset, gift_data.tu, gift_data.show_model)
	self:FlushRewardState(index)
	self.node_list["TxtDayText"].text.text = index
	-- self.node_list["TxtYuanBaoText"].text.text = LoginGift7Data.Instance:GetGiftRewardByDay(index) .. Language.DingGuaGua.YuanBao

	local bundle, asset = ResPath.GetSevenDayGift("word_" .. index)
	self.node_list["ImgWordBG"].image:LoadSprite(bundle, asset .. ".png")

	-- local bundle, asset = ResPath.GetSevenDayGift("word_desc_" .. index)
	-- self.node_list["ImgGiftDesc"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["ShowDec2"].text.text = LoginGift7Data.Instance:GetDataByDay(index).show_dec2

	--是否可旋转
	if gift_data.can_spin then
		self.node_list["ImgDisplayBlock"]:SetActive(gift_data.can_spin == 0)
	end

	self.node_list["EffectModel"]:SetActive(true)
end

function LoginGift7View:OnFlush()
	self:FlushRewardState(self.temp_day)
	self:FlushMainUIShow()
	self:SetToggleNextOn()
end

function LoginGift7View:IsShowRedpt()
	local  login_day_list = LoginGift7Data.Instance:GetLoginDayList()
	for i = 1, 7 do
		if login_day_list[i] == 1 then
			return true
		end
	end

	return false
end

function LoginGift7View:IsReceiveAll()
	local  login_day_list = LoginGift7Data.Instance:GetLoginDayList()
	for i = 1, 7 do
		if login_day_list[i] ~= 2 then
			return
		end
	end
	LoginGift7Data.Instance:SetIsAllReceive(true)
end

function LoginGift7View:SetToggleNextOn()
	local login_day_list = LoginGift7Data.Instance:GetLoginDayList()

	local now_show_index = self:GetShowIndex()
	if nil ~= now_show_index and now_show_index == TabIndex.seven_login_goddess then
		self.node_list["GiftEvent" .. GODDESS_TOGGLE_INDEX].toggle.isOn = true
		self:ToggleEvent(GODDESS_TOGGLE_INDEX)
		return
	end

	-- for i = 1, 7 do
	-- 	if LoginGift7Data.Instance:IsCanReceive(i) then
	-- 		self.node_list["GiftEvent" .. i].toggle.isOn = true
	-- 		self:ToggleEvent(i)
	-- 		return
	-- 	end
	-- end
end

function LoginGift7View:FlushMainUIShow()
	-- 判断是否领取全部奖励
	self:IsReceiveAll()
end

function LoginGift7View:CurDayIsReceive(day)
	local cur_day = day
	local is_reward = LoginGift7Data.Instance:GetLoginRewardFlag(cur_day)
	return is_reward
end

function LoginGift7View:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

---------------------------------------------------------------------------- 每日奖励按钮类
LoginButtonItem = LoginButtonItem or BaseClass(BaseCell)
function LoginButtonItem:__init()
end

function LoginButtonItem:ShowGotGift(is_show)
	self.node_list["GotGift"]:SetActive(is_show)
end

function LoginButtonItem:ShowRedPoint(is_show)
	self.node_list["RedPoint"]:SetActive(is_show)
end
