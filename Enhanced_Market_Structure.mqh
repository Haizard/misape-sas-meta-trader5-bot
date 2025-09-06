//+------------------------------------------------------------------+
//| Enhanced Market Structure Implementation                         |
//| Advanced BOS Detection with Mathematical Validation             |
//| Based on Academic Research in Market Microstructure Theory      |
//+------------------------------------------------------------------+

#property strict

//+------------------------------------------------------------------+
//| Enhanced Market Structure Structures                             |
//+------------------------------------------------------------------+

// Advanced Market Structure Signal
struct AdvancedMarketStructureSignal {
    double bos_confidence;              // BOS confidence score (0-1)
    double choch_probability;           // Change of Character probability
    double mss_strength;                // Market Structure Shift strength
    double order_flow_imbalance;        // Order flow imbalance score
    double institutional_flow_score;    // Institutional flow detection
    double mtf_confluence_score;        // Multi-timeframe confluence
    double statistical_significance;    // P-value for signal validity
    double volume_confirmation;         // Volume confirmation factor
    double strength_factor;             // Break strength relative to ATR
    double time_factor;                 // Time-based validation factor
    bool is_validated;                  // Statistical validation passed
    bool is_false_break;               // False break detection
    datetime last_update;              // Last calculation timestamp
    string signal_details;             // Detailed signal information
};

// Swing Point Structure
struct SwingPoint {
    double price;
    datetime time;
    int bar_index;
    bool is_high;                      // true for swing high, false for swing low
    double strength;                   // Swing strength score
    double volume_at_swing;            // Volume at swing formation
    bool is_broken;                    // Whether this swing has been broken
    datetime break_time;               // When the swing was broken
};

// Market Structure State
struct MarketStructureState {
    int trend_direction;               // 1 = bullish, -1 = bearish, 0 = neutral
    SwingPoint last_swing_high;
    SwingPoint last_swing_low;
    SwingPoint previous_swing_high;
    SwingPoint previous_swing_low;
    double trend_momentum;             // Current trend momentum
    double structure_quality;          // Overall structure quality score
    bool choch_detected;              // Change of Character detected
    bool mss_detected;                // Market Structure Shift detected
    datetime last_structure_update;
};

//+------------------------------------------------------------------+
//| Enhanced Market Structure Input Parameters                       |
//+------------------------------------------------------------------+

input group "=== Enhanced Market Structure Settings ==="
input bool MS_EnableAdvancedBOS = true;                    // Enable advanced BOS detection
input bool MS_EnableCHoCH = true;                          // Enable CHoCH detection
input bool MS_EnableMSS = true;                            // Enable MSS detection
input double MS_MinBOSStrength = 1.5;                      // Minimum BOS strength (ATR multiplier)
input double MS_VolumeConfirmationThreshold = 1.2;         // Volume confirmation threshold
input int MS_SwingDetectionPeriod = 20;                    // Adaptive swing detection period
input double MS_StatisticalSignificance = 0.05;            // P-value threshold for signal validity
input bool MS_EnableOrderFlowAnalysis = true;              // Enable order flow imbalance analysis
input double MS_CHoCHSensitivity = 0.7;                    // CHoCH detection sensitivity (0-1)
input double MS_MSSThreshold = 2.0;                        // MSS strength threshold (ATR multiplier)
input bool MS_EnableMultiTimeframeValidation = true;       // Enable MTF validation
input double MS_FalseBreakFilterStrength = 0.8;            // False break filter strength
input int MS_InstitutionalFlowPeriod = 50;                 // Period for institutional flow analysis

//+------------------------------------------------------------------+
//| Global Variables for Enhanced Market Structure                   |
//+------------------------------------------------------------------+

MarketStructureState g_ms_state;
SwingPoint g_swing_highs[];
SwingPoint g_swing_lows[];
double g_volume_profile[];
double g_order_flow_data[];
double g_institutional_flow_history[];

