# Enforced Coldfusion Object Handling

`EnforcedCFOO` allows coldfusion developers to create enforced contracts, therefore ensuring that data is reliable-- structure keys always exist with consistent value types. This is a little different from classic contracts, which use a class. Instead, `objects` are defined using `functions`.

This component aims to solve 3 problems: Reliability of objects, and reliability of the data type for each key, and general speed for building and maintaining large objects.

## Quick Start
Here is a bare bones example to get you started.

```cfc
// 1. `extend` `EnforcedCFOO` into a component.
// MyContracts.cfc
component extends="EnforcedCFOO" {

  // 2. create a constraint
  public struct function myFirstConstraint() {
    return {
      id: stringSetter // 3. add stuff to your constraints
    };
  }
}

// Test.cfc
component {

  // 4. get your constraint for use wherever you need it.
  public struct function getThisCoolThing() {
    var contractHandler = new MyContracts();

    // first, create a contract from one of your constraints
    var simpleContract = contractHandler.create(contractHandler.myFirstConstraint);

    // then, set it to whatever value you want
    contractHandler.setProperty(simpleContract, "id", "my-id");

    // now build out the contract
    WriteDump(contractHandler.getData(simpleContract));

    // now convert the contract to a structure for use wherever
    return (contractHandler.getData(simpleContract));
  }
}
```

## Slow Start
Let's say we have the following scenario, with a data structure defining a simple order:

```cfc
var order = {
  billing_address: {
    address_1: "400 Test ave",
    city: "High Point",
    state: "NC",
    zip: "27265"
  },
  delivery_address: {
    address_1: "3923 Freeman Rd.",
    address_2: "Apt G-12",
    city: "Greensboro",
    state: "NC",
    zip: "27410"
  },
  is_verified = ""
};
```

In the above example, we already have some consistency issues with the objects that make up an address. `billing_address` does not contain an `address_2` field, while `delivery_address` does. We also have a potential reliability of data types issue, as `is_verified` would appear semantically to be a `boolean`, but is an empty string. Using `EnforcedCFOO`, we can solve both of these problems:

