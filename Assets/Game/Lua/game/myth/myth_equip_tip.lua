MythEquipTip = MythEquipTip or BaseClass(BaseView)
MythEquipTip.FromView = {
	MythView = 1,
	MythEquipView = 2,
	MythBagView = 3,
	MythComposeView = 4,
	MythCuiQuView = 5,
	MythViewPianZhanView = 6,
	MythGongMingView = 7,
}
function MythEquipTip:__init()
	self.ui_config = {{"uis/views/myth_prefab","MythEquipTip"},}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MythEquipTip:__delete()

end

function MythEquipTip:ReleaseCallBack()
	if self.equip_compare_tips then
		self.equip_compare_tips:DeleteMe()
		self.equip_compare_tips = nil
	end
end

function MythEquipTip:LoadCallBack()
	self.equip_compare_tips = MythEquipLeftTip.New(self.node_list["EquipCompareTip"], self)
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function MythEquipTip:CloseCallBack()
	-- self.equip_tips:CloseCallBack()
	self.equip_compare_tips:CloseCallBack()
end

function MythEquipTip:OpenCallBack()
	if self.data_cache then
		self:SetData(self.data_cache.data, self.data_cache.from_view, self.data_cache.writing_id, self.data_cache.close_call_back, self.data_cache.is_tian_sheng)
		self.data_cache = nil
		self:Flush()
	end
end

--关闭装备Tip
function MythEquipTip:OnClickCloseButton()
	self:Close()
end


--设置显示弹出Tip的相关属性显示
function MythEquipTip:SetData(data, from_view, writing_id, close_call_back, is_tian_sheng)
	if not data then
		return
	end
	from_view = from_view or MythEquipTip.FromView.MythView
	if self:IsOpen() then
		self.equip_compare_tips:SetData(data, from_view, writing_id, close_call_back, is_tian_sheng)
		-- self.equip_tips:SetActive(false)
		self:Flush()
	else
		self.data_cache = {data = data, from_view = from_view, writing_id = writing_id, close_call_back = close_call_back, is_tian_sheng = is_tian_sheng,}
		self:Open()
	end

	self.from_view = from_view
end

function MythEquipTip:OnFlush(param_t)
	-- self.equip_tips:OnFlush(param_t)
	self.equip_compare_tips:OnFlush(param_t)
end
--=========item====================


MythEquipLeftTip = MythEquipLeftTip or BaseClass(BaseRender)

function MythEquipLeftTip:__init(instance, parent)
	self.parent = parent
	self.base_attr_list = {}
	-- self.random_attr_list = {}
	self.gongming_attr_list = {}
	self.is_cui_qu = false

	self.data = nil
	self.from_view = nil
	self.writing_id = 0
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}

	self.now_fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetIsShowTips(false)
	self.equip_item:SetInstanceParent(self.node_list["EquipItem"])

	for i = 1, 4 do
		self.gongming_attr_list[i] = {attr_name = self.node_list["GongMingAttr" .. i], attr_value = self.node_list["GongMingAttr" .. i],
									is_show = self.node_list["GongMingAttr" .. i]
		}
	end
	for i = 1, 5 do
		self.base_attr_list[i] = {attr_name = self.node_list["BaseAttr_" .. i], attr_value = self.node_list["BaseAttr_" .. i],
									is_show = self.node_list["BaseAttr_" .. i]
		}
	end

	-- self.show_random = self:FindVariable("ShowRandom")
	self.scroller_rect = self.node_list["Scroller"].scroll_rect
end

