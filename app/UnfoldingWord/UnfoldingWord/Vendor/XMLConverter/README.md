#XMLConverter

Simple converter XML to JSON-like style NSDictionary, based on NSXMLParser and written on Objective-C.

##Usage

1. See examples:
  * add files to your project (at least XMLConverter.h and XMLConverter.m, other files need only for example execution).
  * add `#import "XMLConverterExample.h"` to class, where you will want launch XMLConverter exampes.
  * add `[XMLConverterExample example];` for launch examples.
2. Use XMLConverter:
  * add at least `XMLConverter.h` and `XMLConverter.m` files to your project.
  * add `#import "XMLConverter.h"` to class, where you will want to use XMLConverter.
  * add class method call like this:

```objc
  NSURL *url = ...;
  [XMLConverter convertXMLURL:url completion:^(BOOL success, NSDictionary *dictionary, NSError *error) {
    NSLog(@"%@", success ? dictionary : error);
  }]
```
XML data like this:
  
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 Sample text is taken from the http://stackoverflow.com/questions/15498989/xml-into-json-conversion-in-ios 
 -->
<commands>
  <command id="0" name="GetAPPsProducts">
    <command_parameters>
      <command_parameter id="0" name="APPs_Code">ATAiOS</command_parameter>
    </command_parameters>
    <command_result>
      <apps_products>
        <apps_products id="1">
          <apps_code>ATAiOS</apps_code>
          <apps_product_id>2</apps_product_id>
          <brand_id>2</brand_id>
          <brand_desc>Generic</brand_desc>
          <brand_product_id>2</brand_product_id>
          <product_id>001-7</product_id>
          <descrizione>MyTravelApp</descrizione>
        </apps_products>
      </apps_products>
    </command_result>
  </command>
</commands>
```

will be converted to `NSDictionatry` like this:

```
{
    commands =     {
        command =         {
            "-id" = 0;
            "-name" = GetAPPsProducts;
            "command_parameters" =             {
                "command_parameter" =                 {
                    "#text" = ATAiOS;
                    "-id" = 0;
                    "-name" = "APPs_Code";
                };
            };
            "command_result" =             {
                "apps_products" =                 {
                    "apps_products" =                     {
                        "-id" = 1;
                        "apps_code" = ATAiOS;
                        "apps_product_id" = 2;
                        "brand_desc" = Generic;
                        "brand_id" = 2;
                        "brand_product_id" = 2;
                        descrizione = MyTravelApp;
                        "product_id" = "001-7";
                    };
                };
            };
        };
    };
}
```



## Requirements

Xcode 4.4 and above because project use “modern” Objective-C syntax and "auto-synthesized property" feature.

## License
The MIT License (MIT)

Copyright (c) 2013 Ruslan Soldatenko

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
