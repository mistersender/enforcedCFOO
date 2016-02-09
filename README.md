# Enforced Coldfusion Object Handling

`EnforcedCFOO` allows coldfusion developers to create enforced contracts, therefore ensuring that data is reliable-- structure keys always exist with consistent value types. This is a little different from classic contracts, which use a class. Instead, objects are defined using functions.

## Quick Start

1. `extend` `EnforcedCFOO` into a component.
2. create a contract
3. add stuff to your contract
4. get your contract for use wherever you need it.

```cfc
component extends="EnforcedCFOO" {
  public struct function myFirstContract() {
    return {
      id: stringSetter
    };
  }

  public struct function getContract() {
    // first, create the contract
    var simpleContract = create(myFirstContract);

    // then, set it to whatever value you want
    setProperty(simpleContract, "id", "my-id");

    // now build out the contract
    WriteDump(getObject(simpleContract));

    return getObject(simpleContract);
  }
}
```

## Details
`EnforcedCFOO` is intended to be extended into a `cfc` whose only purpose is to contain a set of `contracts`. Each `contract` is a simple function that describes a single object at a single depth (name/value pairs). Contracts names can be anything the developer would like, however the values must be either a `setter`, another `contract` defined by the developer, or a `hashset`. For the purposes of this readme, we will use the example of an "order" as defined in the data. Orders have a delivery & billing address, delivery options, order total information, and some other data associated with them.

### Setters
A `setter` simply means that there are no more contracts to check against for a given value; the key should contain a "simple" value, and not another contract. The following setters are available:
* `stringSetter`
* `arraySetter`
* `booleanSetter`
* `structSetter`
* `numberSetter`

### HashSets
A HashSet is an array of objects with a defined contract to check against. For example, if I need to have a list of delivery options, I may have an array of `deliveryOptionContracts` that contains the deliver by date, the cost, and an id. Setting this into a HashSet allows us to check against a predefined hash and ensure the data is reliable. HashSets have their own functions to work with them:

#### `hashset(contract)`
creates a `hashset` with the passed in contract to check against. This is what should be used in contract creation. For example, a contract that wants to use a hashset should read:

```cfc
public struct function orderContract() {
  return {
    id: stringSetter,
    delivery_options: hashset(deliveryOptionContract)
  };
}

```

#### `addHash(hashset, value)`
This allows the developer to add a new contract to a hashset.

```cfc
var option = create(deliveryOptionContract);
setProperty(option, "id", i);
setProperty(option, "name", "UPS");
setProperty(option, "price", i * 2.25);
addHash(deliveryOptionsContract, option);
```

#### `sizeHash(hashset)`
Get the current size (or length) of a hashset.
```cfc
sizeHash(deliveryOptionsContract);
```

#### `clearHash(hashset)`
Reset a hashset back to containing nothing.
```cfc
clearHash(deliveryOptionsContract);
```

#### `getHash(hashset)`
Get the full contents of a hashset back.
```cfc
getHash(deliveryOptionsContract);
```

### Contracts
Here is a sample contract that uses each type of `setter`, a `hashset` and calls in to other `contracts` for additional functionality. We will use an example of an order:

```cfc

public struct function orderContract() {
  return {
    id: stringSetter,
    delivery_address: addressContract, // another contract we define
    billing_address: addressContract, // another contract we define (reuseable)
    delivery_options: hashset(deliveryOptionContract), // a hashset of another contract we define
    accepted_cards: arraySetter,
    has_payment: booleanSetter,
    data: structSetter,
    phone: stringSetter,
    total: numberSetter
  };
}

```

### Accessors
Now that our contracts are defined, we need to be able to get, set, and create them at will.

### `create(contract)`
This method allows the developer to create a new contract for working in the code with.

```cfc
var order = create(orderContract);
```

### `setProperty(contract, name, value)`
This method allows the developer to set a specific property in a given contract.

```cfc
setProperty(order, "total", 27.34);
```

### `getProperty(contract, name)`
This method allows the developer to get a specific property from a given contract.

```cfc
getProperty(order, "total");
```

### `getObject(contract)`
This method converts the entire contract to a workable coldfusion structure. Typically this will be called at the end of all code manipulation for sending the enforced contracts off to the view or wherever it is needed.

```cfc
getObject(order);
```
