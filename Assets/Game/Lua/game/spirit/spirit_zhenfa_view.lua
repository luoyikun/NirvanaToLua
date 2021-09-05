-- 仙宠-阵法-已屏蔽
SpiritZhenfaView = SpiritZhenfaView or BaseClass(BaseRender)

function SpiritZhenfaView:__init(instance)
	self.model_list = {}
	self.sprite_table = {}

	self.node_list["model_root1"].button:AddClickListener(BindTool.Bind(self.OnClickShowShangzhenList, self, 1))
	self.node_list["model_root2"].button:AddClickListener(BindTool.Bind(self.OnClickShowShangzhenList, self, 2))
	self.node_list["model_root3"].button:AddClickListener(BindTool.Bind(self.OnClickShowShangzhenList, self, 3))
	self.node_list["AllShowBtn"].button:AddClickListener(BindTool.Bind(self.OnShowProperty, self))
	self.node_list["Promote_Btn"].button:AddClickListener(BindTool.Bind(self.OnLeveUpZhenfa, self))
	self.node_list["BtnHunshouyu1"].button:AddClickListener(BindTool.Bind(self.OnShowHunShouyuView, self))
	self.node_list["BtnHunshouyu2"].button:AddClickListener(BindTool.Bind(self.OnShowHunShouyuView, self))
	self.node_list["BtnHunshouyu3"].button:AddClickListener(BindTool.Bind(self.OnShowHunShouyuView, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelper, self))

	for i = 1,3 do
		self.model_list[i] = RoleModel.New()
		self.model_list[i]:SetDisplay(self.node_list["ModelDisPlay" .. i].ui3d_display)
	end

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritShangZhen)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritZhenFaPromote)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritZhenFaUplevel)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritZhenFaHunyu)
end

function SpiritZhenfaView:LoadCallBack()

end

function SpiritZhenfaView:__delete()
	if self.model_list then
		for k,v in pairs(self.model_list) do
			v:DeleteMe()
		end
	end
	self.model_list = {}
	self.sprite_table = {}
	self.helpId = 42

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function SpiritZhenfaView:RemindChangeCallBack(remind_name, num)
	if RemindName.SpiritShangZhen == remind_name or
		RemindName.SpiritZhenFaPromote == remind_name then
		self:Flush()
	end
end

function SpiritZhenfaView:CloseCallBack()

end

function SpiritZhenfaView:OnShowProperty()

	SpiritCtrl.Instance:ShowSpiritZhenFaValueView()
end

function SpiritZhenfaView:OnLeveUpZhenfa()
	SpiritCtrl.Instance:ShowSpiritZhenFaPromoteView(SPIRITPROMOTETAB_TYPE.TABXIANZHEN)
end

function SpiritZhenfaView:OnClickShowShangzhenList(index)
	local item = self.sprite_table[index] and self.sprite_table[index].item or nil
	TipsCtrl.Instance:ShowSpiritShangZhenView(index, item)
end

function SpiritZhenfaView:OnShowHunShouyuView()
	SpiritCtrl.Instance:ShowSpiritZhenFaPromoteView(SPIRITPROMOTETAB_TYPE.TABHUNYU)
end

function SpiritZhenfaView:OnClickHelper()
	local helpId = 42
	TipsCtrl.Instance:ShowHelpTipView(helpId)
end

