#----------------- Get the A matrix
function getDivGrad(n1,n2,n3)

        # the Divergence
        D1 = kron(speye(n3),kron(speye(n2),ddx(n1)))
        D2 = kron(speye(n3),kron(ddx(n2),speye(n1)))
        D3 = kron(ddx(n3),kron(speye(n2),speye(n1)))
        # DIV from faces to cell-centers
        Div = [D1 D2 D3]

        return Div*Div';
end
#----------------- 1D finite difference on staggered grid
function ddx(n)
# generate 1D derivatives
    return d = spdiagm((-ones(n),ones(n)),[0,1],n,n+1)

end

