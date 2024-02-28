local BUTTON=scene.button

local menu={modeKey=1}
local flashT,enterT,clickT=0,0,0
menu.modelist={'40 lines','marathon','ice storm','thunder','smooth','master','multitasking','sandbox'}
local modename={
    ['40 lines']="Sprint",
    marathon="Marathon",
    ['ice storm']="Ice Storm",
    thunder="Thunder",
    smooth="Smooth Sprint",
    master="Master",
    multitasking="Multitask",
    sandbox="Sandbox"
}

function menu.init()
    if menu.bgName then scene.BG=require('BG/'..menu.bgName) else scene.BG=require('BG/pond') end
    if scene.BG.init then scene.BG.init() end
    if mus.path~='music/Hurt Record/Nine Five' then
        mus.add('music/Hurt Record/Nine Five','parts','mp3',61.847,224*60/130)
        mus.start()
    end
    menu.lvl=1

    BUTTON.create('setting',{
        x=-800,y=-400,type='rect',w=150,h=150,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-75,-75,150,150,12)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.rectangle('line',-75,-75,150,150,12)
            gc.setColor(1,1,1)
            gc.setLineWidth(6)
            gc.setColor(.8,1,.9,.75)
            gc.circle('line',0,0,50,6) gc.circle('line',0,0,22.5)
            --gc.polygon('line')
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
            function menu.send(destScene)
                destScene.exitScene='scene/menu'
            end
        end
    },.2)
end
function menu.keyP(k)
    local len=#menu.modelist
    if k=='return' then menu.lvl=min(menu.lvl+1,2)
    elseif k=='escape' then menu.lvl=max(menu.lvl-1,0) end
    if menu.lvl==0 then
        scene.dest='intro' scene.swapT=.7 scene.outT=.3
        scene.anim=function() anim.cover(.3,.4,.3,0,0,0) end
    elseif menu.lvl==1 then
        if k=='left' or k=='right' or k=='r' or k=='kp4' or k=='kp6' then flashT=.3 end
        if k=='left' or k=='kp4' then menu.modeKey=(menu.modeKey-2)%len+1
        elseif k=='right' or k=='kp6' then menu.modeKey=menu.modeKey%len+1
        elseif k=='r' then menu.modeKey=rand(1,#menu.modelist)
        end
    elseif menu.lvl==2 then
        scene.dest='game' scene.destScene=require'mino/game'
        scene.swapT=.7 scene.outT=.3
        scene.anim=function() anim.cover(.3,.4,.3,0,0,0) end

        scene.sendArg=menu.modelist[menu.modeKey]
        menu.send=menu.gameSend
    end
end
function menu.mouseP(x,y,button,istouch)
    if not BUTTON.click(x,y,button,istouch) then local len,l=#menu.modelist,1920/#menu.modelist
        if button==1 then
            if y>=500 then
            for i=1,len do
                if x>-960+l*(i-1) and x<-960+l*i then
                    menu.modeKey=i flashT=.3 break
                end
            end
            elseif x<-640 then menu.modeKey=(menu.modeKey-2)%len+1 flashT=.3
            elseif x> 640 then menu.modeKey=menu.modeKey%len+1 flashT=.3
            else
                if clickT>0 then
                    scene.dest='game' scene.destScene=require'mino/game'
                    scene.swapT=.7 scene.outT=.3
                    scene.anim=function() anim.cover(.3,.4,.3,0,0,0) end
                    scene.sendArg=menu.modelist[menu.modeKey]
                    menu.send=menu.gameSend
                else clickT=.5 end
            end
            --menu.changeBG(menu.modeKey)
        end
    end
end
function menu.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    flashT=max(flashT-dt,0) clickT=max(clickT-dt,0)
end
function menu.draw()
    local l=1920/#menu.modelist
    gc.printf(modename[menu.modelist[menu.modeKey]],Exo_2,-750,-540,1000,'center',0,1.5,1.5)

    gc.setColor(1,1,1,.5-.15*cos(scene.time%8*math.pi/4))
    gc.printf("Double click / Enter to start\nR for random mode",
        Exo_2,0,0,2000,'center',0,.6,.6,1000,512/3)

    gc.setLineWidth(3)
    for i=1,#menu.modelist do
        if i==menu.modeKey then
            gc.setColor(1,1,1,.6)
            gc.rectangle('fill',-960+l*(menu.modeKey-1),500,l,40)
        else
            gc.setColor(1,1,1,.2+.05*(i%2))
            gc.rectangle('fill',-960+l*(i-1),500,l,40)
        end
        gc.printf(modename[menu.modelist[i]],Consolas,-960+l*(i-.5),480,2000,'center',0,.3,.3,1000,56)
    end
    gc.setColor(1,1,1,.5)
    gc.setLineWidth(20)
    gc.line(-760,-100,-860,0,-760,100)
    gc.line( 760,-100, 860,0, 760,100)
    do
        local s=scene.time%4/4
        if.08-s>0 then
            gc.setColor(1,1,1,10*(.08-s))
            gc.line(-760-800*s,-100,-860-800*s,0,-760-800*s,100)
            gc.line( 760+800*s,-100, 860+800*s,0, 760+800*s,100)
        end
    end
    if flashT>0 then gc.setColor(1,1,1,flashT/.3*.15)
        gc.rectangle('fill',-1000,-600,2000,1200)
    end
    BUTTON.draw()
end
function menu.exit()
    local s=fs.newFile('player/unlocked')
    s:open('w')
    s:write(json.encode(menu.unlocked))
    s:close()
end
function menu.gameSend(destScene,arg)
    destScene.mode=arg
    destScene.exitScene='menu'
    print('success')
end
return menu