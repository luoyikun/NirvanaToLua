local FIX_TIME = 3
local CUR_INDEX = 1
TipsGetEquipView = TipsGetEquipView or BaseClass(BaseView)
function TipsGetEquipView:__init()
	self.ui_config = {{"uis/views/tips/getequiptips_prefab", "GetEquipTips"}}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_async_load = true
	self.cells = {}
end

function TipsGetEquipView:__delete()

end

function TipsGetEquipView:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.close_time then
		GlobalTimerQuest:CancelQuest(self.close_time)
		self.close_time = nil
	end

	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
	
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}

	self.image = nil
end

function TipsGetEquipView:LoadCallBack()
	for i=1,11 do
		self.cells[i] = EquipOpenItem.New(self.node_list["Item" .. i])
	end
	self.image = self.node_list["Image"]

	if self.equip_data_change_fun == nil then
		self.equip_data_change_fun = BindTool.Bind1(self.OnEquipDataChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_change_fun)
	end
	self:OnEquipDataChange()
end

function TipsGetEquipView:SetItemId(item_id, index)
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.close_time then
		GlobalTimerQuest:CancelQuest(self.close_time)
		self.close_time = nil
	end
	self.close_time = GlobalTimerQuest:AddDelayTimer(function()
		self:Close()
	end, 10)	--设置10秒后不管怎么样都关闭界面

	
	self.item_id = item_id
	self.index = index
	
	if self:IsOpen() then
		self:OnEquipDataChange()
	else
		self:Open()
	end
	self:AutoEquip()
	self:Flush()
end

local charge_sequence = nil
local time = 2
function TipsGetEquipView:MoveIcon()
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)

	if item_cfg and self.image then
		if charge_sequence then
			charge_sequence:Kill()
		end
		charge_sequence = DG.Tweening.DOTween.Sequence()
		local tween = nil
		local tween2 = nil
		local bundle, asset = ResPath.GetItemIcon(item_cfg.drop_icon)
	 	self.image.image:LoadSprite(bundle, asset, function()
	 		self.image:SetActive(true)
	 		local equip_index = EquipData.Instance:GetNewEquipIndex(self.item_id) or 1
	 		tween = self.image.rect:DOAnchorPos(self.cells[equip_index].root_node.transform.localPosition, time)
	 		tween2 = self.image.rect:DOSizeDelta(Vector2(40, 40), 0.1)
	 		charge_sequence:Append(tween)
	 		charge_sequence:Insert(2, tween2)
	 		charge_sequence:SetEase(DG.Tweening.Ease.OutCubic)
			charge_sequence:OnComplete(function()
				self.image:SetActive(false)
				self.cells[CUR_INDEX]:SetItemImageGrey(true)
				local delay_time = FIX_TIME + Status.NowTime
				if self.timer_quest then
					GlobalTimerQuest:CancelQuest(self.timer_quest)
				end
				self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
					if delay_time <= Status.NowTime then
						self:Close()
					end
				end, 0.5)
			end)
	 	end)
	else
		self:Close()
	end
	
end

function TipsGetEquipView:OnFlush()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self:MoveIcon()
	end, 0.5)
end

function TipsGetEquipView:AutoEquip()
	if self.image then
		self.image:SetActive(false)
		self.image.rect.anchoredPosition = Vector3(-500, -100, 0)
	end
	local equip_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if equip_cfg then
		local equip_index = EquipData.Instance:GetEquipIndexByType(equip_cfg.sub_type)
		if equip_index > -1 then
			PackageCtrl.Instance:SendUseItem(self.index, 1, equip_index, equip_cfg.need_gold)
		end
	end
end

function TipsGetEquipView:OnEquipDataChange(item_id, index, reason)
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

function TipsGetEquipView:SetData(equiplist)
	for k, v in pairs(self.cells) do
		if equiplist[k - 1] and equiplist[k - 1].item_id then
			v:SetData(k, equiplist[k - 1].item_id, true, self.item_id)
		else
			local item_id = EquipData.Instance:GetDefaultIcon(k - 1)
			v:SetData(k, item_id, false)
		end
	end
end

-------------------------------------------------------------------------------
EquipOpenItem = EquipOpenItem or BaseClass(BaseRender)
function EquipOpenItem:__init()
	self.frame = self.node_list["Frame"]
	self.select = self.node_list["Select"]
	self.no_activate = self.node_list["NoActivate"]
	self.line = self.node_list["Line"]
	self.image = self.node_list["Image"]
end

function EquipOpenItem:__delete()
	self.frame = nil
	self.select = nil
	self.no_activate = nil
	self.line = nil
	self.image = nil
end

function EquipOpenItem:OnFlush()
	if self.data then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data)
		if item_cfg then
			self.line:SetActive(false)
			self.select:SetActive(false)
			local bundle, asset = ResPath.GetItemIcon(item_cfg.drop_icon)
	 		self.image.image:LoadSprite(bundle, asset)
			if self.is_activate then
				UI:SetGraphicGrey(self.no_activate, false)
				local is_cur_equip = false
				if self.data == self.cur_item_id then
					CUR_INDEX = self.index
					is_cur_equip = true
					self:SetItemImageGrey(false)
				end
				UI:SetGraphicGrey(self.image, is_cur_equip)
				self.frame:SetActive(true)
			else
				UI:SetGraphicGrey(self.image, true)
				UI:SetGraphicGrey(self.no_activate, true)
			end
		end	
	end
end

function EquipOpenItem:SetData(index, data, is_activate, cur_item_id)
	self.index = index
	self.data = data
	self.is_activate = is_activate
	self.cur_item_id = cur_item_id

	self:Flush()
end

function EquipOpenItem:SetItemImageGrey(bool)
	if self.image then
		self.line:SetActive(bool)
		self.select:SetActive(bool)
		UI:SetGraphicGrey(self.image, not bool)
		local item_animator = self.root_node:GetComponent(typeof(UnityEngine.Animator))
		if item_animator then
			item_animator.enabled = bool
		end
	end
end