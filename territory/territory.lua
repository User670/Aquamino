local LP=love.physics
local setColor=gc.setColor
local circle,rect,poly=gc.circle,gc.rectangle,gc.polygon
local printf=gc.printf

local supplyRemain=15
local supplyT,supplyTLimit=60,60
local obsList={--障碍分布，用Algodoo作出，坐标需乘以80，y轴需反转
    {-1.2,1.1},{-.4,1.1},{.4,1.1},{1.2,1.1},
    {-1.6,.3},{0,.3},{1.6,.3},
    {-1.2,-0.5},{1.2,-0.5},
    {-.8,-1.3},{0,-1.3},{.8,-1.3}
}
local teamColor={
    {1,.5,.5},{1,1,.5},{.5,1,.75},{.625,.5,1}
}
local fieldColor={
    {.6,0,0},{.6,.6,0},{0,.6,.3},{.15,0,.6}
}
local txtColor={
    {1,0,0},{1,1,0},{0,1,.5},{.34,.12,1}
}
local war={}
local function newBall(m,n,t)
    war.ctrl.ball[t][#war.ctrl.ball[t]+1]={
        body=LP.newBody(war.world,m,n-10*16,'dynamic'),
        shape=LP.newCircleShape(16),
    }
    local b=war.ctrl.ball[t][#war.ctrl.ball[t]]
    b.body:setLinearVelocity(rand()<.5 and 3 or -3,0)
    b.fixture=LP.newFixture(b.body,b.shape,1)
    b.fixture:setCategory(t)
    b.fixture:setMask(t)
    war.teamBelong[b.fixture]=t
    b.fixture:setFriction(0) b.fixture:setRestitution(.8)
end
function war.alivePlayer()
    local a=0
    for i=1,#war.team.alive do
        if war.team.alive[i] then a=a+1 end
    end
    return a
end
function war.init()
    war.team={
        alive={true,true,true,true},
        bulletS={1,1,1,1},--储存多少子弹
        bulletR={1024,1024,1024,1024},--要射出多少子弹
        rCool={0,0,0,0},rCoolT=1/64--子弹发射速度频率为1/rCoolT，cool意为冷却
    }
    war.teamBelong={}
    war.bulletLimit=512

    war.sim=false
    war.angle=1--炮台角度参数
    war.time=0
    war.world=LP.newWorld(0,0) war.world:setSleepingAllowed(false)
    LP.setMeter(16)
    war.field={}--领土场地
    war.edge={}--场地边界
    war.ctrl={edge={},obs={},cmd={},ball={}}--控制区 边界、障碍、指令、小球
    war.cannon={}--炮台
    war.bullet={}--炮弹
    war.onCollide={}--储存碰撞函数
    war.type={}--物体种类

    function war.shoot(x,y,vx,vy,team)
        war.bullet[#war.bullet+1]={
            body=LP.newBody(war.world,x,y,'dynamic'),
            shape=LP.newCircleShape(4),
        }
        local b=war.bullet[#war.bullet]
        b.body:setLinearVelocity(vx,vy)
        b.fixture=LP.newFixture(b.body,b.shape,1)
        b.fixture:setCategory(team)
        b.fixture:setMask(team)
        b.fixture:setFriction(0) b.fixture:setRestitution(1)
        war.onCollide[b.fixture]=function(this,other)
            if other:isDestroyed() or war.type[other]=='edge' then return end
            if war.type[other]=='cannon' then
                other:getBody():destroy()
                print(war.team[war.teamBelong[other]])
            return end
            other:setCategory(this:getCategory())
            other:setMask(this:getMask())
            this:getBody():destroy()
        end
    end

    for i=1,4 do--创建边界
        if i<=2 then
            war.edge[i]={
                body=LP.newBody(war.world,0,(-32+i%2*64)*12.25,'static'),
                shape=LP.newRectangleShape(32*25,16),
            }
        else
            war.edge[i]={
                body=LP.newBody(war.world,(-32+i%2*64)*12.25,0,'static'),
                shape=LP.newRectangleShape(16,32*25),
            }
        end
        war.edge[i].fixture=LP.newFixture(war.edge[i].body,war.edge[i].shape,1)
        war.edge[i].fixture:setCategory(5)
        war.edge[i].fixture:setFriction(0)
        war.edge[i].fixture:setRestitution(1)
        war.type[war.edge[i].fixture]='edge'
    end
    for t=1,4 do--创建控制区边界以及障碍物
        local m,n=(25+10)*((t-1)%2*2-1)*16,12.5*(floor((t-1)/2)*2-1)*16
        local left=t%2==1
        war.ctrl.edge[t]={}
        for i=1,4 do
            if i<=2 then
                war.ctrl.edge[t][i]={
                    body=LP.newBody(war.world,m,n+(-12+i%2*24)*16,'static'),
                    shape=LP.newRectangleShape(20*16,16),
                }
            else
                war.ctrl.edge[t][i]={
                    body=LP.newBody(war.world,m+(-9.5+i%2*19)*16,n,'static'),
                    shape=LP.newRectangleShape(16,25*16),
                }
            end
            war.ctrl.edge[t][i].fixture=LP.newFixture(war.ctrl.edge[t][i].body,war.ctrl.edge[t][i].shape,1)
            war.ctrl.edge[t][i].fixture:setCategory(5)
            war.ctrl.edge[t][i].fixture:setFriction(0)
            war.ctrl.edge[t][i].fixture:setRestitution(.8)
            war.type[war.ctrl.edge[t][i].fixture]='edge'
            war.teamBelong[war.ctrl.edge[t][i].fixture]=t
        end

        --x2和发射
        war.ctrl.cmd[t]={}
        war.ctrl.cmd[t].mtp={
            body=LP.newBody(war.world,m+(left and -1 or 1)*60,n+10.5*16,'static'),
            shape=LP.newRectangleShape(10.5*16,32),
        }
        war.ctrl.cmd[t].mtp.fixture=LP.newFixture(war.ctrl.cmd[t].mtp.body,war.ctrl.cmd[t].mtp.shape,1)
        war.ctrl.cmd[t].mtp.fixture:setCategory(5)
        war.onCollide[war.ctrl.cmd[t].mtp.fixture]=function(this,other)
            if not war.team.alive[t] or war.team.bulletR[t]>0 or war.alivePlayer()<2 then return end
            war.team.bulletS[t]=min(war.team.bulletS[t]*2,war.bulletLimit)
            local b=other:getBody()
            b:setX(m) b:setY(n-10*16)
            b:setLinearVelocity((rand()-.5)*200,0)
        end
        war.ctrl.cmd[t].rel={
            body=LP.newBody(war.world,m-(left and -1 or 1)*84,n+10.5*16,'static'),
            shape=LP.newRectangleShape(7.5*16,32),
        }
        war.ctrl.cmd[t].rel.fixture=LP.newFixture(war.ctrl.cmd[t].rel.body,war.ctrl.cmd[t].rel.shape,1)
        war.ctrl.cmd[t].rel.fixture:setCategory(5)
        war.onCollide[war.ctrl.cmd[t].rel.fixture]=function(this,other)
            if not war.team.alive[t] or war.team.bulletR[t]>0 or war.alivePlayer()<2 then return end
            if war.team.bulletS[t]==war.bulletLimit then war.bulletLimit=war.bulletLimit*2 end
            war.team.bulletR[t]=war.team.bulletS[t] war.team.bulletS[t]=1
            local b=other:getBody()
            b:setX(m) b:setY(n-10*16)
            b:setLinearVelocity((rand()-.5)*100,0)
        end
        --障碍物
        for i=1,#obsList do
            war.ctrl.obs[#war.ctrl.obs+1]={
                body=LP.newBody(war.world,m+80*obsList[i][1],n-80*obsList[i][2],'static'),
                shape=LP.newCircleShape(12),
            }
            local u=war.ctrl.obs[#war.ctrl.obs]
            u.fixture=LP.newFixture(u.body,u.shape,1)
            u.fixture:setCategory(5)
            u.fixture:setRestitution(.8)
        end
        --新的小球
        war.ctrl.ball[t]={}
        newBall(m,n,t)
    end
    for i=1,4 do--创建炮台
        war.cannon[i]={
            body=LP.newBody(war.world,(-32+(i-1)%2*64)*11,(-32+floor((i-1)/2)*64)*11,'static'),
            shape=LP.newCircleShape(16),
        }
        war.cannon[i].fixture=LP.newFixture(war.cannon[i].body,war.cannon[i].shape,1)
        war.cannon[i].fixture:setCategory(i)
        war.cannon[i].fixture:setMask(i)
        war.cannon[i].fixture:setRestitution(1)
        war.type[war.cannon[i].fixture]='cannon'
        war.teamBelong[war.cannon[i].fixture]=i

        war.onCollide[war.cannon[i].fixture]=function(this,other)
            war.team.alive[war.teamBelong[this]]=false
            --this:getBody():destroy()
        end
    end

    for i=1,48 do--创建领土并设置分类与遮罩
        war.field[i]={}
        for j=1,48 do
            war.field[i][j]={
                body=LP.newBody(war.world,16*(i-24.5),16*(j-24.5),'static'),
                shape=LP.newRectangleShape(16,16),
            }
            war.field[i][j].fixture=LP.newFixture(war.field[i][j].body,war.field[i][j].shape,1)
            war.field[i][j].fixture:setRestitution(0.5)
            if i<=24 then
                if j<=24 then
                war.field[i][j].fixture:setCategory(1)
                war.field[i][j].fixture:setMask(1)
                else
                war.field[i][j].fixture:setCategory(3)
                war.field[i][j].fixture:setMask(3)
                end
            else
                if j<=24 then
                war.field[i][j].fixture:setCategory(2)
                war.field[i][j].fixture:setMask(2)
                else
                war.field[i][j].fixture:setCategory(4)
                war.field[i][j].fixture:setMask(4)
                end
            end
        end
    end
end
function war.keyP(k)
    if k=='space' or k=='return' then war.sim=not war.sim
    end
end
local fa,fb
function war.update(dt)
    if war.sim then
        local cList=war.world:getContacts()
        for i=1,#cList do
            if not cList[i]:isDestroyed() and cList[i]:isTouching() then fa,fb=cList[i]:getFixtures()
                if war.onCollide[fa] then war.onCollide[fa](fa,fb) end
                if war.onCollide[fb] then war.onCollide[fb](fb,fa) end
            end
        end
        for i=#war.bullet,1,-1 do--移除已销毁炮弹
            if war.bullet[i].body:isDestroyed() then table.remove(war.bullet,i) end
        end

        for i=1,#war.ctrl.ball do  for j=1,#war.ctrl.ball[i] do --所有小球受到40m/(s^2)的重力
            u=war.ctrl.ball[i][j]
            u.body:applyForce(0,u.body:getMass()*640)
            local vx,vy=u.body:getLinearVelocity()
            if abs(vx)<=4 and abs(vy)<=4 then u.body:setLinearVelocity((rand()-.5)*32,(rand()-.5)*32) end--兄弟你动啊
        end  end

        supplyT=supplyT-dt
        if supplyT<=0 and supplyRemain>0 then
            for t=1,4 do
                newBall((25+10)*((t-1)%2*2-1)*16,12.5*(floor((t-1)/2)*2-1)*16,t)
            end
            supplyT=supplyT+supplyTLimit
            supplyRemain=supplyRemain-1
        end


        war.world:update(dt,1,1) war.time=war.time+dt
        war.angle=abs(war.time%2-1)

        for i=1,4 do
        local a,b=(i-1)%2*2-1,i>2 and 1 or -1
        if war.team.bulletR[i]>0 and war.team.alive[i] then war.team.rCool[i]=war.team.rCool[i]-dt
            if war.team.rCool[i]<0 then
                war.team.rCool[i]=war.team.rCool[i]+war.team.rCoolT
                war.team.bulletR[i]=war.team.bulletR[i]-1
                local r=((i==1 and 0 or i==2 and .5 or i==3 and 1.5 or i==4 and 1)+(war.angle*.52-.01))*math.pi
                war.shoot(a*11*32+30*cos(r),b*11*32+30*sin(r),256*cos(r),256*sin(r),i)
            end
        end
        end
    end
end
local clr,u
function war.draw()
    gc.push()
    gc.scale(1.25)
    --gc.setColor(1,1,1)
    --for i=-50,50 do circle('fill',64*i,0,8,4) circle('fill',0,64*i,8,4) end
    setColor(.8,.8,.8)
    for i=1,#war.edge do
        u=war.edge[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end
    for i=1,#war.field do
        for j=1,#war.field[i] do
            u=war.field[i][j]
            setColor(fieldColor[u.fixture:getMask()])
            --poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
            rect('fill',16*(i-25),16*(j-25),16,16)
        end
    end
    for i=1,#war.ctrl.edge do  for j=1,#war.ctrl.edge[i] do
        u=war.ctrl.edge[i][j]
        setColor(teamColor[war.teamBelong[u.fixture]])
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end  end
    for i=1,#war.ctrl.cmd do
        if war.team.alive[i] and war.team.bulletR[i]==0 then gc.setColor(1,0,0) else gc.setColor(.5,.5,.5) end
        poly('fill',war.ctrl.cmd[i].rel.body:getWorldPoints(war.ctrl.cmd[i].rel.shape:getPoints()))
        setColor(1,0,0,.5)
        printf('FIRE',Consolas,war.ctrl.cmd[i].rel.body:getX(),war.ctrl.cmd[i].rel.body:getY()-32,1280,'center',0,.25,.25,640,56)
        if war.team.alive[i] and war.team.bulletR[i]==0 then gc.setColor(0,1,0) else gc.setColor(.5,.5,.5) end
        poly('fill',war.ctrl.cmd[i].mtp.body:getWorldPoints(war.ctrl.cmd[i].mtp.shape:getPoints()))
        setColor(0,1,0,.5)
        printf('x2',Consolas,war.ctrl.cmd[i].mtp.body:getX(),war.ctrl.cmd[i].mtp.body:getY()-32,1280,'center',0,.25,.25,640,56)
    end
    gc.setColor(1,1,1,.8)
    for i=1,#war.ctrl.obs do
        u=war.ctrl.obs[i]
        gc.circle('fill',u.body:getX(),u.body:getY(),12)
    end
    for i=1,#war.ctrl.ball do  for j=1,#war.ctrl.ball[i] do
        u=war.ctrl.ball[i][j]
        setColor(teamColor[war.teamBelong[u.fixture]])
        circle('fill',u.body:getX(),u.body:getY(),16)
    end  end
    for i=1,4 do
        local c=txtColor[i]
        local m,n=(25+10)*((i-1)%2*2-1)*16,12.5*(floor((i-1)/2)*2-1)*16
        if war.team.bulletR[i]>0 then gc.setColor(c[1],c[2],c[3],.5)
            printf(""..war.team.bulletR[i],Consolas_B,m,n,1280,'center',0,.75,.75,640,56)
        else
            if war.team.bulletS[i]==war.bulletLimit then gc.setColor(c[1],c[2],c[3],.5) else gc.setColor(.75,.75,.75,.5) end
            printf(""..war.team.bulletS[i],Consolas_B,m,n,1280,'center',0,.75,.75,640,56)
        end
    end

    for i=1,#war.bullet do
        if not war.bullet[i].body:isDestroyed() then
            local x,y=war.bullet[i].body:getPosition()
            setColor(teamColor[war.bullet[i].fixture:getMask()])
            circle('fill',x,y,4,8)
        end
    end
    for i=1,#war.cannon do
        local m=war.teamBelong[war.cannon[i].fixture]
        if not war.cannon[i].body:isDestroyed() then
        gc.push('transform')
        local x,y=war.cannon[i].body:getPosition()
        gc.translate(x,y)
        setColor(teamColor[m])
        circle('fill',0,0,16)
        gc.rotate(((m==1 and 0 or m==2 and .5 or m==3 and 1.5 or m==4 and 1)+(war.angle*.52-.01))*math.pi)
        gc.setLineWidth(8)
        gc.line(18,12,30,0,18,-12)
        gc.pop()
        end
    end

    setColor(1,1,1,.3)
    printf(string.format("%02d:%02d",war.time/60,war.time%60),Consolas_B,0,0,10000,'center',0,1,1,5000,56)
    setColor(1,1,1,2+supplyT-supplyTLimit)--显示新球已加入
    printf("New balls added.",Consolas_B,0,0,10000,'center',0,.5,.5,5000,56)

    gc.pop()
end
return war