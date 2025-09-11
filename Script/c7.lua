--[[
Ghost Mage, the Underworld Necromancer
DARK / Fiend / Synchro / Effect
Level 7 / ATK 2500 / DEF 2000

1 Fiend Tuner + 1+ non-Tuner Fiend monsters

Effect:
When this card is Synchro Summoned: You can add 1 Fiend monster from your Deck or GY to your hand.
If this card is destroyed by battle or card effect and sent to the GY: Take control of the monster that destroyed it, also it becomes a Fiend monster.
--]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_FIEND),1,99)
	
	-- Add Fiend from Deck or GY to hand on Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	-- Take control of the monster that destroyed it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end

-- Check if Synchro Summoned
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Add Fiend from Deck or GY to hand
function s.thfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		return g:GetClassCount(Card.GetCode)>=1
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Check if destroyed by battle or card effect
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end

-- Take control of the monster that destroyed it
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local bc=e:GetHandler():GetBattleTarget()
	if chkc then return chkc==bc end
	if chk==0 then
		if e:GetHandler():IsReason(REASON_BATTLE) then
			return bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) and bc:IsControlerCanBeChanged()
		else
			return re and re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsControlerCanBeChanged()
		end
	end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	
	-- Change control
	if Duel.GetControl(tc,tp,PHASE_END,1) then
		-- Change type to Fiend
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_FIEND)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
