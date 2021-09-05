local LUOSHUMAXCOUNT = 16

LuoShuItemView = LuoShuItemView or BaseClass(BaseRender)
LuoShuItemView.AttrList = {"maxhp", "gongji", "fangyu", "fa_fangyu", "baoji", "pojia", "fujiashanghai", "dikangshanghai", "per_baoji", "per_kangbao",
																	"max_hp", "gong_ji", "fa_gong_ji", "fang_yu", "fa_fang_yu", "bao_ji", "per_baoji", "fujia_shanghai", "dikang_shanghai", "po_jia"}

function LuoShuItemView:__init()

end

function LuoShuItemView:__delete()
end

function LuoShuItemView:ReleaseCallBack()
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function LuoShuItemView:LoadCallBack()
	-- self.node_list["Icon"]:SetActive(false)
	-- self.node_list["Quality"]:SetActive(false)
end

function LuoShuItemView:ShowIndexCallBack()
	self:Flush()
end

function LuoShuItemView:ListenClick(handler)
	if self.data then
		-- self.node_list["ItemCell"].toggle:AddClickListener(self.data.tab_index == 1 and handler or BindTool.Bind(self.OnClickItemCell, self))
		self.node_list["ItemCell"].toggle:AddClickListener(BindTool.Bind(self.OnClickItemCell, self))
	end
end

function LuoShuItemView:SetToggleGroup(toggle_group)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.group = toggle_group
	end
end

function LuoShuItemView:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function LuoShuItemView:OnClickActive()
	local data_list = LuoShuData.Instance:GetHeShenLuoShuAllDataByTypeAndSeq()
	if data_list[self.select_index].star_level < 0 then
		LuoShuCtrl.Instance:SendHeShenLuoShuReq(HESHENLUOSHU_REQ_TYPE.HESHENLUOSHU_REQ_TYPE_ACTIVATION, data_list[self.select_index].item_id)
	else
		LuoShuCtrl.Instance:SendHeShenLuoShuReq(HESHENLUOSHU_REQ_TYPE.HESHENLUOSHU_REQ_TYPE_UPGRADELEVEL, data_list[self.select_index].item_id)
	end
end

function LuoShuItemView:OnClickItemCell()
	if nil ~= self.data and nil ~= next(self.data) then
		LuoShuCtrl.Instance:OpenUpgradeView(self.data)
	end
end

function LuoShuItemView:SetData(data)
	self.data = data
	if self.data and next(self.data) then
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
		if nil == item_cfg then
			self.node_list["ItemCell"]:SetActive(false)
			self.node_list["Icon"]:SetActive(false)
			self.node_list["Quality"]:SetActive(false)
			self.node_list["ZhuanShu"]:SetActive(false)
			return
		else
			self.node_list["ZhuanShu"]:SetActive(false)
			self.node_list["Name"]:SetActive(true)
			self.node_list["SpecialName"]:SetActive(false)
			self.node_list["Name"].text.text = item_cfg.name
			local cfg = ItemData.Instance:GetItemConfig(data.item_id_prof)
			if cfg and next(cfg) then
				if cfg.limit_sex ~= 2 then
					self.node_list["ZhuanShu"].image:LoadSprite("uis/views/player/images_atlas", "zhuanshu_prof_" .. cfg.limit_sex , function()
						self.node_list["ZhuanShu"]:SetActive(true)
						self.node_list["ZhuanShu"].image:SetNativeSize()
					end)
					self.node_list["Name"]:SetActive(false)
					self.node_list["SpecialName"]:SetActive(true)
					local str = Language.Common.LuoShuProfNameAndPoint[cfg.limit_sex] or ""
					self.node_list["SpecialName"].text.text = str .. item_cfg.name
				end
			end
			local bundle, asset = ResPath.GetLuoShuIcon(self.data.image_id)
			local bundle1, asset1 = ResPath.GetLuoShuQuality(item_cfg.color)
			local bundle2, asset2 = ResPath.GetLuoNameQuality(item_cfg.color)
			self.node_list["Mask"]:SetActive(self.data.star_level < 0)
			-- UI:SetGraphicGrey(self.node_list["GrayItem"], self.data.star_level < 0)
			self.node_list["Quality"]:SetActive(true)
			self.node_list["Icon"]:SetActive(true)
			self.node_list["Quality"].image:LoadSprite(bundle1, asset1)
			self.node_list["Icon"].image:LoadSprite(bundle, asset)
			self.node_list["LevelBg"].image:LoadSprite(bundle2, asset2)

			self.node_list["StarBg"]:SetActive(true)
			self.node_list["FightPower"]:SetActive(true)
			local is_red = LuoShuData.Instance:HeShenLuoShuRemindShow(self.data)
			local attrs = self.data.star_level == -1 and LuoShuData.Instance:GetHeShenLuoShuSingleAttr(self.data.index, true) or LuoShuData.Instance:GetHeShenLuoShuSingleAttr(self.data.index)
			local power = CommonDataManager.GetCapabilityCalculation(attrs)
			self.node_list["Number"].text.text = power
			if self.data.star_level < 0 then
				self.node_list["LevelBg"]:SetActive(false)
				self.node_list["TxtLevel"].text.text = ""
			else
				self.node_list["LevelBg"]:SetActive(true)
				self.node_list["TxtLevel"].text.text = self.data.star_level + 1
			end
			self.node_list["RedPoint"]:SetActive(is_red)
		end
	end
end