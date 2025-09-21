--[[
Destined HERO - Bloodshade
DARK / Warrior / Effect / Level 5
ATK 1600 / DEF 1800

Effect:
This card's name is treated as "Elemental HERO Necroshade" while on the field or in the GY.
If a "Destined HERO" or "Destiny HERO" monster would be destroyed by battle or card effect, 
you can banish this card from your GY instead. 
If this card is banished: You can Special Summon 1 "Destined HERO" monster from your hand or Deck.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Treat as "Elemental HERO Necroshade"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(89252153) -- Elemental HERO Necroshade
	c:RegisterEffect(e1)
	
	-- Substitute destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	
	-- Special Summon when banished
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

-- Substitute destruction functions
function s.repfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x1122) or c:IsSetCard(0xc008)) -- Destined HERO or Destiny HERO
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
end

-- Special Summon functions
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1122) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsMonster()
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
