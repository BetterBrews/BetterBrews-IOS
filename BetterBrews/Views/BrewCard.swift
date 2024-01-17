//
//  BrewCard.swift
//  BetterBrews
//
//  Created by Colby Haskell on 1/16/24.
//

import SwiftUI


struct BrewCard: View {
    @EnvironmentObject var brewEquipment: BrewEquipmentList;
    
    let brewName: String;
    let brewType: String;
    let brewTime: Int;
    let brewNotes: String;
    let isFavorite: Bool;
    let avgRating: Double;
    
    let onFavoriteClick: () -> Void;
   
    // Calculate rotation angle of the card
    func rotationAngle(_ geometry: GeometryProxy) -> Angle {
        Angle(degrees: -((Double(geometry.frame(in: .global).minX) - 70.0)/18));
    }
    
    var body: some View {
        VStack {
            GeometryReader { cardGeo in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: cardGeo.size.height / 60.0) {
                        HStack {
                            Text(brewName)
                                .font(.title)
                                .bold()
                                .foregroundColor(Color("gold"))
                            Spacer()
                        }
                        HStack {
                            Text("Type:")
                                .foregroundColor(Color("lightTan"))
                                .font(.headline)
                            Text(brewType)
                                .foregroundColor(Color(.white))
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Est. Time:")
                                .font(.headline)
                                .foregroundColor(Color("lightTan"))
                            Text(String(format: "%1d:00", brewTime))
                                .foregroundColor(Color(.white))
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Average Rating:")
                                .foregroundColor(Color("lightTan"))
                                .font(.headline)
                            Text(String(format: "%.2f", avgRating))
                                .foregroundColor(.white)
                            
                        }
                        if(cardGeo.size.height >= 200) {
                            VStack(alignment: .leading) {
                                Text("Notes:")
                                    .font(.headline)
                                    .foregroundColor(Color("lightTan"))
                                Text(brewNotes)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.subheadline)
                                    .padding(.leading)
                                    .foregroundColor(Color(.white))
                            }
                        }

                    }
                    Spacer(minLength: 0)
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(Color("gold"))
                        .font(.headline)
                        .onTapGesture {
                            onFavoriteClick()
                        }
                }
                .padding(.vertical, 17)
                .padding(.horizontal, 20)
                .background(RoundedRectangle(cornerRadius: 40)
                    .foregroundColor(AppStyle.titleColor))
                .rotation3DEffect(rotationAngle(cardGeo), axis: (x:0, y: 10.0, z: 0))
            }
            
            
        }
    }
}

struct BrewCard_Previews: PreviewProvider {
    @State static var isFavorite: Bool = false;
    
    static var previews: some View {
        VStack {
            HStack {
                BrewCard(brewName: "Hario V60", brewType: "Pourover", brewTime: 5, brewNotes: "Very Good brew", isFavorite: isFavorite, avgRating: 4.6, onFavoriteClick: {isFavorite.toggle()})
            }.padding(.horizontal, 65)
        }.padding(.vertical, 200)
    }
}
