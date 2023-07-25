//
//  HomeView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI


fileprivate let defaultSummaryHeight: CGFloat = 140
fileprivate let defaultAgentListHeight: CGFloat = 180

fileprivate let compactOffset: CGFloat = 55

struct HomeView: View {
    @ObservedObject var ln = LN.shared
    @ObservedObject var agents = Agents.shared
    
    var columns = [GridItem(.adaptive(minimum: 300), spacing: 20)]
    
    @State var isCompact = false
    @State var scrollOffset: CGFloat = 0
    
    @State var showReceive = false
    @State var showScanner = false
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.brandTextPrimary.opacity(0.7))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.brandTextSecondary.opacity(0.3))
        UIPageControl.appearance().tintColor = UIColor(Color.brandTextPrimary.opacity(0.7))
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack {
                    header
                        .offset(y: isCompact ? compactOffset : 0)
                    Group {
                        BalanceSummaryCard(isCompact: $isCompact)
                            .frame(height: isCompact ? 50 : defaultSummaryHeight)
                            .frame(maxWidth: isCompact ? 200 : .infinity)
                            .padding(.horizontal)
                        Group {
                            if #available(iOS 16.0, *) {
                                agentList.scrollIndicators(.hidden)
                            } else {
                                agentList
                            }
                        }
                    }
                    .offset(y: min(max(scrollOffset, 0) * 0.1, 15)) //Pulling down slightly
                }
                .background(Color.brandAccent2.opacity(isCompact ? 0.2 : 0))
                .background(.thinMaterial.opacity(isCompact ? 0.9 : 0))
                .cornerRadius(20)
                .offset(y: isCompact ? -compactOffset : 0)
                .zIndex(999)
                
                TransactionList(topSpace: defaultSummaryHeight + defaultAgentListHeight + 60) { y in
                    scrollOffset = y
                    
                    if !isCompact && y < -defaultSummaryHeight {
                        withAnimation(.easeInOut) {
                            isCompact = true
                        }
                    }
                    
                    if isCompact && y > -(defaultSummaryHeight/2) {
                        withAnimation(.easeInOut) {
                            isCompact = false
                        }
                    }
                }
                .refreshable {
                    try? await ln.sync()
                }
            }
            .background(
                Image("Blob 1")
                    .opacity(0.9)
                    .rotationEffect(.degrees(180))
                    .scaleEffect(max(1.3, 1.3 + scrollOffset * 0.001))
                    .offset(x: -320, y: -240 + scrollOffset * -0.1)
                    .accessibility(hidden: true)
            )
            .overlay(buttons, alignment: .bottom)
        }
    }
    
    var header: some View {
        HStack {
            Button {
                //TODO
            } label: {
                CustomIcon(systemName: "bolt.fill", accented: true, isLoading: !ln.synced)
            }
            .accessibilityLabel("Settings")
            
            Spacer()
            Text("\(scrollOffset)")
            
            Button {
                //TODO
            } label: {
                CustomIcon(systemName: "gear")
            }
            .accessibilityLabel("Settings")
            
        }
        .padding(.horizontal)
    }
    
    var agentList: some View {
        ScrollView(.horizontal){
            LazyHGrid(rows: [GridItem()]) {
                ForEach(agents.list, id: \.self) { agent in
                    AgentSummaryCard(agent: agent, isCompact: $isCompact)
                        .onTapGesture {
                            //                            selectedAgent = agent
                            //                            showAgent = true
                        }
                }
            }
            .frame(maxHeight: isCompact ? defaultAgentListHeight * 0.6 : defaultAgentListHeight)
            .padding()
            .offset(y: isCompact ? -12 : -10)
        }
        //        .sheet(isPresented: $showPost) {
        //            PostView(post: $selectedPost)
        //        }
        
    }
    
    var buttons: some View {
        HStack {
            FloatingButton(systemName: "arrow.down")
                .onTapGesture { showReceive = true }
            
            FloatingButton(systemName: "qrcode.viewfinder")
                .onTapGesture { showScanner = true }
        }
        .sheet(isPresented: $showReceive, content: {
            ReceiveView()
        })
        .sheet(isPresented: $showScanner, content: {
            ScannerView()
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .previewDevice("iPhone 14")
            HomeView()
                .previewDevice("iPhone 14")
                .environment(\.sizeCategory, .accessibilityLarge)
                .preferredColorScheme(.dark)
        }
    }
}
