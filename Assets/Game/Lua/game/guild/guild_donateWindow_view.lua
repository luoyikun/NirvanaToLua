DonateWindowView = DonateWindowView or BaseClass(BaseView)

function DonateWindowView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/guildview_prefab", "GuildDonateWindow"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.donate_gold = 0
	self.donate_card = 0
end

function DonateWindowView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(755, 500, 0)
	self.node_list["Txt"].text.text = Language.Guild.DonateTxt
	self.node_list["ButtonPlusCard"].button:AddClickListener(BindTool.Bind(self.OnCardPlus, self))
	self.node_list["ButtonReduce"].button:AddClickListener(BindTool.Bind(self.OnCardReduce, self))
	self.node_list["MaxButton"].button:AddClickListener(BindTool.Bind(self.OnCardMax, self))
	self.node_list["ButtonPlusGold"].button:AddClickListener(BindTool.Bind(self.OnGoldPlus, self))
	self.node_list["ButtonReduceGold"].button:AddClickListener(BindTool.Bind(self.OnGoldReduce, self))
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnCardDonate, self))
	self.node_list["BtnInputCardFiled"].button:AddClickListener(BindTool.Bind(self.OnGoldDonate, self))
	self.node_list["InputGold"].button:AddClickListener(BindTool.Bind(self.OnClickGoldInput, self))
	self.node_list["InputCard"].button:AddClickListener(BindTool.Bind(self.OnClickCardInput, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function DonateWindowView:ReleaseCallBack()

end

function DonateWindowView:CloseCallBack()

end

function DonateWindowView:OpenCallBack()
	self:FlushDonate()
end

function DonateWindowView:OnFlush()
	self:FlushDonate()
	local use_gold = GuildData.Instance:GetGongXianMaxGold()
	local max_gold = GuildData.Instance:GetOtherConfig().day_juanxian_gold_limit
	UI:SetButtonEnabled(self.node_list["BtnInputCardFiled"], (max_gold - use_gold > 0))
end

function DonateWindowView:FlushDonate()
	self.card = 0
	local card_id = GuildData.Instance:GetGuildJianSheId()
	if card_id then
		self.card = ItemData.Instance:GetItemNumInBagById(card_id)
	end
	self.node_list["CurrentCard"].text.text = self.card

	self.node_list["InputGoldNum"].text.text = 0
	self.node_list["InputCardNum"].text.text = self.card
	self.donate_gold = 0
	self.donate_card = self.card

	local guild_gongxian = GuildData.Instance:GetGuildGongxian()
	local guild_total_gongxian = GuildData.Instance:GetGuildTotalGongxian()
	self.node_list["MyDonation"].text.text = guild_gongxian

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.gold = vo.gold
	self.node_list["CurrentGold"].text.text = self.gold

	local exp = CommonDataManager.ConverMoney(GuildDataConst.GUILDVO.guild_exp)
	self.node_list["TextZiJin"].text.text = exp
end

--增加捐献令牌
function DonateWindowView:OnCardPlus()
	self.donate_card = self.donate_card + 1
	if(self.donate_card > self.card) then
		self.donate_card = self.card
	end
	self.node_list["InputCardNum"].text.text = self.donate_card
end

--减少捐献令牌
function DonateWindowView:OnCardReduce()
	self.donate_card = self.donate_card - 1
	if(self.donate_card < 0) then
		self.donate_card = 0
	end
	self.node_list["InputCardNum"].text.text = self.donate_card
end

--最大捐献令牌
function DonateWindowView:OnCardMax()
	self.donate_card = self.card
	self.node_list["InputCardNum"].text.text = self.donate_card
end

--捐献令牌
function DonateWindowView:OnCardDonate()
	if self.donate_card > 0 then
		local card_id = GuildData.Instance:GetGuildJianSheId()
		GuildCtrl.Instance:SendAddGuildExpReq(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_ITEM, 0, 0, {{item_id = card_id, item_num = self.donate_card}})
	end
end

--增加捐献钻石
function DonateWindowView:OnGoldPlus()
	self.donate_gold = self.donate_gold + 10
	if(self.donate_gold > self.gold) then
		self.donate_gold = self.gold
	end
	self.node_list["InputGoldNum"].text.text = self.donate_gold
end

--减少捐献钻石
function DonateWindowView:OnGoldReduce()
	self.donate_gold = self.donate_gold - 10
	if(self.donate_gold < 0) then
		self.donate_gold = 0
	end
	self.node_list["InputGoldNum"].text.text = self.donate_gold
end

--最大捐献钻石
function DonateWindowView:OnGoldMax()
	self.donate_gold = self.gold
	self.node_list["InputGoldNum"].text.text = self.donate_gold
end

--捐献钻石
function DonateWindowView:OnGoldDonate()
	local num = self.donate_gold
	if num > 0 then
		GuildCtrl.Instance:SendAddGuildExpReq(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_GOLD, num, 1, {})
	end
end

-- 点击钻石输入框
function DonateWindowView:OnClickGoldInput()
	local use_gold = GuildData.Instance:GetGongXianMaxGold()
	local max_gold = GuildData.Instance:GetOtherConfig().day_juanxian_gold_limit
	if max_gold - use_gold == 0 then
		return
	end
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.GoldInputEnd, self), nil, self.gold)
end

function DonateWindowView:GoldInputEnd(str)
	local use_gold = GuildData.Instance:GetGongXianMaxGold()
	local max_gold = GuildData.Instance:GetOtherConfig().day_juanxian_gold_limit
	local num = tonumber(str)
	if(num < 0) then
		num = 0
	elseif(num > self.gold and self.gold <= max_gold - use_gold) then
		num = self.gold
	elseif num > max_gold - use_gold and self.gold >= max_gold- use_gold  then
		num = max_gold - use_gold
	end
	self.donate_gold = num
	self.node_list["InputGoldNum"].text.text = num
end

-- 点击令牌输入框
function DonateWindowView:OnClickCardInput()
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.CardInputEnd, self), nil, self.card)
end

function DonateWindowView:CheckLevelUp()
	if self.show_index == TabIndex.guild_altar then
		self.altar_view:CheckLevelUp()
	end
end

function DonateWindowView:CardInputEnd(str)
	local num = tonumber(str)
	if(num < 0) then
		num = 0
	elseif(num > self.card) then
		num = self.card
	end
	self.donate_card = num
	self.node_list["InputCardNum"].text.text = num
end



