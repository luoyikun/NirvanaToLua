KaifuActivityJuBaoPen = KaifuActivityJuBaoPen or BaseClass(BaseRender)

local POINTER_ANGLE_LIST = {
	[1] = 0,
	[2] = -45,
	[3] = -90,
	[4] = -135,
	[5] = -180,
	[6] = -225,
	[7] = -270,
	[8] = -315,
}

local RAND_ACTIVITY_COLLECT_TREASURE_MAX_RECORD_COUNT = 10--最大抽奖信息条数


-- local RA_COLLECT_TREASURE_OPERA_TYPE = {
-- 	RA_COLLECT_TREASURE_OPERA_TYPE_INFO = 0,	-- 信息
-- 	RA_COLLECT_TREASURE_OPERA_TYPE_ROLL = 1,		-- 开始摇奖
-- 	RA_COLLECT_TREASURE_OPERA_TYPE_REWARD = 2,		-- 获取奖励
-- }

--[[
function KaifuActivityJuBaoPen:

end
--]]

function KaifuActivityJuBaoPen:__init()
	for i = 0, 7 do
		local cfg = KaifuActivityData.Instance:GetJuBaoPenCfgByIndex(i + 1)
		if nil == cfg then return end

		local bundle, asset = ResPath.GetOpenGameActivityRes("yuanbao" .. cfg.pic_level)
		self.node_list["Item" .. i].image:LoadSprite(bundle, asset)
		self.node_list["TxtItem" .. i].text.text = string.format(Language.Activity.JuBaoPenItemTxt, cfg.units_digit)
	end
	self.node_list["ImgSelect"]:SetActive(false)
end

function KaifuActivityJuBaoPen:LoadCallBack()
	self:SendInfo(RA_COLLECT_TREASURE_OPERA_TYPE.RA_COLLECT_TREASURE_OPERA_TYPE_INFO)
	self.txt_cell_list = {}

	local toggle_list_delegate = self.node_list["ListView"].list_simple_delegate
	toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnStartChou"].button:AddClickListener(BindTool.Bind(self.SendChoujiang, self))
end

function KaifuActivityJuBaoPen:__delete()
	for k, v in pairs(self.txt_cell_list) do
		v:DeleteMe()
	end
	self.txt_cell_list = {}
end

function KaifuActivityJuBaoPen:GetNumberOfCells()
	return RAND_ACTIVITY_COLLECT_TREASURE_MAX_RECORD_COUNT
end

function KaifuActivityJuBaoPen:RefreshCell(cell, cell_index)
	local info = KaifuActivityData.Instance:GetJuBaoPenInfo()
	if nil == info then return end

	local txt_cell = self.txt_cell_list[cell]
	if nil == txt_cell then
		txt_cell = JuBaoPenText.New(cell.gameObject)
		self.txt_cell_list[cell] = txt_cell
	end
	txt_cell:SetData(info.join_record_list[cell_index + 1])
end

function KaifuActivityJuBaoPen:OnFlush()
	self:FlushUI()
end

function KaifuActivityJuBaoPen:OpenCallBack()
	self:SendInfo(RA_COLLECT_TREASURE_OPERA_TYPE.RA_COLLECT_TREASURE_OPERA_TYPE_INFO)
end

function KaifuActivityJuBaoPen:FlushUI()
	local info = KaifuActivityData.Instance:GetJuBaoPenInfo()
	if nil == info then return end

	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	self.node_list["TxtNum"].text.text = info.left_roll_times
end

function KaifuActivityJuBaoPen:SendInfo(opera_type)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JUBAOPEN, opera_type)
end

function KaifuActivityJuBaoPen:SendChoujiang()
	if self.is_rolling then return end

	self:SendInfo(RA_COLLECT_TREASURE_OPERA_TYPE.RA_COLLECT_TREASURE_OPERA_TYPE_ROLL)
	local info = KaifuActivityData.Instance:GetJuBaoPenInfo()
	if info.left_roll_times > 0 then
		self:TurnCell()
	end
end

function KaifuActivityJuBaoPen:TurnCell()
	if self.is_rolling then return end

	self.is_rolling = true
	self.node_list["ImgSelect"]:SetActive(false)
	local time = 0
	local tween = self.node_list["NodeZhen"].transform:DORotate(Vector3(0, 0, -360 * 20), 20, DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function()
		time = time + UnityEngine.Time.deltaTime
		if time >= 2 then
			tween:Kill()
		end
	end)

	tween:OnKill(function()
		local reward = KaifuActivityData.Instance:GetJuBaoPenResult()
		local angle = POINTER_ANGLE_LIST[reward + 1]
		local tween1 = self.node_list["NodeZhen"].transform:DORotate(Vector3(0, 0, -360 * 3 + angle), 2, DG.Tweening.RotateMode.FastBeyond360)
		tween1:OnComplete(function()
				self.node_list["NodeChoujiang"].transform.eulerAngles = self.node_list["NodeZhen"].transform.eulerAngles
				self.node_list["ImgSelect"]:SetActive(true)
				self.is_rolling = false
				self:SendInfo(RA_COLLECT_TREASURE_OPERA_TYPE.RA_COLLECT_TREASURE_OPERA_TYPE_REWARD)
				self:SendInfo(RA_COLLECT_TREASURE_OPERA_TYPE.RA_COLLECT_TREASURE_OPERA_TYPE_INFO)
			end)
	end)
end


JuBaoPenText = JuBaoPenText or BaseClass(BaseCell)
function JuBaoPenText:OnFlush()
	if self.data then
		local str = string.format(Language.Activity.JuBaoPenMingDanTxt, self.data.name, self.data.roll_mul)
		RichTextUtil.ParseRichText(self.node_list["TxtGongxi"].rich_text, str, 22)
	else
		self.node_list["TxtGongxi"].text.text = ""
	end
end