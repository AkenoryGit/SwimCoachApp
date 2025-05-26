//
//  AnimatedDaySwitcherView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 22.05.2025.
//

//import SwiftUI
//
//struct AnimatedDaySwitcherView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @Binding var selectedDate: Date
//    @State private var dragOffset: CGFloat = 0.0
//    @GestureState private var isDragging = false
//
//    var body: some View {
//        GeometryReader { geometry in
//            HStack(spacing: 0) {
//                DayTimelineView(selectedDate: .constant(previousDate))
//                    .id(previousDate)
//                    .frame(width: geometry.size.width)
//
//                ZStack(alignment: .topLeading) {
//                    BackgroundTimelineLayer(hourHeight: 60) // Нижний слой
//                        .zIndex(0)
//
//                    DayTimelineView(selectedDate: $selectedDate) // Тренировки
//                        .zIndex(1)
//
//                    DutyLayerView(selectedDate: $selectedDate) // Дежурства
//                        .zIndex(2)
//                }
//                .id(selectedDate)
//                .frame(width: geometry.size.width)
//
//                DayTimelineView(selectedDate: .constant(nextDate))
//                    .id(nextDate)
//                    .frame(width: geometry.size.width)
//            }
//            .offset(x: -geometry.size.width + dragOffset)
//            .gesture(
//                DragGesture()
//                    .onChanged { value in
//                        dragOffset = value.translation.width
//                    }
//                    .onEnded { value in
//                        let threshold = geometry.size.width / 3
//                        if value.translation.width < -threshold {
//                            // Свайп влево → следующий день
//                            withAnimation(.easeInOut(duration: 0.25)) {
//                                dragOffset = -geometry.size.width
//                            }
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                selectedDate = nextDate
//                                dragOffset = 0
//                            }
//                        } else if value.translation.width > threshold {
//                            // Свайп вправо → предыдущий день
//                            withAnimation(.easeInOut(duration: 0.25)) {
//                                dragOffset = geometry.size.width
//                            }
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                selectedDate = previousDate
//                                dragOffset = 0
//                            }
//                        } else {
//                            // Отмена свайпа — вернём на место
//                            withAnimation(.easeInOut(duration: 0.25)) {
//                                dragOffset = 0
//                            }
//                        }
//                    }
//            )
//        }
//    }
//
//    private var previousDate: Date {
//        Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
//    }
//
//    private var nextDate: Date {
//        Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
//    }
//}
