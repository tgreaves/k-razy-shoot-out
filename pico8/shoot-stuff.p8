pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- todo
-- player takes damage from enemy bullets
-- player takes damage from falling fireballs 
-- lrge takes damage from crates and fireballs
-- create win screen for beating the game
-- create lose screen with a reason why the player lost

	 
scrn={}

width = 127
height = 127
starfield_init = false

function reset()
    player = {}
    player.x = 8
    player.y = 112
    player.y_vel = 0
    player.jump_height = 40
    player.sprite = 53
    player.inv = false
    player.invt = 30
    player.trnsp = 1
    player.ammo = 20

    enemies = {}
    enemy_spwnt = 30
    enemy_t = 150

    fireball = {}
    fireball_delay = 30*30
    fireball_t = fireball_delay

    eshooter = {}
    eshooter_spwnt = 60
    eshooter_t = 300
    ebullets = {}

    lrgenemies = {}
    lrge_t = 250

    bullets = {}
    cooldown = 15
    lastpressed = 0

    gravity = 40

    clouds = {}
    clouds[1] = {x=0,y=40}
    clouds[2] = {x=64,y=32}
    clouds[3] = {x=127,y=8}

    health_crates = {}
    health_spwnt = 30*13
    health_t = health_spwnt
    hearts = {}
    health = 3

    ammo_crate = {}
    ammox = 2
    ammoy = 3

    plusone = {}
    plusfive = {}

    tshake=2
    shakedur=2

    flasht=2
    score = 0

    anim_t=0
    standing = false
end

-- main game functions --

function _init()
    main_menu()
end

function _update()
    scrn.upd()
end

function _draw()
    scrn.drw()
end

-- main menu functions --
switch_dir = false
top_fnt_y = 20
btm_fnt_y = 42

function main_menu()
    -- leaving a comment for pico!
    music(0)
    scrn.upd = menu_upd
    scrn.drw = menu_drw

    if not starfield_init then
        make_starfield_ps()
        starfield_init = true
    end
end

function menu_upd()
    update_psystems()
    text_movement()

    if(btn(5) and btn(4))then
        music(4)
        sfx(5)
        reset()
        game_init()
        scrn.upd = game_update
        scrn.drw = game_draw
    end
end

function menu_drw()
    cls()
    renderbg()
    map(0,0,0,0,16,16)
    for ps in all(particle_systems) do
        draw_ps(ps)
    end
    -- spr(64,38,5,6,2)
    zspr(64,6,2,15,top_fnt_y,2)
    zspr(70,6,2,15,btm_fnt_y,2)
    print("press x + c to play",25,80,5)
    print(thanks_msg,20,2,7)
end

function zspr(n,w,h,dx,dy,dz)
    sx = 8 * (n % 16)
    sy = 8 * flr(n / 16)
    sw = 8 * w
    sh = 8 * h
    dw = sw * dz
    dh = sh * dz
    sspr(sx,sy,sw,sh, dx,dy,dw,dh)
end

function text_movement()
    if(switch_dir)then
        top_fnt_y -=0.25
        btm_fnt_y -=0.25
    else
        top_fnt_y +=0.25
        btm_fnt_y +=0.25
    end

    if(top_fnt_y>25)then
        switch_dir = true
    elseif(top_fnt_y<20)then
        switch_dir = false
    end 
end

-- win screen --
spark_t = 0
function check_win()
    if score>=100 then
        win_screen()
    end
end

function win_screen()
    music(19)
    scrn.upd = win_upd
    scrn.drw = win_drw 
    thanks_msg = "thank you for playing!"
end

function win_upd()
    if btnp(4)then
        main_menu()
    end
    if spark_t < 15 then
        spark_t+=1
    else
        make_magicsparks_ps(rnd(107)+10,rnd(107)+10)

        make_explosion_ps(rnd(107)+10,rnd(107)+10)
        spark_t = 0
    end    
    text_movement()
    update_psystems()
end

function win_drw()
    cls()
    renderbg()
    for ps in all(particle_systems) do
        draw_ps(ps)
    end
    map(0,0,0,0,16,16)

    zspr(96,3,1,27,top_fnt_y,3)
    zspr(103,3,1,27,btm_fnt_y+5,3)
    print("press c",53,80,5)


end


-- lose screen --
lose_message = " "
function lose_screen()
    music(17)
    scrn.upd = lose_upd
    scrn.drw = lose_drw
end

function lose_upd()
    if btnp(4)then
        main_menu()
    end

    enemy_t -= 1
    lrge_t -= 1
    eshooter_t -= 1

    spawnenemy()

    spawnshooter()
    atk_countdown()

    moveenemy(enemies)
    moveenemy(eshooter)
    moveenemy(lrgenemies)

    spawnlrgenemy()

    text_movement()
    update_psystems()
end

function lose_drw()
    cls()
    renderbg()
    map(0,0,0,0,16,16)

    for ps in all(particle_systems) do
        draw_ps(ps)
    end

    zspr(96,3,1,27,top_fnt_y,3)
    zspr(99,4,1,16,btm_fnt_y+5,3)
    print(lose_message,7,2)
    print("press c",53,80,5)


    drawenemy(enemies)
    drawenemy(eshooter)
    drawlrgenemy()
end

-- main game functions --
thanks_msg = " "
function game_init()	
    for x=1,3 do
        local newx = width-(8*x)
        hearts[x] = {x=newx,y=2}
    end
end


function game_update()
    check_win()
    cooldown -= 1
    health_t -= 1
    enemy_t -= 1
    lrge_t -= 1
    eshooter_t -= 1

    tshake+=0.2

    cratecol(enemies)
    cratecol(eshooter)

    moveclouds()
    playerinput()
    playerjump()
    bulletupdate()
    spawncrate()

    spawnenemy()

    spawnshooter()
    atk_countdown()

    moveenemy(enemies)
    moveenemy(eshooter)
    moveenemy(lrgenemies)

    bulletcol(enemies,2,false)	
    bulletcol(lrgenemies,8,true)
    bulletcol(eshooter,2,false)

    enemycol(enemies,8)
    enemycol(lrgenemies,16)
    enemycol(eshooter,8)
    enemycol(fireball,8)

    update_ebullets()

    invincible()
    bullethealthcol()
    ammocol()

    spawnlrgenemy()

    move_plus(plusone,true)
    move_plus(plusfive,false)

    ammo_warning()
    update_fireball()

    if(btn(4))then
--        player.ammo=20
    end
    -- lose conditions
    ammo_check()
    check_game_over()

    -- player_anim()

    --particle system
    update_psystems()

    if(player.inv)then
        flasht -= 1
        playerflash()
    end

    if(not player.inv)then
        if(standing)then
            player.sprite = player_anim()
        else
            player.sprite = 53
        end
        flasht = 2
    end	
    score = flr(score)	
end	

