--[[
Dark Core Fusion
Spell/Quick-Play

Effect:
Fusion Summon 1 DARK monster from your Extra Deck, using monsters from your hand or field as Fusion Material.
If you Fusion Summon a Fiend monster this way: Draw 1 card.
If a DARK Fiend Fusion Monster you control is destroyed and sent to your GY: You can add this card from your GY to your hand.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),Fusion.OnFieldOrInHand,nil,nil,nil,s.stage2)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	
	-- Add to hand when a DARK Fiend Fusion is destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- Draw 1 if summoned a Fiend
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 and tc:IsRace(RACE_FIEND) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

-- Check for DARK Fiend Fusion in GY
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and (c:IsReason(REASON_DESTROY) or c:IsReason(REASON_BATTLE))
		and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_FIEND) and c:IsType(TYPE_FUSION)
end

-- Condition for adding back to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and e:GetHandler():IsAbleToHand()
end

-- Target for adding back to hand
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

-- Operation for adding back to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT+REASON_BATTLE)
		Duel.ConfirmCards(1-tp,c)
	end
end