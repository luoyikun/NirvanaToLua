-- 精灵-悟性加成提示框-SpiritTip
TipsSpiritAptitudeView = TipsSpiritAptitudeView or BaseClass(BaseView)

local aptitude_type = {"gongji_zizhi", "fangyu_zizhi", "maxhp_zizhi"}
function TipsSpiritAptitudeView:__init()
	self.ui_config = {{"uis/views/tips/spirittips_prefab", "SpiritTip"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsSpiritAptitudeView:LoadCallBack()
	self.modle_effect = {}
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function TipsSpiritAptitudeView:ReleaseCallBack()
	self.modle_effect = nil
	self.data = nil
end

function TipsSpiritAptitudeView:CloseWindow()
	self:Close()
end

function TipsSpiritAptitudeView:CloseCallBack()
end

function TipsSpiritAptitudeView:OpenCallBack()
	if self.spirit_data then 
		self:GetAdditionLevel()
		self:InitData()
		self:SetView()
		self:DisposeAdditionLevel()
	end
end

function TipsSpiritAptitudeView:GetAdditionLevel()
	self.level_total_need = self.spirit_data.title_needs
	self.title_effect = self.spirit_data.title_effect
	self.max_addition_level = #self.level_total_need
	self.addition_level = 0
	for i = 1, self.max_addition_level do
		if tonumber(self.spirit_data.wu_xing) >= tonumber(self.level_total_need[i]) then
			self.addition_level = self.addition_level + 1
		end
	end
end

function TipsSpiritAptitudeView:SetView()
	-- body
	if self.data then
		for i = 1, 2 do
			self.node_list["TxtLevelNeed" .. i].text.text = string.format("%s(%s)", self.data.name[i], self.data.need[i])
			local value = self.data.addition[i] or 0
			self.node_list["TxtlevelAdd" .. i].text.text = string.format(Language.Tips.ChengZhangShuXing, value / 100 .. "%")
			self:LoadEffect(i,self.data.effect[i], self.node_list["Effect" .. i])
		end
	end
end

function TipsSpiritAptitudeView:InitData()
	local data = SpiritData.Instance:GetWuXing()
	if data then
		self.data = {}
		self.data.name = {}
		self.data.need = {}
		self.data.addition = {}
		self.data.effect = {}
		-- 当悟性加成等级为0的时候 total_need全部有值
		-- 当悟性加成等级不为0的时候，total_need只有i=2时有值
		local x = 2
		for i = 1, x do
			if self.spirit_data.titles[self.addition_level + i] and self.spirit_data.titles[self.addition_level + i] then
				local color = SPIRIT_ADDITION_NAME_COLOR[self.addition_level + i]
				local txt = self.spirit_data.titles[self.addition_level + i]
				self.data.name[i] = string.format("<color=%s>%s</color>", color, txt)
				self.data.effect[i] = self.title_effect[self.addition_level + i]
				if i ~= 2 then
					self.data.need[i] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.GREEN_4)
				else
					self.data.need[i] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.RED) .. self:DisposeNeedText("/" .. self.level_total_need[self.addition_level + 1], TEXT_COLOR.GRAY_WHITE)
				end
					self.data.addition[i] = self.spirit_data.extra_attr[self.addition_level + i]
			end
		end 
	end
end

function TipsSpiritAptitudeView:SetData(data)
	self.spirit_data = data
end

function TipsSpiritAptitudeView:DisposeAdditionLevel()
	if self.addition_level == 0 then
		self.node_list["Image2"]:SetActive(true)
		self.node_list["Img3"]:SetActive(false)
		self.node_list["TxtShowTitle"]:SetActive(false)
		self.node_list["TxtShowNow"]:SetActive(true)
		self.node_list["Image1"]:SetActive(false)
		self.node_list["BgSize"].rect.sizeDelta = Vector3(350, 438.1, 0)
	elseif self.addition_level == 4 then
		self.node_list["Image2"]:SetActive(false)
		self.node_list["Img3"]:SetActive(true)
		self.node_list["TxtShowTitle"]:SetActive(true)
		self.node_list["TxtShowNow"]:SetActive(false)
		self.node_list["Image1"]:SetActive(false)
		self.node_list["BgSize"].rect.sizeDelta = Vector3(350, 438.1, 0)
	else
		self.node_list["Image2"]:SetActive(true)
		self.node_list["Img3"]:SetActive(true)
		self.node_list["TxtShowTitle"]:SetActive(true)
		self.node_list["TxtShowNow"]:SetActive(false)
		self.node_list["Image1"]:SetActive(true)
		self.node_list["BgSize"].rect.sizeDelta = Vector3(729.4, 438.1, 0)
	end
end

function TipsSpiritAptitudeView:DisposeNeedText(data, color)
	data = ToColorStr(string.format(Language.Activity.XXLevel, data), color)
	return data
end

function TipsSpiritAptitudeView:LoadEffect(index, itemdata, model_root)
	if self.modle_effect[index] then
		ResMgr:Destroy(self.modle_effect[index])
		self.modle_effect[index] = nil
	end

	if itemdata and itemdata ~= "" then
		local async_loader = AllocAsyncLoader(self, "effect_loader_" .. index)
		local bundle_name, asset_name = ResPath.GetUiJingLingMingHunResid(itemdata)
		async_loader:Load(bundle_name, asset_name, function (obj)
			if IsNil(obj) then
				return
			end
			
			obj.transform:SetParent(model_root.transform, false)
			self.modle_effect[index] = obj.gameObject
		end)
	end
end