function game_draw()
    cls()

    renderbg()
    drawcrates()
    drawsprites()

    drawenemy(enemies)
    drawenemy(eshooter)
    drawlrgenemy()

    spriteflip()
    drawhearts()
    drawammo()

    draw_plus(plusone)
    draw_plus(plusfive)

    foreach(enemies,drawenemyhealth)
    foreach(lrgenemies,drawenemyhealth)
    foreach(eshooter,drawenemyhealth)

    screenshake()

    for ps in all(particle_systems) do
	draw_ps(ps)
    end

    draw_ebullets()
    draw_fireball()

    map(0,0,0,0,16,16)
    print(score.."/100",53,3,7)
    print("ammo:"..player.ammo,ammox,ammoy,ammocolor)
end

-- gameplay functions --

function create_fireball()
 add(fireball, {s=58,x=flr(rnd(120)),y=-8,speed=0})
end

function update_fireball()
    fireball_t-=1

    if(fireball_t<=0)then
	create_fireball()
	fireball_t = fireball_delay
    end

    if(score>25 and score<50)then
	fireball_delay = 30*10
    end

    if(score>50 and score<75)then
	fireball_delay = 30*5
    end

    if(score>75)then
	fireball_delay = 30*2
    end

    for i,o in pairs(fireball)do
	o.y+=1
	if(o.s<60)then
	    o.s+=1
	else
	    o.s=58
	end
	if(o.y>112)then
	    sfx(7)
	    make_sparks_ps(o.x,o.y)
	    make_explosion_ps(o.x,o.y)
	    del(fireball,o)
	end
    end
end

function draw_fireball()
    for i,o in pairs(fireball)do
	spr(o.s,o.x,o.y)
    end
end

function player_anim()
    anim_t+=1
    if(anim_t>=2)then
    if(player.sprite>=53 and player.sprite<57)then
	anim_t=0
	player.sprite+=1
    elseif(player.sprite>=57)then
	anim_t=0
	player.sprite=53
    end
    end

    return player.sprite
end

function ammo_warning()
    if(player.ammo <= 5)then
	ammox = flr(rnd(2)+2)
	ammoy = flr(rnd(2)+3)
	if(ammocolor<15)then
	    ammocolor+=1
	else ammocolor=0 end
    else
	ammox=2
	ammoy=3
	ammocolor=8
    end
end

function create_plus(list,pox,poy,num)
    add(list,{x=pox,y=poy,sprnum=num})   
end

function move_plus(list,one)
    for v in all(list) do
	if(one and v.sprnum<15)then
	    v.sprnum+=1
	elseif(one and v.sprnum>13)then
	    v.sprnum-=1
	end

	if(not one and v.sprnum<50)then
	    v.sprnum+=1
	elseif(not one and v.sprnum>48)then
	    v.sprnum-=1
	end

	if(v.y>80-rnd(20))then
	    v.y-=1
	else
	    del(list,v)
	end
    end
end

function draw_plus(list)
    for i,o in pairs(list) do
	spr(o.sprnum,o.x,o.y)
    end
end

