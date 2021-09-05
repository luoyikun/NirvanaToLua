GuildNoticeView = GuildNoticeView or BaseClass(BaseView)

function GuildNoticeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/guildview_prefab", "NoticeWindow"},
	}
	self.is_modal = true
	self.is_any_click_close = true
end

-- 打开操作面板
function GuildNoticeView:LoadCallBack()
	-- self.node_list["BtnCloseNotice"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["ButtonPublish"].button:AddClickListener(BindTool.Bind(self.OnNoticeChange, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.node_list["Txt"].text.text = Language.Guild.ChangeMessage
	self.node_list["Bg"].rect.sizeDelta = Vector3(520, 460, 0)
end

function GuildNoticeView:__delate()
end

function GuildNoticeView:OpenCallBack()
	self:Flush()
end

function GuildNoticeView:OnFlush(param)
	self.node_list["InputField"]:GetComponent("InputField").text = GuildDataConst.GUILDVO.guild_notice
end

-- 更改公告
function GuildNoticeView:OnNoticeChange()
	local notice = self.node_list["InputField"]:GetComponent("InputField").text
	if(notice == "") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEmptyContent)
		return
	end
	if ChatFilter.Instance:IsIllegal(notice, false) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ContentUnlawful)
		return
	end
	notice = ChatFilter.Instance:Filter(notice)
	GuildCtrl.Instance:SendGuildChangeNoticeReq(notice)
	GuildCtrl.Instance:SendGuildInfoReq()
end
