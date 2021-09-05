WeddingView = WeddingView or BaseClass(BaseView)

function WeddingView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "WeddingView"}}
	self.play_audio = true
end

function WeddingView:__delete()

end

function WeddingView:LoadCallBack()
	local level = MarriageData.Instance:GetMarryLevelLimit()
	local intimacy = MarriageData.Instance:GetMarryIntimacyLimit()
	self.node_list["TxtLevelLimit"].text.text = string.format(Language.Marriage.Level, level)
	self.node_list["TxtIntimacyLimit"].text.text = string.format(Language.Marriage.Intimacy,intimacy)

	self.wedding_item_list = {}
	for i = 1, 3 do
		local wedding_item = WeddingItemCell.New(self.node_list["WeddingItem" .. i])
		wedding_item:SetIndex(i)
		wedding_item.parent_view = self
		table.insert(self.wedding_item_list, wedding_item)
	end
	self.node_list["ImgOtherHead"].button:AddClickListener(BindTool.Bind(self.OpenFriendList, self))
	-- self.node_list["BtnSelectFriend"].button:AddClickListener(BindTool.Bind(self.OpenFriendList, self))
	self.node_list["BtnPropose"].button:AddClickListener(BindTool.Bind(self.ClickPropose, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["ChangeTypeButton"].button:AddClickListener(BindTool.Bind(self.OnClickChangeMarriageType, self))
	self.role_attr_change = BindTool.Bind(self.RoleAttrChange, self)
end

function WeddingView:ReleaseCallBack()
	for k, v in ipairs(self.wedding_item_list) do
		v:DeleteMe()
	end
	self.wedding_item_list = {}

	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end
end

function WeddingView:OpenCallBack()
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_GET_ROLE_INFO)
	self.select_wedding_index = 1			--选择的婚礼
	self.other_name = ""					--对方的名字
	self.marry_way = MARRY_REQ_TYPE.MARRY_REQ_TYPE_PROPOSE		--操作类型

	--限制条件
	self.level_enough = false
	self.online_enough = false
	self.intimacy_enough = false
	self.gold_enough = false
	self.is_bind_gold = false			--是否使用绑定钻石

	self:SetMyHead()
	self.role_is_marriage = Scene.Instance:GetMainRole():IsMarriage()
	if self.role_is_marriage then
		-- self.node_list["BtnSelectFriend"]:SetActive(false)
		self.node_list["ChangeTypeButton"]:SetActive(true)
		self.lover_vo = ScoietyData.Instance:GetFriendInfoById(GameVoManager.Instance:GetMainRoleVo().lover_uid)
		self:SetLoverHead(self.lover_vo)
		self.other_name = self.lover_vo.gamename
	else
		self.node_list["NodeOtherHeadMask"]:SetActive(false)
		self.node_list["Add"]:SetActive(true)
	end

	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if open_day <= 2 then
		self.node_list["ChangeTypeButton"]:SetActive(false)
	end

	self:Flush()

	--监听钻石变化
	PlayerData.Instance:ListenerAttrChange(self.role_attr_change)
end

function WeddingView:CloseCallBack()
	if self.role_attr_change then
		PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change)
	end
end

function WeddingView:RoleAttrChange(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		self:FlushGoldLimit()
	end
end

function WeddingView:SelectFriendCallBack(role_info)
	self.other_name = role_info.gamename
	if self.node_list then
		self.node_list["NodeOtherHeadMask"]:SetActive(true)
		self:SetOtherHead(role_info)
		self:FlushLimit()
	end
end

function WeddingView:OpenFriendList()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = main_role_vo.sex == 1 and 0 or 1
	local callback = BindTool.Bind(self.SelectFriendCallBack, self)
	MarriageCtrl.Instance:ShowFriendListView(callback, sex)
end

function WeddingView:ClickPropose()
	local other_name = self.other_name
	if other_name == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotOtherRoleDes)
		return
	end

	local marry_type = self.select_wedding_index - 1
	if marry_type < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotSelectWeddingDes)
		return
	end

	if not self.level_enough then
		local level = MarriageData.Instance:GetMarryLevelLimit()
		local des = string.format(Language.Marriage.LevelLimitDes, level)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end

	if not self.online_enough then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
		return
	end

	local reward_info = MarriageData.Instance:GetYuYueRoleInfo().param_ch5
	local reward = bit:d2b(reward_info)
	for i=0,2 do
  		self.node_list["GetReward" .. i + 1]:SetActive(reward[32 - i] == 1)
  		-- if reward[32 - marry_type] == 1 then
  		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.GetHunYanReward)
  		-- 	return
  		-- end
 	end 
 	
	if not self.gold_enough then
		if self.is_bind_gold then
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local hunli_info = MarriageData.Instance:GetHunliInfoByType(marry_type)
			local cost = hunli_info.need_bind_gold
			local diff_gold = cost - main_vo.bind_gold
			local des = string.format(Language.Common.ToUseGold, diff_gold)

			local function ok_callback()
				if diff_gold > main_vo.gold then
					TipsCtrl.Instance:ShowLackDiamondView()
					return
				end
				local other_vo = ScoietyData.Instance:GetFriendInfoByName(other_name) or {}
				MarriageCtrl.Instance:SendMarryReq(self.marry_way ,marry_type, other_vo.user_id)
			end
			TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
		return
	end

	local other_vo = ScoietyData.Instance:GetFriendInfoByName(other_name) or {}
	MarriageCtrl.Instance:SendMarryReq(self.marry_way ,marry_type, other_vo.user_id)
