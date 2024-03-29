-- MineRoper script
-- created by rhino [2012-06-02]
-- version 0.14/alpha [2014-01-21]
-- see full license at:
-- https://github.com/cerosrhino/hedgewars-scripts/blob/master/LICENSE

-- CHANGELOG
-- 0.08 -> 0.09
-- -- better key bindings (more suitable for shoppa)
-- 0.10 -> 0.11
-- -- added customization capabilities via schemes:
-- -- -- mines setting defines the bullets count (max: 6, default: 5)
-- -- -- mines timer multiplied by the dud mines percentage defines the bullet
--       fuse time (the dud multiplier is ignored if set to 0)
-- -- -- (you must explicitly set the mines number to a non-zero value in order
--       for any of your settings to take effect)
-- 0.11 -> 0.12
-- -- cleaned the code up a bit and documented it partially
-- 0.12 -> 0.13
-- -- got rid of trigonometry and floating point operations in favor of
--    precomputed values, now the game will not desync anymore
-- 0.13 -> 0.14
-- -- a few minor changes

-- KNOWN ISSUES
-- bullets getting stuck within concrete

-- TODO
-- implement power-ups (double time, extra bullets, random teleport etc.)


local bullets = {}
local maxBullets = 5
local angle = 0
local bulletFireFactor = 2
local bulletFuse = 400
local hpPenalty = 8