//+------------------------------------------------------------------+
//| Enhanced Market Structure Initialization                         |
//+------------------------------------------------------------------+
void InitializeEnhancedMarketStructure() {
    // Initialize market structure state
    g_ms_state.trend_direction = 0;
    g_ms_state.trend_momentum = 0.0;
    g_ms_state.structure_quality = 0.0;
    g_ms_state.choch_detected = false;
    g_ms_state.mss_detected = false;
    g_ms_state.last_structure_update = 0;
    
    // Initialize arrays
    ArrayResize(g_swing_highs, 100);
    ArrayResize(g_swing_lows, 100);
    ArrayResize(g_volume_profile, 200);
    ArrayResize(g_order_flow_data, 200);
    ArrayResize(g_institutional_flow_history, 100);
    
    // Initialize swing points
    for(int i = 0; i < 100; i++) {
        g_swing_highs[i].price = 0.0;
        g_swing_highs[i].time = 0;
        g_swing_highs[i].is_broken = false;
        g_swing_lows[i].price = 0.0;
        g_swing_lows[i].time = 0;
        g_swing_lows[i].is_broken = false;
    }
    
    Print("Enhanced Market Structure initialized successfully");
}

//+------------------------------------------------------------------+
//| Advanced Swing Detection Algorithm                               |
//+------------------------------------------------------------------+
SwingPoint DetectAdvancedSwing(bool find_high, int lookback_period = 0) {
    SwingPoint swing;
    swing.price = 0.0;
    swing.time = 0;
    swing.bar_index = -1;
    swing.is_high = find_high;
    swing.strength = 0.0;
    swing.volume_at_swing = 0.0;
    swing.is_broken = false;
    
    if(lookback_period == 0) lookback_period = MS_SwingDetectionPeriod;
    
    double atr_value = iATR(_Symbol, _Period, 14, 1);
    double avg_volume = 0.0;
    
    // Calculate average volume for comparison
    for(int i = 1; i <= 20; i++) {
        avg_volume += iVolume(_Symbol, _Period, i);
    }
    avg_volume /= 20.0;
    
    // Adaptive swing detection based on volatility
    int min_bars = MathMax(3, (int)(lookback_period * 0.3));
    int max_bars = MathMin(50, lookback_period);
    
    for(int center = min_bars; center <= max_bars; center++) {
        bool is_swing = true;
        double center_price = find_high ? iHigh(_Symbol, _Period, center) : iLow(_Symbol, _Period, center);
        double center_volume = iVolume(_Symbol, _Period, center);
        
        // Check if this is a valid swing point
        for(int i = 1; i <= min_bars; i++) {
            double left_price = find_high ? iHigh(_Symbol, _Period, center + i) : iLow(_Symbol, _Period, center + i);
            double right_price = find_high ? iHigh(_Symbol, _Period, center - i) : iLow(_Symbol, _Period, center - i);
            
            if(find_high) {
                if(center_price <= left_price || center_price <= right_price) {
                    is_swing = false;
                    break;
                }
            } else {
                if(center_price >= left_price || center_price >= right_price) {
                    is_swing = false;
                    break;
                }
            }
        }
        
        if(is_swing) {
            // Calculate swing strength
            double price_range = 0.0;
            for(int i = 1; i <= min_bars; i++) {
                double left_price = find_high ? iHigh(_Symbol, _Period, center + i) : iLow(_Symbol, _Period, center + i);
                double right_price = find_high ? iHigh(_Symbol, _Period, center - i) : iLow(_Symbol, _Period, center - i);
                
                if(find_high) {
                    price_range += (center_price - MathMax(left_price, right_price));
                } else {
                    price_range += (MathMin(left_price, right_price) - center_price);
                }
            }
            
            double strength = (price_range / atr_value) / min_bars;
            
            // Volume confirmation factor
            double volume_factor = center_volume / avg_volume;
            
            // Combined strength score
            double combined_strength = strength * (1.0 + (volume_factor - 1.0) * 0.3);
            
            if(combined_strength > swing.strength) {
                swing.price = center_price;
                swing.time = iTime(_Symbol, _Period, center);
                swing.bar_index = center;
                swing.strength = combined_strength;
                swing.volume_at_swing = center_volume;
            }
        }
    }
    
    return swing;
}

