
-- Elemental Tyrant of Earth - Dread Scarab
local s,id=GetID()

local SET_TYRANT=0x666
local COUNTER_CARAPACE=0x667

s.listed_series={SET_TYRANT}
s.counter_place_list={COUNTER_CARAPACE}

function s.initial_effect(c)

	c:EnableCounterPermit(COUNTER_CARAPACE)

	--------------------------------------------------
	-- EFFECT 1:
	-- Special Summon itself from hand when your
	-- face-up EARTH card is destroyed.
	--------------------------------------------------

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--------------------------------------------------
	-- EFFECT 2:
	-- Gain Carapace Counters when monsters are
	-- destroyed and sent to the Graveyard.
	--------------------------------------------------

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)

	--------------------------------------------------
	-- EFFECT 3:
	-- Gain 200 ATK for each Carapace Counter.
	--------------------------------------------------

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.statval)
	c:RegisterEffect(e3)

	--------------------------------------------------
	-- EFFECT 4:
	-- Gain 200 DEF for each Carapace Counter.
	--------------------------------------------------

	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)

	--------------------------------------------------
	-- EFFECT 5:
	-- Unaffected by ALL opponent's card effects
	-- while it has 3 or more Carapace Counters.
	--------------------------------------------------

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetCondition(s.imcon)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)

end

--------------------------------------------------
-- DESTROYED EARTH CARD FILTER
--------------------------------------------------

function s.spfilter(c,tp,sc)
	return c~=sc
		and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP)
		and (c:GetPreviousAttributeOnField()&ATTRIBUTE_EARTH)~=0
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp,e:GetHandler())
end

--------------------------------------------------
-- SPECIAL SUMMON TARGET
--------------------------------------------------

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

--------------------------------------------------
-- SPECIAL SUMMON OPERATION
--------------------------------------------------

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then

		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)

	end
end

--------------------------------------------------
-- COUNTER FILTER
--------------------------------------------------

function s.ctfilter(c)
	return c:IsMonster()
		and c:IsReason(REASON_DESTROY)
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter,1,nil)
end

--------------------------------------------------
-- ADD CARAPACE COUNTERS
--------------------------------------------------

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if not c:IsFaceup() then return end

	local ct=eg:FilterCount(s.ctfilter,nil)

	if ct>0 then
		c:AddCounter(COUNTER_CARAPACE,ct)
	end
end

--------------------------------------------------
-- ATK / DEF CALCULATION
--------------------------------------------------

function s.statval(e,c)
	return c:GetCounter(COUNTER_CARAPACE)*200
end

--------------------------------------------------
-- IMMUNITY CONDITION
--------------------------------------------------

function s.imcon(e)
	return e:GetHandler():GetCounter(COUNTER_CARAPACE)>=3
end

--------------------------------------------------
-- IMMUNITY FILTER
-- Ignores all effects owned by the opponent.
--------------------------------------------------

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
