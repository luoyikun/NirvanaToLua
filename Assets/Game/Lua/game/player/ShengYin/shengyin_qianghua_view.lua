ShengYinStrength = ShengYinStrength or BaseClass(BaseView)

function ShengYinStrength:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab","BaseSecondPanel"},
		{"uis/views/player/shengyin_prefab", "ShengYinQiangHua"}
	}
	self.is_any_click_close = false
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.equip_cell_list = {}
	self.eff_index = 0
end

function ShengYinStrength:__delete()
	-- if nil ~= self.ProgressBar then
	-- 	self.ProgressBar:DeleteMe()
	-- 	self.ProgressBar = nil
	-- end
end

function ShengYinStrength:OpenQiangHua()
	self.seal_list = PlayerData.Instance:GetSoulStrengthlist()
	if next(self.seal_list) then 
		self:Open()
		self:Flush()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Player.NoHaveShengYin)
	end
end

function ShengYinStrength:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.Player.ShengYinQiangHua
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	local left_list = self.node_list["LeftList"].list_simple_delegate
	left_list.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	left_list.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.item_middle = ItemCell.New()
	self.item_middle:SetInstanceParent(self.node_list["ItemPos"])
	self.node_list["ButtonOneKey"].button:AddClickListener(BindTool.Bind(self.ClickOneKey , self))
	self.node_list["ButtonUpLevel"].button:AddClickListener(BindTool.Bind(self.ClickUpLevel , self))
	self.node_list["TxtUpLevel"].text.text = Language.Common.Strengthen
	self.node_list["TxtOneKey"].text.text = Language.Player.OneKeyUpgrade
	self.node_list["ManJi"]:SetActive(false)
	self.node_list["AttrList"]:SetActive(false)
	-- self.ProgressBar = ProgressBar.New(self.node_list["ProgressBG"])
	-- self.node_list["SliderTxt"].text.text = 0 .." / ".. 100
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ScoreValue"])
end
function ShengYinStrength:ClickMiddle(data)
	local close_callback = function ()
		self.item_middle:SetHighLight(false)
		self.item_middle:ShowHighLight(false)
	end
	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SHENGYIN_NOT_USE, nil, close_callback)
end
function ShengYinStrength:OpenCallBack()
	self.last_index = 1
	self.index = 1
	self.start_on_key = false	--开始一键升级
	if self.seal_list == nil then 
		self.seal_list = PlayerData.Instance:GetSoulStrengthlist()
	end
	self.item_data = self.seal_list[self.index]
end

function ShengYinStrength:ClickOneKey()
	if self.start_on_key == false then 
		-- local need_score, max_level = PlayerData.Instance:GetSealSocrdBySealItemData(self.item_data) 
		local item_data, need_score = PlayerData.Instance:GetMinSealItem()
		local seal_base_info = PlayerData.Instance:GetSealBaseInfo() or {}
		local hun_score = seal_base_info.hun_score or 0 

		if item_data == nil then 
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.YiManJi)
			self:StopOneKeyUpstar()
		else
			if hun_score >= need_score then
				self:StartOneKeyUpstar()
			else
				-- 提示不足
				TipsCtrl.Instance:ShowSystemMsg(Language.Player.ShengYinJingHuaBuZhu)
				self:StopOneKeyUpstar()
			end
		end
	else	
		self:StopOneKeyUpstar()
	end
end

--开始一键升级
function ShengYinStrength:StartOneKeyUpstar()	
	-- if self.item_data == nil then  
	-- 	return 
	-- end
	-- local need_score, max_level = PlayerData.Instance:GetSealSocrdBySealItemData(self.item_data) 
	-- if self.item_data.level >= max_level then 
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Common.YiManJi)
	-- 	self:StopOneKeyUpstar()
	-- 	return
	-- end
	local need_score = 0
	self.item_data, need_score, self.eff_index = PlayerData.Instance:GetMinSealItem()
	if self.item_data == nil then
		self:StopOneKeyUpstar()
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.YiManJi)
		self.eff_index = 0
		return
	end
	local time = 0.2 --延迟0.5秒
	if nil ~= self.seal_one_key_upstar then
		GlobalTimerQuest:CancelQuest(self.seal_one_key_upstar)
		self.seal_one_key_upstar = nil
	end

	local seal_base_info = PlayerData.Instance:GetSealBaseInfo() or {}
	local hun_score = seal_base_info.hun_score or 0 
	if  hun_score >= need_score then 
		self.node_list["TxtOneKey"].text.text = Language.Player.StopStrength
		self.start_on_key = true
		--self.btn_one_key_upstar:setTitleText(Language.Player.StopUpgrade)
		PlayerCtrl.Instance:SendUseShengYin(SEAL_OPERA_TYPE.SEAL_OPERA_TYPE_UPLEVLE, self.item_data.slot_index)
	else
		-- 提示不足
		TipsCtrl.Instance:ShowSystemMsg(Language.Player.ShengYinJingHuaBuZhu)
		self:StopOneKeyUpstar()
		self.eff_index = 0
		return
	end

	self.seal_one_key_upstar = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.StartOneKeyUpstar, self), time)