function ammo_check()
    if(player.ammo<=0 and #ammo_crate == 0) then
        lose_message = "you can't fight without ammo!"	
        lose_screen()
    end
end


function check_game_over()
    if(health<=0)then
        lose_message = "you need heart to continue..."
        lose_screen() 
    end
end

function playerflash()
    if(player.sprite~=0 and flasht>0)then
	player.sprite = 0
    end

    if(player.sprite==0 and flasht<=0)then
	flasht = 2
	player.sprite = 53
    end
end

function invincible()
    if player.inv then
	player.invt-=1
    end

    if(player.invt<=0)then
	player.inv = false
	player.invt = 30
    end
end

function screenshake()
    local dx,dy
    if tshake < shakedur then
	camera(flr(rnd(2)-1),flr(rnd(2)-1))
    end
    if tshake > shakedur then
	camera(0,0)
    end 
end

function drawenemyhealth(e)
    for i=1,e.health do
	pset(e.x+(i*2),e.y-2,3)
    end
end

function drawenemy(e)
    local i,o
    for i,o in pairs(e) do
	if(o.x<=140 and o.x>-10)then
	    spr(o.sprite,o.x,o.y)
	else del(e,o) end
    end
end

function moveenemy(e)
    local i,o
    for i,o in pairs(e) do
	o.x += o.speed
    end
end


function drawlrgenemy()
    local i,o
    for i,o in pairs(lrgenemies) do
	if(o.x<=140 and o.x>-10)then
	    spr(o.sprite,o.x,o.y,2,2)
	else del(lrgenemies,o) end 
    end
end

function spawnlrgenemy()
    if(lrge_t<=0)then
    local edir = flr(rnd(2))
    if(edir == 0)then
	add(lrgenemies,{sprite=28,
	x=-8,y=104,
	speed=0.15,
	health=5})
    end
    if(edir == 1)then
	add(lrgenemies,{sprite=28, 
	x=width+8,y=104,
	speed=-0.15,
	health=5})
    end
	lrge_t = flr(rnd(100))+30*15
    end
end

function spawnenemy()
    if(enemy_t<=0)then
    local edir = flr(rnd(2))
    if(edir == 0)then
	add(enemies,{sprite=42,
	x=-8,y=112,
	speed=1,
	health=2})
    end
    if(edir == 1)then
	add(enemies,{sprite=43, 
	x=width+8,y=112,
	speed=-1,
	health=2})
    end
	enemy_t = flr(rnd(enemy_spwnt))+100
    end
end

function update_ebullets()
    for item in all(ebullets)do
	item.y-=1
    end
end

function draw_ebullets()
    for item in all(ebullets)do
	circfill(item.x+4,item.y,1,8)
    end
end

function atk_countdown()
    for item in all(eshooter) do
	if(item.atk_t>0)then
	    item.atk_t-=1
	else
	    add(ebullets,{x=item.x,y=item.y})
	    item.atk_t=45
	end
    end 
end

function spawnshooter()
    if(eshooter_t<=0)then
	local edir = flr(rnd(2))
	if(edir == 0)then
	    add(eshooter,{sprite=51,
	    x=-8,y=112,
	    speed=0.5,
	    health=2,
	    atk_t = 45}
	    )
	end
	if(edir == 1)then
	    add(eshooter,{sprite=52, 
	    x=width+8,y=112,
	    speed=-0.5,
	    health=2,
	    atk_t = 45}
	    )
	end
	eshooter_t = flr(rnd(eshooter_spwnt))+450
    end
end

function drawammo()
    for i,o in pairs(ammo_crate)do
	spr(o.ammospr,o.x,o.y)
    end
end

function createammo(ammox,ammoy,v)
 --adds ammo crate at location
 add(ammo_crate,{ammospr=12,x=ammox,y=ammoy,value=v})
end

function bullethealthcol()
    local i,o
    for i,o in pairs(bullets) do
	for j,k in pairs(health_crates) do
	    if(o.x>=k.x-2 and o.x<=k.x+2)then
		if(o.y>=k.y-2 and o.y<=k.y+2)then
		    sfx(4)
		    createammo(k.x,k.y,20)
		    make_explosion_ps(k.x+4,k.y+4)
		    del(health_crates,k)
		end
	    end
	end
    end
end

function rnd_drops(rx,ry)
    local ddrop = flr(rnd(9)+1)
    if ddrop==1 then
        sfx(5)
        createammo(rx,ry,5)
        make_magicsparks_ps(rx,ry)
    end
end

function bulletcol(e,offset,lrge)
    local i,o
    for i,o in pairs(bullets) do
	for j,k in pairs(e) do
	    if(o.x>=k.x-offset and o.x<=k.x+offset)then
		if(o.y>=k.y-offset and o.y<=k.y+offset)then
		    del(bullets,o)
		    tshake=0
		    k.health-=1
		    make_sparks_ps(k.x+(offset/2),k.y+(offset/2))
		    if(k.health<=0) then
                        rnd_drops(k.x,k.y)
			if(lrge)then
			    sfx(7)
			    score+=5
			    create_plus(plusfive,k.x,k.y,48)
			    make_explosion_ps(k.x,k.y)
			end
			if not lrge then
			    sfx(flr(rnd(2)+1))
			    score+=1
			    create_plus(plusone,k.x,k.y,13)
			end
			del(e,k)
		    else
			sfx(flr(rnd(2)+1))
		    end
		end
	    end
	end
    end
end

function enemycol(e,offset)
 for i,o in pairs(e)do
  if(o.x>=player.x - offset and o.x<=player.x + offset) then
   if(o.y>=player.y - offset and o.y<=player.y + offset) then
    if(player.inv == false)then
     sfx(3)
     health -=1
     player.inv = true
     if(o.speed<0)then
      player.y_vel=30
      player.x -= 10
     end
     if(o.speed>0)then
      player.y_vel=30
      player.x += 10
     end
    end 
   end  
  end
 end
end

function cratecol(e)
 for i,o in pairs(health_crates) do
  if(o.x>=player.x - 8 and o.x<=player.x + 8) then
   if(o.y>=player.y - 8 and o.y<=player.y + 8) then
    if(health<3)then
     sfx(5)
     health+=1
    end
    del(health_crates,o)
   end  
  end
 end
 
 for b,c in pairs(health_crates) do
  for j,k in pairs(e)do
   if(c.x>=k.x - 8 and c.x<=k.x + 8) then
   if(c.y>k.y - 8 and c.y<k.y) then
     make_explosion_ps(k.x,k.y)
     del(e,k)
     del(health_crates,c)
   end  
  end 
  end
 end  
end

function ammocol()
 for i,o in pairs(ammo_crate) do
  if(o.x>=player.x - 8 and o.x<=player.x + 8) then
   if(o.y>=player.y - 8 and o.y<=player.y + 8) then
    sfx(5)
    player.ammo = player.ammo + o.value
    if player.ammo>20 then
        player.ammo = 20
    end
    del(ammo_crate,o)
   end  
  end
 end
end

function drawhearts()
 local v
 for v=1,health do
  spr(11,hearts[v].x,hearts[v].y)
 end
end

function drawcrates()
 for i,o in pairs(health_crates) do
  spr(41,o.x,o.y)
 end
end

function spawncrate()
 if health_t <= 0 then
  add(health_crates,{
      x=flr(rnd(120)),
      y=-8, speed = 1
      })
  
  health_t = health_spwnt   
 end
 
 local i,o
 for i,o in pairs(health_crates) do
 	if(o.y<112) then
 	 o.y += o.speed 
 	end
 end
end

function playerjump()
 if(player.y_vel~=0) then
 	player.y = player.y - player.y_vel * 0.1
 	player.y_vel = player.y_vel - gravity * 0.1
 
 	if(player.y >= 112) then
 	 player.y_vel = 0
 	 player.y = 112
 	end
 end
end

function moveclouds()
	local v,t
	for v,t in pairs(clouds) do
		if (t.x > -40) then
			t.x -= 1
		end
		if (t.x <= -40) then
			t.x = 160
		end
		
	end
end

function spriteflip()
	if lastpressed == 0 then
		spr(player.sprite,player.x,
		player.y,1,1,true)
	end
	
	if lastpressed == 1 then
		spr(player.sprite,player.x,
		player.y,1,1,false)
	end
end

function fire(direction)
	if cooldown <= 0 and player.ammo > 0 then
	 sfx(0)
	 player.ammo-=1 
		add(bullets,{
			x = player.x,
			y = player.y,
			speed = direction
			}
		)
		cooldown = 15
	end	
end

function playerinput()
 if(btn(0)or btn(1))then
    if(not player.inv) then
        standing=true
    end
 else
  standing=false
 end 
 
 
 if (btn(0)) then 
		if(player.x>0)then
		 player.x -= 1
		end
		lastpressed = 0 
	end
	
	if (btn(1)) then
		if(player.x<121) then
		 player.x += 1
		end
		lastpressed = 1 
	end
	
	if (btn(2)) then
	 print("jump pressed")
		if(player.y_vel == 0) then
		 player.y_vel = player.jump_height
		 sfx(6)
		end
	end
	
	if (btn(5)) and lastpressed == 0 then
	 fire(-2)
 end
 
 if (btn(5)) and lastpressed == 1 then
	 fire(2)
 end
 
 
end

function bulletupdate()
	local i,o
	for i,o in pairs(bullets) do
		o.x += o.speed
		if(o.x < -10) or (o.x > 128) then
			del(bullets,i)
		end
	end
end

function renderbg()
		-- background colors
	rectfill(0,127,127,32,7) -- white
 rectfill(0,96,127,32,15)	-- pink
	rectfill(0,0,127,32,1) --dark blue
	rectfill(0,64,127,32,12) -- light blue
	
	--background secondary colors
	line(0,30,127,30,12)
 line(0,27,127,27,12)	
 line(0,62,127,62,15)
 line(0,58,127,58,15)
 line(0,70,127,70,12)
 line(0,94,127,94,7)
 line(0,90,127,90,7)
 line(0,102,127,102,15)
end	

function drawsprites()
	spr(17,clouds[1].x,clouds[1].y,4,2)
 spr(17,clouds[2].x,clouds[2].y,4,2)
 spr(17,clouds[3].x,clouds[3].y,4,2)
--	spr(player.sprite,player.x, 
	 --   player.y,1,1,0)
	
	
	local i,o
	for i,o in pairs(bullets) do
		circfill(o.x,o.y+4,1,9)
	end
end

--- particle system
function make_magicsparks_ps(ex,ey)
	local ps = make_psystem(0.3,1.7, 1,5,1,5)
	
	add(ps.emittimers,
		{
			timerfunc = emittimer_burst,
			params = { num = 10}
		}
	)
	add(ps.emitters, 
		{
			emitfunc = emitter_box,
			params = { minx = ex-8, maxx = ex+8, miny = ey-8, maxy= ey+8, minstartvx = -1.5, maxstartvx = 1.5, minstartvy = -3, maxstartvy=-2 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_rndspr,
			params = { frames = {106,107,108,109,110}, colors = {8,9,11,12,14} }
		}
	)
	add(ps.affectors,
		{ 
			affectfunc = affect_force,
			params = { fx = 0, fy = 0.3 }
		}
	)

end


function make_starfield_ps()
	local ps = make_psystem(4,6, 1,2,0.5,0.5)
	ps.autoremove = true
	add(ps.emittimers,
		{
			timerfunc = emittimer_constant,
			params = {nextemittime = time(), speed = 0.01}
		}
	)
	add(ps.emitters, 
		{
			emitfunc = emitter_box,
			params = { minx = 125, maxx = 127, miny = 0, maxy= 127, minstartvx = -2.0, maxstartvx = -0.5, minstartvy = 0, maxstartvy=0 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_pixel,
			params = { colors = {7,6,7,6,7,6,6,7,6,7,7,6,6,7} }
		}
	)
end

function make_explosion_ps(ex,ey)
	local ps = make_psystem(0.1,0.5, 9,14,1,3)
	
	add(ps.emittimers,
		{
			timerfunc = emittimer_burst,
			params = { num = 4 }
		}
	)
	add(ps.emitters, 
		{
			emitfunc = emitter_box,
			params = { minx = ex-4, maxx = ex+4, miny = ey-4, maxy= ey+4, minstartvx = 0, maxstartvx = 0, minstartvy = 0, maxstartvy=0 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_fillcirc,
			params = { colors = {7,0,10,9,9,4} }
		}
	)
end


function make_sparks_ps(ex,ey)
	local ps = make_psystem(0.3,0.7, 1,2,0.5,0.5)
	
	add(ps.emittimers,
		{
			timerfunc = emittimer_burst,
			params = { num = 10}
		}
	)
	add(ps.emitters, 
		{
			emitfunc = emitter_point,
			params = { x = ex, y = ey, minstartvx = -1.5, maxstartvx = 1.5, minstartvy = -3, maxstartvy=-2 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_fillcirc,
			params = { colors = {7,10,15,9,4,5} }
		}
	)
	add(ps.affectors,
		{ 
			affectfunc = affect_force,
			params = { fx = 0, fy = 0.3 }
		}
	)
end

-- particle system library -----------------------------------
particle_systems = {}

function make_psystem(minlife, maxlife, minstartsize, maxstartsize, minendsize, maxendsize)
	local ps = {}
	-- global particle system params
	ps.autoremove = true

	ps.minlife = minlife
	ps.maxlife = maxlife
	
	ps.minstartsize = minstartsize
	ps.maxstartsize = maxstartsize
	ps.minendsize = minendsize
	ps.maxendsize = maxendsize
	
	-- container for the particles
	ps.particles = {}

	-- emittimers dictate when a particle should start
	-- they called every frame, and call emit_particle when they see fit
	-- they should return false if no longer need to be updated
	ps.emittimers = {}

	-- emitters must initialize p.x, p.y, p.vx, p.vy
	ps.emitters = {}

	-- every ps needs a drawfunc
	ps.drawfuncs = {}

	-- affectors affect the movement of the particles
	ps.affectors = {}

	add(particle_systems, ps)

	return ps
end

function update_psystems()
	local timenow = time()
	for ps in all(particle_systems) do
		update_ps(ps, timenow)
	end
end

function update_ps(ps, timenow)
	for et in all(ps.emittimers) do
		local keep = et.timerfunc(ps, et.params)
		if (keep==false) then
			del(ps.emittimers, et)
		end
	end

	for p in all(ps.particles) do
		p.phase = (timenow-p.starttime)/(p.deathtime-p.starttime)

		for a in all(ps.affectors) do
			a.affectfunc(p, a.params)
		end

		p.x += p.vx
		p.y += p.vy
		
		local dead = false
		if (p.x<0 or p.x>127 or p.y<0 or p.y>127) then
			dead = true
		end

		if (timenow>=p.deathtime) then
			dead = true
		end

		if (dead==true) then
			del(ps.particles, p)
		end
	end
	
	if (ps.autoremove==true and count(ps.particles)<=0) then
		del(particle_systems, ps)
	end
end

function draw_ps(ps, params)
	for df in all(ps.drawfuncs) do
		df.drawfunc(ps, df.params)
	end
end

function emittimer_burst(ps, params)
	for i=1,params.num do
		emit_particle(ps)
	end
	return false
end

function emittimer_constant(ps, params)
	if (params.nextemittime<=time()) then
		emit_particle(ps)
		params.nextemittime += params.speed
	end
	return true
end

function emit_particle(psystem)
	local p = {}

	local e = psystem.emitters[flr(rnd(#(psystem.emitters)))+1]
	e.emitfunc(p, e.params)	

	p.phase = 0
	p.starttime = time()
	p.deathtime = time()+rnd(psystem.maxlife-psystem.minlife)+psystem.minlife

	p.startsize = rnd(psystem.maxstartsize-psystem.minstartsize)+psystem.minstartsize
	p.endsize = rnd(psystem.maxendsize-psystem.minendsize)+psystem.minendsize

	add(psystem.particles, p)
end

function emitter_point(p, params)
	p.x = params.x
	p.y = params.y

	p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
	p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function emitter_box(p, params)
	p.x = rnd(params.maxx-params.minx)+params.minx
	p.y = rnd(params.maxy-params.miny)+params.miny

	p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
	p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function affect_force(p, params)
	p.vx += params.fx
	p.vy += params.fy
end

function affect_forcezone(p, params)
	if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
		p.vx += params.fx
		p.vy += params.fy
	end
end

function affect_stopzone(p, params)
	if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
		p.vx = 0
		p.vy = 0
	end
end

function affect_bouncezone(p, params)
	if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
		p.vx = -p.vx*params.damping
		p.vy = -p.vy*params.damping
	end
end

function affect_attract(p, params)
	if (abs(p.x-params.x)+abs(p.y-params.y)<params.mradius) then
		p.vx += (p.x-params.x)*params.strength
		p.vy += (p.y-params.y)*params.strength
	end
end

function affect_orbit(p, params)
	params.phase += params.speed
	p.x += sin(params.phase)*params.xstrength
	p.y += cos(params.phase)*params.ystrength
end

function draw_ps_fillcirc(ps, params)
	for p in all(ps.particles) do
		c = flr(p.phase*count(params.colors))+1
		r = (1-p.phase)*p.startsize+p.phase*p.endsize
		circfill(p.x,p.y,r,params.colors[c])
	end
end

function draw_ps_pixel(ps, params)
	for p in all(ps.particles) do
		c = flr(p.phase*count(params.colors))+1
		pset(p.x,p.y,params.colors[c])
	end	
end

function draw_ps_streak(ps, params)
	for p in all(ps.particles) do
		c = flr(p.phase*count(params.colors))+1
		line(p.x,p.y,p.x-p.vx,p.y-p.vy,params.colors[c])
	end	
end

function draw_ps_animspr(ps, params)
	params.currframe += params.speed
	if (params.currframe>count(params.frames)) then
		params.currframe = 1
	end
	for p in all(ps.particles) do
		pal(7,params.colors[flr(p.endsize)])
		spr(params.frames[flr(params.currframe+p.startsize)%count(params.frames)],p.x,p.y)
	end
	pal()
end

function draw_ps_agespr(ps, params)
	for p in all(ps.particles) do
		local f = flr(p.phase*count(params.frames))+1
		spr(params.frames[f],p.x,p.y)
	end	
end

function draw_ps_rndspr(ps, params)
	for p in all(ps.particles) do
		pal(7,params.colors[flr(p.endsize)])
		spr(params.frames[flr(p.startsize)],p.x,p.y)
	end	
	pal()
end

__gfx__
00000000bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000ddd1000000000088088088000000000000000000000000
00000000bb33bbbbbb33bbbb000000000000000000000000700000000000000000000000000000000dddd1100ee0880088088088000000000000000000000000
000000003344333333993333000000000000000000000000000000000000000000070000000000000ddd7170e88e888055055055000000000000000000000000
000000005444444954944949000000000000000000000000000000000000000000777000000000000ddd1110e888888055055055000000000000000000000000
0000000054414449549449490000000000000000000000000000000000000000000700000000000000dd1100e888888055055055000009900000088000000660
0000000051444449549999490000000000000000000000000000070000000000000000000000000000d111000e88880055055055090000900800008006000060
0000000054444149544444490000b00030000b000000000000000000000000000000000000000000001001000088800000000000999000908880008066600060
000000005555555955555559b00300b0b00300b00000000000000000000000000000000000000000001001000008000077077077090009990800088806000666
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e2222000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e88822200000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e888822220000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088aa88aa20000000000000000000
000000000000000000000000007777000000000000000000006666000000000000000000000000000000000000000000000088aa88aa20000000000000000000
00000000000000000000000007777770000000000000000006666660000000000000000000000000000000000000000000008888882220000000000000000000
0000000000000000000000007777777700000000000000006666666600000000000000000000000000000000000000000ee80888882202280000000000000000
0000000000000000000000777ff77777700000000000000666666666660000000000000000000000000000000000000008800888822200220000000000000000
000000000000000000000777777ffff77700000000000066666666666660000000000000eeddddee00ccc100001ccc0008800088822000220000000000000000
000000000000000007707777777777777770000000000666666666666666066000000000e777777e0cc8c810018c8cc000000088822000000000000000000000
000000000000000077777777777777f77777700000066666666666666666666600000000d77bb77d0ccc11100111ccc000000888822200000000000000000000
00000000000777077ff7777f7777777777f7770000666666666666666666666660666000d7bbbb7dc0c1110110111c0c00008888888220000000000000000000
000000000077777777777777f777777f777f777006666666666666666666666666666600d73bb37dc00c10011001c00c00088888888222000000000000000000
00000000077777f7777777777f7777ff7777f77006666666666666666666666666666660d773377d000c10000001c00000088800000822200000000000000000
000000007777777f777fffff7f777fff7777f77006666666666666666666666666666666e777777e00cc11000011cc0000088800000822000000000000000000
00000000fffffffffffffffffffffffffffffff006666666666666666666666666666666eeddddee00c0010000100c0000008800000220000000000000000000
0000000000000000000000000088820000288800000000000000000000ddd10000ddd1000000000000080000a000008080000000000000000000000000000000
000000000000000000000000088989200298988000ddd10000ddd1000dddd1100dddd11000ddd100a00000808000000000080000000000000000000000000000
00000000000000000000000008882220022288800dddd1100dddd1100ddd71700ddd71700dddd1108008a0000008a000008aa080000000000000000000000000
00009990000088800000666080822202202228080ddd71700ddd71700ddd11100ddd11100ddd717000a8a8000088a80000a88a00000000000000000000000000
09009000080080000600600080082002200280080ddd11100ddd111000dd110000dd11000ddd11100a8aaa800aaa8a800aaaaa80000000000000000000000000
999099908880888066606660000820000002800000dd110000dd110000d1118008d1110000dd110008aa8a8008aaaa8008aaaa80000000000000000000000000
090000900800008006000060008822000022880000d1110000d11180008000000000008008d1110008aaa80008aaa80008aaa800000000000000000000000000
00009990000088800000666000800200002008000080080000800000000000000000000000000800008880000088800000888000000000000000000000000000
88888888088880088880888888888088888888808888888899999999099999999099900999099999999099999999099900000000000000000000000000000000
88888888088880088880888888888088888888808888888899999999099999999099900999099999999099999999099900000000000000000000000000000000
88822222088880088880888228888088822888802288882299944444044999944099900999099944444099944444099900000000000000000000000000000000
88800000088880088880888008888088800888800088880099900000000999900099900999099900000099900000099900000000000000000000000000000000
eeeeeeee0eeeeeeeeee0eee00eeee0eee00eeee000eeee00aaaaaaaa000aaaa000aaa00aaa0aaaaaaa00aaaaaaa00aaa00000000000000000000000000000000
2222eeee0eeeeeeeeee0eee00eeee0eee00eeee000eeee004444aaaa000aaaa000aaa00aaa0aaaaaaa00aaaaaaa00aaa00000000000000000000000000000000
0000eeee0eeee22eeee0eee00eeee0eee00eeee000eeee000000aaaa000aaaa000aaaaaaaa0aaa444400aaa44440044400000000000000000000000000000000
88888888088880088880888888888088888888800088880099999999000999900099999999099900000099900000000000000000000000000000000000000000
88888888088880088880888888888088888888800088880099999999000999900099999999099900000099900000099900000000000000000000000000000000
22222222022220022220222222222022222222200022220044444444000444400044444444044400000044400000044400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08880888088888880888088809990000099999990999999909999999099000990999999909990099000000000000000000000000000000000000000000000000
08880888088828880888088809990000099949990994444409999999099000990999499909990099070007000707070000070000000000000000000000000000
0eee0eee0eee0eee0eee0eee0aaa00000aaa0aaa0aa00000044aaa440aa000aa0aaa0aaa0aaaa0aa007070000077700000070000007070000007000000000000
0eeeeeee0eee0eee0eee0eee0aaa00000aaa0aaa0aaaaaaa000aaa000aa000aa0aaa0aaa0aa4aaaa000a0000077a7700077a7700000a0000007a700000000000
08888888088808880888088809990000099909990444499900099900099090990999099909904999007070000077700000070000007070000007000000000000
02288822088888880888888809999999099999990000099900099900099999990999999909900499070007000707070000070000000000000000000000000000
00088800088888880888888809999999099999990999999900099900099949990999999909900099000000000000000000000000000000000000000000000000
00022200022222220222222204444444044444440444444400044400044404440444444404400044000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111161111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111117111111111111111111111111111111111111111111111111111111111111111611111111111111171111111111111111111111
11111111111111111111111111111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111116111111111111111111111111111111111111111111111117111111111111111111111111111111111111111111111111111111111111111
11111111111111111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111177711111111111111111111111111111111111111111111161111111117111111111111111111111111111111111111111111111111111
11111111111111111117111111111111111111111111111111111111111111111111111111111611111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111171611111111111111111111111111111111111111111111111111111711
11111111111111111111111111111111111111111111111111171111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111161111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111116111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111161111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111188888888888888881188888888111188888888118888888888888888881188888888888888888811888888888888888811111111111111111
11111111111111188888888888888881188888888111188888888118888888888888888881188888888888888888811888888888888888811111111111111111
61111111111111188888888888888881188888888111188888888618888888888888888881188888888888888888811888888888888888811111111111111111
11111111111111188888888888888881188888888111188888888118888888888888888881188888888888888888811888888888888888811111111111111111
ccccccccccccccc8888882222222222cc88888888cccc88888888cc888888222288888888cc888888222288888888cc2222888888882222ccccccccccccccccc
11111111111111188888822222222221188888888111188888888118888882222888888881188888822228888888811222288888888222211111111111111111
11111111111111188888811111111111188888888111188888888118888881111888888881188888811118888888811111188888888111111111117111111111
ccccccccccccccc888888cccccccccccc88888888cccc88888888cc888888cccc88888888cc888888cccc88888888cccccc88888888cccccccc7cccccccccccc
111111111111111eeeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeee11eeeeee1111eeeeeeee11eeeeee1111eeeeeeee111111eeeeeeee111111111111111111111
ccccccccccccccceeeeeeeeeeeeeeeecceeeeeeeeeeeeeeeeeeeecceeeeeecccceeeeeeeecceeeeeecccceeeeeeeecccccceeeeeeeeccccccccccccccccccccc
ccccccccccccccc22222222eeeeeeeecceeeeeeeeeeeeeeeeeeeecceeeeeecccceeeeeeeecceeeeeecccceeeeeeeecccccceeeeeeeeccccccccccccccccccccc
ccccccccccccccc22222222eeeeeeeecceeeeeeeeeeeeeeeeeeeecceeeeeecccceeeeeeeecceeeeeecccceeeeeeeecccccceeeeeeeeccccccccccccccccccccc
ccccccccccccccccccccccceeeeeeeecceeeeeeee2222eeeeeeeecceeeeeecccceeeeeeeecceeeeeecccceeeeeeeecccccceeeeeeeeccccccccccccccccccccc
ccccccccccccccccccccccceeeeeeeecceeeeeeee2222eeeeeeeecceeeeeecccceeeeeeeecceeeeeecccceeeeeeeecccccceeeeeeeeccccccc6ccccccccccccc
ccccccccccccccc8888888888888888cc88888888cccc88888888cc888888888888888888cc888888888888888888cccccc88888888ccccccccccccccccccccc
ccccccccccccccc8888888888888888cc88888888cccc88888888cc888888888888888888cc888888888888888888cccccc88888888ccccccccccccccccccccc
ccccccccccccccc8888888888888888cc88888888cccc88888888cc888888888888888888cc888888888888888888cccccc88888888ccccccccccccccccccccc
ccccccccccccccc8888888888888888cc88888888cccc88888888cc888888888888888888cc888888888888888888cccccc88888888ccccccccccccccccccccc
ccccccccccccccc2222222222222222cc22222222cccc22222222cc222222222222222222cc222222222222222222cccccc22222222c6ccccccccccccccccccc
ccccccccccccccc2222222222222222cc22222222cccc22222222cc222222222222222222cc222222222222222222cccccc22222222ccccccccccccccccccccc
cccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccc6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccccccccccccccccccccccccccccccccccc
ccccccccccccccc9999999999999999cc9999999999999999cc999999cccc999999cc9999999999999999cc9999999999999999cc999999ccccccccccccccccc
ccccccccccccccc9999999999999999cc9999999999999999cc999999cccc999999cc9999999999999999cc9999999999999999cc999999ccccccccccccccccc
ccccccccccccccc9999999999999999cc9999999999999999cc999999cccc999999cc9999999999999999cc9999999999999999cc999999ccccccccccccccccc
ccccccccccccccc9999999999999999cc9999999999999999cc999999cccc999999cc9999999999999999cc9999999999999999cc999999ccccccccccccccccc
ccccccccccccccc9999994444444444cc4444999999994444cc999999cccc999999cc9999994444444444cc9999994444444444cc999999ccccccccccccccccc
ccccccccccccccc9999994444444444cc4444999999994444cc999999cccc999999cc9999994444444444cc9999994444444444cc999999ccccccccccccccccc
ccccccccccccccc999999cccccccccccccccc99999999cccccc999999cccc999999cc999999cccccccccccc999999cccccccccccc999999ccccccccccccccccc
ccccccccccccccc999999cccccccccccccccc99999999cccccc999999cccc999999cc999999cccccccccccc999999cccccccccccc999999ccccccccccccccccc
cccccccccccccccaaaaaaaaaaaaaaaaccccccaaaaaaaaccccccaaaaaaccccaaaaaaccaaaaaaaaaaaaaaccccaaaaaaaaaaaaaaccccaaaaaaccccccccccccccccc
cccccccccccccccaaaaaaaaaaaaaaaacc7cccaaaaaaaaccccccaaaaaaccccaaaaaaccaaaaaaaaaaaaaaccccaaaaaaaaaaaaaaccccaaaaaaccccccccccccccccc
ccccccccccccccc44444444aaaaaaaaccccccaaaaaaaaccccccaaaaaaccccaaaaaaccaaaaaaaaaaaaaaccccaaaaaaaaaaaaaaccccaaaaaaccccccccccccccccc
ccccccccccccccc44444444aaaaaaaaccccccaaaaaaaaccccc6aaaaaaccccaaaaaaccaaaaaaaaaaaaaaccccaaaaaaaaaaaaaaccccaaaaaaccccccccccccccccc
cccccccccccccccccccccccaaaaaaaaccccc6aaaaaaaaccccccaaaaaaaaaaaaaaaaccaaaaaa44444444ccccaaaaaa44444444cccc444444ccccccccccccccccc
fffffffffffffffffffffffaaaaaaaaffffffaaaaaaaaffffffaaaaaaaaaaaaaaaaffaaaaaa44444444ffffaaaaaa44444444ffff444444fffffffffffffffff
cccccccc7cccccc9999999999999999cccccc99999999cccccc9999999999999999cc999999cccccccccccc999999ccccccccccccccccccccccc7ccccccccccc
ccccccccccccccc9999999999999999cccccc99999999cccccc9999999999999999cc999999cccccccccccc999999ccccccccccccccccccccccccccccccccccc
ccccccccccccccc9999999999999999cccccc99999999cccccc9999999999999999cc999999cccccccccccc999999cccccccccccc999999ccccccccccccccccc
fffffffffffffff9999999999999999ffffff99999999ffffff9999999999999999ff999999ffffffffffff999999ffffffffffff999999fffffffffffffffff
ccccccccccccccc4444444444444444cccccc44444444cccccc4444444444444444cc444444cccccccccccc444444cccccccccccc444444ccccccccccccccccc
ccccccccccccccc4444444444444444cccccc44444444cccccc4444444444444444cc444444cccccccccccc444444cccccccccccc444444ccccccccccccccccc
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777ffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff777777fffffffff
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777cccccccc
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff777ff777777fffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff777777ffff777ffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77f777777777777777fffff
ff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77777777777777f777777fff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6f777f77ff7777f7777777777f777ff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77777777777777f777777f777f777f
fffffffffffffffffffffffffffffffffffffffffffff6fffffffffffffffffffffffffffffffffffffffffffffffffff77777f7777777777f7777ff7777f77f
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777777f777fffff7f777fff7777f77f
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffff555f555f555ff55ff55fffff5f5fffffffffffff755fffff555ff55fffff555f5fff555f5f5ffffffffffffffffffffffffffff
fffffffffffffffffffffffff5f5f5f5f5fff5fff5ffffff75f5ffffff5ffffff5ffffffff5ff5f5fffff5f5f5fff5f5f5f5fffffffffffffffffffff7ffffff
fffffffffffffffffffffffff555f55ff55ff555f555ffffff5ffffff555fffff5ffffffff5ff5f5fffff555f5fff555f555ffffffffffffffffffffffffffff
fffffffffffffffffffffffff5fff5f5f5fffff5fff5fffff5f5ffffff5ffffff5ffffffff5ff5f5fffff5fff5fff5f5fff5ffffffffffffffffffff7fffffff
fffffffffffffffffffffffff57775f5f555f55ff55ffffff5f5ffffff6fffffff55ffffff5ff55ffffff5fff555f5f5f555ffffffffffffffffffffffffffff
ffff6ffffffffffffffffffff777777ffffffffffffff6ffff7ff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffff77777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffff777ff777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffffff
fffffffffffffffffffff777777ffff777fffffffffffffffffffffffffff6ffffffffffffffffffffffffffffffffffffffffffffff6ffffffffffffff7ffff
fffffffffffffffff77f777777777777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffffffffffffffffffffffffffffffffff
777777777777777777777777777777f7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
fffffffffff777f77ff7777f7776777777f777fffffffffffffffffffffffffffffffffffffffffffffffffffff6ffffffffffffffffffffffffffffffffffff
ffffffffff77777777777777f777777f777f777ffff6ffffffffffffffff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffffff
fffffffff77777f7777777777f7777ff7777f77fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6fffffffffffffffffffffffffffff
777777777777777f777fffff7f777fff7777f7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
ffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777767777777777777777777777777777
77777777777777777777777777777777777777777777777777767777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777776777777777777777777777777777777777777777777777777777777777777777777777777
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777767777777777777777777777777777777777777777777777777777777777777777777777777777777777776777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777776777677777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777677777777777777777777777767777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
67777777777777777777777777777777777777777777777777777777777767777777777777777777777777777777777777777777777777777777777777777777
777777777777b777777777777777777737777b77777777777777777737777b77777777777777b7777777777777777777777777777777b7777777777777777777
77777777b77377b77777777777777777b77377b77777777777777777b77377b777777777b77377b7777777777777777777777777b77377b77777777777777777
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb33bbbbbb33bbbbbb33bbbbbb33bbbbbb33b6bbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb36bbbbbb33bbbbbb36bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbb
33443333339933333344333333993333339933333344333333993333339933333344333333993333334433333399333333443333339933333399333333443333
54444449549449495446444954944949549449495444444954944949549449495444444954944949544444495494494954444449549449495494494954444449
54414449549449495441444954944949549449495441444954944949549449465441444954944949544144495494494954414449549449495494494954414449
51444449549999495144444954999949549999495144444954999949549999495144444954999949514444495499994951444449549999495499994951444449
54444149544444495444414954444449544444495444414954444449544444495444414954444449544441495444444954444149544444495444444954444149
55555559555555595555555955555559555555595555555955555559555555595555555955555559555555595555555955555559555555595555555955555559

__map__
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f082f2f2f2f2f062f2f2f000000002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f082f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f002f2f2f2f2f2f062f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f082f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f111213142f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f212223242f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f111213142f062f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2122232405050505052f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f0000002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f030000042f2f042f032f2f2f032f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010201020201020201020102010202012f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020102020102020102010102012f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003b31039310363103471032710307102e7102b710297102671023710235000b20007200062000520003200022000120001200000000000000000000000000000000000000000000000000000000000000
0102000012025112250f0150e2150d0150c2150b0150a215090150821507015062150501504215030150221501015012150400503205010050760506605066050560504605046050360502605016050160501605
00020000010141322514015142151201515215110151621510015172150e0150a2150701508215050150621503015042150400503205010050760506605066050560504605046050360502605016050160501605
0002000030716367162471636716247162a716187162a716247162a716187162a716187161e7160c7161e716187161e7160c7161e716187161e7160c7161e716247062a706187062a706187071e7070c7071e707
000900000861514615070150651502204006050550005500266002460023600216001f6001d6001c6001a60018600176001660015600146000030000300003000030000300003000030000300003000030000300
000600003a7143f715000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000c5300f52114021180211b0111d0112000017000140000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000200003f613232233a61121221346111e2212f611172212a61112221246110d2211e61109221186110522111611032210c61101221086150122504615002250261500615006000060500600006000060000600
01100000307102c7102771025710307102c7102771025710307102c7102771025710307102c7102771031710307102c7102771025710307102c7102771025710307102c7102771025710307102c7102771025710
011000002751025510305102c5102751025510305102c5102751025510305102c5102751025510305102c5102751031510305102c5102751025510305102c5102751025510305102c5102751025510305102c510
011000000000000000000000810008145081000814508145000000810508105081450814500000000000000000000000000000008100081450810008145081450000008105081050814508145000000814508145
011000000c0430000000000000003061500000000000c0430c003000000000000000306150c043000000c0230c0430000000000000003061500000000000c0430c003000000000000000306150c043000000c003
011000002c7102871023710227102c7102871023710207102c7102871023710227102c71028710237102d7102c7102871023710227102c7102871023710207102c7102871023710227102c710287102371020710
0110000023510225102c5102851023510225102c5102851023510205102c5102851023510225102c51028510235102d5102c5102851023510225102c5102851023510205102c5102851023510225102c51028510
011000000000000000000000810002145081000214502145000000214508105021450214500000000000000000000021450000002145021450810002145021450000002145081050214502145021450214502145
010f000002140021250a0250a02502140021250b0250a02502140021250b0250d0250214002125130251202502140021251102516025021400212517025160250214002125170250e02502140021250d02516025
010a000024545205451b54527545235451e5452a54526545215252d5402d5302d5202d5202d5202d5202d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d522
010a00000813008120081100b1300b1200b1100e1300e1200e1100c1300c1300c1200c1200c1200c1200612100121001200012000120001200012000120001200012000120001200012000122001220012200122
010a00001802018020180151b0201b0201b0151e0201e0201e0152a0202a0202a0102a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e017
010a000018615186150c02318615186150c02318615186150c0232a0202a0202a0102a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e017
010f00000014000125001000010000140001250010000100001400012500100001000014000125001000010000140001250010000100001400012500100001000014000125001000010000140001250010000100
010f000000140001250a0250a02500140001250a0250a02500140001250a0250a02500140001250a0250a02500140001250a0250a02500140001250a0250a02500140001250a0250a02500140001250a0250a025
010f00002b0102c0112d0112e0112b0102c0112d0112e0112b0102c0112d0112e0112b0102c0112d0112e0112b0102c0112d0112e0112b0102c0112d0112e0112b0102c0112d0112e0112e01022011160110a011
010f00002d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d5222d522215211552109521
010f00000952209522095220952209522095220952209522095120951209512095120951209512095120951209512095120951209512095100951009510095100951009510095100951509500095000950009505
010f00001701018011190111a0111701018011190111a0111701018011190111a0111701018011190111a0111701018011190111a0111701018011190111a0111701018011190111a0111701018011190111a011
010f00000a526095260a526095260a506095060a526095260d7250d7250d7250d7250d7250d72519725197250a526095260a526095260a506095060a526095260d7250d7250d7250d7250d7250d7251972519725
010f00000c5260d5260c5260d5260d7250d7250a5210b5210c5260d5260c5260d5260d7250d7250a5210b5210c5260d5260c5260d5260d7250d7250a5210b5210c5260d5260c5260d5260d7250d7250a5210b521
010f000002140021250e02510025021400212510025150250214002125130251502502140021250d0251202502140021251b02515025021400212511025160250214002125170250e02502140021250d02516025
010f000002140021251c0251b025021400212526025150250214002125130251f025021400212520025290250214002125270251502502140021252c02522025021400212517025240250214002125230252a025
010f00001701018011190111a01118010190111a0111b011190101a0111b0111c0111a0101b0111c0111d0111b0101c0111d0111e0111c0101d0111e0111f0111d0101e0111f011200111e0101f0112001121011
010f00001e0101f01120011210111e0101f01120011210111f0102001121011220111f01020011210112201120010210112201123011200102101122011230112101022011230112401121010220112301124011
010f000002140021251c0251b025021400212526025150250314003125130251f025031400312520025290250414004125270251502504140041252c025220250514005125170252402505120031310212101111
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000024545205451b54527545235451e5452a5452654521525305452c54527545335452f5452a54536545325452d5453954239542395323953239522395223952239522395223952239522395223952239522
010a00000813008120081100b1300b1200b1100e1300e1200e1101413014120141101713017120171101a1301a1201a1100e1400e1300e1200e1200e1200e1200212102120021200212002120021200212002120
010a000018615186150c02318615186150c02318615186150c02318615186150c02318615186150c02318615186150c0232a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e017
010a00002c54527545245452f5452a54527545325452d5452a5253854533545305453b5453654533545325452d5452a5452a5402a5302a5202a5102a5102a5102a5102a5102a5102a5122a5122a5122a5122a512
011000000212002120021200212002120021200212002120021200212002120021200212002120021200212002120021200212002120021200212002120021200212002120021200212002120021200212002120
011000002a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e0172a0171e017
011000003952239522395223952239522395223952239522395123951239512395123951239512395123951239512395103951039510395103951039510395103951039510395103951039510395103951039510
011000002a5122a5122a5122a5122a5122a5122a5122a5122a5122a5122a5122a5122a5122a5122a5122a5120c0430000000000000003061500000000000c0430c00330615000000c043306150c0433061530615
011000000214500000000000810002145081000214502145000000214508105021450214500000000000000000000021450000002145021450810002145021450000002145081050214502145021450214502145
0110000036710327102d7102b71036710327102d7102b71036710327102d7102b71036710327102d7103771036710327102d7102b71036710327102d7102b71036710327102d7102b71036710327102d7102b710
011000002d5152b51536515325152d5152b51536515325152d5152b51536515325152d5152b51536515325152d5202d5102d5102d512325213251032510325123652136510365103651239521395103951039512
01100000395103951039510395103951039510395103951039510395103951039510395103951239512335112d5112d5102d5102d5102d5102d5102d5102d5102d5102d5102d5102d5102d5102d5102d5102d510
011000000714507145000000714507105081000714507145000000714508105071450714500000000000000000000071450000007145071450810007145071450000007145081050714507145071450714507145
011000002f5202f5102f5102f5102f5102f5102f5102f5102f5102f5102f5122f5122f5122f5122f5122f5152d5102b51036510325102d5102b51036510325102d5102b51036510325102d5102b5103651032510
011000002d5102b51036510325102d5102b51036510325102d5102b51036510325102d5102b51036510325102d5102b51036510325102d5102b51036510325102d5152b51536515325152d5152b5153651532515
01100000215151f5152a5151a51515515135151e5151a515215151f5152a51526515215151f5152a515265151f51521515265152a5152b5152d51532515365153751536515345153251537515365153451532515
01400020147060e7061471711706167060e7171570611716157060e7061670611717177060c7060c7060e716177171070614706117161470613706177170f706177061671613706177060d7061a7172070610706
011000200b7200c7210d7210e7210b7200c7210d7210e7210b7200c7210d7210e7210b7200c7210d7210e7210b7200c7210d7210e7210b7200c7210d7210e7210b7200c7210d7210e7210b7200c7210d7210e721
010b1f202d5102a511275112451124510235112251121511205111f5111e5111d5111c5111b5111a51119511195101851117511155111351111511105110e5110c5110b511095110751105511045110251100511
010d00200151001510015140101401514015100151001500015100151001514015140151001515010100151001510010100151001510015000151001510015130151001510015100151001010015000150001510
010e00200001000000000200002000020000250002000020000140000500023000200002000000000200002000020000000012500025000200012000020000200002000000000200002400024000200002000020
010b0020147070e7071471711717167070e1071510711707157070e7071671711717177070c7070c7070e717177171070714707117171471713707177070f707177171671713707177070d7071a7172070710707
010a1f201602013021100210d0210c0210c0210b0210a021090210802107021060210502104021030210202100021000200002500520000200002000023000200002000024000200002000025000100012000020
010a1f2015520125210f5210c5210c5200b5210a52109521085210752106521055210452103521025210152101520015200152001520015200152001520015200152001520015200152001520015200152001510
__music__
01 08090a0b
00 08090a0b
00 0c0d0e0b
02 0c0d0e0b
00 10111353
00 17141655
00 1814195a
01 151a5b44
00 151a5b44
00 151b4344
00 151a4344
00 0f194344
00 0f194344
00 151a4344
00 1c194344
00 1d1e4344
02 201f4344
00 3e3f3a3d
03 3b3c3938
00 28292a2b
00 2c2d2e2f
00 3031330b
01 3031320b
00 3431350b
00 3031360b
02 3031370b
00 3031430b
04 3042430b

