HunYuUpGradeView = HunYuUpGradeView or BaseClass(BaseRender)

function HunYuUpGradeView:__init(instance)
	self.node_list["BtnPromote0"].button:AddClickListener(BindTool.Bind(self.OnClickUpGardeAttackHunYu, self))
	self.node_list["BtnPromote1"].button:AddClickListener(BindTool.Bind(self.OnClickUpGardeDefenseHunYu, self))
	self.node_list["BtnPromote2"].button:AddClickListener(BindTool.Bind(self.OnClickUpGardeLifeHunYu, self))

	self.hunyu_type = {
	lifehunyu = 0,
	attackhunyu = 1,
	defensehunyu = 2
	}

	self.hunyu_max_level = 5
end

function HunYuUpGradeView:__delete()

end

function HunYuUpGradeView:OnFlush()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local hunyu_level_list = spirit_info.hunyu_level_list
	local attackhunyu_level = hunyu_level_list[HUNYU_TYPE.ATTACK_HUNYU]
	local defensehunyu_level = hunyu_level_list[HUNYU_TYPE.DEFENSE_HUNYU]
	local lifehunyu_level = hunyu_level_list[HUNYU_TYPE.LIFE_HUNYU]

	if 0 == attackhunyu_level then
		self.node_list["TxtLV1"].text.text = "LV." .. attackhunyu_level
		self.node_list["TxtCurRate1"].text.text = 0 .. "%"
	end

	for i = HUNYU_TYPE.LIFE_HUNYU, HUNYU_TYPE.DEFENSE_HUNYU do
		-- 物品消耗描述
		local next_hunyu_level = hunyu_level_list[i] + 1
		local hunyu_level = hunyu_level_list[i]
		local hunyu_cfg = SpiritData.Instance:GetHunyuCfg(i, hunyu_level) or {}
		local hunyu_next_cfg = SpiritData.Instance:GetHunyuCfg(i, next_hunyu_level) and SpiritData.Instance:GetHunyuCfg(i, next_hunyu_level) or SpiritData.Instance:GetHunyuCfg(i, hunyu_level)
		local item_id = hunyu_next_cfg.stuff_id or 0
		local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
		local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id)
		local cost_item_num = hunyu_next_cfg.stuff_num
		if SpiritData.Instance:GetHunyuMaxLevel() == hunyu_level then
			self.node_list["Txtmaxlevel" .. i]:SetActive(true)
			self.node_list["BtnPromote" .. i]:SetActive(false)
		end
		if have_item_num >= cost_item_num then
			self.node_list["UI_lingqu_T" .. i]:SetActive(true)
			local str = string.format(Language.JingLing.ZhenFaCostDesc, item_cfg.name or "",have_item_num or 0,cost_item_num or 0)
			self.node_list["Txtconsume" .. i].text.text = str
		else
			self.node_list["UI_lingqu_T" .. i]:SetActive(false)
			local str = string.format(Language.JingLing.ZHenFaHunYuLessCostDesc, item_cfg.name or "",have_item_num or 0,cost_item_num or 0)
			self.node_list["Txtconsume" .. i].text.text = str
		end
		-- 魂玉等级
		self.node_list["TxtLV" .. i].text.text = "LV." .. hunyu_level_list[i]
		--当前额外转换率
		local convert_rate = hunyu_cfg and hunyu_cfg.convert_rate or 0
		convert_rate = convert_rate / 100 .. "%" 
		self.node_list["TxtCurRate" .. i].text.text = convert_rate
		self.node_list["TxtNextRate" .. i].text.text = hunyu_next_cfg.convert_rate / 100 .. "%"
	end
end

function HunYuUpGradeView:OnClickUpGardeAttackHunYu()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_HUNYU,self.hunyu_type.attackhunyu)
end

function HunYuUpGradeView:OnClickUpGardeDefenseHunYu()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_HUNYU,self.hunyu_type.defensehunyu)
end

function HunYuUpGradeView:OnClickUpGardeLifeHunYu()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_HUNYU,self.hunyu_type.lifehunyu)
end