end
--停止一键升级
function ShengYinStrength:StopOneKeyUpstar()
	
	if nil ~= self.seal_one_key_upstar then
		GlobalTimerQuest:CancelQuest(self.seal_one_key_upstar)
		self.seal_one_key_upstar = nil
	end
	self.start_on_key = false
	if self.node_list then
		self.node_list["TxtOneKey"].text.text = Language.Player.OneKeyUpgrade
	end
end

function ShengYinStrength:ClickUpLevel()
	if self.item_data == nil then  
		return 
	end
	local need_score, max_level = PlayerData.Instance:GetSealSocrdBySealItemData(self.item_data) 
	if self.item_data.level >= max_level then 
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.YiManJi)
		self:StopOneKeyUpstar()
		return
	end
	self.eff_index = self.index
	local seal_base_info = PlayerData.Instance:GetSealBaseInfo() or {}
	local hun_score = seal_base_info.hun_score or 0 
	if hun_score >= need_score then
		if self.item_data ~= nil then 
			PlayerCtrl.Instance:SendUseShengYin(SEAL_OPERA_TYPE.SEAL_OPERA_TYPE_UPLEVLE, self.item_data.slot_index)
		end
	else
		-- 提示不足
		TipsCtrl.Instance:ShowSystemMsg(Language.Player.ShengYinJingHuaBuZhu)
		self.eff_index = 0
	end
	
end

function ShengYinStrength:CloseWindow()
	self:StopOneKeyUpstar()
	self:Close()
end

function ShengYinStrength:ReleaseCallBack()
	self.index = 1
	if self.item_middle then 
		self.item_middle:DeleteMe()
		self.item_middle = nil
	end
	for k, v in pairs(self.equip_cell_list) do
		v:DeleteMe()
	end
	-- if nil ~= self.ProgressBar then
	-- 	self.ProgressBar:DeleteMe()
	-- 	self.ProgressBar = nil
	-- end
	self.equip_cell_list = {}
	self.fight_text = nil
end

function ShengYinStrength:OnFlush()
	self:FlushLeftList()
	self:FlushMiddleInfo()
end

function ShengYinStrength:GetNumberOfCells()
	if self.seal_list == nil then 
		self.seal_list = PlayerData.Instance:GetSoulStrengthlist()
	end
	return #self.seal_list
end

function ShengYinStrength:RefreshView(cell, data_index)
	data_index = data_index + 1
	local equip_cell = self.equip_cell_list[cell]
	if equip_cell == nil then
		equip_cell = ShengYinQHCell.New(cell.gameObject)
		self.equip_cell_list[cell] = equip_cell
		self.equip_cell_list[cell].root_node.rect.sizeDelta = Vector2(240, 106)
	end
	equip_cell:SetData(self.seal_list[data_index])
	equip_cell:SetIndex(data_index)
	if data_index == self.index then 
		equip_cell:FlushHighImg(true)
		self.equip_cell_list[cell].ishigh = true
	else
		equip_cell:FlushHighImg(false)
		self.equip_cell_list[cell].ishigh = false
	end
	if data_index == self.eff_index then
		equip_cell:ShowEffect()
		self.eff_index = 0
	-- else
		-- equip_cell:CloseEffect()
	end
	equip_cell:SetClickCallBack(BindTool.Bind(self.ShengYinItemOnClick, self))
	
end

function ShengYinStrength:ShengYinItemOnClick(equip_cell)
	self.index = equip_cell:GetIndex()
	self.item_data = equip_cell:GetData()
	if self.index ~= self.last_index then
		self.last_index = self.index
		-- self:StopOneKeyUpstar()
	end
	self.node_list["LeftList"].scroller:RefreshActiveCellViews()
	self:FlushMiddleInfo()
end

