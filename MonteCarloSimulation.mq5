//+------------------------------------------------------------------+
//| MonteCarloSimulation.mq5                                        |
//| Monte Carlo simulation for strategy validation and risk analysis|
//+------------------------------------------------------------------+
#property copyright "Misape Trading Bot"
#property version   "1.00"
#property script_show_inputs

// Monte Carlo parameters
input int SimulationRuns = 1000;                    // Number of simulation runs
input double InitialCapital = 10000.0;              // Starting capital
input double RiskPerTrade = 0.02;                   // Risk per trade (2%)
input int MaxConcurrentTrades = 3;                  // Maximum concurrent trades
input bool UseBootstrapping = true;                 // Use bootstrap resampling
input int BootstrapSampleSize = 252;                // Bootstrap sample size (trading days)
input double ConfidenceLevel = 0.95;                // Confidence level for VaR
input string SimulationResultsFile = "monte_carlo_results.csv"; // Results file

// Simulation results structure
struct MonteCarloResults {
    string strategy_name;
    double mean_return;
    double median_return;
    double std_deviation;
    double var_95;           // Value at Risk (95%)
    double cvar_95;          // Conditional Value at Risk (95%)
    double max_drawdown_mean;
    double max_drawdown_95;
    double probability_of_loss;
    double probability_of_ruin;
    double sharpe_ratio_mean;
    double sortino_ratio_mean;
    double calmar_ratio_mean;
    double skewness;
    double kurtosis;
    double tail_ratio;
    double gain_to_pain_ratio;
    double sterling_ratio;
    double burke_ratio;
    double martin_ratio;
};

// Trade simulation structure
struct SimulatedTrade {
    double entry_price;
    double exit_price;
    double profit_loss;
    double confidence_score;
    double statistical_significance;
    int holding_period;
    string strategy;
};

// Global variables
MonteCarloResults g_mc_results[8];  // Results for each strategy
SimulatedTrade g_historical_trades[];
int g_historical_trade_count = 0;
double g_simulation_returns[];
int g_simulation_count = 0;

// Include main bot functions
#include "Consolidated_Misape_Bot.mq5"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
    Print("=== Monte Carlo Simulation Framework Started ===");
    Print("Simulation Runs: ", SimulationRuns);
    Print("Initial Capital: $", DoubleToString(InitialCapital, 2));
    Print("Risk Per Trade: ", DoubleToString(RiskPerTrade * 100, 1), "%");
    
    // Load historical trade data
    LoadHistoricalTradeData();
    
    // Run Monte Carlo simulations for each strategy
    RunOrderBlockMonteCarlo();
    RunFairValueGapMonteCarlo();
    RunMarketStructureMonteCarlo();
    
    // Generate comprehensive risk analysis report
    GenerateRiskAnalysisReport();
    
    // Export results
    ExportMonteCarloResults();
    
    Print("=== Monte Carlo Simulation Completed ===");
}

//+------------------------------------------------------------------+
//| Load historical trade data for simulation                        |
//+------------------------------------------------------------------+
void LoadHistoricalTradeData() {
    Print("Loading historical trade data...");
    
    // Simulate loading historical trades (in practice, load from file or database)
    ArrayResize(g_historical_trades, 1000);
    g_historical_trade_count = 0;
    
    // Generate sample historical data based on strategy characteristics
    GenerateSampleTradeData("Order Block (Enhanced)", 150, 0.65, 0.75);
    GenerateSampleTradeData("Fair Value Gap (Enhanced)", 120, 0.68, 0.80);
    GenerateSampleTradeData("Market Structure", 100, 0.62, 0.70);
    
    Print("Loaded ", g_historical_trade_count, " historical trades");
}

//+------------------------------------------------------------------+
//| Generate sample trade data for simulation                        |
//+------------------------------------------------------------------+
void GenerateSampleTradeData(string strategy, int trade_count, double win_rate, double avg_confidence) {
    for(int i = 0; i < trade_count && g_historical_trade_count < ArraySize(g_historical_trades); i++) {
        SimulatedTrade trade;
        trade.strategy = strategy;
        trade.confidence_score = avg_confidence + (MathRand() / 32767.0 - 0.5) * 0.3;
        trade.statistical_significance = trade.confidence_score * 0.8 + (MathRand() / 32767.0) * 0.2;
        
        // Generate realistic P&L based on win rate
        bool is_winner = (MathRand() / 32767.0) < win_rate;
        
        if(is_winner) {
            // Winning trade: log-normal distribution
            double random_factor = MathExp((MathRand() / 32767.0 - 0.5) * 0.8);
            trade.profit_loss = 50 + random_factor * 100;  // $50-$200 typical win
        } else {
            // Losing trade: smaller, more consistent losses
            double random_factor = 0.5 + (MathRand() / 32767.0) * 0.5;
            trade.profit_loss = -30 - random_factor * 50;  // $30-$80 typical loss
        }
        
        trade.holding_period = 1 + (int)(MathRand() / 32767.0 * 10);  // 1-10 bars
        
        g_historical_trades[g_historical_trade_count] = trade;
        g_historical_trade_count++;
    }
}

