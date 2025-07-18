class DashboardController < ApplicationController
  require "open3" # for shell
  def index
    @trades = Trade.order(:dtg)
    @completed = match_trades(@trades)
    @completed.each do |c|
      c.merge!(decompose_pnl(c))
    end
    @intraday = compute_intraday_curve(@completed)
    # dump_dat_and_plot(@intraday)
  end

  private

  def match_trades(trades)
    opens = Hash.new { |h, k| h[k] = [] }
    completed = []

    trades.each do |t|
      key = [ t.symbol, t.strike, t.expiry, t.qty, t.symbol.include?("Call") ? "CALL" : "PUT" ].join("|")
      if t.effect.upcase == "OPEN"
        opens[key] << t
      else
        o = opens[key].shift
        pl = (t.price - o.price) * o.qty
        completed << o.attributes.symbolize_keys.merge(
          close_dtg:   t.dtg,
          close_price: t.price,
          pl:          pl,
          open_dtg:    o.dtg,
          open_price:  o.price,
          open_spot:   o.spot,
          close_spot:  t.spot,
          open_iv:     o.iv,
          close_iv:    t.iv,
          delta:       o.delta,
          theta:       o.theta,
          gamma:       o.gamma,
          vega:        o.vega
        )
      end
    end

    completed
  end

  def decompose_pnl(tr)
    d_pnl   = tr[:pl]
    d_spot  = tr[:close_spot] - tr[:open_spot]
    dt_days = (tr[:close_dtg] - tr[:open_dtg]) / 1.day.to_i
    d_sigma = tr[:close_iv] - tr[:open_iv]

    delta_pl = tr[:delta] * d_spot * tr[:qty]
    theta_pl = tr[:theta] * dt_days  * tr[:qty]
    vega_pl  = tr[:vega]  * d_sigma * tr[:qty]
    gamma_pl = 0.5 * tr[:gamma] * d_spot**2 * tr[:qty]
    residual = d_pnl - (delta_pl + theta_pl + vega_pl + gamma_pl)

    { dPnL: d_pnl, deltaPL: delta_pl, thetaPL: theta_pl, vegaPL: vega_pl, gammaPL: gamma_pl, residual: residual }
  end

  def compute_intraday_curve(completed)
    cum = 0.0
    today = Time.zone.today
    completed.each_with_object([]) do |c, arr|
      if c[:close_dtg].to_date == today
        cum += c[:dPnL]
        arr << [ c[:close_dtg].to_i, cum ]
      end
    end
  end

  def dump_dat_and_plot(data)
    dat = Rails.root.join("public", "intraday_equity.dat")
    png = Rails.root.join("public", "intraday_equity.png")
    File.write(dat, data.map { |ts, v| "#{ts} #{v}" }.join("\n"))
    system("gnuplot #{Rails.root.join('intraday_equity.plt')}")
  end
end
