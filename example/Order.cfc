component {

  // return, and possibly initialize order contracts
  private struct function getContracts(){
    if(!structKeyExists(variables, "contracts")){
      contracts = new OrderContracts(); // write contracts to the cfc's variable scope
    }
    return contracts;
  }

  // get an order.
  public struct function getOrder(){
    var contracts = getContracts();
    var order = contracts.create(contracts.orderContract);

    // set basic properties
    contracts.setProperty(order, "id", createUUID()); // string
    contracts.setProperty(order, "accepted_cards", ["visa", "mastercard", "discover"]); // array
    contracts.setProperty(order, "has_payment", false); // boolean (will convert to `1` or `0`)
    contracts.setProperty(order, "total", 27.34); // number
    contracts.setProperty(order, "data", { // struct setting (not typically recommended)
      account_standing: "good"
    });

    // set nested contracts
    setBillingAddress(contracts.getProperty(order, "billing_address"));
    setShippingAddress(contracts.getProperty(order, "delivery_address"));

    // set a hashset
    setDeliveryOptions(contracts.getProperty(order, "delivery_options"));

    return contracts.getObject(order);
  }

  // set the billing address
  private void function setBillingAddress(required any addressContract){
    var contracts = getContracts();
    contracts.setProperty(arguments.addressContract, "address_1", "123 Test st");
    contracts.setProperty(arguments.addressContract, "address_2", "Apartment B-27");
    contracts.setProperty(arguments.addressContract, "city", "High Point");
    contracts.setProperty(arguments.addressContract, "state", "NC");
    contracts.setProperty(arguments.addressContract, "post_code", "27265");
  }

  // set the shipping address
  private void function setShippingAddress(required any addressContract){
    var contracts = getContracts();
    contracts.setProperty(arguments.addressContract, "address_1", "2000 Westmire Pt.");
    contracts.setProperty(arguments.addressContract, "city", "Jamestown");
    contracts.setProperty(arguments.addressContract, "state", "NC");
    contracts.setProperty(arguments.addressContract, "post_code", "27262");
    contracts.setProperty(arguments.addressContract, "cuntry", "USA");
  }

  // set some delivery options
  private void function setDeliveryOptions(required any deliveryOptionsContract){
    var contracts = getContracts();
    var option = {};
    for(var i = 1; i <= 3; i++){
      option = contracts.create(contracts.deliveryOptionContract);
      contracts.setProperty(option, "id", i);
      contracts.setProperty(option, "name", "UPS");
      contracts.setProperty(option, "price", i * 2.25);
      contracts.addHash(arguments.deliveryOptionsContract, option);
    }
  }
}
