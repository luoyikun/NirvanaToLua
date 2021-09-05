-- 仙宠猎取-HuntContent
SpiritHuntView = SpiritHuntView or BaseClass(BaseRender)

function SpiritHuntView:__init()

end

function SpiritHuntView:LoadCallBack(instance)
	-- self.node_list["DanMuToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickDanMu, self)) -- 弹幕的屏蔽，不要删了
	self.node_list["PlayAniToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickPlayAniToggle, self))
	self.node_list["OneceBtn"].button:AddClickListener(BindTool.Bind(self.OnClickOnece, self))
	self.node_list["TenTimesBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTen, self))
	self.node_list["BtnTujian"].button:AddClickListener(BindTool.Bind(self.SpiritTujian, self))
	self.node_list["BtnCangKu"].button:AddClickListener(BindTool.Bind(self.OpenCangKu, self))
	self.node_list["BtnDuiHuan"].button:AddClickListener(BindTool.Bind(self.OpenExchange, self))

	self.time_quest = {}
	self.is_first_open = true
	self.power_data = nil
	self.node_list["DanMuToggle"].toggle.isOn = RollingBarrageData.Instance:GetRecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)

	self.model_list = {}
	for i = 1, 4 do
		self.model_list[i] = RoleModel.New()
		self.model_list[i]:SetDisplay(self.node_list["Display" .. i].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end

	self:SetYiZheJumpTwo()
end

-- 寻宝钥匙，一折抢购跳转
function SpiritHuntView:SetYiZheJumpTwo()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("chestshop_auto").other[1]
	if other_cfg then
		local key_item_id_one = other_cfg.jingling_use_itemid or 0
		local select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_one)

		if not phase then
			local key_item_id_two = other_cfg.jingling_10_use_itemid or 0
			select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_two)
			if not phase then
				return
			end
		end

		local info = DisCountData.Instance:GetDiscountInfoByType(phase, true)
		if not info then
			return
		end

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.level < info.active_level then
			return
		end

		if info.close_timestamp then
			if info.close_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
				local callback = function(node_list)
					node_list["BtnYiZhe"].button:AddClickListener(function()
					ViewManager.Instance:CloseAll()
					ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
					end)
					self:StartCountDown(info, node_list)
				end
				CommonDataManager.SetYiZheBtnJumpTwo(self, self.node_list["BtnYiZheJumpTwo"], callback)
			end
		end
	end
end

-- 寻宝钥匙，一折抢购跳转
function SpiritHuntView:StartCountDown(data, node_list)
	self:StopCountDown()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				self.node_list["BtnYiZheJump"]:SetActive(false)
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 寻宝钥匙，一折抢购跳转
function SpiritHuntView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function SpiritHuntView:__delete()
	self:StopCountDown()

	for i = 1, 4 do
		if self.model_list[i] then
			self.model_list[i]:DeleteMe()
			self.model_list[i] = nil
		end
	end
	self.model_list = {}

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.is_first_open = nil

	for k, v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.time_quest = {}
end

-- 仙宠仓库红点提示
function SpiritHuntView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.node_list["RedPointCangKu"] then
		self.self.node_list["RedPointCangKu"]:SetActive(num > 0)
	end
end

function SpiritHuntView:FulushRedPoint()
	local item_list = SpiritData.Instance:GetHuntSpiritWarehouseList()
	self.node_list["RedPointCangKu"]:SetActive(#item_list > 0)
end

function SpiritHuntView:OnClickPlayAniToggle()
	SpiritData.Instance:SetPlayAniState(self.node_list["PlayAniToggle"].toggle.isOn)
end

function SpiritHuntView:OnClickOnece()
	local count = SpiritData.Instance:GetSpiritBagNum()
	if count > 0 then
		SpiritData.Instance:SetChestshopMode(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1)
		SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpriteBagFull)
	end
end

function SpiritHuntView:OnClickTen()
	local count = SpiritData.Instance:GetSpiritBagNum()
	if count >= 10 then
		SpiritData.Instance:SetChestshopMode(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10)
		SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpriteBagFull)
	end

end

