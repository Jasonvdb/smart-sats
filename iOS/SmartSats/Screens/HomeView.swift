//
//  HomeView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI


fileprivate let defaultSummaryHeight: CGFloat = 160
fileprivate let defaultAgentListHeight: CGFloat = 200

struct HomeView: View {
    @ObservedObject var ln = LN.shared
    @ObservedObject var agents = Agents.shared
    
    var columns = [GridItem(.adaptive(minimum: 300), spacing: 20)]
    
    @State var isCompact = false
    @State var scrollOffset: CGFloat = 0
    
    @Namespace var namespace
    
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
                    WalletSummaryCard(isCompact: $isCompact)
                        .frame(height: isCompact ? defaultSummaryHeight * 0.4 : defaultSummaryHeight)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    Group {
                        if #available(iOS 16.0, *) {
                            agentList.scrollIndicators(.hidden)
                        } else {
                            agentList
                        }
                    }
                }
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
            }
            .background(
                Image("Blob 1")
                    .opacity(0.9)
                    .rotationEffect(.degrees(180))
                    .scaleEffect(1.3)
                    .offset(x: -320, y: -240 + scrollOffset * -0.2)
                    .accessibility(hidden: true)
            )
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
//                        Text("\(scrollOffset)")
            
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
