using CategoricalArrays
using DataFrames: DataFrameRow

struct NaiveCredal
	s::Int64                           # imprecise parameter
	epsilon::Float64                   # mixture factor in ϵ-contaminated to avoid 0 probabilities
	NaiveCredal(; s::Int64 = 2, epsilon::Float64 = 0.05) = new(s, epsilon)
end

mutable struct _FeatureValue
	counts::Matrix{Int64}
	_FeatureValue(feature_levels::Int, y_levels::Int) = new(zeros(Int64, feature_levels, y_levels))
end

struct _FeatureProbabilities
	inf_prob::Matrix{Float64}
	sup_prob::Matrix{Float64}
	function _FeatureProbabilities(f::_FeatureValue, m::NaiveCredal)
		x_levels, y_levels = size(f.counts)
		inf = zeros(Float64, x_levels, y_levels)
		sup = zeros(Float64, x_levels, y_levels)
		counts = sum(f.counts, dims = 1)
		for i ∈ 1:y_levels
			inf[:, i] = (1 - m.epsilon) .* f.counts[:, i] .* (1 / (counts[i] + m.s)) .+ m.epsilon / x_levels
			sup[:, i] = (1 - m.epsilon) .* (f.counts[:, i] .+ m.s) .* (1 / (counts[i] + m.s)) .+ m.epsilon / x_levels
		end
		new(inf, sup)
	end
end

mutable struct _ClassValue
	counts::Vector{Int64}
	_ClassValue(y_levels::Int64) = new(zeros(Int64, y_levels))
end

struct _ClassProbabilities
	inf_prob::Vector{Float64}
	sup_prob::Vector{Float64}
	function _ClassProbabilities(f::_ClassValue, m::NaiveCredal)
		y_levels = length(f.counts)
		inf = zeros(Float64, y_levels)
		sup = zeros(Float64, y_levels)
		counts = sum(f.counts)
		inf[:] = (1 - m.epsilon) .* f.counts[:] .* (1 / (counts + m.s)) .+ m.epsilon / y_levels
		sup[:] = (1 - m.epsilon) .* (f.counts[:] .+ m.s) .* (1 / (counts + m.s)) .+ m.epsilon / y_levels
		new(inf, sup)
	end
end

add!(f::_FeatureValue, x::CategoricalValue{X}, y::CategoricalValue{Y}) where {X, Y} = f.counts[levelcode(x), levelcode(y)] += 1
add!(f::_ClassValue, y::CategoricalValue{Y}) where Y = f.counts[levelcode(y)] += 1

mutable struct NCC_fitted{T}
	names::Vector{String}
	values::Dict{String, _FeatureProbabilities}
	class::_ClassProbabilities
	class_levels::CategoricalPool{T}
	function NCC_fitted(m::NaiveCredal, names::Vector{String}, values::Dict{String, _FeatureValue}, class::_ClassValue, class_levels::CategoricalPool{T}) where T
		v = Dict{String, _FeatureProbabilities}()
		for n in names
			v[n] = _FeatureProbabilities(values[n], m)
		end
		c = _ClassProbabilities(class, m)
		new{T}(names, v, c, class_levels)
	end
end
