local M,T=mymath,mytable

local video={}
local BUTTON,SLIDER=scene.button,scene.slider
function video.read()
    video.info={unableBG=false,vsync=false,fullscr=false}
    if fs.getInfo('conf/video') then T.combine(video.info,json.decode(fs.newFile('conf/video'):read())) end
    win.setFullscr(video.info.fullscr)
end
function video.save()
    local s=fs.newFile('conf/video')
    s:open('w')
    s:write(json.encode(video.info))
    love.window.setVSync(video.info.vsync and 1 or 0)
end
function video.init()
    scene.BG=require'BG/space' scene.BG.init()
    video.info.fullscr=win.fullscr video.save() video.read()

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h,6)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h,6)
            gc.setColor(1,1,1)
            gc.printf("Back",Exo_2_SB,0,0,1280,'center',0,.5,.5,640,84)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
                anim=function() anim.cover(.1,.05,.1,0,0,0) end
            })
        end
    })

    BUTTON.create('unableBG',{
        x=-750,y=-240,type='rect',w=100,h=100,
        draw=function(bt,t,ct)
            local animArg=video.info.unableBG and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.75,animArg)
            gc.setColor(.5,1,.75,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(10)
            gc.rectangle('line',-w/2+5,-h/2+5,h-10,h-10)
            if video.info.unableBG then
                gc.circle('line',0,0,(w/2-5)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf("Disable BG",Exo_2_SB,w/2+50,0,1200,'left',0,.35,.35,0,84)
            gc.setColor(1,1,1,.75)
            gc.printf("Enable if background makes you uncomfortable.",Exo_2_SB,-w/2,h/2+60,1840,'left',0,.25,.25,0,152)
        end,
        event=function()
            video.info.unableBG=not video.info.unableBG
        end
    },.2)
    BUTTON.create('vsync',{
        x=-750,y=0,type='rect',w=100,h=100,
        draw=function(bt,t,ct)
            local animArg=video.info.vsync and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.75,animArg)
            gc.setColor(.5,1,.75,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(10)
            gc.rectangle('line',-w/2+5,-h/2+5,h-10,h-10)
            if video.info.vsync then
                gc.circle('line',0,0,(w/2-5)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf("VSync",Exo_2_SB,w/2+50,0,1200,'left',0,.35,.35,0,84)
            gc.setColor(1,1,1,.75)
            gc.printf("If game lags or has tearing, try toggling this. Usually recommended to be disabled.",Exo_2_SB,-w/2,h/2+64,1840,'left',0,.25,.25,0,152)
        end,
        event=function()
            video.info.vsync=not video.info.vsync
            love.window.setVSync(video.info.vsync and 1 or 0)
        end
    },.2)
    BUTTON.create('fullscr',{
        x=-180,y=-240,type='rect',w=100,h=100,
        draw=function(bt,t,ct)
            local animArg=video.info.fullscr and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.75,animArg)
            gc.setColor(.5,1,.75,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(10)
            gc.rectangle('line',-w/2+5,-h/2+5,h-10,h-10)
            if video.info.fullscr then
                gc.circle('line',0,0,(w/2-5)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf("Full screen",Exo_2_SB,w/2+50,0,1200,'left',0,.35,.35,0,84)
            gc.setColor(1,1,1,.75)
            gc.printf("Can also toggle with F11.",Exo_2_SB,-w/2,h/2+64,1840,'left',0,.25,.25,0,152)
        end,
        event=function()
            video.info.fullscr=not video.info.fullscr
            win.setFullscr(video.info.fullscr)
        end
    },.2)
end
function video.detectKeyP(k)
    if k=='f11' then video.info.fullscr=win.fullscr end
end
function video.mouseP(x,y,button,istouch)
    if not BUTTON.click(x,y,button,istouch) and SLIDER.mouseP(x,y,button,istouch) then end
end
function video.mouseR(x,y,button,istouch)

end
function video.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    end
end
function video.draw()
    gc.setColor(1,1,1)
    gc.printf("Graphics",SYHT,0,-460,1280,'center',0,1,1,640,64)
    BUTTON.draw() SLIDER.draw()
end
function video.exit()
    video.save()
end
return video