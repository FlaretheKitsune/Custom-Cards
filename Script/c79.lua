-- Alchemic Bonding
-- Card ID: 79
-- Water Dragon Cluster: 6022371
local s,id=GetID()
local CARD_WATER_DRAGON_CLUSTER=6022371

function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)

    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Destroy this card during your 2nd Standby Phase after activation
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.descon)
    e2:SetOperation(s.desop)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,3)
    c:SetTurnCounter(0)
    c:RegisterEffect(e2)

    -- Once per turn: Tribute 1 Dinosaur monster from your hand or field; Special Summon 1 Level 4 or lower EARTH/WATER/FIRE/WIND Dinosaur with a different Attribute
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.cost)
    e3:SetTarget(s.tg)
    e3:SetOperation(s.op)
    c:RegisterEffect(e3)

    -- If this card is destroyed by a card effect: Banish 3 Dinosaur monsters with different Attributes from your GY; Special Summon "Water Dragon Cluster"
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=c:GetTurnCounter()
    ct=ct+1
    c:SetTurnCounter(ct)
    if ct==2 then
        Duel.SendtoGrave(c,REASON_EFFECT)
    end
end

function s.tribfilter(c)
    return c:IsRace(RACE_DINOSAUR)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tribfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tribfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
    e:SetLabel(g:GetFirst():GetAttribute())
end

function s.spfilter(c,att)
    return c:IsRace(RACE_DINOSAUR)
        and c:IsLevelBelow(4)
        and (c:IsAttribute(ATTRIBUTE_EARTH) or c:IsAttribute(ATTRIBUTE_WATER) or c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_WIND))
        and c:GetAttribute()~=att
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel())
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
    local att=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,att)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

function s.dino3filter(c)
    return c:IsRace(RACE_DINOSAUR) and c:IsMonster()
end

function s.banishcheck(sg,e,tp,mg)
    return sg:GetClassCount(Card.GetAttribute)==3
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.dino3filter,tp,LOCATION_GRAVE,0,nil)
        return #g>=3 and aux.SelectUnselectGroup(g,e,tp,3,3,s.banishcheck,0)
    end
    local g=Duel.GetMatchingGroup(s.dino3filter,tp,LOCATION_GRAVE,0,nil)
    local rg=aux.SelectUnselectGroup(g,e,tp,3,3,s.banishcheck,1,tp,HINTMSG_REMOVE)
    Duel.SetTargetCard(rg)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local rg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if rg then
        rg=rg:Filter(Card.IsRelateToEffect,nil,e)
    end
    if rg and #rg>0 then
        Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,CARD_WATER_DRAGON_CLUSTER)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
end

c79=Card(79)
