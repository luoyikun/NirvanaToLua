ShengYinAttrTip = ShengYinAttrTip or BaseClass(BaseView)

function ShengYinAttrTip:__init()
	self.ui_config = {
		{"uis/views/player/shengyin_prefab", "TotleAttr"}
	}
	self.is_any_click_close = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.attr_text_list = {}
end

function ShengYinAttrTip:__delete()
	
end

function ShengYinAttrTip:LoadCallBack()
	self.all_attr = self.node_list["AllAttr"].list_simple_delegate
	self.all_attr.NumberOfCellsDel = BindTool.Bind(self.GetAllNumberOfCells, self)
	self.all_attr.CellRefreshDel = BindTool.Bind(self.RefreshAllView, self)
	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["ScoreValue1"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["ScoreValue2"])
end

function ShengYinAttrTip:OnClickClose()
	self:Close()
end

function ShengYinAttrTip:OpenCallBack()
	self.node_list["AllAttr"].scroller:ReloadData(0)
	local attr_type = PlayerData.Instance:GetSelectAttrView()
	if attr_type == 1 then 
		self.node_list["TxtTitle"].text.text = Language.Player.AtrrTip1
		self.node_list["AllAttr"]:SetActive(true)
		self.node_list["AddAttr"]:SetActive(false)
		self.node_list["ContentLeft"]:SetActive(false)
		self.node_list["ContentNext"]:SetActive(true)
		self.node_list["Arrow"]:SetActive(false)
		self.node_list["NextMuBiaoQH"]:SetActive(false)
		self.node_list["BG"].rect.sizeDelta = Vector2(304, 400) 
	elseif attr_type == 2 then
		self.node_list["TxtTitle"].text.text = Language.Player.AtrrTip2
		self.node_list["AllAttr"]:SetActive(false)
		self.node_list["AddAttr"]:SetActive(true)
	end
	self:Flush()
end

