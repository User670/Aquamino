--necessary loading.
do
    local audio=require'scene/game conf/audio'
    audio.read() audio.save()
    local video=require'scene/game conf/video'
    video.read() video.save()
    local hand=require'scene/game conf/handling'
    hand.read() hand.save()
    local key=require'scene/game conf/keys'
    key.read() key.save()
    local custom=require'scene/game conf/custom'
    custom.read() custom.save()
end

do
    if fs.getInfo('player/game stat') then
        local s=fs.newFile('player/game stat')
        local k=json.decode(s:read())
        win.stat.launch=k.launch+1
        s:open('w')
        s:write(json.encode(win.stat))
        s:close()
    else
        local s=fs.newFile('player/game stat')
        win.stat.launch=1
        s:open('w')
        s:write(json.encode(win.stat))
        s:close()
    end
end