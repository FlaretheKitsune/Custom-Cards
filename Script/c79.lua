
-- Alchemic Bonding
-- Card ID: 79
-- Legendary Chemist: 75
-- Water Dragon Cluster: 6022371

local s,id=GetID()
local CARD_LEGENDARY_CHEMIST=75
local CARD_WATER_DRAGON_CLUSTER=6022371

function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)

    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetTarget(s.target)
    c:RegisterEffect(e1)

    -- Once per turn: Tribute 1 Legendary Chemist or Dinosaur
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.tg)
    e2:SetOperation(s.op)
    c:RegisterEffect(e2)

    -- If destroyed by a card effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Activation timer
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end

    local c=e:GetHandler()

    -- Destroy during your 2nd Standby Phase
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.descon)
    e1:SetOperation(s.desop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+
        RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
    c:SetTurnCounter(0)
    c:RegisterEffect(e1)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=c:GetTurnCounter()+1
    c:SetTurnCounter(ct)

    if ct==2 and c:IsFaceup() then
        Duel.Destroy(c,REASON_EFFECT)
    end
end

-- Tribute filter
function s.tribfilter(c,e,tp)
    if not (c:IsCode(CARD_LEGENDARY_CHEMIST)
        or c:IsRace(RACE_DINOSAUR)) then
        return false
    end

    -- Must be possible to Tribute
    if c:IsLocation(LOCATION_MZONE) then
        if not c:IsReleasable() then return false end
    elseif not c:IsAbleToGraveAsCost() then
        return false
    end

    -- Must have a valid Dinosaur with a different Attribute
    return Duel.IsExistingMatchingCard(
        s.spfilter,tp,LOCATION_DECK,0,1,nil,
        e,tp,c:GetAttribute()
    )
end

-- Deck monster filter
function s.spfilter(c,e,tp,att)
    return c:IsRace(RACE_DINOSAUR)
        and c:IsLevelBelow(4)
        and (c:IsAttribute(ATTRIBUTE_EARTH)
            or c:IsAttribute(ATTRIBUTE_WATER)
            or c:IsAttribute(ATTRIBUTE_FIRE)
            or c:IsAttribute(ATTRIBUTE_WIND))
        and (att==nil or c:GetAttribute()~=att)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Tribute cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.tribfilter,tp,
                LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp
            )
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)

    local g=Duel.SelectMatchingCard(
        tp,s.tribfilter,tp,
        LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp
    )

    local tc=g:GetFirst()
    if tc then
        -- Save Attribute before Tributing
        e:SetLabel(tc:GetAttribute())

        -- Tribute the selected monster
        Duel.Release(g,REASON_COST)
    end
end

-- Target
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.spfilter,tp,LOCATION_DECK,0,1,nil,
                e,tp,nil
            )
    end

    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK
    )
end

-- Special Summon from Deck
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local att=e:GetLabel()

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local g=Duel.SelectMatchingCard(
        tp,s.spfilter,tp,
        LOCATION_DECK,0,1,1,nil,e,tp,att
    )

    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Destruction effect condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
        and e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end

-- Dinosaur GY filter
function s.dino3filter(c)
    return c:IsMonster() and c:IsRace(RACE_DINOSAUR)
end

-- Check for 3 different Attributes
function s.banishcheck(sg,e,tp,mg)
    return sg:GetClassCount(Card.GetAttribute)==3
end

-- Destruction effect target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(
            s.dino3filter,tp,LOCATION_GRAVE,0,nil
        )

        return #g>=3 and aux.SelectUnselectGroup(
            g,e,tp,3,3,s.banishcheck,0
        )
    end

    local g=Duel.GetMatchingGroup(
        s.dino3filter,tp,LOCATION_GRAVE,0,nil
    )

    local rg=aux.SelectUnselectGroup(
        g,e,tp,3,3,s.banishcheck,1,tp,HINTMSG_REMOVE
    )

    Duel.SetTargetCard(rg)

    Duel.SetOperationInfo(
        0,CATEGORY_REMOVE,rg,#rg,0,0
    )

    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE
    )
end

-- Special Summon Water Dragon Cluster
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local rg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)

    if rg then
        rg=rg:Filter(Card.IsRelateToEffect,nil,e)
    end

    if not rg or #rg~=3 then return end

    if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=3 then
        return
    end

    local g=Duel.GetMatchingGroup(
        function(tc)
            return tc:IsCode(CARD_WATER_DRAGON_CLUSTER)
                and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
        end,
        tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
        0,nil
    )

    if #g==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local sg=g:Select(tp,1,1,nil)

    Duel.SpecialSummon(
        sg,0,tp,tp,true,false,POS_FACEUP
    )
end

c79=Card(79)
