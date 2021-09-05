 ZhiZunLingPaiData = ZhiZunLingPaiData or BaseClass()

function ZhiZunLingPaiData:__init()
	if ZhiZunLingPaiData.Instance then
		print_error("[ZhiZunLingPaiData] Attempt to create singleton twice!")
		return
	end
	ZhiZunLingPaiData.Instance = self

	self.kuafu_3v3_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_tvt_auto")

 end

function ZhiZunLingPaiData:__delete()
	ZhiZunLingPaiData.Instance = nil
end

 function ZhiZunLingPaiData:GetCardShowByIndex(index)
 	for k,v in pairs(self.kuafu_3v3_cfg.xndex) do
 		if v.seq == index then
 			return v.img_pic
 		end
 	end
 end

 function ZhiZunLingPaiData:GetCardShowCount()
 	return #self.kuafu_3v3_cfg.xndex
 end

function ZhiZunLingPaiData:GetSeasonCardItemCfg(season,grade)
	local cfg = self.kuafu_3v3_cfg.season_card
	for k,v in pairs(cfg) do
		if v.season == season and v.grade == grade then
			return v
		end
	end
end

function ZhiZunLingPaiData:GetSeasonCardItemAttr(season,grade)
	local cfg = self:GetSeasonCardItemCfg(season,grade)
	local attr = CommonDataManager.GetAttributteByClass(cfg)
	local data = {}
	if attr.max_hp and attr.max_hp > 0 then
		table.insert(data, {name = "max_hp",value = attr.max_hp})
	end
	if attr.gong_ji and attr.gong_ji > 0 then
		table.insert(data, {name = "gong_ji",value = attr.gong_ji})
	end
	if attr.fang_yu and attr.fang_yu > 0 then
		table.insert(data, {name = "fang_yu",value = attr.fang_yu})
	end
	if attr.pvp_zengshang and attr.pvp_zengshang > 0 then
		table.insert(data, {name = "pvp_zengshang",value = attr.pvp_zengshang / 100 .. "%"})
	end
	if attr.pvp_jianshang and attr.pvp_jianshang > 0 then
		table.insert(data, {name = "pvp_jianshang",value = attr.pvp_jianshang / 100 .. "%"})
	end
	return data
end

--使用了那个赛季的戒指
function ZhiZunLingPaiData:GetUseCardData()
	return KuafuPVPData.Instance:GetUseCardData()
end

function ZhiZunLingPaiData:GetCurSeason()
	return KuafuPVPData.Instance:GetCurSeason()
end

function ZhiZunLingPaiData:GetHaveCardData()
	return KuafuPVPData.Instance:GetHaveCardData()
end

--根据赛季获取戒指  获取戒指的段位 0表示空
function ZhiZunLingPaiData:GetCardIsHaveGrande(season)
	local data = self:GetHaveCardData()
	return data[season]
end

function ZhiZunLingPaiData:GetUseCardBySeason(season)
	local data = self:GetUseCardData()
	for k,v in pairs(data) do
		if v == season then
			return true
		end
	end
	return false
end

function ZhiZunLingPaiData:GetSeasonShowCfg(season)
	local cfg = self.kuafu_3v3_cfg.season_card
	for k,v in pairs(cfg) do
		if v.season_show == season then
			return v
		end
	end
end