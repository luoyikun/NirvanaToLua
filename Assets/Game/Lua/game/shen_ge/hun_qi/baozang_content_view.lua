BaoZangContentView = BaoZangContentView or BaseClass(BaseRender)

local EffectList = {
	"UI_lingqi_bao_lan",
	"UI_lingqi_bao_lan",
	"UI_lingqi_bao_zi",
	"UI_lingqi_bao_cheng",
	"UI_lingqi_bao_hong",
}
local AssetPath = {
	"UI_lingqi_xunhuan",
	"UI_lingqi_huiju",
	"UI_luhan_juqi",
	"UI_luhan_juqi_shou",
}
local RotaloAngleLimit = 40

function BaoZangContentView:OpenCallBack()
	self.node_list["NodeNeedHide"]:SetActive(true)
	self.node_list["NodeAllEffect"]:SetActive(false)
	self.node_list["MaskBg"]:SetActive(false)
	self.node_list["NodeEffectNew"]:SetActive(false)
	UITween.AlpahShowPanel(self.node_list["NodeNeedHide"], true, 0.4, DG.Tweening.Ease.InExpo)
	local xunbao_cangku = TreasureData.Instance:GetChestItemInfo()
	self.node_list["RemindBtnWarehouse"]:SetActive(next(xunbao_cangku) ~= nil)
end

function BaoZangContentView:__init()
	self.is_click_button = false
	self.cost = 0

	self.is_free = false
	self.is_has_one_key = false
	self.is_has_ten_key = false

	self.node_list["BtnOne"].button:AddClickListener(BindTool.Bind(self.ClickOpenBox, self, 1))
	self.node_list["BtnTen"].button:AddClickListener(BindTool.Bind(self.ClickOpenBox, self, 10))
	self.node_list["ToggleCheckBox"].button:AddClickListener(BindTool.Bind(self.CheckBoxClick, self))
	self.node_list["BtnAgain"].button:AddClickListener(BindTool.Bind(self.ClickAgain, self))
	self.node_list["BtnReturn"].button:AddClickListener(BindTool.Bind(self.ClickReturn, self))
	self.node_list["ImgCheckBox"]:SetActive(HunQiData.Instance:GetIsShield())
	self.node_list["BtnDuihuan"].button:AddClickListener(BindTool.Bind(self.ClickExchange, self))
	self.node_list["BtnWarehouse"].button:AddClickListener(BindTool.Bind(self.ClickBtnWarehouse, self))
	self.node_list["MaskBg"].button:AddClickListener(BindTool.Bind(self.ClickMaskBg, self))
	self.node_list["EventTrigger"].event_trigger_listener:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.item_one = ItemCell.New()
	self.item_one:SetInstanceParent(self.node_list["NodeItemOne"])

	self.item_list = {}
	self.item_name_list = {}
	for i = 1, 10 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["NodeItemTen"].transform:FindHard("NodeItem" .. i))
		self.item_name_list[i] = self.node_list["NodeItemTen"]:FindObj("NodeItem" .. i .. "/TxtName" .. i)
	end
	self.node_list["NodeItemOne"]:SetActive(false)
	self.node_list["NodeItemTen"]:SetActive(false)

	local bundle, asset = ResPath.GetUiXEffect(AssetPath[3])
	-- self.node_list["NodeEffect"]:ChangeAsset(bundle, asset)
	self.node_list["NodeEffectNew"]:SetActive(false)

	self.contain_cell_list = {}
	for i = 1, 5 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		table.insert(self.contain_cell_list, item)
	end	
	local show_cfg = HunQiData.Instance:GetLookCfg()
	if show_cfg == nil then
		return
	end
	for i, v in ipairs(self.contain_cell_list) do
		if show_cfg[i] and show_cfg[i].item_id then
			self.contain_cell_list[i]:SetData({item_id = show_cfg[i].item_id})
			self.contain_cell_list[i]:SetActive(true)
		else	
			self.contain_cell_list[i]:SetActive(false)
		end
	end	
