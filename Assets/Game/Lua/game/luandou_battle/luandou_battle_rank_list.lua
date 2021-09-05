LuanDouRankList = LuanDouRankList or BaseClass(BaseView)
-- local NUM = 4
local ListNum = 6
function LuanDouRankList:__init()
	self.ui_config = {
		{"uis/views/luandoubattleview_prefab", "LuanDouRankList"}
	}
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true
	self.is_modal = true
end

function LuanDouRankList:ReleaseCallBack()
	for k,v in pairs(self.hurt_rank_list) do
		v:DeleteMe()
	end
	self.hurt_rank_list = nil

	self.hurt_data_list = nil

	if self.my_rank then
		self.my_rank:DeleteMe()
		self.my_rank = nil
	end
end

function LuanDouRankList:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.hurt_rank_list = {}
	self.hurt_data_list = {}
	local list_simple_delegate_free = self.node_list["Scroller"].list_simple_delegate
	list_simple_delegate_free.NumberOfCellsDel = BindTool.Bind(self.GetCellNumberHurt, self)
	list_simple_delegate_free.CellRefreshDel = BindTool.Bind(self.CellRefreshHurt, self)

	self.my_rank = LuanDouMyRank.New(self.node_list["RankSelf"])
end

function LuanDouRankList:OnFlush()
	self.node_list["Scroller"].scroller:ReloadData(0)
	local info = LuanDouBattleData.Instance:GetRoleInfo()
	self.node_list["LunNum"].text.text = string.format(Language.LuanDouBattle.Rank2, info.turn)
	self:FlushMyRank()
end

function LuanDouRankList:CloseView()
	self:Close()
end

function LuanDouRankList:GetCellNumberHurt()
	local hurt_data = LuanDouBattleData.Instance:GetHurtRankInfo()
	if #hurt_data < ListNum then
		return #hurt_data
	else
		return ListNum
	end
end

function LuanDouRankList:FlushMyRank()
	if self.my_rank then
		self.my_rank:Flush()
	end
end

function LuanDouRankList:CellRefreshHurt(cell, data_index)
	data_index = data_index + 1
	local hurt_rank_cell = self.hurt_rank_list[cell]
	if nil == hurt_rank_cell then
		hurt_rank_cell = HurtRankCell.New(cell.gameObject)
		self.hurt_rank_list[cell] = hurt_rank_cell
	end
	local hurt_data = LuanDouBattleData.Instance:GetHurtRankInfo()
	if hurt_data[data_index] then
		self.hurt_data_list[data_index] = hurt_data[data_index]
	end
	local data = self.hurt_data_list[data_index]
	hurt_rank_cell:SetData(data_index, data)
end

function LuanDouRankList:CloseView()
	self:Close()
end
-----------------------------------------------------------------------------
------------------------排行ItemRender---------------------------------------
-----------------------------------------------------------------------------
-- 伤害排行单元
HurtRankCell = HurtRankCell or BaseClass(BaseCell)
function HurtRankCell:__init()

end

function HurtRankCell:__delete()

end

function HurtRankCell:SetData(rank, data)
	if not data then
		return
	end
	self.node_list["TxtName"].text.text = data.user_name
	self.node_list["TxtHurt"].text.text = data.hurt_per .. "%"
	if rank < 4 then
		local bundle, asset = ResPath.GetRankIcon(rank)
		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["ImgIcon"].image:LoadSprite(bundle, asset, function () self.node_list["ImgIcon"].image:SetNativeSize() end)
		self.node_list["TxtRank"]:SetActive(false)
	else
		self.node_list["ImgIcon"]:SetActive(false)
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["TxtRank"].text.text = rank
	end
end

function HurtRankCell:OnFlush()
	-- local rank_is_self = (self.data.user_name == GameVoManager.Instance:GetMainRoleVo().name)
	-- self.node_list["ImgSelfLayer"]:SetActive(rank_is_self)
end

LuanDouMyRank = LuanDouMyRank or BaseClass(BaseCell)
function LuanDouMyRank:__init()

end

function LuanDouMyRank:__delete()

end

function LuanDouMyRank:OnFlush()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["Name"].text.text = vo.name
	local score = 0
	local rank = 0
	local hurt_list = LuanDouBattleData.Instance:GetHurtRankInfo()
	if hurt_list then
		for k,v in pairs(hurt_list) do
			if v.user_key == vo.role_id or v.user_name == vo.name then
				rank = k
				score = v.hurt_per
			end
		end
	end

	self.node_list["Score"].text.text = score > 0 and score .. "%" or 0
	if rank < 4 and rank > 0 then
		local bundle, asset = ResPath.GetRankIcon(rank)
		self.node_list["RankImage1"]:SetActive(true)
		self.node_list["RankImage1"].image:LoadSprite(bundle, asset, function () self.node_list["RankImage1"].image:SetNativeSize() end)
		self.node_list["Rank"]:SetActive(false)
	elseif rank >= 4 then
		self.node_list["RankImage1"]:SetActive(false)
		self.node_list["Rank"]:SetActive(true)
		self.node_list["Rank"].text.text = rank
	else
		self.node_list["RankImage1"]:SetActive(false)
		self.node_list["Rank"]:SetActive(true)
		self.node_list["Rank"].text.text = Language.Guild.NoOpponentGuild
	end
end

