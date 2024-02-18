class DataFunction {
  static String? categoryToString(int category) {
    Map<int, String> map = {
      1: "Public Safety",
      2: "Fire Safety",
      3: "Accident Occurrence",
      4: "Natural Disaster",
      5: "General Emergency"
    };
    return map[category];
  }
 static String? detailToString(int detail) {
   Map<int, String> map = {
     1: "Sex Crime",
     2: "Robbery",
     3: "Theft",
     4: "Violent Crime",
     5: "Fire",
     6: "Confinement",
     7: "Emergency Medical Services",
     8: "Electrical Accident",
     9: "Gas Accident",
     10: "Fall",
     11: "Collapse Accident",
     12: "Typhoon",
     13: "Earthquake",
     14: "Request for Help",
   };
   return map[detail];
  }
}
