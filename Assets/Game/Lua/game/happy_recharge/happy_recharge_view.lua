HappyRechargeView = HappyRechargeView or BaseClass(BaseView)

function HappyRechargeView:__init()
	self.ui_config = {{"uis/views/happyrecharge_prefab", "HappyRecharge"}}
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
end

function HappyRechargeView:__delete()
	-- body
end

function HappyRechargeView:LoadCallBack()
	
	self.show_info_list = HappyRechargeData.Instance:GetItemListInfo()

	self.left_info_list = {}
	self.right_info_list = {}
	for k,v in pairs(self.show_info_list) do
		if v.cfg_type == 1 then
			table.insert(self.right_info_list, v)
		else
			table.insert(self.left_info_list, v)
		end
	end
	self.reward_cell_list = {}
	for i = 0, 5 do
		local item_cell = self.node_list["RewardList"].transform:GetChild(i).gameObject
		item_cell = HappyRewardItem.New(item_cell)
		item_cell:SetIndex(i+1)
		item_cell:SetData(self.right_info_list[i + 1])
		table.insert(self.reward_cell_list, item_cell)
	end

	self.item_cell_list = {}
	for i = 1, 7 do
		self.item_cell_list[i] = self.node_list["Item"..i]
		if nil ~= self.item_cell_list[i] and nil ~= self.left_info_list[i] then
			self.item_cell_list[i] = ItemCell.New()
			self.item_cell_list[i]:SetInstanceParent(self.node_list["Item"..i])
			self.item_cell_list[i]:SetData(self.left_info_list[i].reward_item)
		end
	end
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["ButtonOnce"].button:AddClickListener(BindTool.Bind(self.ClickOnce, self))
	self.node_list["ButtonTenTimes"].button:AddClickListener(BindTool.Bind(self.ClickTen, self))
	self.node_list["ButtonRecord"].button:AddClickListener(BindTool.Bind(self.ClickRecord, self))
	self.node_list["ButtonRule"].button:AddClickListener(BindTool.Bind(self.ClickRule, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))

	self.node_list["TextCost"].text.text = string.format(Language.Activity.ChongZhi, HappyRechargeData.Instance:GetCost())

	self:OnFlush()
end

function HappyRechargeView:ReleaseCallBack()
	for k,v in pairs(self.reward_cell_list) do
		v:DeleteMe()
	end
	self.reward_cell_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function HappyRechargeView:OpenCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local time = HappyRechargeData.Instance:GetRestTime()
	self:SetTime(time)
	self.least_time_timer = CountDown.Instance:AddCountDown(time, 1, function ()
		time = time - 1
		self:SetTime(time)
		end)
end

function HappyRechargeView:CloseCallBack()
	if self.least_time_timer then
	CountDown.Instance:RemoveCountDown(self.least_time_timer)
	self.least_time_timer = nil
	end
end

function HappyRechargeView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)
end

function HappyRechargeView:SetTime(time)
	time_tab = TimeUtil.Format2TableDHMS(time)
	local str = ""
	if time_tab.day >= 1 then
		str = string.format(Language.IncreaseCapablity.ResTime, time_tab.day, time_tab.hour)
	else
		str = string.format("<color=#89f201>%s:%s:%s</color>", time_tab.hour, time_tab.min, time_tab.s)
	end

	self.node_list["TextTime"].text.text = str
end

function HappyRechargeView:OnFlush()
	self:ShowChontZhiValue()

	for k,v in pairs(self.reward_cell_list) do
		v:Flush()
	end

	self:RedPointShow()
end

function HappyRechargeView:ClickOnce()
	HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE, 
		RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU, 1)
end

function HappyRechargeView:ClickTen()
	-- 活动号 操作类型 次数
	HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE, 
		RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU, 10)
end

function HappyRechargeView:ClickRecord()
	ViewManager.Instance:Open(ViewName.HappyRecordListView)
end

function HappyRechargeView:ClickRule()
	TipsCtrl.Instance:ShowHelpTipView(228)
end

function HappyRechargeView:CloseView()
	self:Close()
end

-- 可抽取红点提示
function HappyRechargeView:RedPointShow()
	local count = HappyRechargeData.Instance:GetCost()  --充值多少次可以抽取
	if nil == count then return end
	local current_value = HappyRechargeData.Instance:GetChongZhiVlaue()  --当前充值次数
	if nil == current_value then return end

	if current_value >= (count * 10 ) then
		self.node_list["RedPointBtnTen"]:SetActive(true)
		self.node_list["RedPointBtnOnce"]:SetActive(true)
		return
	end
	self.node_list["RedPointBtnTen"]:SetActive(false)
		
	if current_value >= count then
		self.node_list["RedPointBtnOnce"]:SetActive(true)
		return
	end
	self.node_list["RedPointBtnOnce"]:SetActive(false)
end

-- 显示充值次数，提示
function HappyRechargeView:ShowChontZhiValue()
	local count = HappyRechargeData.Instance:GetCost()  --充值多少次可以抽取
	if nil == count then return end
	local current_value = HappyRechargeData.Instance:GetChongZhiVlaue()  --当前充值次数
	if nil == current_value then return end

	self.node_list["RewardTimes"].text.text = HappyRechargeData.Instance:GetTotalTimes()
	if current_value >= (count * 10 ) then
		self.node_list["Rechargecount"].text.text = string.format("<color=#89f201FF>%s</color> / %s", current_value, count * 10)
	else
		self.node_list["Rechargecount"].text.text = string.format("<color=#F9463BFF>%s</color> / %s", current_value, count * 10)
	end
end

-------------------------------HappyRewardItem------------------------------------
HappyRewardItem = HappyRewardItem or BaseClass(BaseCell)
function HappyRewardItem:__init()
	self.is_able_get = false
	self.is_get = true

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Cell"])

	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickGet, self))
end

function HappyRewardItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function HappyRewardItem:OnFlush()
	self.data = self:GetData()
	if self.data == nil then return end
	if next(self.data) then
		self.item_cell:SetData(self.data.reward_item)
		self.node_list["TextTimes"].text.text = string.format(Language.Activity.CiShu, self.data.server_niu_times)
		self.node_list["VipLevel"].text.text = string.format(Language.BlessWater.VIPLimit, self.data.vip_limit)
		self.index = self:GetIndex()
		self.buffer = bit:d2b(HappyRechargeData.Instance:GetFetchFlag())

		local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		local total_time = HappyRechargeData.Instance:GetTotalTimes()
		local vip_flag = vip_level >= self.data.vip_limit
		local time_flag = total_time >= self.data.server_niu_times

		local is_get = self.buffer[#self.buffer - self.index + 1] == 1
		self.is_get = is_get

		self.node_list["TextGet"].text.text = Language.ContinuousRecharge.Fetch
		if is_get then
			self.node_list["TextGet"].text.text = Language.ContinuousRecharge.HasFetch
		end

		UI:SetButtonEnabled(self.node_list["Button"], vip_flag and time_flag and not is_get)
		local total_times = HappyRechargeData.Instance:GetTotalTimes()
		self.is_able_get = self.data.server_niu_times <= total_times

		self.node_list["ImgRedPoint"]:SetActive((not is_get) and self.is_able_get)
	end
end

function HappyRewardItem:ClickGet()
	if not self.is_get then
		if self.is_able_get then
			HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE, 
			RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_FETCH_REWARD, self.index - 1)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.CantGet)
		end
	end
end