end

function BaoZangContentView:LoadCallBack()
	self:SetYiZheJumpTwo()
end

-- 寻宝钥匙，一折抢购跳转
function BaoZangContentView:SetYiZheJumpTwo()
	local key_item_id_one = HunQiData.Instance:GetReplaceID() or 0
	local select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_one)

	if not phase then
		local key_item_id_two = HunQiData.Instance:GetTenReplaceID() or 0
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

-- 寻宝钥匙，一折抢购跳转
function BaoZangContentView:StartCountDown(data, node_list)
	self:StopCountDownTwo()
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
				self:StopCountDownTwo()
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
function BaoZangContentView:StopCountDownTwo()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function BaoZangContentView:__delete()
	if self.baoxiang_model then
		self.baoxiang_model:DeleteMe()
		self.baoxiang_model = nil
	end
	self:StopCountDown()
	self:StopCountDownTwo()

	if self.item_one then
		self.item_one:DeleteMe()
		self.item_one = nil
	end

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.delay_send_req then
		GlobalTimerQuest:CancelQuest(self.delay_send_req)
		self.delay_send_req = nil
	end
	self.is_click_button = false

	self.is_free = false
	self.is_has_one_key = false
	self.is_has_ten_key = false

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}	
end

function BaoZangContentView:StopCountDown()
	if self.free_count_down then
		CountDown.Instance:RemoveCountDown(self.free_count_down)
		self.free_count_down = nil
	end
end

function BaoZangContentView:FlushBaoZangCountDown()
	self:StopCountDown()
	local today_open_free_times = HunQiData.Instance:GetTodayOpenFreeBoxNum()
	local max_open_free_times = HunQiData.Instance:GetMaxFreeBoxTimes()
	local replacement_id = HunQiData.Instance:GetReplaceID()
	local asset, bundle = ResPath.GetItemIcon(replacement_id)
	self.node_list["ImgItem"].image:LoadSprite(asset, bundle)	
	local item_count = ItemData.Instance:GetItemNumInBagById(replacement_id)
	self.is_has_one_key = item_count > 0	
	if today_open_free_times < max_open_free_times then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local times = server_time - HunQiData.Instance:GetLastOpenFreeBoxTimeStamp()
		local diff_time = HunQiData.Instance:GetFreeBoxCD() - times
		diff_time = math.ceil(diff_time)
		if diff_time <= 0 then
			self.node_list["TxtFreeTimeDes"].text.text = ""
			self.node_list["TxtCost"]:SetActive(false)
			self.node_list["TxtFreeTips"]:SetActive(true)
			self.node_list["Effect"]:SetActive(true)
			self.is_free = true
			self.node_list["ImgRed"]:SetActive(true)

			self.node_list["ItemNum1"]:SetActive(false)
		else
			local function timer_func(elapse_time, total_time)
				if elapse_time >= total_time then
					self.node_list["TxtFreeTimeDes"].text.text = ""
					self.node_list["TxtCost"]:SetActive(false)
					self.node_list["TxtFreeTips"]:SetActive(true)
					self.node_list["Effect"]:SetActive(true)
					self.is_free = true
					self.node_list["ImgRed"]:SetActive(true)
					self.node_list["TxtCost"].text.text = Language.Common.Free
					self.node_list["ItemNum1"]:SetActive(false)
					self:StopCountDown()
					return
				end
				if item_count > 0 then
					--有钥匙
					self.node_list["TxtCost"]:SetActive(false)
					self.node_list["TxtFreeTips"]:SetActive(false)
					self.node_list["Effect"]:SetActive(false)
					self.is_free = false
					self.node_list["ImgRed"]:SetActive(true)
					self.node_list["TextKeyNum"].text.text = Language.Common.X .. item_count
					self.node_list["ItemNum1"]:SetActive(true)	
				else
					self.node_list["TxtCost"]:SetActive(true)
					self.node_list["TxtFreeTips"]:SetActive(false)
					self.node_list["Effect"]:SetActive(false)
					self.is_free = false
					self.node_list["ImgRed"]:SetActive(false)
					self.node_list["ItemNum1"]:SetActive(false)					
				end
				local temp_diff_time = math.ceil(total_time - elapse_time)
				local time_str = TimeUtil.FormatSecond(temp_diff_time)
				time_str = string.format(Language.HunQi.FreeText, time_str)
				self.node_list["TxtFreeTimeDes"].text.text = time_str				
			end

			local time_str = TimeUtil.FormatSecond(diff_time)
			time_str = string.format(Language.HunQi.FreeText, time_str)
			self.node_list["TxtFreeTimeDes"].text.text = time_str
			if item_count > 0 then
				--有钥匙
				self.node_list["TxtCost"]:SetActive(false)
				self.node_list["TxtFreeTips"]:SetActive(false)
				self.node_list["Effect"]:SetActive(false)
				self.is_free = false
				self.node_list["ImgRed"]:SetActive(true)
				self.node_list["TextKeyNum"].text.text = Language.Common.X .. item_count
				self.node_list["ItemNum1"]:SetActive(true)	
			else
				self.node_list["TxtCost"]:SetActive(true)
				self.node_list["TxtFreeTips"]:SetActive(false)
				self.node_list["Effect"]:SetActive(false)
				self.is_free = false
				self.node_list["ImgRed"]:SetActive(false)
				self.node_list["ItemNum1"]:SetActive(false)					
			end
			self.free_count_down = CountDown.Instance:AddCountDown(diff_time, 1, timer_func)
		end
	elseif item_count > 0 then
		--有钥匙
		self.node_list["TxtCost"]:SetActive(false)
		self.node_list["TxtFreeTips"]:SetActive(false)
		self.node_list["Effect"]:SetActive(false)
		self.is_free = false
		self.node_list["ImgRed"]:SetActive(true)
		self.node_list["TextKeyNum"].text.text = Language.Common.X .. item_count
		self.node_list["ItemNum1"]:SetActive(true)	
	else
		self.node_list["TxtFreeTimeDes"].text.text = ""
		self.node_list["TxtCost"]:SetActive(true)
		self.node_list["TxtFreeTips"]:SetActive(false)
		self.node_list["Effect"]:SetActive(false)
		self.is_free = false
		self.node_list["ImgRed"]:SetActive(false)
		self.node_list["ItemNum1"]:SetActive(false)
	end
