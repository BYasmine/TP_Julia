using Cbc 
using JuMP

type FactoryData 
    N::Int # nbre de produits
    T::Int # nbre de Periodes
    demande::Array{Float64, 2} 
    CostFab::Array{Float64, 2} 
    CostStock::Array{Float64, 2} 
    cap::Array{Float64,1}
    durfab::Array{Float64,2}
    CostSup::Array{Float64,2}
    hr::Array{Float64,2}
    fi::Array{Float64,2}
end


N = 2
T = 3
demande = [1.0 1.0 1.0; 1.0 1.0 1.0]
CostFab = [2.0 2.0 2.0 ; 2.0 2.0 2.0]
CostStock= [1.5 1.5 1.5; 1.5 1.5 1.5]
cap = [100.0; 100.0; 100.0]
durfab=[ 1.0 1.0 1.0 ; 1.0 1.0 1.0]
CostSup=[2.0 2.0 2.0; 3.0 3.0 3.0]
hr=[3.0 3.0 3.0 ; 3.0 3.0 3.0]
fi = [4.0 4.0 4.0 ; 4.0 4.0 4.0]


data = FactoryData(N , T , demande, CostFab , CostStock, cap, durfab, CostSup, hr,fi)





#Déclarer le solveur 
m=Model(solver=CbcSolver() )

#Déclaration des variables 
@variable(m, x[1:data.N,1:data.T ] >=0 , Int)
@variable(m, s[1:data.N, 1:data.T ] >=0 , Int)
@variable(m, y[1:data.N, 1:data.T ] , Bin)
@variable(m, d[1:data.N, 1:data.T], Int)


#Déclaration de la fonction objectif 
@objective(m, Min, sum(data.CostFab[i,j]*x[i,j] + data.CostStock[i,j]*s[i,j] +data.CostSup[i,j]*y[i,j] + (data.demande[i,j] - d[i,j])*data.fi[i,j] for i in 1:data.N , j in 1:data.T ) )

#Déclaration des contraintes 

@constraint(m, produit1[i in 1:data.N] , 0 + x[i,1] == d[i,1] + s[i,1])

@constraint(m, produit1[i in 1:data.N , j in 2:data.T] ,s[i,j-1] + x[i,j] == d[i,j] + s[i,j])

@constraint(m, temps[j in 1:data.T], sum(data.durfab[i,j]*x[i,j] for i in 1:data.N )+ sum(data.hr[i,j]*y[i,j] for i in 1:data.N) <= data.cap[j] )




print(m)
solve(m)

@show getvalue(x)
@show getvalue(s)
println("la valeur de l'objectif :",getobjectivevalue(m))


