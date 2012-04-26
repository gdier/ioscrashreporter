//
//  YrCrashLogger.m
//
//  Created by Gdier Zhang on 12-4-24.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import "YrCrashLogger.h"
#import <signal.h>
#import <unistd.h>
#import <execinfo.h>
#import "YrCrashLogFile.h"

static int fatal_signals[] = {
    SIGABRT,
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGSEGV,
    SIGTRAP
};

static int n_fatal_signals = (sizeof(fatal_signals) / sizeof(fatal_signals[0]));

static struct {
    BOOL handlerRegistered;
    void *crashCallbackContext;
    stack_t _sigStack;
} sharedHandlerContext = {
    .handlerRegistered = NO,
    .crashCallbackContext = NULL
};

static void sysSignalHandler(int signal, siginfo_t *info, void *uapVoid);
static void uncaughtExceptionHandler(NSException *exception);

@implementation YrCrashLogger

+ (BOOL)registerHandlerForSignal:(int)signal
{
    struct sigaction sa;
    
    memset(&sa, 0, sizeof(sa));
    sa.sa_flags = SA_SIGINFO|SA_ONSTACK;
    sigemptyset(&sa.sa_mask);
    sa.sa_sigaction = &sysSignalHandler;
    
    if (sigaction(signal, &sa, NULL) != 0)
    {
        int err = errno;
        
        NSLog(@"Signal registration for %s failed: %s", strsignal(signal), strerror(err));
        return NO;
    }
    
    return YES;
}

+ (BOOL)registerLogger
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    sharedHandlerContext._sigStack.ss_size = MAX(MINSIGSTKSZ, 64 * 1024);
    sharedHandlerContext._sigStack.ss_sp = malloc(sharedHandlerContext._sigStack.ss_size);
    sharedHandlerContext._sigStack.ss_flags = 0;
    
    if (sigaltstack(&sharedHandlerContext._sigStack, 0) < 0)
    {
        return NO;
    }
    
    for (int i = 0; i < n_fatal_signals; i++) {
        if (![YrCrashLogger registerHandlerForSignal:fatal_signals[i]])
            return NO;
    }
    
    return YES;
}

+ (NSString *)getLogTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *ret = [formatter stringFromDate:[NSDate date]];
    
    [formatter release];
    
    return ret;
}

+ (NSString *)getLogPath
{
    NSArray *documentsDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logFileDir = [[documentsDirs objectAtIndex:0] stringByAppendingPathComponent:@"crashlog"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:logFileDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    return logFileDir;
}

+ (NSString *)getLogFileName
{
    NSString *strLogFileName = [[YrCrashLogger getLogPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"crash_%@.log", [YrCrashLogger getLogTimeString]]];
    
    return strLogFileName;
}

+ (NSArray *)getCallStackStringArray:(void **)stack size:(int)size
{
    NSMutableArray *callStack = [NSMutableArray array];
    
    char **strs = backtrace_symbols(stack, size);
    
    for (int i = 1; i < 20 && i < size; i++)
    {
        [callStack addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);
    
    return callStack;
}

+ (void)signalCallback:(int)signal info:(siginfo_t *)info uap:(ucontext_t *)uap
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(&(info->si_addr), 1);
    NSString *strInfo = [NSString stringWithFormat:@"signal:%d\naddress:0x%08X\n%@", signal, info->si_addr, [NSString stringWithUTF8String:strs[0]]];
    free(strs);

    YrCrashLogFile *logFile = [[YrCrashLogFile alloc] init];
    
    logFile.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    logFile.type = yrCrashTypeSignal;
    logFile.code = (void *)info->si_code;
    logFile.callStack = [YrCrashLogger getCallStackStringArray:callstack size:frames];
    logFile.info = strInfo;
    logFile.address = info->si_addr;
    
    [logFile writeToFile:[YrCrashLogger getLogFileName]];
    
    [logFile release];
}

+ (void)exceptionCallback:(NSException *)exception
{
    NSArray *stackArray = [exception callStackReturnAddresses];
    void* callstack[128];
    
    for (int i = 0; i < [stackArray count]; i ++)
    {
        callstack[i] = (void *)[[stackArray objectAtIndex:i] unsignedLongValue];
    }
    
    YrCrashLogFile *logFile = [[YrCrashLogFile alloc] init];
    
    logFile.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    logFile.type = yrCrashTypeException;
    logFile.code = 0;
    logFile.callStack = [YrCrashLogger getCallStackStringArray:callstack size:[stackArray count]];
    logFile.info = exception.reason;
    logFile.address = (void *)[[[exception callStackReturnAddresses] objectAtIndex:0] unsignedIntValue];
    
    [logFile writeToFile:[YrCrashLogger getLogFileName]];
    
    [logFile release];

    // unregister handler
	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
}

@end

void uncaughtExceptionHandler(NSException *exception)
{
    [YrCrashLogger exceptionCallback:exception];
}

static void sysSignalHandler(int signal, siginfo_t *info, void *uapVoid)
{
    for (int i = 0; i < n_fatal_signals; i++)
    {
        struct sigaction sa;
        
        memset(&sa, 0, sizeof(sa));
        sa.sa_handler = SIG_DFL;
        sigemptyset(&sa.sa_mask);
        
        sigaction(fatal_signals[i], &sa, NULL);
    }
    
    [YrCrashLogger signalCallback:signal info:info uap:uapVoid];
    
    raise(signal);
}

