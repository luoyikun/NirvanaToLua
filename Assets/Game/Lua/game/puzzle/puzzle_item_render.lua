-----------------翻翻转格子------------------
PuzzleFlipCellItemRender = PuzzleFlipCellItemRender or BaseClass(BaseCell)

function PuzzleFlipCellItemRender:__init()
	self.flip_cell = ItemCell.New()
	self.flip_cell:SetInstanceParent(self.node_list["Item"])
	self.node_list["PuzzleItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function PuzzleFlipCellItemRender:__delete()
	self.flip_cell:DeleteMe()
end

function PuzzleFlipCellItemRender:OnFlush()
	if nil == self.data or nil == self.data.seq_type then return end

	if self.data.seq_type == 0 then
		self.flip_cell:SetData({})
		self.node_list["Item"]:SetActive(false)
		self.node_list["TxtWord"]:SetActive(false)
		self.is_front = false
		self.node_list["Bg"].image:LoadSprite("uis/views/randomact/puzzle/images_atlas", "PuzzleCard" .. self.index)
	elseif self.data.seq_type == 1 then
		self.flip_cell:SetData(self.data.info)
		self.flip_cell:SetData(self.data.info)
		self.node_list["Item"]:SetActive(true)
		self.node_list["TxtWord"]:SetActive(false)
		self.is_front = true
		self.node_list["Bg"].image:LoadSprite("uis/views/randomact/puzzle/images_atlas", "bg_04")
	elseif self.data.seq_type == 2 then
		self.flip_cell:SetData({})
		-- self.flip_cell:ShowGetEffect(true)
		self.node_list["Item"]:SetActive(true)
		self.node_list["TxtWord"].image:LoadSprite("uis/views/randomact/puzzle/images_atlas", "PuzzleWord" .. self.data.info + 1)
		self.node_list["TxtWord"]:SetActive(true)
		self.is_front = true
		self.node_list["Bg"].image:LoadSprite("uis/views/randomact/puzzle/images_atlas", "bg_04")
	end
end
function PuzzleFlipCellItemRender:ShowHighLight(value)
	self.flip_cell:ShowHighLight(value)
end

function PuzzleFlipCellItemRender:SetIndex(index)
	self.index = index
end

---翻转动画
function PuzzleFlipCellItemRender:RunFilpAnim()
	if IsNil(self.node_list["Bg"].rect) then return end
	self.node_list["Bg"].rect:SetLocalScale(1, 1, 1)
	local target_scale = Vector3(0, 1, 1)
	local target_scale2 = Vector3(1, 1, 1)
	self.tweener1 = self.node_list["Bg"].rect:DOScale(target_scale, 0.1)

	local func2 = function()
		self.tweener2 = self.node_list["Bg"].rect:DOScale(target_scale2, 0.1)
		self.is_rotation = false
	end
	self.tweener1:OnComplete(func2)
end

-----------------兑换奖励Item------------------
RewardExchangeItemRender = RewardExchangeItemRender or BaseClass(BaseCell)

function RewardExchangeItemRender:__init()
	self.node_list["BtnButton"].button:AddClickListener(BindTool.Bind(self.OnClickBtnExchange, self))

	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.node_list["Item"])

end

function RewardExchangeItemRender:__delete()
	self.reward_cell:DeleteMe()
	self.words_list = nil
end

function RewardExchangeItemRender:OnClickBtnExchange()
	if nil == self.data then return end
	PuzzleCtrl.Instance:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_WORD_EXCHANGE, self.data.index)
end