local fixedAngles = {360, 180, 120, 90, 72, 60}
local fixedOffsets = {{0, 30}, {1, 30}, {1, 30}, {2, 30}, {2, 30}, {3, 30}, {3, 30}, {4, 30}, {4, 30}, {5, 30}, {5, 30}, {6, 29}, {6, 29}, {7, 29}, {7, 29}, {8, 29}, {8, 29}, {9, 29}, {9, 29}, {10, 28}, {10, 28}, {11, 28}, {11, 28}, {12, 28}, {12, 27}, {13, 27}, {13, 27}, {14, 27}, {14, 26}, {15, 26}, {15, 26}, {15, 26}, {16, 25}, {16, 25}, {17, 25}, {17, 25}, {18, 24}, {18, 24}, {18, 24}, {19, 23}, {19, 23}, {20, 23}, {20, 22}, {20, 22}, {21, 22}, {21, 21}, {22, 21}, {22, 20}, {22, 20}, {23, 20}, {23, 19}, {23, 19}, {24, 18}, {24, 18}, {24, 18}, {25, 17}, {25, 17}, {25, 16}, {25, 16}, {26, 15}, {26, 15}, {26, 15}, {26, 14}, {27, 14}, {27, 13}, {27, 13}, {27, 12}, {28, 12}, {28, 11}, {28, 11}, {28, 10}, {28, 10}, {29, 9}, {29, 9}, {29, 8}, {29, 8}, {29, 7}, {29, 7}, {29, 6}, {29, 6}, {30, 5}, {30, 5}, {30, 4}, {30, 4}, {30, 3}, {30, 3}, {30, 2}, {30, 2}, {30, 1}, {30, 1}, {30, 0}, {30, -1}, {30, -1}, {30, -2}, {30, -2}, {30, -3}, {30, -3}, {30, -4}, {30, -4}, {30, -5}, {30, -5}, {29, -6}, {29, -6}, {29, -7}, {29, -7}, {29, -8}, {29, -8}, {29, -9}, {29, -9}, {28, -10}, {28, -10}, {28, -11}, {28, -11}, {28, -12}, {27, -12}, {27, -13}, {27, -13}, {27, -14}, {26, -14}, {26, -15}, {26, -15}, {26, -15}, {25, -16}, {25, -16}, {25, -17}, {25, -17}, {24, -18}, {24, -18}, {24, -18}, {23, -19}, {23, -19}, {23, -20}, {22, -20}, {22, -20}, {22, -21}, {21, -21}, {21, -22}, {20, -22}, {20, -22}, {20, -23}, {19, -23}, {19, -23}, {18, -24}, {18, -24}, {18, -24}, {17, -25}, {17, -25}, {16, -25}, {16, -25}, {15, -26}, {15, -26}, {15, -26}, {14, -26}, {14, -27}, {13, -27}, {13, -27}, {12, -27}, {12, -28}, {11, -28}, {11, -28}, {10, -28}, {10, -28}, {9, -29}, {9, -29}, {8, -29}, {8, -29}, {7, -29}, {7, -29}, {6, -29}, {6, -29}, {5, -30}, {5, -30}, {4, -30}, {4, -30}, {3, -30}, {3, -30}, {2, -30}, {2, -30}, {1, -30}, {1, -30}, {0, -30}, {-1, -30}, {-1, -30}, {-2, -30}, {-2, -30}, {-3, -30}, {-3, -30}, {-4, -30}, {-4, -30}, {-5, -30}, {-5, -30}, {-6, -29}, {-6, -29}, {-7, -29}, {-7, -29}, {-8, -29}, {-8, -29}, {-9, -29}, {-9, -29}, {-10, -28}, {-10, -28}, {-11, -28}, {-11, -28}, {-12, -28}, {-12, -27}, {-13, -27}, {-13, -27}, {-14, -27}, {-14, -26}, {-15, -26}, {-15, -26}, {-15, -26}, {-16, -25}, {-16, -25}, {-17, -25}, {-17, -25}, {-18, -24}, {-18, -24}, {-18, -24}, {-19, -23}, {-19, -23}, {-20, -23}, {-20, -22}, {-20, -22}, {-21, -22}, {-21, -21}, {-22, -21}, {-22, -20}, {-22, -20}, {-23, -20}, {-23, -19}, {-23, -19}, {-24, -18}, {-24, -18}, {-24, -18}, {-25, -17}, {-25, -17}, {-25, -16}, {-25, -16}, {-26, -15}, {-26, -15}, {-26, -15}, {-26, -14}, {-27, -14}, {-27, -13}, {-27, -13}, {-27, -12}, {-28, -12}, {-28, -11}, {-28, -11}, {-28, -10}, {-28, -10}, {-29, -9}, {-29, -9}, {-29, -8}, {-29, -8}, {-29, -7}, {-29, -7}, {-29, -6}, {-29, -6}, {-30, -5}, {-30, -5}, {-30, -4}, {-30, -4}, {-30, -3}, {-30, -3}, {-30, -2}, {-30, -2}, {-30, -1}, {-30, -1}, {-30, 0}, {-30, 1}, {-30, 1}, {-30, 2}, {-30, 2}, {-30, 3}, {-30, 3}, {-30, 4}, {-30, 4}, {-30, 5}, {-30, 5}, {-29, 6}, {-29, 6}, {-29, 7}, {-29, 7}, {-29, 8}, {-29, 8}, {-29, 9}, {-29, 9}, {-28, 10}, {-28, 10}, {-28, 11}, {-28, 11}, {-28, 12}, {-27, 12}, {-27, 13}, {-27, 13}, {-27, 14}, {-26, 14}, {-26, 15}, {-26, 15}, {-26, 15}, {-25, 16}, {-25, 16}, {-25, 17}, {-25, 17}, {-24, 18}, {-24, 18}, {-24, 18}, {-23, 19}, {-23, 19}, {-23, 20}, {-22, 20}, {-22, 20}, {-22, 21}, {-21, 21}, {-21, 22}, {-20, 22}, {-20, 22}, {-20, 23}, {-19, 23}, {-19, 23}, {-18, 24}, {-18, 24}, {-18, 24}, {-17, 25}, {-17, 25}, {-16, 25}, {-16, 25}, {-15, 26}, {-15, 26}, {-15, 26}, {-14, 26}, {-14, 27}, {-13, 27}, {-13, 27}, {-12, 27}, {-12, 28}, {-11, 28}, {-11, 28}, {-10, 28}, {-10, 28}, {-9, 29}, {-9, 29}, {-8, 29}, {-8, 29}, {-7, 29}, {-7, 29}, {-6, 29}, {-6, 29}, {-5, 30}, {-5, 30}, {-4, 30}, {-4, 30}, {-3, 30}, {-3, 30}, {-2, 30}, {-2, 30}, {-1, 30}, {-1, 30}}
local fixedSpreadVelocities = {{0, 650000}, {11344, 649901}, {22685, 649604}, {34018, 649109}, {45342, 648417}, {56651, 647527}, {67944, 646439}, {79215, 645155}, {90463, 643674}, {101682, 641997}, {112871, 640125}, {124026, 638058}, {135143, 635796}, {146218, 633341}, {157249, 630692}, {168232, 627852}, {179164, 624820}, {190042, 621598}, {200861, 618187}, {211619, 614587}, {222313, 610800}, {232939, 606827}, {243494, 602670}, {253975, 598328}, {264379, 593805}, {274702, 589100}, {284941, 584216}, {295094, 579154}, {305157, 573916}, {315126, 568503}, {325000, 562917}, {334775, 557159}, {344448, 551231}, {354015, 545136}, {363475, 538874}, {372825, 532449}, {382060, 525861}, {391180, 519113}, {400180, 512207}, {409058, 505145}, {417812, 497929}, {426438, 490561}, {434935, 483044}, {443299, 475380}, {451528, 467571}, {459619, 459619}, {467571, 451528}, {475380, 443299}, {483044, 434935}, {490561, 426438}, {497929, 417812}, {505145, 409058}, {512207, 400180}, {519113, 391180}, {525861, 382060}, {532449, 372825}, {538874, 363475}, {545136, 354015}, {551231, 344448}, {557159, 334775}, {562917, 325000}, {568503, 315126}, {573916, 305157}, {579154, 295094}, {584216, 284941}, {589100, 274702}, {593805, 264379}, {598328, 253975}, {602670, 243494}, {606827, 232939}, {610800, 222313}, {614587, 211619}, {618187, 200861}, {621598, 190042}, {624820, 179164}, {627852, 168232}, {630692, 157249}, {633341, 146218}, {635796, 135143}, {638058, 124026}, {640125, 112871}, {641997, 101682}, {643674, 90463}, {645155, 79215}, {646439, 67944}, {647527, 56651}, {648417, 45342}, {649109, 34018}, {649604, 22685}, {649901, 11344}, {650000, 0}, {649901, -11344}, {649604, -22685}, {649109, -34018}, {648417, -45342}, {647527, -56651}, {646439, -67944}, {645155, -79215}, {643674, -90463}, {641997, -101682}, {640125, -112871}, {638058, -124026}, {635796, -135143}, {633341, -146218}, {630692, -157249}, {627852, -168232}, {624820, -179164}, {621598, -190042}, {618187, -200861}, {614587, -211619}, {610800, -222313}, {606827, -232939}, {602670, -243494}, {598328, -253975}, {593805, -264379}, {589100, -274702}, {584216, -284941}, {579154, -295094}, {573916, -305157}, {568503, -315126}, {562917, -325000}, {557159, -334775}, {551231, -344448}, {545136, -354015}, {538874, -363475}, {532449, -372825}, {525861, -382060}, {519113, -391180}, {512207, -400180}, {505145, -409058}, {497929, -417812}, {490561, -426438}, {483044, -434935}, {475380, -443299}, {467571, -451528}, {459619, -459619}, {451528, -467571}, {443299, -475380}, {434935, -483044}, {426438, -490561}, {417812, -497929}, {409058, -505145}, {400180, -512207}, {391180, -519113}, {382060, -525861}, {372825, -532449}, {363475, -538874}, {354015, -545136}, {344448, -551231}, {334775, -557159}, {325000, -562917}, {315126, -568503}, {305157, -573916}, {295094, -579154}, {284941, -584216}, {274702, -589100}, {264379, -593805}, {253975, -598328}, {243494, -602670}, {232939, -606827}, {222313, -610800}, {211619, -614587}, {200861, -618187}, {190042, -621598}, {179164, -624820}, {168232, -627852}, {157249, -630692}, {146218, -633341}, {135143, -635796}, {124026, -638058}, {112871, -640125}, {101682, -641997}, {90463, -643674}, {79215, -645155}, {67944, -646439}, {56651, -647527}, {45342, -648417}, {34018, -649109}, {22685, -649604}, {11344, -649901}, {0, -650000}, {-11344, -649901}, {-22685, -649604}, {-34018, -649109}, {-45342, -648417}, {-56651, -647527}, {-67944, -646439}, {-79215, -645155}, {-90463, -643674}, {-101682, -641997}, {-112871, -640125}, {-124026, -638058}, {-135143, -635796}, {-146218, -633341}, {-157249, -630692}, {-168232, -627852}, {-179164, -624820}, {-190042, -621598}, {-200861, -618187}, {-211619, -614587}, {-222313, -610800}, {-232939, -606827}, {-243494, -602670}, {-253975, -598328}, {-264379, -593805}, {-274702, -589100}, {-284941, -584216}, {-295094, -579154}, {-305157, -573916}, {-315126, -568503}, {-325000, -562917}, {-334775, -557159}, {-344448, -551231}, {-354015, -545136}, {-363475, -538874}, {-372825, -532449}, {-382060, -525861}, {-391180, -519113}, {-400180, -512207}, {-409058, -505145}, {-417812, -497929}, {-426438, -490561}, {-434935, -483044}, {-443299, -475380}, {-451528, -467571}, {-459619, -459619}, {-467571, -451528}, {-475380, -443299}, {-483044, -434935}, {-490561, -426438}, {-497929, -417812}, {-505145, -409058}, {-512207, -400180}, {-519113, -391180}, {-525861, -382060}, {-532449, -372825}, {-538874, -363475}, {-545136, -354015}, {-551231, -344448}, {-557159, -334775}, {-562917, -325000}, {-568503, -315126}, {-573916, -305157}, {-579154, -295094}, {-584216, -284941}, {-589100, -274702}, {-593805, -264379}, {-598328, -253975}, {-602670, -243494}, {-606827, -232939}, {-610800, -222313}, {-614587, -211619}, {-618187, -200861}, {-621598, -190042}, {-624820, -179164}, {-627852, -168232}, {-630692, -157249}, {-633341, -146218}, {-635796, -135143}, {-638058, -124026}, {-640125, -112871}, {-641997, -101682}, {-643674, -90463}, {-645155, -79215}, {-646439, -67944}, {-647527, -56651}, {-648417, -45342}, {-649109, -34018}, {-649604, -22685}, {-649901, -11344}, {-650000, 0}, {-649901, 11344}, {-649604, 22685}, {-649109, 34018}, {-648417, 45342}, {-647527, 56651}, {-646439, 67944}, {-645155, 79215}, {-643674, 90463}, {-641997, 101682}, {-640125, 112871}, {-638058, 124026}, {-635796, 135143}, {-633341, 146218}, {-630692, 157249}, {-627852, 168232}, {-624820, 179164}, {-621598, 190042}, {-618187, 200861}, {-614587, 211619}, {-610800, 222313}, {-606827, 232939}, {-602670, 243494}, {-598328, 253975}, {-593805, 264379}, {-589100, 274702}, {-584216, 284941}, {-579154, 295094}, {-573916, 305157}, {-568503, 315126}, {-562917, 325000}, {-557159, 334775}, {-551231, 344448}, {-545136, 354015}, {-538874, 363475}, {-532449, 372825}, {-525861, 382060}, {-519113, 391180}, {-512207, 400180}, {-505145, 409058}, {-497929, 417812}, {-490561, 426438}, {-483044, 434935}, {-475380, 443299}, {-467571, 451528}, {-459619, 459619}, {-451528, 467571}, {-443299, 475380}, {-434935, 483044}, {-426438, 490561}, {-417812, 497929}, {-409058, 505145}, {-400180, 512207}, {-391180, 519113}, {-382060, 525861}, {-372825, 532449}, {-363475, 538874}, {-354015, 545136}, {-344448, 551231}, {-334775, 557159}, {-325000, 562917}, {-315126, 568503}, {-305157, 573916}, {-295094, 579154}, {-284941, 584216}, {-274702, 589100}, {-264379, 593805}, {-253975, 598328}, {-243494, 602670}, {-232939, 606827}, {-222313, 610800}, {-211619, 614587}, {-200861, 618187}, {-190042, 621598}, {-179164, 624820}, {-168232, 627852}, {-157249, 630692}, {-146218, 633341}, {-135143, 635796}, {-124026, 638058}, {-112871, 640125}, {-101682, 641997}, {-90463, 643674}, {-79215, 645155}, {-67944, 646439}, {-56651, 647527}, {-45342, 648417}, {-34018, 649109}, {-22685, 649604}, {-11344, 649901}}


