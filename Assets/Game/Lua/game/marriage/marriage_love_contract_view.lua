MarriageLoveContractView = MarriageLoveContractView or BaseClass(BaseRender)

local PageLeft = 1
local PageRight = 2

function MarriageLoveContractView:__init()
	self.how_day = self.node_list["Howday"]
	self.return_gold = self.node_list["Returntext"]
	self.all_return_gold = self.node_list["Allreturn"]

	self.reward_item_list = {}
	self.reward_node_list = {}
	for i = 1, 4 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["RewardItem" .. i])
	end

	self.contract_item_list = {}
	for i = 1, 7 do
		self.contract_item_list[i] = ContractItemRender.New(self.node_list["ContractItem" .. i])
		self.contract_item_list[i].index = i
		self.contract_item_list[i]:SetClickCallBack(BindTool.Bind1(self.ClickContractHandler, self))
	end

	----------------------------------------------------
	-- 聊天列表生成滚动条
	self.leaveword_cell_list = {}
	self.leaveword_listview_data = {}

	local leaveword_list_delegate = self.node_list["LeaveWordtList"].list_simple_delegate
	leaveword_list_delegate.NumberOfCellsDel = function()
		return #self.leaveword_listview_data or 0
	end
	leaveword_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshLeaveWordListView, self)

	self.node_list["ButtonWish"].button:AddClickListener(BindTool.Bind(self.ClickWishHandler, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickContractTipsHandler, self))
	self.node_list["ImgMask"].button:AddClickListener(BindTool.Bind(self.ClickEditTextCloseHandler, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickEditTextCloseHandler, self))
	self.node_list["ButtonGet"].button:AddClickListener(BindTool.Bind(self.ClickRewardHandler, self))
	self.node_list["BtnSong"].button:AddClickListener(BindTool.Bind(self.ClickDemand, self))
	-- self.node_list["SendButton"].button:AddClickListener(BindTool.Bind(self.ClickSendHandler, self))
	local num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num
	self.select_day = num < 0 and 0 or num
	local other_cfg = MarriageData.Instance:GetMarriageConditions() or {}
	local item_id = PlayerData.Instance.role_vo.sex == 1 and other_cfg.c_title_boy or other_cfg.c_title_girl
	local bundle, asset = ResPath.GetTitleIcon(item_id)
	self.node_list["Title"].image:LoadSprite(bundle, asset)
	self.node_list["Title"].button:AddClickListener(function ()
		local data = PlayerData.Instance.role_vo.sex == 1 and other_cfg.lovecontract_title_boy or other_cfg.lovecontract_title_girl
		TipsCtrl.Instance:OpenItem(data)
		end)
	TitleData.Instance:LoadTitleEff(self.node_list["Title"], item_id, true)
end

function MarriageLoveContractView:__delete()
	for k,v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	for k,v in pairs(self.contract_item_list) do
		v:DeleteMe()
	end
	self.contract_item_list = {}
	TitleData.Instance:ReleaseTitleEff(self.node_list["Title"])
end

function MarriageLoveContractView:ClickDemand()
	local contract_info = MarriageData.Instance:GetQingyuanLoveContractInfo()
	local lover_uid = GameVoManager.Instance:GetMainRoleVo().lover_uid
	MarriageCtrl.Instance:SendQingyuanBuyLoveContract(LOVE_CONTRACT_REQ_TYPE.LC_REQ_TYPE_NOTICE_LOVER_BUY_CONTRACT)
	if contract_info.can_receive_day_num <= 0 then
		local msg_info = ChatData.CreateMsgInfo()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		msg_info.from_uid = main_vo.role_id
		msg_info.role_id = main_vo.role_id
		msg_info.username = main_vo.name
		msg_info.sex = main_vo.sex
		msg_info.camp = main_vo.camp
		msg_info.prof = main_vo.prof
		msg_info.authority_type = main_vo.authority_type
		msg_info.avatar_key_small = main_vo.avatar_key_small
		msg_info.level = main_vo.level
		msg_info.vip_level = main_vo.vip_level
		msg_info.channel_type = CHANNEL_TYPE.PRIVATE
		msg_info.content = Language.Marriage.ContractDemand
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
		msg_info.content_type = CHAT_CONTENT_TYPE.TEXT
		msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
		msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框

		ChatData.Instance:AddPrivateMsg(lover_uid, msg_info)
		ChatCtrl.SendSingleChat(lover_uid, Language.Marriage.ContractDemand, CHAT_CONTENT_TYPE.TEXT)
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.LoverQingqiu)
	end
