return {
	budget_cfg = {
		{min_fps = 25, budget = 1000},
		{min_fps = 30, budget = 2000},
		{min_fps = 35, budget = 2500},
	},
	
	payloads_cfg = {
		{obj_type = 6,  part = 0, payload = 500, priority = 1},				--服务端场景特效

		{obj_type = 30, part = 6, payload = 400, priority = 2},				--精灵-光环

		{obj_type = 1,  part = 8, payload = 200, priority = 3},				--其他角色-宝具
		{obj_type = 1,  part = 6, payload = 400, priority = 4},				--其他角色-光环
		{obj_type = 1,  part = 3, payload = 400, priority = 5},				--其他角色-羽羽

		{obj_type = 20, part = 8, payload = 500, priority = 7},				--主角-宝具
		{obj_type = 20, part = 6, payload = 500, priority = 8},				--主角-光环
		{obj_type = 20, part = 9, payload = 500, priority = 9},				--主角-披风
	},
}