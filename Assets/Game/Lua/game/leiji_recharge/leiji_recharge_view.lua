LeiJiRechargeView = LeiJiRechargeView or BaseClass(BaseView)

local MAX_TOGGLE_NUM = 10
local MAX_REWARD_CELL_NUM = 3

function LeiJiRechargeView:__init()
	self.ui_config = {
		{"uis/views/leijirechargeview_prefab", "LeiJiRechargeView"},
	}
	self.toggle_select = 1
	self.box_select = 0

	self.temp_select_index = -1

	--左边的按钮列表
	self.cell_list = {}
	self.btn_list_index = {}
	self.reward_num = 0
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LeiJiRechargeView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.model then 
		self.model:DeleteMe()
		self.model = nil
	end

	if self.mount_model then
		self.mount_model:DeleteMe()
		self.mount_model = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.fight_text = nil
	self.is_first_load = false
end

-- 打开界面显示的初始值
function LeiJiRechargeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE, 0)
	local first_index = 1
	self:OnBtnRecharge(first_index, false)
	self.node_list["ListContent"].transform.localPosition = Vector3(-250, -465, 0)
end

function LeiJiRechargeView:CloseCallBack()
	self.temp_select_index = -1
end

function LeiJiRechargeView:LoadCallBack()
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.mount_model = RoleModel.New()

	self.is_first_load = true

	self.item_list = {}
	for i = 1, MAX_REWARD_CELL_NUM do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["CellItem" .. i])
	end

	self.btn_list_index = KaifuActivityData.Instance:GetLeiJiChongZhiSortFlag()

	self.record_scroll_y = -1
	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	local item_num = #KaifuActivityData.Instance:GetLeijiChongZhiSortCfg()

	local scroll_size = self.node_list["ListView"].rect.sizeDelta
	-- local item_height = scroll_size.y / 7
	local item_height = 80
	local inner_height = math.max(item_num * item_height, scroll_size.y)	-- 算出取内部高度

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/leijirechargeview_prefab", "ToggleLeiJiReCharge", nil,
		function(new_obj)
			if not new_obj then return end
			self.node_list["ListContent"].rect.sizeDelta = Vector2(scroll_size.x, inner_height - scroll_size.y)
			for i = 1, item_num do
				local obj = ResMgr:Instantiate(new_obj)
				local obj_transform = obj.transform
				obj_transform:SetParent(self.node_list["ListContent"].transform, false)
				obj_transform.localPosition = Vector2(0, inner_height - (i - 1) * item_height)

				local item_render = LeiJiRechargeCell.New(obj)
				item_render:SetParentView(self)
				item_render:SetToggleGroup(self.node_list["ScrollerToggleGroup"].toggle_group)
				local data_list = KaifuActivityData.Instance:GetLeiJiChongZhiSortFlag()
				if not data_list or not next(data_list) then 
					return
				end
				local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiDes(data_list[i].seq)
				if cfg then
					local need_chognzhi = cfg.need_chognzhi
					local show_cfg = CommonDataManager.ConverMoney(need_chognzhi)
					item_render.node_list["ToggleLeiJiReCharge"].toggle.isOn = (data_list[i].seq + 1) == self.toggle_select
					local data = {}
					data.need_chognzhi = show_cfg
					data.index = data_list[i].seq + 1
					item_render:SetData(data)
				end
				-- item_render.node_list["ToggleLeiJiReCharge"].toggle:AddClickListener(BindTool.Bind(self.OnBtnRecharge, self, data_list[i].seq + 1))
				self.cell_list[i] = item_render
			end
			
			self:OnValueChanged()
		end)
end

function LeiJiRechargeView:OnValueChanged()
	if not self.node_list["ListContent"] then
		return
	end
	local inner_y = self.node_list["ListContent"].rect.localPosition.y
	if inner_y == self.record_scroll_y then 
		return
	end
	self.record_scroll_y = inner_y
	for _, v in pairs(self.cell_list) do
		local item_y = v.root_node.transform.localPosition.y
		v:SetPosition(math.pow((item_y + inner_y - 270) / 25, 2), item_y)
	end
end

