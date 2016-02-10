component {

// Start: Contract handling
//
//  Note: Contract Handling works by holding 2 items: the contract (a constraint), and a "build", which
//  is the actual data that is in the contract. When a developer sets a property into a contract, we use the `contract`
//  to make sure that what the developer is setting is correct, and if so, we add the value to the `build`. Even though
//  the data in the `build` var is right there, *resist using it directly* and instead call `getProperty` or `getObject`.

public struct function create(
  required any theContract // what constraint should we use to create this contract?
){
  // Note: This function should be called whenever a new contract is needed. it sets the contract up and actually builds out
  // the skeleton data with defaults so that we have something reliable to work against, overriding defaults as needed.
  var defaults = {
   'contract' = arguments.theContract,
   'build' = buildContractData(arguments.theContract)
  };
  return defaults;
}

public struct function hashSet(
  required any contract // what constraint should we enforce as a contract with this hash set?
) {
  // Note: This function is based off of the java `hashset`, which is an enforced array of structures, which in our case are contracts.
  // This method should be used to make sure when we have an array of structures, we are setting the correct thing in. It
  // will also add a counter variable for us so that all of our code is consistent.
  // A use case would be if you wanted to have a vendor loop, you need an array of vendor contracts. You would use the
  // hashset to accomplish this and effectively make sure you always had the correct information in the array positions.
  var defaults = {
   'contract' = arguments.contract,
   'build' = {
    'count' = 0,
    'list' = []
   },
   'isSelfValidated' = "true" // this tells the parser that we have already got validated fields, just used the build
  };
  return defaults;
}

public void function addHash(
  required any hash, // the hashset we wish to add to
  required any value // the value we want to add, which should be a contract
){
  // Note: When used with hashsets, will validate and then add a single new contract to a particular hash.
  if(arguments.hash.contract == arguments.value.contract){ // if the contracts match, then trust that we have valid data.
   arguments.hash.build.count++;
   arrayAppend(arguments.hash.build.list, duplicate(arguments.value.build));
  }
}

public numeric function sizeHash(
  required any hash
){
  return arguments.hash.build.count;
}

public void function clearHash(
  required any hash
){
  arguments['hash']['build']['list'] = [];
  arguments['hash']['build']['count'] = 0;
}

public struct function getHash(
  required any hash,
  required numeric iterator
){
  var defaults = {
   'contract' = arguments.hash.contract,
   'build' = arguments.hash.build.list[arguments.iterator]
  };
  return defaults;
}

// recursively build the data structure of a contract
private any function buildContractData(
  required any contract
){
  var obj = {};
  var meta = "";
  var currentContract = arguments.contract(); // the constraint passed in is an unexecuted function. Execute the function here to see what it returns.
  if(isStruct(currentContract)){ // if the executed function returns a structure, then we know we have another constraint to drill down into.
   for(var key in currentContract){ // loop over each key in the constraint (keys should only be 1 level deep) to build the contract out
    meta = getMetaData(currentContract[key]);
    if(isStruct(meta) && structKeyExists(meta, "name")){ //it's a "normal" constraint, so call it
     obj[key] = buildContractData(currentContract[key]); // recursively call this method to build out the entire data structure
    }
    else if(isStruct(currentContract[key]) && structKeyExists(currentContract[key], "build")){ //it's a hashset, so update it
     obj[key] = currentContract[key].build;
    }
   }
  }
  else{ // it's just a plain object. This essentially means that we have drilled down to a `setter` function (like `stringSetter`)
   obj = currentContract; // at this point currentContract now equals actual data (the result of calling `stringSetter` is an empty string, for example) so set it to the obj.
  }
  return obj;
}


// End: Contract handling
// Start: Setter handling

//  Note: Setters are used to enforce that what is being sent in to a constraint as a value is what actually should be there.
//  This keeps our data extremely reliable and relieves the concern of a boolean being an empty string, for example, and also
//  allows us some control over what sort of things are passed back.

// validate & set a string in to a contract
private string function stringSetter(
  required string value = ""
)
  handler=true
{
  // Note: do NOT sanitize this by passing around a chr(02) because it prevents developers from being able to do accurate string compares.
  return arguments.value;
}

// validate & set a struct in to a contract
private struct function structSetter(
  required struct value = {}
)
handler=true
{
  return arguments.value;
}

// validate & set an array in to a contract
private array function arraySetter(
  required array value = []
)
handler=true
{
  return arguments.value;
}

// validate & set a boolean in to a contract
private boolean function booleanSetter(
  required boolean value = 0
)
handler=true
{
  return int(arguments.value); //convert booleans to int for consistency
}

// validate & set a number in to a contract
private numeric function numberSetter(
  required numeric value = 0
)
handler=true
{
  return arguments.value;
}

// End: Setter handling
// Start: Contract Accessors

// set & validate a property into a particular contract
public void function setProperty(
  required any theContract,
  required string key,
  required any value
){
  // Note: this function is meant to be called every time a property needs to be set. It will validate the property
  // and add it in to the particular contract correctly.
  var contract = arguments.theContract.contract(); // call the contract (aka constraint) to get the keys
  var build = arguments.theContract.build; // soft copy of the build
  if(structKeyExists(contract, arguments.key)){ // make sure the key really exists in the contract
   contract = contract[arguments.key]; // set the final contract
   // figure out how to set the value.  If neither of the conditions are met below, it means we don't have a way to validate the value being set and therefore we won't set it.
   if(structKeyExists(getMetaData(contract), "handler")){ // if the key has a handler, use the handler to set the key
    try{
      build[arguments.key] = contract(arguments.value);
    }
    catch(any e){
      throw("incorrectObjectType", "Tried to cast`" & arguments.key & "` incorrectly", e);
    }
   }
   else if(isStruct(contract) && structKeyExists(contract, "isSelfValidated")){ // some things have special handling, such as hashsets, and have already been created & validated. this will handle those.
    build[arguments.key] = arguments.value.build;
   }
  }
  return;
}

// return a property inside of a particular contract
public any function getProperty(
  required any contract,
  required string key
){
  var data = {
   'contract' = "",
   'build' = ""
  };
  if(structKeyExists(arguments.contract.build, key)){
   data = {
    'contract' = arguments.contract.contract()[key],
    'build' = arguments.contract.build[key]
   };
  }
  // see if the contract is a handler, and if it is, return a plain value
  if(structKeyExists(getMetaData(data.contract), "handler")){
   data = data.build;
  }
  else if(structKeyExists(data.contract, "isSelfValidated")){ // sniff for a hashset type, and if it is one, override the contract with what's in the hashset already
   data = data.contract;
   data.build = arguments.contract.build[key]; //make sure to get the built version saved in the contract, not the default!
  }
  return data;
}

// Purpose: return the fully built contract as a plain data structure
public any function getData(
  required any theContract
){
  var build = arguments.theContract.build;
  var contract = arguments.theContract.contract();
  if(structKeyExists(contract, "isSelfValidated")){ // sniff for a hashset type, and if it is one, override the contract with what's in the hashset already
   build = contract.build;
  }
  return build;
}

// End: Contract Accessors
}
