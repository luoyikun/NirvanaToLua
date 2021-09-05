require("game/guild_fight/guild_fight_reward_view")


GuildFightRankView = GuildFightRankView or BaseClass(BaseView)

function GuildFightRankView:__init()
	self.ui_config = {{"uis/views/guildfight_prefab", "RankPanel"}}
	self.camera_mode = UICameraMode.UICameraLow

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GuildFightRankView:__delete()

end

function GuildFightRankView:LoadCallBack()
	self.rank_info = {}
	for i = 1, 10 do
		local name_table = self.node_list["Info" .. i]:GetComponent(typeof(UINameTable))
		local info_node_list = U3DNodeList(name_table)
		self.rank_info[i] = {}
		self.rank_info[i].name = info_node_list["Name"]
		self.rank_info[i].grade = info_node_list["Score"]
	end
	self.my_rank = GuildMyRankCell.New(self.node_list["MyInfo"])

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseRank, self))
end

function GuildFightRankView:ReleaseCallBack()
	if self.my_rank then
		self.my_rank:DeleteMe()
		self.my_rank = nil
	end
end

function GuildFightRankView:OnFlush(param_t)
	self:FlushRank()
end

function GuildFightRankView:OpenCallBack()
	self:FlushRank()
	self.node_list["Panel"].list_page_scroll2:JumpToPageImmidate(0)
end

function GuildFightRankView:CloseRank()
	self:Close()
end

function GuildFightRankView:FlushRank()
	local global_info = GuildFightData.Instance:GetGlobalInfo()
	local guild_name = GuildDataConst.GUILDVO.guild_name
	for i = 1, global_info.rank_count do
		local info = global_info.rank_list[i]
		if info then
			self.rank_info[i].name.text.text = info.guild_name
			self.rank_info[i].grade.text.text = info.score
		end
	end

	for i = global_info.rank_count + 1, 10 do
		self.rank_info[i].name.text.text = Language.Common.ZanWu
		self.rank_info[i].grade.text.text = 0
	end
	self.my_rank:Flush()
end

----------------------------------------------GuildMyRankCell--------------------------------------------
GuildMyRankCell = GuildMyRankCell or BaseClass(BaseCell)

function GuildMyRankCell:LoadCallBack( )

end
function GuildMyRankCell:OnFlush()
	local global_info = GuildFightData.Instance:GetGlobalInfo()
	local guild_name = GuildDataConst.GUILDVO.guild_name
	local my_rank =  GuildFightData.Instance:GetMyRank(guild_name)
	if nil == my_rank then
		return
	end

	self.node_list["Name"].text.text = guild_name
	self.node_list["Score"].text.text = global_info.guild_score

	if my_rank > 0 and my_rank <= 3 then
		local bundle, asset = ResPath.GetRankIcon(my_rank)
		self.node_list["RankImage1"].image:LoadSprite(bundle, asset)
		self.node_list["RankImage1"]:SetActive(true)
		self.node_list["Rank"]:SetActive(false)
	elseif my_rank == 0 then
		self.node_list["Rank"].text.text = Language.Guild.NoOpponentGuild
		self.node_list["RankImage1"]:SetActive(false)
	else
		self.node_list["Rank"].text.text = my_rank
		self.node_list["RankImage1"]:SetActive(false)
	end
end
