-- Plasma Carboneddon
local s,id=GetID()

-- Replace with the actual database code for "Carboneddon"
local CARD_CARBONEDDON=15981690
local SET_BONDING=0x100

function s.initial_effect(c)
	-- Name becomes "Carboneddon" while in the hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetValue(CARD_CARBONEDDON)
	c:RegisterEffect(e1)

	-- At the start of the Damage Step, banish the battling monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)

	-- If this card is sent to the GY:
	-- Add 1 Bonding Spell/Trap, then send 1 listed monster to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

function s.bantarget(c)
	return c and c:IsRelateToBattle()
		and not c:IsAttribute(ATTRIBUTE_WATER)
		and not c:IsRace(RACE_SEASERPENT)
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then
		return bc and bc:IsControler(1-tp)
			and s.bantarget(bc)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() and s.bantarget(bc) then
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end

function s.thfilter(c)
	return c:IsSetCard(SET_BONDING)
		and c:IsSpellTrap()
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,
			LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.textlistedfilter(c,added)
	return c:IsMonster()
		and c:IsAbleToGrave()
		and added:ListsCode(c:GetCode())
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,
		LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end

	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,tc)

	local g=Duel.GetMatchingGroup(s.textlistedfilter,tp,
		LOCATION_DECK,0,nil,tc)
	if #g==0 or not Duel.SelectYesNo(tp,94) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end