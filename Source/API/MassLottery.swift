//
//  MassLottery.swift
//  MassStateKeno
//
//  Created by Jeff Kereakoglow on 2/24/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Foundation

enum MassLottery {
  enum Keno {
    case WinningNumbers
  }
}

extension MassLottery.Keno: Path {
  var path: String {
    switch self {
    case .WinningNumbers: return "/search/dailygames/todays/15.json"
    }
  }
}