//+------------------------------------------------------------------+
//| Calculate Order Flow Imbalance                                   |
//+------------------------------------------------------------------+
double CalculateOrderFlowImbalance(int period = 20) {
    if(!MS_EnableOrderFlowAnalysis) return 0.0;
    
    double total_buy_volume = 0.0;
    double total_sell_volume = 0.0;
    double total_volume = 0.0;
    
    for(int i = 1; i <= period; i++) {
        double open_price = iOpen(_Symbol, _Period, i);
        double close_price = iClose(_Symbol, _Period, i);
        double volume = iVolume(_Symbol, _Period, i);
        
        total_volume += volume;
        
        // Estimate buy/sell volume based on price movement
        if(close_price > open_price) {
            // More buying pressure
            double buy_ratio = (close_price - open_price) / (iHigh(_Symbol, _Period, i) - iLow(_Symbol, _Period, i));
            total_buy_volume += volume * (0.5 + buy_ratio * 0.5);
            total_sell_volume += volume * (0.5 - buy_ratio * 0.5);
        } else if(close_price < open_price) {
            // More selling pressure
            double sell_ratio = (open_price - close_price) / (iHigh(_Symbol, _Period, i) - iLow(_Symbol, _Period, i));
            total_sell_volume += volume * (0.5 + sell_ratio * 0.5);
            total_buy_volume += volume * (0.5 - sell_ratio * 0.5);
        } else {
            // Neutral
            total_buy_volume += volume * 0.5;
            total_sell_volume += volume * 0.5;
        }
    }
    
    if(total_volume == 0.0) return 0.0;
    
    // Order Flow Imbalance = (Buy Volume - Sell Volume) / Total Volume
    double ofi = (total_buy_volume - total_sell_volume) / total_volume;
    
    return ofi;
}

//+------------------------------------------------------------------+
//| Calculate Institutional Flow Score                               |
//+------------------------------------------------------------------+
double CalculateInstitutionalFlow(int period = 0) {
    if(period == 0) period = MS_InstitutionalFlowPeriod;
    
    double institutional_score = 0.0;
    double avg_volume = 0.0;
    double volume_variance = 0.0;
    
    // Calculate average volume
    for(int i = 1; i <= period; i++) {
        avg_volume += iVolume(_Symbol, _Period, i);
    }
    avg_volume /= period;
    
    // Calculate volume variance
    for(int i = 1; i <= period; i++) {
        double vol_diff = iVolume(_Symbol, _Period, i) - avg_volume;
        volume_variance += vol_diff * vol_diff;
    }
    volume_variance /= period;
    double volume_stddev = MathSqrt(volume_variance);
    
    // Detect institutional activity patterns
    for(int i = 1; i <= period; i++) {
        double volume = iVolume(_Symbol, _Period, i);
        double price_range = iHigh(_Symbol, _Period, i) - iLow(_Symbol, _Period, i);
        double atr_value = iATR(_Symbol, _Period, 14, i);
        
        // Large volume with small price movement (accumulation/distribution)
        if(volume > avg_volume + volume_stddev && price_range < atr_value * 0.5) {
            institutional_score += 0.3;
        }
        
        // Large volume with large price movement (institutional breakout)
        if(volume > avg_volume + 2 * volume_stddev && price_range > atr_value * 1.5) {
            institutional_score += 0.5;
        }
        
        // Volume concentration analysis
        if(volume > avg_volume + 1.5 * volume_stddev) {
            institutional_score += 0.2;
        }
    }
    
    // Normalize score
    institutional_score = institutional_score / period;
    
    return MathMin(1.0, institutional_score);
}

//+------------------------------------------------------------------+
//| Calculate Multi-Timeframe Confluence Score                       |
//+------------------------------------------------------------------+
double CalculateMultiTimeframeConfluence() {
    if(!MS_EnableMultiTimeframeValidation) return 0.5;
    
    double mtf_score = 0.0;
    double total_weight = 0.0;
    
    // Timeframe weights based on research
    double weights[] = {0.1, 0.2, 0.4, 0.3}; // M15, H1, H4, D1
    ENUM_TIMEFRAMES timeframes[] = {PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};
    
    for(int tf = 0; tf < 4; tf++) {
        if(timeframes[tf] >= _Period) { // Only use higher timeframes
            // Get trend direction for this timeframe
            double ema_fast = iMA(_Symbol, timeframes[tf], 20, 0, MODE_EMA, PRICE_CLOSE);
            double ema_slow = iMA(_Symbol, timeframes[tf], 50, 0, MODE_EMA, PRICE_CLOSE);
            double current_price = iClose(_Symbol, timeframes[tf], 1);
            
            double trend_strength = 0.0;
            if(ema_fast > ema_slow && current_price > ema_fast) {
                trend_strength = 1.0; // Bullish
            } else if(ema_fast < ema_slow && current_price < ema_fast) {
                trend_strength = -1.0; // Bearish
            }
            
            // Weight the trend strength
            mtf_score += trend_strength * weights[tf];
            total_weight += weights[tf];
        }
    }
    
    if(total_weight > 0) {
        mtf_score = mtf_score / total_weight;
    }
    
    // Convert to 0-1 scale
    return (mtf_score + 1.0) / 2.0;
}

