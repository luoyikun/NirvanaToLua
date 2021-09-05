ClothespressSuitAttrView = ClothespressSuitAttrView or BaseClass(BaseView)

ClothespressSuitAttrView.SuitMaxLevel	= 5 									--套装最大等级
function ClothespressSuitAttrView:__init()
	self.ui_config = {{"uis/views/clothespress_prefab", "ClothespressSuitView"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.open_index = 0
end

function ClothespressSuitAttrView:__delete()

end

function ClothespressSuitAttrView:LoadCallBack()
	self.suit_count = 0

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()

	self.color_list = {}
	for i = 0, 4 do
		table.insert(self.color_list, self.node_list["TxtColor" .. i])
	end

	self.suit_attr1 = {}
	self.suit_attr2 = {}
	self.suit_attr3 = {}
	for i = 1, 5 do
		self.suit_attr1[i] = self.node_list["Suit1"].transform:FindHard("Attr" .. i)
		self.suit_attr2[i] = self.node_list["Suit2"].transform:FindHard("Attr" .. i)
		self.suit_attr3[i] = self.node_list["Suit3"].transform:FindHard("Attr" .. i)
	end
end

-- 销毁前调用
function ClothespressSuitAttrView:ReleaseCallBack()
	self.suit_count = nil

	for k,v in pairs(self.color_list) do
		v = nil
	end
	self.color_list = {}
	
	self.hunyin_info = {}
	self.suit_level = 0

	for k, v in pairs(self.suit_attr1) do
        ResMgr:Destroy(v.gameObject)
	end
	self.suit_attr1 = {}
	
	for k, v in pairs(self.suit_attr2) do
        ResMgr:Destroy(v.gameObject)
	end
	self.suit_attr2 = {}

	for k, v in pairs(self.suit_attr3) do
        ResMgr:Destroy(v.gameObject)
	end
	self.suit_attr3 = {}
end

-- 打开后调用
function ClothespressSuitAttrView:OpenCallBack()
	self:Flush()
end

function ClothespressSuitAttrView:CloseCallBack()

end

function ClothespressSuitAttrView:SetData(data_index)
	if not data_index then return end

	self.data_index = data_index
	self.data_list = ClothespressData.Instance:GetSuitAttrDataListBySuitIndex(data_index)
	self:Open()
end

function ClothespressSuitAttrView:OnFlush()
	if not self.data_list or not next(self.data_list) then return end

	local data_list = self.data_list
	self.node_list["TxtSuitLevel"].text.text = ToColorStr(data_list.suit_name, "#fc4d00") 

	local item_info = ClothespressData.Instance:GetSingleSuitPartInfoBySuitIndex(self.data_index)
	local count = 1
	for k, v in pairs(data_list.suit_item_cfg) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.img_item_id)
		if item_cfg and self.color_list[count] then
			local color = item_info[k] == 0 and TEXT_COLOR.WHITE or SOUL_NAME_COLOR[item_cfg.color]
			self.color_list[count].text.text = ToColorStr(item_cfg.name, color)
			self.color_list[count]:SetActive(true)
			count = count + 1
		end
	end

	for i = count, #self.color_list do
		self.color_list[i]:SetActive(false)
	end

	-- 属性
	local active_part_num = data_list.active_part_num
	for k, v in pairs(data_list.suit_attr) do
		local color = active_part_num >= v.img_count_min and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
		local active_num = "(" .. (active_part_num >= v.img_count_min and v.img_count_min or ToColorStr(active_part_num, TEXT_COLOR.RED)) .. "/" .. v.img_count_min .. ")"
		local desc = v.auit_name .. active_num
		self.node_list["SuitTitle" .. k].text.text = ToColorStr(desc, color)

		count = 1
		for k2, v2 in pairs(v) do
			if CommonDataManager.GetAttrName(k2) and CommonDataManager.GetAttrName(k2) ~= "nil" and v2 > 0 or Language.Clothespress.SUitAttr[k2] and v2 > 0 then
				local attr_name = CommonDataManager.GetAttrName(k2)
				if attr_name == "nil" then
					attr_name = Language.Clothespress.SUitAttr[k2]
				end

				if k <= 3 and count <= 5 then
					local obj = self["suit_attr" .. k][count].gameObject
					obj:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr("  " .. attr_name .. ":" .. (v2 / 100) .. "%", color)
					obj:SetActive(true)
					count = count + 1
				end
			end
		end
		if k <= 3 then 		--防止取不到预制体
			if count > 1 then
				self.node_list["Suit" .. k]:SetActive(true)
				self.node_list["Title" .. k]:SetActive(true)
			else
				self.node_list["Suit" .. k]:SetActive(false)
				self.node_list["Title" .. k]:SetActive(false)
			end
			for i = count, #self["suit_attr" .. k], 1 do
				local obj = self["suit_attr" .. k][i].gameObject
				obj:SetActive(false)
			end
		end
	end
end
