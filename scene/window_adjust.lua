local adjust={}
local flore=math.floor
local winposx,winposy=love.window.getPosition()
local movespeed=200
local width,height,wininfo=nil,nil,nil
function adjust.init()
    width,height,wininfo=love.window.getMode()
    wininfo.borderless=false wininfo.resizable=true
    love.window.setMode(width,height,wininfo)
end
function adjust.keyP(k)
    if k=='escape' then
        iswinadjust=false adjust.quit()
    elseif k=='r' then
        wininfo.x,wininfo.y=nil,nil
        love.window.setMode(1120,630,wininfo)
        winposx,winposy=love.window.getPosition()
        win.W,win.H=gc.getDimensions()
        adaptAllWindow=love.math.newTransform(
            win.W/2,win.H/2,0,
            win.H/win.W<9/16 and win.H/1080 or win.W/1920,win.H/win.W<9/16 and win.H/1080 or win.W/1920
        )
    end
end
function adjust.update(dt)
    if kb.isDown('w','a','s','d','up','down','left','right') then
        movespeed=min(movespeed+250*dt,800)
        if kb.isDown('w','up') then winposy=winposy-dt*movespeed end
        if kb.isDown('s','down') then winposy=winposy+dt*movespeed end
        if kb.isDown('a','left') then winposx=winposx-dt*movespeed end
        if kb.isDown('d','right') then winposx=winposx+dt*movespeed end
        love.window.setPosition(flore(winposx+.5),flore(winposy+.5))
    else movespeed=200 end
    winposx,winposy=love.window.getPosition()
    win.x_win,win.y_win=winposx,winposy
    width,height=gc.getDimensions()
end 
function adjust.draw()
    gc.setColor(.1,.4,.2,.5)
    gc.rectangle('fill',-1000,-600,2000,1200)
    gc.setColor(1,1,1)
    gc.setFont(Exo_2)
    gc.printf("Window Adjuster",-1000,-500,2000,'center',0,1,1)
    gc.printf(
[[
Press W/A/S/D and arrow keys to adjust window position.
Press R to reset resolution to 1120x630 and position to center of the screen.
]],
        -4000,-262.6,20000,'center',0,.4,.4)
    gc.printf("Current window position (top left): "..flore(winposx+.5).." , "..flore(winposy+.5).."\nCurrent resolution: "..width.."*"..height,
        -6000,-84.8,20000,'center',0,.6,.6)
end
function adjust.quit()
    if not love.window.getFullscreen() then
    movespeed=200
    wininfo.borderless=true wininfo.x=winposx wininfo.y=winposy
    love.window.setMode(width,height,wininfo) width,height=gc.getDimensions()
    else local w,h,m=love.window.getMode() 
        m.borderless=true m.x,m.y=win.x_win,win.y_win
        love.window.setMode(win.W_win,win.H_win,m)
    end
end
return adjust