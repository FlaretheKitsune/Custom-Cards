local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.fusfilter(c)
	return c:IsSetCard(0x1122) and c:IsType(TYPE_FUSION)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
local function lists_mat(fus,code)
	if not fus or not code then return false end
	if fus.ListsCode then return fus:ListsCode(code) end
	return aux.IsCodeListed and aux.IsCodeListed(fus,code) or false
end
function s.addfilter(c,e,tp,fus)
	local ok=false
	if lists_mat(fus,c:GetCode()) then ok=true end
	if not ok and fus:IsSetCard(0x1122) and c:IsSetCard(0x1122) and c:IsType(TYPE_MONSTER) then ok=true end
	return ok and c:IsAbleToHand() and (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_GRAVE))
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local fus=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if not fus then return end
	Duel.ConfirmCards(1-tp,fus)
	local g_all=Group.CreateGroup()
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(function(c) return s.addfilter(c,e,tp,fus) end),tp,LOCATION_DECK,0,nil,e,tp,fus)
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(function(c) return s.addfilter(c,e,tp,fus) end),tp,LOCATION_GRAVE,0,nil,e,tp,fus)
	g_all:Merge(g1)
	g_all:Merge(g2)
	if #g_all>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g_all:Select(tp,1,math.min(2,#g_all),nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
		Duel.BreakEffect()
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.stfilter(c)
	return c:IsSetCard(0x1122) and c:IsAbleToHand() and not c:IsCode(id) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
