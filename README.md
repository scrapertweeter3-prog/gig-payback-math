# GigPaybackMath

Gig-economy payback math for Swift: the true hourly rate behind a side
hustle, priced after the costs the listing never prints.

- `trueHourlyRate` - (gross - costs) / hours, the receipts-first rate
- `selfEmploymentTax` - the 15.3% x 92.35% SE-tax slice out of net profit
- `deactivationLoss` - the pay a gig-app deactivation actually eats
- `paybackHours` - hours until equipment or a return pallet pays for itself
- `palletTakeHome` - one call for the whole pallet-flip receipt

All money math runs on `Decimal`, so cost audits never inherit
floating-point drift. Pure Foundation, no dependencies, iOS 13+ / macOS
10.15+, Swift 5.9.

## Why

Side-hustle listings quote gross pay. The real number is net per hour
after platform fees, self-employment tax, the weeks a deactivation
freeze can eat, and the sorting hours a $40 pallet costs. This pod
prices those lines so the comparison is honest.

## Usage

    let math = GigPaybackMath()
    let flip = try math.palletTakeHome(
        palletCost: 40, transportCost: 25, marketplaceFees: 12,
        resaleProceeds: 180, sortingHours: 6)
    // flip.takeHome = 103, flip.hourly ~ 17.17

## Installation (CocoaPods)

    pod 'GigPaybackMath', '~> 0.1'

Built by the [Extra Hustles](https://www.extrahustles.com) team, which
publishes true-hourly-rate math for side hustlers.

## License

MIT
