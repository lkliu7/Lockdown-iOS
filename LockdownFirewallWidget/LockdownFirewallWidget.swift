import SwiftUI
import WidgetKit

struct FirewallEntry: TimelineEntry {
    let date: Date
    let size: CGSize
    let isFirewallEnabled: Bool
    let dayMetricsString: String

    var buttonColor: Color { isFirewallEnabled ? .confirmedBlue : Color(.systemGray) }
}

struct FirewallProvider: TimelineProvider {
    func placeholder(in context: Context) -> FirewallEntry {
        FirewallEntry(
            date: Date(),
            size: context.displaySize,
            isFirewallEnabled: false,
            dayMetricsString: "--"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FirewallEntry) -> Void) {
        completion(entry(for: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FirewallEntry>) -> Void) {
        let refresh = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        completion(Timeline(entries: [entry(for: context)], policy: .after(refresh)))
    }

    private func entry(for context: Context) -> FirewallEntry {
        FirewallEntry(
            date: Date(),
            size: context.displaySize,
            isFirewallEnabled: LatestKnowledge.isFirewallEnabled,
            dayMetricsString: getDayMetricsString(commas: true)
        )
    }
}

struct LockdownFirewallWidgetEntryView: View {
    let entry: FirewallEntry

    var body: some View {
        VStack(spacing: 0) {
            LoadingCircle(
                tunnelState: TunnelState(
                    color: entry.buttonColor,
                    circleColor: entry.buttonColor
                ),
                side: entry.size.height,
                link: "lockdown://toggleFirewall"
            )
            .padding(EdgeInsets(top: 12, leading: 0, bottom: 2, trailing: 0))

            StatusLabel(
                text: NSLocalizedString(
                    entry.isFirewallEnabled ? "FIREWALL ON" : "FIREWALL OFF",
                    comment: ""
                ),
                color: entry.isFirewallEnabled ? .confirmedBlue : .flatRed
            )

            Spacer(minLength: entry.size.height < 160 ? 4 : nil)

            Link(destination: URL(string: "lockdown://showMetrics")!) {
                VStack(spacing: 0) {
                    Text(entry.dayMetricsString)
                        .font(.system(size: 21, weight: .semibold))
                    Text(NSLocalizedString("Blocked Today", comment: ""))
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(.bottom, 12)
            }
        }
        .frame(width: entry.size.height, height: entry.size.height)
    }
}

@main
struct LockdownFirewallWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LockdownFirewallWidget", provider: FirewallProvider()) { entry in
            ZStack {
                Color.panelBackground
                LockdownFirewallWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Firewall")
        .description("View and control the local Lockdown firewall.")
        .supportedFamilies([.systemSmall])
    }
}