function fuseMine(gear)
    if (GetGearType(gear) == gtMine) then
        SetState(gear, bor(GetState(gear), bor(gsttmpFlag, gstAttacking)))
    end
end


function onGameInit()
    if (MinesNum > 0) then
        maxBullets = math.min(6, MinesNum)
        if (MinesTime > 0) then
            bulletFuse = MinesTime
            if (MineDudPercent > 0) then
                bulletFuse = bulletFuse * MineDudPercent / 100
            end
        end
    end
    GameFlags = gfSolidLand + gfBorder + gfDisableWind
    CaseFreq = 0
    MinesNum = 0
    MineDudPercent = 0
    Ready = 5000
end

function onGameStart()
    local strBulletFuse = bulletFuse .. 'ms'
    if (bulletFuse % 1000 == 0) then
        strBulletFuse = bulletFuse / 1000 .. 's'
    end
    ShowMission('Mine fight!', 'Show them what you\'ve got!',
                'Jump/Enter: Fire a bullet|Switch/Tab: Special attack (results'
                .. ' in a health loss penalty; also ends your turn)|-----|Turn'
                .. ' time: ' .. TurnTime / 1000 .. 's|Bullets: ' .. maxBullets
                .. '|Bullet fuse: ' .. strBulletFuse .. '|Special attack'
                .. ' penalty: ' .. hpPenalty .. 'hp multiplied by the number of'
                .. ' bullets|-----|Tip: If you don\'t mind sacrificing one of'
                .. ' your hedgehogs,|fall onto the enemy while holding bullets'
                .. ' to cause serious damage!|Remember, falling hurts a lot!',
                -amMine, 5000)
