//+------------------------------------------------------------------+
//| BacktestFramework.mq5                                           |
//| Comprehensive backtesting framework for enhanced strategies     |
//+------------------------------------------------------------------+
#property copyright "Misape Trading Bot"
#property version   "1.00"
#property script_show_inputs

// Backtesting parameters
input datetime StartDate = D'2023.01.01 00:00:00';  // Backtest start date
input datetime EndDate = D'2024.01.01 00:00:00';    // Backtest end date
input double InitialBalance = 10000.0;              // Initial account balance
input double LotSize = 0.01;                        // Fixed lot size for testing
input bool TestOrderBlocks = true;                  // Test Order Block strategy
input bool TestFairValueGaps = true;                // Test Fair Value Gap strategy
input bool TestMarketStructure = true;              // Test Market Structure strategy
input bool EnableDetailedLogging = true;            // Enable detailed trade logging
input string ResultsFileName = "backtest_results.csv"; // Results file name

// Performance metrics structure
struct BacktestResults {
    string strategy_name;
    int total_trades;
    int winning_trades;
    int losing_trades;
    double win_rate;
    double total_profit;
    double total_loss;
    double net_profit;
    double profit_factor;
    double max_drawdown;
    double max_drawdown_percent;
    double sharpe_ratio;
    double sortino_ratio;
    double calmar_ratio;
    double average_win;
    double average_loss;
    double largest_win;
    double largest_loss;
    double consecutive_wins;
    double consecutive_losses;
    double recovery_factor;
    double expectancy;
    double standard_deviation;
    double variance;
    double skewness;
    double kurtosis;
};

// Trade record structure
struct TradeRecord {
    datetime entry_time;
    datetime exit_time;
    string strategy;
    int trade_type;  // 0=buy, 1=sell
    double entry_price;
    double exit_price;
    double lot_size;
    double profit_loss;
    double confidence_score;
    double statistical_significance;
    string exit_reason;
};

// Global variables
BacktestResults g_results[8];  // Results for each strategy
TradeRecord g_trades[];        // All trade records
int g_trade_count = 0;
double g_current_balance;
double g_peak_balance;
double g_current_drawdown;
double g_max_drawdown;
datetime g_current_time;

// Include main bot functions
#include "Consolidated_Misape_Bot.mq5"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
    Print("=== Comprehensive Backtesting Framework Started ===");
    Print("Backtest Period: ", TimeToString(StartDate), " to ", TimeToString(EndDate));
    Print("Initial Balance: $", DoubleToString(InitialBalance, 2));
    
    // Initialize backtesting environment
    InitializeBacktest();
    
    // Run backtests for enabled strategies
    if(TestOrderBlocks) {
        Print("\n--- Testing Order Block Strategy ---");
        RunOrderBlockBacktest();
    }
    
    if(TestFairValueGaps) {
        Print("\n--- Testing Fair Value Gap Strategy ---");
        RunFairValueGapBacktest();
    }
    
    if(TestMarketStructure) {
        Print("\n--- Testing Market Structure Strategy ---");
        RunMarketStructureBacktest();
    }
    
    // Generate comprehensive report
    GenerateBacktestReport();
    
    // Export results to CSV
    ExportResultsToCSV();
    
    Print("=== Backtesting Completed ===");
}

//+------------------------------------------------------------------+
//| Initialize backtesting environment                               |
//+------------------------------------------------------------------+
void InitializeBacktest() {
    g_current_balance = InitialBalance;
    g_peak_balance = InitialBalance;
    g_current_drawdown = 0;
    g_max_drawdown = 0;
    g_trade_count = 0;
    
    // Initialize results arrays
    ArrayResize(g_trades, 10000);  // Pre-allocate for performance
    
    for(int i = 0; i < 8; i++) {
        g_results[i].strategy_name = GetStrategyName(i);
        g_results[i].total_trades = 0;
        g_results[i].winning_trades = 0;
        g_results[i].losing_trades = 0;
        g_results[i].total_profit = 0;
        g_results[i].total_loss = 0;
        g_results[i].max_drawdown = 0;
        g_results[i].consecutive_wins = 0;
        g_results[i].consecutive_losses = 0;
    }
    
    Print("Backtesting environment initialized successfully");
}

