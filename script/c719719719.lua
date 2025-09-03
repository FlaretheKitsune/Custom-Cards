--[[
Mokey Mokey Confused Rage
LIGHT / Fairy / Link / Link-2
ATK: 600
Arrows: (Bottom, Bottom Right)
Materials: 2 Fairy monsters, including at least 1 "Mokey Mokey" monster

Effect:
If this card is Link Summoned: You can Special Summon 1 "Mokey Mokey" monster from your Deck, hand, or GY. 
"Mokey Mokey" monsters this card points to gain 1000 ATK/DEF, also they cannot be destroyed by card effects. 
Each time your opponent takes battle damage involving a "Mokey Mokey": This card gains ATK equal to the damage they took, until the end of this turn.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Link Material
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),2,2,s.lcheck)
	
	-- Special Summon on Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	-- ATK/DEF boost and destruction protection for pointed monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.atktg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	
	-- ATK gain when opponent takes battle damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLE_DAMAGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon2)
	e5:SetOperation(s.atkop2)
	c:RegisterEffect(e5)
end

-- Link Material check
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x184,lc,sumtype,tp)
end

-- Special Summon condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Special Summon target
function s.spfilter(c,e,tp,zone)
	return (c:IsCode(12482652) or c:IsSetCard(0x184)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end

-- Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end

-- ATK/DEF and protection for pointed monsters
function s.atktg(e,c)
	local zone=bit.band(e:GetHandler():GetLinkedZone(),0xff)
	return c:IsFaceup() and (c:IsCode(12482652) or c:IsSetCard(0x184)) 
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(e:GetHandlerPlayer())
		and bit.band(bit.rshift(zone,c:GetSequence()),1)~=0
end

-- ATK gain when opponent takes battle damage
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:IsExists(Card.IsSetCard,1,nil,0x184)
end

function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
