BianShenHeadItem = BianShenHeadItem or BaseClass(BaseCell)
-- 测试
function BianShenHeadItem:__init()

end

function BianShenHeadItem:__delete()
	
end

function BianShenHeadItem:ListenClick(handler)
	self.node_list["BianShenHeadItem"].toggle:AddClickListener(handler)
end

function BianShenHeadItem:SetParent(parent)
	self.parent = parent
end


function BianShenHeadItem:OnFlush()
	if not self.data or not next(self.data) then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id) or {}
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id or 0)
	self.node_list["Head"].image:LoadSprite(bundle, asset)
	local is_active = BianShenData.Instance:CheckGeneralIsActive(self.data.seq)
	UI:SetGraphicGrey(self.node_list["NormalBG"], not is_active)
	self.node_list["NormalBG"].image:LoadSprite(ResPath.GetQualityIcon(self.data.color))
	self:SetUpArrow()
end

function BianShenHeadItem:SetHighLight(value)
	if self.data and self.data.seq then
		self.node_list["RightHl"]:SetActive(self.data.seq == value - 1)
	else
		self.node_list["RightHl"]:SetActive(true)
	end
end

function BianShenHeadItem:SetUpArrow()
	local other_cfg = BianShenData.Instance:GetOtherCfg()
	local cur_info = BianShenData.Instance:GetGeneralSingleInfoBySeq(self.data.seq)
	if not other_cfg or not cur_info then return end
	local is_active = BianShenData.Instance:CheckGeneralIsActive(self.data.seq)

	if self.tab_index == 1 then
		local up_num = ItemData.Instance:GetItemNumInBagById(self.data.item_id)
		local potential_num = ItemData.Instance:GetItemNumInBagById(BianShenData.Instance:GetPotentialUpgradeItem(self.data.seq))
		self.node_list["UpArrow"]:SetActive(up_num >= 1 and cur_info.level < other_cfg.max_level)
		local name_str = ToColorStr(self.data.name, ITEM_COLOR[self.data.color])
		self.node_list["Name"].text.text = name_str
		self.node_list["Lv"]:SetActive(true)
		local str_lv = self.data.level > 0 and string.format(Language.BianShen.UpGradeCountThree, CommonDataManager.GetDaXie(self.data.level)) or Language.BianShen.NotJiHuo
		self.node_list["Lv"].text.text = str_lv
		
		local is_show, _, cfg = DisCountData.Instance:IsOpenYiZheAllBySystemId(Sysetem_Id_Jump.Sheng_Mo)
		self.node_list["XianShiImg"]:SetActive(false)
		if is_show and cfg and cfg.system_index then
			for k, v in pairs(cfg.system_index) do
				local index_list = Split(v, "|")
				for k, v in pairs(index_list) do
					if tonumber(v) == self.data.seq then
						self.node_list["XianShiImg"]:SetActive(true)
						break
					end
				end
			end
		end
	elseif self.tab_index == 2 then
		local upgrade_item, need_num = BianShenData.Instance:GetPotentialUpgradeItem(self.data.seq, cur_info.potential_level + 1)
		local is_max = cur_info.potential_level >= BianShenData.Instance:GetMaxPotentialLevel(self.data.seq)
		local own_num = ItemData.Instance:GetItemNumInBagById(upgrade_item)
		self.node_list["UpArrow"]:SetActive(own_num >= need_num and not is_max and is_active)
		local name_str = ToColorStr(self.data.name, ITEM_COLOR[self.data.color])
		self.node_list["Name"].text.text = name_str
		self.node_list["Lv"]:SetActive(true)
		self.node_list["Lv"].text.text = string.format("Lv.%s", self.data.potential_level)
	elseif self.tab_index == 3 then
		if is_active then
			local is_show_arrow = false
			for i = 0, 3 do
				is_show_arrow = BianShenData.Instance:IsShowArrow(self.data.seq, i)
				if is_show_arrow then
					break
				end
			end
			self.node_list["UpArrow"]:SetActive(is_show_arrow)
		else
			self.node_list["UpArrow"]:SetActive(false)
		end
		self.node_list["Name"].text.text = ToColorStr(self.data.name, ITEM_COLOR[self.data.color])
		self.node_list["Lv"].text.text = ""
		self.node_list["Lv"]:SetActive(false)
	else
		self.node_list["UpArrow"]:SetActive(false)
		self.node_list["Name"].text.text = ToColorStr(self.data.name, ITEM_COLOR[self.data.color])
		self.node_list["Lv"].text.text = ""
		self.node_list["Lv"]:SetActive(false)
	end
end

function BianShenHeadItem:SetTabIndex(tab_index)
	self.tab_index = tab_index
end