//+------------------------------------------------------------------+
//| Run Monte Carlo simulation for Order Block strategy              |
//+------------------------------------------------------------------+
void RunOrderBlockMonteCarlo() {
    Print("\n--- Running Order Block Monte Carlo Simulation ---");
    
    string strategy_name = "Order Block (Enhanced)";
    int strategy_index = 0;
    
    // Collect strategy-specific trades
    SimulatedTrade strategy_trades[];
    int strategy_trade_count = 0;
    
    for(int i = 0; i < g_historical_trade_count; i++) {
        if(g_historical_trades[i].strategy == strategy_name) {
            ArrayResize(strategy_trades, strategy_trade_count + 1);
            strategy_trades[strategy_trade_count] = g_historical_trades[i];
            strategy_trade_count++;
        }
    }
    
    if(strategy_trade_count == 0) {
        Print("No historical data for ", strategy_name);
        return;
    }
    
    // Run Monte Carlo simulation
    RunStrategyMonteCarlo(strategy_trades, strategy_trade_count, strategy_index);
}

//+------------------------------------------------------------------+
//| Run Monte Carlo simulation for Fair Value Gap strategy           |
//+------------------------------------------------------------------+
void RunFairValueGapMonteCarlo() {
    Print("\n--- Running Fair Value Gap Monte Carlo Simulation ---");
    
    string strategy_name = "Fair Value Gap (Enhanced)";
    int strategy_index = 1;
    
    // Collect strategy-specific trades
    SimulatedTrade strategy_trades[];
    int strategy_trade_count = 0;
    
    for(int i = 0; i < g_historical_trade_count; i++) {
        if(g_historical_trades[i].strategy == strategy_name) {
            ArrayResize(strategy_trades, strategy_trade_count + 1);
            strategy_trades[strategy_trade_count] = g_historical_trades[i];
            strategy_trade_count++;
        }
    }
    
    if(strategy_trade_count == 0) {
        Print("No historical data for ", strategy_name);
        return;
    }
    
    // Run Monte Carlo simulation
    RunStrategyMonteCarlo(strategy_trades, strategy_trade_count, strategy_index);
}

//+------------------------------------------------------------------+
//| Run Monte Carlo simulation for Market Structure strategy         |
//+------------------------------------------------------------------+
void RunMarketStructureMonteCarlo() {
    Print("\n--- Running Market Structure Monte Carlo Simulation ---");
    
    string strategy_name = "Market Structure";
    int strategy_index = 2;
    
    // Collect strategy-specific trades
    SimulatedTrade strategy_trades[];
    int strategy_trade_count = 0;
    
    for(int i = 0; i < g_historical_trade_count; i++) {
        if(g_historical_trades[i].strategy == strategy_name) {
            ArrayResize(strategy_trades, strategy_trade_count + 1);
            strategy_trades[strategy_trade_count] = g_historical_trades[i];
            strategy_trade_count++;
        }
    }
    
    if(strategy_trade_count == 0) {
        Print("No historical data for ", strategy_name);
        return;
    }
    
    // Run Monte Carlo simulation
    RunStrategyMonteCarlo(strategy_trades, strategy_trade_count, strategy_index);
}

