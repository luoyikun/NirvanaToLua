JingJieData = JingJieData or BaseClass(BaseEvent)
 JingJieData.OPERA =
  {
   	PROMOTE_LEVEL = 0, -- 提升境界
   	GET_INFO = 1,
   	MAX = 2,
  }
function JingJieData:__init()
	if JingJieData.Instance then
		print_error("[JingJieData] 尝试创建第二个单例模式")
	end
	JingJieData.Instance = self
	self.jingjie_level = 0
	self.wait_time = 0
	self.jingjie_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("rolejingjie_auto").jingjie, "jingjie_level")
	RemindManager.Instance:Register(RemindName.ZhiBao_jingjie, BindTool.Bind(self.GetjingjieRemind, self))
end

function JingJieData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ZhiBao_jingjie)
	JingJieData.Instance = nil
end

function JingJieData:GetTime()
	return self.wait_time or 0
end

function JingJieData:SetTime(time)
	self.wait_time = time
end

function JingJieData:SetjingjieInfo(info)
	self.jingjie_level = info.jingjie_level
end

function JingJieData:GetjingjieLevel()
	return self.jingjie_level
end

function JingJieData:GetjingjieCfg(level)
	return self.jingjie_cfg[level]
end

function JingJieData:GetjingjieName(level)
	return self.jingjie_cfg[level] and self.jingjie_cfg[level].name or ""
end

function JingJieData:GetjingjieRemind()
	if not OpenFunData.Instance:CheckIsHide("baoju_jingjie") then
		return 0
	end
	local cfg = self.jingjie_cfg[self.jingjie_level + 1]
	if cfg then
		local num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
		local role_cap = GameVoManager.Instance:GetMainRoleVo().capability
		if role_cap >= cfg.cap_limit and num >= cfg.stuff_num then
			return 1
		end
	end
	return 0
end

function JingJieData.GetjingjieColor(level)
	return JINGJIE_COLOR[math.ceil(level / 10)] or JINGJIE_COLOR[0]
end

function JingJieData.GetjingjieNum(level)
	if level > 0 then
		local num = level % 5
		return num == 0 and 5 or num
	end
	return 0
end

function JingJieData.GetjingjieIcon(level)
	if level > 0 then
		return math.ceil(level / 5) - 1
	end
	return 0
end