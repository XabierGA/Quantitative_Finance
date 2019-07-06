#=
Author: Xabier Garcia Andrade

Description: Implementation of a Monte Carlo simulator using 
a Geometric Brownian Motion Model to price European Options
=#

using Random
using Plots

plotlyjs()

struct  Option
    stock_price::Float32
    strike_price::Float32
    risk_free_rate::Float32
    volatility::Float32
    time_to_maturity::Float32 
end 

function GBModel(trade::Option , NumberofScenarios)

    prices = []
    #Since we are dealing with European Options (only used at expiration) , we only need one timestep
    timestep = 1;
    for scenario in collect(1:1:NumberofScenarios)
        rnd = randn(Float32 , 1)[1] * 0.5 + 1;

        drift = (trade.risk_free_rate - 0.5*trade.volatility^2)*timestep;
        uncer = trade.volatility*sqrt(timestep)*rnd;

        price = trade.stock_price * exp(drift + uncer);
        push!(prices , price);
    end 

    return prices 
end

function PayOFF_Calculator(trade::Option , Prices_per_scenario)

    pay_offs = 0;

    n = length(Prices_per_scenario);

    for i in collect(1:1:n)

        pay_off = Prices_per_scenario[i] - trade.stock_price;

        if (pay_off>0)

            pay_offs += pay_off;
        
        end
    end
    
    discounted_price = (exp(-trade.risk_free_rate*trade.time_to_maturity))*pay_offs;

    return discounted_price/n

end

function plot_scenarios(trade::Option , Prices_Per_Scenario)

    X = [];

    Y = [];

    x_aux = [1,0];

    for price in Prices_Per_Scenario
        y_aux = []
        push!(y_aux , price);
        push!(y_aux , trade.stock_price);
        push!(Y, y_aux);
        push!(X , x_aux);
    end
    xlabel= "TimeStep (Years)"
    ylabel= "Payoff"
    plt = plot(X , Y , xlabel = xlabel , ylabel =ylabel)
    savefig("sim_results.png")
end
    

function MCSimulator(NumberofScenarios , trade::Option)

    prices_per_scenario = GBModel(trade , NumberofScenarios);
    plot_scenarios(trade , prices_per_scenario)
    price = PayOFF_Calculator(trade , prices_per_scenario);

    return price
end
        
#################################
#################################
#  First Example                #
#################################
#################################
stock_price = 200
strike_price = 200 
time_to_maturity = 1 
volatility = 0.10
risk_free_rate = 0.15

black_scholes_yield = 28.40

trade = Option(stock_price , strike_price, risk_free_rate , volatility , time_to_maturity );

result = MCSimulator(1000 , trade);

println("Result --_>  "  , result);
println("Difference with respect to Black-black_scholes_yield ", 100*(result - black_scholes_yield)/black_scholes_yield)
