TipsMissionCompletedView = TipsMissionCompletedView or BaseClass(BaseView)

function TipsMissionCompletedView:__init()
	self.ui_config = {{"uis/views/tips/missioncompletedtips_prefab", "MissionCompletedTips"}}
	self.again_call_back = nil
	self.close_call_back = nil
	self.item_info_list = {}
	self.need_money = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.item_list ={}
	self.reset_list = {}
end

function TipsMissionCompletedView:__delete()

end
function TipsMissionCompletedView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k,v in pairs(self.reset_list) do
		v:DeleteMe()
	end
	self.reset_list = {}
end

function TipsMissionCompletedView:LoadCallBack()
	self.node_list["again_btn"].button:AddClickListener(BindTool.Bind(self.AgainClick, self))
	self.node_list["BtnSureClick"].button:AddClickListener(BindTool.Bind(self.SureClick, self))
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New() 
		self.item_list[i]:SetInstanceParent(self.node_list["item_"..i])
	end

	for i = 1,4 do
		self.reset_list[i] = ItemCell.New() 
		self.reset_list[i]:SetInstanceParent(self.node_list["ResetRewardItem" .. i])
	end
end

function TipsMissionCompletedView:OpenCallBack()
	-- 平常奖励
	for k = 1, 3 do
		if self.item_info_list and self.item_info_list[k] then
			self.item_list[k]:SetData(self.item_info_list[k])
			self.node_list["item_" .. k]:SetActive(true)
		end
	end
	-- 重置的奖励	
	local itemId = self.item_info_list[4].item_id
	local re_item_list = ItemData.Instance:GetGiftItemList(itemId)
	if re_item_list and next(re_item_list) then
		-- 礼包奖励
		for k,v in pairs(self.reset_list) do
			if re_item_list[k] then
				v:SetData(re_item_list[k])
				self.node_list["ResetRewardItem" .. k]:SetActive(true)
			end
		end
	else
		-- 非礼包奖励
		self.reset_list[1]:SetData(self.item_info_list[4])
		self.node_list["ResetRewardItem" .. 1]:SetActive(true)
	end

	self.node_list["TxtMoneyText"].text.text = self.need_money
	local move_info = GoPawnData.Instance:GetChessInfo()
	if move_info.move_chess_reset_times >= 2 then
		UI:SetButtonEnabled(self.node_list["again_btn"], false)
	else
		UI:SetButtonEnabled(self.node_list["again_btn"], true)
	end
end

function TipsMissionCompletedView:Init(item_info_list, need_money, again_call_back,close_call_back)
	self.item_info_list = item_info_list
	self.need_money = need_money
	self.again_call_back = again_call_back
	self.close_call_back = close_call_back
end

function TipsMissionCompletedView:CloseCallBack()
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function TipsMissionCompletedView:AgainClick()
	self:Close()
	if self.again_call_back ~= nil then
		self.again_call_back()
	end
end

function TipsMissionCompletedView:SureClick()
	self:Close()
end
 