end

-- 物品奖励列表选择回调函数处理
function MarriageLoveContractView:ClickContractHandler(cell)
	if not cell or not cell.data then return end

	local index = cell.index
	local data = cell.data
	self.select_day = data.day


	--保存选择的格子下标
	MarriageData.Instance:SetLoveContractSelectIndex(index)

	self:FlushLoveContractView()
	-- local contract_cfg = MarriageData.Instance:GetQingyuanLoveContractCfgByDay(index - 1)
	-- if contract_cfg then
	-- 	self.how_day.text.text = string.format(Language.Marriage.LoveContractDayGet, index)
	-- 	self.return_gold.text.text = contract_cfg.reward_gold_bind
	-- end

	-- local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num
	-- local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(index - 1)
	-- local is_open = reward_flag == 0 and data.day <= can_receive_day_num
	-- UI:SetButtonEnabled(self.node_list["ButtonGet"], is_open)
	-- self.node_list["TxtButtonGet"].text.text = reward_flag == 0 and Language.Common.LingQu or Language.Common.YiLingQu
	-- for i = 1, 4 do
	-- 	if data.reward_item[i - 1] then
	-- 		self.node_list["RewardItem" .. i]:SetActive(true)
	-- 		self.reward_item_list[i]:SetData(data.reward_item[i - 1])
	-- 	else
	-- 		self.node_list["RewardItem" .. i]:SetActive(false)
	-- 	end
	-- end
	-- self.node_list["PanelRewardView"]:SetActive(true)
end

function MarriageLoveContractView:LoadCallBack()
	self.node_list["PanelRewardView"]:SetActive(false)
end

-- 聊天列表listview
function MarriageLoveContractView:RefreshLeaveWordListView(cell, data_index, cell_index)
	data_index = data_index + 1
	local leaveword_cell = self.leaveword_cell_list[cell]
	if leaveword_cell == nil then
		leaveword_cell = LeaveWordItemRender.New(cell.gameObject)
		self.leaveword_cell_list[cell] = leaveword_cell
	end
	leaveword_cell:SetIndex(data_index)
	leaveword_cell:SetData(self.leaveword_listview_data[data_index])
end

function MarriageLoveContractView:FlushLoveContractView()
	local love_contract_info = MarriageData.Instance:GetQingyuanLoveContractInfo()
	if love_contract_info == nil then
		return
	end
	UI:SetButtonEnabled(self.node_list["ButtonWish"], love_contract_info.lover_love_contract_timestamp <= 0)
	self.node_list["BtnSong"]:SetActive(love_contract_info.can_receive_day_num < 0)
	self.node_list["Yijihuo"]:SetActive(love_contract_info.can_receive_day_num >= 0)
	local contract_cfg = MarriageData.Instance:GetQingyuanLoveContractCfg()
	for i = 1, 7 do
		if self.contract_item_list[i] and contract_cfg[i] then
			self.contract_item_list[i]:SetData(contract_cfg[i])
			self.contract_item_list[i]:SetHight(self.select_day + 1)
			if i == self.select_day + 1 then
				MarriageData.Instance:SetLoveContractSelectIndex(i)
			end
		end
	end

	local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(self.select_day)
	local num = love_contract_info.can_receive_day_num
	local is_open = reward_flag == 0 and self.select_day <= num
	-- contract_cfg = MarriageData.Instance:GetQingyuanLoveContractCfgByDay(self.select_day - 1)
	self.how_day.text.text = string.format(Language.Marriage.LoveContractDayGet, self.select_day + 1)
	if contract_cfg[self.select_day + 1] then
		self.return_gold.text.text = contract_cfg[self.select_day + 1].reward_gold_bind
	else
		self.return_gold.text.text = ""
	end
	UI:SetButtonEnabled(self.node_list["ButtonGet"], is_open)
	self.all_return_gold.text.text = MarriageData.Instance:GetQingyuanLoveContractReturnGold()
	self.node_list["TxtButtonGet"].text.text = reward_flag == 0 and Language.Common.LingQu or Language.Common.YiLingQu

	-- 设置聊天数据
	self.leaveword_listview_data = love_contract_info.leaveword_list
		GlobalTimerQuest:AddDelayTimer(function()
			self.node_list["LeaveWordtList"].scroller:ReloadData(1)
		end, 0)
end