//+------------------------------------------------------------------+
//| Run Order Block strategy backtest                                |
//+------------------------------------------------------------------+
void RunOrderBlockBacktest() {
    int strategy_index = 0;  // Order Block strategy index
    int bars_total = iBars(_Symbol, PERIOD_CURRENT);
    
    for(int i = bars_total - 1; i >= 1; i--) {
        datetime bar_time = iTime(_Symbol, PERIOD_CURRENT, i);
        
        // Skip bars outside test period
        if(bar_time < StartDate || bar_time > EndDate) continue;
        
        g_current_time = bar_time;
        
        // Generate Order Block signal
        TradingSignal signal = GenerateOrderBlockSignal();
        
        if(signal.is_valid && signal.confidence_level >= 0.6) {
            // Execute simulated trade
            ExecuteSimulatedTrade(signal, strategy_index, i);
        }
        
        // Update drawdown calculations
        UpdateDrawdownMetrics();
    }
    
    // Calculate final metrics for Order Block strategy
    CalculateStrategyMetrics(strategy_index);
}

//+------------------------------------------------------------------+
//| Run Fair Value Gap strategy backtest                             |
//+------------------------------------------------------------------+
void RunFairValueGapBacktest() {
    int strategy_index = 1;  // Fair Value Gap strategy index
    int bars_total = iBars(_Symbol, PERIOD_CURRENT);
    
    for(int i = bars_total - 1; i >= 1; i--) {
        datetime bar_time = iTime(_Symbol, PERIOD_CURRENT, i);
        
        // Skip bars outside test period
        if(bar_time < StartDate || bar_time > EndDate) continue;
        
        g_current_time = bar_time;
        
        // Generate Fair Value Gap signal
        TradingSignal signal = GenerateFairValueGapSignal();
        
        if(signal.is_valid && signal.confidence_level >= 0.65) {
            // Execute simulated trade
            ExecuteSimulatedTrade(signal, strategy_index, i);
        }
        
        // Update drawdown calculations
        UpdateDrawdownMetrics();
    }
    
    // Calculate final metrics for Fair Value Gap strategy
    CalculateStrategyMetrics(strategy_index);
}

//+------------------------------------------------------------------+
//| Run Market Structure strategy backtest                           |
//+------------------------------------------------------------------+
void RunMarketStructureBacktest() {
    int strategy_index = 2;  // Market Structure strategy index
    int bars_total = iBars(_Symbol, PERIOD_CURRENT);
    
    for(int i = bars_total - 1; i >= 1; i--) {
        datetime bar_time = iTime(_Symbol, PERIOD_CURRENT, i);
        
        // Skip bars outside test period
        if(bar_time < StartDate || bar_time > EndDate) continue;
        
        g_current_time = bar_time;
        
        // Generate Market Structure signal
        TradingSignal signal = GenerateMarketStructureSignal();
        
        if(signal.is_valid && signal.confidence_level >= 0.7) {
            // Execute simulated trade
            ExecuteSimulatedTrade(signal, strategy_index, i);
        }
        
        // Update drawdown calculations
        UpdateDrawdownMetrics();
    }
    
    // Calculate final metrics for Market Structure strategy
    CalculateStrategyMetrics(strategy_index);
}

//+------------------------------------------------------------------+
//| Execute simulated trade                                          |
//+------------------------------------------------------------------+
void ExecuteSimulatedTrade(TradingSignal &signal, int strategy_index, int bar_index) {
    // Create trade record
    TradeRecord trade;
    trade.entry_time = g_current_time;
    trade.strategy = signal.strategy_name;
    trade.trade_type = signal.signal_type;
    trade.entry_price = signal.entry_price;
    trade.lot_size = LotSize;
    trade.confidence_score = signal.confidence_level;
    
    // Calculate statistical significance for enhanced strategies
    if(StringFind(signal.strategy_name, "Enhanced") >= 0) {
        trade.statistical_significance = CalculateTradeStatisticalSignificance(signal);
    } else {
        trade.statistical_significance = 0.5;  // Default for basic strategies
    }
    
    // Simulate trade execution and exit
    SimulateTradeExecution(trade, signal, strategy_index, bar_index);
    
    // Store trade record
    if(g_trade_count < ArraySize(g_trades)) {
        g_trades[g_trade_count] = trade;
        g_trade_count++;
    }
    
    // Update strategy statistics
    g_results[strategy_index].total_trades++;
    
    if(EnableDetailedLogging) {
        Print("Trade executed: ", trade.strategy, ", Type: ", 
              (trade.trade_type == 0 ? "BUY" : "SELL"), 
              ", Entry: ", DoubleToString(trade.entry_price, _Digits),
              ", Confidence: ", DoubleToString(trade.confidence_score, 3));
    }
}

