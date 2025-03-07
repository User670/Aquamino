local otto={}
function otto.addSFX()
    sfx.add({
        die='sfx/game/otto/die.wav',
        win='sfx/game/otto/win.wav',
        move='sfx/game/otto/move.wav',
        moveFail='sfx/game/otto/move fail.wav',
        landedMove='sfx/game/otto/landed move.wav',
        HD='sfx/game/otto/hard drop.wav',
        --lock='sfx/game/otto/lock.wav',
        hold='sfx/game/otto/hold.wav',
        rotate='sfx/game/otto/rotate.wav',
        spin='sfx/game/otto/spin.wav',
        rotateFail='sfx/game/otto/rotate fail.wav',
        touch='sfx/game/otto/touch.wav',

        ['1']='sfx/game/otto/1.wav',
        ['2']='sfx/game/otto/2.wav',
        ['3']='sfx/game/otto/3.wav',
        ['4']='sfx/game/otto/4.wav',
        mini='sfx/game/otto/mini.wav',
        spin0='sfx/game/otto/spin0.wav',
        spin1='sfx/game/otto/spin1.wav',
        spin2='sfx/game/otto/spin2.wav',
        spin3='sfx/game/otto/spin3.wav',
        PC='sfx/game/otto/PC.wav',
        B2B='sfx/game/otto/B2B.wav',
        megacombo='sfx/game/otto/megacombo.wav',
        wtf='sfx/game/otto/wtf.wav',
    })
end
function otto.move(player,success,landed)
    if success then
        if landed and sfx.pack.landedMove then sfx.play('landedMove') else sfx.play('move') end
    else sfx.play('moveFail') end
end
function otto.rotate(player,success,spin)
    if success then
        if spin then sfx.play('spin')
        else sfx.play('rotate')end
    else sfx.play('rotateFail') end
end
function otto.hold(player)
    sfx.play('hold')
end
function otto.touch(player,touch)
    if touch then sfx.play('touch') end
end
function otto.lock(player)
    --if player.history.dropHeight>0 then sfx.play('HD',.3+.7*player.history.dropHeight/player.h)
    --else sfx.play('lock') end
    sfx.play('HD')
end
function otto.clear(player)
    local his=player.history
    local clearType=(his.spin and 'spin' or '')..min(his.line,(his.spin and 3 or 4))
    local pitch=his.line==0 and 1 or min(2^((his.combo-1)/12),2.848)
    local vol=his.mini and 0 or 1
    if (his.spin and 1 or 0)+floor(his.line/4)+(his.PC and 1 or 0)>=2 then
        sfx.play('wtf') return
    end
    sfx.play(clearType,vol,pitch)
    if his.mini then sfx.play('mini') end
    if his.PC then sfx.play('PC') end
    if his.B2B>0 and his.line>0 then sfx.play('B2B') end
    if his.combo>=18 then sfx.play('megacombo') end
end
function otto.win()
    sfx.play('win')
end
function otto.die()
    sfx.play('die')
end
return otto