end

function WeddingView:OnClickChangeMarriageType()
	ViewManager.Instance:Open(ViewName.EuropeanWeddingView)
	self:Close()
end

function WeddingView:CloseWindow()
	self:Close()
end

--设置我的头像
function WeddingView:SetMyHead()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = main_role_vo.role_id
	local prof = main_role_vo.prof
	local sex = main_role_vo.sex

	AvatarManager.Instance:SetAvatar(role_id, self.node_list["MyRawImage"], self.node_list["ImgMyHeadMask"], sex, prof, false)
end

--设置他人头像
function WeddingView:SetOtherHead(info)
	local role_id = info.user_id
	local prof = info.prof
	local sex = info.sex

	AvatarManager.Instance:SetAvatar(role_id, self.node_list["OtherRawImage"], self.node_list["ImgOtherHeadMask"], sex, prof, false)
	if role_id then
		self.node_list["Add"]:SetActive(false)
	else
		self.node_list["Add"]:SetActive(true)
	end
end

--设置伴侣头像
function WeddingView:SetLoverHead(info)
	local role_id = info.user_id
	local prof = info.prof
	local sex = info.sex

	AvatarManager.Instance:SetAvatar(role_id, self.node_list["OtherRawImage"], self.node_list["ImgOtherHeadMask"], sex, prof, false)

	if role_id then
		self.node_list["Add"]:SetActive(false)
	else
		self.node_list["Add"]:SetActive(true)
	end
end

function WeddingView:FlushGoldLimit()
	if self.other_name ~= "" then
		local cost_enough, is_bind_gold = MarriageData.Instance:CostEnoughByHunliType(self.select_wedding_index - 1)
		self.is_bind_gold = is_bind_gold
		if cost_enough then
			self.gold_enough = true
			self.node_list["ImgGoldLimitYes"]:SetActive(true)
			self.node_list["ImgGoldLimitNo"]:SetActive(false)
		else
			self.gold_enough = false
			self.node_list["ImgGoldLimitYes"]:SetActive(false)
			self.node_list["ImgGoldLimitNo"]:SetActive(true)
		end
	else
		self.gold_enough = false
		self.node_list["ImgGoldLimitYes"]:SetActive(false)
		self.node_list["ImgGoldLimitNo"]:SetActive(true)
	end
end

function WeddingView:FlushWeddingItem()
	for i,v in ipairs(self.wedding_item_list) do
		v:Flush()
	end
end