//+------------------------------------------------------------------+
//| Simulate trade execution with realistic exit conditions          |
//+------------------------------------------------------------------+
void SimulateTradeExecution(TradeRecord &trade, TradingSignal &signal, int strategy_index, int entry_bar) {
    double stop_loss = signal.stop_loss;
    double take_profit = signal.take_profit;
    bool trade_closed = false;
    int max_bars = 100;  // Maximum bars to hold trade
    
    // Simulate price movement until trade closes
    for(int i = entry_bar - 1; i >= 0 && i >= (entry_bar - max_bars) && !trade_closed; i--) {
        double high = iHigh(_Symbol, PERIOD_CURRENT, i);
        double low = iLow(_Symbol, PERIOD_CURRENT, i);
        double close = iClose(_Symbol, PERIOD_CURRENT, i);
        
        if(trade.trade_type == 0) {  // BUY trade
            if(low <= stop_loss) {
                // Stop loss hit
                trade.exit_price = stop_loss;
                trade.exit_time = iTime(_Symbol, PERIOD_CURRENT, i);
                trade.exit_reason = "Stop Loss";
                trade_closed = true;
            } else if(high >= take_profit) {
                // Take profit hit
                trade.exit_price = take_profit;
                trade.exit_time = iTime(_Symbol, PERIOD_CURRENT, i);
                trade.exit_reason = "Take Profit";
                trade_closed = true;
            }
        } else {  // SELL trade
            if(high >= stop_loss) {
                // Stop loss hit
                trade.exit_price = stop_loss;
                trade.exit_time = iTime(_Symbol, PERIOD_CURRENT, i);
                trade.exit_reason = "Stop Loss";
                trade_closed = true;
            } else if(low <= take_profit) {
                // Take profit hit
                trade.exit_price = take_profit;
                trade.exit_time = iTime(_Symbol, PERIOD_CURRENT, i);
                trade.exit_reason = "Take Profit";
                trade_closed = true;
            }
        }
    }
    
    // If trade not closed by SL/TP, close at market
    if(!trade_closed) {
        trade.exit_price = iClose(_Symbol, PERIOD_CURRENT, MathMax(0, entry_bar - max_bars));
        trade.exit_time = iTime(_Symbol, PERIOD_CURRENT, MathMax(0, entry_bar - max_bars));
        trade.exit_reason = "Time Exit";
    }
    
    // Calculate profit/loss
    if(trade.trade_type == 0) {  // BUY
        trade.profit_loss = (trade.exit_price - trade.entry_price) * trade.lot_size * 100000;
    } else {  // SELL
        trade.profit_loss = (trade.entry_price - trade.exit_price) * trade.lot_size * 100000;
    }
    
    // Update balance and strategy metrics
    g_current_balance += trade.profit_loss;
    
    if(trade.profit_loss > 0) {
        g_results[strategy_index].winning_trades++;
        g_results[strategy_index].total_profit += trade.profit_loss;
    } else {
        g_results[strategy_index].losing_trades++;
        g_results[strategy_index].total_loss += MathAbs(trade.profit_loss);
    }
}

