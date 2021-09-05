require("game/serveractivity/expense_gift/expense_gift_view")
require("game/serveractivity/expense_gift/expense_gift_data")
ExpenseGiftCtrl = ExpenseGiftCtrl or BaseClass(BaseController)
function ExpenseGiftCtrl:__init()
	if nil ~= ExpenseGiftCtrl.Instance then
		return
	end
	ExpenseGiftCtrl.Instance = self

	self.data = ExpenseGiftData.New()

	self:RegisterAllProtocols()
end

function ExpenseGiftCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	ExpenseGiftCtrl.Instance = nil
end

function ExpenseGiftCtrl:RegisterAllProtocols()
	-- 消费好礼
	self:RegisterProtocol(SCRAConsumGift, "OnSCRAConsumGift")
	self:RegisterProtocol(SCRAConsumGiftRollReward, "OnSCRAConsumGiftRollReward")
	self:RegisterProtocol(SCRAConsumGiftRollRewardTen, "OnSCRAConsumGiftRollRewardTen")
end

function ExpenseGiftCtrl:OnSCRAConsumGift(protocol)
	self.data:SetExpenseNiceGiftInfo(protocol)
	KaifuActivityCtrl.Instance:FlushKaifuView()
	RemindManager.Instance:Fire(RemindName.ExpenseGift)
end

function ExpenseGiftCtrl:OnSCRAConsumGiftRollReward(protocol)
	self.data:SetRollGiftInfo(protocol)
	KaifuActivityCtrl.Instance:ExpenseViewStartRoll()
end

function ExpenseGiftCtrl:OnSCRAConsumGiftRollRewardTen(protocol)
	self.data:SetRollGiftTenInfo(protocol)
	TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_XIAOFEILINGJIANG_MODE_10)
	KaifuActivityCtrl.Instance:ExpenseViewStartTenRoll()
end
