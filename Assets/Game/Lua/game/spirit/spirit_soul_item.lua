-- 仙宠-命魂item
SpiritSoulItem = SpiritSoulItem or BaseClass(BaseRender)

function SpiritSoulItem:__init(instance)
	self.effect = nil
	self.tip_effect = nil
	self.is_destroy_effect = true
	self.is_loading = false

	self.is_is_destroy_effect_loading = false
end

function SpiritSoulItem:__delete()
	if self.effect then
		ResMgr:Destroy(self.effect)
		self.effect = nil
	end
	if self.tip_effect then
		ResMgr:Destroy(self.tip_effect)
		self.tip_effect = nil
	end
	self.is_destroy_effect = nil
	self.data = nil
end

function SpiritSoulItem:CloseCallBack()
	if self.tip_effect then
		ResMgr:Destroy(self.tip_effect)
		self.tip_effect = nil
	end
	self.is_is_destroy_effect_loading = false
end

function SpiritSoulItem:IsDestroyEffect(enable)
	self.is_destroy_effect = enable
end

function SpiritSoulItem:SetData(data)
	self.data = data
	if self.effect and self.is_destroy_effect then
		ResMgr:Destroy(self.effect)
		if self.node_list["ImgLevel"] then
			self.node_list["ImgLevel"]:SetActive(false)
		end
		self.effect = nil
	elseif self.is_loading and self.is_destroy_effect then
		self.is_is_destroy_effect_loading = true
	end
	if data then
		local soul_cfg = SpiritData.Instance:GetSoulCfgById(data.id)
		local str = "<color=%s>" .. soul_cfg.name .. "</color>"
		
		self.node_list["NameTxt"].text.text = string.format(str, SOUL_NAME_COLOR[soul_cfg.hunshou_color])

		if not self.effect and not self.is_loading then
			self.is_loading = true
			local async_loader = AllocAsyncLoader(self, "effect_loader")
			local bundle_name, asset_name = ResPath.GetUiJingLingMingHunResid(soul_cfg.hunshou_effect)
			async_loader:Load(bundle_name, asset_name, function (prefab)
				if IsNil(prefab) or self.effect then return end

				if self.is_is_destroy_effect_loading then
					self.is_loading = false
					self.is_is_destroy_effect_loading = false
					return
				end

				local obj = ResMgr:Instantiate(prefab)
				local transform = obj.transform
				transform:SetParent(self.node_list["Icon"].transform, false)
				self.effect = obj.gameObject
				self.is_loading = false
			end)
		end

		if self.node_list["ImgLevel"] then
			self.node_list["ImgLevel"]:SetActive(true)
			self.node_list["TextLevel"].text.text = data.level
		end

		local is_better = SpiritData.Instance:GetIsHasBetterSoulById(data.id or 0)
		if self.node_list["UpArrow"] then
			self.node_list["UpArrow"]:SetActive(is_better)
		end
	else
		self.node_list["NameTxt"].text.text = ""
		if self.node_list["UpArrow"] then
			self.node_list["UpArrow"]:SetActive(false)
		end
	end
end

function SpiritSoulItem:GetData()
	return self.data
end

function SpiritSoulItem:ListenClick(handler)
	self.node_list["SoulImg"].button:AddClickListener(handler)
end
