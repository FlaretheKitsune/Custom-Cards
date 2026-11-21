-- Metallic Terrageddon
local s,id=GetID()

local CARD_HYDROGEDDON=22587018
local CARD_WATER_DRAGON=8506680

function s.initial_effect(c)
	-- Its name becomes "Hydrogeddon" while in the hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetValue(CARD_HYDROGEDDON)
	c:RegisterEffect(e1)

	-- WATER monsters you control are unaffected by activated effects
	-- from FIRE monsters and Pyro monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.imtg)
	e2:SetValue(s.imval)
	c:RegisterEffect(e2)

	-- If Normal or Special Summoned: Search 1 "Bonding" Spell/Trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end

function s.imtg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end

function s.imval(e,te)
	if not te:IsActivated() or not te:IsActiveType(TYPE_MONSTER) then
		return false
	end
	local tc=te:GetHandler()
	return tc:IsAttribute(ATTRIBUTE_FIRE) or tc:IsRace(RACE_PYRO)
end

function s.bondfilter(c)
	return c:IsSpellTrap()
		and c:IsSetCard(SET_BONDING)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.bondfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.bondfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end

	local tc=g:GetFirst()
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,tc)

	-- If you control "Water Dragon", summon a Deck monster
	-- listed in the text of the card that was added
	if not Duel.IsExistingMatchingCard(Card.IsCode,tp,
		LOCATION_MZONE,0,1,nil,CARD_WATER_DRAGON) then
		return
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.listedfilter,tp,
		LOCATION_DECK,0,1,1,nil,e,tp,tc)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.listedfilter(c,e,tp,added)
	return c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and added:ListsCode(c:GetCode())
end