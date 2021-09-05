TipsRenameView = TipsRenameView or BaseClass(BaseView)

function TipsRenameView:__init()
	self.ui_config = {{"uis/views/tips/renametip_prefab", "RenamePopupTip"}}
	self.view_layer = UiLayer.Pop

	self.data = nil
	self.name = ""
	self.callback = nil
	self.is_need_pro = false
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsRenameView:__delete()
end

function TipsRenameView:LoadCallBack()

	self.node_list["chat_input"].input_field.onEndEdit:AddListener(BindTool.Bind(self.RenameOnChange, self, true))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.SureBtnOnClick, self))
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.CancelBtnOnClick, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CancelBtnOnClick, self))

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
end

function TipsRenameView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TipsRenameView:OpenCallBack()
	self.node_list["CardNeed"]:SetActive(false)
	self.name = ""
	self.node_list["chat_input"].input_field.text = self.name
	
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	if self.des ~= nil then
		self.node_list["NodeNeedDes"]:SetActive(true)
		self.node_list["TxtNeedDes1"].text.text = self.des
		if self.des_2 ~= nil then
			self.node_list["TxtNeedDes2"].text.text = self.des_2
		end
	else
		self.node_list["NodeNeedDes"]:SetActive(false)
	end
	
	if self.callback then
		self:Flush()
	end
end

function TipsRenameView:CloseCallBack()
	self.item_id = nil
	self.callback = nil
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.des = nil
	self.des_2 = nil
end

function TipsRenameView:RenameOnChange(is_can)
	local text = self.node_list["chat_input"].input_field.text
	self.name = text
end

function TipsRenameView:SureBtnOnClick()
	if ChatFilter.Instance:IsIllegal(self.name, true) or ChatFilter.Instance:IsEmoji(self.name) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.IllegalContent)
		return
	end

	if self.name == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.InputNull)
		return
	end

	if string.utf8len(self.name) > COMMON_CONSTS.GUILD_NAME_MAX then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NameLenLimit)
		return
	end
	
	if self.is_need_pro then
		if ItemData.Instance:GetItemNumInBagById(self.item_id) <= 0 then
			local price_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
			if price_cfg then
				if price_cfg.bind_gold == 0 then
					TipsCtrl.Instance:ShowShopView(self.item_id, 2)
					return
				end
			end
			
			local callback = function(item_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(callback, self.item_id, nil)
			return
		end
	end
	if self.callback ~= nil then
		self.callback(self.name)
		self.callback = nil
	end
	self:Close()
end

function TipsRenameView:CancelBtnOnClick()
	self:Close()
end

function TipsRenameView:SetCallback(callback, is_need_pro)
	self.callback = callback
	self.is_need_pro = is_need_pro or false
end

function TipsRenameView:SetItemId(item_id)
	self.item_id = item_id
end

function TipsRenameView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == self.item_id then
		self:Flush()
	end
end

function TipsRenameView:OnFlush(param_list)
	local data = ItemData.Instance:GetItem(self.item_id) or {item_id = self.item_id}
	self.item_cell:SetData(data)
	for k, v in pairs(param_list) do
		if k == "all" then
			if self.node_list["TxtProName"] ~= nil then
				if v.item_id then self.item_id = v.item_id end
				self.node_list["TxtProName"]:SetActive(self.is_need_pro or nil ~= self.item_id)
				local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
				if v.item_id and v.item_id == 27582 then
					self.node_list["TxtTitle"].text.text = Language.Tips.ZhuiZongLing
					self.callback = function(name)
						--当前场景无法传送
						local scene_type = Scene.Instance:GetSceneType()
						if scene_type ~= SceneType.Common then
							SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
							return
						end
						PlayerCtrl.Instance:SendSeekRoleWhere(name)
					end
					local item_cfg = ItemData.Instance:GetItemConfig(27582)
					local bag_num = ItemData.Instance:GetItemNumInBagById(27582)
					local card_color = bag_num > 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
					local des = item_cfg.name
					local des2 = ToColorStr(bag_num, card_color) .. " / 1"
					self.node_list["NodeNeedDes"]:SetActive(false)
					self.node_list["CardName"].text.text = des
					self.node_list["CardNum"].text.text = des2
					self.node_list["CardNeed"]:SetActive(true)					
				else
					self.node_list["TxtTitle"].text.text = Language.Tips.ChongMingMing
					if self.item_id == PlayerDataReNameItemId.ItemId then
						local bag_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
						local card_color = bag_num > 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
						local des2 = ToColorStr(bag_num, card_color) .. " / 1"
						self.node_list["NodeNeedDes"]:SetActive(false)
						self.node_list["CardName"].text.text = item_cfg.name
						self.node_list["CardNum"].text.text = des2
						self.node_list["CardNeed"]:SetActive(true)
					end
				end
				if item_cfg then
					local bag_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
					local str = string.format("%s:<color=#00FF00> %s</color>", item_cfg.name, bag_num)

					if bag_num < 1 then
						str = string.format("%s:<color=#FF0000> %s</color>", item_cfg.name, bag_num)
					end
					self.node_list["TxtProName"].text.text = string.sub(str, 17, -1 ) .. ToColorStr(" / 1",TEXT_COLOR.GREEN)
				end
			end
		end
	end
	
	self.node_list["PalceholderTxt"].text.text = Language.Player.InputName
	self.node_list["PalceholderTBtn"]:SetActive(true)
end

function TipsRenameView:SetDes(des, des_2)
	self.des = des
	self.des_2 = des_2
end

