library(quantmod)
library(tseries)
library(fUnitRoots)
library(forecast)
getSymbols("AAPL")

plot(Cl(AAPL))

aapl_ts <- ts(AAPL , start = c(2007,1) , frequency = 365)

open_aapl <- aapl_ts[,1]

# Three components of a time series data
# -> Trend: Long term increase or decrease 
# -> Seasonal: Series is influenced by seasonal factors
# -> Cyclic: Data exhibits rises and falls that are not the fixed period

components <- decompose(open_aapl)

#Visualize the different components of the time series

plot(components)

#Now if we want to apply an ARIMA model, we need to find out if it fullfils all the assumptions

# -> We need to achieve stationarity:

# Kwiatkowski-Phillips-Schmidt-Shin (KPSS) test to find out whether difference of regression should be used

urkpssTest(open_aapl, type = c("tau"), lags = c("short"),use.lag = NULL, doplot = TRUE)


tsstationary <- diff(open_aapl, differences=5)


plot(tsstationary)

##Now we will use a built-in function that determines the best model by fixing d with KPSS test and chooses the model by minimizing AIC

arima_model_aapl <- auto.arima(open_aapl)


print(arima_model_aapl)

tsdisplay(residuals(arima_model_aapl), lag.max=45, main='(0,1,2) Model Residuals')

ARIMA <- arima(open_aapl , order=c(0,1,2))
#forecast_arima <- predict(arima_model_aapl , n.ahead = 10)

forec <- predict(ARIMA , h=30)

plot(forecast(ARIMA , h = 50) , ylab="AAPL")
  