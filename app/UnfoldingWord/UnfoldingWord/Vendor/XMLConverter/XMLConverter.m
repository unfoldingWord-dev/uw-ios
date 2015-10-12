/**
 * @class      XMLConverter XMLConverter.m "XMLConverter.m"
 * @brief      XMLConverter
 * @details    XMLConverter.m in XMLConverter
 * @date       10/8/13
 * @copyright  Copyright (c) 2013 Ruslan Soldatenko. All rights reserved.
 */

#import "XMLConverter.h"

#define TEXT_NODE_KEY           @"#text"
#define ATTRIBUTE_PREFIX        @"-"
#define AXIS_PARENT            _axisAncestorOrSelf[_currentLevel - 1]
#define AXIS_PRECEDING_SIBLING _axisAncestorOrSelf[_currentLevel - 1][elementName]
#define AXIS_SELF              _axisAncestorOrSelf[_currentLevel]

@interface XMLConverter () <NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableArray *axisAncestorOrSelf;
@property (strong, nonatomic) NSMutableString *selfText;
@property (strong, nonatomic) NSMutableDictionary *root;
@property (assign, nonatomic) NSError *error;
@property (assign, nonatomic) NSInteger currentLevel;

@end

@implementation XMLConverter

#pragma mark - Main Public Methods

+ (void)convertXMLData:(NSData *)data completion:(OutputBlock)completion
{
  ///Wrapper for -initWithData: method of NSXMLParser
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [[XMLConverter new] parser:parser completion:completion];
  });
}

+ (void)convertXMLURL:(NSURL *)url completion:(OutputBlock)completion
{
  ///Wrapper for -initWithContentsOfURL: method of NSXMLParser
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [[XMLConverter new] parser:parser completion:completion];
  });
}

+ (void)convertXMLStream:(NSInputStream *)stream completion:(OutputBlock)completion
{
  ///Wrapper for -initWithStream: method of NSXMLParser
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithStream:stream];
    [[XMLConverter new] parser:parser completion:completion];
  });
}

#pragma mark - Additional Public Methods

+ (void)convertXMLString:(NSString *)string completion:(OutputBlock)completion
{
  //Convert input string to NSData.
  NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
  //Use class method for NSData.
  [self convertXMLData:data completion:completion];
}

+ (void)convertXMLFile:(NSString *)filePath completion:(OutputBlock)completion
{
  //Convert input file to NSData
  NSData* data = [NSData dataWithContentsOfFile:filePath];
  //Use class method for NSData.
  [self convertXMLData:data completion:completion];
}

#pragma mark - Internal methods

- (void)parser:(NSXMLParser *)parser completion:(OutputBlock)completion
{
  ///Completion of the parser to work and run the parser.
  [parser setDelegate: self];
  //Start parsing
  BOOL success = [parser parse];
  //execute output block with results of parsing as synchronous
  dispatch_sync(dispatch_get_main_queue(), ^{
    completion(success, _root, _error);
  });
}

- (void)dealloc
{
  ///Clear out all objects
  [_axisAncestorOrSelf removeAllObjects];
  _axisAncestorOrSelf = nil;
  _selfText = nil;
  _root = nil;
}

