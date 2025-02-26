using CategoricalArrays

struct DominancePair
	dominant::CategoricalValue
	dominate::CategoricalValue
	DominancePair(y1::CategoricalValue, y2::CategoricalValue) = new(y1, y2)
end

struct IncomparablePair
	class1::CategoricalValue
	class2::CategoricalValue
	IncomparablePair(y1::CategoricalValue, y2::CategoricalValue) = new(y1, y2)
end

struct Prediction
	undominated::Vector{CategoricalValue}
	dominance_pairs::Vector{DominancePair}
	incomparable_pairs::Vector{IncomparablePair}
	function Prediction(dom::Matrix{Bool}, class_levels::CategoricalPool{T}) where T
		dominance_pairs::Vector{DominancePair} = DominancePair[]
		incomparable_pairs::Vector{IncomparablePair} = IncomparablePair[]
		for y1 in 1:length(class_levels), y2 ∈ y1:length(class_levels)
			(y1 == y2) && (continue)
			if dom[y1, y2]
				push!(dominance_pairs, DominancePair(class_levels[y1], class_levels[y2]))
			elseif dom[y2, y1]
				push!(dominance_pairs, DominancePair(class_levels[y2], class_levels[y1]))
			else
				push!(incomparable_pairs, IncomparablePair(class_levels[y1], class_levels[y2]))
			end
		end
		undominated::Vector{CategoricalValue} = CategoricalValue[]
		for y in 1:length(class_levels)
			reduce(Base.:|, dom[y, :]) && push!(undominated, class_levels[y])
		end
		new(undominated, dominance_pairs, incomparable_pairs)
	end
end

function maximality(fitted::NCC_fitted, x::DataFrameRow)
	dom = compute_dominance_matrix(fitted, x)
	pred::Prediction = Prediction(dom, fitted.class_levels)
	return pred.undominated
end

function compute_dominance_matrix(fitted::NCC_fitted, x::DataFrameRow)
	dom::Matrix{Bool} = zeros(Bool, length(fitted.class_levels), length(fitted.class_levels))
	for y1 in 1:length(fitted.class_levels), y2 in 1:length(fitted.class_levels)
		(y1 == y2) && (continue)
		dom[y1, y2] = dominance(fitted, x, y1, y2)
	end
	return dom
end

function dominance(f::NCC_fitted, x::DataFrameRow, y1::Int64, y2::Int64)
	log10(f.class.inf_prob[y1]) - log10(f.class.sup_prob[y2]) + mapreduce(n -> log10(f.values[n].inf_prob[levelcode(x[n]), y1]) - log10(f.values[n].sup_prob[levelcode(x[n]), y2]), +, f.names) > 0.0
end
