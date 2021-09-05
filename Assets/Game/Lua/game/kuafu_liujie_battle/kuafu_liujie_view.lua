require("game/kuafu_liujie_battle/kuafu_liujie_bossinfo_view")
require("game/kuafu_liujie_battle/kuafu_liujie_showinfo_view")
require("game/kuafu_liujie_battle/kuafu_liujieinfo_view")

KuafuGuildBattleView = KuafuGuildBattleView or BaseClass(BaseView)
--地图信息顺序：1，2，3，4，5，6 2为主城
--任务信息顺序：0，1，2，3，4，5 0为主城
local Task_Map_Index = 
{
	[1] = 1,
	[2] = 0,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 5,
}

function KuafuGuildBattleView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/kuafuliujie_prefab", "KuaFULiuJieView", {TabIndex.kuafu_liujie}},
		{"uis/views/kuafuliujie_prefab","BossInfo", {TabIndex.liujie_bossinfo}},
		{"uis/views/kuafuliujie_prefab","ShowInfo", {TabIndex.liujie_show}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.full_screen = true
	self.def_index = TabIndex.kuafu_liujie
	self.play_audio = true
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
end

function KuafuGuildBattleView:__delete()

end

function KuafuGuildBattleView:CloseCallBack()
	if self.open_trigger then
		GlobalEventSystem:UnBind(self.open_trigger)
		self.open_trigger = nil
	end
end

function KuafuGuildBattleView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function KuafuGuildBattleView:LoadCallBack()
	local tab_cfg = {
		{name = Language.KuafuGuildBattle.TabbarName[1],  bundle = "uis/images_atlas", asset = "jianhuibafang_jianzhitianxia", tab_index = TabIndex.kuafu_liujie, remind_id = RemindName.ShowKfBattleRemind,},
		{name = Language.KuafuGuildBattle.TabbarName[3],  bundle = "uis/images_atlas", asset = "jianhuibafang_tianxiawushuang", tab_index = TabIndex.liujie_show},
		{name = Language.KuafuGuildBattle.TabbarName[2],  bundle = "uis/images_atlas", asset = "jianhuibafang_chumo", tab_index = TabIndex.liujie_bossinfo, remind_id = RemindName.ShowKfBattleBossRemind},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["TxtTitle"].text.text = Language.KuafuGuildBattle.TitleName

	self.cur_index = 0
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self:SetBg()
	self.node_list["GoldNode"]:SetActive(false)
	self.node_list["BindGoldNode"]:SetActive(false)
end

function KuafuGuildBattleView:SetBg(index)
	local call_back = function (enable)
		self.node_list["UnderBg"]:SetActive(enable)
		self.node_list["TaiZi"]:SetActive(not enable)
	end
	if index == TabIndex.liujie_show then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/zhuanzhi_bg_1", "zhuanzhi_bg_1.jpg", call_back(true))
	else
		call_back(false)
	end
end

function KuafuGuildBattleView:ReleaseCallBack()
	if self.liujie_panel then
		self.liujie_panel:DeleteMe()
		self.liujie_panel = nil
	end
	if self.boss_info_panel then
		self.boss_info_panel:DeleteMe()
		self.boss_info_panel = nil
	end
	if self.show_info_panel then
		self.show_info_panel:DeleteMe()
		self.show_info_panel = nil
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function KuafuGuildBattleView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "tj_boss" and self.show_index == TabIndex.activity_tj_boss then
			if self.tj_boss_view then
				self.tj_boss_view:FlushBossView()
			end
		elseif k == "sw_boss" and self.show_index == TabIndex.activity_sw_boss then
			if self.sw_boss_view then
				self.sw_boss_view:FlushBossView()
			end
		elseif k == "tuanzhan" and self.show_index == TabIndex.activity_tuanzhan then
			if self.tuanzhan_view then
				self.tuanzhan_view:Flush()
			end
		end
	end
end

function KuafuGuildBattleView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	self.cur_index = index
	if nil ~= index_nodes then
		if index == TabIndex.kuafu_liujie then
			self.liujie_panel = KuafuLiuJieInfoView.New(index_nodes["KuaFULiuJieView"])
		elseif index == TabIndex.liujie_bossinfo then
			self.boss_info_panel = KuafuLiuJieBossInfoView.New(index_nodes["BossInfo"])
			KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_BOSS_INFO, 1450)
		elseif index == TabIndex.liujie_show then
			self.show_info_panel = KuafuLiuJieShowInfoView.New(index_nodes["ShowInfo"])
		end
	end
	self:SetBg(index)
	if index == TabIndex.kuafu_liujie then
		self.liujie_panel:Flush()
	elseif index == TabIndex.liujie_bossinfo then
		KuafuGuildBattleCtrl.Instance:SendGuildBattleGetMonsterInfoReq()
		self.boss_info_panel:Flush()
	elseif index == TabIndex.liujie_show then
		self.show_info_panel:Flush()
	end
end

function KuafuGuildBattleView:CloseWindow()
	self:Close()
end

function KuafuGuildBattleView:OpenCallBack()
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
	self:Flush()
end

function KuafuGuildBattleView:FlushBossInfoView()
	if self.boss_info_panel then
		self.boss_info_panel:Flush()
	end
end

function KuafuGuildBattleView:FlushTaskInfoView()
	if self.liujie_panel then
		self.liujie_panel:Flush()
	end
end