using Cbc 
using JuMP

type FactoryData 
    N::Int # nbre de produits
    R::Int # nbre de machines
    ressources::Array{Float64, 1} # capacité des ressources 
    conso::Array{Float64, 2} # consomation des ressources
    profit::Array{Float64, 1} # profit
    minprod::Array{Float64, 1} # productionn minimumu 
end

nbprod = 2
nbres  = 2
ressources = [400.0 ; 490.0]    
conso = [0.2 0.5 ; 0.4 0.40]
profit = [12.0 ; 20.0]
minprod = [100.0; 100.0]

data = FactoryData(nbprod, nbres , ressources, conso, profit,minprod)

#Déclarer le solveur 
m=Model(solver=CbcSolver() )

#Déclaration des variables 
@variable(m, x[1:data.N] >=0 , Int)
#Déclaration de la fonction objectif 
@objective(m, Max, sum(data.profit[i]*x[i] for i in 1:data.N ) )

#Déclaration des contraintes 
@constraint(m, minprodcons[i in 1:data.N], x[i] >= data.minprod[i] )
@constraint(m, ressourcecons[r in 1:data.R], sum(conso[i,r] *x[i] for i in 1:data.N )<= data.ressources[r] )

print(m)
solve(m)
println("la quantité de téléphone fixe produit est :",  getvalue(x[1]))
#@show getvalue(x)