//+------------------------------------------------------------------+
//| Calculate comprehensive strategy metrics                         |
//+------------------------------------------------------------------+
void CalculateStrategyMetrics(int strategy_index) {
    BacktestResults &result = g_results[strategy_index];
    
    if(result.total_trades == 0) {
        Print("No trades executed for strategy: ", result.strategy_name);
        return;
    }
    
    // Basic metrics
    result.win_rate = (double)result.winning_trades / result.total_trades * 100;
    result.net_profit = result.total_profit - result.total_loss;
    result.profit_factor = result.total_loss > 0 ? result.total_profit / result.total_loss : 0;
    
    // Advanced metrics calculation
    CalculateAdvancedMetrics(strategy_index);
    
    Print("Strategy: ", result.strategy_name);
    Print("Total Trades: ", result.total_trades);
    Print("Win Rate: ", DoubleToString(result.win_rate, 2), "%");
    Print("Net Profit: $", DoubleToString(result.net_profit, 2));
    Print("Profit Factor: ", DoubleToString(result.profit_factor, 2));
    Print("Max Drawdown: ", DoubleToString(result.max_drawdown_percent, 2), "%");
    Print("Sharpe Ratio: ", DoubleToString(result.sharpe_ratio, 3));
}

//+------------------------------------------------------------------+
//| Calculate advanced performance metrics                           |
//+------------------------------------------------------------------+
void CalculateAdvancedMetrics(int strategy_index) {
    BacktestResults &result = g_results[strategy_index];
    
    // Collect strategy-specific trades
    double returns[];
    int return_count = 0;
    
    for(int i = 0; i < g_trade_count; i++) {
        if(g_trades[i].strategy == result.strategy_name) {
            ArrayResize(returns, return_count + 1);
            returns[return_count] = g_trades[i].profit_loss;
            return_count++;
        }
    }
    
    if(return_count == 0) return;
    
    // Calculate statistical measures
    result.average_win = result.winning_trades > 0 ? result.total_profit / result.winning_trades : 0;
    result.average_loss = result.losing_trades > 0 ? result.total_loss / result.losing_trades : 0;
    result.expectancy = (result.win_rate / 100 * result.average_win) - ((100 - result.win_rate) / 100 * result.average_loss);
    
    // Calculate standard deviation and variance
    double mean_return = result.net_profit / return_count;
    double sum_squared_diff = 0;
    
    for(int i = 0; i < return_count; i++) {
        sum_squared_diff += MathPow(returns[i] - mean_return, 2);
    }
    
    result.variance = sum_squared_diff / return_count;
    result.standard_deviation = MathSqrt(result.variance);
    
    // Sharpe Ratio (assuming risk-free rate of 2%)
    double risk_free_rate = 0.02;
    double annual_return = result.net_profit / InitialBalance;
    result.sharpe_ratio = result.standard_deviation > 0 ? 
        (annual_return - risk_free_rate) / result.standard_deviation : 0;
    
    // Sortino Ratio (downside deviation)
    double downside_variance = 0;
    int negative_returns = 0;
    
    for(int i = 0; i < return_count; i++) {
        if(returns[i] < 0) {
            downside_variance += MathPow(returns[i], 2);
            negative_returns++;
        }
    }
    
    double downside_deviation = negative_returns > 0 ? 
        MathSqrt(downside_variance / negative_returns) : 0;
    result.sortino_ratio = downside_deviation > 0 ? 
        annual_return / downside_deviation : 0;
    
    // Calmar Ratio
    result.calmar_ratio = result.max_drawdown_percent > 0 ? 
        annual_return / (result.max_drawdown_percent / 100) : 0;
    
    // Find largest win/loss
    result.largest_win = 0;
    result.largest_loss = 0;
    
    for(int i = 0; i < return_count; i++) {
        if(returns[i] > result.largest_win) result.largest_win = returns[i];
        if(returns[i] < result.largest_loss) result.largest_loss = returns[i];
    }
    
    result.largest_loss = MathAbs(result.largest_loss);
    
    // Recovery Factor
    result.recovery_factor = result.max_drawdown > 0 ? 
        result.net_profit / result.max_drawdown : 0;
}