-- 模型展示
function LeiJiRechargeView:ShowModel(index)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	self.temp_select_index = index
	if not cfg and not cfg[index] and self.temp_select_index == index then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(cfg[index].name_show)
	self.node_list["TxtTabName"].text.text = item_cfg.name
	-- 智霖要求特殊处理写死ID，进行放大模型
	if item_cfg.id == 24868 then
		self.node_list["Display"].rect.sizeDelta = Vector3(1440, 828, 0)
		self.node_list["Display"].rect.localPosition = Vector2(-200, 40)
	else
		self.node_list["Display"].rect.sizeDelta = Vector3(1200, 690, 0)
		self.node_list["Display"].rect.localPosition = Vector2(-210, 40)
	end
	self.node_list["EffectModel"]:SetActive(cfg[index].special_show == 1)
	if cfg[index].is_model == 1 then
		self.node_list["Display"]:SetActive(true)
		self.node_list["ImgRechargeIcon"]:SetActive(false)
		self.model:SetRotation(Vector3(0, 0, 0))
		self.model:SetLocalPosition(Vector3(0, 0, 0))
		self.model:ClearModel()
		self.model:ChangeModelByItemId(cfg[index].model_show)
		self.model:ShowRest()
	else
		self.node_list["Display"]:SetActive(false)
		self.node_list["ImgRechargeIcon"]:SetActive(true)
		local bundle, asset = ResPath.GetLeiJiRechargeShowIcon(cfg[index].model_show)
		self.node_list["ImgRechargeIcon"].image:LoadSprite(bundle, asset)
	end
end

-- 开服时间倒计时
function LeiJiRechargeView:KaiFuTime()
	local time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.node_list["TxtTime"].text.text = string.format(Language.Activity.ActivityTime1, TimeUtil.FormatSecond(time, 10))
end

function LeiJiRechargeView:OnFlush()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.KaiFuTime, self), 1)
		self:KaiFuTime()
	end

	local index = KaifuActivityData.Instance:ShowCurSortIndex()
	if index ~= -1 then
		self:OnBtnRecharge(index, true)
	end

	-- if self.node_list["ScrollerToggleGroup"] then
	-- 	self.node_list["ScrollerToggleGroup"].scroller:ReloadData()
	-- end

	self:FlushLeft()
	self:RechargeFlush()
	self:KaiFuTime()
end

function LeiJiRechargeView:FlushLeft()
	for i = 1, #self.cell_list do
		local data_list = KaifuActivityData.Instance:GetLeiJiChongZhiSortFlag()
		if not data_list or not next(data_list) then 
			return
		end
		local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiDes(data_list[i].seq)
		if cfg then
			local need_chognzhi = cfg.need_chognzhi
			local show_cfg = CommonDataManager.ConverMoney(need_chognzhi)
			self.cell_list[i].node_list["ToggleLeiJiReCharge"].toggle.isOn = (data_list[i].seq + 1) == self.toggle_select
			local data = {}
			data.need_chognzhi = show_cfg
			data.index = data_list[i].seq + 1
			self.cell_list[i]:SetData(data)
		end
	end
end

-- 领取奖励按钮
function LeiJiRechargeView:OnClickGet()
	local is_bag_enough = ItemData.Instance:GetEmptyNum()
	if self.cur_flag == 2 and is_bag_enough >= self.reward_num then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE, 
		RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.toggle_select - 1)
	elseif self.cur_flag == 1 then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
	UI:SetButtonEnabled(self.node_list["BtnGet"], self.cur_flag ~= 0)
end

function LeiJiRechargeView:OnClickClose()
	self:Close()
end

