SecretBossView = SecretBossView or BaseClass(BaseRender)

function SecretBossView:__init()
    self.boss_data = {}
    self.select_scene_id = 1250 -- 场景id
    self.select_boss_id = 10-- 选中的bossid
    self.cell_list = {}
    self.list_view_delegate = self.node_list["BossList"].list_simple_delegate

    self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)


    self.node_list["BtnToAttach"].button:AddClickListener(BindTool.Bind(self.ToActtack, self))
    self.node_list["BtnQuestion"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
    self.node_list["BtnInfo"].button:AddClickListener(BindTool.Bind(self.OpenBossInfo, self))
    self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OpenKillRecord, self))
    self.node_list["BtnQuick"].button:AddClickListener(BindTool.Bind(self.OnClickQuick, self))
    self.model_view = RoleModel.New()
    self.model_view:SetDisplay(self.node_list["display"].ui3d_display)
end

function SecretBossView:__delete()
    if self.model_view then
        self.model_view:DeleteMe()
        self.model_view = nil
    end

    for _, v in pairs(self.cell_list) do
        if v then
            v:DeleteMe()
        end
    end
    
    self.cell_list = {}
    self.is_show = nil
end

function SecretBossView:InitView()
end

function SecretBossView:FlushBossView()
    BossData.Instance:SecretBossRedPointTimer(false)
    BossCtrl.Instance:SetTimer()
    local boss_list,dead_boss = BossData.Instance:GetSecretBossList()
    self.select_boss_id = boss_list[1] and boss_list[1].monster_id or 10
    self:FlushBossList()
    self:FlushInfoList()

    local level = PlayerData.Instance:GetRoleVo().level
    local other_cfg = BossData.Instance:GetSecretOtherCfg()
    local num = BossData.Instance:GetTaskNum()
    if level >= other_cfg.skip_task_limit_level and  num > 0 then 
        self.node_list["BtnQuick"]:SetActive(true)
        UI:SetGraphicGrey(self.node_list["TxtShow"], false)
    else
        self.node_list["BtnQuick"]:SetActive(false)
        UI:SetGraphicGrey(self.node_list["TxtShow"], true)
    end

end

function SecretBossView:GetNumberOfCells()
    return #BossData.Instance:GetSecretBossList() or 0
end

function SecretBossView:RefreshView(cell, data_index)
    data_index = data_index + 1

    local boss_cell = self.cell_list[cell]
    if boss_cell == nil then
        boss_cell = SecretBossItem.New(cell.gameObject)
        boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
        boss_cell.boss_view = self
        self.cell_list[cell] = boss_cell
    end
    boss_cell:SetIndex(data_index)
    boss_cell:SetData(self.boss_data[data_index])
end

function SecretBossView:FlushBossList()
    local boss_list = BossData.Instance:GetSecretBossList()
    if #boss_list > 0 then
        for i = 1, #boss_list do
            self.boss_data[i] = boss_list[i]
        end
    end

    self.node_list["BossList"].scroller:ReloadData(0)

    local total_boss_num = #boss_list
    local boss_num = BossData.Instance:GetSecretBossNum()
    local color = boss_num > 0 and COLOR.WHITE or COLOR.RED_4
    self.node_list["TxtBOSSNum"].text.text = string.format(Language.Boss.BossActiveHaveBoss, ToColorStr(boss_num, color) .. "/" .. ToColorStr(total_boss_num, COLOR.WHITE))
end

function SecretBossView:FlushModel()
    if self.model_view == nil then
        return
    end
    if self.node_list["display"].gameObject.activeInHierarchy then
        local res_id = BossData.Instance:GetMonsterInfo(self.select_boss_id).resid
        self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
        self.model_view:SetTrigger(ANIMATOR_PARAM.REST1)
    end
end

function SecretBossView:ToActtack()
    if not BossData.Instance:GetCanGoAttack() then
        TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
        return
    end
    if self.select_scene_id == 0 then
        SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
        return
    end
    ViewManager.Instance:CloseAll()
    BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
    BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS, self.select_scene_id)
end


function SecretBossView:QuestionClick()
    local tips_id = 214
    TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


function SecretBossView:OpenBossInfo()
    ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_xianjing)
end

function SecretBossView:OpenKillRecord()
    BossCtrl.SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS, self.select_boss_id, self.select_scene_id)
end

function SecretBossView:GetSelectIndex()
    return self.select_index or 1
end

function SecretBossView:SetSelectIndex(index)
    if index then
        self.select_index = index
    end
end

function SecretBossView:SetSelectBossId(boss_id)
    self.select_boss_id = boss_id
end

function SecretBossView:FlushAllHL()
    for k, v in pairs(self.cell_list) do
        v:FlushHL()
    end
end

function SecretBossView:FlushInfoList()
    if self.select_boss_id ~= 0 then
        self:FlushModel()
    end
end

function SecretBossView:OnClickQuick()
    local skip_task_consume = BossData.Instance:GetSecretOtherCfg().skip_task_consume
    local num = BossData.Instance:GetTaskNum()
    local gold = num * skip_task_consume
    local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_PRECIOUS_BOSS], gold, num)

    local ok_callback = function ()
        MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_PRECIOUS_BOSS, -1)
    end
    
    TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, true, nil, nil)
end
------------------------------------------------------------------------------
SecretBossItem = SecretBossItem or BaseClass(BaseCell)

function SecretBossItem:__init()
    self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function SecretBossItem:__delete()
    if self.time_coundown then
        GlobalTimerQuest:CancelQuest(self.time_coundown)
        self.time_coundown = nil
    end
end

function SecretBossItem:ClickItem(is_click)
    if is_click then
        self.root_node.toggle.isOn = true
        local select_index = self.boss_view:GetSelectIndex()
        self.boss_view:SetSelectIndex(self.index)
        self.boss_view:SetSelectBossId(self.data.monster_id)
        self.boss_view:FlushAllHL()
        if self.data == nil or select_index == self.index then
            return
        end
        self.boss_view:FlushInfoList()
    end
end

function SecretBossItem:OnFlush()
    if not self.data then return end
    self.root_node.toggle.isOn = false
    local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
    if monster_cfg then
        self.node_list["ImgName"].text.text =  monster_cfg.name
        self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, monster_cfg.level)
        local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
        self.node_list["image"].raw_image:LoadSprite(bundle, asset)
    end
    self.next_refresh_time = BossData.Instance:GetItemStatusById(self.data.monster_id)
    local diff_time = self.next_refresh_time - TimeCtrl.Instance:GetServerTime()
    if diff_time <= 0 then
        self.node_list["ImgKiller"]:SetActive(false)
        if self.time_coundown then
            GlobalTimerQuest:CancelQuest(self.time_coundown)
            self.time_coundown = nil
        end
        self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN_4)
    else
        self.node_list["ImgKiller"]:SetActive(true)
        if nil == self.time_coundown then
            self.time_coundown = GlobalTimerQuest:AddTimesTimer(
            BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
            self:OnBossUpdate()
        end
        self:OnBossUpdate()
    end
    self:FlushHL()
end

function SecretBossItem:OnBossUpdate()
    local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
    self.node_list["TxtRefreshTime"].text.text = ToColorStr(TimeUtil.FormatSecond(time, 3), TEXT_COLOR.RED_4)
    if time <= 0 then

        self.node_list["ImgKiller"]:SetActive(false)
        self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN_4)
    else
        self.node_list["ImgKiller"]:SetActive(true)
        self.node_list["TxtRefreshTime"].text.text = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED_4)
    end
end

function SecretBossItem:FlushHL()
    local select_index = self.boss_view:GetSelectIndex()
    self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end


