--[[
Mokey Mokey Peace King
LIGHT / Fairy / Link / Link-3
ATK: 2400
Arrows: Bottom Left, Bottom Center, Bottom Right
Materials: 2+ Fairy monsters, including at least 1 "Mokey Mokey" Fusion Monster

Effect:
"Mokey Mokey" monsters this card points to gain 1500 ATK/DEF, also they are unaffected by your opponent's card effects. 
You can discard 1 card; add 1 card that specifically lists "Mokey Mokey" in its text, from your Deck to your hand, or, if "Realm of Mokey Mokey" is on the field, you can add 1 Fairy monster instead. 
If this Link Summoned card is destroyed: You can Special Summon as many "Mokey Mokey" as possible from your GY. 
You can only use each effect of "Mokey Mokey Peace King" once per turn.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Link Material
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),2,3,s.lcheck)
	
	-- ATK/DEF boost and protection for pointed monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.atktg)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
	
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	
	-- Search effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	
	-- Special Summon when destroyed
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end

-- Link Material check
function s.lcheck(g,lc,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_FUSION,lc,SUMMON_TYPE_LINK,tp) and #g>=2
end

-- ATK/DEF and protection for pointed monsters
function s.atktg(e,c)
	local zone=bit.band(e:GetHandler():GetLinkedZone(),0xff)
	return c:IsFaceup() and (c:IsCode(12482652) or c:IsSetCard(0x184)) 
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(e:GetHandlerPlayer())
		and bit.band(bit.rshift(zone,c:GetSequence()),1)~=0
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Search effect
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.thfilter(c,realm)
	if realm then
		return c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
	else
		return c:IsAbleToHand() and 
			   (c:GetText():find("Mokey Mokey") or c:ListsArchetype(0x184))
	end
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local realm=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_FZONE,0,1,nil,72727272) -- Realm of Mokey Mokey
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,realm) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local realm=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_FZONE,0,1,nil,72727272) -- Realm of Mokey Mokey
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,realm)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Special Summon when destroyed
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end

function s.spfilter(c,e,tp)
	return (c:IsCode(12482652) or c:IsSetCard(0x184)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end
	
	if #g<=ft then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,ft,ft,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