-- 根据左按钮Index刷新整体界面显示
function LeiJiRechargeView:RechargeFlush()
	local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiDes(self.toggle_select - 1)
	local money_info = KaifuActivityData.Instance:GetLeiJiChongZhiInfo()
	if not cfg or not money_info then return end
	local special_list = Split(cfg.item_special, ",")
	local reward_cell_num = 0
	for i = 1, MAX_REWARD_CELL_NUM do
		local item_data = cfg.reward_item[i - 1]
		self.item_list[i].root_node:SetActive(item_data ~= nil)
		if item_data then
			local _, big_type = ItemData.Instance:GetItemConfig(item_data.item_id)
			if big_type == GameEnum.ITEM_BIGTYPE_GIF then
				local reward_list = ItemData.Instance:GetGiftItemListByProf(item_data.item_id)
				self.item_list[i]:SetGiftItemId(item_data.item_id)
				item_data = reward_list[1]
				item_data = item_data or cfg.reward_item[i - 1]
			end
			self.item_list[i]:SetData(item_data)
			reward_cell_num = reward_cell_num + 1
			for _, item_id in ipairs(special_list) do
				if tonumber(item_id) == item_data.item_id then
					self.item_list[i]:ShowSpecialEffect(true)
					local bunble, asset = ResPath.GetItemActivityEffect()
					self.item_list[i]:SetSpecialEffect(bunble, asset)
				end
			end
		end
	end
	self.reward_num = reward_cell_num
	self.node_list["TxtCurChongzhi"].text.text = money_info.total_charge_value or 0
	self.node_list["TxtRechargeDiamond"].text.text = cfg.need_chognzhi >= 100000 and (cfg.need_chognzhi / 10000) or cfg.need_chognzhi
	self.node_list["TxtWan"]:SetActive(cfg.need_chognzhi >= 100000)

	local chongzhi_cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
	if chongzhi_cfg and chongzhi_cfg[self.toggle_select] then
		if flag_cfg[chongzhi_cfg[self.toggle_select].seq].flag == 0  then
			self.node_list["TxtGet"].text.text = Language.Activity.FlagAlreadyReceive
		elseif flag_cfg[chongzhi_cfg[self.toggle_select].seq].flag == 1 then
			self.node_list["TxtGet"].text.text = Language.Common.Recharge
		else
			self.node_list["TxtGet"].text.text = Language.Activity.FlagCanAlreadyReceive
		end
		self.node_list["ImgBtnRedPoint"]:SetActive(flag_cfg[chongzhi_cfg[self.toggle_select].seq].flag == 2)
		self.cur_flag = flag_cfg[chongzhi_cfg[self.toggle_select].seq].flag
		UI:SetButtonEnabled(self.node_list["BtnGet"], self.cur_flag ~= 0)
	end
	self:ShowModel(self.toggle_select)

	local temp_power = cfg.capbility or 0
	self.fight_text.text.text = temp_power
end

-- 箱子档位
function LeiJiRechargeView:OnBtnRecharge(index, is_click)
	local select_index = index
	if is_click then
		self:ChangeToIndex(select_index)
	end

	if not is_click and self.is_first_load then
		-- select_index = self.btn_list_index[index].seq + 1
		self:ChangeToIndex(select_index)
		for k,v in pairs(self.cell_list) do
			if index == v:GetIndex() then
				v.node_list["ToggleLeiJiReCharge"].toggle.isOn = true
				break
			end
		end
	end

end

function LeiJiRechargeView:ShowIndexCallBack(index)
	local chongzhi_cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()

	if not chongzhi_cfg or not chongzhi_cfg[index] or not flag_cfg then return end 
	self.toggle_select = index
	self:RechargeFlush()

	local seq = chongzhi_cfg[index].seq
	if not seq or not flag_cfg[seq].flag then return end

	local is_show = flag_cfg[seq].flag ~= 0
	UI:SetButtonEnabled(self.node_list["BtnGet"], is_show)
end

--------------------------------累计充值按钮--------------------------------
LeiJiRechargeCell = LeiJiRechargeCell or BaseClass(BaseCell)

function LeiJiRechargeCell:__init()
	self.obj = nil
	self.index = 0
	self.node_list["ToggleLeiJiReCharge"].toggle:AddClickListener(BindTool.Bind(self.OnBtnRecharge, self))
end

function LeiJiRechargeCell:OnBtnRecharge()
	if self.index ~= 0 and self.parent_view then
		local data_list = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
		if nil ~= data_list then
			self.parent_view:OnBtnRecharge(data_list[self.index - 1].seq + 1)
		end
	end
end
function LeiJiRechargeCell:__delete()
	self.index = 0
	self.parent_view = nil
	self.obj = nil
end

function LeiJiRechargeCell:SetData(data)
	if data == nil then 
		return 
	end
	self.index = data.index
	self.node_list["TxtGold"].text.text = data.need_chognzhi
	self.node_list["TxtName"].text.text = data.name

	local data_list = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()
	if nil ~= data_list then
		self.node_list["ImgRedPoint"]:SetActive(data_list[data.index - 1].flag == 2)
		self.node_list["ImgHasGet"]:SetActive(data_list[data.index - 1].flag == 0)
	end
end

function LeiJiRechargeCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function LeiJiRechargeCell:SetParentView(parent_view)
	self.parent_view = parent_view
end