end

--刷新相关文本
function BaoZangContentView:FlushContent()
	local box_cfg = HunQiData.Instance:GetBoxCfg()
	if nil == box_cfg then
		return
	end

	--展示宝箱个数
	local box_id = HunQiData.Instance:GetBoxId()
	if box_id <= 0 then
		self.node_list["TxtCost"]:SetActive(false)
		self.node_list["TxtBox"].text.text = Language.HunQi.PutInBox
		return
	end
	self.node_list["TxtCost"]:SetActive(true)
	self.node_list["TxtBox"].text.text = Language.HunQi.OpenBox

	self.cost = box_cfg.cousume_diamond
	self.cost_ten =  box_cfg.cousume_diamond10
	self.node_list["TxtCost"].text.text = self.cost
	self.node_list["TxtCostTenTips"].text.text = self.cost_ten-- self.cost * 10

	local open_box_10_use_itemid = HunQiData.Instance:GetTenReplaceID()
	local asset, bundle = ResPath.GetItemIcon(open_box_10_use_itemid)
	self.node_list["ImgItem10"].image:LoadSprite(asset, bundle)	
	local item_count_10 = ItemData.Instance:GetItemNumInBagById(open_box_10_use_itemid)
	if item_count_10 > 0 then
		self.is_has_ten_key = true
		self.node_list["ItemNum10"]:SetActive(true)
		self.node_list["TxtCostTenTips"]:SetActive(false)
		self.node_list["TextKeyNum10"].text.text = Language.Common.X .. item_count_10
		self.node_list["ImgRed10"]:SetActive(true)
	else
		self.is_has_ten_key = false
		self.node_list["ItemNum10"]:SetActive(false)
		self.node_list["TxtCostTenTips"]:SetActive(true)
		self.node_list["ImgRed10"]:SetActive(false)
	end

	self:FlushBaoZangCountDown()
	local jifen = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.SHENZHOU)
	self.node_list["TxtJifen"].text.text = Language.HunQi.TxtJiFen .. CommonDataManager.ConverMoney(jifen)
	--刷新提醒文本
	local box_reward_count_cfg = HunQiData.Instance:GetBoxRewardCountCfg()
	if nil == box_reward_count_cfg then
		return
	end

	local count = HunQiData.Instance:GetHelpCount()
	local temp_count = count
	local reward_num = box_reward_count_cfg["open_reward" .. (temp_count + 1)]
	if count < 4 then
		local num_1 = box_reward_count_cfg["open_reward" .. (count + 1)]
		for i = count, 3 do
			local num_2 = box_reward_count_cfg["open_reward" .. (i + 2)]
			if num_2 and num_2 > num_1 then
				temp_count = i + 1
				reward_num = num_2
				break
			end
		end
	end
