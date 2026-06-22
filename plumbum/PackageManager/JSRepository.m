//
//  JSRepository.m
//  plumbum
//
//

#import "JSRepository.h"

@implementation JSRepository

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = dict[@"name"] ?: @"Unknown Repository";
        _url = dict[@"url"] ?: @"";
        _repoDescription = dict[@"description"] ?: @"";
        
        NSString *dateStr = dict[@"lastUpdated"];
        if (dateStr) {
            _lastUpdated = [NSDate dateWithTimeIntervalSince1970:[dateStr doubleValue]];
        }
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (_name) dict[@"name"] = _name;
    if (_url) dict[@"url"] = _url;
    if (_repoDescription) dict[@"description"] = _repoDescription;
    if (_lastUpdated) dict[@"lastUpdated"] = @([_lastUpdated timeIntervalSince1970]);
    
    return [dict copy];
}

@end

@interface JSRepositoryManager ()
@property (nonatomic, strong) NSMutableArray<JSRepository *> *repositoriesCache;
@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic, strong) NSString *scriptsCachePath;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSDictionary *> *> *scriptsCache;
@end

@implementation JSRepositoryManager

+ (instancetype)sharedManager {
    static JSRepositoryManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _databasePath = [documentsDir stringByAppendingPathComponent:@"js_repositories.plist"];
        _scriptsCachePath = [documentsDir stringByAppendingPathComponent:@"js_cached_scripts.plist"];
        _scriptsCache = [NSMutableDictionary dictionary];
        _repositoriesCache = [NSMutableArray array];
        
        [self loadRepositories];
        if (_repositoriesCache.count == 0) {
            [self addDefaultRepositories];
        }
    }
    return self;
}

- (void)loadRepositories {
    _repositoriesCache = [NSMutableArray array];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:_databasePath]) {
        NSArray *savedRepos = [NSArray arrayWithContentsOfFile:_databasePath];
        for (NSDictionary *dict in savedRepos) {
            JSRepository *repo = [[JSRepository alloc] initWithDictionary:dict];
            [_repositoriesCache addObject:repo];
        }
    }
}

- (void)loadCachedScripts {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:_scriptsCachePath]) {
        NSDictionary *cachedData = [NSDictionary dictionaryWithContentsOfFile:_scriptsCachePath];
        for (NSString *repoURL in cachedData) {
            NSArray *scripts = cachedData[repoURL];
            _scriptsCache[repoURL] = scripts;
        }
    }
}

- (void)saveCachedScripts {
    [_scriptsCache writeToFile:_scriptsCachePath atomically:YES];
}

- (void)saveRepositories {
    NSMutableArray *repoDicts = [NSMutableArray array];
    
    for (JSRepository *repo in _repositoriesCache) {
        [repoDicts addObject:[repo toDictionary]];
    }
    
    [repoDicts writeToFile:_databasePath atomically:YES];
}

- (NSArray<JSRepository *> *)repositories {
    if (_repositoriesCache.count == 0) {
        [self loadRepositories];
    }
    return [_repositoriesCache copy];
}

- (BOOL)addRepository:(JSRepository *)repo error:(NSError **)error {
    if (!repo.url || repo.url.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"JSRepositoryManager" 
                                         code:500 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Repository URL is required"}];
        }
        return NO;
    }
    
    for (JSRepository *existingRepo in _repositoriesCache) {
        if ([existingRepo.url isEqualToString:repo.url]) {
            if (error) {
                *error = [NSError errorWithDomain:@"JSRepositoryManager" 
                                             code:501 
                                         userInfo:@{NSLocalizedDescriptionKey: @"Repository already exists"}];
            }
            return NO;
        }
    }
    
    [_repositoriesCache addObject:repo];
    [self saveRepositories];
    
    NSLog(@"Added JS repository: %@", repo.name);
    return YES;
}

- (BOOL)removeRepository:(JSRepository *)repo error:(NSError **)error {
    if (![_repositoriesCache containsObject:repo]) {
        if (error) {
            *error = [NSError errorWithDomain:@"JSRepositoryManager" 
                                         code:502 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Repository not found"}];
        }
        return NO;
    }
    
    [_repositoriesCache removeObject:repo];
    [self saveRepositories];
    
    NSLog(@"Removed JS repository: %@", repo.name);
    return YES;
}

- (void)refreshRepository:(JSRepository *)repo completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        repo.lastUpdated = [NSDate date];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveRepositories];
            completion(YES, nil);
        });
    });
}

