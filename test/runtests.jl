using NaiveCredalClassifier
using Test
using CSV
using DataFrames

T = CSV.read("./test/animal_dataset.csv", DataFrame)
T = coerce(T, :hair => Multiclass, :tail => Multiclass, :ear => Multiclass, :animal => Multiclass)
y, X = unpack(T, ==(:animal))

@testset "NaiveCredalClassifier.jl" begin
	# Write your tests here.
end