end

function BaoZangContentView:InitView()
	self:FlushContent()
end

function BaoZangContentView:FlushView()
	self:FlushContent()
end

function BaoZangContentView:SetIsClick(state)
	self.is_click_button = state
end

function BaoZangContentView:ShowTreasureType(open_times)
	local item_data_list = TableCopy(ItemData.Instance:GetNormalRewardList())
	for k, v in pairs(item_data_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		v.color = item_cfg.color
	end
	table.sort(item_data_list, SortTools.KeyUpperSorter("color"))

	local color = 1
	for k,v in pairs(item_data_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg.color > color then
			color = tonumber(item_cfg.color)
		end
	end

	self:SetMiHuoMaterials(open_times)

	local call_back = function()
		if self.is_click_button == false then
			return
		end

		self.node_list["NodeAllEffect"]:SetActive(true)
		self.node_list["MaskBg"]:SetActive(true)
		self.node_list["NodeItemOne"]:SetActive(open_times == 1)
		self.node_list["NodeItemTen"]:SetActive(open_times == 10)

		local call_back2 = function()

		end

		if open_times == 1 then
			local cfg = ItemData.Instance:GetItemConfig(item_data_list[1].item_id)
			self.item_one:SetData(item_data_list[1])
			self.node_list["TxtNameOne"].text.text = ToColorStr(cfg.name, ORDER_COLOR[cfg.color])
		elseif open_times == 10 then
			for k, v in pairs(self.item_list) do
				v:SetData(item_data_list[k])
				local cfg = ItemData.Instance:GetItemConfig(item_data_list[k].item_id)
				self.item_name_list[k].text.text = ToColorStr(cfg.name, ORDER_COLOR[cfg.color])
			end
			--if not HunQiData.Instance:GetIsShield() then
				local start_pos = self.node_list["NodeStartMovePos"].transform.anchoredPosition
				for i = 1, 10 do
					local move_obj = self.node_list["NodeItemTen"].transform:FindHard("NodeItem" .. i)
					UITween.MoveScaleShowPanel(move_obj, start_pos, nil, nil, call_back2)
				end
			--end
		end
	end

	local bundle_name, asset_name = ResPath.GetUiXEffect(EffectList[color])
	EffectManager.Instance:PlayAtTransform(
			bundle_name,
			asset_name,
			self.node_list["NodeEffectNew"].transform,			--self.node_list["NodeEffect"].transform,
			0.5, nil, nil, nil,
			call_back)
end

-- 设置继续觅火按钮下的材料显示
function BaoZangContentView:SetMiHuoMaterials(open_times)
	local asset, bundle = "", ""
	local key_count = 0
	if open_times == 1 then
		local replacement_id = HunQiData.Instance:GetReplaceID()
		asset, bundle = ResPath.GetItemIcon(replacement_id)
		key_count = ItemData.Instance:GetItemNumInBagById(replacement_id)
	elseif open_times == 10 then
		local open_box_10_use_itemid = HunQiData.Instance:GetTenReplaceID()
		asset, bundle = ResPath.GetItemIcon(open_box_10_use_itemid)
		key_count = ItemData.Instance:GetItemNumInBagById(open_box_10_use_itemid)
	end
	self.node_list["ImgItemKey"].image:LoadSprite(asset, bundle)
	self.node_list["TextKeyNumKey"].text.text = Language.Common.X .. key_count

	local is_have_key = key_count > 0
	self.node_list["CostGold"]:SetActive(not is_have_key)
	self.node_list["ItemNumKey"]:SetActive(is_have_key)
	if not is_have_key then
		local box_cfg = HunQiData.Instance:GetBoxCfg()
		local cost_gold_count = box_cfg.cousume_diamond
		if open_times == 1 then
			cost_gold_count = box_cfg.cousume_diamond
		elseif open_times == 10 then
			cost_gold_count = box_cfg.cousume_diamond10
		end
		self.node_list["CostGold"].text.text = cost_gold_count
	end
end

function BaoZangContentView:CheckBoxClick()
	local is_shield = HunQiData.Instance:GetIsShield()
	HunQiData.Instance:SetIsShield(not is_shield)
	self.node_list["ImgCheckBox"]:SetActive(not is_shield)
end

function BaoZangContentView:ClickOpenBox(open_times)
	if open_times == 1 then
		HunQiData.Instance:SetCurentOpenBoxType(1)
	elseif open_times == 10 then
		HunQiData.Instance:SetCurentOpenBoxType(10)
	end

	-- 不够钱，不免费，没1抽钥匙，没十抽钥匙直接弹元宝不足面板
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if open_times == 1 and (vo.gold < self.cost * open_times) and self.is_free == false and self.is_has_one_key == false then
		ViewManager.Instance:Open(ViewName.TipsLackDiamondView)
		return
	elseif open_times == 10 and self.is_has_ten_key == false and (vo.gold < self.cost_ten) then
		ViewManager.Instance:Open(ViewName.TipsLackDiamondView)
		return
	end

	self.node_list["NodeAllEffect"]:SetActive(false)
	self.node_list["MaskBg"]:SetActive(false)
	self.node_list["NodeNeedHide"]:SetActive(false)
	

	if not HunQiData.Instance:GetIsShield() then
		local bundle, asset = ResPath.GetUiXEffect(AssetPath[4])
		self.node_list["NodeEffectNew"]:SetActive(true)
		self.node_list["NodeEffectNew"]:ChangeAsset(bundle, asset)
		if self.delay_send_req then
			GlobalTimerQuest:CancelQuest(self.delay_send_req)
			self.delay_send_req = nil
		end
		self.delay_send_req = GlobalTimerQuest:AddDelayTimer(function ()
			HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, open_times)
			self.is_click_button = true		
			end, 0.6)
	else
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, open_times)		
		self.is_click_button = true
	end

	--之前写少条件了，不够钱，不免费，没1抽钥匙，没十抽钥匙都要弹这个面板
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if open_times == 1 and (vo.gold < self.cost * open_times) and self.is_free == false and self.is_has_one_key == false then
		self.node_list["NodeNeedHide"]:SetActive(true)
	elseif open_times == 10 and self.is_has_ten_key == false and (vo.gold < self.cost_ten) then
		self.node_list["NodeNeedHide"]:SetActive(true)
	end
