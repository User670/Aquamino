local warn={}
local bannedkey={'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12','tab'}
function warn.init()
    scene.BG=require'BG/blank'
end
function warn.switch()
    scene.switch({
        dest='intro',swapT=.7,outT=.3,
        anim=function() anim.cover(.3,.4,.3,0,0,0) end
    })
end
function warn.keyP(k)
    if k=='escape' then love.event.quit() else warn.switch() end
end
function warn.mouseP(x,y,button,istouch)
    warn.switch()
end
local title="Epilepsy warning"
local txt="Some people have epileptic sympotoms under certain visual stimuli.\nSymptoms include dizziness, blurred vision, twitching, disorientation, confusion, or brief loss of consciousness.\n\nEven people with no history if epilepsy may have these symptoms.\nShould any symptoms occur, stop playing and consult a doctor."
function warn.draw()
    gc.clear(.08,.08,.08)

    gc.setColor(1,1,1,2*scene.time-.5)
    gc.printf(title,Exo_2,0,-300,1000,'center',0,.6,.6,500,84)
    gc.setColor(.5,1,.75,2*scene.time-.5)
    gc.printf(txt,Exo_2,0,-160,4000,'center',0,50/128,50/128,2000,84)

end
--function intro.send() scene.cur.modename[1]="40行" end
return warn