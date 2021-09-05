ActiviteHongBaoView = ActiviteHongBaoView or BaseClass(BaseView)
local PANEL_NUM = 3
function ActiviteHongBaoView:__init()
	self.ui_config = {{"uis/views/serveractivity/openserverredpacket_prefab", "OpenServerRedPack"}}
	self.play_audio = true
end

function ActiviteHongBaoView:__delete()

end

function ActiviteHongBaoView:CloseCallBack()

end

function ActiviteHongBaoView:LoadCallBack()
	self.node_list["BG"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnClickGetDiamon"].button:AddClickListener(BindTool.Bind(self.OnClickGetDiamon, self))
end

function ActiviteHongBaoView:ReleaseCallBack()
end

function ActiviteHongBaoView:OpenCallBack()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local total_day = GameEnum.NEW_SERVER_DAYS - open_day + 1 			-- 剩余天数
	self.node_list["CloseTimeTxt"].text.text = string.format(Language.ActHongBao.NeedDay, total_day)

	if open_day > GameEnum.NEW_SERVER_DAYS then
		self:ShowView(2)
		self.node_list["TitleTxt"].text.text = Language.ActHongBao.TitleHongBao
	else
		self:ShowView(1)
		self.node_list["TitleTxt"].text.text = Language.ActHongBao.TitleReturn
	end
	self:Flush()
end

function ActiviteHongBaoView:OnFlush()
	local return_percent = ActiviteHongBaoData.Instance:GetReturnPercent()
	local get_diamond_num = math.floor(ActiviteHongBaoData.Instance:GetDiamondNum() * return_percent * 0.01)
	local reward_ser = string.format(Language.ActHongBao.RewardDesc, return_percent)

	self.node_list["GetDiamondTxt"].text.text = get_diamond_num
	self.node_list["GetDiamondTxt2"].text.text = get_diamond_num
	self.node_list["RewardText"].text.text = reward_ser
	local flag = ActiviteHongBaoData.Instance:GetFlag()
	if flag == ActHongBaoFlag.HasGet then
		self:ShowView(3)
	end
end

function ActiviteHongBaoView:ShowView(index)
	for i = 1, PANEL_NUM do
		if i == index then
			self.node_list["panel" .. i]:SetActive(true)
		else
			self.node_list["panel" .. i]:SetActive(false)
		end
	end
end

function ActiviteHongBaoView:OnClickClose()
	self:Close()
end

function ActiviteHongBaoView:OnClickGetDiamon()
end