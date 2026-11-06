-- Earthbound Seed
local s,id=GetID()

function s.initial_effect(c)
    -- Destroy this card if there is no face-up Field Spell
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- If this card is destroyed: Special Summon 1 "Earthbound Immortal"
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

function s.fieldfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_FIELD)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and not Duel.IsExistingMatchingCard(
        s.fieldfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil
    ) then
        Duel.Destroy(c,REASON_EFFECT)
    end
end

function s.imfilter(c,e,tp)
    return c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
        and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.imfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp
            )
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.imfilter,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        -- Earthbound Immortals normally cannot be Special Summoned;
        -- the card text needs to allow ignoring their Summoning conditions.
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
end