function ShengYinStrength:FlushLeftList()
	self.seal_list = PlayerData.Instance:GetSoulStrengthlist()
	self.item_data = self.seal_list[self.index]
	--self.node_list["LeftList"].scroller:ReloadData(0)								--	重新加载，跳转
	self.node_list["LeftList"].scroller:RefreshActiveCellViews()					--	刷新，无跳转
	-- self.node_list["LeftList"].scroller:RefreshAndReloadActiveCellViews(true)		--	刷新重新加载，输入第二个参数可以控制跳转
	--self.node_list["LeftList"].scroller:JumpToDataIndex(0)						--	跳转到索引

end

function ShengYinStrength:FlushMiddleInfo()
	if not next(self.seal_list) then return end
	if nil == self.seal_list[self.index] then return end
	local need_score, max_level = PlayerData.Instance:GetSealSocrdBySealItemData(self.seal_list[self.index]) 
	local seal_atrr_data = PlayerData.Instance:GetSoulAttrValueBySlotIndex(self.seal_list[self.index].slot_index)
	local base_info = PlayerData.Instance:GetSealBaseInfo()
	local hun_score = base_info.hun_score or 0
	local hun_score_number = hun_score
	local suit_attr_info_list = PlayerData.Instance:GetTotalAttrKey()
	-- hun_score = CommonDataManager.ConverMoney(hun_score)
	self.item_middle:SetData(self.seal_list[self.index])
	self.item_middle:ListenClick(BindTool.Bind(self.ClickMiddle, self, self.seal_list[self.index]))
	-- if nil ~= self.seal_list[self.index].order then
	-- 	self.item_middle:SetShengYinGrade(self.seal_list[self.index].order)
	-- end
	local remind = PlayerData.Instance:GetSealStrengthRemind()
	-- self.node_list["OneKeyRemind"].gameObject:SetActive(remind > 0)
	local cur_level = self.seal_list[self.index].level 
	local totle_attr_list = {}
	if cur_level < max_level then 
		self.node_list["AttrList"]:SetActive(true)
		self.node_list["ManJi"]:SetActive(false)
		self.node_list["LevelTxt"].text.text = string.format("Lv.%s", cur_level)
		self.node_list["TxtXiaoHao"]:SetActive(true)
		local hun_score_str = hun_score
		if hun_score >= need_score then
			self.node_list["BtnUpRemind"]:SetActive(true)
			-- self.node_list["OneKeyRemind"]:SetActive(true)
			hun_score_str = ToColorStr(hun_score_str, TEXT_COLOR.GREEN_4)
		else
			self.node_list["BtnUpRemind"]:SetActive(false)
			-- self.node_list["OneKeyRemind"]:SetActive(false)
			hun_score_str = ToColorStr(hun_score_str, TEXT_COLOR.RED_1)
		end
		self.node_list["TxtXiaoHao"].text.text = string.format(Language.Player.HunXiaoHaoNum , hun_score_str .. ToColorStr(" / " .. need_score, TEXT_COLOR.GREEN_4))
		self.node_list["TxTCurLV"].text.text = string.format(Language.Player.ShengYinAddNum , ToColorStr(cur_level, TEXT_COLOR.WHITE))
		self.node_list["TxTNextLV"].text.text = string.format(Language.Player.ShengYinAddNum , ToColorStr(cur_level + 1), TEXT_COLOR.WHITE)

		-- local upstar_percent = math.floor(cur_level / max_level * 100)
		-- self.ProgressBar:SetValue(upstar_percent * 0.01)
		-- self.node_list["SliderTxt"].text.text = cur_level .. " / " ..max_level

		local index = 1
		for i, v in pairs(suit_attr_info_list) do 
			self.node_list["CurInfo" .. index].text.text = ""
			self.node_list["NextInfo" .. index].text.text = ""
			self.node_list["Arrow" .. index]:SetActive(false)
			if seal_atrr_data[v] ~= 0 and seal_atrr_data[v] ~= nil then 
				totle_attr_list[v] = seal_atrr_data[v] * cur_level
				local str = ToColorStr("+".. seal_atrr_data[v] * (cur_level), TEXT_COLOR.WHITE)
				local str2 = ToColorStr("+".. seal_atrr_data[v] * (cur_level + 1), TEXT_COLOR.WHITE)
				self.node_list["CurInfo" .. index].text.text = Language.Player.AttrNameShengYin[v]..str
				self.node_list["NextInfo" .. index].text.text = Language.Player.AttrNameShengYin[v]..str2
				self.node_list["Arrow" .. index]:SetActive(true)
				index = index + 1 
			end
			if index > 2 then 
				self:SetFightTxt(totle_attr_list)
				return 
			end
		end
	else
		-- self.ProgressBar:SetValue(1.0)
		-- self.node_list["SliderTxt"].text.text = cur_level .." / "..max_level
		self.node_list["LevelTxt"].text.text = string.format("Lv.%s" , cur_level)
		self.node_list["TxtXiaoHao"]:SetActive(false)
		self.node_list["BtnUpRemind"]:SetActive(false)
		-- self.node_list["OneKeyRemind"]:SetActive(false)
		self.node_list["AttrList"]:SetActive(false)
		self.node_list["ManJi"]:SetActive(true)
		local index = 1
		for i, v in pairs(suit_attr_info_list) do 
			if seal_atrr_data[v] ~= 0 and seal_atrr_data[v] ~= nil then 
				totle_attr_list[v] = seal_atrr_data[v] * max_level
				self.node_list["manji" .. index].text.text = Language.Player.AttrNameShengYin[v].."+".. seal_atrr_data[v] * (cur_level)
				index = index + 1 
			end
			if index > 2 then
				self:SetFightTxt(totle_attr_list)
				return 
			end
		end	
	end
	self:SetFightTxt(totle_attr_list)
