#=

    Author: Xabier Garcia Andrade


    ---------------------------------


    -> Continue under the Black-Scholes Formalism, but relaxing the assumption of the GBM and introducing the concept of market incompleteness 

    -> Using the formula derived by Merton when the underlying stock returns are discontinuous

    -> Jumps occur in an instantaneuos fashion 

    -> Jumps are a Poisson process 

    -> We just need to add a Poisson term (J) to the GBM model 

    

    =#

struct  Option_JD

    S::Float64
    K::Float64
    r::Float64
    v::Float64
    T::Float64 
    N::Int64
    m::Float64
    lambda::Float64
    nu::Float64

end 


function normal_pdf(x::Float64)

    return (1.0/sqrt(2*pi))*exp(-0.5*x^2)

end 

function normal_cdf(x::Float64)

    k = 1.0/(1.0 + 0.2316419*x);
    k_sum = k*(0.319381530 + k*(-0.356563782 + k*(1.781477937 + k*(-1.821255978 + 1.330274429*k))));

    if (x >= 0.0)

        return (1.0 - (1.0/sqrt(2*pi))*exp(-0.5*x^2)*k_sum)
    
    else

        return 1.0 - normal_cdf(-x)

    end

end 

function d_j(j::Int64 , trade::Option_JD )

    return (log(trade.S/trade.K) + (trade.r + (-1)^(j-1)*0.5*trade.v^2)*trade.T)/(trade.v*sqrt(trade.T))

end

function bs_call_price(trade::Option_JD)

    return S * normal_cdf(d_j(1 , trade))-trade.K*exp(-trade.r*trade.T)*normal_cdf(d_j(2 , trade))

end 

### Approximation to the Merton Formula 
### using a finite series

function bs_jd_call_price(trade)

    price = 0.0 

    factorial = 1.0 

    lambda_p = trade.lambda*trade.m 

    lambda_p_T = lambda_p * trade.T 

    for n in collect(1:1:trade.N)

        sigma_n = sqrt(trade.v*trade.v + n*trade.nu*trade.nu/trade.T)

        r_n = trade.r - trade.lambda*(trade.m-1) + n*log(trade.m)/trade.T;

        if (n==0)

            factorial *=1

        else 

            factorial *= n 

        end 

        price += ((exp(-lambda_p_T) * lambda_p_T^n)/factorial)*bs_call_price(trade)

    end 

    return price 

end 


##############################
########3 Example #############
##############################


S = 100.0 
K = 100.0 
r = 0.05 
v = 0.2 
T = 1.0 
N = 50 
m  = 1.083287 
lambda = 1.0 
nu = 0.4 

trade = Option_JD(S , K , r ,v , T , N , m , lambda , nu)

call = bs_jd_call_price(trade)


println("Price usig JD ---> " , call)