local hand={}
local BUTTON,SLIDER=scene.button,scene.slider
local T=mytable
function hand.read()
    hand.ctrl={ASD=.15,ASP=.03,SD_ASD=0,SD_ASP=.05}
    if fs.getInfo('conf/ctrl') then
        T.combine(hand.ctrl,json.decode(fs.newFile('conf/ctrl'):read()))
    end
    
end
function hand.save()
    local s=fs.newFile('conf/ctrl')
    s:open('w')
    s:write(json.encode(hand.ctrl))
end
function hand.init()
    scene.BG=require'BG/space' scene.BG.init()
    hand.read()

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

    SLIDER.create('ASD',{
        x=-380,y=-250,type='hori',sz={1000,32},button={32,32},
        gear=0,pos=hand.ctrl.ASD/.2,
        sliderDraw=function()
            gc.setColor(.5,.5,.5,.8)
            gc.rectangle('fill',-516,-16,1032,32)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(6)
            gc.rectangle('line',-519,-19,1038,38)
            gc.setColor(1,1,1)
            gc.printf(string.format("Auto Shift Delay (ASD, DAS): %.0fms = %.2fF(60 FPS)",hand.ctrl.ASD*1000,hand.ctrl.ASD*60),
                Consolas,-519,-48,114514,'left',0,.3125,.3125,0,56)
        end,
        buttonDraw=function(pos)
            gc.setColor(1,1,1)
            gc.rectangle('fill',1000*(pos-.5)-16,-18,32,36)
        end,
        always=function(pos)
            hand.ctrl.ASD=.2*pos
        end
    })
    SLIDER.create('ARR',{
        x=-380,y=-125,type='hori',sz={1000,32},button={32,32},
        gear=0,pos=hand.ctrl.ASP/.1,
        sliderDraw=function()
            gc.setColor(.5,.5,.5,.8)
            gc.rectangle('fill',-516,-16,1032,32)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(6)
            gc.rectangle('line',-519,-19,1038,38)
            gc.setColor(1,1,1)
            gc.printf(string.format("Auto Shift Period (ASP, ARR): %.0fms = %.2fF(60 FPS)",hand.ctrl.ASP*1000,hand.ctrl.ASP*60),
                Consolas,-519,-48,114514,'left',0,.3125,.3125,0,56)
        end,
        buttonDraw=function(pos)
            gc.setColor(1,1,1)
            gc.rectangle('fill',1000*(pos-.5)-16,-18,32,36)
        end,
        always=function(pos)
            hand.ctrl.ASP=.1*pos
        end
    })
    SLIDER.create('SD_ASD',{
        x=-380,y=0,type='hori',sz={1000,32},button={32,32},
        gear=0,pos=hand.ctrl.SD_ASD/.2,
        sliderDraw=function()
            gc.setColor(.5,.5,.5,.8)
            gc.rectangle('fill',-516,-16,1032,32)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(6)
            gc.rectangle('line',-519,-19,1038,38)
            gc.setColor(1,1,1)
            gc.printf(string.format("Soft drop ASD: %.0fms = %.2fF(60 FPS)",hand.ctrl.SD_ASD*1000,hand.ctrl.SD_ASD*60),
                Consolas,-519,-48,114514,'left',0,.3125,.3125,0,56)
        end,
        buttonDraw=function(pos)
            gc.setColor(1,1,1)
            gc.rectangle('fill',1000*(pos-.5)-16,-18,32,36)
        end,
        always=function(pos)
            hand.ctrl.SD_ASD=.2*pos
        end
    })
    SLIDER.create('SD_ARR',{
        x=-380,y=125,type='hori',sz={1000,32},button={32,32},
        gear=0,pos=hand.ctrl.SD_ASP/.1,
        sliderDraw=function()
            gc.setColor(.5,.5,.5,.8)
            gc.rectangle('fill',-516,-16,1032,32)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(6)
            gc.rectangle('line',-519,-19,1038,38)
            gc.setColor(1,1,1)
            gc.printf(string.format("Soft drop ASP:%.0fms = %.2fF(60 FPS)",hand.ctrl.SD_ASP*1000,hand.ctrl.SD_ASP*60),
                Consolas,-519,-48,114514,'left',0,.3125,.3125,0,56)
        end,
        buttonDraw=function(pos)
            gc.setColor(1,1,1)
            gc.rectangle('fill',1000*(pos-.5)-16,-18,32,36)
        end,
        always=function(pos)
            hand.ctrl.SD_ASP=.1*pos
        end
    })
end
function hand.mouseP(x,y,button,istouch)
    if not BUTTON.click(x,y,button,istouch) and SLIDER.mouseP(x,y,button,istouch) then end
end
function hand.mouseR(x,y,button,istouch)
    SLIDER.mouseR(x,y,button,istouch)
end
function hand.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    end
end
function hand.draw()
    gc.setColor(1,1,1)
    gc.printf("Handling",SYHT,0,-460,1280,'center',0,1,1,640,64)
    BUTTON.draw() SLIDER.draw()
end
function hand.exit()
    hand.save()
end
return hand