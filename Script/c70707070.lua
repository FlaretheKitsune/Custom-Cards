--Mokey Mokey Ascension
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-------------------------------------------------
	-- If a "Mokey Mokey" monster(s) YOU CONTROL is sent to GY:
	-- All "Mokey Mokey" you CURRENTLY control gain 1000 ATK until the end of this turn.
	-- (mandatory trigger so it can't be missed)
	-------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- Once per turn: Special Summon 1 "Mokey Mokey" from your hand
	-------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-------------------------------------------------
	-- If destroyed by your opponent while face-up: add 1 "Mokey Mokey" card from Deck
	-------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- Treat these as "Mokey Mokey" by name in case your DB doesn't tag them with set 0x184
local CODE_MOKEY_MOKEY	  = 27288416
local CODE_MOKEY_MOKEY_KING = 13803864

s.listed_series={0x184}
s.listed_names={CODE_MOKEY_MOKEY, CODE_MOKEY_MOKEY_KING}

-- Helper: is a "Mokey Mokey" monster?
local function isMokey(c)
	return c:IsSetCard(0x184) or c:IsCode(CODE_MOKEY_MOKEY, CODE_MOKEY_MOKEY_KING)
end

-------------------------------------------------
-- ATK boost trigger
-------------------------------------------------
-- any "Mokey Mokey" YOU controlled on the field that went to GY
function s.gyfilter(c,tp)
	return c:IsType(TYPE_MONSTER)
		and isMokey(c)
		and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gyfilter,1,nil,tp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- "currently control" → snapshot your field now and buff only those
	local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and isMokey(c) end,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-------------------------------------------------
-- Special Summon from hand (OPT)
-------------------------------------------------
function s.spfilter(c,e,tp)
	return isMokey(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-------------------------------------------------
-- Search when destroyed by opponent (face-up on field)
-------------------------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp
		and (r&(REASON_EFFECT+REASON_BATTLE))~=0
		and c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsPreviousPosition(POS_FACEUP)
end
function s.thfilter(c)
	return (isMokey(c) or c:IsSetCard(0x184)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end