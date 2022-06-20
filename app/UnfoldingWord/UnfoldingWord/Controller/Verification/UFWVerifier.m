//
//  UFWVerifier.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/15/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWVerifier.h"
#import "ecdsa.h"
#import "pem.h"
#include <CommonCrypto/CommonDigest.h>

@implementation UFWVerifier

+ (BOOL)verifyFile:(NSString *)filePath withSignature:(NSString *)signature
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSData *fileHash = [self hashFromData:data];
    
    EC_KEY *key = [self ecKeyFromPEMFile];
    ECDSA_SIG *sig = [self ecSigFromString:signature];
    
    if ( ! key || ! sig) {
        NSAssert2(NO, @"Either the key %@ or the signature %@ could not be created!", key, sig);
        return NO;
    }
    
    int verify =  ECDSA_do_verify(fileHash.bytes, (int)fileHash.length, sig, key);
    return (verify != 0) ? YES : NO;
}

+ (EC_KEY *)ecKeyFromPEMFile
{
    // Create a key from the PEM file. ** MUST be PEM file **
    NSString *publicKeyPath =[[NSBundle mainBundle] pathForResource:@"uW_vk_2" ofType:@"pem"];
    
    FILE *f = fopen([publicKeyPath cStringUsingEncoding:1],"r");
    
    EVP_PKEY *evpKey = PEM_read_PUBKEY(f, NULL, NULL, NULL);
    
    EC_KEY *key = NULL;
    if ( evpKey ) {
        key = EVP_PKEY_get1_EC_KEY(evpKey);
    }
    return key;
}

+ (ECDSA_SIG *) ecSigFromString:(NSString *)string
{
    NSData *sigData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    ECDSA_SIG *sig = NULL;
    const unsigned char *pp = sigData.bytes;
    sig = d2i_ECDSA_SIG(&sig, &pp, sigData.length);
    return sig;
}

+ (NSData *)hashFromData:(NSData *)data
{
    unsigned char digest[CC_SHA384_DIGEST_LENGTH];
    if (CC_SHA384(data.bytes, (CC_LONG)data.length, digest)) {
        NSData *hashData = [NSData dataWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
        return hashData;
    }
    else {
        NSLog(@"Failed to create hash from data: %@", data);
        return nil;
    }
}

@end
