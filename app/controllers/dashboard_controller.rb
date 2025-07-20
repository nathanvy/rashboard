# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def index
    @trades    = Trade.order(:dtg)
    matched = match_trades(@trades)

    matched.each do |trade|
      breakdown = decompose_pnl(trade)
      trade.merge!(breakdown)
    end

    @completed = matched.sort_by { |c| c[:strike] }
    @intraday = compute_intraday_curve(@completed)

    @equity_series = compute_intraday_curve(@completed)
    
    @completed_columns = %i[
      symbol strike qty
      open_price close_price
      dPnL deltaPL thetaPL vegaPL gammaPL residual
      ]

    @completed_column_labels = {
      symbol:      "Symbol",
      strike:      "Strike",
      expiry:      "Expiry",
      qty:         "Qty",
      open_price:  "Entry Px",
      close_price: "Exit Px",
      dPnL:        "Total P&L",
      deltaPL:     "Δ P&L",
      thetaPL:     "Θ P&L",
      vegaPL:      "V P&L",
      gammaPL:     "Γ P&L",
      residual:    "Residual"
    }
  end

  private

  def match_trades(trades)
    opens     = Hash.new { |h, k| h[k] = [] }
    completed = []

    trades.each do |t|
      right = t.symbol.include?("Call") ? "CALL" : "PUT"
      key   = [ t.symbol, t.strike, t.expiry.to_s, t.qty, right ].join("|")
      effect = t.effect.to_s.downcase

      if effect.include?("open")
        opens[key] << t
      elsif effect.include?("close")
        if open_t = opens[key].shift
          completed << {
            symbol:       t.symbol,
            strike:       t.strike,
            expiry:       t.expiry,
            qty:          open_t.qty,
            open_dtg:     open_t.dtg,
            close_dtg:    t.dtg,
            open_price:   open_t.price,
            close_price:  t.price,
            open_spot:    open_t.spot,
            close_spot:   t.spot,
            open_iv:      open_t.iv,
            close_iv:     t.iv,
            delta:        open_t.delta,
            theta:        open_t.theta,
            gamma:        open_t.gamma,
            vega:         open_t.vega,
            pl:           (t.price - open_t.price) * open_t.qty
          }
        end
      end
    end

    completed
  end

  def decompose_pnl(trade)
    pl      = trade[:pl]
    d_spot  = trade[:close_spot] - trade[:open_spot]
    dt_days = (trade[:close_dtg] - trade[:open_dtg]) / 1.day.to_f
    d_sigma = trade[:close_iv] - trade[:open_iv]

    delta_pl = trade[:delta] * d_spot * trade[:qty]
    theta_pl = trade[:theta] * dt_days * trade[:qty]
    vega_pl  = trade[:vega]  * d_sigma * trade[:qty]
    gamma_pl = 0.5 * trade[:gamma] * (d_spot**2) * trade[:qty]
    residual = pl - (delta_pl + theta_pl + vega_pl + gamma_pl)

    {
      dPnL:      pl,
      deltaPL:  delta_pl,
      thetaPL:  theta_pl,
      vegaPL:   vega_pl,
      gammaPL:  gamma_pl,
      residual: residual
    }
  end

  def compute_intraday_curve(completed)
    today        = Time.zone.today
    start_of_day = Time.zone.now.beginning_of_day.to_i * 1_000 # js expects milliseconds since epoch
    cum          = 0.0
    points       = [ [ start_of_day, cum ] ]

    completed
      .sort_by { |c| c[:close_dtg] }
      .each do |c|
      next unless c[:close_dtg].to_date == today
      cum += c[:dPnL].to_f
      points << [ c[:close_dtg].to_i * 1_000, cum ]
    end

    points
  end
end
