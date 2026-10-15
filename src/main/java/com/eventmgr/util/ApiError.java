package com.eventmgr.util;
public class ApiError extends RuntimeException {public final int status;public ApiError(int s,String m){super(m);status=s;}}