function WeddingView:FlushLimit()
	if self.other_name ~= "" and self.other_name ~= nil then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local other_vo = ScoietyData.Instance:GetFriendInfoByName(self.other_name) or {}
		local level = MarriageData.Instance:GetMarryLevelLimit()
		local intimacy = MarriageData.Instance:GetMarryIntimacyLimit()
		if main_vo.level >= level and other_vo.level >= level then
			self.level_enough = true
			self.node_list["ImgLevelLimitYes"]:SetActive(true)
			self.node_list["ImgLevelLimitNo"]:SetActive(false)
		else
			self.level_enough = false
			self.node_list["ImgLevelLimitYes"]:SetActive(false)
			self.node_list["ImgLevelLimitNo"]:SetActive(true)
		end

		if other_vo.is_online == 1 then
			self.online_enough = true
			self.node_list["ImgOnlineLimitYes"]:SetActive(true)
			self.node_list["ImgOnlineLimitNo"]:SetActive(false)
		else
			self.online_enough = false
			self.node_list["ImgOnlineLimitYes"]:SetActive(false)
			self.node_list["ImgOnlineLimitNo"]:SetActive(true)
		end

		if other_vo.intimacy >= intimacy then
			self.intimacy_enough = true
			self.node_list["ImgIntimacyLimitYes"]:SetActive(true)
			self.node_list["ImgIntimacyLimitNo"]:SetActive(false)
		else
			self.intimacy_enough = false
			self.node_list["ImgIntimacyLimitYes"]:SetActive(false)
			self.node_list["ImgIntimacyLimitNo"]:SetActive(true)
		end
	else
		if self.role_is_marriage then
			self.online_enough = self.lover_vo.is_online == 1
			self.node_list["ImgOnlineLimitYes"]:SetActive(true)
			self.node_list["ImgOnlineLimitNo"]:SetActive(false)
			self.node_list["ImgIntimacyLimitYes"]:SetActive(true)
			self.node_list["ImgIntimacyLimitNo"]:SetActive(false)
		else
			self.level_enough = false
			self.online_enough = false
			self.intimacy_enough = false
			self.node_list["ImgLevelLimitYes"]:SetActive(false)
			self.node_list["ImgLevelLimitNo"]:SetActive(true)
			self.node_list["ImgOnlineLimitYes"]:SetActive(false)
			self.node_list["ImgOnlineLimitNo"]:SetActive(true)
			self.node_list["ImgIntimacyLimitYes"]:SetActive(false)
			self.node_list["ImgIntimacyLimitNo"]:SetActive(true)
		end
	end

	self:FlushGoldLimit()
end

function WeddingView:OnFlush()
	local reward_info = MarriageData.Instance:GetYuYueRoleInfo().param_ch5
	local reward = bit:d2b(reward_info)
	for i=0,2 do
  		self.node_list["GetReward" .. i + 1]:SetActive(reward[32 - i] == 1)
 	end 

	self:FlushLimit()

	local hunli_data = MarriageData.Instance:GetHunLiData()
	for k, v in ipairs(self.wedding_item_list) do
		v:SetData(hunli_data[k])
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING) then
		if self.count_down_timer then
			CountDown.Instance:RemoveCountDown(self.count_down_timer)
			self.count_down_timer = nil
		end
		local count_down_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING)
		if count_down_time > 0 then
			local time = TimeUtil.FormatSecond(math.floor(count_down_time), 10)
			self.node_list["BuyTime"].text.text = time
			self.node_list["SaleEffect"]:SetActive(true)
			self.node_list["IconXianShi"]:SetActive(true)				
			self.count_down_timer = CountDown.Instance:AddCountDown(count_down_time, 1, BindTool.Bind(self.UpdateTimerCallback, self), 
				BindTool.Bind(self.CompleteTimerCallback, self))
		else
			self.node_list["BuyTime"].text.text = ""
			self.node_list["SaleEffect"]:SetActive(false)
			self.node_list["IconXianShi"]:SetActive(false)			
		end
	else
		if self.count_down_timer then
			CountDown.Instance:RemoveCountDown(self.count_down_timer)
			self.count_down_timer = nil
		end	
		self.node_list["BuyTime"].text.text = ""
		self.node_list["SaleEffect"]:SetActive(false)
		self.node_list["IconXianShi"]:SetActive(false)					
	end
end

function WeddingView:UpdateTimerCallback(elapse_time, total_time)
	if self.node_list and self.node_list["BuyTime"] and self.node_list["BuyTime"].text and self.node_list["BuyTime"].text.text then
		local time = TimeUtil.FormatSecond(math.floor(total_time - elapse_time), 10)
		self.node_list["BuyTime"].text.text = time
		self.node_list["SaleEffect"]:SetActive(true)
		self.node_list["IconXianShi"]:SetActive(true)
	end
end

function WeddingView:CompleteTimerCallback()
	if self.node_list and self.node_list["BuyTime"] and self.node_list["BuyTime"].text and self.node_list["BuyTime"].text.text then
		self.node_list["BuyTime"].text.text = ""
		self.node_list["SaleEffect"]:SetActive(false)
		self.node_list["IconXianShi"]:SetActive(false)
	end
end

function WeddingView:SetSelectWeddingIndex(index)
	self.select_wedding_index = index
end