function MarriageLoveContractView:ClickWishHandler()
	local des = string.format(Language.Marriage.BuyLoveContractTips, MarriageData.Instance:GetQingyuanLoveContractPrice())
	TipsCtrl.Instance:ShowCommonAutoView(nil, des, function ()
		MarriageCtrl.Instance:SendQingyuanBuyLoveContract(LOVE_CONTRACT_REQ_TYPE.LC_REQ_TYPE_BUY_LOVE_CONTRACT)
		self:FlushLoveContractView()
		UI:SetButtonEnabled(self.node_list["ButtonWish"], false)
	end)
end

function MarriageLoveContractView:ClickContractTipsHandler()
	-- 爱情契约Tips
	TipsCtrl.Instance:ShowHelpTipView(154)
end

function MarriageLoveContractView:ClickTitle()
	
end

function MarriageLoveContractView:ClickEditTextCloseHandler()
	self.node_list["PanelRewardView"]:SetActive(false)
end

function MarriageLoveContractView:ClickRewardHandler()
	-- if self.node_list["ContractEditText"].input_field.text == "" then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentNotNull)
	-- 	return
	-- end
	local str = Language.Marriage.GiftIsVeryGood
	local str_cfg = MarriageData.Instance:GetQingyuanLoveContractString()
	local rand_num = math.random(1, #str_cfg)
	if rand_num and str_cfg[rand_num] then
		str = str_cfg[rand_num].des
	end

	local select_index = MarriageData.Instance:GetLoveContractSelectIndex()
	MarriageCtrl.Instance:SendQingyuanFetchLoveContract(0, select_index - 1, str)

	self.node_list["PanelRewardView"]:SetActive(false)
end

function MarriageLoveContractView:ClickSendHandler()
	-- local text = self.node_list["ChatInput"].input_field.text
	-- if text == "" then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentNotNull)
	-- 	return
	-- end
 --    text = ChatFilter.Instance:Filter(text)
    
	-- local select_index = MarriageData.Instance:GetLoveContractSelectIndex()
	-- MarriageCtrl.Instance:SendQingyuanFetchLoveContract(1, select_index - 1, text)
	-- self.node_list["ChatInput"].input_field.text = ""
end

function MarriageLoveContractView:SetFace(index)
	-- local face_id = string.format("%03d", index)
	-- local edit_text = self.node_list["ChatInput"].input_field
	-- if edit_text and ChatData.ExamineEditText(edit_text.text, 3) then
	-- 	self.node_list["ChatInput"].input_field.text = edit_text.text .. "/" .. face_id
	-- 	ChatData.Instance:InsertFaceTab(face_id)
	-- end
end
----------------------------------------------------------------------------
--ContractItemRender	爱情契约itemrender
----------------------------------------------------------------------------
ContractItemRender = ContractItemRender or BaseClass(BaseCell)

function ContractItemRender:__init()
	self.node_list["ListContractItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ContractItemRender:__delete()
end

function ContractItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num
	UI:SetButtonEnabled(self.node_list["ImgIcon"], self.data.day <= can_receive_day_num)
	self:FlushAnimatorData(can_receive_day_num)
end

function ContractItemRender:SetHight(index)
	self.node_list["Select"]:SetActive(self.index == index)
end

-- 刷新animator动画数据
function ContractItemRender:FlushAnimatorData(can_receive_day_num)
	local reward_flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(self.data.day)
	local is_stop = true
	self.node_list["Redpoint"]:SetActive(false)
	if self.data.day <= can_receive_day_num and reward_flag == 0 then
		is_stop = false
		self.node_list["Redpoint"]:SetActive(true)
	end
	
	GlobalTimerQuest:AddDelayTimer(function()
		local animator = self.root_node:GetComponent(typeof(UnityEngine.Animator))
		if animator then
			animator:SetBool("stop", is_stop)
		end
	end, 0)
end

----------------------------------------------------------------------------
--LeaveWordItemRender	爱情契约聊天留言itemrender
----------------------------------------------------------------------------
LeaveWordItemRender = LeaveWordItemRender or BaseClass(BaseCell)

function LeaveWordItemRender:__init()

end

function LeaveWordItemRender:__delete()
end

function LeaveWordItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	self.node_list["TimeTxt"].text.text = os.date(Language.Common.FullTimeStr, self.data.day)
	self.node_list["TxtContent"].text.text = self.data.user_name .. "：" .. ToColorStr(self.data.contract_notice, "#00ffff")
end