#pragma mark - NSXMLParserDelegate Handling XML

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
  ///Initialize internal objects and values
  //Set counter for current level to root element level.
  _currentLevel = 0;
  //Create storage for parsing elements.
  _axisAncestorOrSelf = [NSMutableArray new];
  //Create object for result of parsing - the root object
  _root = [NSMutableDictionary new];
  //Put in the array as first the root object.
  [_axisAncestorOrSelf addObject:_root];
  //Create object for storing current element text value.
  _selfText = [NSMutableString new];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
  ///Clear unused object
  [_axisAncestorOrSelf removeLastObject];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  ///Start processing of the current element
  _currentLevel++;
  if ([_axisAncestorOrSelf count] == _currentLevel)
  {
    //Add dictionary for started element if it not exist.
    [_axisAncestorOrSelf addObject:[NSMutableDictionary new]];
    //Processing a text value (if it exist) of the previous (parent) element.
    if ([_selfText length] > 0)
    {
      [AXIS_PARENT setObject:_selfText forKey:TEXT_NODE_KEY];
      _selfText = [NSMutableString new];
    }
  }
  //Add attribute values (if it exist) to current element.
  if ([attributeDict count] != 0)
  {
    for (id key in [attributeDict allKeys])
    {
      NSString *attributeKey = [NSString stringWithFormat:@"%@%@", ATTRIBUTE_PREFIX, key];
      [AXIS_SELF setObject:attributeDict[key] forKey:attributeKey];
    }
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  ///Processing the text value of the current element
  NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *text = [string stringByTrimmingCharactersInSet: characterSet];
  [_selfText appendString:text];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  ///Completion processing of the current element
  if ([AXIS_SELF count] == 0)
  {
    if (AXIS_PARENT[elementName])
    {
      if ([AXIS_PARENT[elementName] isKindOfClass:[NSMutableArray class]])
      {
        //If exist collection of preceding-sibling elements - add current element to collection.
        [AXIS_PARENT[elementName] addObject:_selfText];
      }
      else
      {
        /*
        If exist only one preceding-sibling element - create collection
        and add both (preceding-sibling and current) elements to collection.
        */
        NSMutableArray *elementsArray = [NSMutableArray new];
        [elementsArray addObjectsFromArray:@[AXIS_PRECEDING_SIBLING, _selfText]];
        [AXIS_PARENT setObject:elementsArray forKey:elementName];
      }
    }
    else
    {
      //If exist only text value of element - set it as element value.
      [AXIS_PARENT setObject:_selfText forKey:elementName];
    }
    _selfText = [NSMutableString new];
  }
  else
  {
    if ([_selfText length] > 0)
    {
      //If exist text value of element and child elements - set it as child element value.
      [AXIS_SELF setObject:_selfText forKey:TEXT_NODE_KEY];
      _selfText = [NSMutableString new];
    }
    if (AXIS_PRECEDING_SIBLING)
    {
      if ([AXIS_PRECEDING_SIBLING isKindOfClass:[NSMutableArray class]])
      {
        //If exist collection of preceding-sibling elements - add current element to collection.
        [AXIS_PRECEDING_SIBLING addObject:AXIS_SELF];
      }
      else if ([AXIS_PRECEDING_SIBLING isKindOfClass:[NSMutableDictionary class]])
      {
        /*
         If exist only one preceding-sibling element - create collection
         and add both (preceding-sibling and current) elements to collection.
         */
        NSMutableArray *elementsArray = [NSMutableArray new];
        [elementsArray addObjectsFromArray:@[AXIS_PRECEDING_SIBLING, AXIS_SELF]];
        [AXIS_PARENT setObject:elementsArray forKey:elementName];
      }
    }
    else
    {
      //If preceding-sibling elements not exist - add current element as child element.
      [AXIS_PARENT setObject:AXIS_SELF forKey:elementName];
    }
    //Remove current element from storage for parsing elements.
    [_axisAncestorOrSelf removeObject:AXIS_SELF];
  }
  _currentLevel--;
}

#pragma mark - NSXMLParserDelegate Handling XML Errors

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
  ///Handle parse error
  //Output in the console error.
  NSLog(@"Line:%i Column:%i - Parse Error Occurred: %@", [parser lineNumber], [parser columnNumber], [parseError description]);
  //Set error prorerty pointer to parse error.
  _error = parseError;
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
  ///Handle validation error
  //Output in the console error.
  NSLog(@"Line:%i Column:%i - Validation Error Occurred: %@", [parser lineNumber], [parser columnNumber], [validationError description]);
  //Set error prorerty pointer to validation error.
  _error = validationError;
}

@end
