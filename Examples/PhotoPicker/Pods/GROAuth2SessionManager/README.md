# GROAuth2SessionManager

GROAuth2SessionManager is an extension for [AFNetworking](http://github.com/AFNetworking/AFNetworking/) that greatly simplifies the process of authenticating against an [OAuth 2](http://oauth.net/2/) provider. It is based in the [AFOAuth2Client](https://github.com/AFNetworking/AFOAuth2Client), but with some changes to support AFNetworking 2.

## Example Usage

``` objective-c
NSURL *url = [NSURL URLWithString:@"http://example.com/"];
GROAuth2SessionManager *sessionManager = [GROAuth2SessionManager managerWithBaseURL:url clientID:kClientID secret:kClientSecret];

[sessionManager authenticateUsingOAuthWithPath:@"/oauth/token"
                                   username:@"username"
                                   password:@"password"
                                      scope:@"email"
                                    success:^(AFOAuthCredential *credential) {
                                        NSLog(@"I have a token! %@", credential.accessToken);
                                        [AFOAuthCredential storeCredential:credential withIdentifier:sessionManager.serviceProviderIdentifier];
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"Error: %@", error);
                                    }];
```

## Documentation

Documentation for all releases of GROAuth2SessionManager, including the latest, are [available on CocoaDocs](http://cocoadocs.org/docsets/GROAuth2SessionManager/).

## Contact

Gabriel Rinaldi

- http://github.com/gabrielrinaldi
- http://twitter.com/gabriel_rinaldi
- gabriel@gabrielrinaldi.me

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

GROAuth2SessionManager is available under the MIT license. See the LICENSE file for more info.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/gabrielrinaldi/groauth2sessionmanager/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

