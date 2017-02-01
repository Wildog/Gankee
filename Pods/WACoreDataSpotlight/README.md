[![Version](https://img.shields.io/cocoapods/v/WACoreDataSpotlight.svg?style=flat)](http://cocoapods.org/pods/WACoreDataSpotlight)
[![License](https://img.shields.io/cocoapods/l/WACoreDataSpotlight.svg?style=flat)](http://cocoapods.org/pods/WACoreDataSpotlight)
[![Platform](https://img.shields.io/cocoapods/p/WACoreDataSpotlight.svg?style=flat)](http://cocoapods.org/pods/WACoreDataSpotlight)
![](https://img.shields.io/badge/Require-Xcode7-lightgrey.svg?style=flat-square)
![](https://img.shields.io/badge/Supported-iOS7+-yellow.svg?style=flat-square)

**Developed and Maintained by [Ipodishima](https://github.com/ipodishima) Founder & CTO at [Wasappli Inc](http://wasapp.li).** (If you need to develop an app, [get in touch](mailto:contact@wasapp.li) with our team!)

# Purpose

With iOS 9 comes great new features. One of them is [CoreSpotlight](https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/AppSearch/index.html#//apple_ref/doc/uid/TP40016308-CH4-SW1) which purpose is to give you access to the app search on iOS itself. A user can now search for it's hotel booking straight from the search on iOS and get back to the app.

Because several developpers are using CoreData, I thought it would have been a great idea to help indexing using both CoreSpotlight and CoreData apis.

WACoreDataSpotlight, after a quick configuration, automatically index you core data database. Yeah, you heard it. Automatically.

It will:
- create the index,
- update the entry on the index,
- delete the entry from the index.

Automatically (after a **save**)

#Compatibility

- Xcode 7 or more
- iOS 7 or more (on iOS < 9, the indexer will return nil)

# Install and use
## Test it!

You can use

`pod try WACoreDataSpotlight`

Then, when the app is launched, go back to the springboard, search for `Marian Paul` for exemple, of for `employee`

## Installation
### CocoaPods
Use CocoaPods, this is the easiest way to install the indexer

`pod 'WACoreDataSpotlight'`

## Setup the indexer

### Import
`#import <WACoreDataSpotlight/WACoreDataSpotlight.h>`

### Allocate a new indexer

For allocating the indexer, you need a valid `NSManagedObjectContext` you are using to create / fetch / etc you core data objects. 

``` objc
self.mainIndexer = [[WACDSIndexer alloc] initWithManagedObjectContext:mainContext];
```

### Create some mappings

Then, you need to create some mappings. You can use `WACDSSimpleMapping` if it remains simple, or `WACDSCustomMapping` if you need more access on `CSSearchableItemAttributeSet`.

Let's start with an easy one

```objc
WACDSSimpleMapping *employeeSearchMapping =
[[WACDSSimpleMapping alloc] initWithManagedObjectEntityName:@"Employee"
                                    uniqueIdentifierPattern:@"employee_{#firstName#}_{#lastName#}"
                                               titlePattern:@"{#firstName#} {#lastName#}"
                                  contentDescriptionPattern:@"{#firstName#} {#lastName#} is working as {#jobTitle#} on {#company.name#}"
                                           keywordsPatterns:@[@"employee", @"{#firstName#}", @"{#lastName#}"]
                                       thumbnailDataBuilder:^NSData *(Employee *employee) {
                                            return UIImagePNGRepresentation([UIImage imageNamed:employee.avatarImageName]);
                                       }];
```

First, you pass `Employee` class which is a subclass of `NSManagedObject`.
Then you need to pass a unique identifier pattern. It is used to id your object in an unique way in the index. Best idea is to use an `itemID` property.

Let's stop with the syntax. Assuming `Employee` has a property `firstName` and `lastName` which values are `Marian` and `Paul`, using an identifier as `employee_{#firstName#}_{#lastName#}` will be mapped to `employee_Marian_Paul`.

`{#object property name#}` is THE syntax you need to use for this to work correctly.

The `titlePattern` is mandatory.

Keywords can be hard values (`employee`) or dynamic (`{#firstName#}`).

### Register the mapping

``` objc
[self.mainIndexer registerMapping:employeeSearchMapping];
```

### Use the indexer

```objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    NSManagedObject *object = [self.mainIndexer objectFromUserActivity:userActivity];
    
    // Do something with the object
        
    return YES;
}

```

### Build the app
Build and run the app. Every objects for which you added a mapping on their classe are now automatically added / updated / deleted from the index... ! 

## Custom indexer
You can use custom mapping to create your own attribute set. For example:

```objc
WACDSCustomMapping *companyMapping =
[[WACDSCustomMapping alloc] initWithManagedObjectEntityName:@"Company"
                                    uniqueIdentifierPattern:@"company_{#name#}"
                          searchableItemAttributeSetBuilder:^CSSearchableItemAttributeSet *(Company *company) {
                               CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
                              attributeSet.title                         = company.name;
                              attributeSet.contentDescription            = [NSString stringWithFormat:@"The company has its offices in %@ and its primary activity is %@.\n%ld employees", company.address, company.activity, [company.employees count]];
                              attributeSet.keywords                      = @[@"company", company.name, company.activity];
                         
                              return attributeSet;
                          }];
[self.mainIndexer registerMapping:companyMapping];

```

## Index existing objects

You can index existing objects using `[self.indexer indexExistingObjects:existingObjects];`
Please not that this is up to you to call this only one time in the app's life.

## Update the index
Assuming you have an object to index which requires an image download from the URL. Indexing would give the order to download the image, but at the end you need to refresh the index to pass the image.

```objc
[self.mainIndexer updateIndexingForObject:company];
```

# Do something with the activity and the object from the search
When the user hits the search result, you grab the object using `[self.mainIndexer objectFromUserActivity:userActivity]`.
But then what?

Well, you could use for example (WAAppRouting)[https://github.com/Wasappli/WAAppRouting] to add some url behavior in your app. It would be as easy as doing:

```objc
self.router = [WAAppRouter defaultRouter];
[self.router.registrar
  registerAppRoutePath:@"companies{CompaniesTableViewController}/:companyName{EmployeesTableViewController}/:employeeID{EmployeeFormViewController}!"
  presentingController:nav];
```

And then on `application: continueUserActivity: restorationHandler:`


```objc
NSManagedObject *object = [self.mainIndexer objectFromUserActivity:userActivity];

if ([object isKindOfClass:[Company class]]) {
    [AppLink goTo:@"companies/%@", ((Company *)object).name];
}

if ([object isKindOfClass:[Employee class]]) {
    [AppLink goTo:@"companies/%@/%@", ((Employee *)object).company.name, ((Employee *)object).employeeID];
}
```

# TODOs
- [ ] Handle the batching
- [ ] Handle the security implementation (on extension)

#Contributing : Problems, Suggestions, Pull Requests?

Please open a new Issue [here](https://github.com/Wasappli/WACoreDataSpotlight/issues) if you run into a problem specific to WACoreDataSpotlight.

For new features pull requests are encouraged and greatly appreciated! Please try to maintain consistency with the existing code style. If you're considering taking on significant changes or additions to the project, please ask me before by opening a new issue to have a chance for a merge.

#That's all folks !

- If your are happy don't hesitate to send me a tweet [@ipodishima](http://twitter.com/ipodishima)!
- Distributed under MIT licence.
- Follow Wasappli on [facebook](https://www.facebook.com/wasappli)