end

function onAmmoStoreInit()
    SetAmmo(amRope, 9, 0, 0, 0)
    SetAmmo(amSkip, 9, 0, 0, 0)
end

function onGameTick()
    if (CurrentHedgehog ~= nil and #bullets > 0) then
        for k, v in ipairs(bullets) do
            local bulletAngle = (angle + (k - 1) * fixedAngles[#bullets]) % 360
            SetGearPosition(v, GetX(CurrentHedgehog) +
                                 fixedOffsets[bulletAngle + 1][1],
                               GetY(CurrentHedgehog) +
                                 fixedOffsets[bulletAngle + 1][2])
            SetGearVelocity(v, 0, 0) -- to avoid glitchy looking spinning mines
        end
        
        angle = GetX(CurrentHedgehog) * 2
        
        if (TurnTimeLeft == 0) then
            for i = 1, #bullets do
                DeleteGear(bullets[i])
            end
            bullets = {}
        end
    end
end

function onNewTurn()
    for i = 1, maxBullets do
        bullets[i] = AddGear(0, 0, gtMine, 0, 0, 0, 0)
        SetTimer(bullets[i], 1) -- 0?
    end
end

function onLJump()
    if (CurrentHedgehog ~= nil and #bullets > 0) then
        local dx, dy = GetGearVelocity(CurrentHedgehog)
        if (band(GetState(CurrentHedgehog), gstMoving) == gstMoving) then
            local bullet = table.remove(bullets, 1)
            SetGearVelocity(bullet,
                            dx * bulletFireFactor, dy * bulletFireFactor)
            SetTimer(bullet, bulletFuse)
            fuseMine(bullet)
        end
    end
    if (#bullets == 0) then
        TurnTimeLeft = 3000
    end
end

function onSwitch()
    if (CurrentHedgehog ~= nil and #bullets > 0) then
        local dx, dy = GetGearVelocity(CurrentHedgehog)
        if (band(GetState(CurrentHedgehog), gstMoving) == gstMoving) then
            local hp = GetHealth(CurrentHedgehog)
            if (hp > hpPenalty * #bullets) then
                hp = hp - hpPenalty * #bullets
            else
                AddCaption('You don\'t have enough health points to use the'
                           .. ' special attack!')
                return
            end
            SetHealth(CurrentHedgehog, hp)
            for k, v in ipairs(bullets) do
                local bulletAngle =
                        (angle + (k - 1) * fixedAngles[#bullets]) % 360
                SetGearVelocity(v, fixedSpreadVelocities[bulletAngle + 1][1],
                                   fixedSpreadVelocities[bulletAngle + 1][2])
                SetHealth(v, 0)
            end
            bullets = {}
            TurnTimeLeft = 3000
        else
            AddCaption('You can use the special attack only while airborne!')
        end
    end
end

function onHogAttack()
    if (GetCurAmmoType() == amSkip) then
        for i = 1, #bullets do
            DeleteGear(bullets[i]) -- delete the mines to avoid explosions
        end
        bullets = {}
    end
end

function onGearDamage(gear)
    if (gear == CurrentHedgehog) then
        for i = 1, #bullets do
            fuseMine(bullets[i])
        end
        bullets = {}
    end
end
