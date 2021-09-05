require("game/goddess/huanhua/goddess_huanhua_view")
GoddessHuanHuaCtrl = GoddessHuanHuaCtrl or BaseClass(BaseController)

function GoddessHuanHuaCtrl:__init()
	if GoddessHuanHuaCtrl.Instance then
		return
	end
	GoddessHuanHuaCtrl.Instance = self

	self.huan_hua_view = GoddessHuanHuaView.New(ViewName.GoddessHuanHua)

end

function GoddessHuanHuaCtrl:__delete()
	if self.huan_hua_view then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	GoddessHuanHuaCtrl.Instance = nil
end

function GoddessHuanHuaCtrl:Flush()
	if self.huan_hua_view then
		self.huan_hua_view:Flush()
	end
end

function GoddessHuanHuaCtrl:FlushView(...)
	if self.huan_hua_view then
		self.huan_hua_view:Flush(...)
	end
end

-- 获取幻化视图
function GoddessHuanHuaCtrl:GoddessHuanHuaView()
	return self.huan_hua_view
end