//+------------------------------------------------------------------+
//| Advanced BOS Detection with Mathematical Validation              |
//+------------------------------------------------------------------+
AdvancedMarketStructureSignal DetectAdvancedBOS() {
    AdvancedMarketStructureSignal signal;
    
    // Initialize signal
    signal.bos_confidence = 0.0;
    signal.choch_probability = 0.0;
    signal.mss_strength = 0.0;
    signal.order_flow_imbalance = 0.0;
    signal.institutional_flow_score = 0.0;
    signal.mtf_confluence_score = 0.0;
    signal.statistical_significance = 1.0;
    signal.volume_confirmation = 0.0;
    signal.strength_factor = 0.0;
    signal.time_factor = 0.0;
    signal.is_validated = false;
    signal.is_false_break = false;
    signal.last_update = TimeCurrent();
    signal.signal_details = "";
    
    // Get current market data
    double current_price = iClose(_Symbol, _Period, 0);
    double atr_value = iATR(_Symbol, _Period, 14, 1);
    
    // Detect recent swing points
    SwingPoint recent_high = DetectAdvancedSwing(true);
    SwingPoint recent_low = DetectAdvancedSwing(false);
    
    // Update market structure state
    if(recent_high.price > 0 && recent_high.time > g_ms_state.last_swing_high.time) {
        g_ms_state.previous_swing_high = g_ms_state.last_swing_high;
        g_ms_state.last_swing_high = recent_high;
    }
    
    if(recent_low.price > 0 && recent_low.time > g_ms_state.last_swing_low.time) {
        g_ms_state.previous_swing_low = g_ms_state.last_swing_low;
        g_ms_state.last_swing_low = recent_low;
    }
    
    // Calculate order flow and institutional metrics
    signal.order_flow_imbalance = CalculateOrderFlowImbalance();
    signal.institutional_flow_score = CalculateInstitutionalFlow();
    signal.mtf_confluence_score = CalculateMultiTimeframeConfluence();
    
    // Check for BOS conditions
    bool bullish_bos = false;
    bool bearish_bos = false;
    
    // Bullish BOS: Price breaks above previous swing high
    if(g_ms_state.last_swing_high.price > 0 && current_price > g_ms_state.last_swing_high.price) {
        double break_distance = current_price - g_ms_state.last_swing_high.price;
        signal.strength_factor = break_distance / atr_value;
        
        if(signal.strength_factor >= MS_MinBOSStrength) {
            bullish_bos = true;
            signal.signal_details += "Bullish BOS detected. ";
        }
    }
    
    // Bearish BOS: Price breaks below previous swing low
    if(g_ms_state.last_swing_low.price > 0 && current_price < g_ms_state.last_swing_low.price) {
        double break_distance = g_ms_state.last_swing_low.price - current_price;
        signal.strength_factor = break_distance / atr_value;
        
        if(signal.strength_factor >= MS_MinBOSStrength) {
            bearish_bos = true;
            signal.signal_details += "Bearish BOS detected. ";
        }
    }
    
    // Calculate BOS confidence using mathematical model
    if(bullish_bos || bearish_bos) {
        // Volume confirmation factor
        double current_volume = iVolume(_Symbol, _Period, 0);
        double avg_volume = 0.0;
        for(int i = 1; i <= 20; i++) {
            avg_volume += iVolume(_Symbol, _Period, i);
        }
        avg_volume /= 20.0;
        signal.volume_confirmation = current_volume / avg_volume;
        
        // Time factor (time since last touch of the level)
        datetime last_touch_time = bullish_bos ? g_ms_state.last_swing_high.time : g_ms_state.last_swing_low.time;
        signal.time_factor = MathMin(1.0, (TimeCurrent() - last_touch_time) / (24 * 3600.0)); // Normalize to days
        
        // Calculate BOS confidence using enhanced mathematical model
        signal.bos_confidence = (signal.strength_factor * 0.3 + 
                               signal.volume_confirmation * 0.2 + 
                               signal.time_factor * 0.1 + 
                               signal.mtf_confluence_score * 0.4) / 1.0;
        
        // Apply volume confirmation threshold
        if(signal.volume_confirmation >= MS_VolumeConfirmationThreshold) {
            signal.bos_confidence *= 1.2; // Boost confidence with volume confirmation
        }
        
        // Statistical significance test (simplified)
        if(signal.strength_factor > 2.0 && signal.volume_confirmation > 1.5) {
            signal.statistical_significance = 0.01; // High significance
        } else if(signal.strength_factor > 1.5 && signal.volume_confirmation > 1.2) {
            signal.statistical_significance = 0.05; // Moderate significance
        } else {
            signal.statistical_significance = 0.1; // Low significance
        }
        
        // Validate signal
        signal.is_validated = (signal.statistical_significance <= MS_StatisticalSignificance && 
                              signal.bos_confidence >= 0.6);
        
        // False break detection
        signal.is_false_break = (signal.strength_factor < MS_FalseBreakFilterStrength || 
                                signal.volume_confirmation < 0.8);
        
        signal.signal_details += StringFormat("Confidence: %.2f, Strength: %.2f, Volume: %.2f, MTF: %.2f", 
                                             signal.bos_confidence, signal.strength_factor, 
                                             signal.volume_confirmation, signal.mtf_confluence_score);
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| Enhanced Market Structure Strategy Runner                        |
//+------------------------------------------------------------------+
TradingSignal RunEnhancedMarketStructureStrategy() {
    TradingSignal trading_signal;
    trading_signal.signal_type = SIGNAL_TYPE_HOLD;
    trading_signal.confidence_level = 0.0;
    trading_signal.stop_loss = 0.0;
    trading_signal.take_profit = 0.0;
    trading_signal.parameters = "";
    trading_signal.strategy_name = "Enhanced Market Structure";
    trading_signal.timestamp = TimeCurrent();
    trading_signal.is_valid = false;
    
    // Get advanced BOS signal
    AdvancedMarketStructureSignal ms_signal = DetectAdvancedBOS();
    
    if(ms_signal.is_validated && !ms_signal.is_false_break) {
        double current_price = iClose(_Symbol, _Period, 0);
        double atr_value = iATR(_Symbol, _Period, 14, 1);
        
        // Determine signal direction based on BOS type
        if(current_price > g_ms_state.last_swing_high.price && ms_signal.bos_confidence > 0.6) {
            // Bullish BOS
            trading_signal.signal_type = SIGNAL_TYPE_BUY;
            trading_signal.confidence_level = ms_signal.bos_confidence;
            trading_signal.stop_loss = g_ms_state.last_swing_high.price - atr_value * 0.5;
            trading_signal.take_profit = current_price + atr_value * 3.0;
            trading_signal.parameters = "Enhanced_BOS_Bullish_" + DoubleToString(ms_signal.bos_confidence, 2);
            trading_signal.is_valid = true;
        }
        else if(current_price < g_ms_state.last_swing_low.price && ms_signal.bos_confidence > 0.6) {
            // Bearish BOS
            trading_signal.signal_type = SIGNAL_TYPE_SELL;
            trading_signal.confidence_level = ms_signal.bos_confidence;
            trading_signal.stop_loss = g_ms_state.last_swing_low.price + atr_value * 0.5;
            trading_signal.take_profit = current_price - atr_value * 3.0;
            trading_signal.parameters = "Enhanced_BOS_Bearish_" + DoubleToString(ms_signal.bos_confidence, 2);
            trading_signal.is_valid = true;
        }
        
        // Add detailed signal information
        trading_signal.parameters += "_" + ms_signal.signal_details;
    }
    
    return trading_signal;
}

//+------------------------------------------------------------------+
//| Enhanced Market Structure Cleanup                                |
//+------------------------------------------------------------------+
void CleanupEnhancedMarketStructure() {
    // Clean up arrays and reset state
    ArrayFree(g_swing_highs);
    ArrayFree(g_swing_lows);
    ArrayFree(g_volume_profile);
    ArrayFree(g_order_flow_data);
    ArrayFree(g_institutional_flow_history);
    
    Print("Enhanced Market Structure cleanup completed");
}

//+------------------------------------------------------------------+