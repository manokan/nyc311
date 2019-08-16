# Noise: Monthly Seasonality

  # Monthly totals of all noise complaints from April 2004 to June 2019 are in monthlyNoise.csv

monthlyNoise <- read.csv("monthlyNoise.csv") # include path if/as needed

monthlyNoiseTS <- ts(monthlyNoise$N, frequency = 12, start = c(2004,4)) # Convert the totals vector into a time-series object, with the frequency at 12 (months) and series starting 2004, month 4

plot.ts(monthlyNoiseTS) # Monthly counts show (a) strong seasonality (zig-zagging line) and (b) a downward trend till 2010 and sharply rising trend from there on. We can get a better handle on it by separating out the various elements.

plot(decompose(monthlyNoiseTS)) # decompose() separates out the trend from the seasonality, and also the randomness that is not accounted for by the trend and seasonality. 

# stl() allows more control over the decomposition but... first disaggregate  specific types of noise; see how seasonal (leaf-blowers) and non-seasonal (honking?) noises, with different trends and randomness, interact. Predictive values will then be more useful?
