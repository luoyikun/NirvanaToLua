-- H-黄金会员.xls
return {
goldvip_active={
{}},

goldvip_shop={
{limit_times=9999,},
{seq=1,limit_times=9999,consume_val=30,reward_item={item_id=27279,num=1,is_bind=1},},
{seq=2,limit_times=3,consume_val=100,reward_item={item_id=22026,num=1,is_bind=1},},
{seq=3,limit_times=2,consume_val=200,reward_item={item_id=28522,num=1,is_bind=1},},
{seq=4,limit_times=2,consume_val=500,reward_item={item_id=28524,num=1,is_bind=1},},
{seq=5,consume_val=1500,reward_item={item_id=26150,num=1,is_bind=1},},
{seq=6,consume_val=3000,reward_item={item_id=26151,num=1,is_bind=1},},
{seq=7,consume_val=8000,reward_item={item_id=22305,num=1,is_bind=1},},
{seq=8,consume_val=10000,reward_item={item_id=22355,num=1,is_bind=1},}},

multiple_cfg={
{times_max=10,},
{times_min=11,times_max=20,price_multile=2,},
{times_min=21,times_max=30,price_multile=4,},
{times_min=31,times_max=40,price_multile=8,},
{times_min=41,times_max=9999,price_multile=16,},
{shop_seq=1,times_max=5,},
{shop_seq=1,times_min=6,times_max=10,price_multile=2,},
{shop_seq=1,times_min=11,times_max=15,price_multile=4,},
{shop_seq=1,times_min=16,times_max=20,price_multile=8,},
{shop_seq=1,times_min=21,times_max=9999,price_multile=16,},
{shop_seq=2,times_max=3,},
{shop_seq=3,times_max=2,},
{shop_seq=4,times_max=2,},
{shop_seq=5,},
{shop_seq=6,},
{shop_seq=7,},
{shop_seq=8,}},

goldvip_active_default_table={need_level=110,convert_rate=10,need_gold=388,return_gold=388,kill_monster_exp_add_per=5000,gold_vip_title_id=4000,continue_days=99999,active_convert_gold=100,title_zhanli=2500,count_down=7,},

goldvip_shop_default_table={seq=0,limit_times=1,consume_type=1,consume_val=15,reward_item={item_id=28521,num=1,is_bind=1},},

multiple_cfg_default_table={shop_seq=0,times_min=1,times_max=1,price_multile=1,}

}

