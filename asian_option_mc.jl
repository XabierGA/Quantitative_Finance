#= 

    Author:     Xabier Garcia Andrade

    ------------------------------------

    Explanation of Asian Options:

    -> The pay-off function is a function of multiple points up to 
    and including the price at expiry. 

    -> It is path-dependent

    -> Considering N equally distributed sample points beginning at 
    time t = 0 and ending at maturity 

    -> In this case we need to generate multiple spot paths while doing MC

    -> We will still use the GBM model 

    ------------------------------------


=# 

using Random
using Plots 
using Statistics

plotlyjs()

struct Asian_Option

    stock_prices::Array{Float32}
    stock_price::Float32
    strike_price::Float32
    risk_free_rate::Float32
    time_to_maturity::Float32
    volatility::Float32

end

function GBModel(trade::Asian_Option)

    timestep = trade.time_to_maturity/length(trade.stock_prices);

    drift = (trade.risk_free_rate - 0.5*trade.volatility^2)*timestep;
    uncer = trade.volatility*sqrt(timestep);

    for i in collect(2:1:length(trade.stock_prices))
        
        rnd = randn(Float32,1)[1] ;

        trade.stock_prices[i] = trade.stock_prices[i-1] * exp(drift + uncer*rnd);
        
    end

    return trade.stock_prices

end

function PayOFF_Function(trade::Asian_Option , mean = "Arithmetic")

    if mean == "Arithmetic"

        pay_off = Statistics.mean(trade.stock_prices)

    elseif mean == "Geometric"

        log_sum = 0

        for log_price in trade.stock_prices

            log_sum += log(log_price)

        end 

        pay_off = exp(log_sum/length(stock_prices))

    end

    result = pay_off - trade.strike_price

    if (result)>0

        return result 

    else 

        return 0 

    end 

end



function MC_Simulator(trade::Asian_Option , NumberofScenarios , mean = "Arithmetic")

    pay_off = 0

    X = []
    x = range(0.0, stop = trade.time_to_maturity ,  length = length(trade.stock_prices)) |> collect
   # x = collect(0 , trade.time_to_maturity/length(trade.stock_prices) , convert(Int , trade.time_to_maturity))
    Y = []
    it = 0
    for scenario in collect(1:1:NumberofScenarios)
        println("Iteration ->" , it)
        h = GBModel(trade)
        push!(Y , h)
        println(" \n \n YYY ->" , Y)
        push!(X , x)
        pay_off += PayOFF_Function(trade , mean )
        println("And here ->" , trade.stock_prices)
        it += 1
    end 

    xlabel= "TimeStep (Years)"
    ylabel= "Payoff"
    println(Y)
    plt = plot(X , Y , xlabel = xlabel , ylabel =ylabel)
    savefig("asian_option_simul.png")

    discounted_price = (exp(-trade.risk_free_rate*trade.time_to_maturity))*pay_off/NumberofScenarios;

    return discounted_price

end 


#######################################
############ First Example ############
#######################################

number_samples = 5

number_simulations = 3


stock_price = 30 
strike_price = 29
risk_free_rate = 0.08 
volatility = 0.3 
time_to_maturity = 1
stock_prices = fill(stock_price , number_samples)

trade = Asian_Option(stock_prices , stock_price , strike_price , risk_free_rate , time_to_maturity , volatility)


pay = MC_Simulator(trade , number_simulations , "Geometric")

println("Pay :::--> " , pay)

        

