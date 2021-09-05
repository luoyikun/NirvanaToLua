require("game/tips/tips_baoji_view")

TipsBaojiviewManager = TipsBaojiviewManager or BaseClass()

function TipsBaojiviewManager:__init()
	if TipsBaojiviewManager.Instance ~= nil then
		error("[TipsBaojiviewManager] attempt to create singleton twice!")
		return
	end
	TipsBaojiviewManager.Instance = self
	self.system_tips = TipsSystemView.New()
	self.list = {}
	self.tips_list = {}
	self.index = 1
end

function TipsBaojiviewManager:__delete()
	self.list = {}
	for k,v in pairs(self.tips_list) do
		v:DeleteMe()
	end
	self.tips_list= {}
	if self.system_tips ~= nil then
		self.system_tips:DeleteMe()
		self.system_tips = nil
	end

	TipsBaojiviewManager.Instance = nil
end

function TipsBaojiviewManager:ShowSystemTips(advance_type)
	if #self.list >= 5 then
		table.remove(self.list, 1)
	end
	table.insert(self.list, advance_type)
	self:UpdateTips()
end

function TipsBaojiviewManager:CreateTip(advance_type)
	local tips_cell = TipsBaoJiView.New()
	self.tips_list[self.index] = tips_cell
	tips_cell:Show(advance_type)
end

function TipsBaojiviewManager:UpdateTips()
	local tips_cell = self.tips_list[self.index]
	if tips_cell then
		tips_cell:Close()
		tips_cell:Show(self.list[self.index])
	else
		self:CreateTip(self.list[self.index])
	end

	self.index = self.index + 1
	if self.index > 5 then
		self.index = 1
	end
	table.remove(self.list, 1)
end