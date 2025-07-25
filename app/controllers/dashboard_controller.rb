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
    @return_histogram = build_return_histogram(@completed)
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

  def build_return_histogram(completed)
    edges = [ -Float::INFINITY, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5, 2.0, Float::INFINITY ]
    labels = edges.each_cons(2).map do |low, high|
      if low.infinite? && high < Float::INFINITY
        "≤ #{sprintf('%.1f', high)}%"
      elsif low > -Float::INFINITY && high.infinite?
        "≥ #{sprintf('%.1f', low)}%"
      else
        "#{sprintf('%.1f', low)} – #{sprintf('%.1f', high)}%"
      end
    end

    counts = Array.new(labels.size, 0)
    completed.each do |trade|
      ret = ((trade[:close_price] - trade[:open_price]) / trade[:open_price]) * 100.0
      idx = edges.each_cons(2).with_index.find do |(low, high), i|
        ret >= low && ret < high
      end&.last
      counts[idx] += 1 if idx
    end
    { labels: labels, counts: counts }
  end
  
  def match_trades(trades)
  opens     = Hash.new { |h, k| h[k] = [] }
  completed = []

  trades.each do |t|
    right  = t.symbol.include?("Call") ? "CALL" : "PUT"
    key    = [t.symbol, t.strike, t.expiry.to_s, t.qty, right].join("|")
    effect = t.effect.to_s.downcase

    if effect.include?("open")
      opens[key] << t

    elsif effect.include?("close")
      if open_t = opens[key].shift
        completed << {
          symbol:        t.symbol,
          strike:        t.strike,
          expiry:        t.expiry,
          qty:           open_t.qty,

          open_dtg:      open_t.dtg,
          close_dtg:     t.dtg,

          open_price:    open_t.price  * 100,
          close_price:   t.price       * 100,

          open_spot:     open_t.spot,
          close_spot:    t.spot,

          open_iv:       open_t.iv * 100,
          close_iv:      t.iv * 100,

          # opening greeks
          open_delta:    open_t.delta,
          open_theta:    open_t.theta,
          open_vega:     open_t.vega,
          open_gamma:    open_t.gamma,

          # closing greeks
          close_delta:   t.delta,
          close_theta:   t.theta,
          close_vega:    t.vega,
          close_gamma:   t.gamma,

          # realized P&L in dollars
          pl:            (t.price - open_t.price) * 100 * open_t.qty
        }
      end
    end
  end

  completed
end


  def decompose_pnl(trade)
  # 1) Compute P&L from prices & qty
  p0      = trade[:open_price].to_f
  p1      = trade[:close_price].to_f
  d_pnl   = (p1 - p0) * trade[:qty].to_f

  # 2) Spot & IV moves
  d_spot  = trade[:close_spot].to_f - trade[:open_spot].to_f
  d_sigma = trade[:close_iv].to_f   - trade[:open_iv].to_f

  # 3) Elapsed time in days
  dt = (trade[:close_dtg] - trade[:open_dtg]) / 1.day.to_f

  # 4) Pull **initial** greeks (at open)
  delta0  = trade[:open_delta].to_f
  theta0  = trade[:open_theta].to_f
  vega0   = trade[:open_vega].to_f
  gamma0  = trade[:open_gamma].to_f

  # 5) Compute each greek’s P&L
  delta_pl = delta0 * d_spot    * 100 * trade[:qty]
  theta_pl = theta0 * dt   * 100 *  trade[:qty]
  vega_pl  = vega0  * d_sigma   *  100 * trade[:qty]
  gamma_pl = 0.5    * gamma0 * (d_spot**2) *  100 * trade[:qty]

  # 6) Residual = total – sum(greeks)
  residual = d_pnl - (delta_pl + theta_pl + vega_pl + gamma_pl)

  # 7) Return with the same keys your charting code expects
  {
    dPnL:     d_pnl,
    deltaPL:  delta_pl,
    thetaPL:  theta_pl,
    vegaPL:   vega_pl,
    gammaPL:  gamma_pl,
    residual: residual
  }
end


  def compute_intraday_curve(completed)
    return [] if completed.empty?
    sorted = completed.sort_by { |c| c[:close_dtg] }
    first_time = sorted.first[:close_dtg].in_time_zone(Time.zone)
    curve_date = first_time.to_date
    session_start = Time.zone.local(curve_date.year,
                                  curve_date.month,
                                  curve_date.day,
                                  9, 30)    #  9:30 AM
    session_end = Time.zone.local(curve_date.year,
                                  curve_date.month,
                                  curve_date.day,
                                  16,  0)    #  4:00 PM


    cum = 0.0
    points = [ [ session_start.to_i * 1_000, cum ] ]

    sorted.each do |c|
      t = c[:close_dtg].in_time_zone(Time.zone)
      # next if t < session_start || t > session_end
      cum += c[:dPnL].to_f
      points << [ t.to_i * 1_000, cum ]
    end

    points
  end
end
