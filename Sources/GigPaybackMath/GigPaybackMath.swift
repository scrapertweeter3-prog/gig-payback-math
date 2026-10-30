import Foundation

/// Gig-economy payback math: the true hourly rate behind a side hustle,
/// priced after platform fees, self-employment tax, deactivation risk,
/// and the hours equipment or a pallet takes to pay itself back.
///
/// All money math runs on `Decimal` so receipt-level audits never inherit
/// floating-point drift. Pure Foundation, no dependencies.
public enum GigPaybackMathError: Error, Equatable {
    case nonPositiveHours
    case negativeMoney
    case nonPositiveNetGain
}

public struct GigPaybackMath {

    public init() {}

    // MARK: - True hourly rate

    /// True hourly rate after costs: (gross - costs) / hours.
    /// The number a gig listing never prints.
    @discardableResult
    public func trueHourlyRate(gross: Decimal, hours: Decimal, costs: [Decimal] = []) throws -> Decimal {
        guard hours > 0 else { throw GigPaybackMathError.nonPositiveHours }
        if gross < 0 { throw GigPaybackMathError.negativeMoney }
        var totalCosts: Decimal = 0
        for c in costs {
            if c < 0 { throw GigPaybackMathError.negativeMoney }
            totalCosts += c
        }
        return (gross - totalCosts) / hours
    }

    // MARK: - Self-employment tax

    /// US self-employment tax basis: 15.3% of 92.35% of net profit.
    /// The take-home slice a 1099 gig owes that a W-2 shift does not.
    @discardableResult
    public func selfEmploymentTax(netProfit: Decimal) throws -> Decimal {
        if netProfit < 0 { throw GigPaybackMathError.negativeMoney }
        return netProfit * 0.9235 * 0.153
    }

    // MARK: - Deactivation risk

    /// Pay lost across a gig-app deactivation: (weeklyPay - substituteWeeklyPay)
    /// times the suspended weeks. Positive means the deactivation is a real
    /// line item, not an annoyance; price it before stacking a second app.
    @discardableResult
    public func deactivationLoss(weeklyPay: Decimal, suspendedWeeks: Decimal, substituteWeeklyPay: Decimal = 0) throws -> Decimal {
        guard suspendedWeeks > 0 else { throw GigPaybackMathError.nonPositiveHours }
        if weeklyPay < 0 || substituteWeeklyPay < 0 { throw GigPaybackMathError.negativeMoney }
        return (weeklyPay - substituteWeeklyPay) * suspendedWeeks
    }

    /// Weeks of pay to hold before relying on a gig whose deactivation
    /// review takes `reviewWeeks`: the review window plus one week.
    @discardableResult
    public func bufferWeeks(reviewWeeks: Decimal) -> Decimal {
        return max(reviewWeeks, 1) + 1
    }

    // MARK: - Equipment payback

    /// Hours of work until an upfront equipment or pallet cost pays itself
    /// back at the net hourly gain it produces. A non-positive net gain
    /// never pays back.
    @discardableResult
    public func paybackHours(equipmentCost: Decimal, netHourlyGain: Decimal) throws -> Decimal {
        guard netHourlyGain > 0 else { throw GigPaybackMathError.nonPositiveNetGain }
        if equipmentCost < 0 { throw GigPaybackMathError.negativeMoney }
        return equipmentCost / netHourlyGain
    }

    // MARK: - Pallet flips

    /// Take-home on a return-pallet flip: resale proceeds minus pallet cost,
    /// transport, and marketplace fees, plus the true hourly rate for the
    /// sorting hours. One call for the whole receipt.
    @discardableResult
    public func palletTakeHome(palletCost: Decimal, transportCost: Decimal, marketplaceFees: Decimal, resaleProceeds: Decimal, sortingHours: Decimal) throws -> (takeHome: Decimal, hourly: Decimal) {
        let rate = try trueHourlyRate(gross: resaleProceeds, hours: sortingHours, costs: [palletCost, transportCost, marketplaceFees])
        let takeHome = resaleProceeds - (palletCost + transportCost + marketplaceFees)
        return (takeHome, rate)
    }
}
