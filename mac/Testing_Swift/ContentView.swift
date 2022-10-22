//
//  ContentView.swift
//  Created by Michael Simms on 5/3/22.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var state = AppState.shared

	var body: some View {
		Text("Heart Rate: " + String(state.currentHeartRateBpm) + " bpm")
		Text("Power: " + String(state.currentPowerWatts) + " watts")
			.padding()
		ForEach(state.radarMeasurements, id: \.self) { measurement in
			Text(String(format: "Radar Threat: %u meters", measurement.threatMeters))
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