function RewardExchangeItemRender:OnFlush()
	if self.data.index == nil then return end
	local flip_word_info = PuzzleData.Instance:GetFlipWordInfo()
	local word_info = PuzzleData.Instance:GetWrodInfo(self.data.index)
	local word_act_info = PuzzleData.Instance:GetWrodActiveInfo(self.data.index)

	UI:SetButtonEnabled(self.node_list["BtnButton"], (self.data.exchange_num > 0))
	UI:SetButtonEnabled(self.node_list["TxtButton"], (self.data.exchange_num > 0))


	
	local active_trigger = self.data.exchange_num > 0 and true or false
	self.node_list["ImgRemind"]:SetActive(active_trigger)
	self.node_list["TxtRemind"].text.text = self.data.exchange_num

	UI:SetGraphicGrey(self.node_list["TxtWord1"], not (self.data.exchange_num > 0))
	UI:SetGraphicGrey(self.node_list["TxtWord2"], not (self.data.exchange_num > 0))
	UI:SetGraphicGrey(self.node_list["TxtWord3"], not (self.data.exchange_num > 0))
	UI:SetGraphicGrey(self.node_list["TxtWord4"], not (self.data.exchange_num > 0))
	if word_info == nil or word_act_info == nil then return end

	local cur_index = PuzzleData.Instance:GetCurWrodGroupIndex()
	for i = 1, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD do
		self.node_list["TxtWord" .. i].image:LoadSprite("uis/views/randomact/puzzle/images_atlas", "PuzzleWord" .. (self.data.index * 4 + i))
	end
	self.reward_cell:SetData(word_info.exchange_item)
end

function RewardExchangeItemRender:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function RewardExchangeItemRender:ShowHighLight(value)
	self.reward_cell:ShowHighLight(value)
end

---------------PuzzleBaoDiItemRender--------------------
PuzzleBaoDiItemRender = PuzzleBaoDiItemRender or BaseClass(BaseCell)
function PuzzleBaoDiItemRender:__init()
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.node_list["Item"])
	self.reward_cell.root_node.transform:SetAsFirstSibling()

end

function PuzzleBaoDiItemRender:__delete()
	self.reward_cell:DeleteMe()
end

function PuzzleBaoDiItemRender:OnFlush()

	if nil == self.data then return end
	self.root_node:SetActive(next(self.data) ~= nil)
	if next(self.data) == nil then
		return
	end

	local num = PuzzleData.Instance:GetBaodiTotal()
	self.total_time = num
	self.node_list["TotalNumberText"].text.text = string.format(Language.Puzzle.TargetTimes, self.total_time, self.data.choujiang_times)
	self.reward_cell:SetData(self.data.reward_item)
	--是否已经领取保底奖励
	local is_giveout_reward = PuzzleData.Instance:IsGiveoutReward(self.data.index)
	
	self.node_list["CanGetRewardText"]:SetActive(false)
	self.node_list["TotalNumberText"]:SetActive(false)
	self.node_list["ImgHighLight"]:SetActive(false)
	self.node_list["ImgBgGray"]:SetActive(false)
	self.node_list["ItemEffect"]:SetActive(false)
	--翻牌总数
	local info_baodi_total = PuzzleData.Instance:GetBaodiTotal() or 0 
	if is_giveout_reward then
		self.node_list["ImgBgGray"]:SetActive(true)
		self.reward_cell:ListenClick()
	elseif info_baodi_total >= self.data.choujiang_times then
		self.node_list["RewardButton"].button:AddClickListener(BindTool.Bind(self.OnClickBaoDiItem, self))
		self.node_list["CanGetRewardText"]:SetActive(true)
		self.node_list["ItemEffect"]:SetActive(true)
		self.node_list["ImgHighLight"]:SetActive(true)
	else
		self.reward_cell:ListenClick()--BindTool.Bind(self.OnClickBaoDiItem, self)为什么条件不满足是发协议呢？
		self.node_list["TotalNumberText"]:SetActive(true)
	end


end

function PuzzleBaoDiItemRender:ShowHighLight(value)
	self.reward_cell:ShowHighLight(value)
end

function PuzzleBaoDiItemRender:OnClickBaoDiItem()

	if nil == self.data then return end

	local info_baodi_total = PuzzleData.Instance:GetBaodiTotal()
	local is_giveout_reward = PuzzleData.Instance:IsGiveoutReward(self.data.index)
	if not is_giveout_reward and info_baodi_total >= self.data.choujiang_times then
		PuzzleCtrl.Instance:SendGetBaoDi(self.data.index)
	end
end