end

function BaoZangContentView:ClickAgain()
	self.node_list["NodeAllEffect"]:SetActive(false)
	self.node_list["MaskBg"]:SetActive(false)
	self.node_list["NodeNeedHide"]:SetActive(true)
	self.node_list["NodeEffectNew"]:SetActive(false)
	self:ClickBtnWarehouse()
end

function BaoZangContentView:ClickMaskBg()
	self.node_list["NodeAllEffect"]:SetActive(false)
	self.node_list["MaskBg"]:SetActive(false)
	self.node_list["NodeNeedHide"]:SetActive(true)
	self.node_list["NodeEffectNew"]:SetActive(false)
end

function BaoZangContentView:ClickReturn()
	local open_times = HunQiData.Instance:GetCurentOpenBoxType()
	-- 不够钱，不免费，没1抽钥匙，没十抽钥匙直接弹元宝不足面板
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if open_times == 1 and (vo.gold < self.cost * open_times) and self.is_free == false and self.is_has_one_key == false then
		ViewManager.Instance:Open(ViewName.TipsLackDiamondView)
		return
	elseif open_times == 10 and self.is_has_ten_key == false and (vo.gold < self.cost * open_times) then
		ViewManager.Instance:Open(ViewName.TipsLackDiamondView)
		return
	end

	self.node_list["NodeAllEffect"]:SetActive(false)
	self.node_list["MaskBg"]:SetActive(false)
	self.node_list["NodeNeedHide"]:SetActive(false)
	if not HunQiData.Instance:GetIsShield() then
		local bundle, asset = ResPath.GetUiXEffect(AssetPath[4])
		-- self.node_list["NodeEffect"]:ChangeAsset(bundle, asset)
		self.node_list["NodeEffectNew"]:SetActive(true)
		self.node_list["NodeEffectNew"]:ChangeAsset(bundle, asset)
		if self.delay_send_req then
			GlobalTimerQuest:CancelQuest(self.delay_send_req)
			self.delay_send_req = nil
		end
		self.delay_send_req = GlobalTimerQuest:AddDelayTimer(function ()
			HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, open_times)			
			self.is_click_button = true
			end, 0.6)
	else
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, open_times)
		self.is_click_button = true
	end

	--之前写少条件了，不够钱，不免费，没1抽钥匙，没十抽钥匙都要弹这个面板
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if open_times == 1 and (vo.gold < self.cost * open_times) and self.is_free == false and self.is_has_one_key == false then
		self.node_list["NodeNeedHide"]:SetActive(true)
	elseif open_times == 10 and self.is_has_ten_key == false and (vo.gold < self.cost * open_times) then
		self.node_list["NodeNeedHide"]:SetActive(true)
	end
