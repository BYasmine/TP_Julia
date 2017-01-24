using Cbc 
using JuMP
using Clp #PL
#=Using Scanner
input = Scan("espaces/travail/s8/outil_logi/tp2/cutting.txt")=#

type cutting
NbItems::Int
RollWidth::Int
Size::Array{Int64,1} 
Amount::Array{Int64,1}
motif::Array{Int64,2} 
end

NbItems = 5
RollWidth = 110
Size = [20, 45, 50, 55, 75]
Amount =[48, 35, 24, 10,8]

motif = [1 0 0 0 1; 0 1 0 0 0; 0 0 1 0 0 ; 1 0 0 1 0; 0 0 0 0 1] 


data = cutting(NbItems,RollWidth,Size,Amount,motif)
#m = Model(solver=CbcSolver())



function  sans_relaxation()
	m = Model(solver=CbcSolver())

	@variable(m, x[1:size(data.motif,1)] >= 0, Int)
	#question 2 pour la relaxation faut rajouter le package Clp 

	@objective(m, Min, sum(x[p] for p in 1:size(data.motif,1)))

	@constraint(m,dem[i in 1:data.NbItems], sum(data.motif[p,i]*x[p] for p in 1:size(data.motif,1)) >= data.Amount[i])

	print(m)
	solve(m)
	@show getvalue(x)
	#c'est pour récuperer la valeur de l'objectif :,@show getobjectivevalue(m)
	println("l'objectif : " ,getobjectivevalue(m))
end


resultat_sans_la_relaxation=sans_relaxation()
println("le programme lineaire avec la relaxation")




function relaxation(data)
	m = Model(solver=ClpSolver())

	@variable(m, x[1:size(data.motif,1)] >= 0)
	#question 2 pour la relaxation faut rajouter le package Clp 

	@objective(m, Min, sum(x[p] for p in 1:size(data.motif,1)))

	@constraint(m,dem[i in 1:data.NbItems], sum(data.motif[p,i]*x[p] for p in 1:size(data.motif,1)) >= data.Amount[i])
	print(m)
	solve(m)
	@show getvalue(x)
	
	println("l'objectif : " ,getobjectivevalue(m))

	v=getdual(dem)
	return v
end

println("chercher les valeurs duals ")
vdual = relaxation(data)
@show vdual


######################################### Cout reduit ###############################################
println("les valeurs du cout reduit sontttttttt :")


function coutreduit(data,vdual)
	n = Model(solver=CbcSolver())
	@variable(n, y[1:NbItems] >= 0, Int)

	@objective(n, Min, 1- sum(y[i] *vdual[i] for i in 1:NbItems ) )
	@constraint(n,cap, sum(y[i] *Size[i] for i in 1:NbItems) <=110 )
       
 	print("YOOOOO")
	print(n)
	solve(n)
	
	return getvalue(y)
	@show getvalue(y)

end 
coutReduit= coutreduit(data,vdual)
println("chercher les valeurs du cout reduit ")


for k in 1:10
	println("iteration ",k)
	dual = relaxation(data)
	newmotif = coutreduit(data,dual)
	#newmotif = coutreduit(data, dual)
	println("nouveau motif ",newmotif)
 	data.motif = [data.motif; newmotif']#le prim c'est pour la transposé du vecteur newmotif
	println("motif ",data.motif)
end













