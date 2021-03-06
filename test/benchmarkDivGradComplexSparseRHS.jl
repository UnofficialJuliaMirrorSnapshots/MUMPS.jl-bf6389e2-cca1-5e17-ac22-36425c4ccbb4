using MUMPSjInv
using Test
using LinearAlgebra
using SparseArrays
using Printf

include("getDivGrad.jl");
Ns   = (32,48,64)
nrhs = (1,10,100,500)
rhsDensity = 0.01
MUMPStimeSparse =zeros(length(nrhs))
MUMPStimeDense  =zeros(length(nrhs))

for i=1:length(Ns)
	println(@sprintf("Factoring div-grad matrix on %d x %d x %d grid",Ns[i],Ns[i],Ns[i]))
	A = getDivGrad(Ns[i],Ns[i],Ns[i]);
	n = size(A,1);
	r = ones(n);
	A = A + im*spdiagm(0=>r);
	
	#Factor the matrix
	Afac1 = factorMUMPS(A,1)
	Afac2 = factorMUMPS(A,1)
	
	rhsInit = spdiagm(0=>ones(n),Ns[i]=>ones(n-Ns[i]),2*Ns[i]=>ones(n-2*Ns[i]))
	#rhsInit = sprandn(n,nrhs[end],rhsDensity)
	rhsInit = complex(rhsInit)
	for j = 1:length(nrhs)
	  println(@sprintf("Solve with %d rhs",nrhs[j]));
	  #rhs = sprandn(n,nrhs[j],rhsDensity)
	  rhs = rhsInit[:,1:nrhs[j]]
	  
	  # solve using MUMPSjInv with sparse RHS
	  MUMPStimeSparse[j]= @elapsed begin
	  	x1 = applyMUMPS(Afac1,rhs)
	  end
	  # solve using MUMPSjInv with dense rhs
	  rhs = Matrix(rhs)
	  MUMPStimeDense[j]= @elapsed begin
	  	x2 = applyMUMPS(Afac2,rhs)
  	  end
  
	  for k = 1:nrhs[j]
	    @test norm(x1[:,k]-x2[:,k])/norm(x1[:,k]) < 1e-9
	  end
        end
	destroyMUMPS(Afac1)
	destroyMUMPS(Afac2)

        println(@sprintf("| %4s | %8s | %8s | %8s |","nrhs","sparseRHS","denseRHS","speedup"))

        for j=1:length(nrhs)
	  println(@sprintf("| %d | %1.5f | %1.5f | %1.5f |",nrhs[j],MUMPStimeSparse[j],MUMPStimeDense[j],MUMPStimeDense[j]/MUMPStimeSparse[j]))
        end
        println(" ")
end
