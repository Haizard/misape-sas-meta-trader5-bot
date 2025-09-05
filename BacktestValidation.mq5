//+------------------------------------------------------------------+
//| BacktestValidation.mq5                                          |
//| Validation script for the enhanced backtesting framework        |
//+------------------------------------------------------------------+
#property copyright "Misape Bot Enhanced"
#property version   "1.00"
#property strict

// Include the main bot for testing
#include "Consolidated_Misape_Bot.mq5"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    Print("=== Backtest Validation Started ===");
    
    // Test backtesting framework components
    TestBacktestFramework();
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Test Backtest Framework                                         |
//+------------------------------------------------------------------+
void TestBacktestFramework() {
    Print("\n=== Testing Backtest Framework ===");
    
    // Test 1: Verify backtesting parameters
    Print("Test 1: Backtesting Parameters");
    Print("EnableBacktesting: ", EnableBacktesting);
    Print("BacktestStartDate: ", TimeToString(BacktestStartDate));
    Print("BacktestEndDate: ", TimeToString(BacktestEndDate));
    Print("ExportBacktestResults: ", ExportBacktestResults);
    Print("RunMonteCarloAfterBacktest: ", RunMonteCarloAfterBacktest);
    
    // Test 2: Initialize backtesting
    Print("\nTest 2: Initialize Backtesting");
    InitializeBacktesting();
    Print("Backtesting Active: ", g_backtesting_active);
    Print("Bars Processed: ", g_backtest_bars_processed);
    Print("Total Trades: ", g_backtest_total_trades);
    
    // Test 3: Simulate a backtest trade
    Print("\nTest 3: Simulate Backtest Trade");
    double test_price = 1.1000;
    double test_sl = 1.0950;
    double test_tp = 1.1100;
    double test_lot = 0.1;
    double test_confidence = 0.75;
    
    RecordBacktestTrade(SIGNAL_TYPE_BUY, test_price, test_sl, test_tp, test_lot, test_confidence, "Test Trade");
    Print("Trade recorded. Total trades: ", g_backtest_total_trades);
    
    if(g_backtest_total_trades > 0) {
        Print("Last trade details:");
        Print("  Type: ", g_backtest_trades[g_backtest_total_trades-1].signal_type == SIGNAL_TYPE_BUY ? "BUY" : "SELL");
        Print("  Entry Price: ", g_backtest_trades[g_backtest_total_trades-1].entry_price);
        Print("  Stop Loss: ", g_backtest_trades[g_backtest_total_trades-1].stop_loss);
        Print("  Take Profit: ", g_backtest_trades[g_backtest_total_trades-1].take_profit);
        Print("  Lot Size: ", g_backtest_trades[g_backtest_total_trades-1].lot_size);
        Print("  Confidence: ", g_backtest_trades[g_backtest_total_trades-1].confidence);
    }
    
    // Test 4: Test metrics calculation
    Print("\nTest 4: Metrics Calculation");
    // Simulate some winning and losing trades
    RecordBacktestTrade(SIGNAL_TYPE_SELL, 1.0950, 1.1000, 1.0900, 0.1, 0.80, "Test Win");
    RecordBacktestTrade(SIGNAL_TYPE_BUY, 1.1050, 1.1000, 1.1150, 0.1, 0.70, "Test Loss");
    
    // Calculate basic metrics
    double win_rate = g_backtest_winning_trades > 0 ? (double)g_backtest_winning_trades / g_backtest_total_trades * 100 : 0;
    Print("Win Rate: ", win_rate, "%");
    Print("Total P&L: $", g_backtest_total_pnl);
    Print("Max Drawdown: $", g_backtest_max_drawdown);
    
    // Test 5: Export functionality
    Print("\nTest 5: Export Test");
    if(ExportBacktestResults) {
        ExportBacktestResults();
        Print("Export completed");
    } else {
        Print("Export disabled in settings");
    }
    
    // Test 6: Finalize backtesting
    Print("\nTest 6: Finalize Backtesting");
    FinalizeBacktesting();
    Print("Backtesting Active: ", g_backtesting_active);
    
    Print("\n=== Backtest Framework Validation Complete ===");
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("=== Backtest Validation Ended ===");
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick() {
    // No tick processing needed for validation
}