end

function ShengYinStrength:SetFightTxt(totle_attr_list)
	local scord = CommonDataManager.GetCapabilityCalculation(totle_attr_list)
	--total_scord = total_scord + scord
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = scord
	end
end

ShengYinQHCell = ShengYinQHCell or BaseClass(BaseCell)

function ShengYinQHCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.node_list["ButtonItem"].button:AddClickListener(BindTool.Bind(self.OnClick , self))
end

function ShengYinQHCell:__delete()
	if self.item_cell then 
		self.item_cell:DeleteMe()
		self.item_cell = nil 
	end
end

function ShengYinQHCell:ClickMiddle(data)
	local close_callback = function ()
		self.item_cell:SetHighLight(false)
		self.item_cell:ShowHighLight(false)
	end
	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SHENGYIN_NOT_USE, nil, close_callback)
end

function ShengYinQHCell:FlushHighImg(boo)
	self.node_list["HighImg"]:SetActive(boo)
	local str, str1 = self:GetNameAndAttr()
	self.node_list["Name"].text.text = boo and ToColorStr(str, "#000000") or ToColorStr(str, "#FFFFFF")
	self.node_list["Attr"].text.text = boo and ToColorStr(str1, "#000000") or ToColorStr(str1, "#FFFFFF")
end

function ShengYinQHCell:OnFlush()
	if self.data == nil then return end	
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local item_data = DeepCopy(self.data)
	item_data.color = item_cfg.color
	self.item_cell:SetData(item_data)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickMiddle, self, item_data))
	-- if nil ~= self.data.order then 
	-- 	self.item_cell:SetShengYinGrade(self.data.order) 
	-- end
	local base_info = PlayerData.Instance:GetSealBaseInfo()
	local hun_score = base_info.hun_score or 0

	local need_score,max_level = PlayerData.Instance:GetSealSocrdBySealItemData(self.data) 
	if hun_score > need_score and self.data.level then 
		if max_level > self.data.level then 
			self.node_list["Remind"]:SetActive(true)
		else
			self.node_list["Remind"]:SetActive(false)
		end
	else
		self.node_list["Remind"]:SetActive(false)
	end
	-- self.node_list["Name"].text.text = ToColorStr(item_cfg.name , ITEM_TIP_COLOR[item_data.color])
	-- self.node_list["Attr"].text.text = ToColorStr(self.data.level..Language.Player.Ji , ITEM_TIP_COLOR[item_data.color])
end

function ShengYinQHCell:GetNameAndAttr()
	if self.data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local  str, str1 = item_cfg.name, self.data.level..Language.Player.Ji
	return item_cfg.name, self.data.level..Language.Player.Ji
end

function ShengYinQHCell:ShowEffect()
	-- self.node_list["Effect"].gameObject:SetActive(true)
	local async_loader = AllocAsyncLoader(self, "effect")
	local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_baodian")
	async_loader:Load(bundle_name, asset_name, 
		function (obj)
			if not IsNil(obj) then
				local transform = obj.transform
				transform:SetParent(self.node_list["Effect"].transform, false)

				GlobalTimerQuest:AddDelayTimer(function()
					ResMgr:Destroy(obj)
					-- ViewManager.Instance:Close(ViewName.FlowerReMindView)
				end, 1)
			end
		end)
end

-- function ShengYinQHCell:CloseEffect()
-- 	self.node_list["Effect"].gameObject:SetActive(false)
-- end