function SpiritHuntView:OnClickDanMu()
	RollingBarrageData.Instance:RecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, self.node_list["DanMuToggle"].toggle.isOn)

	if self.node_list["DanMuToggle"].toggle.isOn then
		ViewManager.Instance:Close(ViewName.RollingBarrageView)
	else
		RollingBarrageData.Instance:SetNowCheckType(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
		ViewManager.Instance:Open(ViewName.RollingBarrageView)
	end
end

function SpiritHuntView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	for k, v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.time_quest = {}
	self.is_first_open = true
end

function SpiritHuntView:SetModleRestAni(model, index)
	local timer = 8
	if not self.time_quest[index] then
		self.time_quest[index] = GlobalTimerQuest:AddRunQuest(function()
			timer = timer - UnityEngine.Time.deltaTime
			if timer <= 0 then
				if model then
					model:SetTrigger(ANIMATOR_PARAM.REST)
				end
				timer = 8
			end
		end, 0)
	end
end

function SpiritHuntView:SetCardState(diff_time)
	local cfg = ConfigManager.Instance:GetAutoConfig("chestshop_auto").other[1] or {}
	local once_card_num = ItemData.Instance:GetItemNumInBagById(cfg.jingling_use_itemid)
	local once_card_cfg = ItemData.Instance:GetItemConfig(cfg.jingling_use_itemid)

	self.node_list["OnceCardNode"]:SetActive(once_card_num > 0 and diff_time > 0)
	self.node_list["OnceImg"]:SetActive(not (once_card_num > 0) and diff_time > 0)
	self.node_list["CardImg"]:SetActive(once_card_num > 0 or diff_time <= 0)
	self.node_list["Effect"]:SetActive(once_card_num > 0 or diff_time <= 0)
	if once_card_num > 0 and once_card_cfg then
		self.node_list["CardTxt1"].text.text = "X " .. once_card_num
	end

	local ten_card_num = ItemData.Instance:GetItemNumInBagById(cfg.jingling_10_use_itemid)
	local ten_card_cfg = ItemData.Instance:GetItemConfig(cfg.jingling_10_use_itemid)

	self.node_list["TenCardNode"]:SetActive(ten_card_num > 0)
	self.node_list["TenCardImg"]:SetActive(not (ten_card_num > 0))
	self.node_list["CardImg2"]:SetActive(ten_card_num > 0)
	if ten_card_num > 0 and ten_card_cfg then
		self.node_list["CardTxt"].text.text = "X " .. ten_card_num
	end
	RemindManager.Instance:Fire(RemindName.SpiritFreeHunt)
end

-- 设置仙宠展示模型
function SpiritHuntView:SetSpiritShowModel()
	local display_list = ConfigManager.Instance:GetAutoConfig("chestshop_auto").fumo_item_list
	if display_list and self.is_first_open then
		for k, v in pairs(display_list) do
			self:SetModleRestAni(self.model_list[k], k)
			self.model_list[k]:ResetRotation()
			local vect = Vector3(0, 0, 0)
			if k <= 2 then
				vect = Vector3(0, -15, 0)
			else
				vect = Vector3(0, 15, 0)
			end
			self.model_list[k]:SetRotation(vect)
			self.model_list[k]:SetMainAsset(ResPath.GetSpiritModel(v.rare_item_id))
		end

		self.node_list["PlayAniToggle"].toggle.isOn = false
		SpiritData.Instance:SetPlayAniState(false)
		self.is_first_open = false
	end
end

function SpiritHuntView:OnFlush()
	self:FulushRedPoint()
	self:SetSpiritShowModel()
	if SpiritData.Instance:GethuntSpiritPriceCfg() then
		self.node_list["minTxt"].text.text = SpiritData.Instance:GethuntSpiritPriceCfg()[1].jingling_gold_1
		self.node_list["TxtSec"].text.text = SpiritData.Instance:GethuntSpiritPriceCfg()[1].jingling_gold_10
	end

	local diff_time = SpiritData.Instance:GetHuntSpiritFreeTime() - TimeCtrl.Instance:GetServerTime()
	self.node_list["TimeTxt"]:SetActive(diff_time > 0)
	self.node_list["FreeTxt"]:SetActive(diff_time <= 0)

	self:SetCardState(diff_time)

	if self.count_down == nil and diff_time > 0 then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				self.node_list["TimeTxt"]:SetActive(false)
				self.node_list["OnceImg"]:SetActive(true)
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.node_list["TimeTxt"].text.text = string.format(Language.Browse.TimeTxt,left_hour,left_min,left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end

	self.node_list["DanMuToggle"].toggle.isOn = RollingBarrageData.Instance:GetRecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
end

--打开仓库面板
function SpiritHuntView:OpenCangKu()
	ViewManager.Instance:Open(ViewName.SpiritWarehouseView)
end

-- 打开兑换面板
function SpiritHuntView:OpenExchange()
	-- ViewManager.Instance:Open(ViewName.SpiritExchangeView)
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_jingling)
end

-- 打开仙宠图鉴面板
function SpiritHuntView:SpiritTujian()
	ViewManager.Instance:Open(ViewName.SpiritTujian)
end

function SpiritHuntView:UITween()
	UITween.MoveShowPanel(self.node_list["BtnList"], Vector3(-90, 40, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["ButtonPanel"], Vector3(-52, -510, 0), 0.7)
end