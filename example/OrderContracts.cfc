component extends="EnforcedCFOO" {

  public struct function orderContract() {
    return {
      id: stringSetter,
      delivery_address: addressContract,
      billing_address: addressContract,
      delivery_options: hashset(deliveryOptionContract),
      accepted_cards: arraySetter,
      has_payment: booleanSetter,
      data: structSetter,
      total: numberSetter,
      phone: stringSetter
    };
  }

  public struct function addressContract() {
    return {
      id: stringSetter,
      address_1: stringSetter,
      address_2: stringSetter,
      city: stringSetter,
      state: stringSetter,
      post_code: stringSetter,
      country: stringSetter
    };
  }

  public struct function deliveryOptionContract() {
    return {
      id: numberSetter,
      name: stringSetter,
      price: numberSetter
    };
  }
}