- (void)scriptsFromRepository:(JSRepository *)repo completion:(void (^)(NSArray<NSDictionary *> *scripts, NSError *error))completion {
    if (_scriptsCache.count == 0) {
        [self loadCachedScripts];
    }
    
    NSArray *cachedScripts = _scriptsCache[repo.url];
    if (cachedScripts && cachedScripts.count > 0) {
        completion(cachedScripts, nil);
        return;
    }
    
    NSString *scriptsURL = repo.url;
    NSURL *url = [NSURL URLWithString:scriptsURL];
    
    if (!url) {
        completion(@[], nil);
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *networkError) {
        if (networkError || !data) {
            NSLog(@"Failed to download scripts from %@: %@", scriptsURL, networkError.localizedDescription);
            completion(@[], networkError);
            return;
        }
        
        NSArray *parsedScripts = nil;
        
        // Check if it's a JSON file
        if ([scriptsURL hasSuffix:@".json"]) {
            NSError *jsonError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"Failed to parse JSON from %@: %@", scriptsURL, jsonError.localizedDescription);
                completion(@[], jsonError);
                return;
            }
            parsedScripts = [self parseJSJSON:jsonDict];
        } else {
            // Parse as plain text listing
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            parsedScripts = [self parseScriptsList:content fromRepo:repo];
        }
        
        if (parsedScripts.count > 0) {
            self->_scriptsCache[repo.url] = parsedScripts;
            [self saveCachedScripts];
        }
        
        completion(parsedScripts, nil);
    }];
    
    [task resume];
}

- (void)allScriptsFromRepositories:(void (^)(NSArray<NSDictionary *> *scripts, NSError *error))completion {
    NSMutableArray *allScripts = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    __block NSError *firstError = nil;
    
    for (JSRepository *repo in _repositoriesCache) {
        dispatch_group_enter(group);
        [self scriptsFromRepository:repo completion:^(NSArray<NSDictionary *> *scripts, NSError *error) {
            if (scripts) {
                [allScripts addObjectsFromArray:scripts];
            }
            if (error && !firstError) {
                firstError = error;
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion([allScripts copy], firstError);
    });
}

- (NSArray *)parseJSJSON:(NSDictionary *)jsonDict {
    NSMutableArray *scripts = [NSMutableArray array];
    
    NSArray *repositoryContents = nil;
    
    if ([jsonDict objectForKey:@"RepositoryContents"]) {
        repositoryContents = jsonDict[@"RepositoryContents"];
    } else if ([jsonDict objectForKey:@"Repository"]) {
        NSDictionary *repo = jsonDict[@"Repository"];
        if ([repo isKindOfClass:[NSDictionary class]]) {
            repositoryContents = repo[@"RepositoryContents"];
        }
    } else if ([jsonDict isKindOfClass:[NSArray class]]) {
        repositoryContents = (NSArray *)jsonDict;
    }
    
    if (!repositoryContents || ![repositoryContents isKindOfClass:[NSArray class]]) {
        return [scripts copy];
    }
    
    for (NSDictionary *scriptDict in repositoryContents) {
        @autoreleasepool {
            if (!scriptDict || ![scriptDict isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            NSMutableDictionary *script = [NSMutableDictionary dictionary];
            
            NSString *scriptID = scriptDict[@"ScriptID"] ?: scriptDict[@"id"];
            if (!scriptID) continue;
            
            script[@"id"] = scriptID;
            script[@"name"] = scriptDict[@"Name"] ?: scriptID;
            script[@"description"] = scriptDict[@"Description"] ?: @"";
            script[@"author"] = scriptDict[@"Author"] ?: @"Unknown";
            script[@"version"] = scriptDict[@"Version"] ?: @"1.0";
            script[@"url"] = scriptDict[@"URL"] ?: scriptDict[@"url"] ?: @"";
            script[@"filename"] = scriptDict[@"Filename"] ?: @"";
            
            [scripts addObject:[script copy]];
        }
    }
    
    return [scripts copy];
}

- (NSArray *)parseScriptsList:(NSString *)content fromRepo:(JSRepository *)repo {
    NSMutableArray *scripts = [NSMutableArray array];
    
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmed.length == 0 || [trimmed hasPrefix:@"#"]) {
            continue;
        }
        
        NSDictionary *script = @{
            @"id": trimmed,
            @"name": [trimmed lastPathComponent],
            @"description": @"",
            @"author": @"Unknown",
            @"version": @"1.0",
            @"url": [repo.url stringByAppendingPathComponent:trimmed],
            @"filename": trimmed
        };
        
        [scripts addObject:script];
    }
    
    return [scripts copy];
}

- (void)addDefaultRepositories {
    NSArray *defaultRepos = @[
        @{
            @"name": @"Default JS Scripts",
            @"url": @"https://example.com/js_scripts.json",
            @"description": @"Default JavaScript scripts repository"
        }
    ];
    
    for (NSDictionary *dict in defaultRepos) {
        JSRepository *repo = [[JSRepository alloc] initWithDictionary:dict];
        
        BOOL exists = NO;
        for (JSRepository *existingRepo in _repositoriesCache) {
            if ([existingRepo.url isEqualToString:repo.url]) {
                exists = YES;
                break;
            }
        }
        
        if (!exists) {
            [self addRepository:repo error:nil];
        }
    }
    
    [_scriptsCache removeAllObjects];
    [self saveCachedScripts];
}

@end
