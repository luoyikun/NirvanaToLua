ShenShouHuanlingView = ShenShouHuanlingView or BaseClass(BaseRender)

function ShenShouHuanlingView:__init(instance, mother_view)
	self.is_cancel = false
	self.is_flush = false
	self.data = ShenShouData.Instance

	self.node_list["BtnDraw"].button:AddClickListener(BindTool.Bind(self.ClickDraw, self))
	self.node_list["BtnFlush"].button:AddClickListener(BindTool.Bind(self.ClickFlush, self))
	self.node_list["ImgGird"].toggle:AddClickListener(BindTool.Bind(self.ClickCancel, self))

	self.cell_list = {}
	for i = 1, GameEnum.SHENSHOU_MAX_RERFESH_ITEM_COUNT do
		self.cell_list[i] = DrawHuanLingItem.New(self.node_list["item" .. i])
	end
end

function ShenShouHuanlingView:__delete()
	self.node_list["SelectEffect"] = nil
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = nil
	self.data = nil
end

function ShenShouHuanlingView:OpenCallBack()
	UI:SetButtonEnabled(self.node_list["BtnDraw"], true)
	self:Flush()
	self:InitData()

end

function ShenShouHuanlingView:CloseCallBack()
	if nil ~= self.rotate_timer then
		GlobalTimerQuest:CancelQuest(self.rotate_timer)
		ShenShouData.Instance:StartFloatingLabel()
	end
end
function ShenShouHuanlingView:FlushTxtIntergral()
	if self.IntergralCallBack ~= nil then 
		self.IntergralCallBack()
	end
end
function ShenShouHuanlingView:SetIntergraCallBack(callback)
	self.IntergralCallBack = callback
end
function ShenShouHuanlingView:OnFlush(param_t)
	local score = self.data:GetHuanLingScore()
	local huanling_draw_limit = self.data:GetHuanLingDrawLimit()
	local huanling_refresh_consume = self.data:GetHuanLingRefreshConsume()
	local huanling_get_draw = self.data:GetHuanLingDrawTime()
	local spend_score = self.data:GetHuanLingConsume(huanling_get_draw)

	--self.node_list["TxtIntegral"].text.text = string.format(Language.ShenShou.JiFen, score)
	self:FlushTxtIntergral()
	self.node_list["TxtNum"].text.text = string.format("%s / %s", huanling_get_draw, huanling_draw_limit)

	self.node_list["TxtRightNum"].text.text = huanling_get_draw < huanling_draw_limit and string.format(Language.ShenShou.SpendScore, huanling_refresh_consume) or Language.ShenShou.FreeFlush
	self.node_list["TxtLeftNum"].text.text = string.format(Language.ShenShou.SpendScore, spend_score)

	if self.is_flush then
	   self:InitData()
	   self.is_flush = false
	end
	if self.is_cancel then
	   self:InitData()
	end
end

function ShenShouHuanlingView:ClickCancel()
	self.is_cancel = not self.is_cancel
end

function ShenShouHuanlingView:ClickFlush()
	if self.data:GetHuanLingRefreshConsume() <= self.data:GetHuanLingScore() then 
		self.need_flush = false
		for k,v in pairs(self.cell_list) do
			self:Paging(k)
		end
	else
		ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_HUANLING_REFRESH)
		self.is_flush = true
		for k,v in pairs(self.cell_list) do
			if v.is_get_end == true then 
				self.node_list["BGGetItem" .. k]:SetActive(true)
			else
				self.node_list["BGGetItem" .. k]:SetActive(false)
			end
		end
	end
	
end
function ShenShouHuanlingView:NeedFlush(bool)
	if bool ~= self.need_flush then 
		ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_HUANLING_REFRESH)
		self.is_flush = true
		for k,v in pairs(self.cell_list) do
			if v.is_get_end == true then 
				self.node_list["BGGetItem" .. k]:SetActive(true)
			else
				self.node_list["BGGetItem" .. k]:SetActive(false)
			end
		end
	end
end
function ShenShouHuanlingView:Paging(i)
	local target_scale = Vector3(0, 1, 1)
	local target_scale2 = Vector3(1, 1, 1)
	self.tweener1 = self.node_list["item" .. i].rect:DOScale(target_scale, 0.5)
	local func2 = function()
		self.tweener2 = self.node_list["item" .. i].rect:DOScale(target_scale2, 0.5)
		self:NeedFlush(true)
		self.need_flush = true
	end
	self.tweener1:OnComplete(func2)

end
function ShenShouHuanlingView:ClickDraw()
	for k,v in pairs(self.cell_list) do
		if v.is_get_end == true then 
			self.node_list["BGGetItem" .. k]:SetActive(true)
		else
			self.node_list["BGGetItem" .. k]:SetActive(false)
		end
	end
	local huanling_draw_limit = self.data:GetHuanLingDrawLimit()
	local huanling_get_draw = self.data:GetHuanLingDrawTime()
	if huanling_get_draw < huanling_draw_limit then
	   ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_HUANLING_DRAW)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.FlushReward)
	end
end

function ShenShouHuanlingView:InitData()
	ShenShouData.Instance:StartFloatingLabel()
	self:SetDataView()
	UI:SetButtonEnabled(self.node_list["BtnDraw"], true)

end

function ShenShouHuanlingView:SetDataView()
	local data = self.data:GetHuanLingList()
	for k, v in pairs(self.cell_list) do
		v:SetData(data[k])
	end
	for k,v in pairs(self.cell_list) do
		if v.is_get_end == true and k ~= self.now_index then 
			self.node_list["BGGetItem" .. k]:SetActive(true)
		else
			self.node_list["BGGetItem" .. k]:SetActive(false)
		end
	end
