using ResumableFunctions

struct Explainer
	model::Any
	observation::Any

	function Explainer(model, observation)
		new{model, observation}
	end
end

function explain(e::Explainer, r::DominancePair, type::_PrimeImplicant) end
function explain(e::Explainer, r::DominancePair, type::_CounterFactual) end
function explain_all(e::Explainer, r::DominancePair, type::_PrimeImplicant) end
function explain_all(e::Explainer, r::DominancePair, type::_CounterFactual) end
function explain_generator(e::Explainer, r::DominancePair, type::_PrimeImplicant) end
function explain_generator(e::Explainer, r::DominancePair, type::_CounterFactual) end

function explain(e::Explainer, r::IncomparablePair, type::_PrimeImplicant) end
function explain(e::Explainer, r::IncomparablePair, type::_CounterFactual, class1::Bool = true) end
function explain_all(e::Explainer, r::IncomparablePair, type::_PrimeImplicant) end
function explain_all(e::Explainer, r::IncomparablePair, type::_CounterFactual, class1::Bool = true) end
function explain_generator(e::Explainer, r::IncomparablePair, type::_PrimeImplicant) end
function explain_generator(e::Explainer, r::IncomparablePair, type::_CounterFactual, class1::Bool = true) end