function MythEquipLeftTip:__delete()
	self.button_label = nil
	self.base_attr_list = nil
	self.parent = nil
	self.gongming_attr_list = nil 
	self.gongming = nil
	self.resonance_level = nil
	self.now_fight_text = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function MythEquipLeftTip:ShowTipContent()
	 local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	 if item_cfg == nil then
	 	return
	 end

	local bundle, sprite = nil, nil
	local color = nil
	local chapter_quality = MythData.Instance:GetPianZhangQualityByIndex(self.data.chapter_id)
	bundle, asset = ResPath.GetQualityRawBgIcon(chapter_quality)
	self.node_list["TopTitleQuality"].raw_image:LoadSprite(bundle, asset)

	if self.from_view == MythEquipTip.FromView.MythViewPianZhanView or self.from_view == MythEquipTip.FromView.MythGongMingView then
		-- self.node_list["SpecialAttr"]:SetActive(false)
		-- self.show_random:SetValue(false)
		self.node_list["GongMingAttr"]:SetActive(true)
		self.node_list["TypeTitle"]:SetActive(false)
		self.node_list["quality"]:SetActive(false)
		self.node_list["name"].text.text = self.data.name
		self.node_list["ResonanceLevel"]:SetActive(true)
		local show_level = math.max(self.data.level - 1, 0)
		local zhangjie_level = show_level..Language.ShenHua.Zhang
		local resonance_level = self.data.resonance_level..Language.ShenHua.Juan
		self.node_list["ResonanceLevel"].text.text = string.format("%s%s", resonance_level, zhangjie_level)
		self.node_list["EquaipName"].text.text = ToColorStr(self.data.name, SOUL_NAME_COLOR[chapter_quality])
		local pianzhan_attr = self.data[1]
		local lingwu_attr = self.data[2]
		-- local gongming_attr = self.data[3]
		local gongming_attr = MythData.Instance:SortListByAttr(self.data[3])
		for k,v in ipairs(self.base_attr_list) do
			if pianzhan_attr[k] then
				local attr_name = Language.ShenHua.MythEquipAttrNameNoUnderline[pianzhan_attr[k].name] .. ": "
				if pianzhan_attr[k].name and (pianzhan_attr[k].name == "per_pofang" or pianzhan_attr[k].name == "per_mianshang") then
					local value = math.floor(pianzhan_attr[k].value / 100)
					v.attr_value.text.text = ToColorStr(attr_name, "#ffffff") .. ToColorStr(value .. "%", "#00ff00")
				else
					v.attr_value.text.text = ToColorStr(attr_name, "#ffffff") .. ToColorStr(pianzhan_attr[k].value, "#00ff00")
				end
				v.is_show:SetActive(true)
			else
				v.is_show:SetActive(false)
			end
		end
		for k,v in ipairs(self.gongming_attr_list) do
			if gongming_attr[k].name ~= "" then
				local attr_name = Language.ShenHua.MythEquipAttrNameNoUnderline[gongming_attr[k].name] .. ": "
				-- 万分比特殊显示
				local attr_value = gongming_attr[k].value
				for i = 10, 26 do
					if MythGongMingAttrType[i] and gongming_attr[k].name == MythGongMingAttrType[i] then
						attr_value = attr_value / 100
						attr_value = attr_value.."%"
					end
				end
				v.attr_value.text.text = ToColorStr(attr_name, "#ffffff") .. ToColorStr(attr_value, "#00ff00")
				v.is_show:SetActive(true)
			else
				v.is_show:SetActive(false)
			end
		end

		self.equip_item:SetData({item_id = self.data.item_id})
		-- self.node_list["FightText"].text.text = self.data.all_cap
		if self.now_fight_text and self.now_fight_text.text then
			self.now_fight_text.text.text = self.data.all_cap
		end

	elseif self.from_view == MythEquipTip.FromView.MythEquipView or 
			self.from_view == MythEquipTip.FromView.MythComposeView or 
			self.from_view == MythEquipTip.FromView.MythBagView or
			self.from_view == MythEquipTip.FromView.MythCuiQuView
			then

		if self.from_view == MythEquipTip.FromView.MythEquipView then
			local show_level = self.data.level - 1
			self.zhangjie_level.text.text = show_level.. Language.ShenHua.Zhang
			self.node_list["name"].text.text = Language.ShenHua.ChapterName[self.writing_id]
			self.node_list["TypeTitle"]:SetActive(false)
			self.node_list["quality"]:SetActive(false)
		else
			self.node_list["TypeTitle"]:SetActive(true)
			self.node_list["quality"]:SetActive(false)
		end
		self.gongming:SetActive(false)
		self.node_list["quality"].text.text = Language.ShenHua.ShenHunColor[item_cfg.color]
		local item_name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
		self.node_list["EquaipName"].text.text = item_name
		self.node_list["TypeTitle"].text.text = Language.ShenHua.ShenHunLeiXing

		local attr_list = MythData.Instance:GetGodsoulBaseattr(self.data.item_id)
		local base_attr_list = CommonDataManager.GetAttributteNoUnderline(attr_list)
		local base_capability = CommonDataManager.GetCapability(attr_list)
		      							-- 装备基础评分
		local attr_list_cap = MythData.Instance:ComputingAttrListPower(self.data.attr_list,self.data.quality)
		local zonghe_pingfen = base_capability + attr_list_cap
		-- self.node_list["FightText"].text.text = zonghe_pingfen
		if self.now_fight_text and self.now_fight_text.text then
			self.now_fight_text.text.text = zonghe_pingfen
		end

		local cfg= MythData.Instance:GetGodSoulConfig(self.data.item_id)
		local  count = 0
		if self.data.give_start_num then
			count = self.data.give_start_num
		else
			if cfg then
				for i=1,MYTH_TYPE.MAX_MYTH_SOUL_SLOT do
					local random_attr = MythData.Instance:GetRandomAttrCfg(cfg.quality,self.data.attr_list[i].attr_type)
					if random_attr and random_attr.is_star_attr == 1 then
						count = count + 1
					end
				end
			end
		end

		self.equip_item:SetData(self.data)
		self.equip_item:SetInteractable(false)
		self.equip_item:SetShowStar(count)
		self.equip_item.show_prop_des:SetActive(false)

		local had_base_attr = {}

		for k, v in pairs(base_attr_list) do
			if v > 0 then
				table.insert(had_base_attr, {key = k, value = v})
			end
		end

		-- 基础
		if #had_base_attr > 0 then
			for k, v in ipairs(self.base_attr_list) do
				v.is_show:SetActive(had_base_attr[k] ~= nil)
				if had_base_attr[k] ~= nil then
					-- v.attr_name.text.text = Language.Common.AttrNameNoUnderline[had_base_attr[k].key]
					local attr_name = Language.Common.AttrNameNoUnderline[had_base_attr[k].key] .. ": "
					if had_base_attr[k].key and had_base_attr[k].key == per_pofang or had_base_attr[k].key == per_mianshang then
						local value = math.floor(had_base_attr[k].value / 100)
						v.attr_value.text.text = ToColorStr(attr_name, "#ffffff") .. ToColorStr(value .. "%", "#00ff00")
					else
						v.attr_value.text.text = ToColorStr(attr_name, "#ffffff") .. ToColorStr(had_base_attr[k].value, "#00ff00")
					end
					-- local bundle,asset = ResPath.GetBaseAttrIcon(had_base_attr[k].key)
					-- v.attr_icon:SetAsset(bundle, asset)
				end
			end
		end
		if self.data.attr_list then
		    --卓越属性
			-- self.node_list["SpecialAttr"]:SetValue(true)
			-- self.show_random:SetValue(false)
			local spec_index = 1
			if self.data.attr_list then
				for k,v in pairs(self.data.attr_list) do
					if v.attr_type > 0 then
						local add_per_t = {[1] = "%", [2] = "%", [3] = "%", [4] = "%", [5] = "%", [6] = "%", [7] = "%", [8] = "%", [9] = "%"}
						local add_value = add_per_t[v.attr_type] and v.attr_value/100 .. "%" or v.attr_value
						local random_cfg = MythData.Instance:GetRandomAttrCfg(item_cfg.color, v.attr_type) or {}
						local attr_show = random_cfg.attr_type % 10 + math.floor(random_cfg.attr_type / 10)	* 1
						local color = random_cfg.is_star_attr == 1 and TEXT_COLOR.ORANGE or TEXT_COLOR.PURPLE
						-- if self.special_attr_list[spec_index] then
						-- 	self.special_attr_list[spec_index].is_show:SetValue(true)
						-- 	if random_cfg.is_star_attr == 1 then
						-- 		self.special_attr_list[spec_index].attr_name:SetValue(string.format("<color='%s'>%s</color>", color,Language.ShenHua.ChapterAttr .. Language.Common.ShenHuaRandAttrKey[attr_show] .. "+" .. add_value)) 
						-- 	else
						-- 		self.special_attr_list[spec_index].attr_name:SetValue(string.format("<color='%s'>%s</color>", color,Language.Common.ShenHuaRandAttrKey[attr_show] .. "+" .. add_value)) 
						-- 	end
						-- 	local bundle,asset = ResPath.GetBaseAttrIcon(Language.Common.ShenHuaRandAttrKey[attr_show])
						-- 	self.special_attr_list[spec_index].attr_icon:SetAsset(bundle, asset)
						-- 	spec_index = spec_index + 1
						-- end
					end
				end
			end
		else
			-- 随机属性
			-- self.node_list["SpecialAttr"]:SetValue(false)
			-- self.show_random:SetValue(true)
			local rand_index = 1
			local legend_num = self.data.give_start_num
			local legend_attr_list = MythData.Instance:GetRanAttrList(item_cfg.color, legend_num)
			
			-- for k,v in ipairs(self.random_attr_list) do
			-- 	if k > legend_num then
			-- 		v.is_show:SetValue(false)
			-- 	end
			-- end
			-- self.rand_attr_num:SetValue(legend_num)
			-- self.node_list["RandomAttrText"].text.text = string.format("(随机生成%s条高级极品属性)", legend_num)
			for k,v in pairs(legend_attr_list) do
				if v.attr_type > 0 then
					local add_per_t = {[1] = "%", [2] = "%", [3] = "%", [4] = "%", [5] = "%", [6] = "%", [7] = "%", [8] = "%", [9] = "%"}
					local add_value = add_per_t[v.attr_type] and v.attr_value/100 .. "%" or v.attr_value
					local random_cfg = MythData.Instance:GetRandomAttrCfg(item_cfg.color, v.attr_type) or {}
					local attr_show = random_cfg.attr_type % 10 + math.floor(random_cfg.attr_type / 10)	* 1
					local color = random_cfg.is_star_attr == 1 and TEXT_COLOR.ORANGE or TEXT_COLOR.PURPLE
					-- if self.random_attr_list[rand_index] then
					-- 	self.random_attr_list[rand_index].is_show:SetValue(true)
					-- 	if random_cfg.is_star_attr == 1 then
					-- 		self.random_attr_list[rand_index].attr_name:SetValue(string.format("<color='%s'>%s</color>", color,Language.ShenHua.ChapterAttr .. Language.Common.ShenHuaRandAttrKey[attr_show] .. "+" .. add_value))  
					-- 	else
					-- 		self.random_attr_list[rand_index].attr_name:SetValue(string.format("<color='%s'>%s</color>", color,Language.Common.ShenHuaRandAttrKey[attr_show] .. "+" .. add_value))  	
					-- 	end	
					-- 	local bundle,asset = ResPath.GetBaseAttrIcon(Language.Common.ShenHuaRandAttrKey[attr_show])
					-- 	self.random_attr_list[rand_index].attr_icon:SetAsset(bundle, asset)
					-- 	rand_index = rand_index + 1
					-- end
				end
			end
		end
	end
end


function MythEquipLeftTip:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.is_tian_sheng = nil
	self.writing_id = 0
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function MythEquipLeftTip:OnFlush(param_t)
	if self.data == nil then
		return
	end
	if self.scroller_rect then
		self.scroller_rect.normalizedPosition = Vector2(0, 1)
	end
	self:ShowTipContent()
end

--设置显示弹出Tip的相关属性显示
function MythEquipLeftTip:SetData(data,from_view, writing_id, close_call_back, is_tian_sheng)
	if not data then
		print("数据等于空")
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end


	self.close_call_back = close_call_back
	self.is_tian_sheng = is_tian_sheng
	self.from_view = from_view
	self.writing_id = writing_id or 0
	self:Flush()

end