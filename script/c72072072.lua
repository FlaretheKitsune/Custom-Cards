--[[
Mokey Mokey the Forbidden One
LIGHT / Fairy / Level 1 / Effect / ATK ? / DEF 300
Effect:
This card's name becomes "Mokey Mokey" and is treated as a Normal Monster while face-up on the field or in the GY.
If this card is Normal or Special Summoned: You can Special Summon 1 "Mokey Mokey" monster from your Deck in Defense Position.
This card gains 300 ATK for each "Mokey Mokey" in your GY.
If there are 3 "Mokey Mokey the Forbidden One" cards in your GY: "Mokey Mokey" monsters you control cannot be destroyed by card effects.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Name becomes "Mokey Mokey" and treated as Normal Monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(12482652) -- Original "Mokey Mokey" code
	c:RegisterEffect(e1)
	
	-- Treated as Normal Monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e2:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e3)
	
	-- Special Summon "Mokey Mokey" from Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	
	-- ATK gain effect
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)
	
	-- Protection effect when 3 in GY
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(s.indtg)
	e7:SetValue(1)
	e7:SetCondition(s.indcon)
	c:RegisterEffect(e7)
end

-- Special Summon "Mokey Mokey" from Deck
function s.spfilter(c,e,tp)
	return (c:IsCode(12482652) or c:IsSetCard(0x184)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

-- ATK gain calculation
function s.atkfilter(c)
	return c:IsCode(12482652) or c:IsSetCard(0x184)
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end

-- Protection effect condition
function s.indcon(e)
	return Duel.GetMatchingGroupCount(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,id)>=3
end

function s.indtg(e,c)
	return c:IsCode(12482652) or c:IsSetCard(0x184)
end
