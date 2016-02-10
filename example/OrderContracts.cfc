component extends="EnforcedCFOO" {

  public struct function orderConstraint() {
    return {
      id: stringSetter,
      delivery_address: addressConstraint,
      billing_address: addressConstraint,
      delivery_options: hashset(deliveryOptionConstraint),
      accepted_cards: arraySetter,
      has_payment: booleanSetter,
      data: structSetter,
      total: numberSetter,
      phone: stringSetter
    };
  }

  public struct function addressConstraint() {
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

  public struct function deliveryOptionConstraint() {
    return {
      id: numberSetter,
      name: stringSetter,
      price: numberSetter
    };
  }
}