end

function ShenShouHuanlingView:FlushAnimation()
   self.node_list["SelectEffect"]:SetActive(true)
	local index = self.now_index or 1
	local speed_index = index
	local result_index = self.data:GetResultIndex()
	
	local item_cfg = ItemData.Instance:GetItemConfig(self.cell_list[result_index].item_cell.data.item_id)
	local item_name =  ItemData.Instance:GetItemName(self.cell_list[result_index].item_cell.data.item_id)
	item_name = ToColorStr(item_name, SOUL_NAME_COLOR[item_cfg.color])
	if self.is_cancel then
		if nil == self.cell_list[result_index] then return end
		local posx = self.cell_list[result_index].root_node.transform.position.x
		local posy = self.cell_list[result_index].root_node.transform.position.y
		local posz = self.cell_list[result_index].root_node.transform.position.z
	   	self.node_list["SelectEffect"].transform.position = Vector3(posx, posy, posz)
		self.now_index = result_index
		if nil ~= self.cell_bg_index then 
			self.cell_list[self.cell_bg_index]:ShowHighLightBG(false)
		end
		self.cell_bg_index = result_index
		self.cell_list[result_index]:ShowHighLightBG(true)
		if nil ~= self.rotate_timer then
			GlobalTimerQuest:CancelQuest(self.rotate_timer)
		end
		self:InitData()
		TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.ShenShou.GetEquip,item_name) .. " X1")
		for k,v in pairs(self.cell_list) do
			if v.is_get_end == true and k ~= result_index then 
				self.node_list["BGGetItem" .. k]:SetActive(true)
			else
				self.node_list["BGGetItem" .. k]:SetActive(false)
			end
		end
		return
	else
		local loop_num = GameMath.Rand(2, 3)
		self.move_motion = function ()
			local quest = self.rotate_timer
			local quest_list = GlobalTimerQuest:GetRunQuest(quest)
			if nil == quest or nil == quest_list then return end
			if index == (loop_num * 14) + result_index then
				if nil == self.cell_list[result_index] then return end
				local posx = self.cell_list[result_index].root_node.transform.position.x
				local posy = self.cell_list[result_index].root_node.transform.position.y
				local posz = self.cell_list[result_index].root_node.transform.position.z
			   	self.node_list["SelectEffect"].transform.position = Vector3(posx, posy, posz)
				self.now_index = result_index
			  	if nil ~= self.cell_bg_index then 
					self.cell_list[self.cell_bg_index]:ShowHighLightBG(false)
				end
				self.cell_bg_index = result_index
				self.cell_list[result_index]:ShowHighLightBG(true)
				if nil ~= self.rotate_timer then
					GlobalTimerQuest:CancelQuest(self.rotate_timer)
				end
				 self:InitData()
				 self.cell_list[result_index].is_get_end = true
				 TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.ShenShou.GetEquip,item_name) .. " X1")
				for k,v in pairs(self.cell_list) do
					if v.is_get_end == true and k ~= result_index then 
						self.node_list["BGGetItem" .. k]:SetActive(true)
					else
						self.node_list["BGGetItem" .. k]:SetActive(false)
					end
				end
				return
			else
				UI:SetButtonEnabled(self.node_list["BtnDraw"], false)
				local read_index = ((index + 1) == 14 and 14) or ((index + 1) % 14 == 0 and 14) or ((index + 1) % 14)
				local posx = self.cell_list[read_index].root_node.transform.position.x
				local posy = self.cell_list[read_index].root_node.transform.position.y
				local posz = self.cell_list[read_index].root_node.transform.position.z
			  	self.node_list["SelectEffect"].transform.position = Vector3(posx, posy, posz)
			  	if nil ~= self.cell_bg_index then 
					self.cell_list[self.cell_bg_index]:ShowHighLightBG(false)
				end
				self.cell_bg_index = read_index
				self.cell_list[read_index]:ShowHighLightBG(true)
				-- 速度限制
				if index < speed_index + 3 then
					quest_list[2] = 0.25 -- 0.1 0.25 0.1 0.08
				elseif speed_index + 3 <= index and index <= speed_index + 6 then
					quest_list[2] = 0.1
				elseif index > ((loop_num * 14) + result_index) - 5 then
					quest_list[2] = 0.2
					if index > ((loop_num * 14) + result_index) - 2 then
						quest_list[2] = 0.3
					end
				else
					quest_list[2] = 0.08
				end
				index = index + 1
			end
		end

		if nil ~= self.rotate_timer then
			GlobalTimerQuest:CancelQuest(self.rotate_timer)
		end
		self.rotate_timer = GlobalTimerQuest:AddRunQuest(self.move_motion, 0.1)
	end
end

------------------------------DrawHuanLingItem-------------------------------
DrawHuanLingItem = DrawHuanLingItem or BaseClass(BaseRender)

function DrawHuanLingItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
end

function DrawHuanLingItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end


function DrawHuanLingItem:SetData(data)
	local name = ItemData.Instance:GetItemName(data.item.item_id)
	self.item_cell:SetData(data.item)
	self.node_list["TxtItemName"].text.text = name
	if tonumber(data.draw) == 0 then
		self:ShowGet(false)
		self.is_get_end = false
	else 
		self:ShowGet(true)
		self.is_get_end = true
	end
end

function DrawHuanLingItem:ShowGet(enable)
	self.node_list["ImgReward"]:SetActive(enable)
end

function DrawHuanLingItem:ShowHighLightBG(bool)
	self.node_list["ImageHigh"]:SetActive(bool)
end