--[[
Mokey Mokey Metamorphosis
Spell Card
(This card is always treated as "Polymerization".)
Fusion Summon 1 "Mokey Mokey" Fusion Monster from your Extra Deck, using monsters from your hand or field as Fusion Material.
If you control 3 or more "Mokey Mokey" monsters, you can also use 1 "Mokey Mokey" monster from your Deck as Fusion Material.
If this card is in your GY, except the turn it was sent there: You can banish this card; add 1 "Mokey Mokey" monster from your Deck to your hand. You can only use this effect of "Mokey Mokey Metamorphosis" once per turn.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Always treated as "Polymerization"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(CARD_POLYMERIZATION)
	c:RegisterEffect(e0)
	
	-- Fusion Summon
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x184),Fusion.OnFieldMat(Card.IsAbleToDeck),s.fextra,Fusion.BanishMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	
	-- Add from Deck to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	e2:SetCountLimit(1,id+1)
	c:RegisterEffect(e2)
end

-- Check if can use deck as material
function s.fextra(e,tp,mg1)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,12482652),tp,LOCATION_MZONE,0,3,nil) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_DECK,0,nil),s.fcheck
	end
	return nil
end

-- Check if can use from deck
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK)
end

-- Target for using from deck
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Check GY effect condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

-- Add to hand target
function s.thfilter(c)
	return c:IsCode(12482652) or (c:IsSetCard(0x184) and c:IsMonster() and c:IsAbleToHand())
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