function ShengYinAttrTip:ReleaseCallBack()
	for _,v in pairs(self.attr_text_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.attr_text_list = {}
	self.all_attr = nil
	self.fight_text1 = nil
	self.fight_text2 = nil
end
------- 没有数据测试不了
function ShengYinAttrTip:GetAllNumberOfCells()
	local attr_type = PlayerData.Instance:GetSelectAttrView()
	
	if attr_type == 1 then 
		local attr_list =  PlayerData.Instance:GetSealTotalAttr()
		return #attr_list
	else
		return 0
	end
end

function ShengYinAttrTip:RefreshAllView(cell, data_index)
	local attr_list =  PlayerData.Instance:GetSealTotalAttr()
	data_index = data_index + 1
	local attr_text_cell = self.attr_text_list[cell]
	equip_cell = self.attr_text_list[cell]
	if equip_cell == nil then
		equip_cell = AllAttr.New(cell.gameObject)
		self.attr_text_list[cell] = equip_cell
	end
	equip_cell:SetData(attr_list[data_index])

end
--ToColorStr(has_num, COLOR.RED)
function ShengYinAttrTip:OnFlush()
	local attr_type = PlayerData.Instance:GetSelectAttrView()
	if attr_type == 2 then
		local cur_qh_level,cur_level_cfg = PlayerData.Instance:GetCurTotalLevelCfg()
		local max_level,next_level_cfg = PlayerData.Instance:GetNextTotalLevelCfg()
		local atrr_key_list = PlayerData.Instance:GetTotalAttrKey()
		-- local color = COLOR.ORANGE
		-- self.lbl_cur_qh_level:setColor(COLOR.PURPLE)
		-- self.lbl_cur_lj_level:setColor(color)
		-- self.lbl_next_target:setColor(color)
		-- self.lbl_next_lj_level:setColor(color)
		if cur_qh_level >= max_level then 
			--self.layout_next_attr_add:setVisible(false)
			self.node_list["BG"].rect.sizeDelta = Vector2(304, 400) 
			self.node_list["ContentLeft"]:SetActive(true)
			self.node_list["ContentNext"]:SetActive(false)
			self.node_list["Arrow"]:SetActive(false)
			-- self.node_list["CurLeiJiQH"]:SetActive(true)
			self.node_list["CurList"]:SetActive(true)
			-- self.node_list["CurLeiJiQH"].text.text = string.format(Language.Player.SealLevelText,cur_level_cfg.level)
			self.node_list["CurQH"].text.text = string.format(Language.Player.CurQHLevelText,cur_qh_level)	--Language.Common.YiManJi
			for i,v in pairs(atrr_key_list) do 
				if cur_level_cfg[v] ~= nil and cur_level_cfg[v] ~= 0 then 
					local attri_text = string.format (Language.Player.SuitAtrrTipAll,Language.Player.AttrNameShengYin[v],"#28f328",cur_level_cfg[v])
					self.node_list["Cur"..v].text.text = attri_text
				end
			end
			local attribute = CommonDataManager.GetAttributteByClass(cur_level_cfg)
			local scord = CommonDataManager.GetCapability(attribute)
			if self.fight_text1 and self.fight_text1.text then
				self.fight_text1.text.text = scord
			end
		elseif cur_qh_level < cur_level_cfg.level then 
			-----------------------------下级强化等级--------------------------------------
			self.node_list["BG"].rect.sizeDelta = Vector2(304, 400) 
			self.node_list["ContentLeft"]:SetActive(false)
			self.node_list["Arrow"]:SetActive(false)
			-- self.node_list["CurLeiJiQH"]:SetActive(false)
			self.node_list["CurList"]:SetActive(false)
			self.node_list["CurQH"].text.text = string.format(Language.Player.CurQHLevelText,cur_qh_level)
			self.node_list["NextMuBiaoQH"].text.text = Language.Player.NextTarget
			self.node_list["NextMuBiaoQH"]:SetActive(true)
			self.node_list["NextLeiJiQH"].text.text = string.format(Language.Player.SealLevelText, cur_qh_level, cur_level_cfg.level)
			
			for i,v in pairs(atrr_key_list) do 
				if cur_level_cfg[v] ~= nil and cur_level_cfg[v] ~= 0 then 
					local attri_text = string.format(Language.Player.SuitAtrrTipAll,Language.Player.AttrNameShengYin[v],"#28f328",cur_level_cfg[v])
					self.node_list["Next"..v].text.text = attri_text
				end
			end
			local attribute = CommonDataManager.GetAttributteByClass(next_level_cfg)
			local scord = CommonDataManager.GetCapability(attribute)
			if self.fight_text2 and self.fight_text2.text then
				self.fight_text2.text.text = scord
			end
		else
			-----------------------------初始强化等级--------------------------------------
			self.node_list["BG"].rect.sizeDelta = Vector2(608, 400)
			self.node_list["ContentLeft"]:SetActive(true)
			self.node_list["Arrow"]:SetActive(true)
			-- self.node_list["CurLeiJiQH"]:SetActive(true)
			self.node_list["CurList"]:SetActive(true)
			-- self.node_list["CurLeiJiQH"].text.text = string.format(Language.Player.SealLevelText,cur_level_cfg.level)
			self.node_list["CurQH"].text.text = string.format(Language.Player.CurQHLevelText,cur_qh_level)
			for i,v in pairs(atrr_key_list) do 
				if cur_level_cfg[v] ~= nil and cur_level_cfg[v] ~= 0 then 
					local attri_text = string.format (Language.Player.SuitAtrrTipAll,Language.Player.AttrNameShengYin[v],"#28f328",cur_level_cfg[v])
					self.node_list["Cur"..v].text.text = attri_text
				end
			end
			local attribute = CommonDataManager.GetAttributteByClass(cur_level_cfg)
			local scord = CommonDataManager.GetCapability(attribute)
			if self.fight_text1 and self.fight_text1.text then
				self.fight_text1.text.text = scord
			end
			-----------------------------下级强化等级--------------------------------------
			self.node_list["NextMuBiaoQH"].text.text = Language.Player.NextTarget
			self.node_list["NextMuBiaoQH"]:SetActive(true)
			self.node_list["NextLeiJiQH"].text.text = string.format(Language.Player.SealLevelText, cur_qh_level, next_level_cfg.level)
			
			for i,v in pairs(atrr_key_list) do 
				if next_level_cfg[v] ~= nil and next_level_cfg[v] ~= 0 then 
					local attri_text = string.format(Language.Player.SuitAtrrTipAll,Language.Player.AttrNameShengYin[v],"#28f328",next_level_cfg[v])
					self.node_list["Next"..v].text.text = attri_text
				end
			end
			local attribute = CommonDataManager.GetAttributteByClass(next_level_cfg)
			local scord = CommonDataManager.GetCapability(attribute)
			if self.fight_text2 and self.fight_text2.text then
				self.fight_text2.text.text = scord
			end
		end
	end
end
AllAttr = AllAttr or BaseClass(BaseCell)
function AllAttr:__init()
	
end

function AllAttr:__delete()

end


function AllAttr:OnFlush()
	if self.data == nil then return	end
	local attr_key = self.data[1]
	local attr_value = self.data[2]
	local split_attr = Split(attr_key, "_")
	local is_per = split_attr[1] == "per" or split_attr[#split_attr] == "per"
	if is_per then 
		attr_value = attr_value / 100 .. "%"
	end
	local attri_text = string.format (Language.Player.SuitAtrrTipAll,Language.Player.AttrNameShengYin[attr_key],"#28f328","  "..attr_value)
	self.node_list["TxtAttr"].text.text = attri_text
end