end

-- 点击兑换按钮
function BaoZangContentView:ClickExchange()
	ViewManager.Instance:Open(ViewName.YiHuoExchange)
end

-- 点击寻宝仓库按钮
function BaoZangContentView:ClickBtnWarehouse()
	ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
end

-- 设置寻宝仓库按钮红点
function BaoZangContentView:GetRemindBtnWarehouse()
	if self.node_list["RemindBtnWarehouse"] then
		return self.node_list["RemindBtnWarehouse"]
	end
end

function BaoZangContentView:OnRoleDrag(data)
	local transform = self.node_list["NodeEffect"].transform
	local x_angles = self:GetAngle(transform.localEulerAngles.x)
	local y_delta = data.delta.y
	if x_angles <= RotaloAngleLimit and x_angles >= -1 * RotaloAngleLimit or
		x_angles >= RotaloAngleLimit and y_delta <= 0 or x_angles <= -1 * RotaloAngleLimit and y_delta >= 0 then
		self.node_list["NodeEffect"].transform:Rotate(y_delta * 0.02, 0, 0)
	end
	self:CheckAngle(transform.localEulerAngles)
	self.node_list["NodeEffect2"].transform.localEulerAngles = self.node_list["NodeEffect"].transform.localEulerAngles
end

function BaoZangContentView:GetAngle(value)
	local angle = value - 180
	if angle >= 0 then
		return angle - 180
	end
	return angle + 180
end

function BaoZangContentView:CheckAngle(localEulerAngles)
	local angle = self:GetAngle(localEulerAngles.x)
	if angle > RotaloAngleLimit then
		localEulerAngles.x = RotaloAngleLimit
	elseif angle < -1 * RotaloAngleLimit then
		localEulerAngles.x = RotaloAngleLimit * -1
	end
end