```cfc
// OrderContracts.cfc
component extends="EnforcedCFOO" {

  public struct function orderConstraint() {
    return {
      delivery_address: addressConstraint,
      billing_address: addressConstraint,
      is_verified: booleanSetter
    };
  }

  public struct function addressConstraint() {
    return {
      address_1: stringSetter,
      address_2: stringSetter,
      city: stringSetter,
      state: stringSetter,
      post_code: stringSetter
    };
  }
}
```
Now, we can create an `Order.cfc` to consume our objects:
```
// Order.cfc
component {

  public struct function getOrder() {
    var contractHandler = new OrderContracts();
    var order = contractHandler.create(contractHandler.orderConstraint); // Create the order contract
    return contractHandler.getData(order); // convert the order to a useable structure
  }
}
```
Now, when we output `getOrder()`, we see the following structure:
```cfc
// output of `getOrder()`
{
  delivery_address: {
    address_1: "",
    address_2: "",
    city: "",
    state: "",
    post_code: ""
  },
  billing_address: {
    address_1: "",
    address_2: "",
    city: "",
    state: "",
    post_code: ""
  },
  is_verified: 0
}
```
Let's say your user has an address book of saved addresses to ship to, as well. You could add a [`hashset`](#hashsets) of the `addressConstraint` to your object now and continue to have the same consistent data across all locations where address is used:
```cfc
public struct function orderConstraint() {
  return {
    delivery_address: addressConstraint,
    billing_address: addressConstraint,
    is_verified: booleanSetter,
    address_book: hashset(addressConstraint) // add in address_book hashset
  };
}
```
If you [added a couple of hashes](#addhashhashset-value) to the `hashset`, your output would now look something like this:
```cfc
// output of `getOrder()`
{
  delivery_address: {
    address_1: "",
    address_2: "",
    city: "",
    state: "",
    post_code: ""
  },
  billing_address: {
    address_1: "",
    address_2: "",
    city: "",
    state: "",
    post_code: ""
  },
  is_verified: 0,
  address_book: [
    {
      address_1: "",
      address_2: "",
      city: "",
      state: "",
      post_code: ""
    },
    {
      address_1: "",
      address_2: "",
      city: "",
      state: "",
      post_code: ""
    }
  ]
}
```

Now, let's say your brand expands into another country, so your addresses now have to be clearer. By adding `country` once to your `addressConstraint`, you effectively add the `country` field to all places that use that constraint:
```cfc
public struct function addressConstraint() {
  return {
    address_1: stringSetter,
    address_2: stringSetter,
    city: stringSetter,
    state: stringSetter,
    post_code: stringSetter,
    country: stringSetter // add in "country"
  };
}
```
The Result:

```cfc
// output of `getOrder()`
{
  delivery_address: {
    address_1: "",
    address_2: "",
    city: "",
    state: "",
    post_code: "",
    country: ""
  },
  billing_address: {
    address_1: "",
    address_2: "",
    city: "",
    state: "",
    post_code: "",
    country: ""
  },
  is_verified: 0,
  address_book: [
    {
      address_1: "",
      address_2: "",
      city: "",
      state: "",
      post_code: "",
      country: ""
    },
    {
      address_1: "",
      address_2: "",
      city: "",
      state: "",
      post_code: "",
      country: ""
    }
  ]
}
```

So, that is super cool, but a bunch defined data structures with no data doesn't help much! We need to be able to set data into the object. Setting properties can be accomplished using [`contractHandler.setProperty(specificContract, ..)`](#setpropertycontract-name-value), or when working with hashes, using [`addHash`](#addhashhashset-value).

```cfc
contractHandler.setProperty(contractHandler.addressContract, "address_1", "300 Test St.");
```
results in the output:
```cfc
{
  address_1: "300 Test St.",
  address_2: "",
  city: "",
  state: "",
  post_code: "",
  country: ""
}
```

Trying to set a property that doesn't exist fails silently:
```cfc
contractHandler.setProperty(contractHandler.addressContract, "kitties", "Meow Meow");
```
results in the unscathed output:
```cfc
{
  address_1: "",
  address_2: "",
  city: "",
  state: "",
  post_code: "",
  country: ""
}
```

Now that we know how to create and set a contract, how do we get the contract in a useable form? Use [`getData`](#getdatacontract) to convert the contract to a structure.
```cfc
var order = contractHandler.getData(contractHandler.orderContract);
WriteDump(order); // see the struct to the order
```

All of this is great, but why not just use a traditional OO approach, using components to define objects? Well, you could! I recently worked on a project with a *very* large object structure - about 30 objects, some reused to make a final data structure that used about 45 objects. I did some tick count testing on creating, setting and building the objects out, and it was taking about *650ms* on a good run (not using DI)-- not awesome. I rewrote the entire thing using `EnforcedCFOO`, and ticks for the same functionality were coming in at about *35ms*, about *95%* performance gain.

## Example
This example uses every type of `setter`, as well as an example of adding `hashsets` and setting properties. [Check out the fully functional standalone example from the code below.](/example/)


#### `OrderContracts.cfc`
The `OrderContracts.cfc` is where we `extend` `EnforcedCFOO` and create all of our contracts. No logic exists in this component.

```cfc
// OrderContracts.cfc
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
```


#### `Order.cfc`
All of the logic for creating and adding data to our contracts exists in a second `component`, named `Order.cfc`.

```cfc
// Order.cfc
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
```
----------------------------------------------------------
## Documentation
`EnforcedCFOO` is intended to be extended into a `cfc` whose only purpose is to contain a set of `constraints`, any of which can be turned into a `contract` by passing it in to `create()`. Each `constraint` is a simple function that describes a single object at a single depth (name/value pairs). Constraint `names` can be anything the developer would like, however the `values` must be either a `setter`, another `constraint` defined by the developer, or a `hashset`.

### Setters
A `setter` simply means that there are no more contracts to check against for a given value; the key should contain a "simple" value, and not another contract. The following setters are available:
* `stringSetter`
* `arraySetter`
* `booleanSetter`
* `structSetter`
* `numberSetter`

### HashSets
A HashSet is an array of objects with a defined contract to check against. For example, if I need to have a list of delivery options, I may have an array of `deliveryOptionConstraints` that contains the deliver by date, the cost, and an id. Setting this into a HashSet allows us to check against a predefined hash and ensure the data is reliable. HashSets have their own functions to work with them:

#### `hashset(constraint)`
creates a `hashset` with the passed in constraint to check against. This is what should be used in constraint creation. For example, a constraint that wants to use a hashset should read:

```cfc
public struct function orderConstraint() {
  return {
    id: stringSetter,
    delivery_options: hashset(deliveryOptionConstraint)
  };
}

```

#### `addHash(hashset, value)`
This allows the developer to add a new contract to a hashset.

```cfc
var option = contractHandler.create(deliveryOptionConstraint);
contractHandler.setProperty(option, "id", i);
contractHandler.setProperty(option, "name", "UPS");
contractHandler.setProperty(option, "price", i * 2.25);
contractHandler.addHash(contractHandler.deliveryOptionsContract, option);
```

#### `sizeHash(hashset)`
Get the current size (or length) of a hashset.
```cfc
contractHandler.sizeHash(deliveryOptionsContract);
```

#### `clearHash(hashset)`
Reset a hashset back to containing nothing.
```cfc
contractHandler.clearHash(deliveryOptionsContract);
```

#### `getHash(hashset)`
Get the full contents of a hashset back.
```cfc
contractHandler.getHash(deliveryOptionsContract);
```

### Accessors
Now that our contracts are defined, we need to be able to get, set, and create them at will.

### `create(constraint)`
This method allows the developer to create a new contract for working in the code with. This method expects a `constraint` function to be passed in to it.

```cfc
var order = contractHandler.create(contractHandler.orderConstraint);
```

### `setProperty(contract, name, value)`
This method allows the developer to set a specific property in a given contract.

```cfc
contractHandler.setProperty(order, "total", 27.34);
```

### `getProperty(contract, name)`
This method allows the developer to get a specific property from a given contract.

```cfc
contractHandler.getProperty(order, "total");
```

### `getData(contract)`
This method converts the entire contract to a workable coldfusion structure. Typically this will be called at the end of all code manipulation for sending the enforced contracts off to the view or wherever it is needed.

```cfc
contractHandler.getData(order);
```
