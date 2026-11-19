-- Alchemic Bonding
-- Card ID: 79
-- Water Dragon Cluster: 6022371
local s,id=GetID()
local CARD_WATER_DRAGON_CLUSTER=6022371

function s.initial_effect(c)
    c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsCode,id),LOCATION_ONFIELD)

    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Once per turn: Tribute 1 Dinosaur;
    -- Special Summon 1 Level 4 or lower Dinosaur with an allowed Attribute
    -- different from the Tributed monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.tcost)
    e2:SetTarget(s.ttg)
    e2:SetOperation(s.top)
    c:RegisterEffect(e2)

    -- If this card is destroyed by a card effect:
    -- Banish 3 Dinosaurs with different Attributes;
    -- Special Summon "Water Dragon Cluster"
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- Destroy this card during your 2nd Standby Phase after activation
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.descon)
    e1:SetOperation(s.desop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
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

    if ct==2 then
        Duel.Destroy(c,REASON_EFFECT)
    end
end

function s.tribfilter(c)
    return c:IsRace(RACE_DINOSAUR)
        and c:IsAbleToGraveAsCost()
end

function s.tcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tribfilter,tp,
            LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tribfilter,tp,
        LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
    e:SetLabel(g:GetFirst():GetAttribute())
end

function s.sptribfilter(c,att)
    return c:IsRace(RACE_DINOSAUR)
        and c:IsLevelBelow(4)
        and (c:IsAttribute(ATTRIBUTE_EARTH)
            or c:IsAttribute(ATTRIBUTE_WATER)
            or c:IsAttribute(ATTRIBUTE_FIRE)
            or c:IsAttribute(ATTRIBUTE_WIND))
        and c:GetAttribute()~=att
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.ttg(e,tp,eg,ep,ev,re,r,rp,chk)
    local att=e:GetLabel()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.sptribfilter,tp,
                LOCATION_DECK,0,1,nil,att)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.top(e,tp,eg,ep,ev,re,r,rp)
    local att=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.sptribfilter,tp,
        LOCATION_DECK,0,1,1,nil,att)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
        and e:GetHandler():IsReason(REASON_EFFECT)
end

function s.dinofilter(c)
    return c:IsMonster()
        and c:IsRace(RACE_DINOSAUR)
        and c:IsAbleToRemove()
end

function s.banishcheck(sg,e,tp,mg)
    return sg:GetClassCount(Card.GetAttribute)==3
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.dinofilter,tp,LOCATION_GRAVE,0,nil)
    if chk==0 then
        return aux.SelectUnselectGroup(g,e,tp,3,3,s.banishcheck,0)
            and Duel.IsExistingMatchingCard(Card.IsCode,tp,
                LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,
                CARD_WATER_DRAGON_CLUSTER)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.dinofilter,tp,LOCATION_GRAVE,0,nil)
    if #g<3 then return end

    local rg=aux.SelectUnselectGroup(g,e,tp,3,3,s.banishcheck,1,tp,HINTMSG_REMOVE)
    if not rg or #rg~=3 then return end

    if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,Card.IsCode,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,
        CARD_WATER_DRAGON_CLUSTER)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
    end
end