//+------------------------------------------------------------------+
//| Run Monte Carlo simulation for specific strategy                 |
//+------------------------------------------------------------------+
void RunStrategyMonteCarlo(SimulatedTrade &trades[], int trade_count, int strategy_index) {
    ArrayResize(g_simulation_returns, SimulationRuns);
    g_simulation_count = 0;
    
    double portfolio_returns[];
    double max_drawdowns[];
    ArrayResize(portfolio_returns, SimulationRuns);
    ArrayResize(max_drawdowns, SimulationRuns);
    
    // Run simulations
    for(int sim = 0; sim < SimulationRuns; sim++) {
        double simulation_result = RunSingleSimulation(trades, trade_count);
        portfolio_returns[sim] = simulation_result;
        
        // Calculate max drawdown for this simulation
        max_drawdowns[sim] = CalculateSimulationDrawdown(trades, trade_count);
        
        if(sim % 100 == 0) {
            Print("Completed ", sim, " simulations...");
        }
    }
    
    // Calculate comprehensive statistics
    CalculateMonteCarloStatistics(portfolio_returns, max_drawdowns, strategy_index);
    
    Print("Monte Carlo simulation completed for strategy index ", strategy_index);
}

//+------------------------------------------------------------------+
//| Run single Monte Carlo simulation                                |
//+------------------------------------------------------------------+
double RunSingleSimulation(SimulatedTrade &trades[], int trade_count) {
    double portfolio_value = InitialCapital;
    double peak_value = InitialCapital;
    double max_drawdown = 0;
    int simulation_trades = 252;  // One year of trading
    
    for(int i = 0; i < simulation_trades; i++) {
        // Bootstrap sampling or sequential sampling
        int trade_index;
        if(UseBootstrapping) {
            trade_index = (int)(MathRand() / 32767.0 * trade_count);
        } else {
            trade_index = i % trade_count;
        }
        
        if(trade_index >= trade_count) trade_index = trade_count - 1;
        
        SimulatedTrade selected_trade = trades[trade_index];
        
        // Apply position sizing based on risk per trade
        double risk_amount = portfolio_value * RiskPerTrade;
        double position_size = CalculatePositionSize(selected_trade, risk_amount);
        
        // Apply confidence-based adjustment
        double confidence_multiplier = selected_trade.confidence_score;
        double adjusted_pnl = selected_trade.profit_loss * position_size * confidence_multiplier;
        
        // Apply statistical significance filter
        if(selected_trade.statistical_significance < 0.5) {
            adjusted_pnl *= 0.7;  // Reduce impact of low-significance trades
        }
        
        portfolio_value += adjusted_pnl;
        
        // Track drawdown
        if(portfolio_value > peak_value) {
            peak_value = portfolio_value;
        } else {
            double current_drawdown = (peak_value - portfolio_value) / peak_value;
            if(current_drawdown > max_drawdown) {
                max_drawdown = current_drawdown;
            }
        }
        
        // Check for ruin condition
        if(portfolio_value <= InitialCapital * 0.1) {  // 90% loss = ruin
            break;
        }
    }
    
    return (portfolio_value - InitialCapital) / InitialCapital;  // Return percentage
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk management                 |
//+------------------------------------------------------------------+
double CalculatePositionSize(SimulatedTrade &trade, double risk_amount) {
    // Simple position sizing based on expected loss
    double expected_loss = MathAbs(trade.profit_loss) * 0.5;  // Simplified
    if(expected_loss <= 0) return 1.0;
    
    double position_size = risk_amount / expected_loss;
    return MathMin(5.0, MathMax(0.1, position_size));  // Limit position size
}

//+------------------------------------------------------------------+
//| Calculate simulation drawdown                                    |
//+------------------------------------------------------------------+
double CalculateSimulationDrawdown(SimulatedTrade &trades[], int trade_count) {
    double portfolio_value = InitialCapital;
    double peak_value = InitialCapital;
    double max_drawdown = 0;
    
    for(int i = 0; i < 252; i++) {  // One year simulation
        int trade_index = (int)(MathRand() / 32767.0 * trade_count);
        if(trade_index >= trade_count) trade_index = trade_count - 1;
        
        SimulatedTrade selected_trade = trades[trade_index];
        double risk_amount = portfolio_value * RiskPerTrade;
        double position_size = CalculatePositionSize(selected_trade, risk_amount);
        double adjusted_pnl = selected_trade.profit_loss * position_size;
        
        portfolio_value += adjusted_pnl;
        
        if(portfolio_value > peak_value) {
            peak_value = portfolio_value;
        } else {
            double current_drawdown = (peak_value - portfolio_value) / peak_value;
            if(current_drawdown > max_drawdown) {
                max_drawdown = current_drawdown;
            }
        }
    }
    
    return max_drawdown;
}

//+------------------------------------------------------------------+
//| Calculate comprehensive Monte Carlo statistics                   |
//+------------------------------------------------------------------+
void CalculateMonteCarloStatistics(double &returns[], double &drawdowns[], int strategy_index) {
    MonteCarloResults &result = g_mc_results[strategy_index];
    
    // Sort arrays for percentile calculations
    ArraySort(returns);
    ArraySort(drawdowns);
    
    int count = ArraySize(returns);
    if(count == 0) return;
    
    // Basic statistics
    double sum = 0;
    for(int i = 0; i < count; i++) {
        sum += returns[i];
    }
    result.mean_return = sum / count;
    result.median_return = returns[count / 2];
    
    // Standard deviation
    double sum_squared_diff = 0;
    for(int i = 0; i < count; i++) {
        sum_squared_diff += MathPow(returns[i] - result.mean_return, 2);
    }
    result.std_deviation = MathSqrt(sum_squared_diff / count);
    
    // Value at Risk (VaR) and Conditional VaR
    int var_index = (int)((1.0 - ConfidenceLevel) * count);
    result.var_95 = -returns[var_index];  // Negative for loss
    
    // Conditional VaR (Expected Shortfall)
    double cvar_sum = 0;
    for(int i = 0; i <= var_index; i++) {
        cvar_sum += returns[i];
    }
    result.cvar_95 = var_index > 0 ? -cvar_sum / (var_index + 1) : 0;
    
    // Drawdown statistics
    double dd_sum = 0;
    for(int i = 0; i < ArraySize(drawdowns); i++) {
        dd_sum += drawdowns[i];
    }
    result.max_drawdown_mean = dd_sum / ArraySize(drawdowns);
    result.max_drawdown_95 = drawdowns[(int)(0.95 * ArraySize(drawdowns))];
    
    // Probability calculations
    int loss_count = 0;
    int ruin_count = 0;
    
    for(int i = 0; i < count; i++) {
        if(returns[i] < 0) loss_count++;
        if(returns[i] < -0.5) ruin_count++;  // 50% loss considered ruin
    }
    
    result.probability_of_loss = (double)loss_count / count;
    result.probability_of_ruin = (double)ruin_count / count;
    
    // Advanced risk metrics
    CalculateAdvancedRiskMetrics(returns, result);
    
    // Set strategy name
    switch(strategy_index) {
        case 0: result.strategy_name = "Order Block (Enhanced)"; break;
        case 1: result.strategy_name = "Fair Value Gap (Enhanced)"; break;
        case 2: result.strategy_name = "Market Structure"; break;
        default: result.strategy_name = "Unknown Strategy"; break;
    }
}

//+------------------------------------------------------------------+
//| Calculate advanced risk metrics                                  |
//+------------------------------------------------------------------+
void CalculateAdvancedRiskMetrics(double &returns[], MonteCarloResults &result) {
    int count = ArraySize(returns);
    if(count < 3) return;
    
    double mean = result.mean_return;
    double std_dev = result.std_deviation;
    
    // Skewness calculation
    double skew_sum = 0;
    for(int i = 0; i < count; i++) {
        skew_sum += MathPow((returns[i] - mean) / std_dev, 3);
    }
    result.skewness = skew_sum / count;
    
    // Kurtosis calculation
    double kurt_sum = 0;
    for(int i = 0; i < count; i++) {
        kurt_sum += MathPow((returns[i] - mean) / std_dev, 4);
    }
    result.kurtosis = kurt_sum / count - 3;  // Excess kurtosis
    
    // Sharpe Ratio (annualized)
    double risk_free_rate = 0.02;  // 2% annual risk-free rate
    result.sharpe_ratio_mean = std_dev > 0 ? (mean - risk_free_rate) / std_dev : 0;
    
    // Sortino Ratio (downside deviation)
    double downside_sum = 0;
    int downside_count = 0;
    
    for(int i = 0; i < count; i++) {
        if(returns[i] < risk_free_rate) {
            downside_sum += MathPow(returns[i] - risk_free_rate, 2);
            downside_count++;
        }
    }
    
    double downside_deviation = downside_count > 0 ? 
        MathSqrt(downside_sum / downside_count) : 0;
    result.sortino_ratio_mean = downside_deviation > 0 ? 
        (mean - risk_free_rate) / downside_deviation : 0;
    
    // Calmar Ratio
    result.calmar_ratio_mean = result.max_drawdown_mean > 0 ? 
        mean / result.max_drawdown_mean : 0;
    
    // Tail Ratio (95th percentile / 5th percentile)
    int p95_index = (int)(0.95 * count);
    int p5_index = (int)(0.05 * count);
    result.tail_ratio = returns[p5_index] != 0 ? 
        returns[p95_index] / MathAbs(returns[p5_index]) : 0;
    
    // Gain-to-Pain Ratio
    double gain_sum = 0;
    double pain_sum = 0;
    
    for(int i = 0; i < count; i++) {
        if(returns[i] > 0) {
            gain_sum += returns[i];
        } else {
            pain_sum += MathAbs(returns[i]);
        }
    }
    
    result.gain_to_pain_ratio = pain_sum > 0 ? gain_sum / pain_sum : 0;
}

//+------------------------------------------------------------------+
//| Generate comprehensive risk analysis report                      |
//+------------------------------------------------------------------+
void GenerateRiskAnalysisReport() {
    Print("\n=== MONTE CARLO RISK ANALYSIS REPORT ===");
    Print("Simulation Parameters:");
    Print("  Runs: ", SimulationRuns);
    Print("  Initial Capital: $", DoubleToString(InitialCapital, 2));
    Print("  Risk Per Trade: ", DoubleToString(RiskPerTrade * 100, 1), "%");
    Print("  Confidence Level: ", DoubleToString(ConfidenceLevel * 100, 1), "%");
    
    for(int i = 0; i < 3; i++) {  // Only first 3 strategies
        if(g_mc_results[i].strategy_name != "") {
            MonteCarloResults &result = g_mc_results[i];
            
            Print("\n--- ", result.strategy_name, " ---");
            Print("Expected Return: ", DoubleToString(result.mean_return * 100, 2), "%");
            Print("Volatility (Std Dev): ", DoubleToString(result.std_deviation * 100, 2), "%");
            Print("VaR (95%): ", DoubleToString(result.var_95 * 100, 2), "%");
            Print("CVaR (95%): ", DoubleToString(result.cvar_95 * 100, 2), "%");
            Print("Probability of Loss: ", DoubleToString(result.probability_of_loss * 100, 1), "%");
            Print("Probability of Ruin: ", DoubleToString(result.probability_of_ruin * 100, 1), "%");
            Print("Max Drawdown (Mean): ", DoubleToString(result.max_drawdown_mean * 100, 2), "%");
            Print("Max Drawdown (95%): ", DoubleToString(result.max_drawdown_95 * 100, 2), "%");
            Print("Sharpe Ratio: ", DoubleToString(result.sharpe_ratio_mean, 3));
            Print("Sortino Ratio: ", DoubleToString(result.sortino_ratio_mean, 3));
            Print("Skewness: ", DoubleToString(result.skewness, 3));
            Print("Kurtosis: ", DoubleToString(result.kurtosis, 3));
            Print("Tail Ratio: ", DoubleToString(result.tail_ratio, 2));
            Print("Gain-to-Pain Ratio: ", DoubleToString(result.gain_to_pain_ratio, 2));
        }
    }
}

//+------------------------------------------------------------------+
//| Export Monte Carlo results to CSV                                |
//+------------------------------------------------------------------+
void ExportMonteCarloResults() {
    string filename = SimulationResultsFile;
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_CSV);
    
    if(file_handle != INVALID_HANDLE) {
        // Write header
        FileWrite(file_handle, "Strategy", "Mean_Return", "Std_Deviation", "VaR_95", 
                 "CVaR_95", "Prob_Loss", "Prob_Ruin", "Max_DD_Mean", "Max_DD_95", 
                 "Sharpe_Ratio", "Sortino_Ratio", "Skewness", "Kurtosis", 
                 "Tail_Ratio", "Gain_Pain_Ratio");
        
        // Write results
        for(int i = 0; i < 3; i++) {
            if(g_mc_results[i].strategy_name != "") {
                MonteCarloResults &result = g_mc_results[i];
                FileWrite(file_handle,
                         result.strategy_name,
                         result.mean_return,
                         result.std_deviation,
                         result.var_95,
                         result.cvar_95,
                         result.probability_of_loss,
                         result.probability_of_ruin,
                         result.max_drawdown_mean,
                         result.max_drawdown_95,
                         result.sharpe_ratio_mean,
                         result.sortino_ratio_mean,
                         result.skewness,
                         result.kurtosis,
                         result.tail_ratio,
                         result.gain_to_pain_ratio);
            }
        }
        
        FileClose(file_handle);
        Print("\nMonte Carlo results exported to: ", filename);
    } else {
        Print("Failed to create Monte Carlo results file: ", filename);
    }
}