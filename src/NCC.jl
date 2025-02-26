using ScientificTypes
using CategoricalArrays
using DataFrames


function fit(m::NaiveCredal, x::DataFrame, y::CategoricalVector)
	for n in names(x)
		@assert typeof(x[:, n]) <: CategoricalVector "Column '$(n)' is not Categorical"
	end

	values = Dict{String, _FeatureValue}()
	class = _ClassValue(length(levels(y)))
	for n in names(x)
		values[n] = _FeatureValue(length(levels(x[:, n])), length(levels(y)))
	end
	n_sample::Int64 = length(y)
	for row in 1:n_sample
		add!(class, y[row])
		for n in names(x)
			add!(values[n], x[row, n], y[row])
		end
	end
	NCC_fitted(m, names(x), values, class, y.pool)
end

function predict(m::NaiveCredal, fitted::NCC_fitted, Xnew::DataFrame)
	n_x, _ = size(Xnew)
	y_hat = Vector{CategoricalValue}[]
	for x ∈ 1:n_x
		push!(y_hat, maximality(fitted, Xnew[x, :]))
	end
	y_hat
end