function WeddingView:GetSelectWeddingIndex()
	return self.select_wedding_index
end

WeddingItemCell = WeddingItemCell or BaseClass(BaseCell)

function WeddingItemCell:__init()
	self.parent_view = nil
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["CellItemCell1"])
	self.item_cell:SetData(nil)

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["CellItemCell2"])
	self.equip_cell:SetData(nil)
	self.node_list["PanelWeddingItem"].toggle:AddClickListener(BindTool.Bind(self.Click, self))
end

function WeddingItemCell:__delete()
	self.parent_view = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitleModel"])
end

function WeddingItemCell:SetImage(variable, str)
	local res_str = str .. self.index
	local bundle, asset = ResPath.GetMarryTxtImage(res_str)
	variable.image:LoadSprite(bundle, asset .. ".png")
end

function WeddingItemCell:SetGoldImage()
	local temp_id = 2
	if self.data.need_bind_gold > 0 then
		temp_id = 3
	end
	local res_str = "Icon_Diamon0" .. temp_id
	local bundle, asset = ResPath.GetImages(res_str)
end

function WeddingItemCell:SetCost()
	local cost = 0
	if self.data.need_bind_gold > 0 then
		cost = self.data.need_bind_gold
	else
		cost = self.data.need_gold
	end
	self.node_list["TxtCost"].text.text = cost
end

function WeddingItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	if self.root_node.toggle.isOn then
		self.root_node.transform:SetLocalScale(1, 1, 1)
	else
		self.root_node.transform:SetLocalScale(0.9, 0.9, 0.9)
	end

	-- self.root_node.toggle.isOn = false

	self:SetCost()

	self:SetImage(self.node_list["ImgTitle"], "wedding_title_")
	self:SetGoldImage()

	local reward_item = self.data.reward_item
	local item_data = {}

	--装备格子
	local is_equip = true
	local equip_data = {}
	-- if main_vo.last_marry_time <= 0 then
		-- local equip_reward_data = MarriageData.Instance:GetHunliEquipReward()
		-- equip_data.item_id = equip_reward_data.item_id
	-- end
	if self.data.hunli_type ~= 0 then
	equip_data = reward_item[1]
	end	
	if equip_data and next(equip_data) then
		self.node_list["CellItemCell2"]:SetActive(true)
		self.equip_cell:SetData(equip_data)
	else
		self.node_list["CellItemCell2"]:SetActive(false)
	end
	--物品格子
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	item_data = reward_item[3] and reward_item[3] or reward_item[0]
	self.node_list["CellItemCell1"]:SetActive(true)
	self.item_cell:SetData(item_data)
	if self.node_list["Power"] then
		self.node_list["Power"].text.text = MarriageData.Instance:GetMarriageTipPower(0, WEDDING_TIPS_POWER_TYPE.RING)
	end
	if self.data.title_id > 0 then
		self.node_list["ImgTitleModel"]:SetActive(true)
		self.node_list["TxtTitleReward"]:SetActive(false)
		local bundle, asset = ResPath.GetTitleIcon(self.data.title_id)
		self.node_list["ImgTitleModel"].image:LoadSprite(bundle, asset .. ".png")
		TitleData.Instance:LoadTitleEff(self.node_list["ImgTitleModel"], self.data.title_id, true)
	else
		self.node_list["ImgTitleModel"]:SetActive(false)
		self.node_list["TxtTitleReward"]:SetActive(true)
	end

	-- if main_vo.last_marry_time > 0 and self.data.hunli_type == 0 then
		-- self.node_list["ListGameObject"]:SetActive(false)
		-- self.node_list["TxtHaveItem"]:SetActive(true)
	-- else
		self.node_list["ListGameObject"]:SetActive(true)
		self.node_list["TxtHaveItem"]:SetActive(false)
	-- end
end

function WeddingItemCell:Click()
	self.root_node.toggle.isOn = true
	local select_index = self.parent_view:GetSelectWeddingIndex()
	local reward_info = MarriageData.Instance:GetYuYueRoleInfo().param_ch5
	local reward = bit:d2b(reward_info)
	if reward[32 - self.index + 1] ~= 1 then
		MarriageCtrl.Instance:OpenMarriageTipView(self.index)
	end
	if select_index == self.index then
		return
	end

	self.parent_view:SetSelectWeddingIndex(self.index)
	self.parent_view:FlushGoldLimit()
	self.parent_view:FlushWeddingItem()
end