function SpiritZhenfaView:OnFlush(param_list)
	--判断红点
	self.node_list["Imgredpoint"]:SetActive(SpiritData.Instance:CanPromote())

	for i =1, 3 do
		self.node_list["Imgredpoint" .. i]:SetActive(SpiritData.Instance:CanHunYuUp(i))
	end

	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local zhenfa_attr_list = SpiritData.Instance:GetZhenfaAttrList()
	local zhenfa_level = spirit_info.xianzhen_level
	local zhenfa_info = SpiritData.Instance:GetZhenfaCfgByLevel(zhenfa_level)
	if nil == zhenfa_info then -- 阵法满級
		zhenfa_info = SpiritData.Instance:GetZhenfaMaxLevelCfg()
	end
	local zhenfa_rate = zhenfa_info.convert_rate / 100
	local hunyu_level_list = spirit_info.hunyu_level_list
	local attackhunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.ATTACK_HUNYU, hunyu_level_list[HUNYU_TYPE.ATTACK_HUNYU])
	local attackhunyu_rate = attackhunyu_cfg and attackhunyu_cfg.convert_rate or 0
	local defensehunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.DEFENSE_HUNYU, hunyu_level_list[HUNYU_TYPE.DEFENSE_HUNYU])
	local defensehunyu_rate = defensehunyu_cfg and defensehunyu_cfg.convert_rate or 0
	local lifehunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.LIFE_HUNYU,hunyu_level_list[HUNYU_TYPE.LIFE_HUNYU])
	local lifehunyu_rate = lifehunyu_cfg and lifehunyu_cfg.convert_rate or 0

	self.node_list["zhenfa_lv"].text.text = "LV." .. zhenfa_level
	self.node_list["addspiritpower"].text.text = CommonDataManager.GetCapabilityCalculation(SpiritData.Instance:GetZhenfaAttrList())
	self.node_list["attackhunshouyu_lv"].text.text = string.format(Language.JingLing.TxtGongJi, attackhunyu_rate / 100 .. "%")
	self.node_list["lifeshouhunyu_lv"].text.text = string.format(Language.JingLing.TxtShengMing, lifehunyu_rate / 100 .. "%")
	self.node_list["defenseshouhunyu_lv"].text.text = string.format(Language.JingLing.TxtFangYu, defensehunyu_rate / 100 .. "%")
	self.node_list["FangyuTxt"].text.text = string.format(Language.JingLing.TxtZhenFaRate, zhenfa_rate .. "%")
	local display_list = SpiritData.Instance:GetSpiritInfo().jingling_list
	local use_jingling_id = SpiritData.Instance:GetSpiritInfo().use_jingling_id
	for i = 1, 3 do 
		self.node_list["ZhenfaImg" .. i]:SetActive(SpiritData.Instance:CanShangZhen())
	end

	for k,v in pairs(self.sprite_table) do
		v.has = false
	end
	local add_list = {}
	local need = true
	if display_list then
		for k, v in pairs(display_list) do
			if v.item_id > 0 and use_jingling_id ~= v.item_id then
				need = true
				for k1,v1 in pairs(self.sprite_table) do
					if v1.item.item_id == v.item_id then
						v1.has = true
						need = false
					end
				end
				if need then
					table.insert(add_list, v)
				end
			end
		end
	end
	for k,v in pairs(self.sprite_table) do
		if not v.has then
			self.sprite_table[k] = nil
			self.node_list["ModelImg" .. k]:SetActive(true)
			self.node_list["NameImg" .. k]:SetActive(false)
			self.node_list["ModelDisPlay" .. k]:SetActive(false)
		else
			self.node_list["ModelImg" .. k]:SetActive(false)
			self.node_list["NameImg" .. k]:SetActive(true)
			self.node_list["ModelDisPlay" .. k]:SetActive(true)
			self.node_list["ZhenfaImg" .. k]:SetActive(false)
		end

		-- 各个仙宠战斗力显示
		local attr_list = SpiritData.Instance:GetSpiritZhenfaCapacityByIndex(v.item.index)
		local capacity = CommonDataManager.GetCapabilityCalculation(attr_list)
		self.node_list["TxtPower" .. k].text.text = capacity

	end
	local spirit_cfg = nil
	local bundle_main, asset_main = nil, nil

	for k,v in pairs(add_list) do
		for i = 1, 3 do
			if nil == self.sprite_table[i] then
				self.sprite_table[i] = {}
				self.sprite_table[i].item = v
				self.sprite_table[i].has = true
				spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(v.item_id)
				bundle_main, asset_main = ResPath.GetSpiritModel(spirit_cfg.res_id)
				self.model_list[i]:SetMainAsset(bundle_main, asset_main)
				self.node_list["ZhenfaImg" .. i]:SetActive(false)
				self.node_list["ModelImg" .. i]:SetActive(false)
				self.node_list["NameImg" .. i]:SetActive(true)
				self.node_list["ModelDisPlay" .. i]:SetActive(true)
				-- 各个仙宠战斗力显示
				local attr_list = SpiritData.Instance:GetSpiritZhenfaCapacityByIndex(v.index)
				local capacity = CommonDataManager.GetCapabilityCalculation(attr_list)
				self.node_list["TxtPower" .. i].text.text = capacity
				break
			end
		end 
	end
end