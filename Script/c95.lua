
--Chemical Breakdown
local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)
	e1:SetCost(s.actcost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--Hyozanryu filter
function s.hyozanfilter(c)
	return c:IsCode(62397231) and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE))
		and c:IsAbleToDeck()
end

--Dinosaur filter
function s.spfilter(c,e,tp,attr)
	return c:IsMonster() and c:IsRace(RACE_DINOSAUR)
		and c:IsLevelBelow(5)
		and c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND)
		and (attr==0 or (c:GetAttribute()&attr)==0)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

--Activation condition
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.hyozanfilter,tp,
		LOCATION_HAND|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,
		LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,
		0,1,nil,e,tp,0)
end

--Shuffle Hyozanryu into the Deck
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.hyozanfilter,tp,
		LOCATION_HAND|LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.hyozanfilter,tp,
		LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--Activate effect
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=math.min(5,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct<=0 then return end

	local sg=Group.CreateGroup()
	local attr=0

	--Select up to 5 Dinosaurs with different Attributes
	for i=1,ct do
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,
			LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,
			0,0,1,nil,e,tp,attr)

		if g:GetCount()==0 then
			break
		end

		local tc=g:GetFirst()
		sg:AddCard(tc)
		attr=attr|tc:GetAttribute()
	end

	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)

		--Remember the monsters successfully summoned
		local tg=Duel.GetOperatedGroup():Clone()
		if tg:GetCount()>0 then
			tg:KeepAlive()

			--Destroy them when this Trap leaves the field
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetOperation(s.desop)
			e1:SetLabelObject(tg)
			c:RegisterEffect(e1)
		end
	end
end

--Destroy the summoned monsters
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g then
		Duel.Destroy(g,REASON_EFFECT)
		g:DeleteGroup()
	end
end
