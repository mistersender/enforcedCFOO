component {

  // return, and possibly initialize order contracts
  private struct function getContractHandler(){
    if(!structKeyExists(variables, "contracts")){
      contractHandler = new OrderContracts(); // write contractHandler to the cfc's variable scope
    }
    return contractHandler;
  }

  // get an order.
  public struct function getOrder(){
    var contractHandler = getContractHandler();
    var order = contractHandler.create(contractHandler.orderConstraint);

    // set basic properties
    contractHandler.setProperty(order, "id", createUUID()); // string
    contractHandler.setProperty(order, "accepted_cards", ["visa", "mastercard", "discover"]); // array
    contractHandler.setProperty(order, "has_payment", false); // boolean (will convert to `1` or `0`)
    contractHandler.setProperty(order, "total", 27.34); // number
    contractHandler.setProperty(order, "data", { // struct setting (not typically recommended)
      account_standing: "good"
    });

    // set nested constraints
    setBillingAddress(contractHandler.getProperty(order, "billing_address"));
    setShippingAddress(contractHandler.getProperty(order, "delivery_address"));

    // set a hashset
    // setDeliveryOptions(contractHandler.getProperty(order, "delivery_options"));

    return contractHandler.getData(order);
  }

  // set the billing address
  private void function setBillingAddress(required any addressConstraint){
    var contractHandler = getContractHandler();
    contractHandler.setProperty(arguments.addressConstraint, "address_1", "123 Test st");
    contractHandler.setProperty(arguments.addressConstraint, "address_2", "Apartment B-27");
    contractHandler.setProperty(arguments.addressConstraint, "city", "High Point");
    contractHandler.setProperty(arguments.addressConstraint, "state", "NC");
    contractHandler.setProperty(arguments.addressConstraint, "post_code", "27265");
  }

  // set the shipping address
  private void function setShippingAddress(required any addressConstraint){
    var contractHandler = getContractHandler();
    contractHandler.setProperty(arguments.addressConstraint, "address_1", "2000 Westmire Pt.");
    contractHandler.setProperty(arguments.addressConstraint, "city", "Jamestown");
    contractHandler.setProperty(arguments.addressConstraint, "state", "NC");
    contractHandler.setProperty(arguments.addressConstraint, "post_code", "27262");
    contractHandler.setProperty(arguments.addressConstraint, "cuntry", "USA");
  }

  // set some delivery options
  private void function setDeliveryOptions(required any deliveryOptionsConstraint){
    var contractHandler = getContractHandler();
    var option = {};
    for(var i = 1; i <= 3; i++){
      option = contractHandler.create(contractHandler.deliveryOptionConstraint);
      contractHandler.setProperty(option, "id", i);
      contractHandler.setProperty(option, "name", "UPS");
      contractHandler.setProperty(option, "price", i * 2.25);
      contractHandler.addHash(arguments.deliveryOptionsConstraint, option);
    }
  }
}