//+------------------------------------------------------------------+
//| Update drawdown metrics                                          |
//+------------------------------------------------------------------+
void UpdateDrawdownMetrics() {
    if(g_current_balance > g_peak_balance) {
        g_peak_balance = g_current_balance;
        g_current_drawdown = 0;
    } else {
        g_current_drawdown = g_peak_balance - g_current_balance;
        if(g_current_drawdown > g_max_drawdown) {
            g_max_drawdown = g_current_drawdown;
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate trade statistical significance                          |
//+------------------------------------------------------------------+
double CalculateTradeStatisticalSignificance(TradingSignal &signal) {
    // Enhanced statistical significance for advanced strategies
    double base_significance = signal.confidence_level;
    
    // Add VPIN-based significance
    double vpin_score = CalculateVPINScore(1, 20);
    double vpin_significance = MathMin(0.3, vpin_score * 0.5);
    
    // Add multi-timeframe significance
    double mtf_score = CalculateMultiTimeframeScore();
    double mtf_significance = MathMin(0.2, mtf_score * 0.4);
    
    double total_significance = base_significance + vpin_significance + mtf_significance;
    
    return MathMin(1.0, total_significance);
}

//+------------------------------------------------------------------+
//| Generate comprehensive backtest report                           |
//+------------------------------------------------------------------+
void GenerateBacktestReport() {
    Print("\n=== COMPREHENSIVE BACKTEST REPORT ===");
    Print("Test Period: ", TimeToString(StartDate), " to ", TimeToString(EndDate));
    Print("Initial Balance: $", DoubleToString(InitialBalance, 2));
    Print("Final Balance: $", DoubleToString(g_current_balance, 2));
    Print("Total Return: ", DoubleToString((g_current_balance - InitialBalance) / InitialBalance * 100, 2), "%");
    Print("Maximum Drawdown: $", DoubleToString(g_max_drawdown, 2), " (", 
          DoubleToString(g_max_drawdown / g_peak_balance * 100, 2), "%)");
    Print("Total Trades Executed: ", g_trade_count);
    
    Print("\n--- STRATEGY PERFORMANCE SUMMARY ---");
    
    for(int i = 0; i < 8; i++) {
        if(g_results[i].total_trades > 0) {
            Print("\n", g_results[i].strategy_name, ":");
            Print("  Trades: ", g_results[i].total_trades, 
                  " | Win Rate: ", DoubleToString(g_results[i].win_rate, 1), "%",
                  " | Net P/L: $", DoubleToString(g_results[i].net_profit, 2),
                  " | Profit Factor: ", DoubleToString(g_results[i].profit_factor, 2),
                  " | Sharpe: ", DoubleToString(g_results[i].sharpe_ratio, 3));
        }
    }
}

//+------------------------------------------------------------------+
//| Export results to CSV file                                       |
//+------------------------------------------------------------------+
void ExportResultsToCSV() {
    string filename = ResultsFileName;
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_CSV);
    
    if(file_handle != INVALID_HANDLE) {
        // Write header
        FileWrite(file_handle, "Strategy", "Total_Trades", "Win_Rate", "Net_Profit", 
                 "Profit_Factor", "Max_Drawdown", "Sharpe_Ratio", "Sortino_Ratio", 
                 "Calmar_Ratio", "Expectancy", "Avg_Win", "Avg_Loss");
        
        // Write strategy results
        for(int i = 0; i < 8; i++) {
            if(g_results[i].total_trades > 0) {
                FileWrite(file_handle, 
                         g_results[i].strategy_name,
                         g_results[i].total_trades,
                         g_results[i].win_rate,
                         g_results[i].net_profit,
                         g_results[i].profit_factor,
                         g_results[i].max_drawdown_percent,
                         g_results[i].sharpe_ratio,
                         g_results[i].sortino_ratio,
                         g_results[i].calmar_ratio,
                         g_results[i].expectancy,
                         g_results[i].average_win,
                         g_results[i].average_loss);
            }
        }
        
        FileClose(file_handle);
        Print("Results exported to: ", filename);
    } else {
        Print("Failed to create results file: ", filename);
    }
}

//+------------------------------------------------------------------+
//| Get strategy name by index                                       |
//+------------------------------------------------------------------+
string GetStrategyName(int index) {
    switch(index) {
        case 0: return "Order Block (Enhanced)";
        case 1: return "Fair Value Gap (Enhanced)";
        case 2: return "Market Structure";
        case 3: return "Range Breakout";
        case 4: return "Support/Resistance";
        case 5: return "Chart Pattern";
        case 6: return "Pin Bar";
        case 7: return "VWAP";
        default: return "Unknown Strategy";
    }
}