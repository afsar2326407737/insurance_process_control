class BankDet {
  List<Banks>? banks;

  BankDet({this.banks});

  BankDet.fromJson(Map<String, dynamic> json) {
    if (json['banks'] != null) {
      banks = <Banks>[];
      json['banks'].forEach((v) {
        banks!.add(new Banks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.banks != null) {
      data['banks'] = this.banks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Banks {
  String? bankId;
  String? bankName;

  Banks({this.bankId, this.bankName});

  Banks.fromJson(Map<String, dynamic> json) {
    bankId = json['bank_id'];
    bankName = json['bank_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bank_id'] = this.bankId;
    data['bank_name'] = this.bankName;
    return data;
  }
}